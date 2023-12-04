/**
 * @description       : Test class for TOTService_ForCreateduser
 * @author            : Chandra @ Deloitte
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   05-22-2014   Chandra @ Deloitte             Initial Version
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc      Add file header and run the Unit Test as an International User 
 *                                                   for code coverage
**/
@isTest
public class TOTService_ForCreateduser_Test {

    @TestSetup
    static void makeData() {
        ZTS_EU_Field_ID__c record = new ZTS_EU_Field_ID__c(Name = 'Event object Regular Event' );
        record.Description__c = 'Event object Regular Event';
        record.ZTS_EU_ID__c = '012F0000000WRKiIAO';
        insert record;

        // List <TriggerActivation__c> triggerActiveList = new List < TriggerActivation__c > ();
        // TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_AllTOTTrigger',ZTS_EU_Bypass__c = true);
        // triggerActiveList.add(tr);
        // insert triggerActiveList;
    }

    @IsTest
    static void TOTService_ForCreateduser() {            
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        List<Account> acc = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        // Run the full test as an International User to get proper code coverage and data setup
        System.runAs(usr)
        {
            List < Time_Out_of_Territory__c > totAMOffRecord = ZTS_EU_DataUtilityTest.createToTOffAM(1); 
            List < Time_Out_of_Territory__c > totPMONRecord = ZTS_EU_DataUtilityTest.createToTOffPM(1); 

            List < Time_Out_of_Territory__c > totAMOffRecord1 = ZTS_EU_DataUtilityTest.createToTOffAM(1); 
            List < Time_Out_of_Territory__c > totPMONRecord1 = ZTS_EU_DataUtilityTest.createToTOffPM(1); 
            List < Time_Out_of_Territory__c > totrecONFull = ZTS_EU_DataUtilityTest.createToTONFull(1);
            List < Time_Out_of_Territory__c > totONOFFAMRecord = ZTS_EU_DataUtilityTest.createToTONOFFAM(1); 
            List < Time_Out_of_Territory__c > totOFFONPMRecord = ZTS_EU_DataUtilityTest.createToTOFFONFull(1); 
            List < Time_Out_of_Territory__c > totFULLOffRecord = ZTS_EU_DataUtilityTest.createToTOffFull(1);
            List < Time_Out_of_Territory__c > totlst = new List < Time_Out_of_Territory__c > ();

            List < Time_Out_of_Territory__c > totAMONRecord = ZTS_EU_DataUtilityTest.createToTOffAM(1);
            List < Time_Out_of_Territory__c > totFULLONRecord = ZTS_EU_DataUtilityTest.createToTOffFull(1);
        
            insert acc;
        
        
            Datetime datm = Datetime.newInstance(2014, 9, 1, 14,00,00);
            Call__c Callrec = new Call__c(ZTS_EU_Account__c = acc[0].id, ZTS_EU_Duration__c = '2 hours', ZTS_EU_Sub_Type__c = 'Account Call', ZTS_EU_Start_Date_Time__c = datm  );
            Insert Callrec;
            
            List<User> usersList = ZTS_EU_DataUtilityTest.createcoacherUser();
            insert userslist;

            Test.startTest();
            List<Time_Out_of_Territory__c> totupd = new List<Time_Out_of_Territory__c>();
            List<Time_Out_of_Territory__c> totupd1 = new List<Time_Out_of_Territory__c>();

            database.Insert(totAMOffRecord);
            System.assert(totAMOffRecord[0].id != null);
            database.Insert(totPMONRecord);
            System.assert(totPMONRecord[0].id != null);        
            List<Time_Out_of_Territory__c> totoffcall = ZTS_EU_DataUtilityTest.createToTCallOnOff(1);

            for(Time_Out_of_Territory__c tot: totoffcall){
                tot.ownerid = userinfo.getuserid();
                tot.ZTS_EU_Start_Date__c = system.today();
                tot.ZTS_EU_End_Date__c = system.today()+3;
                tot.ZTS_EU_Duration__c =  'Full Day = 9 AM - 5 PM';
                tot.ZTS_EU_Type__c = 'Time Off';
                //tot.Record_Owner__c = usersList[0].id;
                totupd.add(tot);
            }
            insert totupd;

            List<Time_Out_of_Territory__c> totoncall = ZTS_EU_DataUtilityTest.createToTOFFONPM(1);
            for(Time_Out_of_Territory__c tot: totoncall){
                tot.ownerid = userinfo.getuserid();
                tot.ZTS_EU_Start_Date__c = system.today();
                tot.ZTS_EU_End_Date__c = system.today()+3;
                tot.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
                tot.ZTS_EU_Type__c = 'Time On';
                //tot.Record_Owner__c = usersList[0].id;
                totupd1.add(tot);   
            }
            insert totupd1;
            
            
            //system.debug('Test custom setting'+record);
            TOTService_ForCreateduser.generateAndSetupEventsFromToTs(totupd);
            TOTService_ForCreateduser.generateAndSetupEventsFromToTs(totupd1);
            
            List < Time_Out_of_Territory__c > updlst = new List < Time_Out_of_Territory__c > ();
            for (Time_Out_of_Territory__c tot: totAMOffRecord) {
                tot.ZTS_EU_Description__c = 'ToT From test class';
                updlst.add(tot);

                for (Time_Out_of_Territory__c toton: totPMONRecord) {
                    toton.ZTS_EU_Description__c = 'ToT From test class';
                    updlst.add(toton);
                }

            }
            upsert updlst;
            
            Test.stopTest();  
        }
    }
}