/****************************************************************************************************************************************** 
 * Trigger Name : INTLContactTriggerService
 * Description  : Service class holding Contact Trigger logic
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 10th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman      02/10/2020              Created and moved code to service class
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sathiya SB			02/14/2023				Added E164 standard for International Ph no. (SC-009335)
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Added Trigger(s) below:
 * ---------------------------------------------------------------------------------------------------------------------------------------
* Name          :    ZTS_EU_Contact_Trigger .
* Description   :    Trigger used to insert AccountContactAffiliation record on creation of Contact
                :    Trigger used to insert Address record after insert of Contact.
                :    Trigger used to update Market
                :    Trigger used to check if Primary Contact is being made inactive
                :    Trigger used to update the Contact Type field on Affiliation
                :    Trigger used to update Address record in case Address fields on Contact are updated.
* Author        :    Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
4/10/2014       Teresa                        Created
                Chandra                   Modified for Market functionality, Contact Type updation functionality
9/2/2014        Srinivas                  Added code to fix bug DEF-000073 (T-12613)
22/10/2014      CloudSense:Parvez         Added code to fix T-14216/DEF-000078
22/12/2014      Shefali                   Added code for populating the city text field
17/06/2015      Sohil Shah(CloudSense)    DEF-000417 - Update Local Address Flag on Contact if it's own Primary Address is updated 
23/05/2016      Srinivas K(CloudSense)    DEFINC0657967 - Activating sample drops based on contact status
30/03/2023      Padma Nerella @Zoetis Inc Moved ImprovacTriggerHandler logic to ImprovacContactsService class as part of refactoring code TPDEV-89 

/**  ContactProcessD - триггер для Contact / trigger for Contact
*    1. Отвечает за сообщение об ошибке / inform about Error
*    2. Отвечает за подтверждение сохранения / implements Commit after save for local base

* Class Name   : ImprovacTrigger
* ---------------------------------------------------------------------------------------------------------------------------------------
* Author                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Teja Sri Dasari       12-Mar-2018        Initial Version
**************************************************************************************/
public class INTLContactTriggerService 
{      
    public static void afterInsert(List<Contact> triggerNew, Map<Id, Contact> triggerNewMap)
    {   
        //Added by brian@pedowitzgroup.com to handle marketo sync permissions.
        if(CheckRecursiveTrigger.runOnce())
        {            
            List<Contact> contactList = new List<Contact>();
            ContactUtility contactutil = new ContactUtility();  
            for(Contact c : triggerNew){
                contactList.add(c);
            }   
            contactutil.setMKTOPermissions(contactList);
        }
        
        // create address record that is primary to the related Account     
        ZTS_EU_ContactAddinsertfromAccount.insertAddress(triggerNew);
        // create Account Contact Affiliation record
        ZTS_EU_Affiliation_Update.createAccountContactAffiliationRecord(triggerNew);
        // DEF-000417 - Update Local & Inherited Address Flag on Contact if it's own Primary Address is updated 
        ContactPrimaryAddressCheck.localInhetitedPrimaryAddressUpdate(triggerNew);
        
        /* if (ObjectSettings__c.getValues('Contact') != null && ObjectSettings__c.getValues('Contact').Active__c == true)
        {
            List<Contact> ContactList = triggerNew; 
            TriggerHelperD.checkCommit2(ContactList, 'Contact', null);     
        } */
        
        if(ImprovacContactsService.canIrun)
        {
            ImprovacContactsService.prepareContacts('afterInsert', triggerNew, null);        
        }
    }
    
