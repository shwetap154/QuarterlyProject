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
* File Name     :  ZTS_US_IXHSalesDataControllerTest
* Description   :           
* @author       :  Abir Bhattacharya
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     2/22       Abir Bhattacharya      Created the Class.

********************************************************************************************************************************************/
@isTest(SeeAllData = false)
public class ZTS_US_IXHSalesDataControllerTest{
    public static list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS;
    public static string queryString;
    
    //Initializes data required to run the test class 
    @testSetup 
    private static void initialize(){
        lstSEUS = new  list<IXH_IXH_SALES_ENRICHED_US__x>();
        
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account objAccount = testAccts[0];
        objAccount.Name = 'Test Account';
        objAccount.ZTS_EU_Market__c = 'United States';
        
        insert objAccount;
        
        List<ZTS_EU_Sales_Presets__c> lstPresets = new List<ZTS_EU_Sales_Presets__c>();
        
        ZTS_EU_Sales_Presets__c salesPresets = new ZTS_EU_Sales_Presets__c ();
        salesPresets.Name = 'Test Preset1';
        salesPresets.ZTS_EU_Selected_GLR_Type__c = 'BILL-TO';
        salesPresets.ZTS_EU_Selected_Preferred_Brands__c = 'TSV-2;Inforce-3';
        salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c = 'a1ci0000000JsrGAAS;a1ci0000000Jt2nAAC';
        salesPresets.ZTS_EU_Selected_Preferred_Species__c = 'Cattle';
        salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Biologicals Respiratory';
        salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c = 'a1ci0000000Jsp8AAC';   
        salesPresets.ZTS_EU_Selected_Preferred_Time__c = 'MAT';
        salesPresets.ZTS_EU_User__c = UserInfo.getUserId();
        lstPresets.add(salesPresets);
        
        // Sales Preset creation
        ZTS_EU_Sales_Presets__c salesPresets1 = new ZTS_EU_Sales_Presets__c ();
        salesPresets1.Name = 'Test Preset2';
        salesPresets1.ZTS_EU_Selected_GLR_Type__c = 'SHIP-TO';
        salesPresets1.ZTS_EU_Selected_Preferred_Brands__c = 'TSV-2;Inforce-3';
        salesPresets1.ZTS_EU_Selected_Preferred_Brands_Ids__c = 'a1ci0000000JsrGAAS;a1ci0000000Jt2nAAC';
        salesPresets1.ZTS_EU_Selected_Preferred_Species__c = 'Equine';
        salesPresets1.ZTS_EU_Selected_Preferred_Thera_Grps__c = 'Biologicals Respiratory';
        salesPresets1.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c = 'a1ci0000000Qsp8AAC';  
        salesPresets1.ZTS_EU_Selected_Preferred_Time__c = 'YTD';
        salesPresets1.ZTS_EU_User__c = UserInfo.getUserId();
        lstPresets.add(salesPresets1);
        
        insert lstPresets;
        
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        system.debug('obj==='+obj);
        lstSEUS.add(obj);       
        queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        system.debug('queryString2======'+queryString);
    }
    
    @isTest
    public static void TestTotalSales(){
        
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('TotalSales', 200);
        
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        salesDataCont.redirect();
        
        
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        salesDataCont.queryAccName = 'Test';
        salesDataCont.selectedTerr = 'Test';
        salesDataCont.soqlQuery = 'Test'; 
        salesDataCont.isChildSelected = true;
        salesDataCont.monthList = new List<String>{'Test'};
            salesDataCont.toggleFlagParent = false;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'test';
        
        //changing the execution context to do rest callout
        Test.startTest();        
        salesDataCont.queryAccData();
        salesDataCont.getcreateDataTable();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getSalesProdList();
        salesDataCont.generateUnitSalesPdf();
        salesDataCont.DownloadUnitSalesExcel();
        salesDataCont.generateProductSalesPdf();
        salesDataCont.DownloadProductSalesExcel();
        salesDataCont.generateTotalSalesPdf();
        salesDataCont.DownloadTotalSalesExcel();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        // added by Kishore
        salesDataCont.FirstPage();
        salesDataCont.next();
        salesDataCont.LastPage();
        salesDataCont.previous();
        salesDataCont.getnxt();
        salesDataCont.getprev();
        String val ='ASC';
        salesDataCont.setSortDirection(val);
         // ---------
        Test.stopTest();
        
        ZTS_US_IXHsalesDataReportingController.ActualSalesDataValue objActualSalesValue = salesDataCont.customSetList[0].salesDataWrapp[0];
        
        //system.debug('--objActualSalesValue--'+objActualSalesValue);
        
        system.assertEquals('65,428', objActualSalesValue.grandTotal[0]);
        system.assertEquals('7%', objActualSalesValue.grandTotal[3]);
        
    }
    
