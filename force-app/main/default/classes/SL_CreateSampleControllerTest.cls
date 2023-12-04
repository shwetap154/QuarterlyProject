/**
 * @description       : Test class for Test class for SL_CreateSampleController, SL_SampleCreationSchedule, SL_SampleFromProductsBatch, SL_SampleCreationHelper
 * @author            : Premraj K K @ Silverline
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   10-15-2019   Premraj K K @ Silverline    Initial Version JIRA Ticket LIGHTNI-1682,LIGHTNI-1684
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Add header and fix errors due to Contact validation rule and Account Market defaulting to US
**/
@isTest
public class SL_CreateSampleControllerTest {
	
    @testSetup 
    static void test_SetUp() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            Account a = ZTS_DataUtilityTest.createAccountRecord(1)[0];
            a.BillingPostalCode = '00000';
            a.BillingCity = 'testCity';
            a.BillingState = 'testState';
            a.BillingStreet = 'testStreet';
            a.ZTS_EU_Market__c = 'Italy';
            insert a;

            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            Contact c = ZTS_DataUtilityTest.createContactRecord(1)[0];
            c.AccountId = a.Id;
            c.ZTS_EU_Contact_type__c = 'Veterinarian';
            c.ZTS_EU_District__c = 'UK';
            c.ZTS_EU_Market__c = 'Italy';

            insert c;
            
            insert new List<ZTS_EU_Species_Product__c> { 
                new ZTS_EU_Species_Product__c(Name = 'P1', ZTS_EU_Market__c = 'Germany', ZTS_EU_Type__c = 'Therapeutic Group', ZTS_EU_is_Samplable__c = true),
                    new ZTS_EU_Species_Product__c(Name = 'P2', ZTS_EU_Market__c = 'Italy', ZTS_EU_Type__c = 'Brand', ZTS_EU_is_Samplable__c = true)
                    };
            }
    }
    
    static testMethod void TestCreateSample() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<ZTS_EU_Species_Product__c> prods = [Select Id
                                                    From ZTS_EU_Species_Product__c
                                                    Where ZTS_EU_Market__c = 'Italy'];
            
            List<Contact> contacts = [Select Id
                                    From Contact
                                    Where ZTS_EU_Market__c = 'Italy'];
            
            if(!prods.isEmpty()) {
                Test.startTest();
                SL_CreateSampleController.createSamples(prods[0].Id);
                SL_CreateSampleController.createSamples(contacts[0].Id);
                
                SL_SampleCreationSchedule schedule = new SL_SampleCreationSchedule();
                String cron = '0 0 0 1/1 * ? *';
                System.schedule('Create Samples for Contacts test', cron, schedule);
                
                Test.stopTest();
            }
        }
    }
}