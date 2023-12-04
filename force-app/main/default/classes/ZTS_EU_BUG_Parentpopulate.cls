/*************************************************************************************
* Name          :    ZTS_EU_BUG_Parentpopulate
* Description   :    This is code is developed to populate the custom parent Id field on each Account record with the grand parent id
                     Any change in the parent of an account with update the custom parent id field accordingly. Parent account in the
                     hierarchy will have its own record populated in the custom parent Id field and the any child records will have its
                     parent's parent id field value. If A1, A2, A3 and A4 are the Accounts in the hierarchy and A1 id = x, then A2, A3 
                     and A4 will have X in the custom parent Id field
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
 4/14/2014       Chandra            Created
 07/11/2018		 Saipraneeth		Modified updateParentIDBlankAccount method

**************************************************************************************/
public class ZTS_EU_BUG_Parentpopulate {
    /********************************************
    VARIABLES
    ********************************************/
    public static boolean isRecursive = false;
    /***********
    * Method name  : insertAccounts
    * Description  : This method will be called on an insert of any new account. Soon after an account is inserted, 
                     if it is an orphan or parent Account in the hierarchy, then same Accounts Id will be populated 
                     in the custom parent id field else if the inserted Account has a parent to it, then parent 
                     account's parent id field will be populated in the parent id field on all Accounts in the hierarchy
    * Return Type  : None
    * Parameters   : List of new Accounts from Trigger
    ***********/
    
    public static void insertAccounts(List < Account > newAcc) {
       Set < Id > accParentIds = new Set < Id > ();
        //Check if the new Account has parent, then add it to the set of parentids        
        for (Account acc: newAcc) {
            If(acc.parentid != null) {
                accParentIds.add(acc.parentId);
            }
        }
        List < Account > lstToUpdate = new List < Account > ();
        // Map will have all the parents and parent id field value
        Map < Id, Account > accMap = new Map < Id, Account > ([select id, ZTS_EU_Parent_Id__c from Account where id IN: accParentIds AND ZTS_EU_Market__c != 'United States']);
        List < Account > lst = [Select id, parentId from Account where Id in : trigger.new AND ZTS_EU_Market__c != 'United States'];
        // Checking if the parentid of the Account is null or not. If null, the same Accounts id will be populated in the custom 
        // parent id field else parent's parent id will be populated
        for (Account acc: lst) {
            if (!ZTS_EU_BUG_RecursiveClass.UpdatedIds.contains(acc.Id)) {
                if (acc.parentid != null) {
                    acc.ZTS_EU_Parent_Id__c = accMap.get(acc.parentId).ZTS_EU_Parent_Id__c;
                } else {
                    acc.ZTS_EU_Parent_Id__c = acc.id;
                }
                ZTS_EU_BUG_RecursiveClass.UpdatedIds.add(acc.Id);
                lstToUpdate.add(acc);
            }
        }
        isRecursive = true;
        if (lstToUpdate.size() > 0)
            update lstToUpdate;
    }
    
    /***********
    * Method name  : updateParentIDBlankAccount
    * Description  : This method will is called before update of any Account. If the Account Parent is removed and is made orphan,
                     same records id will be populated in the Parent Id field. On change of parent on the Account, else Custom Parent Id will be equal to parent id.
    * Return Type  : None
    * Parameters   : List of new Accounts from Trigger
    ***********/
    public static void updateParentIDBlankAccount(List < Account > lstAcc) {
        for (Account act: lstAcc) {
            act.ZTS_EU_Parent_Id__c = (act.parentid == null) ? act.id : act.parentid;
        }
    }
    
