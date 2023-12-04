/*************************************************************************************
* Name          :    DxPrimaryErrorLookupController
* Description   :    Controller for adding Asset/Primary Consumable/Error Code from diagnosticsPrimaryErrorSelection LWC component
* Author        :    Karim Abdelrazek
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
08/22/2022       Karim Abdelrazek         Created

**************************************************************************************/
@isTest
private class DxPrimaryErrorLookupControllerTest {
    @TestSetup
    static void makeData() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'FirstName';
        usr.LastName = 'Tester';
        usr.zts_eu_market__c = 'United States';
        insert usr;
    
        System.runAs(usr)
        {
            List<Account> accs = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            Account tempAcc = accs[0];
            tempAcc.Name = 'testacc202226';
            Account objAcc = (Account)SL_TestDataFactory.createSObject(tempAcc, true);
    
            List<Contact> conts = ZTS_DataUtilityTest.createContactRecord(1);
            Contact tempCon = conts[0];
            tempCon.LastName = 'Test case component con';
            tempCon.AccountId = objAcc.Id;
            SL_TestDataFactory.createSObject(tempCon, true);
    
            String strAccAdrss = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
    
            SL_TestDataFactory.createSObject
            (   new Address__c
                (   RecordTypeId = strAccAdrss
                ,   ZTS_EU_Account__c = objAcc.Id
                ,   Name = 'Test Adrs'
                ,   ZTS_EU_Country__c = 'Austria'
                ,   Zip_Postal_Code__c = '10001'
                ,   ZTS_EU_District__c = 'Test'
                ,   ZTS_US_Source_Account_Number__c = '10111'
                ,   ZTS_EU_Market_from_Parent__c = 'United Kingdom'
                )
            ,   true
            );

            Diagnostics_Error_Codes__c fuseErrCode = (Diagnostics_Error_Codes__c) SL_TestDataFactory.createSObject
            (   new Diagnostics_Error_Codes__c
                (   Name = 'FUSE'
                ,   Active__c = true
                ,   Product_Families__c ='Rapids'
                )
            ,   true
            );
            Diagnostics_Error_Codes__c errCode = (Diagnostics_Error_Codes__c) SL_TestDataFactory.createSObject
            (   new Diagnostics_Error_Codes__c
                (   Name = 'ERR-0000190'
                ,   Active__c = true
                ,   Product_Families__c = 'Chemistry'
                
                )
            ,   true
            );
            SAP_Material__c objSAPM = (SAP_Material__c) SL_TestDataFactory.createSObject
            (   new SAP_Material__c
                (   SAP_Item_Category_Group__c = 'NORM'
                ,   SAP_Product_Number__c = 'TestProductID132'
                )
            ,   true
            );
            // Product record creation for lot record
            Product2 objProd = (Product2) SL_TestDataFactory.createSObject
            (   new Product2
                (   Name = 'TestDXProduct'
                ,   IsActive = true
                ,   ProductCode = '123456'
                ,   Product_External_ID__c = '10023208'
                ,   Diagnostics_Product_Family__c = 'Rapids'
                ,   Chemistries__c = 'ALB;GLOB;NA+;MG'
                ,   SAP_Material__c = objSAPM.Id
                )
            ,   true
            );
            Product2 objProd_chemistry = (Product2) SL_TestDataFactory.createSObject
            (   new Product2
                (   Name = 'TestDX2Prod'
                ,   IsActive = true
                ,   ProductCode = '7382738271'
                ,   Product_External_ID__c = '109944408'
                ,   Diagnostics_Product_Family__c = 'Chemistry'
                )
            ,   true
            );
            insert new List<Asset>
            {   new Asset
                (   Name = 'Asset1'
                ,   AccountId = objAcc.Id
                ,   Product2Id = objProd.Id
                ),
                new Asset
                (   Name = 'Asset 2'
                ,   AccountId = objAcc.Id
                ,   Product2Id = objProd.Id
                )
            };
        }
    }

    @isTest
    static void testSaveCase(){

        Asset  newAsset = [SELECT Id FROM Asset LIMIT 1];
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Case testCase = ZTS_DataUtilityTest.createCases(1, diagRecordTypeId)[0];
        testCase.AssetId = newAsset.Id;
        insert testCase;

        Test.startTest();
            DxPrimaryErrorLookupController.saveCase(testCase.Id, newAsset.Id, null, null);
        Test.stopTest();

        Case result = [SELECT  AssetId FROM Case WHERE Id =: testCase.Id];
        System.assertEquals(newAsset.Id, result.AssetId, 'We expect the asset to be populated on the case');
    }


    @isTest
    static void searchPrimaryErrorCode(){
        
        Asset testAsset = [SELECT Id FROM Asset WHERE Product2.Diagnostics_Product_Family__c  = 'Rapids' LIMIT 1];
        Product2  testConsumable = [SELECT Id FROM Product2 WHERE Diagnostics_Product_Family__c = 'Chemistry' LIMIT 1];

        List<LookupSearchResult> searchResults;
        Test.startTest();
            searchResults = DxPrimaryErrorLookupController.searchPrimaryErrorCodes('all',testAsset.Id,testConsumable.Id);
        Test.stopTest();
        System.assertEquals(2, searchResults.size(), 'We expect two results to be returned, one error code for each of the diagnostic error codes');
    }


    @isTest
    static void searchPrimaryErrorCode_fuseProduct(){
        
        Asset testAsset = [SELECT Id FROM Asset WHERE Product2.Diagnostics_Product_Family__c  = 'Rapids' LIMIT 1];
        Product2  testConsumable = [SELECT Id FROM Product2 WHERE Diagnostics_Product_Family__c = 'Chemistry' LIMIT 1];

        List<LookupSearchResult> searchResults;
        Test.startTest();
            searchResults = DxPrimaryErrorLookupController.searchPrimaryErrorCodes('FUSE',testAsset.Id,testConsumable.Id);
        Test.stopTest();
        System.assertEquals(1, searchResults.size(), 'We expect one result to be returned');
    }

    @isTest
    static void searchPrimaryErrorCode_noResult(){
        
        Asset testAsset = [SELECT Id FROM Asset WHERE Product2.Diagnostics_Product_Family__c  = 'Rapids' LIMIT 1];

        List<LookupSearchResult> searchResults;
        Test.startTest();
            searchResults = DxPrimaryErrorLookupController.searchPrimaryErrorCodes('doesNotExist',testAsset.Id,null);
        Test.stopTest();
        System.assertEquals(0, searchResults.size(), 'We expect no results to be returned');
    }

    @isTest
    static void testFetchData(){
        String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
        Case testCase = ZTS_DataUtilityTest.createCases(1, diagRecordTypeId)[0];
        Asset  newAsset = [SELECT Id FROM Asset LIMIT 1];
        testCase.AssetId = newAsset.Id;
        insert testCase;

        DxPrimaryErrorLookupController.DataResult result;
        Test.startTest();
            result = DxPrimaryErrorLookupController.fetchData(testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'We expect a result to be returned');
        System.assertEquals(newAsset.id, result.assetId, '');
    }

    

}