@isTest
private class SL_AddToCampaignOREvent_Test 
{
    private static testMethod void test_SL_AddToCampaignOREvent() 
    {
        Account objAccount = new Account(Name='Test Account 1', BillingPostalCode = '00000', BillingCity = 'testCity', BillingState = 'testState', BillingStreet = 'testStreet');
        insert objAccount;
        
        PageReference pageRef = Page.SL_AddToCampaign;      
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objAccount.Id);
        
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(new List<Account>{objAccount});
        setCon.setSelected(new List<Account>{objAccount});
        SL_AddToCampaignOREvent objCntl = new SL_AddToCampaignOREvent(setCon);
        //system.assertEquals(objCntl.lstAccount.size(), 1);
    }
}