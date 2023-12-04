/**
* @ClassName    : SL_AccountNewButtonOverride 
* @JIRATicket   : LIGTHTNI-1084
* @CreatedOn    : 26 July, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Test class for controller 'SL_AccountNewButtonOverride' class.
*/
@isTest
public with sharing class SL_AccountNewButtonOverride_Test {
    
    @isTest
    public static void testHandler() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;        
		System.runAs(usr)
        {
            Map<String, Object> obj =  SL_AccountNewButtonOverride.getDefaultUserData('Account');
            System.assertNotEquals(null, obj);
        }
        
    }
}