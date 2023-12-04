/*************************************************************************************
* Name          :    ZTS_EU_BUG_AccountAffiliation
* Description   :    This code is developed to Insert/update/delete affiliations on an 
                     insert/update/delete of any affiliation on Accounts. When Account 
                     Affiliation is created where “Affiliated Account” is of Account Record 
                     Type “Buying Group”, then add similar Account Affiliation records for all 
                     other accounts in the complete account hierarchy of the account for which 
                     the initial Account Affiliation is created. Same with update/delete operations as well
 
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
 4/10/2014       Chandra            Created

**************************************************************************************/
public class ZTS_EU_BUG_AccountAffiliation {
    /********************************************
    VARIABLES
    ********************************************/
    public static boolean isRecursive = false;
    public static Map < String, ZTS_GL_Account_Affiliation_Reverse_Roles__c > customSettingAcc = ZTS_GL_Account_Affiliation_Reverse_Roles__c.getAll();
    /***********
        * Method name  : insertAffiliates
        * Description  : This method will be called on an insert of any new affiliation to an Acount
                         Soon after the affiliation is created for an Account in the hierarchy, then 
                         all the Accounts in the hierarchy will be inserted with the same affiliated account
        * Return Type  : None
        * Parameters   : List of new affiliations from Trigger
    ***********/

    public static List < ZTS_EU_Account_Affiliations__c > insertAffiliates(List < ZTS_EU_Account_Affiliations__c > lstNew) {

        List < ZTS_EU_Account_Affiliations__c > lstAff = [Select id,
                                                            ZTS_EU_Affiliated_Account__c, ZTS_EU_Account__r.ZTS_EU_Parent_Id__c,
                                                            ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_Affiliation_Status__c,
                                                            ZTS_EU_Account__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c
                                                        from
                                                            ZTS_EU_Account_Affiliations__c
                                                        where
                                                           ZTS_EU_Affiliated_Account__r.RecordType.DeveloperName = 'ZTS_EU_Buying_Group'
                                                            and Id IN: lstNew];
      
        Set < String > affrolekeySet = new Set < String > ();
        set < String > affliationAccountParentIdSet = new set < String > ();
        for (ZTS_EU_Account_Affiliations__c Aff: lstAff) {
            if (aff.ZTS_EU_Account__c != null) {
                affrolekeySet.add(aff.ZTS_EU_Account__c + '-' + aff.ZTS_EU_Affiliated_Account__c + '-' + aff.ZTS_EU_Role__c); // 2-bug3-purchase for
                if (aff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c != null) {
                    affliationAccountParentIdSet.add(aff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c);
                }
            }
        }
        Map < String, ZTS_EU_Account_Affiliations__c > newaffrecsMap = new Map < String, ZTS_EU_Account_Affiliations__c > ();
        if (affliationAccountParentIdSet != null && affliationAccountParentIdSet.size() > 0)
            for (Account acc: [Select id, ZTS_EU_Parent_Id__c, ZTS_EU_Market__c from Account where ZTS_EU_Parent_Id__c IN: affliationAccountParentIdSet AND ZTS_EU_Market__c != 'United States']) {
                //new line
                if(acc.ZTS_EU_Market__c != 'New Zealand' && acc.ZTS_EU_Market__c != 'Australia') {
                for (ZTS_EU_Account_Affiliations__c accAff: lstAff) {
                    if (acc.ZTS_EU_Parent_Id__c == accAff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c) {
                        ZTS_EU_Account_Affiliations__c ztsAff = new ZTS_EU_Account_Affiliations__c();
                        ztsAff.ZTS_EU_Account__c = acc.id;
                        ztsAff.ZTS_EU_Affiliated_Account__c = accAff.ZTS_EU_Affiliated_Account__c;
                        ztsAff.ZTS_EU_Affiliation_Status__c = accAff.ZTS_EU_Affiliation_Status__c;
                        ztsAff.ZTS_EU_Account_influence__c = accAff.ZTS_EU_Account_influence__c;
                        ztsAff.ZTS_EU_Role__c = accAff.ZTS_EU_Role__c;
                        newaffrecsMap.put(ztsAff.ZTS_EU_Account__c + '-' + ztsAff.ZTS_EU_Affiliated_Account__c + '-' + ztsAff.ZTS_EU_Role__c, ztsAff);
                    }
                }
                }
            }
         for (String keyRole: affrolekeySet) {
                if (newaffrecsMap.containskey(keyRole))
                    newaffrecsMap.remove(keyRole);
            }
        
          

        return newaffrecsMap.values();
    }

