/*************************************************************************************
* Name          :    ZTS_EU_Affiliation_Update .
* Description   :    Class called from Trigger for updation of Affiliation records.
                :    It is used to update the Status field of Account Contact Affiliation record
                     if the Status of the Contact become 'Inactive'
                :    This class is used to insert record into ZTS_EU_Affiliations__c object whenever a new contact is created
                     from Related List Account Contact Affiliation -'Add Contact' button in Account record.
                :    This class is used to update Affiliation Status of Account Affiliation if the Account status is made 'Inactive'
* Author        :    Chandra/Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/20/2014       Chandra                   Created
3/23/2014       Teresa                    Modified
8/26/2014       Srinivas                   Added code to fix bug DEF-000076
9/2/2014        Srinivas                   Added code to fix bug DEF-000073 
10/15/2014      Sohil(CloudSense)         Added code to fix bug DEF-000087  
11/07/2014      Sohil(CloudSense)         Added code to fix bug DEF-000087  
17/06/2015      Sohil(cloudSense)         Sohil shah Update all affiliated records Name if Account name modifies
24/08/2018		Saipraneeth(Cognizant)	  Modified UpdateAccountContactAffilation(Defect: SC-003834)
03/08/2022      Ethan Hirsch (Zoetis)     Fix a bug in updateRepAccountStatus when adding an error to a Contact
                                          to make sure the related Account errored. Also add code to more easily
                                          test the behavior of an Account erroring.
                                          Refactor UpdateContactAffilation and updateRepAccountStatus to reduce queries and code.
                                          Added notes of other changes that were not made yet.
04/10/2023      Padma Nerella (Zoetis)    TPDEV-104 moved updateAccountContactAffilation and updateRepContactStatus logic to AffiliationsService class                                    
**************************************************************************************/


