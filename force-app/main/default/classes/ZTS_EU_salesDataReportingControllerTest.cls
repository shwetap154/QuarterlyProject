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
* File Name     :  ZTS_EU_salesDataReportingControllerTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Ketan             Created the Class.
* 1.1     12/15        CloudSense(Ilirjana) Modified the class.
* 1.2.    11/17		   Aritra (Cognizant)	Modified the class.
********************************************************************************************************************************************/
@isTest(SeeAllData = true)
public class ZTS_EU_salesDataReportingControllerTest{

    Public static List<Account> accList = new List<Account>();

    public static void createTestData(){

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        accList =  ZTS_EU_DataUtilityTest.createAccountRecord(2);
        accList[0].ParentId = accList[1].Id;        
        System.runAs(usr){
            insert accList;
        }
        
        // Sales Preset creation
        ZTS_EU_Sales_Presets__c salesPresets = new ZTS_EU_Sales_Presets__c ();
        salesPresets.Name = 'Test Preset';
        salesPresets.ZTS_EU_Selected_GLR_Type__c = 'Bill-To';
        salesPresets.ZTS_EU_Selected_Preferred_Brands__c = 'Brand1;Brand2';
        salesPresets.ZTS_EU_Selected_Preferred_Species__c = 'Species1;Species2';
        salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Thera1;Thera2';
        salesPresets.ZTS_EU_Selected_Preferred_Time__c = 'MAT';
        salesPresets.ZTS_EU_User__c = UserInfo.getUserId();
        insert salesPresets;
        
        // Sales Preset creation
        ZTS_EU_Sales_Presets__c salesPresets1 = new ZTS_EU_Sales_Presets__c ();
        salesPresets1.Name = 'Test Preset1';
        salesPresets1.ZTS_EU_Selected_GLR_Type__c = 'Bill-To';
        salesPresets1.ZTS_EU_Selected_Preferred_Brands__c = 'Brand1;Brand2';
        salesPresets1.ZTS_EU_Selected_Preferred_Species__c = 'Species1;Species2';
        salesPresets1.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Thera1;Thera2';
        salesPresets1.ZTS_EU_Selected_Preferred_Time__c = 'YTD';
        salesPresets1.ZTS_EU_User__c = UserInfo.getUserId();
        insert salesPresets1;
        
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
        salesThera.ZTS_EU_Account__c = accList[0].id;
        salesThera.ZTS_EU_Date__c = system.today()-60;
        salesThera.ZTS_EU_Product__c  = prodSpeciesThera.Id;
        salesThera.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesThera.CurrencyIsoCode = 'EUR';
        insert salesThera;
        
        ZTS_EU_Net_Sales__c salesThera1 = new ZTS_EU_Net_Sales__c();
        salesThera1.ZTS_EU_Account__c = accList[0].id;
        salesThera1.ZTS_EU_Date__c = system.today()-60;
        salesThera1.ZTS_EU_Product__c  = prodSpeciesThera.Id;
        salesThera1.CurrencyIsoCode = 'EUR';
        insert salesThera1;
        
        // Product of type Brand creation specific to this class
        ZTS_EU_Species_Product__c prodSpeciesBrand = new ZTS_EU_Species_Product__c();
        prodSpeciesBrand.Name='Test Product Brand';
        prodSpeciesBrand.ZTS_EU_Market__c='United Kingdom';
        prodSpeciesBrand.ZTS_EU_Type__c='Brand';
        prodSpeciesBrand.CurrencyIsoCode = 'EUR';
        prodSpeciesBrand.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpeciesBrand.ZTS_EU_Is_Active__c=true;
        insert prodSpeciesBrand;
        
        // Sales record creation with product of type Brand
        ZTS_EU_Sales__c salesBrand = new ZTS_EU_Sales__c();
        salesBrand.ZTS_EU_Account__c = accList[0].id;
        salesBrand.ZTS_EU_Date__c = system.today()-60;
        salesBrand.ZTS_EU_Product__c  = prodSpeciesBrand.Id;
        salesBrand.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesBrand.CurrencyIsoCode = 'EUR';
        insert salesBrand;
        
        ZTS_EU_Net_Sales__c salesBrand1 = new ZTS_EU_Net_Sales__c();
        salesBrand1.ZTS_EU_Account__c = accList[0].id;
        salesBrand1.ZTS_EU_Date__c = system.today()-60;
        salesBrand1.ZTS_EU_Product__c  = prodSpeciesBrand.Id;
        salesBrand1.CurrencyIsoCode = 'EUR';
        insert salesBrand1;
        
        ZTS_EU_Species_Product__c prodSpeciesMPG= new ZTS_EU_Species_Product__c();
        prodSpeciesMPG.Name='Test Product MPG';
        prodSpeciesMPG.ZTS_EU_Market__c='United Kingdom';
        prodSpeciesMPG.ZTS_EU_Type__c='MPG';
        prodSpeciesMPG.ZTS_EU_Parent_Species_Product__c=prodSpeciesBrand.Id;
        prodSpeciesMPG.CurrencyIsoCode = 'EUR';
        prodSpeciesMPG.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpeciesMPG.ZTS_EU_Is_Active__c=true;
        insert prodSpeciesMPG;
        
        ZTS_EU_Species_Product__c prodSpeciesSKU= new ZTS_EU_Species_Product__c();
        prodSpeciesSKU.Name='Test Product SKU';
        prodSpeciesSKU.ZTS_EU_Market__c='United Kingdom';
        prodSpeciesSKU.ZTS_EU_Type__c='SKU';
        prodSpeciesSKU.ZTS_EU_Parent_Species_Product__c=prodSpeciesMPG.Id;
        prodSpeciesSKU.CurrencyIsoCode = 'EUR';
        prodSpeciesSKU.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpeciesSKU.ZTS_EU_Is_Active__c=true;
        insert prodSpeciesSKU;
        
        ZTS_EU_Sales__c salesSKU = new ZTS_EU_Sales__c();
        salesSKU.ZTS_EU_Account__c = accList[0].id;
        salesSKU.ZTS_EU_Date__c = system.today()-60;
        salesSKU.ZTS_EU_Product__c  = prodSpeciesSKU.Id;
        salesSKU.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesSKU.CurrencyIsoCode = 'EUR';
        insert salesSKU;
        
        ZTS_EU_Net_Sales__c salesSKU1 = new ZTS_EU_Net_Sales__c();
        salesSKU1.ZTS_EU_Account__c = accList[0].id;
        salesSKU1.ZTS_EU_Date__c = system.today()-60;
        salesSKU1.ZTS_EU_Product__c  = prodSpeciesSKU.Id;
        salesSKU1.CurrencyIsoCode = 'EUR';
        insert salesSKU1;
        
        
        ZTS_EU_Sales__c salesTotal = new ZTS_EU_Sales__c();
        salesTotal.ZTS_EU_Account__c = accList[0].id;
        salesTotal.ZTS_EU_Date__c = system.today()-60;
        salesTotal.ZTS_EU_GLR_Type__c = 'Bill-To';
        salesTotal.CurrencyIsoCode = 'EUR';
        insert salesTotal;
        
        ZTS_EU_Net_Sales__c salesTotal1 = new ZTS_EU_Net_Sales__c();
        salesTotal1.ZTS_EU_Account__c = accList[0].id;
        salesTotal1.ZTS_EU_Date__c = system.today()-60;
        salesTotal1.CurrencyIsoCode = 'EUR';
        insert salesTotal1;
        
        System.debug('-->SALE1'+salesThera.ZTS_EU_Product__c);
        System.debug('-->SALE2'+salesBrand.ZTS_EU_Product__c);
        System.debug('-->SALE1'+salesThera.ZTS_EU_Product__r.ZTS_EU_Type__c);
        System.debug('-->SALE2'+salesBrand.ZTS_EU_Product__r.ZTS_EU_Type__c);
    }
    