    public static void beforeupdateAffiliates(List < ZTS_EU_Account_Affiliations__c > lstaffnew) {
            Map < String, ZTS_EU_Account_Affiliations__c > mapAffaftins = new Map < String, ZTS_EU_Account_Affiliations__c > ();
            for (ZTS_EU_Account_Affiliations__c aff: lstaffnew) {
                mapAffaftins.put(aff.ZTS_EU_Account__c + '-' + aff.ZTS_EU_Affiliated_Account__c + '-' + aff.ZTS_EU_Role__c, aff);
            }
            map < String, ZTS_EU_Account_Affiliations__c > mapextstringAff = new map < String, ZTS_EU_Account_Affiliations__c > ();
            for (ZTS_EU_Account_Affiliations__c aff: [Select Id, ZTS_EU_After_Insert__c from ZTS_EU_Account_Affiliations__c where ZTS_EU_After_Insert__c IN: mapAffaftins.keySet() and Id Not IN: lstaffnew AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ]) {
                mapextstringAff.put(aff.ZTS_EU_After_Insert__c, aff);
            }
            for (ZTS_EU_Account_Affiliations__c aff: lstaffnew) {
                String keyvalue = aff.ZTS_EU_Account__c + '-' + aff.ZTS_EU_Affiliated_Account__c + '-' + aff.ZTS_EU_Role__c;
                if (mapextstringAff.containsKey(keyvalue) && (mapextstringAff.get(keyvalue)
                    .id != mapAffaftins.get(keyvalue)
                    .id)) {
                    aff.adderror(System.label.Duplicate_due_to_same_affiliation + mapextstringAff.get(keyvalue));
                }
            }
        }
        /***********
         * Method name  : updateAffiliates
         * Description  :
         * Return Type  : None
         * Parameters   : List of new affiliations from Trigger
         ***********/
    public static void updateAffiliates(List < ZTS_EU_Account_Affiliations__c > lstaffnew, Map < Id, ZTS_EU_Account_Affiliations__c > affoldMap) {

            map < id, ZTS_EU_Account_Affiliations__c > affActTobeUpdatedMap = new map < id, ZTS_EU_Account_Affiliations__c > ();
            Map < String, List < ZTS_EU_Account_Affiliations__c >> parentIdAffAccountMap = new Map < String, List < ZTS_EU_Account_Affiliations__c >> ();
            List < ZTS_EU_Account_Affiliations__c > affAccountlst = new List < ZTS_EU_Account_Affiliations__c > ();

            for (ZTS_EU_Account_Affiliations__c aff: lstaffnew) {
                affAccountlst = parentIdAffAccountMap.containskey(affoldMap.get(aff.id)
                        .ZTS_EU_Account_Affiliation_Id__c) ?
                    parentIdAffAccountMap.get(affoldMap.get(aff.id)
                        .ZTS_EU_Account_Affiliation_Id__c) :
                    new List < ZTS_EU_Account_Affiliations__c > ();
                affAccountlst.add(aff);
                parentIdAffAccountMap.put(affoldMap.get(aff.id)
                    .ZTS_EU_Account_Affiliation_Id__c, affAccountlst);
            }
      
            if (parentIdAffAccountMap != null && parentIdAffAccountMap.size() > 0) {
                for (ZTS_EU_Account_Affiliations__c aff: [select id, ZTS_EU_Affiliated_Account__c, ZTS_EU_Role__c,
              ZTS_EU_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_After_Insert__c,
              ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_Hierarchy_Id__c,
              ZTS_EU_Account_Affiliation_Id__c
               from ZTS_EU_Account_Affiliations__c where
               ZTS_EU_Account_Affiliation_Id__c in : parentIdAffAccountMap.keyset() and
               ZTS_EU_Affiliated_Account__r.RecordType.DeveloperName = 'ZTS_EU_Buying_Group' AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ]) {
                    if (parentIdAffAccountMap.containsKey(aff.ZTS_EU_Account_Affiliation_Id__c)) {
                        for (ZTS_EU_Account_Affiliations__c aff1: parentIdAffAccountMap.get(aff.ZTS_EU_Account_Affiliation_Id__c)) {
                            if (aff.ZTS_EU_Account_Affiliation_Id__c == affoldMap.get(aff1.id)
                                .ZTS_EU_Account_Affiliation_Id__c && aff.id != aff1.id) {
                                aff.ZTS_EU_Role__c = aff1.ZTS_EU_Role__c;
                               //comment added by SC-010047     
                              //  aff.ZTS_EU_Affiliation_Status__c = aff1.ZTS_EU_Affiliation_Status__c;
                                affActTobeUpdatedMap.put(aff.id, aff);
                     
                            }
                        }
                    }
                }
            }
            for (Id affAccount: affoldMap.keyset()) {
                affActTobeUpdatedMap.remove(affAccount);
            }
            isRecursive = true;
         
        if (affActTobeUpdatedMap != null && affActTobeUpdatedMap.size() > 0){
             database.update(affActTobeUpdatedMap.values(), false);
        }
               

        }
        /***********
        * Method name  : insertAffiliatesfromAccount
        * Description  : This method will insert the Affiliations whenever there is a new parent or child added to an
                         Account in the hierarchy. When an Account is inserted on top or on any of the Accounts
        * Return Type  : None
        * Parameters   : List of new affiliations from Trigger and old map of Affiliations
    ***********/

