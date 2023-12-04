@isTest
private class Test_salesAnalysisDataFromExternalObject
{
    static testMethod void salesAnalysisFromExternalObjects() 
    {
    
    integer offsetsize = 10;
    integer limitsize = 10;
    boolean noParent = false;
    boolean isChildSelected =false;
    String selectedValue = 'L1';
    String selectedReport = 'UnitSales';
    
        list<IXH_IXH_SALES_ENRICHED_US__x> lstSalesEnrichedUS = new  list<IXH_IXH_SALES_ENRICHED_US__x>();
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
                                                                            TOTAL_CYTD_SALES__c=65428.00, TOTAL_PYTD_SALES__c=60718.00, TOTAL_YTD_DIFF_SALES__c=4710.00,
                                                                            TOTAL_YTD_P_DIFF_SALES__c=7.76, TOTAL_CYTD_UNITS__c=1022.00, TOTAL_PYTD_UNITS__c=924.00);
        lstSalesEnrichedUS.add(obj);       
        string queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        salesAnalysisDataFromExternalObject.queryData(queryString,lstSalesEnrichedUS,offsetsize,limitsize,noParent,isChildSelected,selectedValue,selectedReport);
        queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=MAT&accountType=SHIP-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        salesAnalysisDataFromExternalObject.queryData(queryString,lstSalesEnrichedUS,offsetsize,limitsize,noParent,isChildSelected,selectedValue,selectedReport) ;
        
        queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=YTD&accountType=BILL-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        salesAnalysisDataFromExternalObject.queryData(queryString,lstSalesEnrichedUS,offsetsize,limitsize,noParent,isChildSelected,selectedValue,selectedReport) ;
        queryString ='accountErpId=396864&aggregationLevel=ITEM&target=US&selectedMATYTD=YTD&accountType=SHIP-TO&accountAggregationLevel=CHILD&species=Animal&therapeuticGroupIds=1234&brandIds=1234';
        salesAnalysisDataFromExternalObject.queryData(queryString,lstSalesEnrichedUS,offsetsize,limitsize,noParent,isChildSelected,selectedValue,selectedReport) ;
    }  
}