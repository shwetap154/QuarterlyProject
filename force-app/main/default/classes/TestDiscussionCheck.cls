@IsTest
private class TestDiscussionCheck{
    static testmethod void afteInsertTest (){ 
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.LastName = 'Seliman';
        usr.Email = 'pleaseWork@gmail.com123454321';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Test.starttest();
            ZTS_DataUtilityTest.activateTriggerSettings();
            List<Call__c> calls = ZTS_DataUtilityTest.createCallRecord(1);
            Account a = [SELECT Id, ZTS_EU_Market__c FROM Account WHERE Id = :calls[0].ZTS_EU_Account__c];
            a.ZTS_EU_Market__c = 'United Kingdom';
            update a;
            
            Insert calls;
            //ZTS_US_Discussion_Item__c discItem = new ZTS_US_Discussion_Item__c();
            //   discItem.ZTS_EU_Start_Date__c=date.newInstance(2000, 9, 1);     
            //discItem.ZTS_EU_Description__c = 'Description Text';
            //discItem.ZTS_US_Discussion_Item_Title__c = 'Leadership Certificate Program (LCP) - Opportunity';
            //Insert discItem;
            Attendee__c attn = new Attendee__c();
            attn.ZTS_EU_call__c = calls[0].id;
            insert attn;
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
            disc.name = 'Leadership Certificate Program (LCP) - Opportunity';
            disc.ZTS_EU_Call_Attendee__c=attn.id;
            //disc.ZTS_EU_Discussion_Items__c=discItem.id;
            Insert disc;
            Test.stopTest();
        }
    }
}