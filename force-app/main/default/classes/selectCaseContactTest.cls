@isTest
public class selectCaseContactTest {
    // @testSetup static void setupmethod() {
      /*   Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Master Data Inquiry',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = 'test11@reflabs.com',
                               // LIS_Org_Code__c = ACCOUNT1_ORG_CODE,
                                // Set Market to Canada as otherwise it will be set to the Market of Account 1.
                                // This will prevent the test User from beign able to edit the Case.
                                ZTS_EU_Market__c = 'Canada'
                               );*/
        
    // }
	@isTest
    private static void getCaseDetailsTest(){
         Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Master Data Inquiry',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = 'test11@reflabs.com',
                               // LIS_Org_Code__c = ACCOUNT1_ORG_CODE,
                                // Set Market to Canada as otherwise it will be set to the Market of Account 1.
                                // This will prevent the test User from beign able to edit the Case.
                                ZTS_EU_Market__c = 'Canada'
                               );
        insert newCase;
        Test.startTest();
        selectCaseContact.getCaseDetail(newCase.Id);
        selectCaseContact.getContactsByCaseId(newCase.Id);
        Test.stopTest();
    }
    /*@isTest
    private static void getContactsByCaseIdTest(){
         Case newCase = new Case(Status = 'New',
                                Origin = 'RefLabs Portal',
                                Type = 'Master Data Inquiry',
                                Subject = 'RefLabs Portal Case test',
                                Description = 'Portal Case',
                                SuppliedEmail = 'test11@reflabs.com',
                               // LIS_Org_Code__c = ACCOUNT1_ORG_CODE,
                                // Set Market to Canada as otherwise it will be set to the Market of Account 1.
                                // This will prevent the test User from beign able to edit the Case.
                                ZTS_EU_Market__c = 'Canada'
                               );
        insert newCase;
        Test.startTest();
        selectCaseContact.getContactsByCaseId(newCase.Id);
        Test.stopTest();
    }*/
}