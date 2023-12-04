/**
* @ClassName    : SL_LinkContactToAccountController_Test 
* @JIRATicket   : LIGHTNI-1641
* @CreatedOn    : 25th September, 2019
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Handler for the vf page SL_LinkContactToAccount.
*/
@isTest
public with sharing class SL_LinkContactToAccountController_Test {
    
    @isTest
    public static void testHandler() {
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        Account objAcc = new Account();
        Contact objContact = new Contact();
        ApexPages.StandardSetController setCon;
        SL_LinkContactToAccountController objCntl;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            objAcc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAcc;
            
            objContact = new Contact(FirstName= 'Test', LastName='Contact ACA', AccountId=objAcc.Id, ZTS_EU_Market__c = 'United Kingdom');
            insert objContact;
            
            PageReference pageRef = Page.SL_LinkContactToAccount;      
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', objContact.Id);
            
            setCon = new ApexPages.StandardSetController(new List<ZTS_EU_Affiliations__c>());
            objCntl = new SL_LinkContactToAccountController(setCon);
            objCntl.backToView();
        }
        System.assertNotEquals(null, objCntl.ContactName);
    }
}