    //Ilirjana 14/12/14 Added tests
    static testmethod void testNoGross(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        Test.startTest();
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedAccnt = accList[0].Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.accntParent = accList[1];
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.queryAccData();
        salesDataCont.refreshTable();
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        
        salesDataCont.salesPresetAction = 'New';
        salesDataCont.selectedPreset = '--None--';
        // Sales Preset creation
        ZTS_EU_Sales_Presets__c salesPresets = new ZTS_EU_Sales_Presets__c ();
        salesPresets.Name = salesDataCont.selectedPreset;
        salesPresets.ZTS_EU_Selected_GLR_Type__c = 'Bill-To';
        salesPresets.ZTS_EU_Selected_Preferred_Brands__c = 'Brand1;Brand2';
        salesPresets.ZTS_EU_Selected_Preferred_Species__c = 'Species1;Species2';
        salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Thera1;Thera2';
        salesPresets.ZTS_EU_Selected_Preferred_Time__c = 'MAT';
        salesPresets.ZTS_EU_User__c = UserInfo.getUserId();
        insert salesPresets;
        salesDataCont.userPreference();
        salesDataCont.savePreferences();
        
        salesDataCont.salesPresetAction = 'Edit';
        salesDataCont.selectedPreset = 'TestSP';
        // Sales Preset creation
        ZTS_EU_Sales_Presets__c salesPresets2 = new ZTS_EU_Sales_Presets__c ();
        salesPresets2.Name = salesDataCont.selectedPreset;
        salesPresets2.ZTS_EU_Selected_GLR_Type__c = 'Bill-To';
        salesPresets2.ZTS_EU_Selected_Preferred_Brands__c = 'Brand1;Brand2';
        salesPresets2.ZTS_EU_Selected_Preferred_Species__c = 'Species1;Species2';
        salesPresets2.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Thera1;Thera2';
        salesPresets2.ZTS_EU_Selected_Preferred_Time__c = 'YTD';
        salesPresets2.ZTS_EU_User__c = UserInfo.getUserId();
        insert salesPresets2;
        salesDataCont.userPreference();
        salesDataCont.savePreferences();
        
        salesDataCont.createQueryStr();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedAccnt = accList[0].Name;
        salesDataCont.getSalesData();
        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
        ZTS_EU_Logger.getDMLSuccessMsg(accList);
        
        Test.stopTest();
    }
        
