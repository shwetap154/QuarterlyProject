/**
 * @description       : Test class for SL_DeepCloneAccountController
 * @author            : Premraj K K @ Silverline
 * @group             : 
 * @last modified on  : 07-25-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-15-2019   Premraj K K @ Silverline    Initial Version
 * 1.1   07-25-2022   Ethan Hirsch @ Zoetis Inc   Update Address assertions in testReparenting to account for 3 
 *                                                Addresses being created.
**/
@isTest
public class SL_DeepCloneAccountControllerTest {
	
    @testSetup 
    static void test_SetUp() { 

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {

            
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
                                            ZTS_EU_Species_Specialty__c='Cattle', Select_Consent_for_eSign__c ='Privacy', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'United Kingdom');
            insert objContact;
            
            //List<ZTS_EU_Affiliations__c> objAffiliations = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
//objAffiliations[0].ZTS_EU_Account__c = objAccount.Id;
           // objAffiliations[0].ZTS_EU_Contact__c = objContact.Id;

            //insert objAffiliations;
			
            List<ZTS_EU_Species_Product__c> buList = ZTS_EU_DataUtilityTest1.createProductBURecord(1);
            buList[0].ZTS_EU_Market__c = 'United Kingdom';
            insert buList;
            
            List<ZTS_EU_Species__c> speciesList = ZTS_EU_DataUtilityTest1.createSpeciesRecord(1);
            speciesList[0].ZTS_EU_Market__c = 'United Kingdom';
            speciesList[0].ZTS_EU_Business_Unit__c = buList[0].Id;
            insert speciesList;
            
            
            ZTS_EU_Account_Species_Potential__c speciesPotential = new ZTS_EU_Account_Species_Potential__c();
            speciesPotential.Account__c = objAccount.Id;
            speciesPotential.ZTS_EU_Species_Potential__c = speciesList[0].Id;
            insert speciesPotential;
            
            List<Address__c> addr = ZTS_EU_DataUtilityTest.createAddressRecord(1);
            addr[0].ZTS_EU_Account__c = objAccount.Id;
            insert addr;
            
            ZTS_EU_Territory__c t = new ZTS_EU_Territory__c();
            t.ZTS_EU_Market__c = 'Italy';
            insert t;

            ZTS_EU_Position__c position = new ZTS_EU_Position__c();
            position.ZTS_EU_Territory__c = t.Id;
            insert position;
            
            ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = objAccount.Id, 
                                                                            ZTS_EU_Position__c = position.Id);
            insert accPos;

            ZTS_EU_Bring_Offline__c objBO = new ZTS_EU_Bring_Offline__c(ZTS_EU_Account__c = objAccount.Id);
            insert objBO;
        }
        
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Profile p = [SELECT Id,Name 
                     FROM Profile 
                     WHERE Name Like '%Business Admin%'
                     Limit 1];
        system.debug('---->'+p.Name);
        User objUser = new User(firstname = 'TestUser',
                                lastName = 'User56',
                                email = uniqueName + '@test' + orgId + '.org',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = p.Id,
                                ZTS_EU_Market__c = 'Mexico',
                                IsActive = true);
        insert objUser;
    }
    
    @isTest
    private static void Test_DeepCloneAccountAndRelatedRecords() {

        List<Account> lstAccounts = [Select Id, Name
                                     From Account
                                     Limit 1];
                                     SYstem.debug('$$$ lstAccounts: '+lstAccounts);
        
        User testUser = [SELECT Id FROM User WHERE FirstName='IntUser'][0];
        Test.startTest();
            System.runAs(testUser) {
                SL_DeepCloneAccountController.deepCloneAccountAndRelatedRecords(lstAccounts[0].Id);
            }

        Test.stopTest();
        String expectedName = lstAccounts[0].Name + ' - CLONED';
        System.assertEquals(1, [SELECT Id FROM Account WHERE Name = :expectedName AND ZTS_EU_Market__c != 'United States'].size());
	}
    
    @isTest
    private static void testReparenting() {

        List<Account> lstAccounts = [Select Id, Name
                                     From Account
                                     Limit 1];
        Account newAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
                                      
        
       
        User testUser = [SELECT Id FROM User WHERE FirstName='IntUser'][0];
        
            System.runAs(testUser) 
            {
                Test.startTest();
                insert newAccount;      
                SL_DeepCloneAccountController.reparentContacts(lstAccounts[0].Id, newAccount.Id);
                SL_DeepCloneAccountController.cloneAndReparentAccntContAffilliations(lstAccounts[0].Id, newAccount.Id);
                SL_DeepCloneAccountController.cloneAndReparentAccntSpeciesPotential(lstAccounts[0].Id, newAccount.Id);
                SL_DeepCloneAccountController.cloneAndReparentAddress(lstAccounts[0].Id, newAccount.Id);
                SL_DeepCloneAccountController.cloneAndReparentAccountPosition(lstAccounts[0].Id, newAccount.Id);
                Test.stopTest();

            }

        System.assertEquals(1, [SELECT AccountId FROM Contact WHERE AccountId = :newAccount.Id ].size());
        System.assertEquals(1, [SELECT ZTS_EU_Account__c FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Account__c = :newAccount.Id ].size());
        System.assertEquals(1, [SELECT Account__c FROM ZTS_EU_Account_Species_Potential__c WHERE Account__c = :newAccount.Id ].size());
        // 3 Addresses are created for the cloned Account. 1 based on the Primary Address fields and 2 from the original Account.
        // The original Account has 2 Addresses. One manual and one created from the Primary Address
        System.assertEquals(3, [SELECT ZTS_EU_Account__c FROM Address__c WHERE ZTS_EU_Account__c = :newAccount.Id ].size());
        System.assertEquals(1, [SELECT ZTS_EU_Account__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c = :newAccount.Id ].size());

	}
}