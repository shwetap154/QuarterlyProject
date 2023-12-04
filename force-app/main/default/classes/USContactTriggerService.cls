/******************************************************//**
@class      USContactTriggerService
@brief      Service class for Contact Trigger functionality 

@revision   02-10-2020  Mohamed Seliman
Created.

@copyright  (c)2020, Zoetis
Trigger Logic added below(s):
  Trigger Name   : FAContactSync
  Trigger Name     : ZTS_US_Contact_Trigger
  Description    : This Trigger creates a new AccountContact Affilication on insert & updates contact affilicaiton and contact address.
  Created By     : Ninad
  Created On     : 02/26/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Ninad Patil    02/26/2014              Created
  Deloitte Constulting/Raghu          03/11/2014              Added/Modification on Contact Affilication Jobfunction & Adress.
  CloudSense Sohil Shah               04/22/2015              DEF-001643 Update Account on Contact Update(Of Record Type Account Contact)  
  
Cognizant Technology Solutions/Miten Bhagat 12/22/2016      Pet Owner(PE) contacts can be created with a dummy account, fetched from record type
  following class handlers are involved-
  - ZTS_US_ContactAffiliation_Update.prepopulateAccountAddrInfo :to filter out PE contacts so that account address is not prepopulated, code added
  - ZTS_US_addrCreationAndUpdateFromAccount.updateContactsAddress:to filter out PE contacts so that upon updation of parent account address, not reflect in child PE,code added
  
Cognizant Technology Solutions/Kaushik Ghosh 05/19/2017    Producer Account(PA), Equine Account(EA) contacts can be created with a dummy account, fetched from record type

  Slalom/Taylor Poppell               01/08/2020              Updated loops to use getRecordTypeInfosByDeveloperName()
                                                              rather than hardcoded RecordTypeId
  Aritra(Cognizant)                   03/11/2022              Updated 'afterUpdate' method. commented out "Opt_Out_AccountUpdate" method call as it was wrongly updating email field on account (SC-009334)
  Prasun(Congnizant)				  04/26/2022			  Updated before Insert to assign Horse Owner account to all horse owner contacts (SC-009114)
  Aritra(Cognizant)                   05/12/2022              Updated 'afterInsert' and 'afterUpdate' method. Added a future method call to reset Duplicate bypassed flag to FALSE (SC-008149)
  Yadagiri Avula @ Cognizant          03-Aug-2023             Moved "listFieldName", "updateSendTOLIS" methods to ContactService class as part of code refactoring and for TPDEV-366
  Yadagiri Avula @ Cognizant          17-Aug-2023             Updated "beforeInsert" and "beforeUpdate" methods. Called "updateSendTOLIS" method from ContactService class.
  Prasun @ Cognizant				  27-Oct-2023			  TPDEV-1005 Trigger affiliation name update on contact's name update
**********************************************************/

public class USContactTriggerService 
{
    