    public static void insertAffiliatesfromAccount(List < Account > newAcc) {
        
        System.debug('we are in insertAffiliatesfromAccount ***');
 
            // Get to map , <id, parentid> and <parentid, id> if Parent_Id__c != null and parentid is changed
            map < id, id > acctParentIdMap = new map < id, id > ();
            List < ZTS_EU_Account_Affiliations__c > insertAffAccount = new List < ZTS_EU_Account_Affiliations__c > ();
            for (Account acc: newAcc) {
                if (acc.ZTS_EU_Parent_Id__c != null && (acc.parentid != null)) {
                    acctParentIdMap.put(acc.id, acc.parentid);
                    acctParentIdMap.put(acc.parentid, acc.id);
                }
            }

            if (acctParentIdMap != null && acctParentIdMap.size() > 0) {
                map < id, list < ZTS_EU_Account_Affiliations__c >> actAffliationsMap = new map < id, list < ZTS_EU_Account_Affiliations__c >> ();
                list < ZTS_EU_Account_Affiliations__c > affLst = new list < ZTS_EU_Account_Affiliations__c > ();
                for (ZTS_EU_Account_Affiliations__c aff: [Select id, ZTS_EU_Account__r.ZTS_EU_Parent_Id__c,
                        ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c,
                        ZTS_EU_Account__c, ZTS_EU_Account_influence__c, ZTS_EU_Role__c
                        from
                            ZTS_EU_Account_Affiliations__c
                        where
                            //Updated Query as part of TPDEV-1829 to filter only Active affiliations                              
                            ZTS_EU_Affiliated_Account__r.RecordType.DeveloperName = 'ZTS_EU_Buying_Group' and ZTS_EU_Affiliation_Status__c!='Inactive'
                    and
                            ZTS_EU_Account__c IN: acctParentIdMap.keySet()]) {
                    affLst = actAffliationsMap.containskey(aff.ZTS_EU_Account__c) ? actAffliationsMap.get(aff.ZTS_EU_Account__c) : new list < ZTS_EU_Account_Affiliations__c > ();
                    affLst.add(aff);
                    actAffliationsMap.put(aff.ZTS_EU_Account__c, affLst);
                }

                // map<account id, set<aff.ZTS_EU_Affiliated_Account__c> for checking duplicate on creation of new records
                map < id, set < id >> actAfflicatedAcctIdSetMap = new map < id, set < id >> ();
                for (String id: acctParentIdMap.keySet()) {
                    set < id > affliationIdSet = new set < id > ();
                    system.debug(' account Id : ' + id);
                    system.debug('actAffliationsMap.containskey(id) ' + actAffliationsMap.containskey(id));
                    if (actAffliationsMap.containskey(id)) {
                        for (ZTS_EU_Account_Affiliations__c aff: actAffliationsMap.get(id))
                            affliationIdSet.add(aff.ZTS_EU_Affiliated_Account__c);
                    }
                    actAfflicatedAcctIdSetMap.put(id, affliationIdSet);
                }
                System.debug('actAfflicatedAcctIdSetMap *****' + actAfflicatedAcctIdSetMap);

                // For each account, parent account checking
                for (String actId: acctParentIdMap.keySet()) {
                    list < ZTS_EU_Account_Affiliations__c > affliationsLst =
                        (acctParentIdMap.get(actId) != null && actAffliationsMap.containskey(acctParentIdMap.get(actId))) ?
                        actAffliationsMap.get(acctParentIdMap.get(actId)) : new list < ZTS_EU_Account_Affiliations__c > ();
                    // Looping through child afflications for parent Account and vice-versa
                    //for(ZTS_EU_Account_Affiliations__c aff :actMap.get(acctParentIdMap.get(actId)).ZTS_GL_Account_Affiliations_Affiliated__r){
                    for (ZTS_EU_Account_Affiliations__c aff: affliationsLst) {
                        // Checking if affliation is already present to avoid duplicate creation
                        if (actAfflicatedAcctIdSetMap.containskey(actId) && !actAfflicatedAcctIdSetMap.get(actId)
                            .contains(aff.ZTS_EU_Affiliated_Account__c)) {
                            ZTS_EU_Account_Affiliations__c affnew = new ZTS_EU_Account_Affiliations__c();
                            //affnew.ZTS_EU_Affiliated_Account__c     = aff.ZTS_EU_Account__c;
                            affnew.ZTS_EU_Affiliated_Account__c = aff.ZTS_EU_Affiliated_Account__c;
                            affnew.ZTS_EU_Account__c = actId;
                            affnew.ZTS_EU_Account_influence__c = aff.ZTS_EU_Account_influence__c;
                            affnew.ZTS_EU_Role__c = aff.ZTS_EU_Role__c;
                            affnew.ZTS_EU_Affiliation_Status__c = aff.ZTS_EU_Affiliation_Status__c;
                            affnew.ZTS_EU_After_Insert__c = String.valueOf(affnew.ZTS_EU_Account__c) + String.valueOf(affnew.ZTS_EU_Affiliated_Account__c);
                            if (affnew.ZTS_EU_After_Insert__c != null)
                                insertAffAccount.add(affnew);
                        }
                    }
                }
            }

            try {
                System.debug('insertAffAccount records are ****'+ insertAffAccount);
               insert insertAffAccount;
            } catch (Exception e) {
                    ZTS_EU_Logger.error('DMLException***'+e.getMessage(), null, 'ZTS_EU_BUG_AccountAffiliation.insertAffiliatesfromAccount');
            }
        }
    
    
 
