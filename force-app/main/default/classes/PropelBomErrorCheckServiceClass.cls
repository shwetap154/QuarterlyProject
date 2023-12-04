global with sharing class PropelBomErrorCheckServiceClass {
    /**
     * Parent extended sites should be a subset or equal to the child extended sites
     *  - Children Extended sites
     *          - Propel Lookup Table: Add another field with plant extension information, e.g. US45;US87
     *                  - PDLM__Aseembly__c.PDLM__Item__r.PDLM__Latest_Released_Revision__r.SAP_Material_Setup_Code__r.MSC_Plant_Extensions__c
     *          - Extended Sites: US45;US87;US13
     *                  - PDLM__Aseembly__c.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Extended_Site_s__c
     *  - Parent Extended Sites
     *          - Manufacturing Plant Extension - single pick (US45:01:01)
     *                  - PDLM__Aseembly__c.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c
     *          - Sales/VC BOM Plant Extension - multi-pick
     *                  - PDLM__Aseembly__c.PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c
     * 
     * Check for records in the following categories
     *      - Parent - ZEQU and ZASP that are pre-production, production, and discontinued
     *      - Child - only ROH, ZASP that are pre-production, production, and discontinued
     *      - PDLM__Change__c.PDLM__Approved__c = False
     *      - Check for ECO, ECO-QMS and VCO
     *      - Check only when moving out of Pending and Final File Creation
     * 
     * If there is an error
     *      - Set PDLM__Assembly__c.Parent_Child_BOM_Error__c = TRUE
     */

    public static List<PDLM__Affected_Item__c> afterUpdate(List<PDLM__Change__c> changes) {
        Map<Id, Set<PDLM__Affected_Item__c>> changeIdAisMap = new Map<Id, Set<PDLM__Affected_Item__c>>();
        // Map<Id, Set<String>> changeIdErroredRevsMap = new Map<Id, Set<String>>();
        // Map<Id, PDLM__Change__c> changeIdChangeRecMap = new Map<Id, PDLM__Change__c>();
        Set<Id> parentChildBomErrorRevsList = new Set<Id>();
        List<PDLM__Affected_Item__c> affectedItemsToUpdate = new List<PDLM__Affected_Item__c>();

        // for (PDLM__Change__c change : changes){
        //     changeIdChangeRecMap.put(change.Id, change);
        // }

        for (PDLM__Affected_Item__c ai : [SELECT Id, PDLM__Change_Order_lk__c, PDLM__Item_Revision__c, PDLM__Item_Revision__r.Name, 
                                          PDLM__Item_Revision__r.PDLM__Has_Bom__c, Parent_Child_BOM_Error__c  
                                          FROM PDLM__Affected_Item__c WHERE PDLM__Change_Order_lk__c IN :changes 
                                          AND PDLM__Item_Revision__r.PDLM__Has_Bom__c = true AND PDLM__Change_Order_lk__r.PDLM__Approved__c = false
                                         AND PDLM__Change_Order_lk__r.PDLM__Category__r.Name IN ('ECO', 'ECO-QMS', 'VCO')]){
            if (!changeIdAisMap.containsKey(ai.PDLM__Change_Order_lk__c)){
                changeIdAisMap.put(ai.PDLM__Change_Order_lk__c, new Set<PDLM__Affected_Item__c> {ai});
            }
            else{
                changeIdAisMap.get(ai.PDLM__Change_Order_lk__c).add(ai);
            }
        }

        if (changeIdAisMap.size() == 0){return affectedItemsToUpdate;}

        for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item__r.PDLM__Latest_Released_Revision__r.SAP_Material_Setup_Code__r.MSC_Plant_Extensions__c,
                                    PDLM__Item__r.PDLM__Latest_Released_Revision__r.Extended_Site_s__c, PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c, 
                                    PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c, PDLM__Item_Revision__c FROM PDLM__Assembly__c 
                                    WHERE PDLM__Item_Revision__r.PDLM__Related_Change__c IN :changeIdAisMap.keySet()
                                    AND PDLM__Item__r.SAP_Material_Type__c IN ('ROH', 'ZASP')
                                    AND PDLM__Item__r.PDLM__Latest_Lifecycle_Phase__c IN ('Production', 'Pre-Production', 'Discontinued')
                                    AND PDLM__Item_Revision__r.PDLM__Master_Item__r.SAP_Material_Type__c IN ('ZEQU', 'ZASP')
                                    AND PDLM__Item_Revision__r.PDLM__Lifecycle_Phase__c in ('Production', 'Pre-Production', 'Discontinued')]){
            //Check parent and child extended sites
            Set<String> parentExtendedSite = new Set<String>();
            Set<String> childExtendedSite = new Set<String>();
        
            if (ass.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c != null){
                parentExtendedSite.addAll(ass.PDLM__Item_Revision__r.Manufacturing_Plant_Extension__c.split(';'));
            }

            if (ass.PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c != null){
                parentExtendedSite.addAll(ass.PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c.split(';'));
            }

            if (ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.SAP_Material_Setup_Code__r.MSC_Plant_Extensions__c != null){
                childExtendedSite.addAll(ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.SAP_Material_Setup_Code__r.MSC_Plant_Extensions__c.split(';'));
            }

            if (ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Extended_Site_s__c != null){
                childExtendedSite.addAll(ass.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Extended_Site_s__c.split(';'));
            }

            //Compare Parent and Child Extended Sites
            for (String site : parentExtendedSite){
                String siteFirst4 = site.left(4);

                if (!childExtendedSite.contains(siteFirst4)){
                    parentChildBomErrorRevsList.add(ass.PDLM__Item_Revision__c);
                    break;
                }
            }
        }

        if (parentChildBomErrorRevsList.size() > 0){
            for (Id chgId : changeIdAisMap.keySet()){
                for (PDLM__Affected_Item__c ai :changeIdAisMap.get(chgId)){
                    if (parentChildBomErrorRevsList.contains(ai.PDLM__Item_Revision__c)){
                        PDLM__Affected_Item__c aiToUpdate = new PDLM__Affected_Item__c();
                        aiToUpdate.Id = ai.Id;
                        aiToUpdate.Parent_Child_BOM_Error__c = true;
                        affectedItemsToUpdate.add(aiToUpdate);

                        // if (!changeIdErroredRevsMap.containsKey(chgId)){
                        //     changeIdErroredRevsMap.put(chgId, new Set<String> {ai.PDLM__Item_Revision__r.Name});
                        // }
                        // else{
                        //     changeIdErroredRevsMap.get(chgId).add(ai.PDLM__Item_Revision__r.Name);
                        // }
                    }
                }
            }
        }
        else{
            for (Id chgId : changeIdAisMap.keySet()){
                for (PDLM__Affected_Item__c ai :changeIdAisMap.get(chgId)){
                    if (ai.Parent_Child_BOM_Error__c == true){
                        PDLM__Affected_Item__c aiToUpdate = new PDLM__Affected_Item__c();
                        aiToUpdate.Id = ai.Id;
                        aiToUpdate.Parent_Child_BOM_Error__c = false;
                        affectedItemsToUpdate.add(aiToUpdate);
                    }
                }
            }
        }

        System.debug('affectedItemsToUpdate: ' + affectedItemsToUpdate);

        //Update Affected Items
        if (affectedItemsToUpdate.size() > 0){
            update affectedItemsToUpdate;
        }

        // //Throw an Error
        // if (changeIdErroredRevsMap.size() > 0){
        //     for (Id chgId : changeIdErroredRevsMap.keySet()){
        //         changeIdChangeRecMap.get(chgId).addError(changeIdErroredRevsMap.get(chgId) + ' have children not extended to the Manufacturing and/or Sales/VC BOM Plant Extension.');
        //     }
        // }

        return affectedItemsToUpdate;
    }
}