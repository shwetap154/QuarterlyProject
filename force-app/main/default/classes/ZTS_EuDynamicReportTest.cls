/*******************************************************************************************************************************************
* File Name     :  ZTS_EuDynamicReportTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/16         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_EuDynamicReportTest 
{   
    static List<ZTS_EU_Report_Names__c> listReportNames;
    static List<Account> listAccount;
    static List<ZTS_EU_Business_Units__c> listBusinessUnits;
    static ZTS_EuDynamicReport dynamicReport = new ZTS_EuDynamicReport();
    
    static void createTestData(){
        listReportNames = createReportNames();
        insert listReportNames;
        listBusinessUnits = createBusinessUnits();
        insert listBusinessUnits;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        listAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert listAccount;
        }
        
    }
    
    static User createUserTerritoryToAssociation()
    {
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
         User u2 = new User(firstname= 'Test',
                              lastname='XXXX',
                              Alias='Test',
                              email = 'test1234122@test.com',
                              username= 'test1234xxx123@test.com', 
                              profileId= p.id, 
                              emailencodingkey='UTF-8',
                              languagelocalekey='en_US',
                              localesidkey='en_US',
                              timezonesidkey='America/Los_Angeles',
                              ZTS_EU_Market__c ='India');
        insert u2;   
        
        List<ETM_Required_Ids__mdt> mdtETMRequiredIds = [SELECT DeveloperName,ETM_Model_ID__c,ETM_Type_Id__c FROM ETM_Required_Ids__mdt Where DeveloperName = 'Default_Values' Limit 1];
        
        Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c, Name='TestTerritory', Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c);
        insert objTerr;

        Territory2 objTerrChild = new Territory2(DeveloperName = 'TestTerritoryChild', ParentTerritory2Id = objTerr.Id, Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c, Name='TestTerritoryChild', Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c);
        insert objTerrChild;

        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2='Sales / Marketing Manager');
        insert objUserTerritory2Association;
        
        return u2;
    }
    
  /*  static testMethod void constructorTest(){
        test.startTest();
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnits();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.businessUnit = 'CA';
        dynamicReport.getaddFilter();
        test.stopTest();
    }
    
    static testMethod void showReportTest(){
        test.startTest();
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnits();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.businessUnit = 'CA';
        dynamicReport.getaddFilter();
        dynamicReport.reportName = 'Monthly Brand Sales';
        dynamicReport.filterValue = 'CA';
        dynamicReport.showReport();
        dynamicReport.changeReportType();
        test.stopTest();
    }
    
    static testMethod void showReportBusinessUnitNullBrandSalesReportTest(){
        test.startTest();
        dynamicReport.businessUnitMS = null;
        dynamicReport.currencyOfSales = 'test$';
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.getaddFilter();
        dynamicReport.reportName = 'Monthly Brand Sales';
        dynamicReport.filterValue = 'CA';
        dynamicReport.showReport();
        dynamicReport.changeReportType();
        test.stopTest();
    }
    
    static testMethod void showReportBusinessUnitNullSegmentSalesReportTest(){
        test.startTest();
        dynamicReport.businessUnitMS = null;
        dynamicReport.currencyOfSales = 'test$';
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.getaddFilter();
        dynamicReport.reportName = 'Monthly Segment Sales';
        dynamicReport.filterValue = 'CA';
        dynamicReport.showReport();
        dynamicReport.changeReportType();
        test.stopTest();
    }
    
    static testMethod void showReportNameNullTest(){
        test.startTest();
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnits();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.businessUnit = 'CA';
        dynamicReport.getaddFilter();
        dynamicReport.reportName = null;
        dynamicReport.filterValue = 'CA';
        dynamicReport.showReport();
        dynamicReport.changeReportType();
        test.stopTest();
    }
    
    static testMethod void showReportActivityAnalysisTest(){
        test.startTest();
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnits();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.businessUnit = null;
        dynamicReport.getaddFilter();
        dynamicReport.reportName = 'Activity Analysis';
        dynamicReport.filterValue = 'CA';
        dynamicReport.showReport();
        dynamicReport.changeReportType();
        test.stopTest();
    }
    
    static testMethod void showReportTest1(){
        
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnits();
        dynamicReport.businessUnit = 'CA';
        dynamicReport.getaddFilter();
        //dynamicReport.reportName = 'Monthly Segment Sales';
        dynamicReport.filterValue = 'CA';
        dynamicReport.selectedProduct = 'TestProd';
        test.startTest();
        dynamicReport.showReport();
        test.stopTest();
    }*/
    
    static testMethod void showReportTest2()
    {
        system.runAs(createUserTerritoryToAssociation())
        {
            createTestData();
            dynamicReport.getReports();
            dynamicReport.getbusinessUnits();
            dynamicReport.businessUnit = 'EQ'   ;
            dynamicReport.getaddFilter();
            dynamicReport.reportName = 'Monthly Segment Sales';
            dynamicReport.filterValue = 'CA';
            test.startTest();
            dynamicReport.showReport();
            test.stopTest();   
        }
    }
    
    static testMethod void showReportTest3(){
        test.startTest();
        createTestData();
        dynamicReport.getReports();
        dynamicReport.getbusinessUnits();
        dynamicReport.getbusinessUnitsMS();
        dynamicReport.businessUnit = 'EQ'   ;
        dynamicReport.getaddFilter();
        dynamicReport.reportName = 'Annual Segment Sales';
        dynamicReport.filterValue = 'CA';
        dynamicReport.showReport();
        test.stopTest();
    }
    
    static testMethod void generateReportDataTest()
    {
        system.runAs(createUserTerritoryToAssociation())
        {
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'CA';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_CA__c = 'C1';
            update listAccount[0];
            dynamicReport.generateReportData('CA',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest2()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'CA';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_CA__c = 'C1';
            update listAccount[0];
            dynamicReport.filterValue = 'CA';
            dynamicReport.generateReportData('CA',false);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest3()
    {
        system.runAs(createUserTerritoryToAssociation())
        {
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'EQ';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_EQ__c = 'E1';
            update listAccount[0];
            dynamicReport.generateReportData('EQ',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest4()
    {
        system.runAs(createUserTerritoryToAssociation())
        {
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'PY';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_PY__c = 'PY1';
            update listAccount[0];
            dynamicReport.filterValue = 'PY';
            dynamicReport.generateReportData('PY',false);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest5()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'RU';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_RU__c = 'R1';
            update listAccount[0];
            dynamicReport.generateReportData('RU',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest6()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'SW';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_SW__c = 'S1';
            update listAccount[0];
            dynamicReport.filterValue = 'SW';
            dynamicReport.generateReportData('SW',false);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest7()
    {
        system.runAs(createUserTerritoryToAssociation())
        {
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'VPS';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_VPS__c = 'VPS1';
            update listAccount[0];
            dynamicReport.generateReportData('VPS',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest8()
    {
        system.runAs(createUserTerritoryToAssociation())
        {        
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'EQ';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_VPS__c = 'VPS1';
            update listAccount[0];
            dynamicReport.filterValue = 'SW,PY';
            test.stopTest();
            dynamicReport.generateReportData('VPS',false);
        }
    }
    
    static testMethod void generateReportDataTest9()
    {
        system.runAs(createUserTerritoryToAssociation())
        {
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'VPS';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_VPS__c = null;
            update listAccount[0];
            dynamicReport.generateReportData('VPS',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest10()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'CA';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_CA__c = null;
            update listAccount[0];
            dynamicReport.generateReportData('CA',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest11()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'EQ';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_EQ__c = null;
            update listAccount[0];
            dynamicReport.generateReportData('EQ',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest12()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'PY';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_VPS__c = 'PY1';
            update listAccount[0];
            dynamicReport.generateReportData('PY',true);
            test.stopTest();
        }
    }
    
    static testMethod void generateReportDataTest13()
    {
        system.runAs(createUserTerritoryToAssociation())
        {    
            createTestData();
            createDummyData();
            dynamicReport.businessUnit = 'SW';
            dynamicReport.selectedProduct = 'TestProd';
            test.startTest();
            dynamicReport.showProducts();
            listAccount[0].ZTS_EU_RAT_VPS__c = 'SW1';
            update listAccount[0];
            dynamicReport.generateReportData('SW',true);
            test.stopTest();
        }
    }
    
    static void createDummyData(){
        // Product of type Therapeutic Group creation specific to this class
        ZTS_EU_Species_Product__c prodSpeciesThera = new ZTS_EU_Species_Product__c();
        prodSpeciesThera.Name='Test Product Thera';
        prodSpeciesThera.ZTS_EU_Market__c='United Kingdom';
        prodSpeciesThera.ZTS_EU_Type__c='Brand';
        prodSpeciesThera.CurrencyIsoCode = 'EUR';
        prodSpeciesThera.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpeciesThera.ZTS_EU_Is_Active__c=true;
        insert prodSpeciesThera;
        
        // Sales record creation with product of type Therapeutic group
        ZTS_EU_Sales__c salesThera = new ZTS_EU_Sales__c();
        salesThera.ZTS_EU_Date__c = system.today();
        salesThera.ZTS_EU_Product__c  = prodSpeciesThera.Id;
        salesThera.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesThera.ZTS_EU_Account__c = listAccount[0].Id;
        insert salesThera;
        
        Set<Id> setTerritoryID = ZOE_FindTerritoryByUserId.findTerritoriesForUserId(UserInfo.getUserId(), true);
        List<Group> grp = [select Id, Type from Group where Type='Territory' and RelatedId IN : setTerritoryID];
        if(grp != null && grp.size() >0){
            /*AccountShare accShare = new AccountShare(UserOrGroupId=grp[0].Id,AccountId=listAccount[0].Id);
            insert accShare;*/

            ObjectTerritory2Association obj = new ObjectTerritory2Association(ObjectId = listAccount[0].Id, Territory2Id = (new List<id>(setTerritoryID))[0], AssociationCause='Territory2Manual' );
            insert obj;
        }
        ZTS_EU_Species_Product__c spProd1 = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Business Unit',Name='TestBU');
        insert spProd1;
        ZTS_EU_Species_Product__c spProd = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Brand',Name='Test');
        insert spProd;
        ZTS_EU_Species__c species = new ZTS_EU_Species__c(ZTS_EU_Business_Unit__c=spProd1.Id,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Species__c='CA');
        insert species;
        ZTS_EU_Potential_Brands__c potBrand = new ZTS_EU_Potential_Brands__c(Brand__c=spProd.Id, Potential__c=species.Id);
        insert potBrand;
    }
    
     /*-------------insert ZTS_Events__c objects---------------*/
    public static List<ZTS_EU_Report_Names__c> createReportNames(){ // 6/14
        List<ZTS_EU_Report_Names__c> listReports = new List<ZTS_EU_Report_Names__c>();
        ZTS_EU_Report_Names__c report = new ZTS_EU_Report_Names__c(Report_Name__c = 'Account Sales by Brand',Name='Account Sales by Brand');
        listReports.add(report);
        report = new ZTS_EU_Report_Names__c(Report_Name__c = 'Monthly Brand Sales',Name='Monthly Brand Sales');
        listReports.add(report);
        report = new ZTS_EU_Report_Names__c(Report_Name__c = 'Monthly Segment Sales',Name='Monthly Segment Sales');
        listReports.add(report);        
        return listReports;
    }
    
    public static List<ZTS_EU_Business_Units__c> createBusinessUnits(){
        List<ZTS_EU_Business_Units__c> listBusiness = new List<ZTS_EU_Business_Units__c>();
        ZTS_EU_Business_Units__c business = new ZTS_EU_Business_Units__c(Name='CA', Ratings__c='C1,C2,C3,C4,All');
        listBusiness.add(business);
        business = new ZTS_EU_Business_Units__c(Name='EQ', Ratings__c='EQ1,EQ2,EQ3,EQ4,All');
        listBusiness.add(business);
        business = new ZTS_EU_Business_Units__c(Name='PY', Ratings__c='P1,P2,P3,All');
        listBusiness.add(business);
        business = new ZTS_EU_Business_Units__c(Name='RU', Ratings__c='R1,R2,All');
        listBusiness.add(business);
        business = new ZTS_EU_Business_Units__c(Name='SW', Ratings__c='SW1,SW2,s3,All');
        listBusiness.add(business);
        business = new ZTS_EU_Business_Units__c(Name='VPS', Ratings__c='v1,v2,P3,All');
        listBusiness.add(business);
        return listBusiness;
    }
}