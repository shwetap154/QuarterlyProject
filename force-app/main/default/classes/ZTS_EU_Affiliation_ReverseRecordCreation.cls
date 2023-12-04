/*************************************************************************************
* Name          :    ZTS_EU_Affiliation_ReverseRecordCreation
* Description   :    This Class will create reverse affiliation for every affiliation 
                     inserted. This class will also update the corresponding reverse 
                     affiliation on update of any affiliation
* Author        :    Ninad
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
4/16/2014       Ninad                    Created
**************************************************************************************/
public Class ZTS_EU_Affiliation_ReverseRecordCreation {

    public static Map < String, ZTS_GL_Account_Affiliation_Reverse_Roles__c > customSettingAcc = ZTS_GL_Account_Affiliation_Reverse_Roles__c.getAll();
    /***********
        * Method name  : insertRecord
        * Description  : This method create reverse affiliation for every affiliation created
                         and returns the list to Trigger
        * Return Type  : None
        * Parameters   : List of new affiliations from Trigger
    ***********/
    public static List < ZTS_EU_Account_Affiliations__c > insertRecord(List < ZTS_EU_Account_Affiliations__c > lstNew) {

        List < ZTS_EU_Account_Affiliations__c > lstAff = [Select id,
                                                            ZTS_EU_Affiliated_Account__c, ZTS_EU_Account__r.ZTS_EU_Parent_Id__c,
                                                            ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_Affiliation_Status__c,
                                                            ZTS_EU_Account__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c
                                                        from
                                                            ZTS_EU_Account_Affiliations__c
                                                        where
                                                            Id IN: lstNew];
        set < String > affliationAccountParentIdSet = new set < String > ();
        for (ZTS_EU_Account_Affiliations__c Aff: lstAff) {
            if (aff.ZTS_EU_Account__c != null) {
                if (aff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c != null) {
                    affliationAccountParentIdSet.add(aff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c);
                }
            }
        }
        Map < String, ZTS_EU_Account_Affiliations__c > newaffrecsMap = new Map < String, ZTS_EU_Account_Affiliations__c > ();
        if (affliationAccountParentIdSet != null && affliationAccountParentIdSet.size() > 0)
            for (Account acc: [Select id, ZTS_EU_Parent_Id__c from Account where ZTS_EU_Parent_Id__c IN: affliationAccountParentIdSet AND ZTS_EU_Market__c != 'United States']) {
                for (ZTS_EU_Account_Affiliations__c accAff: lstAff) {
                    if (acc.ZTS_EU_Parent_Id__c == accAff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c) {
                        ZTS_EU_Account_Affiliations__c ztsAff = new ZTS_EU_Account_Affiliations__c();
                        ztsAff.ZTS_EU_Account__c = accAff.ZTS_EU_Affiliated_Account__c;
                        ztsAff.ZTS_EU_Affiliated_Account__c = acc.id;
                        ztsAff.ZTS_EU_Affiliation_Status__c = accAff.ZTS_EU_Affiliation_Status__c;
                        ztsAff.ZTS_EU_Account_influence__c = accAff.ZTS_EU_Account_influence__c;
                        ztsAff.ZTS_EU_Role__c = customSettingAcc.get(accAff.ZTS_EU_Role__c).ZTS_GL_Reverse_Role__c;
                        //New line added
                        if(ztsAff.ZTS_EU_Account__c != ztsAff.ZTS_EU_Affiliated_Account__c)
                        {
                        newaffrecsMap.put(ztsAff.ZTS_EU_Account__c + '-' + ztsAff.ZTS_EU_Affiliated_Account__c + '-' + ztsAff.ZTS_EU_Role__c, ztsAff);
                        }
                    }
                }
            }
/*        try {

        } catch (Exception e) {
               ZTS_EU_Logger.error('Non DMLException***'+e.getMessage(), null, 'ZTS_EU_Affiliation_ReverseRecordCreation.insertRecord');
        } */
                
        return newaffrecsMap.values();
    }
    /***********
        * Method name  : updateAccountRecord
        * Description  : This method update reverse affiliation for every affiliation updated
                         and returns the list to Trigger
        * Return Type  : None
        * Parameters   : List of new affiliations, old map of affiliations, new map of new affiliations from Trigger
    ************/   
    public void updateAccountRecord(List < ZTS_EU_Account_Affiliations__c > triggerNew, List < ZTS_EU_Account_Affiliations__c > triggerOld,
        map < ID, ZTS_EU_Account_Affiliations__c > triggerNewMap, map < ID, ZTS_EU_Account_Affiliations__c > triggerOldMap) {
        map < id, id > accountAffParentIdMap = new map < id, id > ();
        for (ZTS_EU_Account_Affiliations__c acctAff: [Select id, ZTS_EU_Account_Affiliation_Id__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c,
              ZTS_EU_Related_Record_ID__c, ZTS_EU_Role__c, ZTS_EU_Affiliated_Account__c,
              ZTS_EU_Account__c,
              ZTS_EU_Account__r.ZTS_EU_Parent_Id__c
            from
             ZTS_EU_Account_Affiliations__c
             where id IN: triggernew]) {

            accountAffParentIdMap.put(acctAff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c, acctAff.id);
                 System.debug('accountAffParentIdMap keyset'+accountAffParentIdMap.keyset());
                 System.debug('accountAffParentIdMap values'+accountAffParentIdMap.values());

                 
        }
        map < id, list < ZTS_EU_Account_Affiliations__c >> acctAffIdMap = new map < id, list < ZTS_EU_Account_Affiliations__c >> ();

        for (ZTS_EU_Account_Affiliations__c acctAff: [Select id, ZTS_EU_Account__c, ZTS_EU_After_Insert__c, ZTS_EU_Related_Record_ID__c,
               ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_Affiliation_Status__c,
               ZTS_EU_Account_influence__c, ZTS_EU_Role__c, Reverse_Affiliation_Id__c from ZTS_EU_Account_Affiliations__c
                where
                 ZTS_EU_Affiliation_Type__c = 'Reverse'
            AND
                 ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c in : accountAffParentIdMap.keyset() AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ]) {
            list < ZTS_EU_Account_Affiliations__c > acctAffList = acctAffIdMap.containskey(acctAff.ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c) ?
                acctAffIdMap.get(acctAff.ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c) :
                new list < ZTS_EU_Account_Affiliations__c > ();
            acctAffList.add(acctAff);
            acctAffIdMap.put(acctAff.ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c, acctAffList);
                    
        }
        map < id, ZTS_EU_Account_Affiliations__c > acctAffliationUpdateMap = new map < id, ZTS_EU_Account_Affiliations__c > ();
        for (Id parentId: accountAffParentIdMap.keyset()) {
            if (acctAffIdMap.containsKey(parentId)) {
                for (ZTS_EU_Account_Affiliations__c acctAff: acctAffIdMap.get(parentId)) {
                    //Condition modified by SC-010047  
                     if (acctAff.ZTS_EU_Account__c == triggerOldMap.get(accountAffParentIdMap.get(parentId))
                        .ZTS_EU_Affiliated_Account__c && acctAff.ZTS_EU_Affiliated_Account__c == triggerOldMap.get(accountAffParentIdMap.get(parentId))
                        .ZTS_EU_Account__c &&
                        acctAff.ZTS_EU_Role__c == customSettingAcc.get(triggerOldMap.get(accountAffParentIdMap.get(parentId))
                            .ZTS_EU_Role__c)
                        .ZTS_GL_Reverse_Role__c) {
                        acctAff.ZTS_EU_Role__c = customSettingAcc.get(triggerNewMap.get(accountAffParentIdMap.get(parentId))
                                .ZTS_EU_Role__c)
                            .ZTS_GL_Reverse_Role__c;
                        acctAff.ZTS_EU_Affiliation_Status__c = triggerNewMap.get(accountAffParentIdMap.get(parentId))
                            .ZTS_EU_Affiliation_Status__c;
                        acctAff.ZTS_EU_Account__c = triggerNewMap.get(accountAffParentIdMap.get(parentId))
                            .ZTS_EU_Affiliated_Account__c;
                        acctAffliationUpdateMap.put(acctAff.id, acctAff);
                    }
                }
            }
        }
        if (acctAffliationUpdateMap.size() > 0) {
            update acctAffliationUpdateMap.values();
        }
    }
}