        /***********
         * Method name  : deleteRecords
         * Description  : This method will delete both Affiliations and their corresponding reverse affiliations
         * Return Type  : None
         * Parameters   : List of new affiliations from Trigger
         ***********/ 
    
      
    public static void deleteBUGAffRecords(list < ZTS_EU_Account_Affiliations__c > accountAffLst) {
        map < id, ZTS_EU_Account_Affiliations__c > parentAccAffMap = new map < id, ZTS_EU_Account_Affiliations__c > ();
        for (ZTS_EU_Account_Affiliations__c acctAff: [Select id, ZTS_EU_Account_Affiliation_Id__c, ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_influence__c,
                      ZTS_EU_Role__c, ZTS_EU_Affiliated_Account__c,
                      ZTS_EU_Account__c,
                      ZTS_EU_Account__r.ZTS_EU_Parent_Id__c
                    from
                      ZTS_EU_Account_Affiliations__c
                    where id IN: accountAffLst]) {
            parentAccAffMap.put(acctAff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c, acctAff);
        }
        map < id, ZTS_EU_Account_Affiliations__c > deleteAcctAffMap = new map < id, ZTS_EU_Account_Affiliations__c > ();
        for (ZTS_EU_Account_Affiliations__C acctAff: [Select id, ZTS_EU_Account__c,
              ZTS_EU_Affiliated_Account__c, ZTS_EU_Affiliation_Status__c,
              ZTS_EU_Account_influence__c, ZTS_EU_Role__c, ZTS_EU_Account__r.ZTS_EU_Parent_Id__c,
              ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c,
              Reverse_Affiliation_Id__c from ZTS_EU_Account_Affiliations__C
              where(ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c in : parentAccAffMap.keyset() or ZTS_EU_Account__r.ZTS_EU_Parent_Id__c in : parentAccAffMap.keyset()) AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ]) {
            Id acctAffParentId = parentAccAffMap.containskey(acctAff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c) ? acctAff.ZTS_EU_Account__r.ZTS_EU_Parent_Id__c : acctAff.ZTS_EU_Affiliated_Account__r.ZTS_EU_Parent_Id__c;
            if (acctAff.id != parentAccAffMap.get(acctAffParentId)
                .id &&
                (acctAff.ZTS_EU_Affiliated_Account__c == parentAccAffMap.get(acctAffParentId)
                    .ZTS_EU_Affiliated_Account__c ||
                    acctAff.ZTS_EU_Account__c == parentAccAffMap.get(acctAffParentId)
                    .ZTS_EU_Affiliated_Account__c) &&
                (acctAff.ZTS_EU_Role__c == parentAccAffMap.get(acctAffParentId)
                    .ZTS_EU_Role__c ||
                    acctAff.ZTS_EU_Role__c == customSettingAcc.get(parentAccAffMap.get(acctAffParentId)
                        .ZTS_EU_Role__c)
                    .ZTS_GL_Reverse_Role__c)) {
                deleteAcctAffMap.put(acctAff.id, acctAff);
            }

        }
        if (deleteAcctAffMap.size() > 0) {
            delete deleteAcctAffMap.values();
        }
    }
}