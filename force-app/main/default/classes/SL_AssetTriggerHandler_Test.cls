@isTest
public without sharing class SL_AssetTriggerHandler_Test 
{

    @isTest 
    public static void updateAssetProductBulkTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account account = (Account)SL_TestDataFactory.createSObject(new Account(Name = 'Test Account',
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Country__c=''), true);
            
            Address__c address = (Address__c)SL_TestDataFactory.createSObject(new Address__c(Name='Test Address',
                                                                                            Zip_Postal_Code__c='12345',
                                                                                            ZTS_EU_Country__c='France',
                                                                                            ZTS_EU_Account__c=account.Id), true); 

            
            SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c( SAP_Item_Category_Group__c = 'NORM', 
                                                                                            SAP_Product_Number__c = 'TestProductID1324'), true);
            
            Product2 objProd = (Product2)SL_TestDataFactory.createSObject(new Product2(Name = 'Test Product 1', SAP_Material__c = objSAPM.Id), true);
            
            List<Asset> assetList = new List<Asset>();
            for(Integer i=0; i<200; i++) 
            {
                assetList.add(new Asset(Name='Test Asset ' + i,
                                        Address_Lookup__c=address.Id,
                                        Material_Number__c = 'TestProductID1324'));
            }
            insert assetList;
            
            assetList[0].Material_Number__c = null;
            update assetList[0];

            List<Asset> assetListDB = [SELECT Id, AccountId FROM Asset];
            
            System.assertEquals(200, [SELECT Id, AccountId FROM Asset].size());
        }
    }
    
    static TestMethod void checkEditDeleteAccess(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        Profile profiles=[Select Id From Profile Where Name='BNLX Business Administrator'];
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='testuser@bnlx.com';
        newuser.username='testuser@bnlx.com';
        newuser.lastname='test';
        newuser.alias='tbnlx001';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';  
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        insert newuser;
        
        System.runAs(usr)
        {
            Account account = (Account)SL_TestDataFactory.createSObject(new Account(Name = 'Test Account',
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Country__c='',
                                                                                    ZTS_EU_SAP_Customer_ID__c = '123456'), true);
            
            Address__c address = (Address__c)SL_TestDataFactory.createSObject(new Address__c(Name='Test Address',
                                                                                            Zip_Postal_Code__c='12345',
                                                                                            ZTS_EU_Country__c='France',
                                                                                            ZTS_EU_Account__c=account.Id,
                                                                                            ZTS_US_Source_Account_Number__c = '123456'), true); 

            
            SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c( SAP_Item_Category_Group__c = 'NORM', 
                                                                                            SAP_Product_Number__c = 'TestProductID1324'), true);
            
            Product2 objProd = (Product2)SL_TestDataFactory.createSObject(new Product2(Name = 'Test Product 1', SAP_Material__c = objSAPM.Id), true);
            
            String competitorRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Competitor_Asset').getRecordTypeId();
            
            Asset ast1 = new Asset();
            ast1.Name='Test Asset 1';
            ast1.Address_Lookup__c=address.Id;
            ast1.Material_Number__c = 'TestProductID1324';
            ast1.Ship_to_Number__c = '123456';
            ast1.RecordTypeId = competitorRecordTypeId;
            insert ast1;
        }
        
        System.runAs(newuser){
            Test.startTest();
            
            List<Asset> assets = [Select Id,RecordTypeId,AccountId,OwnerId From Asset Where Name = 'Test Asset 1'];
             
            SL_AssetTriggerHandler handler = new SL_AssetTriggerHandler();
            handler.checkEditDeletePermission(assets);
            handler.updateZoetisFlagonDelete(assets);
            Test.stopTest();
        }
    }
    
