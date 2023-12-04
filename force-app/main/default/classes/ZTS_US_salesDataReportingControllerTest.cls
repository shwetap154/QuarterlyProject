/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/*******************************************************************************************************************************************
* File Name     :  ZTS_US_salesDataReportingControllerTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest
public class ZTS_US_salesDataReportingControllerTest
{

    Public static List<Account> accList = new List<Account>();
    Public static List<Account> accList2 = new List<Account>();

    public static void createTestData(){
        ZTS_US_Sales_Date__c salesdateCustSett = new ZTS_US_Sales_Date__c();
        salesdateCustSett.Name = 'SalesDate1';
        salesdateCustSett.ZTS_US_01__c = 'MAY';
        salesdateCustSett.ZTS_US_02__c = 'APR';
        salesdateCustSett.ZTS_US_03__c = 'MAR';
        salesdateCustSett.ZTS_US_04__c = 'FEB';
        salesdateCustSett.ZTS_US_05__c = 'JAN';
        salesdateCustSett.ZTS_US_06__c = 'DEC';
        salesdateCustSett.ZTS_US_07__c = 'NOV';
        salesdateCustSett.ZTS_US_08__c = 'OCT';
        salesdateCustSett.ZTS_US_09__c = 'SEP';
        salesdateCustSett.ZTS_US_10__c = 'AUG';
        salesdateCustSett.ZTS_US_11__c = 'JUL';
        salesdateCustSett.ZTS_US_12__c = 'JUN';
        salesdateCustSett.ZTS_US_Date__c = date.parse('5/9/2014');
        insert salesdateCustSett;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        accList =  ZTS_DataUtilityTest.createAccountRecord(2);
        accList[0].ZTS_EU_Market__c = 'United States';      
		System.runAs(usr)
        {
            insert accList;
        }
        
        accList2 =  ZTS_DataUtilityTest.createAccountRecord(2,1357);
        accList2[0].ParentId = accList[0].Id;
        for (Account acc : accList2) acc.ZTS_EU_Market__c = 'United States';
        insert accList2;
       
        // Sales Preset creation    
        ZTS_DataUtilityTest.createSalesPreset('Test Preset', 'MAT');
        ZTS_DataUtilityTest.createSalesPreset('Test Preset1', 'YTD');
        
        // Product of type Product Line creation specific to this class
        ZTS_EU_Species_Product__c prodLine = new ZTS_EU_Species_Product__c();
        prodLine.Name='Test Product Line';
        prodLine.ZTS_Hierarchy_Level__c='Therapeutic Group';
        prodLine.ZTS_Species__c='Test Species';
        prodLine.ZTS_EU_Is_Active__c=true;
        prodLine.ZTS_EU_Market__c = 'United States';
        prodLine.ZTS_EU_Type__c = 'Therapeutic Group';
        insert prodLine;
        
        ZTS_EU_Species_Product__c prodLine2 = new ZTS_EU_Species_Product__c();
        prodLine2.Name='Test Product Line1';
        prodLine2.ZTS_Hierarchy_Level__c='Disease Condition';
        prodLine2.ZTS_Species__c='Test Species';
        prodLine2.ZTS_EU_Is_Active__c=true;
        prodLine2.ZTS_EU_Parent_Species_Product__c = prodLine.id;
        prodLine2.ZTS_EU_Market__c = 'United States';
        prodLine2.ZTS_EU_Type__c = 'Brand';
        insert prodLine2;
        
        ZTS_EU_Species_Product__c prodLine3 = new ZTS_EU_Species_Product__c();
        prodLine3.Name='Test Product Line2';
        prodLine3.ZTS_Hierarchy_Level__c='Brand';
        prodLine3.ZTS_Species__c='Test Species';
        prodLine3.ZTS_EU_Is_Active__c=true;
        prodLine3.ZTS_EU_Parent_Species_Product__c = prodLine2.id;
        prodLine3.ZTS_EU_Market__c = 'United States';
        prodLine3.ZTS_EU_Type__c = 'MPG';
        insert prodLine3;
        
        ZTS_EU_Species_Product__c prodLine4 = new ZTS_EU_Species_Product__c();
        prodLine4.Name='Test Product Line3';
        prodLine4.ZTS_Hierarchy_Level__c='Product Line';
        prodLine4.ZTS_Species__c='Test Species';
        prodLine4.ZTS_EU_Is_Active__c=true;
        prodLine4.ZTS_EU_Parent_Species_Product__c = prodLine3.id;
        prodLine4.ZTS_EU_Market__c = 'United States';
        prodLine4.ZTS_EU_Type__c = 'SKU';
        insert prodLine4;
        
        
        ZTS_EU_Species_Product__c prodLine5 = new ZTS_EU_Species_Product__c();
        prodLine5.Name='Test Product Line4';
        prodLine5.ZTS_Hierarchy_Level__c='Item';
        prodLine5.ZTS_Species__c='Test Species';
        prodLine5.ZTS_EU_Is_Active__c=true;
        prodLine5.ZTS_EU_Parent_Species_Product__c = prodLine3.id;
        prodLine5.ZTS_EU_Market__c = 'United States';
        prodLine5.ZTS_EU_Type__c = 'SKU';
        insert prodLine5;
        
        // Sales record creation with product of type Product Line
        ZTS_EU_Sales__c salesProdLine = new ZTS_EU_Sales__c();
        salesProdLine.ZTS_EU_Account__c = accList[0].id;
        salesProdLine.ZTS_EU_Product__c  = prodLine4.Id;
        salesProdLine.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesProdLine.ZTS_US_Product_Level__c = 'Product';
        salesProdLine.ZTS_EU_Date__c = system.today();
        salesProdLine.ZTS_EU_Aggregated__c = true;
        insert salesProdLine;
        
        // Sales record creation with product of type Product Line
        ZTS_EU_Sales__c salesProdLine2 = new ZTS_EU_Sales__c();
        salesProdLine2.ZTS_EU_Account__c = accList[0].id;
        salesProdLine2.ZTS_EU_Product__c  = prodLine4.Id;
        salesProdLine2.ZTS_US_Product_Level__c = 'Product';
        salesProdLine2.ZTS_EU_GLR_Type__c = 'Ship-To';  
        salesProdLine2.ZTS_EU_Date__c = system.today();
        salesProdLine2.ZTS_EU_Aggregated__c = false;
        insert salesProdLine2;
                      
        
        // Sales record creation with product of type Item
        ZTS_EU_Sales__c salesItem = new ZTS_EU_Sales__c();
        salesItem.ZTS_EU_Account__c = accList[0].id;
        salesItem.ZTS_EU_Product__c  = prodLine5.Id;
        salesItem.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesItem.ZTS_US_Product_Level__c = 'Item';
        salesItem.ZTS_EU_Date__c = system.today();
        insert salesItem;
        
                
        // Sales record creation with product of type Account
        ZTS_EU_Sales__c salesAccount = new ZTS_EU_Sales__c();
        salesAccount.ZTS_EU_Account__c = accList[0].id;
        salesAccount.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesAccount.ZTS_US_Product_Level__c = 'Account';
        salesAccount.ZTS_EU_Date__c = system.today();
        salesAccount.ZTS_EU_Aggregated__c = false;  
        insert salesAccount;
        
        // Sales record creation with product of type Account
        ZTS_EU_Sales__c salesAccount2 = new ZTS_EU_Sales__c();
        salesAccount2.ZTS_EU_Account__c = accList[0].id;       
        salesAccount2.ZTS_EU_GLR_Type__c = 'Ship-To';
        salesAccount2.ZTS_US_Product_Level__c = 'Account';
        salesAccount2.ZTS_EU_Date__c = system.today();
        salesAccount2.ZTS_EU_Aggregated__c = true;
        insert salesAccount2;     
        
        MarketGeoMapping__c marketGeoMapping = new MarketGeoMapping__c(name = 'United States',Product_Potential_Level__c = 'SKU');
        insert marketGeoMapping;
    
    }
    static testmethod void testZTS_US_salesDataReportingCont(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        
        Test.startTest();            
        salesDataCont.createQueryStr();
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.selectedPreset = 'Test Preset';
        //salesDataCont.selectedLevelValue = 'CHILD';
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.selectedBillToShipTo = 'Bill-To';
        salesDataCont.noChild = false;
        salesDataCont.noParent = false;
        salesDataCont.aggCheck = false;
        salesDataCont.toggleFlagParent = false;
        salesDataCont.displayErrPopup = false;
        salesDataCont.disableL1 = true;
        salesDataCont.disableL2 = true;
        salesDataCont.multiSelectedValueQuery();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getTherapeuticGrp();      
        salesDataCont.getSalesDataProd();       
        salesDataCont.getSalesSpecies();
        salesDataCont.getradioOptions1();
        salesDataCont.getradioOptions2();
        salesDataCont.getradioOptions3();
        salesDataCont.generateUnitSalesPdf();
        salesDataCont.DownloadUnitSalesExcel();
        salesDataCont.generateProductSalesPdf();
        salesDataCont.DownloadProductSalesExcel();
        salesDataCont.generateTotalSalesPdf();
        salesDataCont.DownloadTotalSalesExcel();        
        salesDataCont.salesPreference();
        salesDataCont.savePreferences();
        salesDataCont.closePopup();     
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected  = true;
        salesDataCont.accntChild = accList2[0];
        salesDataCont.queryAccData();
        salesDataCont.refreshTable();
        salesDataCont.selectedPreset = '--None--';
        salesDataCont.refreshTable();
        salesDataCont.isChildSelected  = false;            
        salesDataCont.queryAccData();
        //salesDataCont.ViewSortData();     
        Test.stopTest();

        List<ZTS_EU_Species_Product__c> speciesPRoductList = [SELECT Id FROM ZTS_EU_Species_Product__c];
        ZTS_EU_Product_Gift_Limit__c giftLimit = new ZTS_EU_Product_Gift_Limit__c();
        giftLimit.ZTS_EU_Product__c = speciesPRoductList[0].Id;
    	insert giftLimit;

        String exceptionMessage = '';
        try{
            delete speciesPRoductList[0];
        }catch(DmlException ex){
            exceptionMessage = ex.getMessage();
        }

        System.assertNotEquals('', exceptionMessage, 'The delete shall fail');
        

    }
    
    static testmethod void testZTS_US_salesDataReportingCont1(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);       
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        
        Test.startTest();       
        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.createQueryStr();
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.createQueryStr();
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.createQueryStr();
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.dataNoMonth();
        salesDataCont.selectedValueQuery();     
        salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.selectedPreset = 'Test Preset';
        salesDataCont.selectedReport = 'UnitSales'; 
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.multiSelectedValueQuery();        
        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.salesPresetAction  = 'New';       
        salesDataCont.salesPreference();
        salesDataCont.multiSelectedValueQuery();
        salesDataCont.savePreferences();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getTherapeuticGrp();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProd();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getSalesSpecies();
        salesDataCont.getSalesSpeciesList();
        salesDataCont.getradioOptions1();
        salesDataCont.getradioOptions2();
        salesDataCont.getradioOptions3();
        salesDataCont.salesPreference();
        salesDataCont.salesPresetAction  = 'Edit';
        salesDataCont.selectedPreset   = 'Test Preset';
        salesDataCont.salesPreference();
        salesDataCont.multiSelectedValueQuery();
        salesDataCont.savePreferences();
        salesDataCont.closePopup();     
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.queryAccData();
        salesDataCont.refreshTable();
        //salesDataCont.ViewSortData();     
        Test.stopTest();
    }

     
    static testmethod void testZTS_US_salesDataReportingCont2(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
                
        Test.startTest();
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;          
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = true;                      
        salesDataCont.selectedValueQuery();           
        salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.selectedPreset = 'Test Preset1';
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        List<String> lstStr2 = new List<String>{'test1', 'test2'};
        salesDataCont.multiSelectPopulate(lstStr2);
        salesDataCont.multiSelectedValueQuery();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getTherapeuticGrp();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProd();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getSalesSpecies();
        salesDataCont.getSalesSpeciesList();       
        salesDataCont.getradioOptions1();
        salesDataCont.getradioOptions2();               
        salesDataCont.salesPresetAction = 'Delete';
        salesDataCont.savePreferences();
        salesDataCont.closePopup();     
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();   
        Test.stopTest();
    }
    
   static testmethod void testZTS_US_salesDataReportingCont3(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;          
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = true;
        Test.startTest();
        salesDataCont.selectedValueQuery();
        salesDataCont.selectedPreset = '--None--';
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.queryAccData();
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();           
        Test.stopTest();
    }
    
    static testmethod void testZTS_US_salesDataReportingCont4(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);      
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;
        //salesDataCont.selectedLevelValue = 'CHILD';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = true;      
        
        Test.startTest();          
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.selectedMATYTD = 'MAT';        
        salesDataCont.selectedValueQuery();     
        salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.selectedPreset = 'Test Preset';
        salesDataCont.salesPresetAction = 'New';
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.queryAccData(); 
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();       
        Test.stopTest();
    }
    
    static testmethod void testZTS_US_salesDataReportingCont5(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;          
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = true;
        
        Test.startTest();
        salesDataCont.selectedValueQuery();
        salesDataCont.selectedPreset = '--None--';
        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();            
        Test.stopTest();    
    }
    
    
     static testmethod void testZTS_US_salesDataReportingCont6(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);      
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        
        Test.startTest();
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;          
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = true;
        salesDataCont.selectedValueQuery();           
        salesDataCont.selectedPreset = 'Test Preset';
        salesDataCont.selectedReport = 'UnitSales';        
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.queryAccData();
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();            
        Test.stopTest();
    }
    
    static testmethod void testZTS_US_salesDataReportingCont7(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
       
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;
        //salesDataCont.selectedLevelValue = 'CHILD';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = true;
        
        Test.startTest();         
        salesDataCont.selectedValueQuery();
        salesDataCont.selectedPreset = 'Test Preset1';
        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        List<String> lstStr2 = new List<String>{'test1', 'test2'};
        salesDataCont.multiSelectPopulate(lstStr2);
        salesDataCont.multiSelectedValueQuery();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getTherapeuticGrp();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProd();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getSalesSpecies();
        salesDataCont.getSalesSpeciesList();        
        salesDataCont.getradioOptions1();
        salesDataCont.getradioOptions2();      
        salesDataCont.salesPresetAction = 'New';
        salesDataCont.salesPreference();         
        salesDataCont.closePopup();     
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.queryAccData();
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();       
        Test.stopTest();
    }
    
    static testmethod void testZTS_US_salesDataReportingCont8(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
       
        ZTS_US_salesDataReportingController salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.queryAccID = accList[0].id;
        salesDataCont.accntCurrent = accList[0];
        salesDataCont.accntActual = accList[0];
        salesDataCont.accnPrevious = null;
        salesDataCont.selectedAccnt = accList[0].Name;
        //salesDataCont.selectedLevelValue = 'CHILD';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;          
        Test.startTest();          
        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.selectedMATYTD = 'YTD';       
        salesDataCont.selectedValueQuery();     
        salesDataCont = new ZTS_US_salesDataReportingController(cont);
        salesDataCont.selectedPreset = 'Test Preset1';
        salesDataCont.salesPresetAction = 'New';
        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.isChildSelected = true;
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.refreshTable();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        List<String> lstStr2 = new List<String>{'test1', 'test2'};
        salesDataCont.multiSelectPopulate(lstStr2);
        salesDataCont.multiSelectedValueQuery();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getTherapeuticGrp();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProd();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getSalesSpecies();
        salesDataCont.getSalesSpeciesList();        
        salesDataCont.getradioOptions1();
        salesDataCont.getradioOptions2();
        salesDataCont.salesPreference();
        salesDataCont.closePopup();     
        salesDataCont.getSortDirection();
        salesDataCont.setSortDirection('ASC');
        salesDataCont.ViewSortData();       
        salesDataCont.queryAccData();
        salesDataCont.checkAggData();
        salesDataCont.refreshTable();
        salesDataCont.ViewSortData();            
        Test.stopTest();
    }
              
}