    public static void afterUpdate(List<Contact> triggerOld, Map<Id, Contact> triggerOldMap, List<Contact> triggerNew, Map<Id, Contact> triggerNewMap)
    {   
        //Added by brian@pedowitzgroup.com to handle marketo sync permissions.
         //    System.debug('CheckRecursiveTrigger.runOnce()--->'+CheckRecursiveTrigger.runOnce());
        if(CheckRecursiveTrigger.runOnce())
        {            
            List<Contact> contactList = new List<Contact>();
            ContactUtility contactutil = new ContactUtility();  
            for(Contact c : triggerNew){
                contactList.add(c);
            }   
            contactutil.setMKTOPermissions(contactList);
        }
        if( UtilityService.iscontactTriggerRun() )
        {
            // update Affiliation record INC0409371
            boolean isChanged = false;
            boolean isStatusChanged = false;
            ZTS_EU_contypeUpdateonAff.contypeUpdateonAff(triggerNew, triggerOldMap);
            
            //Srinivas K added code as part of the defect fix INC0657967
            List<String> listOfApplicableMarkets = new List<String>();  
            set<string> geoMarkets = new set<string>() ;  
            List<Contact> toUpdateSamplesOfActivatedContactList = new List<Contact>();      
            listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
            
            if(listOfApplicableMarkets != null && listOfApplicableMarkets.size()>0){
                for(string market : listOfApplicableMarkets){           
                    geoMarkets.add(market);
                }
            }
            
            for(Contact con: triggerNew)
            {
                Contact contact = triggerOldMap.get(con.id);
                System.debug('Full_Contact_Name__c :'+contact.Full_Contact_Name__c);
                System.debug('ZTS_EU_Contact_Status__c :'+contact.ZTS_EU_Contact_Status__c);
                System.debug('ZTS_EU_Contact_Status__c :'+con.ZTS_EU_Contact_Status__c);
                System.debug('con.Full_Contact_Name__c-->'+con.Full_Contact_Name__c);
                
                if(contact.Full_Contact_Name__c!= con.Full_Contact_Name__c)
                {
                    isChanged = true;
                }
                if(contact.ZTS_EU_Contact_Status__c != con.ZTS_EU_Contact_Status__c)
                {
                    isStatusChanged = true;
                }
                
                //Srinivas K added code as part of the defect fix INC0657967
                if(geoMarkets.contains(con.ZTS_EU_Market__c) && con.ZTS_EU_Contact_type__c =='Veterinarian' && con.ZTS_EU_Contact_Status__c== 'Active'&& contact.ZTS_EU_Contact_Status__c != con.ZTS_EU_Contact_Status__c && con.ZTS_EU_Create_Samples__c ){
                    toUpdateSamplesOfActivatedContactList .add(con);
                }
                
            }
            
            if(toUpdateSamplesOfActivatedContactList != null && toUpdateSamplesOfActivatedContactList .size()>0){
                ZTS_EU_SampleAndSampleDropUtility.processSampleDataForActivatedContacts(toUpdateSamplesOfActivatedContactList );
            }
            
            if(isChanged == true)
            {
                ZTS_EU_UpdateAffNameAndContactName.updateAffNameOnContactNameUpdate(Trigger.new); 
            }      
            // update ACA when Contact status becomes inactive
            if(isStatusChanged == true)
            {
                //ZTS_EU_Affiliation_Update.UpdateContactAffilation(Trigger.New,Trigger.old,Trigger.newMap,Trigger.oldMap);
                ZTS_EU_Affiliation_Update.UpdateContactAffilation(Trigger.New);
            }    
            // update address record with address fields
            
            //Code Added by CloudSense:Parvez for T-14216/DEF-000078
            //    ZTS_EU_Bring_Offline_UtilityClass.deleteContactRecords(trigger.new);        
            //EOC Added by CloudSense Parvez
            
            // Sohil-->This method is used to update Affiliation records of AccountContactAffiliationRecord if the contact's Account has been changed DEF-000917
            List<Contact> contactList = new List<Contact>();
            List<Contact> contactList2 = new List<Contact>();
            for(Contact con : triggerNew)
            {
                Contact contactObj = triggerOldMap.get(con.id);
                if(con.AccountId != contactObj.AccountId)
                {
                    contactList.add(con);
                }
                // Sohil  DEF-000417 - Update Local Address Flag on Contact if it's own Primary Address is updated 
                if(con.ZTS_EU_Primary_Address__c != contactObj.ZTS_EU_Primary_Address__c)
                {
                    
                    contactList2.add(con);
                }
                //EOC Sohil - DEF-000417
            }
            // Sohil  DEF-000917
            String str = userinfo.getUserId();
            User us = [Select Id,ZTS_EU_Market__c from User where id=:str];
            if(us.ZTS_EU_Market__c == 'Spain')
            {
                ZTS_EU_Affiliation_Update.updateAccountContactAffiliationRecord(contactList);
            } // EOC Sohil DEF-000917
            
            // Sohil  DEF-000417 - Update Local Address Flag on Contact if it's own Primary Address is updated 
            ContactPrimaryAddressCheck.localInhetitedPrimaryAddressUpdate(contactList2);
        }
        
        /* if (ObjectSettings__c.getValues('Contact') != null && ObjectSettings__c.getValues('Contact').Active__c == true)
        {
            List<Contact> ContactList = triggerNew; 
            TriggerHelperD.checkCommit2(ContactList, 'Contact', triggerOldMap);     
        } */
        
        if(ImprovacContactsService.canIrun)
        {
            ImprovacContactsService.prepareContacts('afterUpdate', triggerNew, triggerOldMap); 
        }
    }
    
