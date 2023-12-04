@isTest
private class SL_CompleteCoaching_Test 
{
	private static testMethod void test_SL_CompleteCoaching() 
	{
	    ZTS_EU_Coaching__c objCoaching = new ZTS_EU_Coaching__c(ZTS_EU_Status__c = 'Submitted');
	    insert objCoaching;
	    
        SL_CompleteCoaching.updateCoaching(objCoaching.Id);
        
        system.assertEquals([Select ZTS_EU_Status__c From ZTS_EU_Coaching__c Limit 1].ZTS_EU_Status__c,'Planned');
	}
    
    @isTest
    static void testDeleteCoaching() {
        
        ZTS_EU_Coaching__c objCoaching = new ZTS_EU_Coaching__c(ZTS_EU_Status__c = 'Submitted');
	    insert objCoaching;
        
        Test.startTest();
        	delete objCoaching;
        Test.stopTest();
        
        List<ZTS_EU_Coaching__c> actualCoaching = [SELECT Id FROM ZTS_EU_Coaching__c WHERE Id = :objCoaching.Id];
        System.assert(actualCoaching.isEmpty(),'No coaching record should exist');
    }

}