    public static void beforeUpdate(List<Contact> triggerOld, Map<Id, Contact> triggerOldMap, List<Contact> triggerNew, Map<Id, Contact> triggerNewMap) 
    {   
        //added below line as part of code refactoring and for TPDEV-366
        ContactsService.updateSendTOLIS( triggerNew, triggerOldMap, false );
			system.debug('rachana inside USContactTRiggerService');
        List<Contact> primaryAccountChangedMap = new List<Contact>();
        
        
        for (Contact con : triggerNew) {
            
            //TPDEV-1037 starts here 
            //Override values from Atlas Integration in Contact's fields
            
            if(AutomationSettings__c.getInstance().Atlas_Integration_User__c != null){
                if (UserInfo.getUserId() == AutomationSettings__c.getInstance().Atlas_Integration_User__c) {
                    for (Schema.FieldSetMember fieldSetMember : SObjectType.Contact.FieldSets.Atlas_Override_Prevention.getFields()) {    
                        String fieldName = fieldSetMember.getFieldPath();
                        Object fieldValue = con.get(fieldName);                       
                        if (fieldValue == null && triggerOldMap.get(con.Id).get(fieldName)!=null) {                        
                            con.put(fieldName, triggerOldMap.get(con.Id).get(fieldName));
                        }
                    }
                } 
            }
            
            //TPDEV-1037 ends here
            //SC-008911 for any changed phone numbers, get E.164 formatted phone numbers
            if (con.Phone != triggerOldMap.get(con.Id).Phone && con.Phone != null) {
                con.Phone = UtilityService.getE164FormattedPhoneNumber(con.Phone,'1',10,'US');
            }

            if (con.AccountId != triggerOldMap.get(con.Id).AccountId) {
                primaryAccountChangedMap.add(con);
            }
        }
        
        updateLISId(triggerNew);
        //before insert operation; moved before trigger mute logic for data load, so that contacts contains address from account.
        boolean flag = false; //removed public modifier as it's a local variable
        //Only for 'PetOwner',Producer Account, Equine Account- contact record types, account names will be autosaved to dummy account as per change request vmips implementation
        //PetOwnerAccountId__c is a custom settings which hold account name, accountid__c.Similar record types for EA, PA scenarios
        List<PetOwnerAccountId__c> petOwns = PetOwnerAccountId__c.getall().values();
        List<ProducerAccountId__c> producerOwns = ProducerAccountId__c.getall().values();
        List<EquineAccountId__c> equineOwns = EquineAccountId__c.getall().values();
        
        Id accountContactId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
        
        //update primary account address tp mailing address when primary account is changed
        if (!primaryAccountChangedMap.isEmpty()) {
            ZTS_US_addrCreationAndUpdateFromAccount.updateContactsAddress(primaryAccountChangedMap,triggerOldMap);  
        }
	try 
        {
            AtlasIntegrationHelper.handleContactsForAnonymization( triggerNew, triggerOldMap );
        }
        catch ( Exception e )
        {
            System.debug( 'error anonymizing contacts' + e.getMessage() );
        }
    }
    
    
    // SFDCATS- 463: update LIS id field and NPI id field on Contact.
    public static void updateLISId(List<Contact> triggerNew) 
    {
        for(Contact con : triggerNew){
            if ( !con.Reference_Lab_Contact__c ) continue;
            if ( String.isBlank( con.LIS_ID__c ) ) con.LIS_ID__c = con.Id;
            if ( String.isBlank( con.LIS_NPI__c ) ) con.LIS_NPI__c = con.ZTS_EU_Zoetis_SFDC_ID__c.substringAfter( '-' ); 
   
        }
        
    }
    