    @isTest
    public static void TestYTDTotalSales(){
        
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('TotalSales', 200);
        
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        salesDataCont.redirect();
         //Added by Kishore
        String t1='Test1';
        List<String> t2 = new List<String>();
        t2.add(t1);
         ZTS_US_IXHsalesDataReportingController.AccntSalesDataValue page = new  ZTS_US_IXHsalesDataReportingController.AccntSalesDataValue(t1,t1,t1,t1);        
        ZTS_US_IXHsalesDataReportingController.dataYTD page1 = new  ZTS_US_IXHsalesDataReportingController.dataYTD(t1,t2);
         ZTS_US_IXHsalesDataReportingController.CustomSettSalesData page2 = new  ZTS_US_IXHsalesDataReportingController.CustomSettSalesData(t1,t1,t1,null);
      //===========================
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00,
                                                                            TOTAL_CYTD_SALES__c = 1234.50, TOTAL_PYTD_SALES__c=6782.90, TOTAL_YTD_DIFF_SALES__c=-5548.4, TOTAL_YTD_P_DIFF_SALES__c=-449.50, TOTAL_CYTD_UNITS__c=12.34, TOTAL_PYTD_UNITS__c=67.83);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=YTD&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        salesDataCont.queryAccName = 'Test';
        salesDataCont.selectedTerr = 'Test';
        salesDataCont.soqlQuery = 'Test'; 
        salesDataCont.isChildSelected = true;
        salesDataCont.monthList = new List<String>{'Test'};
            salesDataCont.toggleFlagParent = false;
        salesDataCont.isChild = true;
        salesDataCont.prettyJSON = 'test';
        
        //changing the execution context to do rest callout
        Test.startTest();        
        salesDataCont.queryAccData();
        salesDataCont.getcreateDataTable();
        salesDataCont.getSalesPresetsData();
        salesDataCont.getSalesDataProdList();
        salesDataCont.getSalesProdList();
        salesDataCont.generateUnitSalesPdf();
        salesDataCont.DownloadUnitSalesExcel();
        salesDataCont.generateProductSalesPdf();
        salesDataCont.DownloadProductSalesExcel();
        salesDataCont.generateTotalSalesPdf();
        salesDataCont.DownloadTotalSalesExcel();
        salesDataCont.closePopup();
        salesDataCont.getSortDirection();
        salesDataCont.ViewSortData();
        salesDataCont.refreshTable();
        Test.stopTest();
        
        ZTS_US_IXHsalesDataReportingController.ActualSalesDataValue objActualSalesValue = salesDataCont.customSetList[0].salesDataWrapp[0];
        //system.debug(objActualSalesValue);
        