@isTest 
    public static void addAssettoAccountTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account account = (Account)SL_TestDataFactory.createSObject(new Account(Name = 'Test Account',
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Country__c='',ZTS_EU_SAP_Customer_ID__c = '123456'), true);
            
            Address__c address = (Address__c)SL_TestDataFactory.createSObject(new Address__c(Name='Test Address',
                                                                                            Zip_Postal_Code__c='12345',
                                                                                            ZTS_EU_Country__c='France',
                                                                                            ZTS_EU_Account__c=account.Id), true); 

            List<Asset> assetList = new List<Asset>();
            for(Integer i=0; i<2; i++) 
            {
                assetList.add(new Asset(Name='Test Asset ' + i,
                                        Ship_to_Number__c = '123456'));
            }
            insert assetList;
           
            List<Asset> assetList1 = [SELECT Id, AccountId FROM Asset where AccountId!=null];
            System.assertEquals(2, assetList1.size());
            
            assetList1[0].Ship_to_Number__c=null;
            update assetList1;
            
            List<Asset> assetList2 = [SELECT Id, AccountId FROM Asset where AccountId=null];
            System.assertEquals(1, assetList2.size());
        }
    }

@isTest
public static void addAssettoAddressTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account account = (Account)SL_TestDataFactory.createSObject(new Account(Name = 'Test Account',
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Country__c=''), true);
            
            Address__c address = (Address__c)SL_TestDataFactory.createSObject(new Address__c(Name='Test Address',
                                                                                            Zip_Postal_Code__c='12345',
                                                                                            ZTS_EU_Country__c='France',
                                                                                            ZTS_EU_Account__c=account.Id,ZTS_US_Source_Account_Number__c = '1234568'), true); 

            List<Asset> assetList = new List<Asset>();
            for(Integer i=0; i<2; i++) 
            {
                assetList.add(new Asset(Name='Test Asset ' + i,
                                        Ship_to_Number__c = '1234568'));
            }
            insert assetList;
            List<Asset> assetList1 = [SELECT Id, Address_Lookup__c FROM Asset where Address_Lookup__c!=null];
            System.assertEquals(2, assetList1.size());
            
            assetList1[0].Ship_to_Number__c=null;
            update assetList1;
            
            List<Asset> assetList2 = [SELECT Id, Address_Lookup__c FROM Asset where Address_Lookup__c=null];
            System.assertEquals(1, assetList2.size());
        }
    }
    
    @isTest
	public static void addZoetisAssetTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('SAP Integration User', false);
        usr.FirstName = 'davidsUserSAP';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account account = (Account)SL_TestDataFactory.createSObject(new Account(Name = 'Test Account',
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Country__c=''), true);
            
            Account account1 = (Account)SL_TestDataFactory.createSObject(new Account(Name = 'Test Account1',
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Country__c=''), true);
            
            
            Address__c address = (Address__c)SL_TestDataFactory.createSObject(new Address__c(Name='Test Address',
                                                                                            Zip_Postal_Code__c='12345',
                                                                                            ZTS_EU_Country__c='France',
                                                                                            ZTS_EU_Account__c=account.Id,ZTS_US_Source_Account_Number__c = '1234568'), true); 

            Address__c address1 = (Address__c)SL_TestDataFactory.createSObject(new Address__c(Name='Test Address',
                                                                                            Zip_Postal_Code__c='12345',
                                                                                            ZTS_EU_Country__c='France',
                                                                                            ZTS_EU_Account__c=account.Id,ZTS_US_Source_Account_Number__c = '98765432'), true); 

            
            List<Asset> assetList = new List<Asset>();
            for(Integer i=0; i<2; i++) 
            {
                assetList.add(new Asset(Name='Test Asset ' + i,
                                        Ship_to_Number__c = '1234568'));
            }
            insert assetList;
            List<Asset> assetList1 = [SELECT Id, Ship_to_Number__c,Address_Lookup__c,recordtype.developerName FROM Asset];
            System.assertEquals(2, assetList1.size());
            System.assertNotEquals('Competitor_Asset', assetList1[0].recordtype.developerName);
            
            assetList1[0].Ship_to_Number__c='98765432';
            update assetList1;
            System.assertEquals('98765432', assetList1[0].Ship_to_Number__c);
            
            delete assetList1[1];
            
            List<Asset> assetList2 = [SELECT Id, AccountId FROM Asset where Ship_to_Number__c='98765432'];
            System.assertEquals(1, assetList2.size());
        }
    }
}