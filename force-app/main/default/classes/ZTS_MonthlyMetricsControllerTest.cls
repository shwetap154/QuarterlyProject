/*******************************************************************************************************************************************
* File Name     :  ZTS_MonthlyMetricsControllerTest
* Description   :  This is the test class for the class: ZTS_MonthlyMetricsController.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     29th-Apr-15   Shreyas             Created the class.

********************************************************************************************************************************************/
@isTest
Public class ZTS_MonthlyMetricsControllerTest{
    public static testMethod void testMethod1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        List<Call__c> callList = new List<Call__c>();
        System.runAs(usr)
        {
            callList = ZTS_EU_DataUtilityTest1.createCallRecord(3);
            for(Call__c c: callList){
                c.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
            }
            callList[0].ZTS_EU_Start_Date_Time__c = system.now();  
            callList[0].ZTS_EU_End_Date_Time__c = system.now().addHours(1);  
            
            insert callList;
            
            Call__c call = new Call__c();
            call = [Select Id, ZTS_EU_Account__c from Call__c where Id =: callList[0].Id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            string accId = call.ZTS_EU_Account__c;
            
            System.runAs(usr)
            {
                Account a = [Select Id, ZTS_EU_RAT_CA__c from Account where Id =: accId AND ZTS_EU_Market__c != 'United States'];
                a.ZTS_EU_Market__c = 'New Zealand';
                a.ZTS_EU_RAT_CA__c = 'Non-CA';
                update a;
            }
            test.startTest();        
            
            List<Time_Out_of_Territory__c> totList = ZTS_EU_DataUtilityTest1.createToTOffPM(1);
            totList[0].ZTS_EU_Start_Date__c = system.today();  
            totList[0].ZTS_EU_End_Date__c = system.today() + 1;
            totList[0].OwnerId = userinfo.getuserId();
            totList[0].ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            insert totList;
            System.runAs(usr)
            {
                ZTS_EU_Account_Position__c ap = ZTS_EU_DataUtilityTest.createAccountPosition(userinfo.getuserId(), accId);
            }
            Holiday__c holiday = ZTS_EU_DataUtilityTest.createHoliday('New Zealand', true);
            ZTS_MonthlyMetricsController obj1;
            System.runAs(usr)
            {
                obj1 = new ZTS_MonthlyMetricsController();
            }
            obj1.selectedRatingLabel = 'CA';
            obj1.selectedRatingValue = 'Non-CA';
            obj1.getAccountBySegmentDetails();
            
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.All;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.CADPre;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.CADTher;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.CA;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.CTBF;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.CTDY;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.CTFL;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.EQ;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.PY;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.RU;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.SW;
            obj1.getRatingValues();
            obj1.selectedRatingLabel = ZTS_EU_GlobalConstants.VPS;
            obj1.getRatingValues();
            
            
            test.stopTest();
            
        }
    }
    
}