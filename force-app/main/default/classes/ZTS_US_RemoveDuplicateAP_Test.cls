/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_US_RemoveDuplicateAP_Test.cls
   Description: Test Class for Batch Apex 
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   02-02-2022   1.0     Amitabh               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_US_RemoveDuplicateAP_Test {
    @TestSetup
    static void setUpData(){  
 
    }
    static testMethod void testAPsBatch(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration Profile', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        User usr1 = new User();
        usr1 = ZTS_EU_DataUtilityTest.createUserWithProfile('US Business Administrator', false);
        usr1.FirstName = 'davidsUser1';
        usr1.zts_eu_market__c = 'United States';
        insert usr1;
        
         ZTS_EU_Territory__c GerUsTerr = new ZTS_EU_Territory__c(
         Name = 'US-Terr-T4304',
         ZTS_EU_Market__c = 'United States'
         );
         insert GerUsTerr; 
        
         Account Act=new Account(
         Name = 'Test',
         ZTS_EU_Market__c = 'United States',
         ZTS_US_NARC_ID__c='322382'
         );
         insert Act;
        
        List<ZTS_EU_Position__c> testPositions= new List<ZTS_EU_Position__c>();
        ZTS_EU_Position__c testPosition1 = new ZTS_EU_Position__c(
        ZTS_EU_Territory__c = GerUsTerr.id,
        ZTS_EU_Employee__c = usr.Id
        );
        testPositions.add(testPosition1);
         ZTS_EU_Position__c testPosition2 = new ZTS_EU_Position__c(
        ZTS_EU_Territory__c = GerUsTerr.id,
        ZTS_EU_Employee__c = usr.Id
        );
        
        testPositions.add(testPosition2);
        insert testPositions;
        
       List<ZTS_EU_Account_Position__c> testAccPositions= new List<ZTS_EU_Account_Position__c>();
       ZTS_EU_Account_Position__c newAccPosition1 =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = Act.id,
            ZTS_EU_Position__c = testPositions[0].id,
            ZTS_EU_Call_Target__c = 1
        );
       testAccPositions.add(newAccPosition1);
        ZTS_EU_Account_Position__c newAccPosition2 =  new ZTS_EU_Account_Position__c (
            ZTS_EU_Account__c = Act.id,
            ZTS_EU_Position__c = testPositions[1].id,
            ZTS_EU_Call_Target__c = 3
        );
        testAccPositions.add(newAccPosition2);
        insert testAccPositions;
        
             System.runAs(usr)
             { 
             Test.startTest();
                 ZTS_US_RemoveDuplicateAP batchIns = new ZTS_US_RemoveDuplicateAP();
                 Database.executeBatch(batchIns);
                 Test.stopTest();
                 List<ZTS_EU_Account_Position__c> my_list =  [SELECT Id,ZTS_AccountUserTerrUniqueKey__c FROM ZTS_EU_Account_Position__c where ZTS_EU_Market__c = 'United States'];
                 System.assertEquals(my_list.size(),2);
                 System.assertEquals(my_list[0].ZTS_AccountUserTerrUniqueKey__c != my_list[1].ZTS_AccountUserTerrUniqueKey__c, true);
            }
         
     }
}