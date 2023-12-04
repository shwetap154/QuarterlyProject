/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_Batch_SampleHandlerForContact_Test.cls
   Description: Test Class for Class ZTS_EU_Batch_SampleHandlerForContact.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   28-11-2014   1.0     CloudSense(Shefali)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */


@isTest
public class ZTS_EU_Batch_SamplerContact_Test{
 
       static testMethod void testContacts(){
            User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'eltonUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
            System.runAs(usr)
        	{
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List<String> listOfApplicableMarkets = new  List<String>();
            listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
            Database.QueryLocator queryLoc;
            Database.BatchableContext BatchCont;
            
            ZTS_EU_Species_Product__c product1 = ZTS_EU_DataUtilityTest.createProduct('SKU', true);
            List<ZTS_EU_Species_Product__c> prodMainList =[Select ZTS_EU_Create_Samples__c,ZTS_EU_Is_Old__c, ZTS_EU_is_Samplable__c from ZTS_EU_Species_Product__c where Id =: product1.Id];
            prodMainList[0].ZTS_EU_Create_Samples__c = false;
            prodMainList[0].ZTS_EU_Is_Old__c = False;
            prodMainList[0].ZTS_EU_is_Samplable__c=true;
            update prodMainList;
            
            List<Contact> contList = ZTS_EU_DataUtilityTest.createContactRecord(4);
            contList[0].ZTS_EU_Create_Samples__c = False;
            contList[0].ZTS_EU_Contact_Status__c = 'Active';
            contList[0].ZTS_EU_Contact_type__c = 'Veterinarian';
            contList[0].ZTS_EU_Market__c ='United Kingdom';
            insert contList;
            
            ZTS_EU_Batch_SampleHandlerForContact testBatch = new ZTS_EU_Batch_SampleHandlerForContact();
            Test.startTest();
            testBatch.execute(BatchCont,contList);
            Test.stopTest();
            
            
            queryLoc= testBatch.start(BatchCont);
            System.debug('####Batch Context'+BatchCont);
            }
       }

}