/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_SampleHandlerForContact
* Description   :  Batch class for handling creation and deactivation of Samples on creation and deactivation of contacts.                       

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21st-Nov-14   Shreyas             Created the class.
* 1.1     17th-April-15 Sohil(CloudSense)   Modified the code for DEF-000673(Only for Active and Italy + Veterian Types Contacts )
********************************************************************************************************************************************/
global class ZTS_EU_Batch_SampleHandlerForContact implements Database.Batchable<SObject>

{
    
   global Database.queryLocator start(Database.BatchableContext bc) {
   
       List<String> listOfApplicableMarkets = new  List<String>();
       listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
       String contactStatus_Active = 'Active';
       String contactType = 'Veterinarian';
       String query = 'Select Id, ZTS_EU_Create_Samples__c, ZTS_EU_Contact_type__c, ZTS_EU_Contact_Status__c, Account.Id, ZTS_EU_Market__c from Contact'; 
            query = query + ' where (ZTS_EU_Create_Samples__c = False AND ZTS_EU_Contact_Status__c =: contactStatus_Active  AND ZTS_EU_Contact_type__c =: contactType AND ZTS_EU_Market__c IN: listOfApplicableMarkets)';        
       return Database.getQueryLocator(query);   
    }
        
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
           
        List<Contact> contactList = new List<Contact>();
        for(Contact c: scope){
            contactList.add(c);
        }
        
        ZTS_EU_Batch_SampleHandlerController.processSampleDataForContacts(contactList);
       
    }
     
    
    global void finish(Database.BatchableContext bc) {
                

    } 


}