    public static void beforeInsert(List<Contact> triggerNew) 
    {
        
        //SC-009335 - Extend phone number to E.164 formatting
        List<E164_Format__mdt> e164Lst = new List<E164_Format__mdt>();
        e164Lst = [SELECT id,Country__c,Country_Code__c,NumberofDigits__c from E164_Format__mdt];
        String countryCode = '';
        Integer digitinNum = 0;
        for (Contact con : triggerNew) {
            for(E164_Format__mdt e164Mdt : e164Lst)
           	   if (con.Phone != null && con.ZTS_EU_Market__c == e164Mdt.Country__c ) {
                	countryCode = string.valueof(e164Mdt.Country_Code__c);
               	    digitinNum  = integer.valueof(e164Mdt.NumberofDigits__c);
                	con.phone = UtilityService.getE164FormattedPhoneNumber(con.phone,countryCode,digitinNum , 'INTL');
            }
        }//SC-009335 End
        
        //string accOwner; *not being used*
        List<AccountAndContactOwnerId__c> ownerids= AccountAndContactOwnerId__c.getall().values();
        Map<string, string> MarketUserIdMap=new Map<string,string>(); 
        boolean isUpdate = false;
        
         for(AccountAndContactOwnerId__c customvalues:ownerids){
            MarketUserIdMap.put(customvalues.Market__c,customvalues.OwnerId__c);
         }
        for(Contact con: triggerNew)
        { 
            if(MarketUserIdMap.containsKey(con.ZTS_EU_Market__c)&& MarketUserIdMap.containsKey(con.OwnerId)!=null)
            {
                con.OwnerId=MarketUserIdMap.get(con.ZTS_EU_Market__c);
                isUpdate = true;
            }
            
            //Added by Rachana: TPDEV-479
            if(con.HasOptedOutOfEmail && con.ZTS_EU_Market__c=='Germany')
                con.ZTS_EU_Opt_Out_Email__c = true;
            else if(con.ZTS_EU_Opt_Out_Email__c && con.ZTS_EU_Market__c=='Germany')
                con.HasOptedOutOfEmail = true;
            //End
        }

        set<ID> setAcc = new set<Id>();
        for(Contact con: triggerNew){
            If(Con.AccountId != null){
                setAcc.add(con.AccountId);
            }
        }
        
        //Shefali  22nd Dec 2014 Added for populating the City Text field
        ZTS_Account_Utility.populateCity(triggerNew);
        /******************
        Added this as a part of defect 213 and 468
        *******************/
        List<Contact> lstCon = new List<Contact>();
        for(Contact con: triggerNew){
            if(Con.ZTS_EU_Market__c == null){
                lstCon.add(con);
            }
        }
        
        // Commenting line number 233 because this class is already mentioned in Contact Trigger - Modified by Chanbasha Nbsk on 6/23/2021.
        // update market
        //ZTS_EU_UpdateMarket.Contact_updateMarket(lstCon);
        // update Inherited Address Flag Sohil(CloudSense) DEF-000417
        
        /* if (ObjectSettings__c.getValues('Contact') != null && ObjectSettings__c.getValues('Contact').Active__c == true)
        {
            List<Contact> ContactList = triggerNew;   
            // проверка на вставку/обновление контакта
            TriggerHelperD.CheckToken(ContactList, 'Contact', null);       
            TriggerHelperD.checkCommit(ContactList);
        } */
            
    }
    
