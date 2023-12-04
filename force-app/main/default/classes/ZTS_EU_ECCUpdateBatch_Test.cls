/***************************************************************************** 
* Class Name     : ZTS_EU_ECCUpdateBatch_Test
* Description    : This test class is used to increase the test code coverage for ZTS_EU_ECCUpdateBatch.
*                
*      
* Created By   : Tanmoy Bardhan(Cognizant Technology Solutions)
* Created Date : 13th Feb, 2017.
*
* Modification Log: 
* ----------------------------------------------------------------------------
* Developer                Date               Description 
* ----------------------------------------------------------------------------
* 
******************************************************************************/
@isTest
public class ZTS_EU_ECCUpdateBatch_Test {
    static void init(){
        
        Profile p = [select id from profile where name='System Administrator' limit 1];
        User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                    Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                    TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
        insert userRecord;
        
        /* Insert test data for Account object */
        Account acc = new Account(Name = 'Test',Type = 'Administration',
                                  ZTS_EU_Market__c='United Kingdom',
                                  Practice_Management_Software__c = 'Other',
                                  Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                  ZTS_EU_Zip_Postal_Code__c = '12345');
        Insert acc;
        
        ZTS_EU_Territory__c	testTerritory = new ZTS_EU_Territory__c	(Name = 'TestSlalomTerr',
                                                                     ZTS_EU_Market__c = 'United Kingdom');
        insert testTerritory;  
        
        /* Insert test data for ZTS_EU_Position__c object */
        ZTS_EU_Position__c pos = new ZTS_EU_Position__c(ZTS_EU_Territory__c = testTerritory.Id);
        Insert pos;
        
        /* Insert test data for ZTS_EU_Account_Position__c object */
        ZTS_EU_Account_Position__c accpos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = acc.Id,ZTS_EU_Position__c=pos.Id, ZTS_EU_Call_Target__c = 1);
        Insert accpos;
        
        /* Insert test data for Call__c object */
        Call__c cl = new Call__c(ZTS_EU_Account__c = acc.Id, ZTS_EU_Call_Owner__c = userRecord.Id);
        Insert cl;       
        
        /* Insert test data for Attendee__c object */
        Attendee__c att = new Attendee__c(Name='TestAtt',ZTS_EU_call__c = cl.Id);
        Insert att;
        
        /* Insert test data for ZTS_EU_Discussion__c object */
        ZTS_EU_Discussion__c dis = new ZTS_EU_Discussion__c(Name='TestDis',ZTS_EU_Call_Attendee__c = att.Id);
        Insert dis;
        
        /* Update the ZTS_EU_Status__c field in Call_c object to Completed */
        cl.ZTS_EU_Status__c = 'Completed';
        Update cl; 
        
        /* Insert test data for ZTS_EU_Colleague__c object */
        ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c(Name = 'TestCol',CurrencyIsoCode = 'INR',ZTS_EU_Call__c = cl.Id);
        Insert col;
        
        /* Insert test data for ZTS_EU_Employee_Call_Credit__c object */
        ZTS_EU_Employee_Call_Credit__c empcl = new ZTS_EU_Employee_Call_Credit__c(Is_Call_status_Completed__c=false,ZTS_EU_Call__c = cl.Id,
                                                                                  ZTS_EU_Account_Position__c = accpos.Id,
                                                                                  ZTS_EU_Employee_Colleague__c = col.Id);
        Insert empcl;
    }
    
    static testMethod void ZTS_EU_ECCUpdateBatch(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            init();
            Test.startTest();
            ZTS_EU_ECCUpdateBatch ub = new ZTS_EU_ECCUpdateBatch();
            Database.executeBatch(ub);
            Test.stopTest();   
        }
    }
}