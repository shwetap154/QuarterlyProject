/*************************************************************************************************************************
Class Name     : ZTS_US_ContactAffiliation_Update
Description    : This class is called from trigger on Contact to Create/Update Contact Affiliation.
Created By     : Ketan Prakash Singh
Created On     : 03/23/2014

Modification Log    :
-----------------------------------------------------------------------------------------------------------------------
Developer                            Date                   Description
---------                            ----                 -----------
Ketan Prakash Singh                 03/23/2014              Created
Shiva                               12/26/2016              Do not allow prepopulating account address info to Pet Owner contacts
(Method modified -prepopulateAccountAddrInfo
Kaushik                             05/19/2017              Do not allow prepopulating account address info to Equine Owner & Producer owner contacts  
Saipraneeth						  08/02/2018              Updated code: Contact affiliation status will be in 'Active' even if contact status is 'Pending' or 'Pending - Incorrect First or Last Name' or 'Pending - Incorrect Profession or Job Function'
Yadagiri                          04/04/2023             Modified if else condition to update Affliation Status as Active or inactive based on Contact Status and
                                                         removed old logic as part of of TPDEV-424(SC-010283) 

***************************************************************************************************************************/
public  class ZTS_US_ContactAffiliation_Update {    
    
    /***********
* Method name  : UpdateContactAffilation
* Description  : This method updates contact affiliation on contact creation/updation.
* Return Type  : None.
* Parameters   : Trigger parameters.
***********/ 
    public static void UpdateContactAffilation(List<Contact> Triggernew,List<Contact> Triggerold,Map<id,Contact> TriggernewMap,Map<id,Contact> TriggeroldMap)
    {   
        Map <Id,List<ZTS_EU_Affiliations__c>> mapConidAndAff=new Map<Id,List<ZTS_EU_Affiliations__c>>(); 
        List<Contact> conList= new List<Contact>();
        
        for(Contact eachContact: Triggernew){
            if(((TriggeroldMap.get(eachContact.id).ZTS_EU_Contact_Status__c) <> (TriggernewMap.get(eachContact.id).ZTS_EU_Contact_Status__c) )|| ((TriggeroldMap.get(eachContact.id).ZTS_US_Profession__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Profession__c)) ||((TriggeroldMap.get(eachContact.id).ZTS_Job_Function__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Job_Function__c))||((TriggeroldMap.get(eachContact.id).ZTS_US_LE_Contact__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_LE_Contact__c))||((TriggeroldMap.get(eachContact.id).ZTS_US_Account_influence__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Account_influence__c))||((TriggeroldMap.get(eachContact.id).ZTS_US_Profit_Solver_Contact__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Profit_Solver_Contact__c))){
                conList.add(eachContact);
            }
        }
        
        List<ZTS_EU_Affiliations__c> conAffList=[Select Id,ZTS_EU_Affiliation_Status__c,ZTS_EU_Contact__r.id,ZTS_US_Profession__c,Profit_Solver_Contact__c,ZTS_US_Job_Function__c,ZTS_US_LE_Contact__c,ZTS_EU_Account_influence__c,ZTS_US_Primary_Account__c from ZTS_EU_Affiliations__c where ZTS_EU_Contact__r.id IN:conList AND ZTS_EU_Market_from_Parent__c = 'United States']; 
        
        for(ZTS_EU_Affiliations__c aff : conAffList)
        {
            list<ZTS_EU_Affiliations__c> listofAff = new List<ZTS_EU_Affiliations__c>();
            if(mapConidAndAff.get(aff.ZTS_EU_Contact__r.id)!= null){
                listofAff = mapConidAndAff.get(aff.ZTS_EU_Contact__r.id);
                listofAff.add(aff);
                mapConidAndAff.put(aff.ZTS_EU_Contact__r.id,listofAff);
            } else {
                listofAff.add(aff);
                mapConidAndAff.put(aff.ZTS_EU_Contact__r.id,listofAff);
            }           
        }
        List<ZTS_EU_Affiliations__c> modifiedList=new List<ZTS_EU_Affiliations__c>();
        
        for(Contact eachContact: conList){
            if(mapConidAndAff.containskey(eachContact.id)){
                for(ZTS_EU_Affiliations__c aca:mapConidAndAff.get(eachContact.id)){
                    boolean isStatusupdated=false;
                    boolean isProfupdated=false;
                    boolean islejobupdated=false;
                    boolean isPftslrupdated=false;
                    if(aca.ZTS_EU_Affiliation_Status__c <> (TriggernewMap.get(eachContact.id).ZTS_EU_Contact_Status__c)){
    // Modified the below if else condition and removed old logic as part of TPDEV-424(SC-010283) 
                        if(TriggernewMap.get(eachContact.id).ZTS_EU_Contact_Status__c == 'Inactive'){
                            aca.ZTS_EU_Affiliation_Status__c = 'Inactive';
                        }
                        else{
                            aca.ZTS_EU_Affiliation_Status__c= 'Active'; 
                        }
                        isStatusupdated=true;
                    }
                    if((aca.ZTS_US_Profession__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Profession__c)){
                        aca.ZTS_US_Profession__c =TriggernewMap.get(eachContact.id).ZTS_US_Profession__c;
                        isProfupdated=true;
                    }
                    
                    if((aca.Profit_Solver_Contact__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Profit_Solver_Contact__c)){
                        aca.Profit_Solver_Contact__c =TriggernewMap.get(eachContact.id).ZTS_US_Profit_Solver_Contact__c;
                        isPftslrupdated=true;
                    }
                    
                    if(aca.ZTS_US_Primary_Account__c==true && (((aca.ZTS_US_Job_Function__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Job_Function__c))||((aca.ZTS_US_LE_Contact__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_LE_Contact__c))||((aca.ZTS_EU_Account_influence__c) <> (TriggernewMap.get(eachContact.id).ZTS_US_Account_influence__c)))){
                        aca.ZTS_US_Job_Function__c=TriggernewMap.get(eachContact.id).ZTS_US_Job_Function__c;
                        aca.ZTS_US_LE_Contact__c=TriggernewMap.get(eachContact.id).ZTS_US_LE_Contact__c;
                        aca.ZTS_EU_Account_influence__c=TriggernewMap.get(eachContact.id).ZTS_US_Account_influence__c;
                        islejobupdated=true;
                    }
                    
                    if(isStatusupdated || isProfupdated || islejobupdated ||isPftslrupdated){
                        modifiedList.add(aca);
                    } 
                }
            }
        }
        
        if(!modifiedList.IsEmpty()){
            try{
                //Database.update(modifiedList);
                List<Database.Saveresult> results=Database.update(modifiedList,false);
                ZTS_EU_Logger.error(results,'ZTS_US_ContactAffiliation_Update-UpdateContactAffilation');
            }
            catch(Exception e){
                ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_US_ContactAffiliation_Update-UpdateContactAffilation');
            }
        }
    }
    /***********
* Method name  : prepopulateAccountAddrInfo
* Description  : This method updates contact address on insert if its empty.
* Return Type  : None.
* Parameters   : Trigger parameters.
* Pet Owner(PE) scenario has been added to ignore this PE record types
* Producer Owner & Equine Owner scenario has been added to ignore 
***********/ 
    public static void prepopulateAccountAddrInfo(List<Contact> newContactList)
    {
        Id petOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_Pet_Owner').getRecordTypeId();
        Id producerOwnerContactRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Producer_Account').getRecordTypeId();
        Id equineOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Equine_Account').getRecordTypeId();
        
        List<Contact> filteredContactList = new List<Contact>();
        for(Contact con: newcontactlist){
            if((con.RecordTypeId != petOwnerContactRecTypeId)
               && (con.RecordTypeId != producerOwnerContactRecTypeId) && (con.RecordTypeId != equineOwnerContactRecTypeId)){
                   filteredContactList.add(con);
               }
        }
        
        Set<Id> accIds=new Set<Id>();
        for(Contact con:filteredContactList){
            if(con.AccountId!=null){
                accIds.add(con.AccountId);
            }
        }
        
        
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT 
              Id, 
              BillingCity, 
              BillingCountry, 
              BillingState, 
              BillingStreet, 
              BillingPostalCode 
            FROM Account 
            WHERE Id IN :accIds
        ]); // Removed the market check as to fix NPE - NamrataP [11/1/21]
        for(Contact eachContact: filteredContactList){
            if(
                eachContact.MailingCity==null ||
                eachContact.MailingCountry==null ||
                eachContact.MailingState==null ||
                eachContact.MailingStreet==null ||
                eachContact.MailingPostalCode==null
            ){
                if(eachContact.Accountid != null){
                    Account objAccount;
                    objAccount = accMap.get(eachContact.AccountId);
                    eachContact.MailingCity = objAccount.BillingCity;                
                    eachContact.MailingCountry=objAccount.BillingCountry;
                    eachContact.MailingState=objAccount.BillingState;
                    eachContact.MailingStreet=objAccount.BillingStreet;
                    eachContact.MailingPostalCode=objAccount.BillingPostalCode;
                    System.debug('We are updating contact address');
                }
            }
        }
    }
    
    /* This method is used to insert record into ZTS_EU_Affiliations__c object whenever a new contact is created
* from Related List Account Contact Affiliation -'Add Contact' button in Account record.
* Release Note -RN-144
* User Story - US-0067
*/
    public static void createAccountContactAffiliationRecord(List<Contact> newContactList)
    {
        List<ZTS_EU_Affiliations__c> contactAffiliationInsertList = new List<ZTS_EU_Affiliations__c>();
        for(Contact eachContact: newContactList){
            if(eachContact.AccountId!=null){
                ZTS_EU_Affiliations__c affiliationRecord = new ZTS_EU_Affiliations__c();
                affiliationRecord.ZTS_EU_Affiliation_Status__c = 'Active';
                affiliationRecord.ZTS_EU_Contact__c = eachContact.Id;
                affiliationRecord.ZTS_EU_Account__c = eachContact.AccountId;
                affiliationRecord.ZTS_US_Profession__c=eachContact.ZTS_US_Profession__c;
                affiliationRecord.ZTS_US_Job_Function__c=eachContact.ZTS_US_Job_Function__c;
                affiliationRecord.ZTS_US_LE_Contact__c=eachContact.ZTS_US_LE_Contact__c;
                affiliationRecord.ZTS_EU_Account_influence__c=eachContact.ZTS_US_Account_influence__c;
                contactAffiliationInsertList.add(affiliationRecord);
            }
        }
        
        if(!contactAffiliationInsertList.isEmpty()){
            try{
                //Database.insert(contactAffiliationInsertList);
                List<Database.Saveresult> results=Database.insert(contactAffiliationInsertList,false);
                ZTS_EU_Logger.error(results,'ZTS_US_ContactAffiliation_Update-createAccountContactAffiliationRecord');
                
                
                
            }
            catch(Exception e){
                ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_US_ContactAffiliation_Update-createAccountContactAffiliationRecord');
            }
        }
    }
    /* This method is used to update Affiliation Status of Account Affiliation if the Account status is made 'Inactive'
*Release Note -RN-144
* User Story - US-0067 
*/
    public static void updateAccountAffiliation(List<Account> Triggernew,Map<id,Account> TriggernewMap,Map<id,Account> TriggeroldMap)
    {
        Map <Id,List<ZTS_EU_Account_Affiliations__c>> mapAccidAndAff=new Map<Id,List<ZTS_EU_Account_Affiliations__c>>();
        
        for(ZTS_EU_Account_Affiliations__c aff : [select ZTS_EU_Affiliated_Account__r.id,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Account_Affiliations__c where ZTS_EU_Affiliated_Account__r.id IN :triggerNew AND ZTS_EU_Market_from_Primary_Account__c = 'United States' ])
        {
            list<ZTS_EU_Account_Affiliations__c> listofAff = new List<ZTS_EU_Account_Affiliations__c>();
            if(mapAccidAndAff.get(aff.ZTS_EU_Affiliated_Account__r.id)!= null){
                listofAff = mapAccidAndAff.get(aff.ZTS_EU_Affiliated_Account__r.id);
                listofAff.add(aff);
                mapAccidAndAff.put(aff.ZTS_EU_Affiliated_Account__r.id,listofAff);
            } else {
                listofAff.add(aff);
                mapAccidAndAff.put(aff.ZTS_EU_Affiliated_Account__r.id,listofAff);
            }
            
        }
        List<ZTS_EU_Account_Affiliations__c> modifiedList=new List<ZTS_EU_Account_Affiliations__c>();
        for(Account eachAcccount: Triggernew){
            if((TriggeroldMap.get(eachAcccount.id).ZTS_EU_Account_Status__c) <> (TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c))
            {
                if(TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c=='Inactive'||TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c=='Active'){
                    if(mapAccidAndAff.containsKey(eachAcccount.id)){
                        for(ZTS_EU_Account_Affiliations__c affiliation:mapAccidAndAff.get(eachAcccount.id))
                        {    
                            affiliation.ZTS_EU_Affiliation_Status__c=TriggernewMap.get(eachAcccount.id).ZTS_EU_Account_Status__c;
                            modifiedList.add(affiliation);
                        } 
                    }
                }
                
            }
            
        }
        if(!modifiedList.isEmpty())
            upsert modifiedList;
    }
    
    /***********
* Method name  : populateAccContactAffPositions
* Description  : This method populates Profession information in AccountContactAff records from associated contacts.
* Return Type  : None.
* Parameters   : AccountContAff list.
***********/
    public static void populateAccContactAffPositions(List<ZTS_EU_Affiliations__c> newAccountConAffList){
        Set<Id> conIds=new Set<Id>();
        for(ZTS_EU_Affiliations__c aCA:newAccountConAffList){
            if(aCA.ZTS_EU_Contact__c!=null){
                conIds.add(aCA.ZTS_EU_Contact__c);
            }
        }
        //retrieve  account contact affiliations for updated contacts
        Map<Id,Contact> conMap=new Map<Id,Contact>([SELECT ZTS_US_Profession__c FROM Contact WHERE Id IN :conIds AND ZTS_EU_Market__c = 'United States' ]);
        for(ZTS_EU_Affiliations__c aCA:newAccountConAffList){
            if(aCA.ZTS_EU_Contact__c!=null){
                aCA.ZTS_US_Profession__c=conMap.get(aCA.ZTS_EU_Contact__c).ZTS_US_Profession__c;
            }
        }        
    }
}