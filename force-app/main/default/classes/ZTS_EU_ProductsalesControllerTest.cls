/**
 */
/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ProductsalesControllerTest
* Description   :           
* @author       :  Laxmikanth
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10/27       Laxmikanth           Created the Class.
********************************************************************************************************************************************/
@isTest
public class ZTS_EU_ProductsalesControllerTest{

    Public static ZTS_EU_Species_Product__c PrdList= new ZTS_EU_Species_Product__c();
    Public static ZTS_EU_Species_Product__c PrdList2= new ZTS_EU_Species_Product__c();
    Public static ZTS_EU_Species_Product__c PrdList3= new ZTS_EU_Species_Product__c();
    Public static ZTS_EU_Species_Product__c PrdList4= new ZTS_EU_Species_Product__c();
    Public static List<Account> PrdListIreland = new List<Account>();
   Public static List<Account> PrdListAus= new List<Account>();
    public static void createTestData(){
        PrdList=  ZTS_EU_DataUtilityTest.createProduct('Brand',true);
        PrdList2=  ZTS_EU_DataUtilityTest.createProduct('Therapeutic Group',true);
        PrdList3=  ZTS_EU_DataUtilityTest.createProduct('Business Unit',true);
        PrdList4=  ZTS_EU_DataUtilityTest.createProduct('SKU',true);
        
        //insert PrdList;
        
     //PrdListAus = ZTS_EU_DataUtilityTest.createAccountRecordAus(2);
     //insert PrdListAus; 
     //PrdListIreland = ZTS_EU_DataUtilityTest.createAccountRecordIre(2); 
     //insert PrdListIreland;       
      
        //PrdListAus.ZTS_EU_Vetsave_ID__c='100';
        //update PrdListAus;
        
        // Sales Preset creation
       // List<ZTS_EU_Species_Product__c> Theragrps = [select Id, ZTS_EU_Type__c,Name from ZTS_EU_Species_Product__c where ZTS_EU_Type__c = 'Therapeutic Group' ORDER BY Name];
       // List<ZTS_EU_Species_Product__c> prds = [select Id, ZTS_EU_Type__c,Name from ZTS_EU_Species_Product__c where ZTS_EU_Type__c = 'Brand' ORDER BY Name];
     
        CurrencySymbolMapping__c cur = new CurrencySymbolMapping__c();
        cur.Currency_Symbol__c = '$';
        cur.name = 'EUR';
        insert cur;
        // Product of type Therapeutic Group creation specific to this class
        ZTS_EU_Species_Product__c prodSpeciesThera = new ZTS_EU_Species_Product__c();
        prodSpeciesThera.Name='Test Product Thera';
        prodSpeciesThera.ZTS_EU_Market__c='United Kingdom';
        prodSpeciesThera.ZTS_EU_Type__c='Brand';
        prodSpeciesThera.CurrencyIsoCode = 'EUR';
        prodSpeciesThera.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpeciesThera.ZTS_EU_Is_Active__c=true;
        insert prodSpeciesThera;
        
        // Product of type Brand creation specific to this class
        ZTS_EU_Species_Product__c prodSpeciesBrand = new ZTS_EU_Species_Product__c();
        prodSpeciesBrand.Name='Test Product Brand';
        prodSpeciesBrand.ZTS_EU_Market__c='United Kingdom';
        prodSpeciesBrand.ZTS_EU_Type__c='Brand';
        prodSpeciesBrand.CurrencyIsoCode = 'EUR';
        prodSpeciesBrand.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpeciesBrand.ZTS_EU_Is_Active__c=true;
        insert prodSpeciesBrand;
        
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
        
        
        ZTS_EU_Sales_Date__c salesDate = new ZTS_EU_Sales_Date__c();
        salesDate.Name = 'United Kingdom - Sales Date';
        salesDate.ZTS_EU_01__c = 'MAR';
        salesDate.ZTS_EU_02__c = 'FEB';
        salesDate.ZTS_EU_03__c = 'JAN';
        salesDate.ZTS_EU_04__c = 'DEC';
        salesDate.ZTS_EU_05__c = 'NOV';
        salesDate.ZTS_EU_06__c = 'OCT';
        salesDate.ZTS_EU_07__c = 'SEP';
        salesDate.ZTS_EU_08__c = 'AUG';
        salesDate.ZTS_EU_09__c = 'JUL';
        salesDate.ZTS_EU_10__c = 'JUN';
        salesDate.ZTS_EU_11__c = 'MAY';
        salesDate.ZTS_EU_12__c = 'APR';
        salesDate.ZTS_EU_Date__c = date.parse('3/9/2017');
        salesDate.ZTS_EU_External_ID__c = 'GBR-SALES';
        salesDate.ZTS_EU_Market__c = 'United Kingdom';
        
        insert salesDate;
        
        
    }
    
