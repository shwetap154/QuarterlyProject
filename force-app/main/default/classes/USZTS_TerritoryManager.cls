/****************************************************************************************************************************************** 
 * Class Name   : USZTS_TerritoryManager
 * Description  : This class contain operations for Account TerritoryManagement and teams.
 *
 *
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 27 Feb 2014.
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   02/27/2014           Created
 * Raghu                   03/12/2014           Added/Modification to Account Positions
 * Raghu                   04/27/2014           Added Territory Automation
 *****************************************************************************************************************************************/
global with sharing class USZTS_TerritoryManager {

    /*** @JIRATicket   : ZETM-16
        * @ModifiedBy   : Poonam Dalvi
        Following is the Unsed code within this US ORG.
        ***/
    /***********  
     * Method name  : getAccTerritoryUsrGrp
     * Description  : This  method  returns  UserorGroupId for Accounts
     * Return Type  : Map of AccountId(key) and UserorGroupId set(value-set).
     * Parameters   : Account List.
     ***********/
    /*public static Map < Id, Set < Id >> getAccTerritoryUsrGrp(List < Id > accIds) {
        List < AccountShare > accShareList = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE accountId IN: accIds AND RowCause in ('Territory', 'TerritoryManual')];
        Map < Id, Set < Id >> accUserGrpIdMap = new Map < Id, Set < Id >> ();
        for (AccountShare acc_shr: accShareList) {
            if (!accUserGrpIdMap.containsKey(acc_shr.accountId)) {
                accUserGrpIdMap.put(acc_shr.accountId, new Set < Id > ());
            }

            accUserGrpIdMap.get(acc_shr.accountId).add(acc_shr.UserOrGroupId);
        }
        return accUserGrpIdMap;
    }*/


    /***********  
     * Method name  : getAccountTerritories
     * Description  : This  method  returns  UserorGroupId for Accounts
     * Return Type  : Map of AccountId(key) and UserorGroupId set(value-set).
     * Parameters   : Map of AccountId(key) and Territory list.
     ***********/
    /*public static Map < Id, List < Territory2 >> getAccountTerritories(Map < Id, Set < Id >> accTerrUsrGrp) {
        List < Id > grpIdList = new List < Id > ();

        for (Set < Id > grpIdset: accTerrUsrGrp.values()) {
            grpIdList.addAll(grpIdset);
        }

        Map < Id, Group > grpMap = new Map < Id, Group > ([SELECT Id, Name, DeveloperName, Type FROM Group where type = 'Territory'
            and Id IN: grpIdList
        ]);
        //get territory names for user grp
        List < String > dev_GrpNames = new List < String > ();

        for (Group grp: grpMap.values()) {
            dev_GrpNames.add(grp.DeveloperName);
        }

        List < Territory2 > terrList = [SELECT Name, DeveloperName from Territory2 WHERE DeveloperName IN: dev_GrpNames];
        Map < String, Territory2 > terrNameMap = new Map < String, Territory2 > ();

        for (Territory2 terr: terrList) {
            if (!terrNameMap.containsKey(terr.DeveloperName)) {
                terrNameMap.put(terr.DeveloperName, terr);
            }
        }

        Map < Id, List < Territory2 >> accTerrMap = new Map < Id, List < Territory2 >> ();
        for (Id accId: accTerrUsrGrp.keySet()) {
            for (Id grpId: accTerrUsrGrp.get(accId)) {
                if (grpMap.containsKey(grpId)) {
                    if (!accTerrMap.containsKey(accId)) {
                        accTerrMap.put(accId, new List < Territory2 > ());
                    }
                    accTerrMap.get(accId).add(terrNameMap.get(grpMap.get(grpId).DeveloperName));
                }
            }
        }

        return accTerrMap;
    }*/

    /***********  
     * Method name  : fetchAccountWithNARCID
     * Description  : This method fetches account list from narcids
     * Return Type  : Account List.
     * Parameters   : NARCID List.
     ***********/
    public static List < Account > fetchAccountWithNARCID(List < String > narcIds) {
        List < Account > accList = new List < Account > ();
        if (narcIds != null && !narcIds.isEmpty()) {
            accList = [SELECT Id, ZTS_US_NARC_ID__c FROM Account WHERE ZTS_US_NARC_ID__c IN: narcIds AND ZTS_EU_Market__c = 'United States'];
        }

        return accList;
    }

    /***********  
     * Method name  : getNARCID_AccountMap
     * Description  : This method fetches NARCIDs from Account List
     * Return Type  : NARCID-Account Map.
     * Parameters   : Account List.
     ***********/
    public static Map < String, Account > getNARCID_AccountMap(List < Account > acclist) {
        Map < String, Account > narcIdAccMap = new Map < String, Account > ();
        for (Account acc: accList) {
            narcIdAccMap.put(acc.ZTS_US_NARC_ID__c, acc);
        }
        return narcIdAccMap;
    }

    /***********  
     * Method name  : fetch_NARCID_AccountListMap
     * Description  : This method fetches account list from narcids
     * Return Type  : NARCID and Account List Map.
     * Parameters   : NARCIDs Set.
     ***********/
    public static Map < String, List < Account >> fetch_NARCID_AccountListMap(Set < String > narcIds) {
        Map < String, List < Account >> narcIdAccListMap = new Map < String, List < Account >> ();
        if (narcIds != null && !narcIds.isEmpty()) {
            List < Account > accList = [SELECT Id, ZTS_US_NARC_ID__c, ZTS_US_TSF__c FROM Account WHERE ZTS_US_NARC_ID__c IN: narcIds AND ZTS_EU_Market__c = 'United States'];
            for (Account acc: accList) {
                if (!narcIdAccListMap.containsKey(acc.ZTS_US_NARC_ID__c)) {
                    narcIdAccListMap.put(acc.ZTS_US_NARC_ID__c, new List < Account > ());
                }

                narcIdAccListMap.get(acc.ZTS_US_NARC_ID__c).add(acc);
            }
        }

        return narcIdAccListMap;
    }


    /***********  
     * Method name  : fetch_NARCID_AccountsMap
     * Description  : This method fetches account list from narcids
     * Return Type  : NARCID and Account List Map.
     * Parameters   : AccountID Set.
     ***********/
    public static Map < String, List < Account >> fetch_NARCID_AccountsMap(Set < Id > accIds) {
        Map < String, List < Account >> narcIdAccListMap = new Map < String, List < Account >> ();
        if (accIds != null && !accIds.isEmpty()) {
            List < Account > accList = [SELECT Id, ZTS_US_NARC_ID__c, ZTS_US_TSF__c FROM Account WHERE Id IN: accIds AND ZTS_EU_Market__c = 'United States'];
            for (Account acc: accList) {
                if (!narcIdAccListMap.containsKey(acc.ZTS_US_NARC_ID__c)) {
                    narcIdAccListMap.put(acc.ZTS_US_NARC_ID__c, new List < Account > ());
                }

                narcIdAccListMap.get(acc.ZTS_US_NARC_ID__c).add(acc);
            }
        }

        return narcIdAccListMap;
    }

    /***********  
     * Method name  : fetch_NARCID_Accounts
     * Description  : This method fetches account list from narcids
     * Return Type  : NARCID and Account List Map.
     * Parameters   : NARCIDs Set.
     ***********/
    public static Map < String, Account > fetch_NARCID_Accounts(Set < String > narcIds) {
        Map < String, Account > narcIdAccListMap = new Map < String, Account > ();
        if (narcIds != null && !narcIds.isEmpty()) {
            List < Account > accList = [SELECT Id, ZTS_US_NARC_ID__c, ZTS_US_TSF__c FROM Account WHERE ZTS_US_NARC_ID__c IN: narcIds AND ZTS_EU_Market__c = 'United States'];
            for (Account acc: accList) {
                narcIdAccListMap.put(acc.ZTS_US_NARC_ID__c, acc);
            }

        }

        return narcIdAccListMap;
    }


    /***********  
     * Method name  : getAccountInfo
     * Description  : This method fetches NARCID associated accounts
     * Return Type  : NARCID and Account List Map.
     * Parameters   : NARCIDs Set.
     ***********/
    public static Map < String, Account > getAccountInfo(List < Id > accIds) 
    {
        Map < String, Account > narcIdAccListMap = new Map < String, Account > ();
        if (accIds != null && !accIds.isEmpty()) 
        {
            List < Account > accList = [SELECT Id, ZTS_US_NARC_ID__c, ZTS_US_TSF__c FROM Account WHERE Id IN: accIds AND ZTS_EU_Market__c = 'United States'];

            for (Account acc: accList) 
                narcIdAccListMap.put(acc.ZTS_US_NARC_ID__c, acc);
        }
        return narcIdAccListMap;
    }


    /***********  
     * Method name  : getNARCIDs
     * Description  : This method retrieves  NARCIDs from Account Territory List list from narcids
     * Return Type  : NARCIDs Set.
     * Parameters   : Account Territory List.
     ***********/
    public static Set < String > getNARCIDs(List < ZTS_AccountTerritory__c > acc_terrList) {
        Set < String > narcIDSet = new Set < String > ();
        for (ZTS_AccountTerritory__c accTerr: acc_terrList) {
            narcIDSet.add(accTerr.ZTS_NARC_ID__c);
        }
        return narcIDSet;
    }

    /***********  
     * Method name  : zoetisTerritoryUpdate
     * Description  : This webservice method sync custom territory record with standard territory records.
     * Return Type  : None.
     * Parameters   : Custom Territory ID List.
     ***********/
    webservice static void zoetisTerritoryUpdate(List < String > terrIdList) {

        USZTS_TerritoryManager.SFA terrSFA = new USZTS_TerritoryManager.SFA();
        terrSFA.upsertZoetisTerritory(terrIdList);
    }


    /***********  
     * Method name  : populateAccountTSF
     * Description  : This method populate Account TSF with Account Territory information.
     * Return Type  : None.
     * Parameters   : Account Territory List & isDelete flag.
     ***********/
    public static void populateAccountTSF(List < ZTS_AccountTerritory__c > accTerrList, boolean isDelete) 
    {
        Set < Id > accIdSet = new Set < Id > ();
        for (ZTS_AccountTerritory__c accterr: accTerrList) 
            accIdSet.add(accterr.ZTS_EU_Account__c);

        Map < Id, Account > accMap = new Map < Id, Account > ([SELECT Id, ZTS_US_NARC_ID__c, ZTS_US_TSF__c FROM Account WHERE Id IN: accIdSet AND ZTS_EU_Market__c = 'United States']);
        Map<Id,Account> accMapWithTSFUpdate=new Map<Id,Account>();

        for (ZTS_AccountTerritory__c acc_terr: accTerrList) 
        {
            if (accMap.containsKey(acc_terr.ZTS_EU_Account__c)) 
            {
                Account acc = !accMapWithTSFUpdate.containsKey(acc_terr.ZTS_EU_Account__c)
                                ? accMap.get(acc_terr.ZTS_EU_Account__c) : accMapWithTSFUpdate.get(acc_terr.ZTS_EU_Account__c);
            
                if (!String.isBlank(acc.ZTS_US_TSF__c)) 
                {
                    Set < String > tsf_tokens = new Set < String > ();
                    tsf_tokens.addAll(acc.ZTS_US_TSF__c.split(';'));
                    //prevent duplicates entry in Account TSF field
                    if (!tsf_tokens.contains(acc_terr.ZTS_TerrName__c) && !isDelete) 
                    {
                        acc.ZTS_US_TSF__c += ';' + acc_terr.ZTS_TerrName__c;
                        accMapWithTSFUpdate.put(acc.id,acc);
                    }

                    //CLEAR TSF for Deleted Account Territories
                    if (isDelete) 
                    {
                        if (tsf_tokens.contains(acc_terr.ZTS_TerrName__c)) 
                        {
                            acc.ZTS_US_TSF__c = tsf_tokens.size() > 1 ? acc.ZTS_US_TSF__c.replace((';' + acc_terr.ZTS_TerrName__c), '') : acc.ZTS_US_TSF__c.replace(acc_terr.ZTS_TerrName__c, '');
                            accMapWithTSFUpdate.put(acc.id,acc);
                        }
                    }
                } 
                else if (!isDelete) 
                {
                    acc.ZTS_US_TSF__c = acc_terr.ZTS_TerrName__c;
                    accMapWithTSFUpdate.put(acc.id,acc);
                }
            }
        }
        if (!accMapWithTSFUpdate.isEmpty()) 
        {
            List < Database.Saveresult > results = Database.update(accMapWithTSFUpdate.values(), false);
            ZTS_EU_Logger.error(results, 'Territory Management -populateAccountTSF');
        }
    }

    /***********  
     * Method name  : updateAccountTSF
     * Description  : This method updates Account TSF field.
     * Return Type  : None.
     * Parameters   : Account Territory ID List.
     ***********/
    /*public static void updateAccountTSF(List < Id > accTerrIds) {

        List < ZTS_AccountTerritory__c > accTerrList = [SELECT Id, ZTS_NARC_ID__c, Name, ZTS_TerrName__c, ZTS_EU_Territory__c FROM ZTS_AccountTerritory__c
            WHERE Id IN: accTerrIds
        ];
        populateAccountTSF(accterrList, true);

    }*/


    /***********  
     * Method name  : removeTerritories
     * Description  : This webservice method removes standard territories.
     * Return Type  : None.
     * Parameters   : Custom Territory ID List.
     ***********/
    webservice static void removeTerritories(List < String > terrIdList) {
        List < Id > childTerrIds = new List < Id > ();
        List < Id > parentTerrIds = new List < Id > ();
        List < ZTS_EU_Territory__c > cust_TerrList = [SELECT Name, ZTS_EU_Is_Active__c, ZTS_EU_Parent_Territory__c, ZTS_EU_Type__c, Id FROM ZTS_EU_Territory__c WHERE ID IN: terrIdList AND ZTS_EU_Market__c = 'United States'];
        //first child territories have to be delete in order to remove parent territories
        for (ZTS_EU_Territory__c terr: cust_TerrList) {
            if (terr.ZTS_EU_Parent_Territory__c != null) {
                childTerrIds.add(terr.id);
            } else {
                parentTerrIds.add(terr.id);
            }
        }


        childTerrIds.addAll(parentTerrIds);
        //delete associated standard territories
        List < Territory2 > stdTerritoryList = [SELECT Id, name FROM Territory2 WHERE ZTS_Terr_SFID__c IN: childTerrIds];
        List < Id > stdTerrIdList = new List < Id > ();
        for (Territory2 terr: stdTerritoryList) {
            stdTerrIdList.add(terr.id);
        }
        removeTerritory(stdTerrIdList);

    }

    /***********  
     * Method name  : removeTerritory
     * Description  : This webservice method removes custom territories.
     * Return Type  : None.
     * Parameters   : Custom Territory ID List.
     ***********/
    webservice static void removeTerritory(List < Id > terrIdList) {
        try {
            Database.delete(terrIdList);
        } catch (DMLException ex) {
            System.debug(ex);
            String msg = '';
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                msg = ex.getDMLMessage(i) + '\n';
            }
            ZTS_EU_Logger.errorAsync('Territory Manager -removeTerritories(custom territory) - ' + msg, null, 'Territory Mgmt-DML Operation');
            //show error msg explicity to end TM Admin user
            throw new ZTS_ZoetisException(msg);
        }

    }


    /***********  
     * Method name  : updateAssignedFlag
     * Description  : This future method is called from Std. Territory trigger which updates the assigned flag and std.territory id  in custom territory records.
     * Return Type  : None.
     * Parameters   : Custom Territory ID List.
     ***********/
    
    /*@future
    global static void updateAssignedFlag(List < Id > cust_terrIds) {
        List < ZTS_EU_Territory__c > custTerrList = new List < ZTS_EU_Territory__c > ();

        //fetch STD territories
        List < Territory2 > stdTerrList = [SELECT Id, ZTS_Terr_SFID__c, Name FROM Territory2 WHERE ZTS_Terr_SFID__c IN: cust_terrIds];
        Map < Id, Territory2 > custTerrIdKeyTerrMap = new Map < Id, Territory2 > ();
        for (Territory2 terr: stdTerrList) {
            custTerrIdKeyTerrMap.put(terr.ZTS_Terr_SFID__c, terr);
        }
        for (Id cust_terrId: cust_terrIds) {
            ZTS_EU_Territory__c custTerr = new ZTS_EU_Territory__c(Id = cust_terrId, ZTS_EU_Territory_synced__c = true, ZTS_EU_Terr_SFID__c = custTerrIdKeyTerrMap.get(cust_terrId).id);
            custTerrList.add(custTerr);
        }


        List < Database.Saveresult > results = Database.update(custTerrList, true);
        ZTS_EU_Logger.error(results, 'Territory Management -updateAssignedFlag');
    }*/

    /***********  
     * Method name  : getAccountTerritoryRecordsForAccTeam
     * Description  : This method returns a Map of associated for account teams/positions
     * Return Type  : Map with accountid and terrid as combination key and account territory values.
     * Parameters   : AccountPosition/Team List.
     ***********/
    public static Map < String, ZTS_AccountTerritory__c > getAccountTerritoryRecordsForAccTeam(List < ZTS_EU_Account_Position__c > accTeamsList) {
        List < ZTS_EU_Territory__c > custTerrList = new List < ZTS_EU_Territory__c > ();
        Set < String > acc_terr_keys = new Set < String > (); //ZTS_Acc_Terr_Key__c
        Set<Id> accIds=new Set<Id>();
        Set<String> terrIds=new Set<String>();
        for (ZTS_EU_Account_Position__c atm: accTeamsList) {
            if (atm.ZTS_AccountTerritory__c == null && atm.ZTS_EU_Account__c != null && !String.isBlank(atm.ZTS_US_Territory_ID__c)) {
                accIds.add(atm.ZTS_EU_Account__c);
                terrIds.add(atm.ZTS_US_Territory_ID__c);
                acc_terr_keys.add(atm.ZTS_EU_Account__c + ':' + atm.ZTS_US_Territory_ID__c);
            }
        }

       /* List < ZTS_AccountTerritory__c > accTerrList = [SELECT Id, ZTS_EU_Account__c, ZTS_Territory_SF_ID__c, ZTS_EU_Territory__c, ZTS_US_Exception_Alignment__c,
            ZTS_Acc_Terr_Key__c FROM ZTS_AccountTerritory__c WHERE ZTS_Acc_Terr_Key__c IN: acc_terr_keys
            //ORDER BY CreatedDate
        ];*/
        
        List < ZTS_AccountTerritory__c > accTerrList = [SELECT Id, ZTS_EU_Account__c, ZTS_Territory_SF_ID__c, ZTS_EU_Territory__c, ZTS_Exception_Alignment__c,
            ZTS_Acc_Terr_Key__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Account__c IN: accIds AND ZTS_EU_Territory__c IN :terrIds
            
        ];

        Map < String, ZTS_AccountTerritory__c > accTerrKeyMap = new Map < String, ZTS_AccountTerritory__c > ();

        for (ZTS_AccountTerritory__c accTerr: accTerrList) {
            accTerrKeyMap.put(accTerr.ZTS_Acc_Terr_Key__c, accTerr);
        }

        return accTerrKeyMap;
    }



    /********************************************
      TM Salesforce Automation(SFA) class 
    *******************************************/
    global class SFA {

        /***********  
         * Method name  : upsertZoetisTerritory
         * Description  : This method Syncs Custom Territory object records to Standard Salesforce Territories on creation.
         * Return Type  : Territory list.
         * Parameters   : Custom Territory ID - list.
         ***********/
        public List < Territory2 > upsertZoetisTerritory(List < String > terrIds) {
            List < Territory2 > allTerrList = [SELECT AccountAccessLevel, CaseAccessLevel, /*RestrictOpportunityTransfer, */ContactAccessLevel, OpportunityAccessLevel,
                ParentTerritory2Id, SystemModstamp, Id, Name, ZTS_Terr_SFID__c FROM Territory2
            ];

            //Map - key(ZTS_US_Terr_SFID) with territory values                          
            Map < String, Territory2 > terrStd_Map = new Map < String, Territory2 > ();
            for (Territory2 terr: allTerrList) {
                terrStd_Map.put(terr.ZTS_Terr_SFID__c, terr);
            }

            List < Territory2 > terrList = new List < Territory2 > ();
            List < ZTS_EU_Territory__c > cust_TerrList = [SELECT Id, Name, ZTS_EU_Is_Active__c, ZTS_EU_Parent_Territory__c, ZTS_EU_Type__c, ZTS_EU_Description__c FROM ZTS_EU_Territory__c WHERE ID IN: terrIds AND ZTS_EU_Market__c = 'United States'];
            
            List<ETM_Required_Ids__mdt> mdtETMRequiredIds = [SELECT DeveloperName,ETM_Model_ID__c,ETM_Type_Id__c FROM ETM_Required_Ids__mdt Where DeveloperName = 'Default_Values' Limit 1];

            for (ZTS_EU_Territory__c terr_cust: cust_TerrList) {

                String devName = 'x_' + terr_cust.Name.replaceAll('\\s', '').replaceAll('-', '_').replaceAll(',', '_'); //DeveloperName=devName,
                Territory2 terr_std = new Territory2(Name = terr_cust.name, ZTS_Terr_SFID__c = terr_cust.id, Description = terr_cust.ZTS_EU_Description__c,
                    AccountAccessLevel = ZTS_EU_GlobalConstants.DEFAULT_ACC_ACCESS, CaseAccessLevel = ZTS_EU_GlobalConstants.DEFAULT_CASE_ACCESS,
                    OpportunityAccessLevel = ZTS_EU_GlobalConstants.DEFAULT_OPP_ACCESS, /*, RestrictOpportunityTransfer = ZTS_EU_GlobalConstants.DEFAULT_RESTRICT_OPP_TRANSFER*/
                    Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c, Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c, DeveloperName = devName);

                if (terr_cust.ZTS_EU_Parent_Territory__c != null && terrStd_Map.containsKey(terr_cust.ZTS_EU_Parent_Territory__c)) {
                    terr_std.ParentTerritory2Id = terrStd_Map.get(terr_cust.ZTS_EU_Parent_Territory__c).id;
                }

                //existing territory set id
                if (terrStd_Map.containsKey(terr_cust.id)) {
                    terr_std.id = terrStd_Map.get(terr_cust.id).Id;
                }

                //provide check to prevent unsync parent-child territory    
                if (terr_cust.ZTS_EU_Parent_Territory__c == null || (terr_cust.ZTS_EU_Parent_Territory__c != null && terr_std.ParentTerritory2Id != null))
                    terrList.add(terr_std);
            }
            List < Database.Upsertresult > results = Database.upsert(terrList, false);

            String errmsgs = ZTS_EU_Logger.getDMLErrorMsg(results);
            if (!String.isBlank(errmsgs)) 
            {
                ZTS_EU_Logger.errorAsync(errmsgs, 'Territory Management-upsertZoetisTerritory');
            }
            return terrList;
        }

    }

    /***********  
     * Method name  : updateCustomTerrAssignedFlag
     * Description  : This method updates CustomTerritory Assigned Status Flag after Std Territory is created.
     * Return Type  : None.
     * Parameters   : None.
     ***********/
    webservice static List < ZTS_EU_Territory__c > updateCustomTerrAssignedFlag() {
        Map < String, Territory2 > terrMap = new Map < String, Territory2 > ();

        //get all territories created today
        List < Territory2 > terrList = [SELECT Id, name, ZTS_Terr_SFID__c, SystemModstamp FROM Territory2 WHERE SystemModstamp = TODAY AND ZTS_Terr_SFID__c != ''];
        for (Territory2 terr: terrList) {
            terrMap.put(terr.ZTS_Terr_SFID__c, terr);
        }
        //get custom territories 
        List < ZTS_EU_Territory__c > cterrList = [SELECT Id, ZTS_EU_Parent_Territory__c, ZTS_EU_Territory_synced__c, ZTS_EU_Terr_SFID__c FROM ZTS_EU_Territory__c
            WHERE Id IN: terrMap.keySet() AND ZTS_EU_Market__c = 'United States'
        ];
        List < ZTS_EU_Territory__c > cterrToUpdate = new List < ZTS_EU_Territory__c > ();
        for (ZTS_EU_Territory__c cterr: cterrList) {
            if (!cterr.ZTS_EU_Territory_synced__c || String.isBlank(cterr.ZTS_EU_Terr_SFID__c)) {
                cterr.ZTS_EU_Territory_synced__c = true;
                cterr.ZTS_EU_Terr_SFID__c = terrMap.get(cterr.id).id;
                cterrToUpdate.add(cterr);
            }
        }
        update cterrToUpdate;
        return cterrToUpdate;
    }


    /***********  
     * Method name  : getUserTerritoryCSV_ToInsert
     * Description  : This method prepares  UserTerritory2Association  CSV data for insertion.
     * Return Type  : String - CSV Std.UserTerritory2Association DATA.
     * Parameters   : Custom UserTerritory2Association  - list.
     ***********/
    public static String getUserTerritoryCSV_ToInsert(List < ZTS_EU_Position__c > userTerrList) {
        //prepare UserTerritory2Association rules data
        String HEADER = '"Territory2Id","UserId"\n';
        String ROWS = '';
        for (ZTS_EU_Position__c userTerr: userTerrList) {
            if (!String.isBlank(userTerr.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c)) {
                String LINE = userTerr.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c + ',' + userTerr.ZTS_EU_Employee__c + '\n';
                ROWS += line;
            }
        }


        return String.isBlank(ROWS) == false ? HEADER + ROWS : '';
    }

    /***********  
     * Method name  : getSFID_ToDelete
     * Description  : This method prepares  SObject ID  CSV data for deletion.
     * Return Type  : String - CSV Std.UserTerritory2Association DATA.
     * Parameters   : SObjects list.
     ***********/
    public static String getSFID_ToDelete(List < SObject > SObjectList) {
        String HEADER = '"Id"\n';
        String ROWS = '';
        for (Sobject sobj: SObjectList) {
            String LINE = sobj.get('Id') + '\n';
            ROWS += line;
        }


        return String.isBlank(ROWS) == false ? HEADER + ROWS : '';
    }

    /***********  
     * Method name  : insertUserTerritoryBatch
     * Description  : This method add UserTerritories records for Batch insert.
     * Return Type  : None.
     * Parameters   : UserTerritory2Association custom object list.
     ***********/

    public static JobUtilities insertUserTerritoryBatch(List < ZTS_EU_Position__c > userTerrList) {
        JobUtilities.JobInfo job = new JobUtilities.JobInfo('UserTerritory2Association', JobUtilities.OPERATION.insert_x, JobUtilities.CONCURRENCY_MODE.Serial, JobUtilities.CONTENT_TYPE.CSV);
        JobUtilities job_utl = new JobUtilities();
        job_utl.sessionId = UserInfo.getSessionId();
        String payload = getUserTerritoryCSV_ToInsert(userTerrList);
        System.debug('Payload : ' + payload);
        if (String.isBlank(payload)) {
            return job_utl;
        }

        String jobId = job_utl.createJob(job, new JobUtilities.BulkConnection());

        if (String.isBlank(jobId)) 
        {
            throw new ZTS_ZoetisException('Job creation failed (Terriotry Manager - insertUserTerritoryBatch) , see error log for more information');
        }

        String batchId = job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);

        return job_utl;
    }


    /***********  
     * Method name  : getTerritoryGroupMap
     * Description  : This method queries Groups associated with Std Territories.
     * Return Type  : Map - Territory ID and associated Group list value.
     * Parameters   : Std Territory Id list.
     ***********/
    public static Map < Id, List < Group >> getTerritoryGroupMap(List < Id > terrId) {
        Map < Id, List < Group >> terrGrpMap = new Map < Id, List < Group >> ();
        List < Group > terrGrpList = [SELECT Type, Name, OwnerId, RelatedId, Email, Id FROM Group WHERE Type = 'Territory'
            AND RelatedId IN: terrId
        ];
        for (Group terrGrp: terrGrpList) {
            if (!terrGrpMap.containsKey(terrGrp.RelatedId)) {
                terrGrpMap.put(terrGrp.RelatedId, new List < Group > ());
            }
            terrGrpMap.get(terrGrp.RelatedId).add(terrGrp);
        }
        return terrGrpMap;
    }

    /***********  
     * Method name  : addToAccountShares
     * Description  : This method adds AccountId and Territory Groups to Account Sharing table.
     * Return Type  : Map - Territory ID and associated Group list value.
     * Parameters   : Std Territory Id list.
     ***********/
    public static List < ObjectTerritory2Association > createAccountShares(Id accId, Id idTerritory2)
    {
        List<ObjectTerritory2Association> lstObjectTerritory2Association = new List<ObjectTerritory2Association>();

        ObjectTerritory2Association obj = new ObjectTerritory2Association(ObjectId = accId, Territory2Id = idTerritory2, AssociationCause='Territory2Manual' );
        lstObjectTerritory2Association.add(obj);
        return lstObjectTerritory2Association;
    }


    /***********  
     * Method name  : deleteAccountShares
     * Description  : This method removes entries in  Account Share table.
     * Return Type  : None.
     * Parameters   : AccountTerritory list.
     ***********/
    public static void deleteAccountShares(List < ZTS_AccountTerritory__c > accTerrList) 
    {
        List < String > narcIdList = new List < String > ();
        List < Id > stdTerrIdList = new List < Id > ();
        List<ObjectTerritory2Association> accShareList = new List<ObjectTerritory2Association>();

        for (ZTS_AccountTerritory__c acc_terr: accTerrList) 
        {
            narcIdList.add(acc_terr.ZTS_NARC_ID__c);
            stdTerrIdList.add(acc_terr.ZTS_Territory_SF_ID__c);
        }

        Map < Id, Account > accMap = new Map < Id, Account > ([SELECT Id, ZTS_US_NARC_ID__c FROM Account WHERE ZTS_US_NARC_ID__c IN: narcIdList AND ZTS_EU_Market__c = 'United States']);
        List < ObjectTerritory2Association > accSharesToDelete = [SELECT Id FROM ObjectTerritory2Association WHERE ObjectId IN: accMap.keySet() AND Territory2Id = : stdTerrIdList];

        List < Database.Deleteresult > delResults = Database.delete(accSharesToDelete, false);
        ZTS_EU_Logger.error(delResults, 'Territory Management-deleteAccountShares');

    }

    /***********  
     * Method name  : deleteAccountShares
     * Description  : This  method  removes Territory record account shares for Inactive accounts
     * Return Type  : None
     * Parameters   : Account Id List.
     ***********/
    public static void deleteAccountTerritoryShares(List < Id > accIds) 
    {
        if (!accIds.isEmpty()) 
        {
            List < ObjectTerritory2Association > accShareList = [SELECT Id, ObjectId, Territory2Id FROM ObjectTerritory2Association 
                                                  WHERE ObjectId IN: accIds AND AssociationCause in ('Territory', 'Territory2Manual')];                                              
            List < Database.Deleteresult > delResults = Database.delete(accShareList, false);
            ZTS_EU_Logger.error(delResults, 'Territory Management-deleteAccountTerritoryShares');
        }
    }
    
   /***********  
     * Method name  : deleteAccountTerritory
     * Description  : This method is invoked on deletion of account territories
     * Return Type  : None
     * Parameters   : Account Territory List,boolean isOriginTrigger used to check method called from trigger context.
     ***********/
    public static void deleteAccountTerritory(List < ZTS_AccountTerritory__c > accterrList,boolean isOrginTrigger) 
    {
        /*Set < Id > accIds = new Set < Id > ();
        Set < Id > terrIds = new Set < Id > ();
        Set < String > deleteAccTerrSet = new Set < String > ();

        for (ZTS_AccountTerritory__c accTerr: accterrList) 
        {
            accIds.add(accTerr.ZTS_EU_Account__c);
            terrIds.add(accTerr.ZTS_US_Territory__c);
            deleteAccTerrSet.add(accTerr.ZTS_EU_Account__c + ':' + accTerr.ZTS_US_Territory__c);
        }
        //Delete associated AccountPosition 
        
        List < ZTS_EU_Account_Position__c > acc_pos_list = [SELECT Id, Name, ZTS_EU_Position__c, ZTS_EU_Territory__c, , ZTS_EU_Position__r.ZTS_US_Territory__c,
                                                            ZTS_EU_Account__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c IN: accIds AND ZTS_EU_Position__c != null
                                                            AND ZTS_EU_Position__r.ZTS_US_Territory__c IN: terrIds AND ZTS_EU_Market__c = 'United States'];

        List < ZTS_EU_Account_Position__c > acc_pos_to_del = new List < ZTS_EU_Account_Position__c > ();

        for (ZTS_EU_Account_Position__c acc_pos: acc_pos_list) 
        {
            String acc_terr = acc_pos.ZTS_EU_Account__c + ':' + acc_pos.ZTS_EU_Position__r.ZTS_US_Territory__c;
            if (deleteAccTerrSet.contains(acc_terr)) 
                acc_pos_to_del.add(acc_pos);
        }

        List < Database.DeleteResult > results = Database.delete(acc_pos_to_del, false);
        ZTS_EU_Logger.error(results, 'Territory Management-Account Position/Team Deletion');
        //Remove Account record access
        USZTS_TerritoryManager.deleteAccountShares(Trigger.old);
        //update TSF field in Account records
        USZTS_TerritoryManager.populateAccountTSF(Trigger.old, Trigger.isDelete);
        
        //delete account territories if not called from trigger
        if(!isOrginTrigger)
        {
            List<Database.Deleteresult> delresults=Database.delete(accterrList,false);
            ZTS_EU_Logger.error(delresults, 'Territory Management-Account Territory Deletion'); 
        }*/
    }


    /***********  
     * Method name  : fetchTerritoryAccTerrMap
     * Description  : This method creates returns the Account Territory list.
     * Return Type  : void.
     * Parameters   : UserTerrit.
     ***********/

    public static Map < Id, ZTS_EU_Territory__c > fetchTerritoryAccTerrMap(List < ZTS_EU_Position__c > userTerritoryList) {
        Set < String > terrIdentifierSet = new Set < String > ();
        for (ZTS_EU_Position__c userTerr: userTerritoryList) {
            //fetch the custom territory identifier for all new positions
            terrIdentifierSet.add(userTerr.ZTS_EU_Territory__c);
        }

        //get all account territories for the position/team territories
        Map < Id, ZTS_EU_Territory__c > terrMap = new Map < Id, ZTS_EU_Territory__c > ([SELECT Name, Id, ZTS_EU_Is_Active__c, (SELECT ZTS_NARC_ID__c, ZTS_EU_Territory__c, ZTS_EU_Account__c FROM Account_Territories__r WHERE ZTS_EU_Account__c != '') FROM ZTS_EU_Territory__c WHERE Id IN: terrIdentifierSet AND ZTS_EU_Market__c = 'United States']);
        return terrMap;
    }




    /***********  
     * Method name  : createAccountTeams
     * Description  : This method creates Account Teams from UserTerrirotyList
     * Return Type  : void.
     * Parameters   : CustomUserTerritoryList and AccountTerritoryList.
     ***********/
    public static void createAccountTeams(List < ZTS_EU_Position__c > custUsrTerrList, List < ZTS_AccountTerritory__c > accTeamList) {

        Map < Id, List < ZTS_AccountTerritory__c >> terrAccMap = new Map < Id, List < ZTS_AccountTerritory__c >> ();

        for (ZTS_AccountTerritory__c accTerr: accTeamList) 
        {
            if (accTerr.ZTS_EU_Territory__c != null) 
            {
                if (!terrAccMap.containsKey(accTerr.ZTS_EU_Territory__c)) 
                    terrAccMap.put(accTerr.ZTS_EU_Territory__c, new List < ZTS_AccountTerritory__c > ());
                terrAccMap.get(accTerr.ZTS_EU_Territory__c).add(accTerr);
            }
        }
 
        /*****Optmised to convert the Set into list directly, no more needed tof the list******/
        //List < ZTS_EU_Account_Position__c > acc_pos_List = new List < ZTS_EU_Account_Position__c > ();
        Set < ZTS_EU_Account_Position__c > acc_pos_set = new Set < ZTS_EU_Account_Position__c > ();
        List<ZTS_EU_Position__c> updUsrTerrProcessFlagList=new List<ZTS_EU_Position__c>();

        for (ZTS_EU_Position__c userTerr: custUsrTerrList) 
        {
            if (userTerr.ZTS_EU_Territory__c != null && terrAccMap.containsKey(userTerr.ZTS_EU_Territory__c)) 
            {   
                for (ZTS_AccountTerritory__c accTerr: terrAccMap.get(userTerr.ZTS_EU_Territory__c)) 
                {
                    if (accTerr.ZTS_NARC_ID__c != null && accTerr.ZTS_EU_Account__c != null) 
                    {
                        String acc_userterr_key = accTerr.ZTS_EU_Account__c + ':' + userTerr.id;
                        ZTS_EU_Account_Position__c acc_pos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = accTerr.ZTS_EU_Account__c, ZTS_EU_Position__c = userTerr.id,
                        ZTS_AccountUserTerrUniqueKey__c = acc_userterr_key, ZTS_AccountTerritory__c = accTerr.id);
                        acc_pos.ZTS_NotificationUser__c= userTerr.ZTS_EU_Employee__c!=null?userTerr.ZTS_EU_Employee__c:null;
                        acc_pos_set.add(acc_pos);
                    }
                }

            }
            if(!userterr.ZTS_Processed__c)
              updUsrTerrProcessFlagList.add(new ZTS_EU_Position__c(id=userTerr.id,ZTS_Processed__c=true));
        }
        /*****Optmised to convert the Set into list directly, no more needed tof the list******/

        //acc_pos_List.addAll(acc_pos_set);
        List < Database.Upsertresult > results = Database.upsert(new List<ZTS_EU_Account_Position__c> (acc_pos_set), Schema.ZTS_EU_Account_Position__c.ZTS_AccountUserTerrUniqueKey__c, false);
        List<Database.Saveresult> updResults=Database.update(updUsrTerrProcessFlagList,false);
        ZTS_EU_Logger.error(results, 'USZTS_TerritoryManager-createAccountTeams-UserTerr');
        ZTS_EU_Logger.error(updResults,'USZTS_TerritoryManager-createAccountTeams-UserTerr-ProcessFlagUpdate');
    }


    /***********  
     * Method name  : createAccountTeams
     * Description  : This method creates Account Teams from AccountTerritory List
     * Return Type  : void.
     * Parameters   : AccountTerrlist.
     ***********/
    public static void createAccountTeams(List < ZTS_AccountTerritory__c > acc_terrlist) {

        Map < Id, List < ZTS_EU_Position__c >> usrTerrMap = new Map < Id, List < ZTS_EU_Position__c >> ();

        Set < Id > terrIDs = new Set < Id > ();
        for (ZTS_AccountTerritory__c acc_terr: acc_terrList) {
            if (acc_terr.ZTS_EU_Territory__c != null) {
                terrIDs.add(acc_terr.ZTS_EU_Territory__c);
            }
        }

        List < ZTS_EU_Position__c > usrTerrList = [SELECT Id, Name, ZTS_EU_Territory__c, ZTS_EU_Employee__c FROM ZTS_EU_Position__c
                                                         WHERE ZTS_EU_Territory__c IN: terrIDs];

        for (ZTS_EU_Position__c usrterr: usrTerrList) {
            if (!usrTerrMap.containsKey(usrterr.ZTS_EU_Territory__c)) {
                usrTerrMap.put(usrterr.ZTS_EU_Territory__c, new List < ZTS_EU_Position__c > ());
            }
            usrTerrMap.get(usrterr.ZTS_EU_Territory__c).add(usrterr);
        }


        List < ZTS_EU_Account_Position__c > acc_pos_List = new List < ZTS_EU_Account_Position__c > ();
        Set < ZTS_EU_Account_Position__c > acc_pos_set = new Set < ZTS_EU_Account_Position__c > ();

        for (ZTS_AccountTerritory__c accterr: acc_terrList) {
            if (accterr.ZTS_EU_Territory__c != null && usrTerrMap.containsKey(accterr.ZTS_EU_Territory__c)) {
                //included Account Territory record
                for (ZTS_EU_Position__c usrterr: usrTerrMap.get(accterr.ZTS_EU_Territory__c)) {
                    String acc_userterr_key = accTerr.ZTS_EU_Account__c + ':' + usrterr.id;
                    ZTS_EU_Account_Position__c acc_pos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = accterr.ZTS_EU_Account__c, ZTS_EU_Position__c = usrterr.id,
                        ZTS_AccountUserTerrUniqueKey__c = acc_userterr_key, ZTS_AccountTerritory__c = accterr.id);
                        acc_pos.ZTS_NotificationUser__c= usrterr.ZTS_EU_Employee__c!=null?usrterr.ZTS_EU_Employee__c:null;
                        acc_pos_set.add(acc_pos);
                }

            }
            
            accterr.ZTS_Processed__c=true;
        }
        acc_pos_List.addAll(acc_pos_set);

        List < Database.Upsertresult > results = Database.upsert(acc_pos_List, Schema.ZTS_EU_Account_Position__c.ZTS_AccountUserTerrUniqueKey__c, false);
        List < Database.Saveresult > updResults = Database.update(acc_terrList,false);
        ZTS_EU_Logger.info(ZTS_EU_Logger.getDMLSuccessMsg(results), '', 'USZTS_TerritoryManager-createAccountTeamsFromAccTerr -success results');
        ZTS_EU_Logger.error(results, 'USZTS_TerritoryManager-createAccountTeamsFromAccTerr');
        ZTS_EU_Logger.error(updResults, 'USZTS_TerritoryManager-updateAccountTerrProcessFlag');
    }

    /***********  
     * Method name  : updatedUserTerrHistoryRecords
     * Description  : This method retrieves updated updated Custom object UserTerritory2Association history records to be removes from changes made to User lookup field in custom UserTerritory2Association records for specified date range.
     * Return Type  : Custom UserTerritory2Association History records.
     * Parameters   : Date - toDate & fromDt.
     ***********/

    public static List < ZTS_EU_Position__History > updatedUserTerrHistoryRecords(Date fromDate, Date toDate) {
        if (fromDate > toDate) {
            throw new ZTS_ZoetisException('Invalid arguments fromDate cannot be greater than toDate : ' + fromDate + ' > ' + toDate);
        }

        Integer DAYS_DIFF = fromDate.daysBetween(toDate);
        String usr_lookup_field = ZTS_EU_GlobalConstants.USER_LOOKUP_FIELD;
        String qry = 'SELECT ParentId, OldValue, NewValue, Field, CreatedDate, IsDeleted FROM ZTS_EU_Position__History WHERE ' +
            ' CreatedDate=LAST_N_DAYS:' + DAYS_DIFF + ' AND Field=:usr_lookup_field';
        return Database.query(qry);

    }

    /***********  
     * Method name  : updatedUserTerrUserRecordsToRemove
     * Description  : This method retrieves updated UserTerritory2Association to be removes from changes made to User lookup field in custom UserTerritory2Association records for specified date range.
     * Return Type  : None.
     * Parameters   : Updated Custom UserTerritory2Association history records received from updatedUserTerrHistoryRecords method date range.
     ***********/
    public static List < UserTerritory2Association > updatedUserTerrUserRecordsToRemove(List < ZTS_EU_Position__History > ut_histList) {
        // updatedUserTerrHistoryRecords
        Set < Id > custUsrTerrIds = new Set < Id > ();
        Set < Id > custTerrIds = new Set < Id > ();
        Set < String > existingUsrTerrKeys = new Set < String > ();
        List < ZTS_EU_Position__History > ut_updatedUsr_histList = new List < ZTS_EU_Position__History > ();

        //filter results
        for (ZTS_EU_Position__History uth: ut_histList) {
            if (uth.OldValue != null && uth.OldValue != '' && uth.OldValue != uth.NewValue && String.valueOf(uth.OldValue).startsWith(ZTS_EU_GlobalConstants.USER_KEYCODE) && String.valueOf(uth.OldValue).length() == 18) {
                custUsrTerrIds.add(uth.parentId);
                ut_updatedUsr_histList.add(uth);

            }
        }
        //get Territory information from updated user territories
        Map < Id, ZTS_EU_Position__c > custUsrTerrMap = new Map < Id, ZTS_EU_Position__c > ([SELECT Id, ZTS_EU_Employee__c, ZTS_EU_Territory__c FROM ZTS_EU_Position__c WHERE Id IN: custUsrTerrIds]);
        for (ZTS_EU_Position__c custUsrTerr: custUsrTerrMap.values()) {
            if (custUsrTerr.ZTS_EU_Employee__c != null) {
                existingUsrTerrKeys.add(custUsrTerr.ZTS_EU_Territory__c + ':' + custUsrTerr.ZTS_EU_Employee__c);
            }
            custTerrIds.add(custUsrTerr.ZTS_EU_Territory__c);
        }
        //get territory info from history parent ids
        Map < Id, ZTS_EU_Territory__c > custTerrMap = new Map < Id, ZTS_EU_Territory__c > ([SELECT Id, Name, ZTS_EU_Terr_SFID__c, ZTS_EU_Territory_synced__c FROM ZTS_EU_Territory__c WHERE Id IN: custTerrIds
            AND ZTS_EU_Terr_SFID__c != ''
            AND ZTS_EU_Territory_synced__c = TRUE
            AND ZTS_EU_Market__c = 'United States'
        ]);
        List < String > terrIdList = new List < Id > ();
        List < String > usrIdList = new List < Id > ();
        //combo key Territory and UserId to be deleted
        Set < String > stdUserTerrCombKeyToDel = new Set < String > ();
        for (ZTS_EU_Position__History uth: ut_updatedUsr_histList) {
            if (custUsrTerrMap.containsKey(uth.parentId)) {
                String stdTerrId = custTerrMap.get(custUsrTerrMap.get(uth.parentId).ZTS_EU_Territory__c).ZTS_EU_Terr_SFID__c;
                String usrId = String.valueOf(uth.OldValue);
                String usrTerrKey = custUsrTerrMap.get(uth.parentId).ZTS_EU_Territory__c + ':' + uth.OldValue;
                //Exclude any rolled backed changes
                if (!existingUsrTerrKeys.contains(usrTerrKey) && !(stdUserTerrCombKeyToDel.contains(stdTerrId + ':' + usrId))) {
                    terrIdList.add(stdTerrId);
                    usrIdList.add(usrId);
                    stdUserTerrCombKeyToDel.add(stdTerrId + ':' + usrId);
                }
            }

        }
        //get Std.Userterritory list of records
        List < UserTerritory2Association > userTerrList = [SELECT Id, Territory2Id, UserId FROM UserTerritory2Association WHERE Territory2Id IN: terrIdList];
        List < UserTerritory2Association > userTerrToDelete = new List < UserTerritory2Association > ();
        for (UserTerritory2Association usrTerr: userTerrList) {
            String usrTerrKey = usrTerr.Territory2Id + ':' + usrTerr.UserId;
            //check to exclude same user changed in other territory 
            if (stdUserTerrCombKeyToDel.contains(usrTerrKey)) {
                userTerrToDelete.add(usrTerr);
            }
        }
        return userTerrToDelete;
    }




    /***********  
     * Method name  : removeUserTerritory
     * Description  : This method removes standard UserTerritory2Association records.
     * Return Type  : None.
     * Parameters   : custom UserTerritory2Association list.
     ***********/
    public static JobUtilities removeUserTerritory(List < UserTerritory2Association > userTerrList, String sessionId) {

        JobUtilities.JobInfo job = new JobUtilities.JobInfo('UserTerritory2Association', JobUtilities.OPERATION.delete_x, JobUtilities.CONCURRENCY_MODE.Serial, JobUtilities.CONTENT_TYPE.CSV);
        JobUtilities job_utl = new JobUtilities();
        job_utl.sessionId = sessionId;
        String payload = getSFID_ToDelete(userTerrList);
        System.debug('Payload : ' + payload);
        if (String.isBlank(payload)) {
            return job_utl;
        }

        String jobId = job_utl.createJob(job, new JobUtilities.BulkConnection());
        if (String.isBlank(jobId)) {
            throw new ZTS_ZoetisException('Job creation failed (Territory Manager - removeUserTerritory) , see error log for more information');
        }

        String batchId = job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);
        // set details in BatchInfo CS
        JobUtilities.createBatchInfoEntry(jobId, batchId);

        return job_utl;
    }
    
     /***********  
     * Method name  : removeCustomUserTerritory
     * Description  : This method removes custom UserTerritory2Association records.
     * Return Type  : None.
     * Parameters   : custom UserTerritory list.
     ***********/
    public static void removeCustomUserTerritory(List < ZTS_EU_Position__c > customUserTerrList) {
         List<ZTS_EU_Position__c> cUsrTerrToDelList=new List<ZTS_EU_Position__c>();
            for(ZTS_EU_Position__c userterr:customUserTerrList){
                if(userterr.ZTS_ChangeFlag__c==ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_DELETE){
                    cUsrTerrToDelList.add(userterr);
                }
            }
            
             if(!cUsrTerrToDelList.isEmpty()){
                List<Database.Deleteresult> delresults=Database.delete(cUsrTerrToDelList,false);
                ZTS_EU_Logger.error(delresults, 'USZTS_TerritoryManager-removeCustomUserTerritory');
             }

    }

    /***********  
     * Method name  : removeUserTerritoryAsync
     * Description  : This future method removes standard UserTerritory2Association records.
     * Return Type  : None.
     * Parameters   : custom UserTerritory list.
     ***********/
    
    @future(callout = true)
    public static void removeUserTerritoryAsync(List < String > stduserTerrIds, String sessionId) {
        List < UserTerritory2Association > utlist = new List < UserTerritory2Association > ();
        for (String utId: stduserTerrIds) {
            utlist.add(new UserTerritory2Association(Id = utId));
        }
        removeUserTerritory(utlist, sessionId);

    }

}