 public static void beforeInsert(List<Contact> triggerNew) 
    {
        //Updated below line as part of code refactoring and for TPDEV-366
        ContactsService.updateSendTOLIS(triggerNew,null, false);
        //before insert operation; moved before trigger mute logic for data load, so that contacts contains address from account.
        boolean flag = false; //removed public modifier as it's a local variable
        //Only for 'PetOwner',Producer Account, Equine Account- contact record types, account names will be autosaved to dummy account as per change request vmips implementation
        //PetOwnerAccountId__c is a custom settings which hold account name, accountid__c.Similar record types for EA, PA scenarios
        //List<PetOwnerAccountId__c> petOwns = PetOwnerAccountId__c.getall().values();
        List<ProducerAccountId__c> producerOwns = ProducerAccountId__c.getall().values();
        List<EquineAccountId__c> equineOwns = EquineAccountId__c.getall().values();
        
        Id accountContactId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
        Id producerOwnerContactRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Producer_Account').getRecordTypeId();
       /* commented as part of TPDEV-583
        Id equineOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Equine_Account').getRecordTypeId();
         
        // Start:  Added as part of SC-009114
        Integer modInteger = 0;
        String key = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Integer accountCount = [Select Count() from Contact Where RecordTypeId =: equineOwnerContactRecTypeId];
        modInteger = accountCount/10000;
        List<Account> eqAccountList = new List<Account>();
        String accountName = 'Horse Owner Account '+key.substring(modInteger,modInteger+1);
        eqAccountList = [Select Id From Account Where Name =: accountName];
        // End:  Added as part of SC-009114
        */
        // 
        for(Contact con: triggerNew){
            //SC-008911 for any US phone numbers, get E.164 formatted phone numbers
            if (con.Phone != null) {
                con.Phone = UtilityService.getE164FormattedPhoneNumber(con.Phone,'1',10,'US');
            }
			
			
      
            /*if(con.RecordTypeId == petOwnerContactRecTypeId ){
                if (petOwns != null && petOwns.size()>0 ) {
                    con.AccountId = petOwns[0].Account_Id__c; 
                } 
            }
            
            else*/ if(con.RecordTypeId == producerOwnerContactRecTypeId ){
               if (producerOwns != null && producerOwns.size()>0 ) {
                    con.AccountId = producerOwns[0].Account_Id__c; 
                } 
            }
            
            
            /* commented as part of TPDEV-583
            else if(con.RecordTypeId == equineOwnerContactRecTypeId ){
                // Start:  Added as part of SC-009114
                 
                if(eqAccountList != null && eqAccountList.size() > 0){
                    con.AccountId = eqAccountList[0].Id;
                }
                // End:  Added as part of SC-009114
            }
            */
            
        }//End ...PetOwner new contact creation trigger part
        ZTS_US_ContactAffiliation_Update.prepopulateAccountAddrInfo(triggerNew); //Modified to include PE criteria
    }
    
    public static void afterInsert(List<Contact> triggerNew, Map<Id, Contact> triggerNewMap)
    {
        //before insert operation; moved before trigger mute logic for data load, so that contacts contains address from account.
        boolean flag = false; //removed public modifier as it's a local variable
        //Only for 'PetOwner',Producer Account, Equine Account- contact record types, account names will be autosaved to dummy account as per change request vmips implementation
        //PetOwnerAccountId__c is a custom settings which hold account name, accountid__c.Similar record types for EA, PA scenarios
        List<PetOwnerAccountId__c> petOwns = PetOwnerAccountId__c.getall().values();
        List<ProducerAccountId__c> producerOwns = ProducerAccountId__c.getall().values();
        List<EquineAccountId__c> equineOwns = EquineAccountId__c.getall().values();
        
        Id accountContactId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
        
        // creation of account contact affiliation record on contact insert
        ZTS_US_ContactAffiliation_Update.createAccountContactAffiliationRecord(triggerNew);          
        /*
        Added by Sohil for DEF-001643 - Dummy Affiliated Contact for Each Account to handle Email Marketo and
        copy Account's Email to contact's Interface Email.
        */
        
        for(Id con: triggerNewMap.keySet())
        {
            if( (triggerNewMap.get(con).RecordTypeId == accountContactId ) )
            {
                updateOpt_Out_Contact.copyAccountEmailOnContactInsert(triggerNew);
            }
        }   
        
        ZTS_US_EduCreationAndUpdateFromContact.createEducationRecord(triggerNew);
        System.debug( 'in trigger handler' );
        try 
        {
            AtlasIntegrationHelper.filterAndCreatePetOwners( triggerNew );
        } 
        catch ( Exception e)  
        {
            System.debug( 'exception thrown calling integration helper: ' + e.getMessage() );
        }
		// This below portion is added to call future method for resetting bypass duplicate flag on Contact (SC-008149)
        List<Id> conIdList = new List<Id>();
        for(Id i: triggerNewMap.keyset())
        {
            conIdList.add(i);
        }
        if(conIdList != null && conIdList.size() > 0){
            USContactUtil_Queueable q= new USContactUtil_Queueable(conIdList);
            system.enqueueJob(q);
        }
    }
    