    //Ilirjana 14/12/14 Added tests
    static testmethod void testNoGross(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = false;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        Test.startTest();
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        //salesDataCont.accntParent = PrdList[1];
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        ////salesDataCont.queryAccData();
        salesDataCont.refreshTable();
        salesDataCont.isChildSelected = true;
        //salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        //salesDataCont.currencyisocode='EUR';
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
        
    static testmethod void testZTS_EU_salesDataReportingCont(){
        createTestData();
        
        
        
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        Test.startTest();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.salesPresetAction = 'New';
            salesDataCont.isChildSelected = false;
            salesDataCont.multiSelectedValueQuery();
            
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
            salesDataCont.generateUnitSalesPdf();
            salesDataCont.DownloadUnitSalesExcel();
            salesDataCont.generateProductSalesPdf();
            salesDataCont.DownloadProductSalesExcel();
            salesDataCont.generateTotalSalesPdf();
            salesDataCont.DownloadTotalSalesExcel();
            
            //salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingCont1(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
        ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.selectedReport = 'UnitSales';
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
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
            //salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingCont2(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.selectedMATYTD = 'YTD';
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
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
            
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
            salesDataCont.getradioOptionsSales();
            SalesDataCont.callSalethroghtMethod();
            
        Test.stopTest();
    }
    
   static testmethod void testZTS_EU_salesDataReportingCont3(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'ProductSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
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
            //salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
     static testmethod void testZTS_EU_salesDataReportingCont4(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
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
           // //salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            //salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingCont6(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
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
            
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
            salesDataCont.getradioOptionsSales();
            
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingContTotalSales(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
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
            salesDataCont.getradioOptions1();
            salesDataCont.getradioOptions2();
            salesDataCont.getradioOptionsSales();
            salesDataCont.getBusinessUnitsList();
            
            salesDataCont.salesPreference();
            salesDataCont.getSortDirection();
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            ////salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
     static testmethod void testZTS_EU_salesDataReportingContTotalSalesYTD(){
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        ZTS_EU_ProductsalesReportingController.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesReportingController.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesReportingController.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesReportingController.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesReportingController.dataYTD dy1 = new ZTS_EU_ProductsalesReportingController.dataYTD(null, null);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesReportingController.dataYTD> lstStr = new List<ZTS_EU_ProductsalesReportingController.dataYTD>();
            List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesReportingController.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesReportingController.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesReportingController.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.selectedMATYTD = 'YTD';
         //   salesDataCont.dataNoMonth();
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
            //salesDataCont.selectedPreset = 'Test Preset1';
           // salesDataCont.salesPresetAction = 'New';
            salesDataCont.selectedReport = 'TotalSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.refreshTable();
            salesDataCont.closePopup();
            salesDataCont.getSortDirection();
       
            salesDataCont.getCARatings();
            salesDataCont.getEQRatings();
            salesDataCont.getRURatings();
            salesDataCont.getSWRatings();
            salesDataCont.getPYRatings();
            salesDataCont.getPHRatings();
            salesDataCont.getLSRatings();
            salesDataCont.getVPSRatings();
            salesDataCont.getAccountGrpList();
            salesDataCont.checkClickPrevPage();
            salesDataCont.checkClickNextPage();
            salesDataCont.setSortDirection('ASC');
            salesDataCont.ViewSortData();
            //salesDataCont.queryAccData();
            salesDataCont.refreshTable();
            salesDataCont.ViewSortData();
            
        Test.stopTest();
    }
    
    static testmethod void testZTS_EU_salesDataReportingCont11(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = false;
        salesRadio.DisplayOn__c = false;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
       // ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData(null, null, null, null);
        
        Test.startTest();
            ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesExcelExport.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.dataYTD dy1 = new ZTS_EU_ProductsalesExcelExport.dataYTD(null, null);
          //  ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesExcelExport.dataYTD> lstStr = new List<ZTS_EU_ProductsalesExcelExport.dataYTD>();
            List<ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.runningTest = true;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.selectedValueQuery();
            
            salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.isChildSelected = false;
            salesDataCont.selectedMATYTD = 'YTD';
            List<String> lstStr2 = new List<String>{'test1', 'test2'};
            
            
            
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExport(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList;
        
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdChild = PrdList;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExportNotYTD(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList;
        
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdChild = PrdList;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    
    static testmethod void testNoGrossExcelExportNullSelectedMATYTD(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList;
        
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdChild = PrdList;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExportTheraputicGroup(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList2);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList2;
        salesDataCont.selectedAccount = 'Test Acc';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList2.Name;
        salesDataCont.prdParent = PrdList2;
        salesDataCont.prdChild = PrdList2;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList2.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExportBusinessUnit(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList3);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList3;
        salesDataCont.selectedAccount = 'Test Acc';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList3.Name;
        salesDataCont.prdParent = PrdList3;
        salesDataCont.prdChild = PrdList3;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList3.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExportAllRecordsSelected(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList4);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList4;
        salesDataCont.selectedAccount = 'Test Acc';
        salesDataCont.allRecords = 'check';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList4.Name;
        salesDataCont.prdParent = PrdList4;
        salesDataCont.prdChild = PrdList4;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList4.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExportLinkNextTrue(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList4);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList4;
        salesDataCont.selectedAccount = 'Test Acc';
        salesDataCont.allRecords = 'check';
        salesDataCont.linkNext = true;
        salesDataCont.linkPrev = false;
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList4.Name;
        salesDataCont.prdParent = PrdList4;
        salesDataCont.prdChild = PrdList4;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList4.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossExcelExportSKU(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList4);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList4;
        salesDataCont.selectedAccount = 'Test Acc';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList4.Name;
        salesDataCont.prdParent = PrdList4;
        salesDataCont.prdChild = PrdList4;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList4.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    
    static testmethod void testNoGrossExcelExportNullSelectedNotNullAccount(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
        List<SelectOption> thGroup = new List<SelectOption>();
        thGroup.add(new SelectOption('Test1','Test1'));
        thGroup.add(new SelectOption('Test2','Test2'));
        
        List<String> strList = new List<String>();
        strList.add('Test1');
        strList.add('Test2');
        
        Test.startTest();
        salesDataCont.selectedMultiTherapeuticGrpOpt = thGroup;
        salesDataCont.listMultiTherapeuticGrp = thGroup;
        salesDataCont.selectedMultiProductOpt = thGroup;
        salesDataCont.selectedMultiSpeciesOpt = thGroup;
        salesDataCont.selectedMultiBusinessUnitOpt = thGroup;
        salesDataCont.selectedSpecies = 'Test1';
        salesDataCont.monthList = strList;
        salesDataCont.displayPopup = true;
        salesDataCont.salesPresetAction = 'Test2';
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'TestStr';
        salesDataCont.PrdCurrent = PrdList;
        salesDataCont.selectedAccount = 'Test Acc';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdChild = PrdList;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.isChildSelected = true;
        salesDataCont.queryAccData();
        salesDataCont.selectedPrd = PrdList.Name;
        
        salesDataCont.runningTest = false;
        
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        
        salesDataCont.checkClickPrevPage();
        salesDataCont.checkClickNextPage();
        
        
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();
        SalesDataCont.callSalethroghtMethod();
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    //Ilirjana 14/12/14 Added tests
    static testmethod void testNoGross1(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossTHGroup(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList2);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList2;
        salesDataCont.prdParent = PrdList2;
        salesDataCont.prdCurrent = PrdList2;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList2.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossBusinessUnit(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList3);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList3;
        salesDataCont.prdParent = PrdList3;
        salesDataCont.prdCurrent = PrdList3;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList3.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList3.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSKU(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList4);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList4;
        salesDataCont.prdParent = PrdList4;
        salesDataCont.prdCurrent = PrdList4;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList4.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList4.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNullMatYTD(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullAccount(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedAccount = 'Test Acc';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullCARating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedCARating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullEQRating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedEQRating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullRURating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedRURating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullSWRating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedSWRating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    
    static testmethod void testNoGrossSelectedNotNullPYRating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedPYRating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullPHRating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedPHRating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullLSRating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedLSRating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGrossSelectedNotNullVPSRating(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = true;
        salesRadio.DisplayOn__c = false;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        salesDataCont.selectedMultiTherapeuticGrpOpt = testList;
        salesDataCont.listMultiTherapeuticGrp = testList;
        salesDataCont.selectedMultiProductOpt = testList;
        salesDataCont.selectedMultiSpeciesOpt = testList;
        salesDataCont.selectedMultiBusinessUnitOpt = testList;
        salesDataCont.monthList = testListString;
        salesDataCont.toggleFlagParent = true;
        salesDataCont.getAllRecords = true;
        salesDataCont.prettyJSON = 'TestJson';
        salesDataCont.selectedVPSRating = 'Test';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = null;
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = true;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        Test.setMock(HttpCalloutMock.class, new ZTS_EU_MockHttpResponseGenerator());
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.selectedReport = 'TotalSales';
        salesDataCont.getSalesDataFromIXH();

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    static testmethod void testNoGross2(){
       
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = false;
        salesRadio.DisplayOn__c = true;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        ZTS_EU_ProductsalesReportingController salesDataCont = new ZTS_EU_ProductsalesReportingController(cont);
        
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
        salesDataCont.prdChild = PrdList;
        salesDataCont.prdParent = PrdList;
        salesDataCont.prdCurrent = PrdList;
        
        salesDataCont.selectedTerr = 'Ter1';
        salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
        salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
        salesDataCont.selectedRating = 'Test1';
        
        salesDataCont.selectedSalesType = 'No_Gross';
        salesDataCont.selectedMATYTD = 'YTD';
        salesDataCont.selectedLevelValue = 'Head Office';
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.selectedTherapeuticGrp = 'Test TG';
        salesDataCont.selectedProduct = 'Test Prod';
        salesDataCont.selectedBusinessUnit = 'Test BU';
        salesDataCont.isChildSelected = false;
        salesDataCont.noParent = false;
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        salesDataCont.queryAccData();
        salesDataCont.getTherapeuticGrpList();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getBusinessUnitsList();
        salesDataCont.getradioOptionsSales();
        salesDataCont.selectedPrd = PrdList.Name;
        salesDataCont.currencyType= '$';
        salesDataCont.runningTest = true;
        salesDataCont.selectedReport = 'ProductSales';
        

        

        salesDataCont.getradioOptions3();
        SalesDataCont.callSalethroghtMethod();
        salesDataCont.listStringPopulate(testList);
        salesDataCont.listStringPopulate1(testList);
        salesDataCont.listSelOptPopulate(testListString);
        salesDataCont.listSelOptPopulate1(testMapString);
        
        
        ZTS_EU_Logger.errorAsync('mess','stat','ltype');
        ZTS_EU_Logger.warn('mess','stat','ltype');
        ZTS_EU_Logger.info('mess','stat','ltype');
        ZTS_EU_Logger.debug('mess','stat','ltype');
        ZTS_EU_Logger.trace('mess','stat','ltype');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, 'message');
       // ZTS_EU_Logger.getDMLSuccessMsg(PrdList);
        
        Test.stopTest();
    }
    
    
    static testmethod void testZTS_EU_salesDataReportingCont12(){
        SalesRadioButtonsDisplay__c salesRadio = new SalesRadioButtonsDisplay__c();
        salesRadio.Name = 'United Kingdom';
        salesRadio.DisplayNetSalesOnly__c = false;
        salesRadio.DisplayOn__c = true;
        
        insert salesRadio;
        createTestData();
        ApexPages.standardController cont =  new ApexPages.StandardController(PrdList);
        //PageReference myPage = Page.ZTS_EU_AddtoCampaign_Redirect;
        ZTS_EU_ProductsalesExcelExport salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
        
       // ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cusSetSalData = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData(null, null, null, null);
        List<SelectOption> testList = new List<SelectOption>();
        testList.add(new SelectOption('test1','test1'));
        testList.add(new SelectOption('test2','test1'));
        
        List<String> testListString = new List<String>();
        testListString.add('test1');
        testListString.add('test2');
        
        Map<String,String> testMapString = new Map<String,String>();
        testMapString.put('test1','test1a');
        testMapString.put('test2','test2a');
        
        Test.startTest();
            
            ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue ASDV1 = new ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue ASDV2 = new ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue ASDV3 = new ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.AccntSalesDataValue ASDV4= new ZTS_EU_ProductsalesExcelExport.AccntSalesDataValue(null, null, null, null);
            ZTS_EU_ProductsalesExcelExport.dataYTD dy1 = new ZTS_EU_ProductsalesExcelExport.dataYTD(null, null);
          //  ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cssd1 = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData(null, null, null, null);
            List<ZTS_EU_ProductsalesExcelExport.dataYTD> lstStr = new List<ZTS_EU_ProductsalesExcelExport.dataYTD>();
            List<ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue> lstASDV = new List<ZTS_EU_ProductsalesExcelExport.ActualSalesDataValue>();
            Map<String, List<String>> mapStrLstStr = new Map<String, List<String>>();
            ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cssd2 = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData('', '', '', lstASDV, lstStr);
            ZTS_EU_ProductsalesExcelExport.CustomSettSalesData cssd3 = new ZTS_EU_ProductsalesExcelExport.CustomSettSalesData('', '', '', lstASDV, mapStrLstStr);
            salesDataCont.selectedReport = 'UnitSales';
            salesDataCont.runningTest = true;
            salesDataCont.selectedMATYTD = 'YTD';
            salesDataCont.selectedValueQuery();
            
            salesDataCont.prdChild = PrdList;
            salesDataCont.prdParent = PrdList;
            salesDataCont.prdCurrent = PrdList;
            
            salesDataCont.selectedTerr = 'Ter1';
            salesDataCont.selectedMultiTherapeuticGrp = new String[]{'Test1','Test2'};
            salesDataCont.selectedMultiProduct = new String[]{'Test1','Test2'};
            salesDataCont.selectedMultiSpecies = new String[]{'Test1','Test2'};
            salesDataCont.selectedMultiBusinessUnits = new String[]{'Test1','Test2'};
            salesDataCont.selectedRating = 'Test1';
            salesDataCont = new ZTS_EU_ProductsalesExcelExport(cont);
            salesDataCont.selectedPreset = 'Test Preset';
            salesDataCont.isChildSelected = false;
            salesDataCont.noParent = false;
            List<String> lstStr2 = new List<String>{'test1', 'test2'};
            
            
            
        Test.stopTest();
    }
}