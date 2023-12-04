/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_Batch_SmplHandlrFrInactiveContact 
* Description   :  This is a batch class that deactivates all the samples for the non active contacts and which are not of type Veterian .                        

* @author       :   CloudSense (Sohil shah)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     17th-April-15   Shreyas             Created the class.

********************************************************************************************************************************************/

global class ZTS_EU_Batch_SmplHandlrFrInactiveContact implements Database.Batchable<SObject>

{
     global final List<contact> contactListForDeactivatingSamples;  
      String contactStatus_Active;
       String contactType;   
       List<String> listOfApplicableMarkets; 
     global ZTS_EU_Batch_SmplHandlrFrInactiveContact()
     {
         contactStatus_Active = 'Active';  
         contactType = 'Veterinarian'; 
         listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();       
         contactListForDeactivatingSamples = [Select Id, ZTS_EU_Create_Samples__c, ZTS_EU_Contact_type__c, ZTS_EU_Contact_Status__c, Account.Id, ZTS_EU_Market__c,Is_Deactivated_Processed__c,ZTS_EU_Rep_Contact_Status__c from Contact 
        where (ZTS_EU_Create_Samples__c = True AND ZTS_EU_Contact_Status__c !=: contactStatus_Active AND Is_Deactivated_Processed__c = false AND ZTS_EU_Market__c IN: listOfApplicableMarkets)
        OR (ZTS_EU_Create_Samples__c = True AND ZTS_EU_Contact_type__c !=: contactType AND ZTS_EU_Market__c IN: listOfApplicableMarkets)  ];
                
     }
         
   global Database.queryLocator start(Database.BatchableContext bc) { 
       //skuProductList = new List<ZTS_EU_Species_Product__c>();
        System.debug('contactListForDeactivatingSamples----------------'+contactListForDeactivatingSamples);
        System.debug('contactListForDeactivatingSamples--Size--------------'+contactListForDeactivatingSamples.Size()); 
             
        String query = ' Select Id, ZTS_EU_Is_Active__c, ZTS_EU_Contact__c from ZTS_EU_Sample__c where ZTS_EU_Contact__c in: contactListForDeactivatingSamples ';  
        return Database.getQueryLocator(query);   
            
    }
        
    
    global void execute(Database.BatchableContext bc, List<ZTS_EU_Sample__c> scope) {
             
        List<ZTS_EU_Sample__c> sampleList = new List<ZTS_EU_Sample__c>();      
         for(ZTS_EU_Sample__c samples: scope)
         {
             sampleList.add(samples);
         }
        System.debug('sampleList--Size--------------'+sampleList.Size());    
        ZTS_EU_Batch_SampleHandlerController.processSampleDataForInactivatedContacts(sampleList);
    }
     
    
    global void finish(Database.BatchableContext bc) {
    boolean flag = false;
         List<Contact> contactListToUpdate = new List<Contact>();
        for(Contact con: contactListForDeactivatingSamples){
                contactListToUpdate.add(con);
                 if(con.Is_Deactivated_Processed__c == false)
                {
                    flag = true;
                }
            }
    
        if(contactListToUpdate.size() > 0 && flag == true){
            for(contact con: contactListToUpdate){
                if(con.ZTS_EU_Rep_Contact_Status__c == 'Inactive')
                {
                    con.ZTS_EU_Reason_for_Inactivation__c = 'No Longer in Practice';
                }
                con.Is_Deactivated_Processed__c = true;
                
            }
         }
        System.debug('contactListToUpdate----------------'+contactListToUpdate); 
        update contactListToUpdate;
    } 
   

}