    public static void beforeUpdate(List<Contact> triggerOld, Map<Id, Contact> triggerOldMap, List<Contact> triggerNew, Map<Id, Contact> triggerNewMap) 
    {
        
        //SC-009335 - Extend phone number to E.164 formatting
        List<E164_Format__mdt> e164Lst = new List<E164_Format__mdt>();
        e164Lst = [SELECT id,Country__c,Country_Code__c,NumberofDigits__c from E164_Format__mdt];
        String countryCode = '';
        Integer digitinNum = 0;
        
        for (Contact con : triggerNew) {
              System.debug('con.Phone--->'+con.Phone);
         System.debug('triggerOldMap.get(con.Id).Phone--->'+triggerOldMap.get(con.Id).Phone);
         System.debug('con.ZTS_EU_Market__c'+con.ZTS_EU_Market__c);
            for(E164_Format__mdt e164Mdt : e164Lst)
            	if (con.Phone != null && con.Phone != triggerOldMap.get(con.Id).Phone && con.ZTS_EU_Market__c == e164Mdt.Country__c ) {
                	countryCode = string.valueof(e164Mdt.Country_Code__c);
                	digitinNum  = integer.valueof(e164Mdt.NumberofDigits__c);
                	con.Phone = UtilityService.getE164FormattedPhoneNumber(con.Phone,countryCode,digitinNum,'INTL');
            }
            
            
            //Added by Rachana: TPDEV-479
            if(triggerOldMap.get(con.Id).HasOptedOutOfEmail != triggerNewMap.get(con.Id).HasOptedOutOfEmail && con.ZTS_EU_Market__c=='Germany')
                con.ZTS_EU_Opt_Out_Email__c = triggerNewMap.get(con.Id).HasOptedOutOfEmail;
            if(triggerOldMap.get(con.Id).ZTS_EU_Opt_Out_Email__c != triggerNewMap.get(con.Id).ZTS_EU_Opt_Out_Email__c && con.ZTS_EU_Market__c=='Germany')
                con.HasOptedOutOfEmail = triggerNewMap.get(con.Id).ZTS_EU_Opt_Out_Email__c;
            //Ended
            
            
        }//SC-009335 End
        //string accOwner; *not being used*
        List<AccountAndContactOwnerId__c> ownerids= AccountAndContactOwnerId__c.getall().values();
        Map<string, string> MarketUserIdMap=new Map<string,string>(); 
        boolean isUpdate = false;
        
        for(Contact con: triggerNew)
        {
            if(MarketUserIdMap.containsKey(con.ZTS_EU_Market__c) && con.OwnerId!=MarketUserIdMap.get(con.ZTS_EU_Market__c) && MarketUserIdMap.containsKey(con.OwnerId)!=null)
            {
                con.OwnerId=MarketUserIdMap.get(con.ZTS_EU_Market__c);
                isUpdate = true;
            }             
        }
        if(UtilityService.iscontactTriggerRun())
        {
            // on update of primary Address look up update the address fields on contact
            ZTS_EU_Update_Address.updateAddressFieldsOfContact(triggerNew,triggerOldMap);
            // throw alert when rep status is inactivated
            //Ilirjana 23/09/2014 added safe block with checking for null values
            if (triggerNewMap != null && triggerOldMap != null)
                ZTS_EU_RepStatusInactive.cannotinactivate(triggerNew,triggerNewMap,triggerOldMap);
            /******************
            Added this as a part of defect 213 and 468
            *******************/
            List<Contact> lstCon = new List<Contact>();
            for(Contact con: triggerNew){
                if(Con.ZTS_EU_Market__c == null){
                    lstCon.add(con);
                }
            }
            // update market
            ZTS_EU_UpdateMarket.Contact_updateMarket(lstCon);

            //Shefali  22nd Dec 2014 Added for populating the City Text field
            List<Contact> contactListToPopulateCity = new List<Contact>();
            for(Integer i=0; i<triggerNew.size() ;i++){
                if(triggerNew[i].ZTS_EU_City_Country__c != triggerOld[i].ZTS_EU_City_Country__c){
                    //ZTS_Account_Utility.populateCity(triggerNew);
                    contactListToPopulateCity.add(triggerNew[i]);
                }
            }
            
            ZTS_Account_Utility.populateCity(contactListToPopulateCity);
        }
        
        /* if (ObjectSettings__c.getValues('Contact') != null && ObjectSettings__c.getValues('Contact').Active__c == true)
        {
            List<Contact> ContactList = triggerNew; 
            TriggerHelperD.CheckToken(ContactList, 'Contact', triggerOldMap);       
            TriggerHelperD.checkCommit(ContactList);
        } */
    }
    
    public static void beforeDelete(List<Contact> triggerOld, Map<Id, Contact> triggerOldMap) 
    {
        // The below commented code is for storing the account primary address to all related contacts 
        // ZTS_EU_ContactAddinsertfromAccount.ContactAddinsertfromAccount(setAcc,trigger.new);
        
        /******************
        Added this as a part by Srinivas of defect DEF-000073 (T-12613)
        *******************/
        if(UtilityService.iscontactTriggerRun()){    
            ZTS_EU_Affiliation_Update.deleteAccountContactAffiliationRecord (triggerOld);     
        }
    }
}