@isTest
public with sharing class Account_Affiliations_InsrtDupRecord_Test {

    static final String ADMIN_USER_FIRSTNAME = 'intlUser';

    @TestSetup static void dataSetup() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = ADMIN_USER_FIRSTNAME;
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr) {

            List<Account> acPrimaryRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acPrimaryRecord;

            List<Account> acAffliatedRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert acAffliatedRecord;

            List<ZTS_EU_Account_Affiliations__c> insertAffiliationList = new List<ZTS_EU_Account_Affiliations__c>();
            ZTS_EU_Account_Affiliations__c affNew = new ZTS_EU_Account_Affiliations__c();
            affNew.ZTS_EU_Affiliated_Account__c = acPrimaryRecord.get(0).id;
            affNew.ZTS_EU_Account__c = acAffliatedRecord.get(0).id;
            affNew.ZTS_EU_Account_influence__c = 'Low';
            // affNew.ZTS_EU_Role__c = 'Influences';
            affNew.ZTS_EU_Affiliation_Type__c = 'Reverse';
            insertAffiliationList.add(affNew);
            insert insertAffiliationList;
            
            List<ZTS_EU_Account_Affiliations__c> deleteAffiliationList = new List<ZTS_EU_Account_Affiliations__c>();

        }
    }
    @isTest static void validate_ZTS_EU_Account_Affiliations_InsrtDupRecord_Update() {

        User testUser = [SELECT Id FROM User WHERE FirstName = :ADMIN_USER_FIRSTNAME];
        
        List<ZTS_EU_Account_Affiliations__c> testAffiliations = [SELECT id, ZTS_EU_Affiliated_Account__c, ZTS_EU_Role__c,
                                                                    ZTS_EU_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_After_Insert__c,
                                                                    ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_Hierarchy_Id__c, ZTS_EU_Account_influence__c,
                                                                    ZTS_EU_Account_Affiliation_Id__c, ZTS_EU_Account__c
                                                                FROM ZTS_EU_Account_Affiliations__c ];
        
        List<ZTS_EU_Account_Affiliations__c> updateAffiliationList = new List<ZTS_EU_Account_Affiliations__c>();
        ZTS_EU_Account_Affiliations__c testAffiliation =  testAffiliations[0];
        testAffiliation.ZTS_EU_Account_influence__c = 'Medium';
        testAffiliation.ZTS_EU_Affiliation_Status__c = 'Inactive';
        updateAffiliationList.add(testAffiliation);
        
        UtilityService.reverseUpdAffRun = true;
        UtilityService.AffUpdateRun = true;
        
        System.runAs(testUser) {
            Test.startTest(); 
                update updateAffiliationList;
            Test.stopTest();
        }

        List<ZTS_EU_Account_Affiliations__c> updatedAccountAff = [SELECT id, ZTS_EU_Affiliated_Account__c, ZTS_EU_Role__c,
                                                                    ZTS_EU_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_After_Insert__c,
                                                                    ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_Hierarchy_Id__c, ZTS_EU_Account_influence__c,
                                                                    ZTS_EU_Account_Affiliation_Id__c, ZTS_EU_Account__c
                                                                    FROM ZTS_EU_Account_Affiliations__c ];
        
        System.assertEquals(updatedAccountAff.get(0).ZTS_EU_Account_influence__c, 'Medium', 'The expected value of ZTS_EU_Account_influence__c is Medium');
        
    }

    @isTest static void validate_ZTS_EU_Account_Affiliations_InsrtDupRecord_Delete() {

        User testUser = [SELECT Id FROM User WHERE FirstName = :ADMIN_USER_FIRSTNAME];

        List<ZTS_EU_Account_Affiliations__c> testAffiliations = [SELECT id, ZTS_EU_Affiliated_Account__c, ZTS_EU_Role__c,
                                                                    ZTS_EU_Account__r.ZTS_EU_Parent_Id__c, ZTS_EU_After_Insert__c,
                                                                    ZTS_EU_Affiliation_Status__c, ZTS_EU_Account_Hierarchy_Id__c, ZTS_EU_Account_influence__c,
                                                                    ZTS_EU_Account_Affiliation_Id__c, ZTS_EU_Account__c
                                                                FROM ZTS_EU_Account_Affiliations__c ];

        System.runAs(testUser) {
            Test.startTest(); 
                delete testAffiliations;
            Test.stopTest();
        }
        
        Integer numAffiliations = [SELECT count() FROM ZTS_EU_Account_Affiliations__c];
        System.assertEquals(numAffiliations, 0, 'The expected ZTS_EU_Account_Affiliations__c size is 0');

    }

}