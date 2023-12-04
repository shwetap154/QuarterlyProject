/**
 * @description       : Test class for ZTS_EU_BatchToUpdateECCFY_Test
 * @author            : Srinivas K @ Cloudsense
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-08-2016   Srinivas K @ Cloudsense     Created the Class.
 * 1.1   07-25-2022   Ethan Hirsch @ Zoetis Inc   Add call to ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting
 *                                                to stop a null exception.
 *                                                Increase ZTS_EU_Submitted_Date__c to pass a validation rule.
 *                                                Create Attendees for each Call to prevent a null exception in 
 *                                                ZTS_EU_Contact_populateCallDates when updating Calls
 **/
@isTest
public class ZTS_EU_BatchToUpdateECCFY_Test {
    public static List<ZTS_Events__c> listEvents;
    public static List<Account> listAccount;
    public static List<Contact> listContact;
    public static Task tak;
    public static User u1,u;
    public static List<Call__c> listCalls;
    public static List<ZTS_EU_Employee_Call_Credit__c> ECClst;
    
    @testSetup
    public static void createTestData(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            
            listAccount = ZTS_EU_DataUtilityTest.createAccountRecord(2);
            insert listAccount;
            
            u = new User();
            u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', true);
            
            u1 = new User();
            u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', true);
            
            List<ZTS_EU_Account_Position__c> apList = new List<ZTS_EU_Account_Position__c>();
            ZTS_EU_Account_Position__c ap1 = ZTS_EU_DataUtilityTest.createAccountPosition(u.Id, listAccount[0].Id);
            apList.add(ap1);        
            ZTS_EU_Position__c p = new ZTS_EU_Position__c();
            p = ZTS_EU_DataUtilityTest.createPosition(u.Id, true);
            ZTS_EU_Position__c p1 = new ZTS_EU_Position__c();
            test.startTest();
            p1 = [Select ZTS_EU_Employee__c, Id from ZTS_EU_Position__c where Id =: p.Id];
            p1.ZTS_EU_Employee__c = u1.Id;
            update p1;
            ZTS_EU_Colleague__c collegue1 = new ZTS_EU_Colleague__c();
            collegue1 = ZTS_EU_DataUtilityTest.createColleague(u.id, listAccount[0].Id, true);
            listCalls = createCalls(listAccount);
            insert listCalls;
            listContact = ZTS_EU_DataUtilityTest.createContactRecord(1);
            insert listContact;
            ZTS_EU_Employee_Call_Credit__c ecc = new ZTS_EU_Employee_Call_Credit__c( ZTS_EU_Account_Position__c = ap1.id,ZTS_EU_Employee_Colleague__c = collegue1.id,ZTS_EU_Call__c = listCalls[0].Id);
            insert ecc;
            test.stopTest();            
        }
    }
    static void generateData(){      
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Attendee__c att = new Attendee__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert att;
            ZTS_EU_Species_Product__c spProd = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Brand',Name='Test',ZTS_EU_Is_Detailable__c=true);
            insert spProd;
            ZTS_EU_Species_Product__c spProd1 = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Business Unit',Name='Test');
            insert spProd1;
            Product2 prod = new Product2(ZTS_EU_Market__c='United Kingdom',Name='Test Product',ZTS_EU_Product_Type__c='Brand',isActive=true);
            insert prod;
            ZTS_EU_Species__c sp = new ZTS_EU_Species__c(ZTS_EU_Business_Unit__c=spProd1.Id,ZTS_External_ID__c='Test12',ZTS_EU_Market__c='United Kingdom',ZTS_EU_Species__c='TEst Species');
            insert sp;       
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Market__c='Brand',ZTS_EU_Active__c=true,ZTS_EU_Discussion_Item_Title__c='Test Item');
            insert discItem;
        }
    }
    /*-------insert Call__c object records------*/
    public static List<Call__c> createCalls(List<Account> listAcct){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        List<Call__c> listCall = new List<Call__c>();
        
        System.runAs(usr)
        {
            Profile p = [select id from profile where name='System Administrator' limit 1];
            User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                        Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                        TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
            insert userRecord;
            
            for(Account acc: listAcct){
                Call__c call = new Call__c(ZTS_EU_Account__c=acc.Id, ZTS_EU_Call_Owner__c = userRecord.Id,ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(1),
                                           ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today());
                listCall.add(call);
            }
        }
        return listCall;
    }
    static testMethod void saveAndSubmitTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            listCalls = [select id from call__c];
            listcontact = [select id from contact];
            listaccount = [select id from account];
            test.startTest();
            
            List<call__c> updateCalls = new List <Call__c>();
            List<Attendee__c> attn = new List<Attendee__c>();

            generateData();
            
            List<Contact> callContacts = new List<Contact> {listContact[0]};
            for(call__c calls:listCalls){
                calls.ZTS_EU_Status__c = 'Completed';
                calls.ZTS_EU_Submitted_Date__c = system.today().addDays(5);
                updateCalls.add(calls);

                Attendee__c testAttendee = ZTS_EU_DataUtilityTest.createAttendees(callContacts, calls)[0];
                testAttendee.ZTS_EU_Employee__c=UserInfo.getUserId();
                // Set External Id to a unique value for each Attendee as this is a unique field.
                testAttendee.ZTS_EU_External_ID__c = String.format('test{0}', new List<Object> {calls.Id});
                testAttendee.ZTS_EU_Represents_Account__c = listAccount[0].Id;
                attn.add(testAttendee);
            }

            insert attn;
            update updateCalls;
            test.stopTest();
            ZTS_EU_BatchToUpdateECCFY batcjob = new ZTS_EU_BatchToUpdateECCFY();
            Database.executeBatch(batcjob);
        }
    }
}