    public static void afterUpdate(List<Contact> triggerOld, Map<Id, Contact> triggerOldMap, List<Contact> triggerNew, Map<Id, Contact> triggerNewMap)
    {
        //before insert operation; moved before trigger mute logic for data load, so that contacts contains address from account.
        boolean flag = false; //removed public modifier as it's a local variable
        //Only for 'PetOwner',Producer Account, Equine Account- contact record types, account names will be autosaved to dummy account as per change request vmips implementation
        //PetOwnerAccountId__c is a custom settings which hold account name, accountid__c.Similar record types for EA, PA scenarios
        List<PetOwnerAccountId__c> petOwns = PetOwnerAccountId__c.getall().values();
        List<ProducerAccountId__c> producerOwns = ProducerAccountId__c.getall().values();
        List<EquineAccountId__c> equineOwns = EquineAccountId__c.getall().values();
        List<Contact> nameUpdatedList = new List<Contact>(); //TPDEV-1005 
        
        Id accountContactId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId();
        
        /*
        Added by Sohil for DEF-001643 - Dummy Affiliated Contact for Each Account to handle Email Marketo and
        update Email_Opt_Out and Invalid_Email From Contact to Account
        */
        // Commented the below part as requested by Lydia in SC-009334 as it was wrongly populating account's email id
        /*for(Id con: triggerNewMap.keySet())
        {
            if( (triggerNewMap.get(con).RecordTypeId == accountContactId ) )
            {
                if(triggerOldMap.get(con).Interface_Email__c != triggerNewMap.get(con).Interface_Email__c || 
                   triggerOldMap.get(con).Interface_Email_Opt_Out__c != triggerNewMap.get(con).Interface_Email_Opt_Out__c ||
                   triggerOldMap.get(con).ZTS_Invalid_Email__c != triggerNewMap.get(con).ZTS_Invalid_Email__c )            
                {
                    USupdate_Opt_Out_Account.Opt_Out_AccountUpdate(triggerNew);
                }
            }
        }*/
        /*
        EOD by SOHIL For DEF-001643
        */
        //updation of contact affiliation record on contact update        
        if(CheckRecursiveTrigger.updateconaffonce()){
            ZTS_US_ContactAffiliation_Update.UpdateContactAffilation(triggerNew,triggerOld,triggerNewMap,triggerOldMap);
        }
        
        if(CheckRecursiveTrigger.updateeduandcon()){
            ZTS_US_EduCreationAndUpdateFromContact.createEducationRecord(triggerNew);  
            ZTS_US_EduCreationAndUpdateFromContact.updateEducationRecord(triggerNew,triggerOldMap);       
        }
        ZTS_US_EduCreationAndUpdateFromContact.updateAccConAffInactive(triggerNew);
		// This below portion is added to call future method for resetting bypass duplicate flag on Contact (SC-008149)
        List<Id> conIdList = new List<Id>();
        for(Id i: triggerNewMap.keyset())
        {
            conIdList.add(i);
            //TPDEV-1005 Added
            if(triggerNewMap.get(i).FirstName != triggerOldMap.get(i).FirstName || triggerNewMap.get(i).LastName != triggerOldMap.get(i).LastName)
            {
                nameUpdatedList.add(triggerNewMap.get(i));
            }
        }
        //TPDEV-1005 Added
        if(nameUpdatedList.size() > 0){
            List<ZTS_EU_Affiliations__c> affiliationList = new List<ZTS_EU_Affiliations__c>();
            affiliationList = [Select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name, Name, ZTS_EU_Contact__r.ZTS_EU_Full_Name__c From ZTS_EU_Affiliations__c Where ZTS_EU_Contact__c in: nameUpdatedList];
            if(affiliationList != null && affiliationList.size() > 0 ){
                AffiliationsService.updateAffiliationName(affiliationList);
            }
        }
        USContactUtil_Queueable q= new USContactUtil_Queueable(conIdList);
        system.enqueueJob(q);
    }
}