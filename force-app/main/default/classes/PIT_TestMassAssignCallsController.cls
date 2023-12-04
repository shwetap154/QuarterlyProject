@isTest
public with sharing class PIT_TestMassAssignCallsController {
    
    public testmethod static void test_PIT_MassAssignCallsController(){
        
        /*Select 
        z.ZTS_US_User_Territory_Uniq_Key__c, 
        z.ZTS_US_Territory__c, 
        z.ZTS_US_Territory_Name__c, 
        z.ZTS_US_Start_Date__c, 
        z.ZTS_US_Processed__c, 
        z.ZTS_US_End_Date__c, 
        z.ZTS_US_Employee__c, 
        z.ZTS_US_ChangeFlag__c, 
        z.Name 
        From ZTS_US_UserTerritory__c z
        */
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        Account acc = new Account();
        acc.Name = 'Test123';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        System.runAs(usr)
        {
            insert acc;
        }
        
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United kingdom';
        //cg.PIT_Colleague_Territory__c = '';
        //cg.PIT_Colleagues_Director__c = '';
        //cg.PIT_Colleagues_Manager__c = '';
        //cg.PIT_Copy_Comments__c = '';
        //cg.PIT_Date_of_Visit__c = '';
        //cg.PIT_Day_Summary__c = '';
        //cg.PIT_Last_Session__c = '';
        //cg.PIT_No_of_Account_Calls__c = '';
        //cg.PIT_No_of_Days_in_Field__c = '';
        //cg.PIT_Notification_Extra_Email__c = '';
        //cg.PIT_Users_Match__c = '';
        //cg.PIT_Check_Current_User_Coach__c = '';
        //cg.PTI_Check_Current_User_Colleague__c = '';
        //cg.PTI_Check_Current_User_Manager__c = '';
        
        insert cg;
        
        Call__c c1 = new Call__c();
        c1.ZTS_EU_Status__c = 'Submitted';
        c1.ZTS_EU_Start_Date_Time__c = System.now().addDays(-1);
        c1.ZTS_EU_End_Date_Time__c = System.now();
        c1.PIT_Coaching_Guide__c = null;
        c1.ZTS_EU_Account__c = acc.Id;
        insert c1;
        
        Test.startTest();
    
        PageReference pageRef = Page.PIT_MassAssignCalls;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',cg.id);            
        
        Call__c[] chck = [select Id from Call__c where PIT_Coaching_Guide__c = :cg.Id];
        System.assert(chck.size() == 0, 'At this stage no related calls should be found');
        
        PIT_MassAssignCallsController ctl = new PIT_MassAssignCallsController();
        System.assert(ctl.foundEls.size() == 1, 'Single call should be potentially found and availale in the app');
        
        ctl.foundEls[0].selected = true;
        ctl.assignCalls();
        
        chck = [select Id from Call__c where PIT_Coaching_Guide__c = :cg.Id];
        System.assert(chck.size() == 1, 'Now record should be assign for contextual coaching guide');
        
        Map<Id, Integer> mIdCoachingGuide2Change = new Map<Id, Integer>();
        Integer i = 3;
        mIdCoachingGuide2Change.put(cg.Id, i);
        Integer j = 2;
        PIT_MassAssignCallsController.addEntryToMap(mIdCoachingGuide2Change, cg.Id, j);
        
        System.assert(mIdCoachingGuide2Change.get(cg.Id) == i + j, 'Method should assign sum of prev. value and new one.');
        
        mIdCoachingGuide2Change = new Map<Id, Integer>();
        PIT_MassAssignCallsController.addEntryToMap(mIdCoachingGuide2Change, cg.Id, j);
        System.assert(mIdCoachingGuide2Change.get(cg.Id) == j, 'In case of not found element, passed value should be used.');
        
        delete chck;
             
    }
    
    
}