    static testmethod void testZTS_EU_salesDataReportingCont(){
        createTestData();
        
        
        
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        Test.startTest();
            salesDataCont.createQueryStr();
           // salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.salesPresetAction = 'New';
            salesDataCont.isChildSelected = false;
            salesDataCont.multiSelectedValueQuery();
            salesDataCont.getSalesPresetsData();
            salesDataCont.getTherapeuticGrp();
            
            salesDataCont.getSalesDataProd();
            
            salesDataCont.getSalesSpecies();
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
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
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingCont1(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
        ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.createQueryStr();
           // salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.selectedReport = 'UnitSales';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
//System.debug('1--> '+salesDataCont.selectedBillToShipTo);
            salesDataCont.multiSelectedValueQuery();
            
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.multiSelectedValueQuery();
            salesDataCont.getSalesPresetsData();
            salesDataCont.getTherapeuticGrp();
            
            salesDataCont.getSalesDataProd();
            
            salesDataCont.getSalesSpecies();
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
            /*Dec 1:Added by Bimba*/salesDataCont.salesPresetAction = 'New';
            salesDataCont.salesPreference();
            salesDataCont.savePreferences();
            salesDataCont.closePopup();
            
            salesDataCont.getSortDirection();
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
  
    static testmethod void testZTS_EU_salesDataReportingCont2(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.createQueryStr();
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
//System.debug('--> '+salesDataCont.selectedBillToShipTo);
//System.debug(salesDataCont.accntIds);
//System.debug(salesDataCont.prodLevel);
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
            salesDataCont.getradioOptionsSales();
            SalesDataCont.callSalethroghtMethod();
            salesDataCont.getBusinessUnitsList();
            salesDataCont.getSalesBusinessUnits();
            /*Dec 1:Added by Bimba*/salesDataCont.salesPresetAction = 'New';
            salesDataCont.salesPreference();
            salesDataCont.savePreferences();
            salesDataCont.closePopup();
            
            salesDataCont.getSortDirection();
            salesDataCont.setSortDirection('ASC');
            //salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            //salesDataCont.queryAccData();
           // salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
   static testmethod void testZTS_EU_salesDataReportingCont3(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.createQueryStr();
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = '--None--';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();

            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
     static testmethod void testZTS_EU_salesDataReportingCont4(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.createQueryStr();
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = '--None--';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();

            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingCont6(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.createQueryStr();
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
//System.debug('--> '+salesDataCont.selectedBillToShipTo);
//System.debug(salesDataCont.accntIds);
//System.debug(salesDataCont.prodLevel);
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
            salesDataCont.getradioOptionsSales();
            salesDataCont.getBusinessUnitsList();
            salesDataCont.getSalesBusinessUnits();
            /*Dec 1:Added by Bimba*/salesDataCont.salesPresetAction = 'New';
            salesDataCont.salesPreference();
            salesDataCont.savePreferences();
            salesDataCont.closePopup();
            
            salesDataCont.getSortDirection();
            salesDataCont.setSortDirection('ASC');
           // salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            //salesDataCont.queryAccData();
            //salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingContTotalSales(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.createQueryStr();
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
             salesDataCont.salesPresetAction = 'New';
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
//System.debug('--> '+salesDataCont.selectedBillToShipTo);
//System.debug(salesDataCont.accntIds);
//System.debug(salesDataCont.prodLevel);
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
            salesDataCont.getradioOptionsSales();
            salesDataCont.getBusinessUnitsList();
            salesDataCont.getSalesBusinessUnits();
            
            salesDataCont.salesPreference();
            salesDataCont.savePreferences();
            salesDataCont.closePopup();
            
            salesDataCont.getSortDirection();
            salesDataCont.setSortDirection('ASC');
            //salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            //salesDataCont.queryAccData();
            //salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
     static testmethod void testZTS_EU_salesDataReportingContTotalSalesYTD(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.createQueryStr();
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            
            salesDataCont.selectedPreset = 'Test Preset1';
           // salesDataCont.salesPresetAction = 'New';
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
       
         
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingContTotalSalesYTDGreg(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.createQueryStr();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.refreshTable();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
        
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
        
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
       
         
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingContProductSalesYTDGreg(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.createQueryStr();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.refreshTable();
        
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
        
        	salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1'; 
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.refreshTable();
        
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
           salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
        
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
       
         
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
     static testmethod void testZTS_EU_salesDataReportingContUnitSalesYTDGreg(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(accList[0]);
        ZTS_EU_salesDataReportingController salesDataCont = new ZTS_EU_salesDataReportingController(cont);
        ZTS_EU_salesDataReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_salesDataReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_salesDataReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_salesDataReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_salesDataReportingController.dataYTD dy1 = new ZTS_EU_salesDataReportingController.dataYTD(null, null);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd1 = new ZTS_EU_salesDataReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_salesDataReportingController.dataYTD> lstStr = new List<ZTS_EU_salesDataReportingController.dataYTD>();
            List<ZTS_EU_salesDataReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_salesDataReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd2 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_salesDataReportingController.CustomSettSalesData cssd3 = new ZTS_EU_salesDataReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.createQueryStr();
            salesDataCont.selectedValueQuery();
         
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.refreshTable();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
            
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
           salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
         
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
           salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Gregorian Calendar';
            salesDataCont.selectedSalesType = 'Net';
            salesDataCont.refreshTable();
        
            salesDataCont = new ZTS_EU_salesDataReportingController(cont);
           salesDataCont.selectedPreset = 'Test Preset1';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'MAT';
        	salesDataCont.selectedDisplayType = 'Accounting Period';
            salesDataCont.selectedSalesType = 'Gross';
            salesDataCont.refreshTable();
        
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
       
         
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            
            salesDataCont.accntParent = accList[1];
            salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
}