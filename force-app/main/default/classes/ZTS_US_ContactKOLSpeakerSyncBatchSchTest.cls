/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ZTS_US_ContactKOLSpeakerSyncBatchSchTest {

  static testMethod void testSync() {
     ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
    List<Contact> lstcon = ZTS_DataUtilityTest.createContactRecord(5);
    for(Contact con : lstcon){
	    con.ZTS_EU_Contact_Status__c = 'Active';
      con.ZTS_US_Speaker_Flag__c=true;
      con.ZTS_EU_Market__c = 'United States';
	    }
    insert lstcon;
     
    List<ZTS_EU_KOL__c> kolList=new List<ZTS_EU_KOL__c>();
    for(Contact con:lstcon){
	    ZTS_EU_KOL__c kolrecord = new ZTS_EU_KOL__c(ZTS_EU_Contact__c=con.id,ZTS_US_Therapeutic_Class__c='Anesthetic',ZTS_US_Role__c='Influencer',ZTS_US_End_Date__c=Date.today().addDays(5));
	    ZTS_EU_KOL__c kolrecord1 = new ZTS_EU_KOL__c(ZTS_EU_Contact__c=con.id,ZTS_US_Therapeutic_Class__c='Anesthetic',ZTS_US_Role__c='Speaker',ZTS_US_End_Date__c=Date.today().addDays(-2));
	    kolList.add(kolrecord);
	    kolList.add(kolrecord1); 
	    }
    insert kolList;
    
   Test.startTest(); 	
	    Database.executeBatch(new ZTS_US_ContactKOLSpeakSyncBatchScheduler());
   Test.stopTest();
    Integer cnt=[SELECT COUNT() FROM Contact WHERE ZTS_US_KOL_Speaker_SyncStatus__c=false AND ZTS_EU_Market__c = 'United States'];
    System.assertEquals(0, cnt,'Update of KOL and Speaker Flags failed');
    }
    
   static testMethod void testStartSchedule() {
   Test.startTest(); 	
    ZTS_US_ContactKOLSpeakSyncBatchScheduler.start();
    Test.stopTest();
    }
}