public with sharing class ZTS_EU_Affiliation_Update {

    /*This method is used to update the Status field of Account Contact Affiliation record
    * if the Rep Contact Status field of the Contact become 'Inactive'
    */
    public static boolean myFlag = false;
    //public static void UpdateContactAffilation(List<Contact> Triggernew,List<Contact> Triggerold,Map<id,Contact> TriggernewMap,Map<id,Contact> TriggeroldMap)
    public static void UpdateContactAffilation(List<Contact> Triggernew)
    {
        if(myFlag == false)
        {
            try {
                // Only process inactive Contacts. Exit early if all Contacts are Active
                Map<Id, Contact> inactiveContactsMap = new Map<Id, Contact>();
                for(Contact eachContact: Triggernew){
                    if (eachContact.ZTS_EU_Contact_Status__c == 'Inactive') {
                        inactiveContactsMap.put(eachContact.Id, eachContact);
                    }
                }

                if (inactiveContactsMap.isEmpty()) {
                    return;
                }

                // Note: Ideally at this point an AffiliationService would be called to perform this logic
                List<ZTS_EU_Affiliations__c> modifiedList=new List<ZTS_EU_Affiliations__c>();
                for(ZTS_EU_Affiliations__c aff : [
                    SELECT ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c, Name, ZTS_EU_Account__c
                    FROM ZTS_EU_Affiliations__c 
                    WHERE ZTS_EU_Contact__c IN :inactiveContactsMap.keySet() 
                    AND ZTS_EU_Market_from_Parent__c != 'United States']
                    ) {
                    aff.ZTS_EU_Affiliation_Status__c = 
                        inactiveContactsMap.get(aff.ZTS_EU_Contact__c).ZTS_EU_Contact_Status__c;

                    modifiedList.add(aff);
                }

                 if(!modifiedList.isEmpty())
                 {
                    List<Database.SaveResult> results=Database.update(modifiedList);

                    // Note: Ideally this would be in an AccountsService class
                    updateRepAccountStatus(modifiedList,Triggernew);//by sohil Shah

                    ZTS_EU_Logger.error(results, 'ZTS_EU_Affiliation_Update-UpdateContactAffilation');
                 }
            }  catch(DmlException e) {
                   ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Affiliation_Update-UpdateContactAffilation');
            }

        myFlag = true;
        }
    }

    // Allow an Account to be passed in a Unit Test to force an error and receive code coverage
    @testVisible
    private static Id forceUpdateRepAccountStatusErrorId;
    /* Added by Sohil DEF-000087
    This method is used to update the Rep Account status to inactive if it's all related ACA records status are inactive (only for those accounts whose ACA list size is 1)
    */
    public static void updateRepAccountStatus(List<ZTS_EU_Affiliations__c> ACAList, List<Contact> conList)
    {
        try{
            Set<Id> accountIds = new Set<Id>(); 
            List<Account> accountListToUpdate = new List<Account>();

            for(ZTS_EU_Affiliations__c affiliationObj : ACAList) {
                accountIds.add(affiliationObj.ZTS_EU_Account__c);
            }

            Map<Id,Account> accContMap = new Map<Id,Account>();
            Map<Id,Boolean> secondMap = new  Map<Id,Boolean>();
            for (Account AccountObj : [
                SELECT Id, Name, ZTS_EU_Account_Status__c,ZTS_EU_Rep_Account_Status__c,
                       (SELECT Id, Name, ZTS_EU_Affiliation_Status__c FROM Accounts_and_Contacts__r WHERE ZTS_EU_Affiliation_Status__c = 'Active') 
                FROM Account 
                WHERE id IN : accountIds
                AND ZTS_EU_Market__c != 'United States']) {

                accContMap.put(AccountObj.Id, AccountObj);

                // Note: This uses the flag variable that is also used to bypass UpdateAccountContactAffilation
                // if its already been run.
                // This should ideally be changed
                flag = false;
                if(AccountObj.Accounts_and_Contacts__r.size() > 0)
                {
                    for(ZTS_EU_Affiliations__c affiliatedContacts : AccountObj.Accounts_and_Contacts__r)
                    {
                        if(affiliatedContacts.ZTS_EU_Affiliation_Status__c == 'Active')
                        {
                            flag = true;                    
                            break;
                        } 
                    }                   
                } 
                
                    secondMap.put(AccountObj.id, flag); 
            }

            for(Id AccountId : secondMap.keySet())
            {
                Account accObj = accContMap.get(AccountId);         
                if(secondMap.get(AccountId) == false)
                {
                    // Set Sic to an invalid value in a Unit Test to force an error on the specified Account
                    if (Test.isRunningTest() && accObj.Id == forceUpdateRepAccountStatusErrorId) {
                        accObj.Sic = 'aaaaaaaaaaaaaaaaaaaaa';
                    }

                    accObj.ZTS_EU_Account_Status__c = 'Inactive';
                    accountListToUpdate.add(accObj);
                }           
            }
            Map<Id, String> fundIdErrorMap = new Map<Id, String>();
            if(!accountListToUpdate.isEmpty())
            {
                try{
                    Database.SaveResult[] srList = database.update(accountListToUpdate, false);
                
                    for(Integer i=0;i<srList.size();i++)
                    {
                        if (srList.get(i).isSuccess())
                        {
                            // For success records, no action will be required
                        } else if (!srList.get(i).isSuccess())
                        {
                            // For failed operation, create map of Fund Id to error message
                            Database.Error error = srList.get(i).getErrors().get(0);
                            String errString ;
                            
                            errString = ' On Account: '+accountListToUpdate[i].Name + ' :  ' + error.getMessage() ;                            
                            for(Id conid : accContMap.keySet())
                            {
                                fundIdErrorMap.put(conid, errString);
                            }
                        }
                    }
                } 
                catch(Exception e)
                {
                    system.debug('Exception in Update on Fund====================' + e.getMessage());
                }
            }
            
            /*
            * Error handling on Error in Updates on Fund records.
            */
                      
            if(fundIdErrorMap!=null && !fundIdErrorMap.isEmpty())
            {    
                      
                for(Contact con : conList){    
                    if (fundIdErrorMap.containsKey(con.AccountId)) {                  
                        con.addError(fundIdErrorMap.get(con.AccountID));          
                    }                  
                }           
            }           
        }catch(DMLException e)//Debug statements to catch the failing of DML operation
        {
            system.debug('##### EXCEPTION - '+e.getmessage());
            system.debug('##### EXCEPTION - '+e.getstacktracestring());            
        }   
    }//* EOD Sohil DEF-000087 //* EOD Sohil Modification 11/07/2014 DEF-000087
    
    
    /* This method is used to insert record into ZTS_EU_Affiliations__c object whenever a new contact is created
    * from Related List Account Contact Affiliation -'Add Contact' button in Account record.
    * Release Note -RN-00115
    * User Story - US-0067
    */
    public static void createAccountContactAffiliationRecord(List<Contact> Triggernew)
    {
        List<ZTS_EU_Affiliations__c> contactAffiliationInsertList = new List<ZTS_EU_Affiliations__c>();
        try {
                for(Contact eachContact: Triggernew){
                ZTS_EU_Affiliations__c affiliationRecord = new ZTS_EU_Affiliations__c();
                affiliationRecord.ZTS_EU_Affiliation_Status__c = 'Active'; // Srinivas changed the code as part of bug Fix DEF-000076
                affiliationRecord.ZTS_EU_Contact__c = eachContact.Id;
                affiliationRecord.ZTS_EU_Account__c = eachContact.AccountId;
               // affiliationRecord.ZTS_EU_Unique_Primary_key__c = eachContact.AccountId +''+ eachContact.Id+TRUE;
                contactAffiliationInsertList.add(affiliationRecord);
            }
            List<Database.Saveresult> results=Database.Insert(contactAffiliationInsertList,false);
            ZTS_EU_Logger.error(results, 'ZTS_EU_Affiliation_Update-createAccountContactAffiliationRecord');
          
        }  catch(DmlException e) {
            ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Affiliation_Update-createAccountContactAffiliationRecord');
            
        }
    }
     /* This method is used to update Affiliation Status of Account Affiliation if the  Account status is made 'Inactive'
    * Release Note -RN-00139
    * User Story - US-0036
    */
     public static void updateAccountAffiliation(List<Account> Triggernew,Map<id,Account> TriggernewMap,Map<id,Account> TriggeroldMap)
    {
        
        List<ZTS_EU_Account_Affiliations__c> listofAff;
        List<ZTS_EU_Account_Affiliations__c> primaryAffliation;
        List<ZTS_EU_Account_Affiliations__c> modifiedList=new List<ZTS_EU_Account_Affiliations__c>();
        Map <Id,List<ZTS_EU_Account_Affiliations__c>> mapAccidAndAff = new Map<Id,List<ZTS_EU_Account_Affiliations__c>>();
        try {
                             
            for(ZTS_EU_Account_Affiliations__c aff : [select ZTS_EU_Affiliated_Account__r.id,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Account_Affiliations__c where ZTS_EU_Affiliated_Account__r.id IN :triggerNew AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ])
            {                     
                if(mapAccidAndAff.get(aff.ZTS_EU_Affiliated_Account__r.id)!= null){
                    listofAff = mapAccidAndAff.get(aff.ZTS_EU_Affiliated_Account__r.id);
                    listofAff.add(aff);                                            
                }
                else {
                    listofAff = new List<ZTS_EU_Account_Affiliations__c>();
                    listofAff.add(aff);                        
                }
                mapAccidAndAff.put(aff.ZTS_EU_Affiliated_Account__r.id,listofAff);
           } 
         
           // Added by Sunil
           for(ZTS_EU_Account_Affiliations__c primeAff : [select ZTS_EU_Account__c,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Account_Affiliations__c where ZTS_EU_Account__c IN :triggerNew AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ])
            {                     
                if(mapAccidAndAff.get(primeAff.ZTS_EU_Account__c)!= null){
                    primaryAffliation = mapAccidAndAff.get(primeAff.ZTS_EU_Account__c);
                    primaryAffliation.add(primeAff);
                                            
                }
                else {
                    primaryAffliation = new List<ZTS_EU_Account_Affiliations__c>();
                    primaryAffliation.add(primeAff);                        
                }
                mapAccidAndAff.put(primeAff.ZTS_EU_Account__c,primaryAffliation);
           } 
           
            for(Account eachAcccount: Triggernew){
                if((TriggeroldMap.get(eachAcccount.id).ZTS_EU_Account_Status__c) <> (TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c))
                {
                    if(TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c=='Inactive'||TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c=='Active'){
                    if(mapAccidAndAff != null && mapAccidAndAff.containsKey(eachAcccount.id)){
                        for(ZTS_EU_Account_Affiliations__c affiliation:mapAccidAndAff.get(eachAcccount.id))
                        {            
                            affiliation.ZTS_EU_Affiliation_Status__c=TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c;
                            modifiedList.add(affiliation);
                         } 
                       }
                    }

                }

            }
            
            List<Database.Upsertresult> results=Database.Upsert(modifiedList,false);
            ZTS_EU_Logger.error(results, 'ZTS_EU_Affiliation_Update-updateAccountAffiliation');
        
        }  catch(DmlException e) {
             ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Affiliation_Update-updateAccountAffiliation');
        } catch(Exception ex){
             ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_Affiliation_Update-updateAccountAffiliation');
        }

    }
    static boolean flag = false;
    
    /* Srinivas-->This method is used to delete Affiliation records of AccountContactAffiliationRecord if the contact is deleted 
    * DEF-000073
    */
    public static void deleteAccountContactAffiliationRecord(List<Contact> TriggerRecords){
        List<ZTS_EU_Affiliations__c> contactAffiliationDeleteList = new List<ZTS_EU_Affiliations__c>();
        map<id,id> contactAffiliationDeleteMap= new map<id,id>();                   
        try {            
            for(Contact eachContact: TriggerRecords){
                contactAffiliationDeleteMap.put(eachContact.id,eachContact.AccountId);               
            }           
            contactAffiliationDeleteList= [select id,Name from ZTS_EU_Affiliations__c where ZTS_EU_Account__c IN: contactAffiliationDeleteMap.values() and ZTS_EU_Contact__c IN: contactAffiliationDeleteMap.keyset() AND ZTS_EU_Market_from_Parent__c != 'United States'];           
            delete contactAffiliationDeleteList;
        }
        catch(DmlException e) {
             ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Affiliation_Update-deleteAccountContactAffiliationRecord');
        }
    }
    /* Sohil-->This method is used to update Affiliation records of AccountContactAffiliationRecord if the contact's Account has been changed 
    * DEF-000917
    */ 
    public static void updateAccountContactAffiliationRecord(List<Contact> Triggernew)
    {
        List<Contact> updatedContactList = new List<Contact>();
        updatedContactList = [Select Id,Name,AccountId,(Select Id,ZTS_EU_Contact__c,ZTS_EU_Account__c,ZTS_EU_Affiliation_Status__c,ZTS_EU_Primary_Account__c,ZTS_EU_Primary_Contact__c from Accounts_and_Contacts__r) from Contact where Id IN: Triggernew AND ZTS_EU_Market__c != 'United States'];
        
        List<ZTS_EU_Affiliations__c> contactAffiliationUpdateList = new List<ZTS_EU_Affiliations__c>();
        List<ZTS_EU_Affiliations__c> contactAffiliationExistingList = new List<ZTS_EU_Affiliations__c>();
        try {                                   
                for(Contact con: updatedContactList)
                {
                     for(ZTS_EU_Affiliations__c affiliatedAccounts : con.Accounts_and_Contacts__r)
                     {
                        affiliatedAccounts.ZTS_EU_Account__c = con.AccountId;
                        contactAffiliationUpdateList.add(affiliatedAccounts);   
                     }
                }                          
            List<Database.Saveresult> results=Database.Update(contactAffiliationUpdateList,false);
            ZTS_EU_Logger.error(results, 'ZTS_EU_Affiliation_Update-createAccountContactAffiliationRecord');
          
        }  catch(DmlException e) {
            ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Affiliation_Update-createAccountContactAffiliationRecord');
            
        }
    }     
  
    
}