        system.assertEquals('1,234', objActualSalesValue.grandTotal[0]);
        system.assertEquals('-449%', objActualSalesValue.grandTotal[3]);
        
    }
    
    
    @isTest
    public static void TestProductSales(){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('ProductSales', 200);
        
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.selectedSalesType = 'BILL-TO';
        salesDataCont.selectedLevelValue = 'CHILD';        
        salesDataCont.selectedPreset = 'Test Preset1';
        //changing the execution context to do rest callout
        Test.startTest();
        
        salesDataCont.getcreateDataTable();
        
        Test.stopTest();
        
        system.debug('##businessUnits:' + salesDataCont.therapeuticGroup);
        Integer intBusinessUnits = salesDataCont.getBusinessUnitsList().size(); 
        system.assertEquals(2, intBusinessUnits);
        
    }
    
    
    @isTest
    public static void TestUnitSales(){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('UnitSales', 200);
        
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.selectedReport = 'UnitSales';
        salesDataCont.selectedSalesType = 'BILL-TO';
        salesDataCont.selectedLevelValue = 'CHILD';        
        salesDataCont.selectedPreset = '--None--';
        //changing the execution context to do rest callout
        Test.startTest();
        
        salesDataCont.getcreateDataTable();
        
        Test.stopTest();
        system.debug('##CustomSett: ' + salesDataCont.customSetList[salesDataCont.customSetList.size()-1]);
        ZTS_US_IXHsalesDataReportingController.ActualSalesDataValue objActualSalesValue = salesDataCont.customSetList[salesDataCont.customSetList.size()-1].salesDataWrapp[0];
        lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                               SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                               MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                               CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                               CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                               CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                               CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                               CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                               CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                               CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                               PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                               PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                               PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                               PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                               PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                               PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                               DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                               DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                               DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                               DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                               DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                               PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                               PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                               PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                               PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                               PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                               TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                               TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        system.debug('##ActualSalesDataValue : ' +  objActualSalesValue);
        system.assertEquals('1,022', objActualSalesValue.grandTotal[0]);
        system.assertEquals('924', objActualSalesValue.grandTotal[1]);
        
    }
    
    
    @isTest
    public static void TestProductSalesMutiSelect(){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('ProductSalesMultiSelect', 200);
        
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        salesDataCont.selectedPreset = 'Test Preset1';
        
        Test.startTest();
        
        salesDataCont.multiSelectedValueQuery();
        
        Test.stopTest();
        
        system.debug('##businessUnits:' + salesDataCont.therapeuticGroup);
        Integer intBusinessUnits = salesDataCont.getBusinessUnitsList().size(); 
        system.assertEquals(2, intBusinessUnits);        
        system.assertEquals(2, salesDataCont.getTherapeuticGrpList().size());   
        //system.assertEquals(null, salesDataCont.getTherapeuticGrpList()[1].getLabel());
        
    }
    
    
    @isTest
    public static void EditSalesPreset(){
        
        List<SelectOption> lstOptions  = null;
        
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('ProductSales', 200);       
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        system.debug('queryString====>>test===='+ queryString);
        
        
        
        salesDataCont.selectedMATYTD = 'MAT';
        salesDataCont.selectedReport = 'ProductSales';
        salesDataCont.selectedSalesType = 'BILL-TO';
        salesDataCont.selectedLevelValue = 'CHILD';        
        system.debug('salesDataCont==='+salesDataCont);
        
        Test.startTest();
        List<SelectOption> options1 = salesDataCont.getradioOptions1();
        List<SelectOption> options2 = salesDataCont.getradioOptions2();
        List<SelectOption> options3 = salesDataCont.getradioOptions3();
        salesDataCont.selectedValueQuery();
        salesDataCont.selectedPreset = 'Test Preset1';
        salesDataCont.salesPresetAction = 'Edit';
        system.debug('salesDataCont===2'+salesDataCont);
         salesDataCont.salesPreference();
        //Added by Kishore
        ZTS_EU_Sales_Presets__c salesPresets = new ZTS_EU_Sales_Presets__c();
        salesPresets.Name = 'Test Preset3';
        salesPresets.ZTS_EU_Selected_GLR_Type__c = 'BILL-TO';        
        salesPresets.ZTS_EU_Selected_Preferred_Time__c = 'MAT';
        Insert salesPresets;
        salesDataCont.salesPresets = salesPresets;
        salesDataCont.savePreferences();
       // =========================
        Test.stopTest();
        
        lstOptions = salesDataCont.selectedMultiTherapeuticGrpOpt;
        system.assertEquals(1, lstOptions.size());
        system.assertEquals('Biologicals Respiratory', lstOptions[0].getLabel());
        lstOptions = salesDataCont.selectedMultiProductOpt;
        system.assertEquals(2, lstOptions.size());
        
        system.assertEquals('MAT', options1[0].getlabel());
        system.assertEquals('Bill-To', options2[0].getlabel());
        
    }
    
    
    @isTest
    public static void SaveSalesPreset(){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        
        ZTS_US_IXHSalesDataControllerTest.setStaticResourceMock('ProductSalesMultiSelect', 200);
        
        ZTS_US_IXHsalesDataReportingController salesDataCont = new ZTS_US_IXHsalesDataReportingController(cont);
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS = new list<IXH_IXH_SALES_ENRICHED_US__x>();
        IXH_IXH_SALES_ENRICHED_US__x obj = new IXH_IXH_SALES_ENRICHED_US__x(ACCOUNT_TYPE__c='Bill-To', AGGREGATION_LEVEL__c='Account', ACCOUNT_AGGREGATION_LEVEL__c='CHILD', ACCOUNT_MASTER_ID__c='10002', MARKET__c='US',DATA_DATE__c = system.today(),
                                                                            SALES_TYPE__c='G', TERRITORY__c='8183;8189;8824;9131;9915;A001;A104;US-Area-109;US-Area-811;US-Terr-1025;US-Terr-C1401;US-Terr-D1401;US-Terr-I0104;US-Terr-T1404;US-Terr-X0109',
                                                                            MARKET_ISO_CODE__c='US', ACCOUNT_ERP_ID__c='10002', ACCOUNT_CRM_ID__c='0012C00000ThtqmQAB', ACCOUNT_NAME__c='Dr N E Lohr', 
                                                                            CURRENCY_ISO_CODE__c='USD', CURRENT_SALES_01__c=3933.00, CURRENT_SALES_02__c=8819.00, CURRENT_SALES_03__c=4412.00, 
                                                                            CURRENT_SALES_04__c=5298.00, CURRENT_SALES_05__c=3449.00, CURRENT_SALES_06__c=6683.00, CURRENT_SALES_07__c=2967.00, 
                                                                            CURRENT_SALES_08__c=3359.00, CURRENT_SALES_09__c=7995.00, CURRENT_SALES_10__c=6486.00, CURRENT_SALES_11__c=7973.00, 
                                                                            CURRENT_SALES_12__c=4055.00, CURRENT_UNITS_01__c=37.00, CURRENT_UNITS_02__c=166.00, CURRENT_UNITS_03__c=42.00, 
                                                                            CURRENT_UNITS_04__c=148.00, CURRENT_UNITS_05__c=34.00, CURRENT_UNITS_06__c=101.00, CURRENT_UNITS_07__c=40.00, 
                                                                            CURRENT_UNITS_08__c=99.00, CURRENT_UNITS_09__c=114.00, CURRENT_UNITS_10__c=78.00, CURRENT_UNITS_11__c=80.00, 
                                                                            CURRENT_UNITS_12__c=82.00, PREVIOUS_SALES_01__c=6072.00, PREVIOUS_SALES_02__c=6825.00, PREVIOUS_SALES_03__c=3983.00, 
                                                                            PREVIOUS_SALES_04__c=7308.00, PREVIOUS_SALES_05__c=2693.00, PREVIOUS_SALES_06__c=5466.00, PREVIOUS_SALES_07__c=6808.00, 
                                                                            PREVIOUS_SALES_08__c=3309.00, PREVIOUS_SALES_09__c=3772.00, PREVIOUS_SALES_10__c=5502.00, PREVIOUS_SALES_11__c=5596.00, 
                                                                            PREVIOUS_SALES_12__c=3383.00, PREVIOUS_UNITS_01__c=96.00, PREVIOUS_UNITS_02__c=136.00, PREVIOUS_UNITS_03__c=44.00, 
                                                                            PREVIOUS_UNITS_04__c=80.00, PREVIOUS_UNITS_05__c=27.00, PREVIOUS_UNITS_06__c=76.00, PREVIOUS_UNITS_07__c=112.00, 
                                                                            PREVIOUS_UNITS_08__c=44.00, PREVIOUS_UNITS_09__c=130.00, PREVIOUS_UNITS_10__c=30.00, PREVIOUS_UNITS_11__c=128.00, 
                                                                            PREVIOUS_UNITS_12__c=21.00, DIFF_SALES_01__c=-2140.00, DIFF_SALES_02__c=1994.00, DIFF_SALES_03__c=429.00, 
                                                                            DIFF_SALES_04__c=-2010.00, DIFF_SALES_05__c=756.00, DIFF_SALES_06__c=1217.00, DIFF_SALES_07__c=-3841.00, DIFF_SALES_08__c=49.00, 
                                                                            DIFF_SALES_09__c=4223.00, DIFF_SALES_10__c=984.00, DIFF_SALES_11__c=2377.00, DIFF_SALES_12__c=672.00, DIFF_UNITS_01__c=-59.00, 
                                                                            DIFF_UNITS_02__c=30.00, DIFF_UNITS_03__c=-2.00, DIFF_UNITS_04__c=68.00, DIFF_UNITS_05__c=-42.00, DIFF_UNITS_06__c=25.00, 
                                                                            DIFF_UNITS_07__c=-72.00, DIFF_UNITS_08__c=54.00, DIFF_UNITS_09__c=-16.00, DIFF_UNITS_10__c=48.00, DIFF_UNITS_11__c=-48.00, 
                                                                            DIFF_UNITS_12__c=61.00, PERC_DIFF_SALES_01__c=-35.24, PERC_DIFF_SALES_02__c=29.22, PERC_DIFF_SALES_03__c=10.77, 
                                                                            PERC_DIFF_SALES_04__c=-27.51, PERC_DIFF_SALES_05__c=28.09, PERC_DIFF_SALES_06__c=22.27, PERC_DIFF_SALES_07__c=-56.42, 
                                                                            PERC_DIFF_SALES_08__c=1.49, PERC_DIFF_SALES_09__c=111.95, PERC_DIFF_SALES_10__c=17.89, PERC_DIFF_SALES_11__c=42.47, 
                                                                            PERC_DIFF_SALES_12__c=19.85, PERC_DIFF_UNITS_01__c=-61.46, PERC_DIFF_UNITS_02__c=22.06, PERC_DIFF_UNITS_03__c=-3.41, 
                                                                            PERC_DIFF_UNITS_04__c=85.00, PERC_DIFF_UNITS_05__c=25.93, PERC_DIFF_UNITS_06__c=32.89, PERC_DIFF_UNITS_07__c=-64.29, 
                                                                            PERC_DIFF_UNITS_08__c=122.47, PERC_DIFF_UNITS_09__c=-12.31, PERC_DIFF_UNITS_10__c=160.00, PERC_DIFF_UNITS_11__c=-37.50, 
                                                                            TOTAL_MAT_CURRENT_SALES__c=65428.00, TOTAL_MAT_PREVIOUS_SALES__c=60718.00, TOTAL_MAT_DIFF_SALES__c=4710.00, 
                                                                            TOTAL_MAT_P_DIFF_SALES__c=7.76, TOTAL_MAT_CURRENT_UNITS__c=1022.00, TOTAL_MAT_PREVIOUS_UNITS__c=924.00);
        lstSEUS.add(obj); 
        
        
        
        salesDataCont.lstSEUS = lstSEUS;
        salesDataCont.testQueryString= queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        
        salesDataCont.salesPresetAction = 'New';
        
        ZTS_EU_Sales_Presets__c salesPresets = new ZTS_EU_Sales_Presets__c();
        salesPresets.Name = 'Test Preset3';
        salesPresets.ZTS_EU_Selected_GLR_Type__c = 'BILL-TO';        
        salesPresets.ZTS_EU_Selected_Preferred_Time__c = 'MAT';
        
        salesDataCont.selectedMultiTherapeuticGrpOpt.add(new SelectOption('a1ci0000000Jsp8AAC','Biologicals Respiratory'));
        salesDataCont.selectedMultiProductOpt.add(new SelectOption('a1ci0000000JsrGAAS','TSV-2'));
        salesDataCont.selectedMultiProductOpt.add(new SelectOption('a1ci0000000Jt2nAAC','Inforce-3'));
        salesDataCont.selectedMultiSpeciesOpt.add(new SelectOption('Cattle','Cattle'));
        
        salesDataCont.salesPresets = salesPresets;
        
        //changing the execution context to do rest callout
        Test.startTest();
        // Added by  Kishore
        salesDataCont.isChildSelected = false;
         salesDataCont.accntParent = accounts[0];
        salesDataCont.queryAccData();
         // ===========
        salesDataCont.savePreferences();
        Test.stopTest();
        List<ZTS_EU_Sales_Presets__c> lstSalesPresets = [SELECT Id, Name ,ZTS_EU_Selected_Preferred_Brands__c, ZTS_EU_Selected_Preferred_Brands_Ids__c, ZTS_EU_Selected_Preferred_Species__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c FROM  ZTS_EU_Sales_Presets__c WHERE Name = 'Test Preset3' ];
        
        system.assertEquals('Biologicals Respiratory', lstSalesPresets[0].ZTS_EU_Selected_Preferred_Thera_Grps__c);
        system.assertEquals('TSV-2;Inforce-3', lstSalesPresets[0].ZTS_EU_Selected_Preferred_Brands__c);
        
        
        system.debug('##businessUnits:' + salesDataCont.therapeuticGroup);
        Integer intBusinessUnits = salesDataCont.getBusinessUnitsList().size(); 
        system.assertEquals(2, intBusinessUnits);        
        system.assertEquals(2, salesDataCont.getTherapeuticGrpList().size());   
        
    }
    
    //Used to set the mock framework to get response from static resources
    public static void setStaticResourceMock(String staticResourceName, Integer responseCode){ 
         //Added by Kishore
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' AND ZTS_EU_Market__c = 'United States' LIMIT 1];
        ApexPages.standardController cont =  new ApexPages.StandardController(accounts[0]);
        //====================
        StaticResourceCalloutMock objStaticResourceCalloutMock = new StaticResourceCalloutMock();
        objStaticResourceCalloutMock.setStaticResource(staticResourceName);
        objStaticResourceCalloutMock.setStatusCode(responseCode);
        objStaticResourceCalloutMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, objStaticResourceCalloutMock);  
        //Added by Kishore
          ZTS_US_IXHsalesDataReportingController salesDataCo = new ZTS_US_IXHsalesDataReportingController(cont);
       HttpRequest request = new HttpRequest();
        salesDataCo.getHTTPCalloutResponse(request);
        //===============
        
    } 
}