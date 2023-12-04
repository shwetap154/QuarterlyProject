/*************************************************************************************************************************
  Class Name     : ZTS_US_Account_Sample_Drop_Controller
  Description    : This Trigger creates a new Account Sample Drop on insert & updates Account Sample Drop upon Sample Drop create and update
  Created By     : Laxmikanth
  Created On     : 08/31/2015
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                             Date                   Description
  ---------                             ----                 -----------
  CloudSense Constulting/Laxmikanth    08/31/2015              Created
  
***************************************************************************************************************************/
Public class ZTS_US_Account_Sample_Drop_Controller{

     /* This method is used to insert record into Account_Sample_Drop__c object whenever a new contact is created
    * from Related List Account Contact Affiliation -'Add Contact' button in Account record.
    * Release Note -RN-144
    * User Story - US-0067
    */
    public static void createAccounSampleDrop(List<ZTS_US_Sample_Drop__c> newSampleDropList)
    {
        List<Account_Sample_Drop__c> AccountSampleDropInsertList = new List<Account_Sample_Drop__c>();
        for(ZTS_US_Sample_Drop__c eachSampleDrop: newSampleDropList){
           
            Account_Sample_Drop__c accountSampleDropRecord = new Account_Sample_Drop__c();
            
            accountSampleDropRecord.ZTS_US_Account__c = eachSampleDrop.ZTS_US_Account__c;
            accountSampleDropRecord.Sample_Drop_ID__c = eachSampleDrop.Id;
            accountSampleDropRecord.ZTS_US_Call__c = eachSampleDrop.ZTS_US_Call__c;
            accountSampleDropRecord.ZTS_US_Quantity__c=eachSampleDrop.ZTS_EU_Quantity__c;
            accountSampleDropRecord.Drop_Created_Date__c=eachSampleDrop.createddate.date();
            accountSampleDropRecord.ZTS_US_Sample__c=eachSampleDrop.ZTS_US_Sample__c;
            accountSampleDropRecord.ZTS_US_Sample_Drop_Type__c=eachSampleDrop.ZTS_US_Sample_Drop_Type__c;
            accountSampleDropRecord.ZTS_US_Signature_Captured__c=eachSampleDrop.ZTS_US_Signature_Captured__c;
            AccountSampleDropInsertList.add(accountSampleDropRecord);
            
        }
        
        if(!AccountSampleDropInsertList.isEmpty()){
            try{
                //Database.insert(contactAffiliationInsertList);
               List<Database.Saveresult> results=Database.insert(AccountSampleDropInsertList,false);
                 ZTS_EU_Logger.error(results,'ZTS_US_Account_Sample_Drop_Controller-createAccounSampleDrop');
                 
    

            }
            catch(Exception e){
                ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_US_Account_Sample_Drop_Controller-createAccounSampleDrop');
            }
        }
    }
    
    public static void deleteAccounSampleDrop(List<ZTS_US_Sample_Drop__c> deletedSampleDropList)
    {   
        List<String> deletedDrops = new List<String>();
        
        for(ZTS_US_Sample_Drop__c eachSampleDrop:deletedSampleDropList){
            deletedDrops.add(eachSampleDrop.id);
            }
        List<Account_Sample_Drop__c> AccountSampleDropDeleteList = new List<Account_Sample_Drop__c>();
        for(Account_Sample_Drop__c eachAccountSampleDrop: [select id,Sample_Drop_ID__c from Account_Sample_Drop__c where Sample_Drop_ID__c IN : deletedDrops]){
            AccountSampleDropDeleteList.add(eachAccountSampleDrop);
            }
        if(AccountSampleDropDeleteList != null && AccountSampleDropDeleteList.size() > 0){
            delete AccountSampleDropDeleteList;
           }
      }   
           
}