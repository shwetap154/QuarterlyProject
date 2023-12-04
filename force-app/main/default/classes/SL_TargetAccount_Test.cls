@isTest
private class SL_TargetAccount_Test 
{
    @testSetup static void test_setUp() 
    { 
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'test';
        usr.zts_eu_market__c = 'India';
        insert usr;
        
        
        
        System.runAs(usr){
            List<Account> accs = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Account objAccount = accs[0];
            objAccount.Name='Test Account 1';
            insert objAccount;
            
            Campaign objCamp = new Campaign(Name = 'Test Camp', Status = 'Planned', ZTS_EU_Field_Targeting__c = 'Open', ZTS_EU_Market__c = 'India',
                                            Campaign_Name_English__c = 'English');
            insert objCamp;
            
            ZTS_EU_Campaign_Account__c objCampAccount = new ZTS_EU_Campaign_Account__c(ZTS_EU_Campaign__c = objCamp.Id, ZTS_EU_Account__c = objAccount.Id,
                                                                                       ZTS_EU_Member_Status__c = 'Added');
            insert objCampAccount;
        }
    }
    
    private static testMethod void test_SL_TargetAccount() 
    {
        Campaign objCamp = [Select Id, ZTS_EU_Field_Targeting__c From Campaign WHERE ZTS_EU_Market__c != 'United States' Limit 1];
        ZTS_EU_Campaign_Account__c objCampAccount = [Select Id,ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c, ZTS_EU_Account__c from ZTS_EU_Campaign_Account__c WHERE ZTS_EU_Market_From_Parent__c != 'United States' Limit 1];
        
        PageReference pageRef = Page.SL_RemoveAccount;      
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objCamp.Id);
        
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(new List<ZTS_EU_Campaign_Account__c>{objCampAccount});
        SL_TargetAccount objCntl = new SL_TargetAccount(setCon);
        system.assertEquals(objCntl.strStatus, 'Open');
        
    }
    
}