    /***********
    * Method name  : updateAccounts
    * Description  : This method will is called after update of any Account. Any update to the Account hierarchy like 
                     adding a new parent, adding a new child will udpate the custom parent id field accordingly on the 
                     other Accounts in the hierarchy
    * Return Type  : None
    * Parameters   : Accounts List, Account Map from Trigger
    ***********/
    public static void updateAccounts(List < Account > acclist, Map < id, Account > newmapAcc) {
        List < Account > lstToUpdates = new List < Account > ();
        SET < Id > accIds = new Set < Id > ();
        Map < Id, Id > mpAccIds = new Map < Id, Id > ();
        for (Account acc: acclist) {
            if (acc.parentId != newmapAcc.get(acc.Id).parentId) {
                accIds.add(acc.Id);
                mpAccIds.put(acc.id, acc.parentId);
            }
        }
        if (!accIds.isEmpty()) {
            Map < id, Account > accMaps = new map < Id, Account > ([Select id, parentId, parent.ZTS_EU_Parent_Id__c from Account where Id in : accIds AND ZTS_EU_Market__c != 'United States']);
            for (Account acc: [Select id, parentid, ZTS_EU_Parent_Id__c from Account where ZTS_EU_Parent_Id__c in : accMaps.keyset() AND ZTS_EU_Market__c != 'United States']) {
                //acc.ZTS_EU_Parent_Id__c = mpAccIds.get(acc.ZTS_EU_Parent_Id__c);
                acc.ZTS_EU_Parent_Id__c = acc.parentid != null ? accMaps.get(acc.ZTS_EU_Parent_Id__c).parent.ZTS_EU_Parent_Id__c : acc.id;
                lstToUpdates.add(acc);
            }
            isRecursive = true;
            if (!lstToUpdates.isEmpty()) {
                List<Database.Saveresult> resultvalue = Database.update(lstToUpdates,false);
                ZTS_EU_Logger.error(resultvalue, 'ZTS_EU_BUG_Parentpopulate - Accounts Id will be populated in the custom parent id field');
            }
        }
    }
    
    /***********
    * Method name  : deletedAccounts
    * Description  : This method is called after delete of any Account in the hierarchy. If a parent Account in
                     hierarchy is deleted, then the new parent's id will be updated in the custom parent id field
    * Return Type  : None
    * Parameters   : Set of Account ids to delete
    ***********/
    public static void deletedAccounts(Set < Id > setParentAccountsDeleted) {
        Map < Id, Id > mapUpdateParentIds = new Map < Id, Id > ();
        List < Account > lstHierarchialAccounts = [select id, Parent.Id, ZTS_EU_Parent_Id__c from account where ZTS_EU_Parent_Id__c in : setParentAccountsDeleted AND ZTS_EU_Market__c != 'United States'];
        for (Account obj: lstHierarchialAccounts) {
            if (obj.parentid == null)
                mapUpdateParentIds.put(obj.ZTS_EU_Parent_Id__c, obj.Id);
        }
        for (Account obj: lstHierarchialAccounts) {
            //if(obj.parentid == null)
            //obj.parentid = obj.Id;
            obj.ZTS_EU_Parent_Id__c = mapUpdateParentIds.get(obj.ZTS_EU_Parent_Id__c);
        }
        isRecursive = true;
        List<Database.Saveresult> resultvalue = Database.update(lstHierarchialAccounts,false);
        ZTS_EU_Logger.error(resultvalue, 'ZTS_EU_BUG_Parentpopulate - Accounts Id will be populated in the custom parent id field');
    }
    
    /***********
    * Method name  : deleteAccountsAff
    * Description  : This method is called after delete of any Account in the hierarchy. If an Account in
                     hierarchy is deleted, then any affiliation with that Account has to be deleted
    * Return Type  : None
    * Parameters   : Set of Account ids to delete
    ***********/
    public static void deleteAccountsAff(List < Account > lstAccount) {
        List < ZTS_EU_Account_Affiliations__c > lstAccountsAff = [select id, ZTS_EU_Affiliated_Account__c,ZTS_EU_Account__c from ZTS_EU_Account_Affiliations__c where (ZTS_EU_Account__c in : lstAccount or ZTS_EU_Affiliated_Account__c IN : lstAccount) AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ];
        if(!lstAccountsAff.isEmpty()){
            isRecursive = true;
            //delete lstAccountsAff;
            List<Database.DeleteResult> resultvalue = Database.delete(lstAccountsAff,false);
            ZTS_EU_Logger.error(resultvalue, 'ZTS_EU_BUG_Parentpopulate - Accounts Id will be populated in the custom parent id field');
        }
    }    
}