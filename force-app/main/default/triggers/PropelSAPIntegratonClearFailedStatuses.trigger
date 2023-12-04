trigger PropelSAPIntegratonClearFailedStatuses on SAP_Material_BOM_Status_Clear_Event__e (after insert) {
    /**
     * When a button is clicked on Changes, a platform event message will be created
     * If there is any of the following is Failed, reset them to null 
     *      PDLM__Item_Revision__c.SAP_Material_Interface_Status__c
     *      PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c
     *      SAP_BOM_Interface_Status__c.SAP_BOM_Interface_Status__c
    */
    
    List<Id> changeIdsForMaterialAndBom = new List<Id>();
    List<Id> changeIdsForMaterialOnly = new List<Id>();
    List<Id> changeIdsForBomOnly = new List<Id>();
    List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
    List<SAP_BOM_Interface_Status__c> bomStatusesToUpdate = new List<SAP_BOM_Interface_Status__c>();

    if (Trigger.isAfter && Trigger.isInsert){
        for (SAP_Material_BOM_Status_Clear_Event__e event : Trigger.New){
            if (event.Status_to_Set__c == 'Material Only'){
                changeIdsForMaterialOnly.add(event.Change_Id__c);
            }
            else if (event.Status_to_Set__c == 'BOM Only'){
                changeIdsForBomOnly.add(event.Change_Id__c);
            }
            else{
                changeIdsForMaterialAndBom.add(event.Change_Id__c);
            }
        }
    }

    System.debug('changeIdsForMaterialAndBom: ' + changeIdsForMaterialAndBom);
    System.debug('changeIdsForMaterialOnly: ' + changeIdsForMaterialOnly);
    System.debug('changeIdsForBomOnly: ' + changeIdsForBomOnly);

    if (changeIdsForMaterialAndBom.size() == 0 && changeIdsForMaterialOnly.size() == 0 && changeIdsForBomOnly.size() == 0){return;}

    //DML Changes
    if (changeIdsForMaterialAndBom.size() > 0){
        revsToUpdate.addAll(ItemRevisionMaterialAndBomStatusesToUpdate(changeIdsForMaterialAndBom));
        bomStatusesToUpdate.addAll(BomStatusesToUpdate(changeIdsForMaterialAndBom));
    }
    
    if (changeIdsForMaterialOnly.size() > 0){
        revsToUpdate.addAll(ItemRevisionMaterialStatusesToUpdate(changeIdsForMaterialOnly));
    }
    
    if (changeIdsForBomOnly.size() > 0){
        bomStatusesToUpdate.addAll(BomStatusesToUpdate(changeIdsForBomOnly));
        revsToUpdate.addAll(ItemRevisionBomStatusesToUpdate(changeIdsForBomOnly));
    }

    System.debug('revsToUpdate: ' + revsToUpdate);
    if (revsToUpdate.size() > 0){
        update revsToUpdate;
    }

    System.debug('bomStatusesToUpdate: ' + bomStatusesToUpdate);
    if (bomStatusesToUpdate.size() > 0){
        update bomStatusesToUpdate;
    }

    public static List<PDLM__Item_Revision__c> ItemRevisionMaterialStatusesToUpdate(List<Id> changeIds){
        List<PDLM__Item_Revision__c> tempRevsToUpdate = new List<PDLM__Item_Revision__c>();

        for (PDLM__Item_Revision__c rev : [SELECT Id, Name, SAP_Material_Interface_Status__c FROM PDLM__Item_Revision__c 
                                           WHERE PDLM__Related_Change__c in : changeIds and SAP_Material_Interface_Status__c = 'Failed']){                       
            rev.SAP_Material_Interface_Status__c = null;
            tempRevsToUpdate.add(rev);
        }

        System.debug('tempRevsToUpdate for Material Only: ' + tempRevsToUpdate);

        return tempRevsToUpdate;
    }

    public static List<PDLM__Item_Revision__c> ItemRevisionBomStatusesToUpdate(List<Id> changeIds){
        List<PDLM__Item_Revision__c> tempRevsToUpdate = new List<PDLM__Item_Revision__c>();

        for (PDLM__Item_Revision__c rev : [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c 
                                           WHERE PDLM__Related_Change__c in : changeIds and SAP_BOM_Interface_Status__c = 'Failed']){                       
            rev.SAP_BOM_Interface_Status__c = null;
            tempRevsToUpdate.add(rev);
        }

        System.debug('tempRevsToUpdate for BOM Only: ' + tempRevsToUpdate);

        return tempRevsToUpdate;
    }

    public static List<PDLM__Item_Revision__c> ItemRevisionMaterialAndBomStatusesToUpdate(List<Id> changeIds){
        List<PDLM__Item_Revision__c> tempRevsToUpdate = new List<PDLM__Item_Revision__c>();

        for (PDLM__Item_Revision__c rev : [SELECT Id, Name, SAP_Material_Interface_Status__c, SAP_BOM_Interface_Status__c 
                                           FROM PDLM__Item_Revision__c WHERE PDLM__Related_Change__c in : changeIds and 
                                           (SAP_Material_Interface_Status__c = 'Failed' OR SAP_BOM_Interface_Status__c = 'Failed')]){ 
            if (rev.SAP_Material_Interface_Status__c == 'Failed'){
                rev.SAP_Material_Interface_Status__c = null;
            }
            
            if (rev.SAP_BOM_Interface_Status__c == 'Failed'){
                rev.SAP_BOM_Interface_Status__c = null;
            }

            tempRevsToUpdate.add(rev);
        }

        System.debug('tempRevsToUpdate for Material and BOM: ' + tempRevsToUpdate);

        return tempRevsToUpdate;
    }

    public static List<SAP_BOM_Interface_Status__c> BomStatusesToUpdate(List<Id> changeIds){
        List<SAP_BOM_Interface_Status__c> tempBomStatusesToUpdate = new List<SAP_BOM_Interface_Status__c>();

        for (SAP_BOM_Interface_Status__c status : [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM SAP_BOM_Interface_Status__c 
                                                   WHERE Item_Revision__r.PDLM__Related_Change__c in : changeIds 
                                                   and SAP_BOM_Interface_Status__c = 'Failed']){             
            status.SAP_BOM_Interface_Status__c = null;
            tempBomStatusesToUpdate.add(status);
        }

        System.debug('tempBomStatusesToUpdate: ' + tempBomStatusesToUpdate);

        return tempBomStatusesToUpdate;
    }
}