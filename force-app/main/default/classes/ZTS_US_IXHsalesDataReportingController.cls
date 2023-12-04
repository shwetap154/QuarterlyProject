/*************************************************************************************
* Name          :    ZTS_US_IXHsalesDataReportingController
* Description   :    Controller for a Sales Analysis page
* Created By    :    Cognizant Technology Solutions (Abir Bhattacharya)
* Created Date  :    04-08-2014 

Modification Log
---------------------------------------------------------------------------------------
Developer           Date             Modification ID        Comments
---------------------------------------------------------------------------------------
Chelsea Paice       28-Jul-2021      1.1          Updating FAST report link parameter work (SC-008600)
Chanbasha Nbsk      07-Sep-2021      1.2          Updated the method 'getcreateDataTable' (SC-008850)
**************************************************************************************/

public with sharing class ZTS_US_IXHsalesDataReportingController {
    
    salesAnalysisDataFromExternalObject.SalesDataWrapper wrapperObj = new salesAnalysisDataFromExternalObject.SalesDataWrapper();
    integer totalRecs;
    integer OffsetSize;
    integer LimitSize;
    public Boolean isNext = false, isPrevious = false, onChildAccount=true;
    public static integer totalRecords = 0;
       
    public Account accntCurrent                                 {get;set;}
    public Account accntActual                                  {get;set;}
    public Account accnPrevious                                 {get;set;}
    public Account accntParent                                  {get;set;}
    public Account accntChild                                   {get;set;}
    public Id accntId                                           {get;set;}
    public String queryAccName                                  {get;set;}
    public String queryAccID                                    {get;set;}
    public String selectedAccnt                                 {get;set;}
    public String selectedTerr                                  {get;set;}
    public String selectedTherapeuticGrp                        {get;set;}
    public List<String> selectedMultiTherapeuticGrp             {get;set;}
    public List<String> selectedMultiProduct                    {get;set;}
    public List<String> selectedMultiSpecies                    {get;set;}
    public List<String> selectedMultiBusinessUnits              {get;set;}
    public List<SelectOption> selectedMultiTherapeuticGrpOpt    {get;set;}
    public List<SelectOption> listMultiTherapeuticGrp           {get;set;} // list of select options to be shown on left in case of preset
    public List<SelectOption> selectedMultiProductOpt           {get;set;}
    public List<SelectOption> selectedMultiSpeciesOpt           {get;set;}
    public List<SelectOption> selectedMultiBusinessUnitOpt      {get;set;}
    public String selectedProduct                               {get;set;}
    public String selectedSpecies                               {get;set;}
    public String selectedMATYTD                                {get;set;}
    public String selectedReport                                {get;set;}
    public String soqlQuery                                     {get;set;}
    List<Account> listChildAccnt;
    public Boolean parentAccntNotAvailable                      {get;set;}
    public Boolean isChildSelected                              {get;set;} // This variable will determine the type of Account selected
    public List<CustomSettSalesData> customSetList              {get;set;}
    public List<dataYTD> listdataYTD                            {get;set;}
    public String currencyISO                                  {get;set;} // This variable identifies the currency based on the Market
    public String currencyType                              {get;set;}
    public Map<String,List<String>> mapTotalSalesYTD ;
    public Map<String,List<String>> mapProdSalesYTD ;
    public Map<String,List<String>> mapUnitSalesYTD ;
    public Map<String,String> mapNoMonth ;
    public Map<String, String> dataNoMonthAPMap;
    public List<String> monthList{get;set;} 
    public boolean displayPopup {get; set;}
    public boolean displayErrPopup {get; set;}
    List<User> listUser;
    public ZTS_EU_Sales_Presets__c salesPresets {get; set;}
    public String selectedPreset{get;set;} 
    public String salesPresetAction{get;set;}
    Integer counter = 0;
    Map<String,Account> mapParentToChildValues = new Map<String, Account>();
    Map<Integer, String> monthAPMap;
    Map<Integer, Integer> tempMonthAPMap;
    public String apStartDate                                     {get;set;}
    Map<String, String> monthNumberMap;
    public List<String> monthAPList                             {get;set;} // This list will have the order in which to display the AP values
    public boolean noParent                                     {get;set;}
    public boolean toggleFlagParent                             {get;set;}
    public String selectedSalesType                             {get;set;}
    public Boolean ispopupErr                                   {get;set;}
    public Boolean isChild                                      {get;set;}
    public String selectedLevelValue                            {get;set;}  
    public List<Account> listAccnt;
    public Boolean toDisplayGross                               {get;set;}
    public boolean showFootNote                                 {get; set;}
    public boolean showProductPicklist                          {get; set;}
    public Account passAccount                                  {get;set;} // This will copy the current account id and use for passing a s aparameter +   A 
    public List<CustomSettSalesData> customSetListREST          {get;set;}
    
    //[Ali Mohammed:] - Map that contains the filter parameters 
    public Map<String, String> httpSvcFilterParamMap;
    //public boolean runningTest = false;
    public List<String> monthAPTitleList                             {get;set;} // This list will have the order in which to display the AP Title values
    public String prettyJSON                                    {get;set;}
    public Map<String, String> prodBrandMap;
    public Map<String, String> prodBUMap;
    public Map<String, String> prodThGrpMap;
    public Map<String, String> prodSpeciesMap;
    
    public String testTab;
    
    //Added by Abir
    public Boolean disableL1                                    {get;set;}
    public Boolean disableL2                                    {get;set;}
    public boolean noChild                                      {get;set;}
    public List<SelectOption> therapeuticGroup                  {get;set;}
    public List<selectOption> salesProductList                  {get;set;}
    public List<selectOption> salesProductSpecies               {get;set;}
    
    private boolean isDMLBeforeCallout;
    private Map<String, String> brandMap = null;
    private Map<String, String> thGrpMap = null;
    private Map<String, String> speciesMap = null;
    
    public String queryString;//Added by AjayKrishna Istarla-SC-008658 - Add this line
    public list<IXH_IXH_SALES_ENRICHED_US__x> lstSEUS; //Added by AjayKrishna Istarla-SC-008658 - Add this line
    public string testQueryString; //Added by AjayKrishna Istarla-SC-008658 - Add this line
    
    public ZTS_US_IXHsalesDataReportingController(ApexPages.StandardController controller) {
        isDMLbeforeCallout = false;
        totalRecs = 0;
        OffsetSize = 0;
        LimitSize = 10;
        displayErrPopup = false;
        noParent = false;
        noChild = false;
        ispopupErr = false;
        currencyISO = '';
        userPreference();
        Id accntIdQuery;
        selectedMATYTD = 'MAT';
        if (apexpages.currentpage().getparameters().containsKey('prod') && apexpages.currentpage().getparameters().get('prod') != 'undefined') {
            selectedReport = 'ProductSales';
        } else {
            selectedReport = 'TotalSales';
        }
        monthAPMap = new Map<Integer, String>();
        monthNumberMap = new Map<String, String>();
        monthAPList =  new List<String>();
        parentAccntNotAvailable =  false;
        selectedLevelValue ='CHILD'; // Set to 'Branch' to ensure initial page load gets this value, logic will alter the sales data based on 'Head Office' radio selection
        Account accntRec = (Account)controller.getrecord();
        
        //Harcoded for Testing: Abir (Must comment the line below for UAT movement)
        //accntRec.Id = Id.valueOf('001i000000zfkuRAAQ');
        //accntRec.Id = Id.valueOf('001i000000zfucu');
        
        httpSvcFilterParamMap = new Map<String, String>();
        
        prodBrandMap = new Map<String, String>();
        prodBUMap = new Map<String, String>();
        prodThGrpMap = new Map<String, String>();
        prodSpeciesMap = new Map<String, String>();
        accntId = accntRec.Id;
        
        
        //System.debug('****** Account Record ' + accntRec);
        
        List<Account> listAccnt = [Select Id, Name,ParentId, Parent.Name 
                                   from Account where Id =: accntRec.Id AND ZTS_EU_Market__c = 'United States']; 
        
        if (listAccnt == null || listAccnt.isEmpty())
        {
            return;
        }
        
        passAccount =listAccnt[0];
        //System.debug('passAccount-------'+passAccount);
        showFootNote = false;
        showProductPicklist = true;
        
        if(listAccnt != null && listAccnt.size()>0){
            
            selectedSalesType = System.label.ZTS_US_Bill_To; 
            toDisplayGross =true;  
            
            accntCurrent = listAccnt[0];
            accntActual = listAccnt[0];
            accnPrevious = null;
            
            List<Account> listParentAcc = [select Id, Name, ParentId,Parent.Name from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c = 'United States' limit 1];
            if(listParentAcc != null && listParentAcc.size() > 0){
                accntParent = listParentAcc[0];
            }else{
                accntParent = null;
                noParent = true;
            }
            
            accntChild = null;
            system.debug('## accntParent : ' + accntParent + ' noParent : ' + noParent + ' accntChild : ' + accntChild);
        }
        
        calculateLevelValues(accntRec);
        //selectedSalesType = 'Gross';
        if(accntCurrent.ParentId == null){
            parentAccntNotAvailable = true;
        }
        accntIdQuery = accntCurrent.Id;
        listChildAccnt = [Select Id, Name, ParentId, Parent.Name from Account where (ParentId =: accntIdQuery OR Id =: accntIdQuery) AND ZTS_EU_Market__c = 'United States'];
        //getcreateDataTable();
        
    }
    
    //Checked By Abir
    /***********
* Method name : queryAccData
* Description : This method is called for toggling parent and child account on clicking the link.
* Return Type : PageReference.
* Parameters : None.
***********/
    public PageReference queryAccData() {
        //to apply limit and offset for only parent account sales data
        //IF condiiton logic changes by Sreekanth to avoid null pointer exception on 03/28
        if(isChildSelected == false){
         onChildAccount = false;
                   }
        else if (isChildSelected == true)
        {
        onChildAccount = true;    
        }
        
        //system.debug('-------------------------accntParent: ' + accntParent);
        if(isChildSelected == false && (monthNumberMap == null || monthNumberMap.size() <= 0)){
        String accountParentId;
        if(!isNext){
        accountParentId = accntParent.Id;
        }
        else
        {
            accountParentId = passAccount.Id;
        }            
            accntParent =   [Select Id, Name,ParentId, Parent.Name
                             from Account where Id =: accountParentId];
                                                                    
        }
        
        selectedAccnt = queryAccName;
        
        if(!noParent){
            // When the child record is selected
            if(isChildSelected == true){
                accntCurrent = accntChild;
                
                if(mapParentToChildValues.containsKey(accntchild.Name)){
                    accntChild = mapParentToChildValues.get(accntchild.Name);
                }else{
                    accntchild = null;
                }
                if(counter != 0 && accntParent!= null){
                    accnPrevious = accntParent;
                }else{
                    accnPrevious = accntActual;
                    counter++;
                }
                List<Account> listParentAcc = [select Id, Name,ParentId, Parent.Name from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c = 'United States' limit 1];
                if(listParentAcc != null && listParentAcc.size() > 0){
                    accntParent = listParentAcc[0];
                }else{
                    accntParent = null;
                }
            }else {
                List<String> prodLevel = new List<String>{'Account'};
                    
                    if(accntParent != null){
                        mapParentToChildValues.put(accntParent.Name, accntCurrent);
                    }
                
                accnPrevious = accntchild;
                accntchild = accntCurrent;
                if(isNext || isPrevious){
                    accntCurrent = passAccount;
                }else{
                    accntCurrent = accntParent;
                }
                List<Account> listParentAcc = [select Id, Name,ParentId, Parent.Name from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c = 'United States' limit 1];
                if(listParentAcc != null && listParentAcc.size() > 0){
                    accntParent = listParentAcc[0];
                }else{
                     accntParent = null;
                }
            }
        }else{
            if(toggleFlagParent == true){ toggleFlagParent = false;}
            else { toggleFlagParent = true;}
        }
        
        getcreateDataTable();
        return null;
    }
    
    
    /***********
* Method name : getcreateDataTable
* Description : This method is responsible for populating the values in the table.
* Return Type : List<CustomSettSalesData>.
* Parameters : None.
***********/
    public void getcreateDataTable(){
        if (accntCurrent == null) return;
        customSetList = new List<CustomSettSalesData>();
        
        selectedAccnt = accntCurrent.Name;
        try{
            selectedProductVal(); //Added by AjayKrishna Istarla-SC-008600
            customSetList = getSalesDataFromIXH();
            //Below part has been commented by Chanbasha for SC-008850
            /* if(brandMap == null || brandMap.size() == 0){
brandMap = prodBrandMap.clone();    
}

if(thGrpMap == null || thGrpMap.size() == 0){
thGrpMap = prodThGrpMap.clone();                
}

if(speciesMap == null || speciesMap.size() == 0){
speciesMap = prodSpeciesMap.clone();                
}*/
            
            system.debug('---Inside method getcreateDataTable -----------');
            //Below part has been added by Chanbasha for SC-008850
            brandMap = prodBrandMap.clone(); 
            thGrpMap = prodThGrpMap.clone();
            speciesMap = prodSpeciesMap.clone();
            
            system.debug('##customSetList : ' + customSetList);
            
            
        }
        catch(Exception e){
            system.debug('Error Occurred: Line Number:' + e.getLineNumber() + ' Cause: ' + e.getCause() + ' Message: ' + e.getMessage() +' StackTrace: ' + e.getStackTraceString());
        }
        //system.debug('Exiting : getCreateDataTable');
    }
    
    /* Added by AjayKrishna Istarla-SC-008600- Start */
    /***********
* Method name : selectedProductVal
* Description : This will select product passed in url parameter
* Return Type : Void
* Parameters : None
***********/
    public void selectedProductVal(){   
        String strProductNameFromURL = '';
        String strDecocedURL = ''; 
        List<ZTS_EU_Species_Product__c> lstProductHeirarchy = new List<ZTS_EU_Species_Product__c>();
        
        if(apexpages.currentpage().getparameters() != null && apexpages.currentpage().getparameters().containskey('prod')
           && apexpages.currentpage().getparameters().get('prod') != null && apexpages.currentpage().getparameters().get('prod') != 'undefined' )
        {
            strProductNameFromURL = apexpages.currentpage().getparameters().get('prod');
            system.debug('found parameter: ' + strProductNameFromURL);
            strDecocedURL = EncodingUtil.urlDecode(strProductNameFromURL, 'UTF-8');
            
            lstProductHeirarchy = [Select Id 
                                   from ZTS_EU_Species_Product__c 
                                   where ZTS_Hierarchy_Level__c = 'Brand' 
                                   And Name =:strDecocedURL];
            system.debug('lstProductHeirarchy: ' + lstProductHeirarchy);
            
            if(!lstProductHeirarchy.isEmpty())
            {
                selectedProduct  = lstProductHeirarchy[0].Id;
                system.debug('selected product: ' + selectedProduct);
            }
        }
        
    }
    /* Added by AjayKrishna Istarla-SC-008600--- END */ 
    
    /***********
* Method name : getSalesDataFromIXH
* Description : This method is responsible for showing the data in the grid according to business logic. 
* This data is retrieved by calling the REST service rather than querying Salesforce DB.
* Return Type : List<CustomSettSalesData>.
* Parameters : None.
***********/
    public List<CustomSettSalesData> getSalesDataFromIXH()
    {
        //system.debug('======================= Entered getSalesDataFromRESTCall =======================\n');
        List<String> prodLevel;
        Set<Id> accntIds = new Set<Id>();
        List<CustomSettSalesData> listCustomSettSalesData = new List<CustomSettSalesData>();
        //boolean checkparentaccount = accntParent != null ? true : false;
        
        
        List<ActualSalesDataValue> listAccntSalesDataValue;
        
        Map<Id, String> mapAccntIdAccntName =  new Map<Id, String>();
        Map<Id, String> mapAccntIdNarcId =  new Map<Id, String>();
        
        Map<String, Decimal> currentSumMap = new Map<String,Decimal>();
        Map<String, Decimal> prevSumMap = new Map<String, Decimal>();
        Map<String, Decimal> diffSumMap = new Map<String, Decimal>();
        
        List<SalesDataRestClientHelperUS.SalesItems> saleItemListByAccount;
        List< SalesDataRestClientHelperUS.SalesItems > salesItemsList = new List< SalesDataRestClientHelperUS.SalesItems >();
        
        Integer salesRecordCount = 0;
        
        if(queryAccID != null && queryAccID != ''){
            accntIds.add((ID)queryAccID);
        }
        
        if(accntCurrent == null){ 
            accntIds.add(queryAccId);
            
            
            
            
        }else{
            accntIds.add(accntCurrent.Id);
        }
        
        //Use the named credential to connect to remote server
        //String namedCredential = 'MiB_Sales_Inbound_Service_QA';
        string namedCredential = 'MiB_Sales_Inbound_Service_Prod';
        String accountNARCId; 
        for( Account acc : [ SELECT Id, ZTS_US_NARC_Id__c FROM Account WHERE Id = :accntIds.iterator().next() ] )  accountNARCId = acc.ZTS_US_NARC_Id__c;
        
        //Initialize the filter map and build new
        httpSvcFilterParamMap.clear();
        //httpSvcFilterParamMap.put('accountId', (String)accntIds.iterator().next());
        httpSvcFilterParamMap.put('accountErpId', accountNARCId);
        buildHttpSvcParamMap();
        
        HttpRequest request = buildHttpRequest(namedCredential, httpSvcFilterParamMap);
        //system.debug('##request : ' + request);
        
        HTTPResponse response;// = getHTTPCalloutResponse(request); //Added by AjayKrishna Istarla-SC-008658 - Disabled the json call
        //system.debug('##response : ' + response);
        system.debug('##queryString : ' + queryString);
        
        String strSalesDataFromRestCall;
        //if(response != null //Added by AjayKrishna Istarla-SC-008658 
        system.debug('lstSEUS from3 ===='+lstSEUS);
        if(queryString!=null) //Added by AjayKrishna Istarla-SC-008658 
        {
            //strSalesDataFromRestCall  = response.getBody(); //Added by AjayKrishna Istarla-SC-008658 - Disabled the json call    
            if(!Test.isRunningTest())
            {
                lstSEUS = null;                
            }
            if(Test.isRunningTest())
            {
                queryString = testQueryString;                
            }
            
            system.debug('testQueryString===='+testQueryString);
            system.debug('queryStringTest===='+queryString);
            system.debug('lstSEUS from ===='+lstSEUS);
            wrapperObj = salesAnalysisDataFromExternalObject.queryData(queryString,lstSEUS,OffsetSize,LimitSize,noParent,onChildAccount,selectedLevelValue,selectedReport);   //Added by AjayKrishna Istarla-SC-008658 - Changed the connection                   
            strSalesDataFromRestCall = wrapperObj.externalObjResponse;
            prodBrandMap.clear();
            prodThGrpMap.clear();
            prodSpeciesMap.clear();
        }
        /*else if(runningTest){
if(selectedReport == 'TotalSales'){
strSalesDataFromRestCall = jsonProductSales;
}else if(selectedReport == 'ProductSales'){    
strSalesDataFromRestCall = jsonProductSales;
}else if(selectedReport == 'UnitSales'){
strSalesDataFromRestCall = jsonProductSales;
}
//system.debug('Rest Response: ' + strSalesDataFromRestCall);
}*/
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
            //system.debug('Service did not return any data for this account');
            return null;              
        }
        
        
        //System.debug('##Returned data from REST Service: ' + strSalesDataFromRestCall);
        
        
        SalesDataRestClientHelperUS salesDataHelper = new SalesDataRestClientHelperUS(System.JSON.createParser(strSalesDataFromRestCall));          
        salesItemsList =  salesDataHelper.salesItems;
        
        system.debug('No of Sales Items returned: ' + salesItemsList.size());
        System.debug('##Returned data from REST Service: ' + strSalesDataFromRestCall);
        // system.debug('=======================salesItems: '+ salesItemsList+'\n');
        
        //this line below is only needed for testing the json result from service call. Not needed in production
        //            prettyJSON = System.JSON.serializePretty(salesDataHelper);
        //            system.debug('=======================prettyJSON: '+ prettyJSON+'\n');
        
        Map < String, List<SalesDataRestClientHelperUS.SalesItems>> accountSalesItemsMap = new Map<String, List<SalesDataRestClientHelperUS.SalesItems>>();
        String accCRMKey;
        String Salesdate;
        //setup currency symbol:
        if(salesItemsList != null && salesItemsList.size() > 0){
            //setCurrencySymbol(salesItemsList[0].account.currencyIsoCode);
            //Setting currency type as Dollars
            currencyType = '$';
            apStartDate = salesItemsList[0].asOfDate;
            //apStartDate = Date.parse(Salesdate);
            //Retrieve AP Names from ServiceResult and update MonthList with it
            //Can't be sure if the records will always be in sequence so create a map and then add them to list.
            //Change Detected Abir
            
            Map<Integer, String> mapAPNames = new Map<Integer, String>();
            for(SalesDataRestClientHelperUS.SalesRecords record : salesItemsList[0].salesRecords){
                mapAPNames.put(record.period, record.accountingPeriod);
            }
            monthAPTitleList = new List<String>();
            for(Integer i=1; i<=12; i++){
                monthAPTitleList.add(mapAPNames.get(i));
            }
            
            /*if(selectedMATYTD != 'YTD'){
Map<Integer, String> mapAPNames = new Map<Integer, String>();
for(SalesDataRestClientHelperUS.SalesRecords record : salesItemsList[0].salesRecords){
mapAPNames.put(record.period, record.accountingPeriod);
}
monthAPTitleList = new List<String>();
for(Integer i=1; i<=12; i++){
monthAPTitleList.add(mapAPNames.get(i));
}
}
else{
monthAPTitleList = new List<String>{'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
//Commented by Abir
// for(Integer i=1; i<=12; i++){
// monthAPTitleList.add('AP-' + i);
// }

} */           
            //system.debug('monthAPTitleList: ' + monthAPTitleList);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No data returned'));
            //System.debug('No sales data returned from the service for this account');
            return null;
            
        }
        
        for(SalesDataRestClientHelperUS.SalesItems salesItem : salesItemsList){
            accCRMKey = salesItem.account.crmTechnicalKey;
            mapAccntIdAccntName.put(accCRMKey, salesItem.account.businessName);
            mapAccntIdNarcId.put(accCRMKey, salesItem.account.erpBusinessKey);
            if(accountSalesItemsMap.get(accCRMKey) == null){
                List<SalesDataRestClientHelperUS.SalesItems> itemList = new List<SalesDataRestClientHelperUS.SalesItems>();
                itemList.add(salesItem);
                accountSalesItemsMap.put(accCRMKey, itemList);
            }
            else{
                accountSalesItemsMap.get(accCRMKey).add(salesItem); 
            }
        }
        system.debug('accountSalesItemsMap: ' + accountSalesItemsMap);
        for(Id oaccntId : accountSalesItemsMap.keySet()){
            
            //Initialize data structures
            //
            String accName ;            
            String accId ;
            String narcId;
            SalesDataRestClientHelperUS.SalesItems saleItem;
            saleItemListByAccount = accountSalesItemsMap.get(oaccntId);
            CustomSettSalesData oCustomSettSalesData;
            Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
            Map<String, List<Double>> mapSalesDataTotal = new Map<String, List<Double>>();
            mapSalesDataTotal.put(System.label.ZTS_US_Current_Year, null);
            mapSalesDataTotal.put(System.label.ZTS_US_Previous_Year, null);
            mapSalesDataTotal.put(System.label.ZTS_US_Diff_Sales, null);
            mapSalesDataTotal.put('%'+System.label.ZTS_US_Diff_Sales, null);
            listAccntSalesDataValue = new List<ActualSalesDataValue>();
            ActualSalesDataValue oAccntSalesDV;
            accName = mapAccntIdAccntName.get(oaccntId);
            narcId = mapAccntIdNarcId.get(oaccntId);
            accId = oaccntId ;
            List<String> oaccntSalesData1total = new List<String>();
            List<String> oaccntSalesData2total = new List<String>();
            List<String> oaccntSalesData3total = new List<String>();
            List<String> oaccntSalesData4total = new List<String>();
            List<String> oaccntSalesData5total = new List<String>();
            List<String> oaccntSalesData6total = new List<String>();
            List<String> oaccntSalesData7total = new List<String>();
            List<String> oaccntSalesData8total = new List<String>();
            List<String> oaccntSalesData9total = new List<String>();
            List<String> oaccntSalesData10total = new List<String>();
            List<String> oaccntSalesData11total = new List<String>();
            List<String> oaccntSalesData12total = new List<String>();
            List<String> oaccntSalesData13total = new List<String>();
            List<String> oaccntSalesData14total = new List<String>();
            //System.debug( '======================= Tab Selected ' + selectedReport + ' =======================');
            
            for(SalesDataRestClientHelperUS.SalesItems osalesData : saleItemListByAccount){
                
                String productName = '';
                
                //Get the count of salesrecords in the list. In YTD scenario, there may not be all 12 records returned.
                salesRecordCount = osalesData.salesRecords.size();
                
                updateProductHierarchyMaps(osalesData);
                
                //if UnitSales tab is selected
                if(selectedReport == 'UnitSales')
                {
                    List<String> oaccntSalesData1a = new List<String>{getProductHierarchyValueByKey('THERAPEUTIC_GROUP', osalesData)};
                        List<String> oaccntSalesData1b = new List<String>{getProductHierarchyValueByKey('BRAND', osalesData)};
                            if(osalesData.product != null && osalesData.product.productName != null)
                            productName = osalesData.product.productName;
                    //else
                    //  productName = 'Not returned by service';
                    List<String> oaccntSalesData1c = new List<String>{productName};
                        List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_US_Current_Year,System.label.ZTS_US_Previous_Year};
                            List<String> oaccntSalesData2;
                    
                    oaccntSalesData2 = new List<String>{String.valueOf(osalesData.totalSalesRecord.currentYearUnitTotal),String.valueOf(osalesData.totalSalesRecord.previousYearUnitTotal)};
                        if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                            currentSumMap.put('total',osalesData.totalSalesRecord.currentYearUnitTotal);
                            prevSumMap.put('total',osalesData.totalSalesRecord.previousYearUnitTotal);
                        }else{
                            Decimal currVal = currentSumMap.get('total') + osalesData.totalSalesRecord.currentYearUnitTotal;
                            Decimal prevVal = prevSumMap.get('total') + osalesData.totalSalesRecord.previousYearUnitTotal;
                            currentSumMap.put('total', currVal);
                            prevSumMap.put('total', prevVal);
                        }
                    // Calculate sum of current and previous values for all sales records
                    // List<List<String>> oaccntSalesDataList = new List<List<String>>();
                    Map<String, List<String>> monthNoValueMap = new Map<String, List<String>>();
                    List<String> fieldValueList ;
                    
                    for(Integer i=0; i<salesRecordCount; i++){
                        //Build SUM for current and previous units sold
                        if(!currentSumMap.containsKey(String.valueOf(i)) && !prevSumMap.containsKey(String.valueOf(i))){
                            currentSumMap.put(String.valueOf(i),osalesData.salesRecords[i].currentUnits);
                            prevSumMap.put(String.valueOf(i),osalesData.salesRecords[i].previousUnits);
                        }else{
                            Decimal currVal = currentSumMap.get(String.valueOf(i)) + osalesData.salesRecords[i].currentUnits;
                            Decimal prevVal = prevSumMap.get(String.valueOf(i)) + osalesData.salesRecords[i].previousUnits;
                            currentSumMap.put(String.valueOf(i), currVal);
                            prevSumMap.put(String.valueOf(i), prevVal);
                        }
                        // Build the list of current and previous units sold that will be displayed in UI grid
                        fieldValueList = new List<String>{String.valueOf(osalesData.salesRecords[i].currentUnits.format()),String.valueOf(osalesData.salesRecords[i].previousUnits.format())};
                            //oaccntSalesDataList.add(fieldValueList);
                            monthNoValueMap.put(String.valueOf(i),fieldValueList);
                        //system.debug('------------values in here----: ' +i+'---'+ fieldValueList);
                    }
                    
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<=12; cnt++){                                    
                            monthNoValueMap.put(String.valueOf(cnt),new List<String>());
                        }
                    }                                       
                    
                    
                    //system.debug('------------------monthNumberMap values here: ' + monthNoValueMap.get('0')+'---'+monthNoValueMap.get('1'));
                    //system.debug('------------------monthNumberMap values here: ' + monthNoValueMap.get('2')+'---'+monthNoValueMap.get('3'));
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1c,oaccntSalesData1,oaccntSalesData2,monthNoValueMap.get('0'),
                                                             monthNoValueMap.get('1'),monthNoValueMap.get('2'),monthNoValueMap.get('3'),monthNoValueMap.get('4'),
                                                             monthNoValueMap.get('5'),monthNoValueMap.get('6'),monthNoValueMap.get('7'),monthNoValueMap.get('8'),
                                                             monthNoValueMap.get('9'),monthNoValueMap.get('10'),monthNoValueMap.get('11'));
                    listAccntSalesDataValue.add(oAccntSalesDV);
                    
                    
                }
                //if TotalSales tab is selected
                else if(selectedReport == 'TotalSales'){                
                    // new code added
                    //System.debug( '======================= Entering Total Sales Section =======================');
                    List<Double> listIntCurrent = mapSalesDataTotal.get(System.label.ZTS_US_Current_Year);
                    List<Double> listIntPrior = mapSalesDataTotal.get(System.label.ZTS_US_Previous_Year);
                    List<Double> listIntDollDiff = mapSalesDataTotal.get(System.label.ZTS_US_Diff_Sales);
                    List<Double> listIntPerDiff = mapSalesDataTotal.get('%'+System.label.ZTS_US_Diff_Sales);
                    Double intCurrent = osalesData.totalSalesRecord.currentYearSalesTotal;
                    Double intPrior = osalesData.totalSalesRecord.previousYearSalesTotal;
                    Double intDollDiff = osalesData.totalSalesRecord.diffSalesTotal;
                    Double intPerDiff = osalesData.totalSalesRecord.percDiffSalesTotal;
                    
                    
                    //System.debug( '======================= Total Sales Numbers =======================');
                    //System.debug('intCurrent: ' + intCurrent + '\n' + 'listIntPrior: ' + listIntPrior + '\n' 
                    //             + 'listIntDollDiff: ' + listIntDollDiff + '\n' + 'listIntPerDiff: ' + listIntPerDiff + '\n' );
                    
                    SalesDataRestClientHelperUS.SalesRecords currRec;
                    
                    if(listIntCurrent == null){
                        listIntCurrent = new List<Double>();
                        listIntCurrent.add(intCurrent);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listIntCurrent.add(currRec.currentSales);
                            }
                        }
                    }                                  
                    else {
                        List<Double> listTemp = new List<Double>();
                        listTemp.add(listIntCurrent[0] + intCurrent);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listTemp.add(listIntCurrent[cnt+1] + currRec.currentSales);
                            }
                        }
                        listIntCurrent.clear();
                        listIntCurrent = listTemp;
                    }
                    
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listIntCurrent.add(0);
                        }
                    }
                    mapSalesDataTotal.put(System.label.ZTS_US_Current_Year,listIntCurrent);              
                    
                    if(listIntPrior == null){
                        listIntPrior = new List<Double>();
                        listIntPrior.add(intPrior);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listIntPrior.add(currRec.previousSales);
                            }
                        }
                    }                                  
                    else {
                        List<Double> listTemp = new List<Double>();
                        listTemp.add(listIntPrior[0] + intPrior);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listTemp.add(listIntPrior[cnt+1] + currRec.previousSales);
                            }
                        }
                        listIntPrior.clear();
                        listIntPrior = listTemp;
                    }
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listIntPrior.add(0);
                        }
                    }
                    mapSalesDataTotal.put(System.label.ZTS_US_Previous_Year,listIntPrior); 
                    
                    if(listIntDollDiff == null){
                        listIntDollDiff = new List<Double>();
                        listIntDollDiff.add(intPrior);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listIntDollDiff.add(currRec.diffSales);
                            }
                        }
                    }                                  
                    else {
                        List<Double> listTemp = new List<Double>();
                        listTemp.add(listIntPrior[0] + intPrior);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listTemp.add(listIntDollDiff[cnt+1] + currRec.diffSales);
                            }
                        }
                        listIntDollDiff.clear();
                        listIntDollDiff = listTemp;
                    }
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listIntDollDiff.add(0);
                        }
                    }
                    mapSalesDataTotal.put(System.label.ZTS_US_Diff_Sales,listIntDollDiff); 
                    
                    
                    if(listIntPerDiff == null){
                        listIntPerDiff = new List<Double>();
                        listIntPerDiff.add(intPerDiff);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listIntPerDiff.add(currRec.percDiffSales);
                            }
                            
                        }
                    }                                  
                    else {
                        List<Double> listTemp = new List<Double>();
                        listTemp.add(listIntPrior[0] + intPerDiff);
                        for(Integer cnt=0; cnt<salesRecordCount; cnt++){
                            currRec = osalesData.salesRecords[cnt];
                            if(currRec != null){
                                listTemp.add(listIntPerDiff[cnt+1] + currRec.percDiffSales);
                            }
                        }
                        listIntPerDiff.clear();
                        listIntPerDiff = listTemp;
                    }
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listIntPerDiff.add(0);
                        }
                    }
                    mapSalesDataTotal.put('%' + System.label.ZTS_US_Diff_Sales,listIntPerDiff); 
                    //System.debug('Entering second if condition for TotalSales');
                    List<String> listStr = new List<String>{System.label.ZTS_US_Current_Year,System.label.ZTS_US_Previous_Year,System.label.ZTS_US_Diff_Sales,'%'+System.label.ZTS_US_Diff_Sales};
                        Map<String, List<String>> monthNoValueMap = new Map<String, List<String>>();
                    List< List<String> > listOfoaccntSalesDataTotals = new List< List<String>>();
                    listOfoaccntSalesDataTotals.add(oaccntSalesData2total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData3total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData4total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData5total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData6total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData7total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData8total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData9total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData10total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData11total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData12total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData13total);
                    listOfoaccntSalesDataTotals.add(oaccntSalesData14total);
                    
                    for(String oStr : listStr){
                        
                        String preStrAppend = '';
                        String postStrAppend = '';
                        oaccntSalesData1total.add(oStr);
                        if(oStr == '%'+System.label.ZTS_US_Diff_Sales){
                            postStrAppend = '%';                            
                        }
                        Integer tempTotal;
                        
                        for(integer i=0; i<=salesRecordCount; i++){
                            listOfoaccntSalesDataTotals[i].add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[i] != null ? mapSalesDataTotal.get(oStr)[i].format() : '')+postStrAppend);
                            
                        }
                    }
                    oaccntSalesData2total = new List<String>{String.valueOf(osalesData.totalSalesRecord.currentYearSalesTotal.format()),String.valueOf(osalesData.totalSalesRecord.previousYearSalesTotal.format()), String.valueOf(osalesData.totalSalesRecord.diffSalesTotal.format()),String.valueOf(osalesData.totalSalesRecord.percDiffSalesTotal.format())+'%'};
                        if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                            currentSumMap.put('total',osalesData.totalSalesRecord.currentYearSalesTotal);
                            prevSumMap.put('total',osalesData.totalSalesRecord.previousYearSalesTotal);
                            diffSumMap.put('total',osalesData.totalSalesRecord.diffSalesTotal);
                        }else{
                            Decimal currVal = currentSumMap.get('total') + osalesData.totalSalesRecord.currentYearSalesTotal;
                            Decimal prevVal = prevSumMap.get('total') + osalesData.totalSalesRecord.previousYearSalesTotal;
                            Decimal diffVal = diffSumMap.get('total') + osalesData.totalSalesRecord.diffSalesTotal;
                            currentSumMap.put('total', currVal);
                            prevSumMap.put('total', prevVal);
                            diffSumMap.put('total',diffVal);
                        }
                    List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                    
                    
                    //system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())});                                               
                    }
                    
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                        }
                    }                                                
                    monthNoValueMap.put('1',oaccntSalesData3total);monthNoValueMap.put('2',oaccntSalesData4total);monthNoValueMap.put('3',oaccntSalesData5total);
                    monthNoValueMap.put('4',oaccntSalesData6total);monthNoValueMap.put('5',oaccntSalesData7total);monthNoValueMap.put('6',oaccntSalesData8total);
                    monthNoValueMap.put('7',oaccntSalesData9total);monthNoValueMap.put('8',oaccntSalesData10total);monthNoValueMap.put('9',oaccntSalesData11total);
                    monthNoValueMap.put('10',oaccntSalesData12total);monthNoValueMap.put('11',oaccntSalesData13total);monthNoValueMap.put('12',oaccntSalesData14total);
                    
                    // system.debug('------------------------ monthNoValueMap: ' + monthNoValueMap);
                    
                    
                    // System.debug('Creating ActualSalesDataValue object');
                    // system.debug('----------------monthNumberMap.get12: ' + monthNumberMap.get('12')+'\n'+oaccntSalesData14total);
                    
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1total,oaccntSalesData2total,oaccntSalesData3total,oaccntSalesData4total,oaccntSalesData5total,
                                                             oaccntSalesData6total,oaccntSalesData7total,oaccntSalesData8total,oaccntSalesData9total,oaccntSalesData10total,
                                                             oaccntSalesData11total,oaccntSalesData12total,oaccntSalesData13total,oaccntSalesData14total);
                    // system.debug('----------------------oAccntSalesDV: ' + oAccntSalesDV);
                    listAccntSalesDataValue.add(oAccntSalesDV);   
                    
                }
                
                //if ProductSales tab is selected
                else if(selectedReport == 'ProductSales'){
                    Double intCurrent = osalesData.totalSalesRecord.currentYearSalesTotal;
                    Double intPrior = osalesData.totalSalesRecord.previousYearSalesTotal;
                    Double intDollDiff = osalesData.totalSalesRecord.diffSalesTotal;
                    //Double intPerDiff = osalesData.totalSalesRecord.percDiffSalesTotal;
                    
                    List<String> oaccntSalesData1a = new List<String>{getProductHierarchyValueByKey('THERAPEUTIC_GROUP', osalesData)};
                        List<String> oaccntSalesData1b = new List<String>{getProductHierarchyValueByKey('BRAND', osalesData)};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_US_Current_Year,System.label.ZTS_US_Previous_Year,System.label.ZTS_US_Diff_Sales};
                                List<String> oaccntSalesData2;
                    oaccntSalesData2 = new List<String>{String.valueOf(osalesData.totalSalesRecord.currentYearSalesTotal.format()),String.valueOf(osalesData.totalSalesRecord.previousYearSalesTotal.format()), String.valueOf(osalesData.totalSalesRecord.diffSalesTotal.format())};
                        if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                            currentSumMap.put('total',osalesData.totalSalesRecord.currentYearSalesTotal);
                            prevSumMap.put('total',osalesData.totalSalesRecord.previousYearSalesTotal);
                            diffSumMap.put('total',osalesData.totalSalesRecord.diffSalesTotal);
                        }else{
                            Decimal currVal = currentSumMap.get('total') + osalesData.totalSalesRecord.currentYearSalesTotal;
                            Decimal prevVal = prevSumMap.get('total') + osalesData.totalSalesRecord.previousYearSalesTotal;
                            Decimal diffVal = diffSumMap.get('total') + osalesData.totalSalesRecord.diffSalesTotal;
                            currentSumMap.put('total', currVal);
                            prevSumMap.put('total', prevVal);
                            diffSumMap.put('total',diffVal);
                        }
                    
                    for(Integer i=0; i<salesRecordCount; i++){
                        //Build SUM for current and previous units sold
                        if(!currentSumMap.containsKey(String.valueOf(i)) && !prevSumMap.containsKey(String.valueOf(i))){
                            currentSumMap.put(String.valueOf(i),osalesData.salesRecords[i].currentSales);
                            prevSumMap.put(String.valueOf(i),osalesData.salesRecords[i].previousSales);
                            diffSumMap.put(String.valueOf(i),osalesData.salesRecords[i].diffSales);
                        }else{
                            Decimal currVal = currentSumMap.get(String.valueOf(i)) + osalesData.salesRecords[i].currentSales;
                            Decimal prevVal = prevSumMap.get(String.valueOf(i)) + osalesData.salesRecords[i].previousSales;
                            Decimal diffVal = diffSumMap.get(String.valueOf(i)) + osalesData.salesRecords[i].diffSales;
                            currentSumMap.put(String.valueOf(i), currVal);
                            prevSumMap.put(String.valueOf(i), prevVal);
                            diffSumMap.put(String.valueOf(i), diffVal);
                        }
                    }
                    
                    List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                    
                    
                    //system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())});                                                    
                    }
                    
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                        }
                    }                                                
                    
                    
                    
                    
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1,oaccntSalesData2,listOfoaccntSalesData[0], listOfoaccntSalesData[1],
                                                             listOfoaccntSalesData[2],listOfoaccntSalesData[3],listOfoaccntSalesData[4],listOfoaccntSalesData[5],listOfoaccntSalesData[6],listOfoaccntSalesData[7],
                                                             listOfoaccntSalesData[8],listOfoaccntSalesData[9],listOfoaccntSalesData[10],listOfoaccntSalesData[11]);
                    
                    
                    // system.debug('oaccntSalesData1a:- ' + oaccntSalesData1a);
                    // system.debug('oaccntSalesData1b:- ' + oaccntSalesData1b);
                    // system.debug('oaccntSalesData1:- ' + oaccntSalesData1);
                    // system.debug('oaccntSalesData2:- ' + oaccntSalesData2);
                    // system.debug('oAccntSalesDV:- ' + oAccntSalesDV);
                    
                    listAccntSalesDataValue.add(oAccntSalesDV);
                }     
                
            }
            
            oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue);            
            listCustomSettSalesData.add(oCustomSettSalesData);          
        }
        
        if(salesItemsList.size()>0){
            // my code here for total
            
            if(selectedReport == 'UnitSales'){
                List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                
                ActualSalesDataValue oAccntSalesDV;
                //system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                List<String> oaccntSalesData;
                for(integer i=0; i<salesRecordCount; i++){
                    
                    listOfoaccntSalesData.add(new List<String>{String.valueOf(currentSumMap.get(String.valueOf(i)).format()),String.valueOf(prevSumMap.get(String.valueOf(i)).format())});                                                    
                }
                
                if(salesRecordCount < 12){
                    for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                        listOfoaccntSalesData.add(new List<String>());
                    }
                }                                            
                List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_US_Total + ' ' + System.label.ZTS_US_Current_Year,System.label.ZTS_US_Total + ' ' + System.label.ZTS_US_Previous_Year};
                    
                    CustomSettSalesData oCustomSettSalesData;
                listdataYTD = new List<dataYTD>();
                Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
                
                oAccntSalesDV = new ActualSalesDataValue(null,null,null,oaccntSalesData1,new List<String>{String.valueOf(currentSumMap.get('total').format()),String.valueOf(prevSumMap.get('total').format())},
                                                         listOfoaccntSalesData[0],listOfoaccntSalesData[1],listOfoaccntSalesData[2],listOfoaccntSalesData[3],
                                                         listOfoaccntSalesData[4],listOfoaccntSalesData[5],listOfoaccntSalesData[6],listOfoaccntSalesData[7],
                                                         listOfoaccntSalesData[8],listOfoaccntSalesData[9],listOfoaccntSalesData[10],listOfoaccntSalesData[11]);
                listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
                    oCustomSettSalesData  = new CustomSettSalesData(null,null,null,listAccntSalesDataValue);
                listCustomSettSalesData.add(oCustomSettSalesData);
                
            }
            if(selectedReport == 'ProductSales'){
                List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                
                ActualSalesDataValue oAccntSalesDV;
                //system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                List<String> oaccntSalesData;
                for(integer i=0; i<salesRecordCount; i++){
                    
                    listOfoaccntSalesData.add(new List<String>{String.valueOf(currentSumMap.get(String.valueOf(i)).format()),String.valueOf(prevSumMap.get(String.valueOf(i)).format()),String.valueOf(DiffSumMap.get(String.valueOf(i)))});                                                    
                }
                
                if(salesRecordCount < 12){
                    for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                        listOfoaccntSalesData.add(new List<String>());
                    }
                }                                            
                List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_US_Total + ' ' + System.label.ZTS_US_Current_Year,System.label.ZTS_US_Total + ' ' + System.label.ZTS_US_Previous_Year,System.label.ZTS_US_Total + ' '+System.label.ZTS_US_Diff_Sales};
                    
                    CustomSettSalesData oCustomSettSalesData;
                listdataYTD = new List<dataYTD>();
                Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
                
                oAccntSalesDV = new ActualSalesDataValue(null,null,oaccntSalesData1,new List<String>{String.valueOf(currentSumMap.get('total').format()),String.valueOf(prevSumMap.get('total').format()),String.valueOf(diffSumMap.get('total').format())},
                                                         listOfoaccntSalesData[0],listOfoaccntSalesData[1],listOfoaccntSalesData[2],listOfoaccntSalesData[3],
                                                         listOfoaccntSalesData[4],listOfoaccntSalesData[5],listOfoaccntSalesData[6],listOfoaccntSalesData[7],
                                                         listOfoaccntSalesData[8],listOfoaccntSalesData[9],listOfoaccntSalesData[10],listOfoaccntSalesData[11]);
                listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
                    oCustomSettSalesData  = new CustomSettSalesData(null,null,null,listAccntSalesDataValue);
                listCustomSettSalesData.add(oCustomSettSalesData);
                
            }
            
        }
        system.debug('listCustomSettSalesData========='+listCustomSettSalesData);
        return listCustomSettSalesData;
    }
    
    /***********
* Method name : getProductHierarchyValueByKey
* Description : This method retrieves the product hierarchy values from the list based on the key.
* Return Type : String.
* Parameters :  key - attribute to be retrieved. e.g.: THERAPEUTIC GROUP or BRAND
*               productHierarchies - list of product hierarchies returned from the service call
***********/
    public String getProductHierarchyValueByKey(String key, SalesDataRestClientHelperUS.SalesItems oData){
        String value='';
        if(oData.product != null && oData.product.productHierarchies != null){
            for(SalesDataRestClientHelperUS.ProductHierarchies item : oData.product.productHierarchies){
                if(key == item.code){
                    value = item.name;
                    break;
                }
            }
        }
        return value;
    }
    
    /***********
* Method name : updateProductHierarchyMaps
* Description : This method strores all the Species, Therapeutic Group and Products in a map.
* Return Type : void.
* Parameters :  Sales Items
***********/
    public void updateProductHierarchyMaps(SalesDataRestClientHelperUS.SalesItems oData){
        
        String value='';
        String phId = '';
        String key = '';
        
        if(oData.product != null && oData.product.productHierarchies != null){
            //system.debug('##product: ' + oData.product);
            if(oData.product.species != null || oData.product.species != ''){
                //Used to add the species information
                //system.debug('##Species:' + oData.product.species);
                prodSpeciesMap.put(oData.product.species,oData.product.species);
            }
            for(SalesDataRestClientHelperUS.ProductHierarchies item : oData.product.productHierarchies){
                key = item.code;
                value = item.name;
                phId = item.crmTechnicalKey;
                system.debug('phId: ' + phId + ', value: ' + value);
                if(key == 'BRAND'){
                    prodBrandMap.put(phId, value);                                    
                }
                else if(key == 'BUSINESS_UNITS'){
                    prodBUMap.put(phId, value);
                }
                else if(key == 'THERAPEUTIC_GROUP'){
                    prodThGrpMap.put(phId, value); 
                }
            }
        }
        
    }
    
    
    /***********
* Method name : buildProductHierarchyFilterListOptions
* Description : This method is used to generate a list of SelectOption from Map required for building Picklist for Species, TherapeuticGroup, Products.
* Return Type : void.
* Parameters :  List of Select Option which has the header value(i.e. <Species>) as SelectOption, The map that needs to be concerted to SelectOption
***********/
    public List<selectoption> buildProductHierarchyFilterListOptions(List<selectoption> optionList, Map <String, String> paramMap){
        system.debug('paramMap==='+paramMap);
        Set<String> paramKeys = paramMap.keySet();
        String sep = '&';
        for(String key : paramKeys){
            optionList.add(new selectoption(key, paramMap.get(key)));
        }
        //System.debug('OptionList: ' + optionList);
        return optionList;        
    }
    
    
    /***********
* Method name : buildHttpSvcParamMap
* Description : This method creates the map of the filter parameters which is passed during the call to service.
* Return Type : void.
* Parameters : None.
***********/
    public void buildHttpSvcParamMap(){
        
        Map<String, String> reportTypeMap = new Map<String, String>();
        reportTypeMap.put('UnitSales', 'ITEM');
        reportTypeMap.put('ProductSales', 'PRODUCT');
        reportTypeMap.put('TotalSales', 'ACCOUNT');
        
        Map<String, String> salesTypeMap = new Map<String, String>();
        salesTypeMap.put(System.label.ZTS_US_Bill_To, 'BILL-TO');
        salesTypeMap.put(System.label.ZTS_US_Ship_To, 'SHIP-TO');
        
        
        //Waiting for service implementation to include these filter parameters
        httpSvcFilterParamMap.put('aggregationLevel', reportTypeMap.get(selectedReport));
        httpSvcFilterParamMap.put('target', 'US');
        
        if(selectedMATYTD == null || selectedMATYTD.length() == 0){
            selectedMATYTD = 'MAT';
        }
        
        httpSvcFilterParamMap.put('selectedMATYTD', selectedMATYTD);
        
        if(selectedSalesType == null || selectedSalesType.length() == 0){
            selectedSalesType = System.label.ZTS_US_Bill_To;
        }
        //system.debug('##selectedSalesType--' + selectedSalesType);
        httpSvcFilterParamMap.put('accountType', salesTypeMap.get(selectedSalesType));
        //system.debug('##selectedReport : ' + selectedReport);
        
        // Apply filters only when Product Sales or Unit Sales tab is selected
        if(selectedReport == 'UnitSales' || selectedReport == 'ProductSales'){
            if(selectedTherapeuticGrp != null && selectedTherapeuticGrp != '' && selectedTherapeuticGrp != '<Therapeutic Group>'){
                httpSvcFilterParamMap.put('therapeuticGroupIds', selectedTherapeuticGrp);
            }
            
            if(selectedProduct != null && selectedProduct != '' && selectedProduct != '<Product>') {
                httpSvcFilterParamMap.put('brandIds', selectedProduct);
            }
            
            system.debug('httpSvcFilterParamMap====='+httpSvcFilterParamMap);
            
            if(selectedSpecies != null && selectedSpecies != '' && selectedSpecies != '<Species>'){
                httpSvcFilterParamMap.put('species', selectedSpecies);
            }
            /*if Preset is selected, then apply these filters */
            //system.debug('##selectedPreset : ' + selectedPreset);            
            if(selectedPreset != '--None--' && !isDMLbeforeCallout){
                
                List<ZTS_EU_Sales_Presets__c> presets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Thera_Grps__c,ZTS_EU_Selected_Preferred_Species__c, ZTS_EU_Selected_Preferred_Brands__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c, ZTS_EU_Selected_Preferred_Brands_Ids__c, ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                if (!presets.isEmpty()) {
                    salesPresets = presets[0];
                    selectedMATYTD = salesPresets.ZTS_EU_Selected_Preferred_Time__c;
                    
                    if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c != Null){
                        httpSvcFilterParamMap.put('therapeuticGroupIds', salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c);
                    }
                    if(salesPresets.ZTS_EU_Selected_Preferred_Species__c != Null){
                        httpSvcFilterParamMap.put('species', salesPresets.ZTS_EU_Selected_Preferred_Species__c);
                    }
                    if(salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c != Null){
                        
                        httpSvcFilterParamMap.put('brandIds', salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c);
                    }
                }
            }
            
            if(selectedPreset != '--None--' && isDMLbeforeCallout){
                if(!string.isBlank(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c)){
                    httpSvcFilterParamMap.put('therapeuticGroupIds', salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c);
                }
                if(!string.isBlank(salesPresets.ZTS_EU_Selected_Preferred_Species__c)){
                    httpSvcFilterParamMap.put('species', salesPresets.ZTS_EU_Selected_Preferred_Species__c);
                }
                if(!string.isBlank(salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c)){
                    
                    httpSvcFilterParamMap.put('brandIds', salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c);
                }       
            }
            
            //system.debug('##httpSvcFilterParamMap : ' + httpSvcFilterParamMap);
            
        } // End Apply filters only when Product Sales or Unit Sales tab is selected
        
        //Start:Added by Abir to set the account Aggregation Level
        if(selectedLevelValue =='CHILD'){
            httpSvcFilterParamMap.put('accountAggregationLevel', 'CHILD');
        }else if(selectedLevelValue =='L1'){
            httpSvcFilterParamMap.put('accountAggregationLevel', 'L1');
        }else if(selectedLevelValue =='L2'){
            httpSvcFilterParamMap.put('accountAggregationLevel', 'L2');
        }else {
            httpSvcFilterParamMap.put('accountAggregationLevel', 'CHILD');
        }       
        //END
        
        //System.debug('Final Svc Params : ' + httpSvcFilterParamMap);
        
    }
    
    /***********
* Method name : buildHttpRequest
* Description : This method is responsible to building the HttpRequest object from the named credentials
* Return Type : HttpRequest.
* Parameters : It accepts a parameter map
***********/   
    public HttpRequest buildHttpRequest(String namedCred, Map<String, String> paramMap)
    {
        queryString = buildQueryString(paramMap);  //Added by AjayKrishna Istarla-SC-008658 - Declared on the top and remove declaration from here
        //queryString = EncodingUtil.urlEncode(queryString, 'UTF-8');
        //queryString = queryString.replace(' ', '%20');
        system.debug('queryString=============='+queryString);
        HttpRequest req = new HttpRequest();
        String endpointURL = 'callout:'  + namedCred + '/?' + queryString;
        System.debug('Endpoint URL: ' + endpointURL);
        req.setEndpoint(endpointURL);
        req.setMethod('POST');        
        return req;
    }
    
    
    /***********
* Method name : getHTTPCalloutResponse
* Description : This method is responsible to generate the callout request
* Return Type : HttpResponse.
* Parameters : It accepts an HttpRequest 
***********/
    public HTTPResponse getHTTPCalloutResponse(HttpRequest request)
    {   
        HTTPResponse response;
        Http http;
        try {
            //if(!runningTest){
            http = new Http();
            request.setTimeout(120000);
            response = http.send(request);
            //}
            
            //System.debug('Response returned: ' + response.getBody());
        } catch(Exception ex) {
            System.debug(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        }
        return response;
    }
    
    /***********
* Method name : buildQueryString
* Description : This method will build query from a parameter map.
* Return Type : String.
* Parameters : Paramter map contains key value of String type.
***********/
    public String buildQueryString(Map<String, String> paramMap){
        
        String queryString = '';
        Set<String> paramKeys = paramMap.keySet();
        String sep = '&';
        if(paramKeys.size() > 0){
            String key1 = paramKeys.iterator().next();
            queryString = key1 + '=' + paramMap.get(key1);
            paramKeys.remove(key1);
            for(String key : paramKeys){
                queryString += sep + key + '=' + paramMap.get(key);
            }
        }
        //System.debug('Query String: ' + queryString);
        return queryString;
    }
    
    
    
    /***********
* Method name : selectedValueQuery
* Description : This method will modify the query according to filter value selected.
* Return Type : None.
* Parameters : None.
***********/
    public void selectedValueQuery(){
        selectedPreset = '--None--';
        getcreateDataTable();
    }
    
    
    /***********
* Method name : multiSelectedValueQuery
* Description : This method will modify the query according to filter value selected.
* Return Type : None.
* Parameters : None.
***********/
    public void multiSelectedValueQuery(){
        selectedTherapeuticGrp = '<' + System.label.ZTS_US_Therapeutic_Group + '>';
        selectedProduct = '<' + System.label.ZTS_US_Product + '>';
        selectedSpecies = '<' + System.label.ZTS_US_Species + '>';
        
        if(selectedPreset == '--None--'){
            selectedMATYTD = 'MAT';
        }
        
        getcreateDataTable();
        
        if(isDMLbeforeCallout){
            
            if(salesPresetAction == 'New'){
                insert salesPresets;                    
            }
            if(salesPresetAction == 'Delete' && salesPresets != null){
                delete salesPresets;                    
            }
            if(salesPresetAction == 'Edit' && salesPresets != null){
                update salesPresets;                    
            }                           
            isDMLbeforeCallout =  false;
        }       
    }
    
    
    /***********
* Method name : getSalesPresetsData
* Description : This will get the sales preset data for a particular user 
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getSalesPresetsData() {
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesPreset = new Set<String>();
        
        options.add(new selectOption('--None--', '--None--'));
        for (ZTS_EU_Sales_Presets__c listSalesPresetData : [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Species__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() ORDER BY Name] ) {
             options.add(new selectOption(listSalesPresetData.name, listSalesPresetData.Name));               
        }
        return options; //return the picklist options
    }
    
    
    /***********
* Method name : getTherapeuticGrpList
* Description : This will create Therapeutic Group with values header values
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getTherapeuticGrpList() { 
        List<selectOption> options = new List<selectOption>(); 
        options.add(new selectOption('<Therapeutic Group>', '<' + System.label.ZTS_US_Therapeutic_Group + '>'));
        try{
            options.addAll(this.getTherapeuticGroupList());            
        }
        catch(Exception e){
            system.debug('Error: ' + e.getCause());
            system.debug('Error Message: ' + e.getMessage());
            system.debug('Error Line Number: ' + e.getLineNumber());
            system.debug('Error StackTrace: ' + e.getStackTraceString());
        }
        
        return options; //return the picklist options
        
    }
    
    /***********
* Method name : getTherapeuticGroupList
* Description : This will create Therapeutic Group with values.
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getTherapeuticGroupList() {         
        
        List<SelectOption> ddlTherapeuticItems = new List<SelectOption>();       
        
        try{
            
            ddlTherapeuticItems = buildProductHierarchyFilterListOptions(ddlTherapeuticItems, prodThGrpMap);
        }
        catch(Exception e){
            system.debug('Error: ' + e.getCause());
            system.debug('Error Message: ' + e.getMessage());
            system.debug('Error Line Number: ' + e.getLineNumber());
            system.debug('Error StackTrace: ' + e.getStackTraceString());
        }
        
        return ddlTherapeuticItems; //return the picklist options
        
    }
    
    /***********
* Method name : getSalesDataProdList
* Description : This will create Product filter values with header value
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getSalesDataProdList() {
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesDataProd = new Set<String>();
        options.add(new selectOption('<Product>', '<' + System.label.ZTS_US_Product + '>'));
        try{            
            options.addAll(this.getSalesProdList());       
        }
        catch(Exception e){
            system.debug('Error: ' + e.getCause());
            system.debug('Error Message: ' + e.getMessage());
            system.debug('Error Line Number: ' + e.getLineNumber());
            system.debug('Error StackTrace: ' + e.getStackTraceString());
        }
        return options; //return the picklist options
    }
    
    
    /***********
* Method name : getSalesProdList
* Description : This will create Product filter values.
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getSalesProdList() {
        // salesProductList = new List<selectOption>(); 
        List<SelectOption> ddlProductItems = new List<SelectOption>();
        
        try{                        
            ddlProductItems = buildProductHierarchyFilterListOptions(ddlProductItems, prodBrandMap);             
        }
        catch(Exception e){
            system.debug('Error: ' + e.getCause());
            system.debug('Error Message: ' + e.getMessage());
            system.debug('Error Line Number: ' + e.getLineNumber());
            system.debug('Error StackTrace: ' + e.getStackTraceString());
        }
        
        return ddlProductItems; //return the picklist options
    }
    
    /***********
* Method name : getSalesSpeciesList
* Description : This will create Sales Species with values.
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getSalesSpeciesList() { 
        
        List<SelectOption> ddlSpeciesItems = new List<SelectOption>();
        
        try{           
            ddlSpeciesItems = buildProductHierarchyFilterListOptions(ddlSpeciesItems, prodSpeciesMap);            
        }
        catch(Exception e){
            system.debug('Error: ' + e.getCause());
            system.debug('Error Message: ' + e.getMessage());
            system.debug('Error Line Number: ' + e.getLineNumber());
            system.debug('Error StackTrace: ' + e.getStackTraceString());
        }
        
        return ddlSpeciesItems; //return the picklist options
        
    }
    
    
    /***********
* Method name : getBusinessUnitsList
* Description : This will create Species filter values with header data
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<selectOption> getBusinessUnitsList() {
        
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setBusinessUnits = new Set<String>();
        List<String> allBUList;
        options.add(new selectOption('<Species>', '<Species>'));
        
        try{
            options.addAll(this.getSalesSpeciesList());           
        }
        catch(Exception e){
            system.debug('Error: ' + e.getCause());
            system.debug('Error Message: ' + e.getMessage());
            system.debug('Error Line Number: ' + e.getLineNumber());
            system.debug('Error StackTrace: ' + e.getStackTraceString());
        }
        
        return options; //return the picklist options
    }
    
    
    /***********
* Method name : getradioOptions1
* Description : This will create radio button values for MAT,YTD.
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<SelectOption> getradioOptions1() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('MAT','MAT'));
        options.add(new SelectOption('YTD','YTD'));
        return options;
    }
    
    /***********
* Method name : getradioOptions2
* Description : This will create radio button values for Bill-To,Ship-To.
* Return Type : List<selectOption>.
* Parameters : None.
***********/
    public List<SelectOption> getradioOptions2() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Bill-To',System.label.ZTS_US_Bill_To));
        options.add(new SelectOption('Ship-To',System.label.ZTS_US_Ship_To));
        return options;
    }
    
    
    /***********
* Method name : getradioOptions3
* Description : This will create radio button values for Aggregation of Records(Branch , HeadOffice)
* Return Type : List<selectOption>.
* Parameters : None.
***********/   
    public List<SelectOption> getradioOptions3() {
        List<SelectOption> options = new List<SelectOption>();
        if(disableL1){
            options.add(new SelectOption('CHILD',System.label.ZTS_US_CHILD));
        }else
            if(disableL2){
                options.add(new SelectOption('CHILD',System.label.ZTS_US_CHILD)); 
                options.add(new SelectOption('L1',System.label.ZTS_US_L1));
            }else {
                options.add(new SelectOption('CHILD',System.label.ZTS_US_CHILD)); 
                options.add(new SelectOption('L1',System.label.ZTS_US_L1)); 
                options.add(new SelectOption('L2',System.label.ZTS_US_L2)); 
            }
        return options;
    }
    
    /***********
* Method name : calculateLevelValues
* Description : This method will decide whether the account is child or parent record.
* Return Type : None.
* Parameters : Account.
* Author : Shefali Vinchurkar
***********/   
    public void calculateLevelValues(Account accntRec){
        disableL1 = true;
        disableL2 = true;
        if(accnPrevious != null && accnPrevious.Id != null && isChildSelected == false){
            listAccnt = [Select Id, ZTS_US_NARC_ID__c, (Select Id, Name from ChildAccounts where Id=:accntActual.ParentId) ,Name,ParentId, Parent.Name, Parent.ParentId from Account where Id =: accntRec.Id AND ZTS_EU_Market__c = 'United States'];
        }else{
            listAccnt = [Select Id, ZTS_US_NARC_ID__c, (Select Id, Name from ChildAccounts ) ,Name,ParentId, Parent.Name, Parent.ParentId from Account where Id =: accntRec.Id AND ZTS_EU_Market__c = 'United States'];
        }
        if(listAccnt != Null && listAccnt.size()>0){
            if(listAccnt[0].ChildAccounts != null && listAccnt[0].ChildAccounts.size()>0){
                noChild = false;
            }else {
                noChild = true;
            }
            
            if(listAccnt[0].ParentId != null){
                if(listAccnt[0].ChildAccounts != null && listAccnt[0].ChildAccounts.size() > 0 ){
                    disableL1 = false;
                }
            }else{
                if(listAccnt[0].ChildAccounts != null && listAccnt[0].ChildAccounts.size() > 0 ){
                    List<Account> grandChildAccList = [Select Id, Name from Account where ParentId IN: listAccnt[0].ChildAccounts AND ZTS_EU_Market__c = 'United States' limit 100];
                    if(grandChildAccList != null && grandChildAccList.size() > 0){
                        disableL1 = false;
                        disableL2 = false;
                    }else{
                        disableL1 = false;
                    }
                }
            }
        }
    }
    
    //Checked by Abir
    /***********
* Method name : generateUnitSalesPdf
* Description : This method is called for pdf functionality on UnitSales Tab.
* Return Type : pagereference.
* Parameters : None.
***********/
    public PageReference generateUnitSalesPdf(){
        PageReference  pg=new PageReference('/apex/ZTS_US_IXHUnitSalesPdf');
        pg.setRedirect(false);
        return  pg;
    }
    
    //Checked by Abir
    /***********
* Method name : DownloadUnitSalesExcel
* Description : This method is called for excel functionality on UnitSales Tab.
* Return Type : pagereference.
* Parameters : None.
***********/
    //Download Method to download Table Data in Excel Sheet
    public pagereference DownloadUnitSalesExcel(){
        PageReference pg=new PageReference('/apex/ZTS_US_IXHUnitSalesExcelDownload');
        pg.setRedirect(false);
        return  pg;
    }
    
    //Checked by Abir
    /***********
* Method name : generateProductSalesPdf
* Description : This method is called for pdf functionality on ProductSales Tab.
* Return Type : pagereference.
* Parameters : None.
***********/
    public PageReference generateProductSalesPdf(){
        PageReference  pg=new PageReference('/apex/ZTS_US_IXHProductSalesPdf');
        pg.setRedirect(false);
        return  pg;
    }
    
    //Checked By Abir
    /***********
* Method name : DownloadProductSalesExcel
* Description : This method is called for excel functionality on ProductSales Tab.
* Return Type : pagereference.
* Parameters : None.
***********/
    //Download Method to download Table Data in Excel Sheet
    public pagereference DownloadProductSalesExcel(){    
        PageReference pg=new PageReference('/apex/ZTS_US_IXHProductSalesExcelDownload');
        pg.setRedirect(false);
        return  pg;
    }
    
    //Checked By Abir
    /***********
* Method name : generateTotalSalesPdf
* Description : This method is called for pdf functionality on TotalSales Tab.
* Return Type : pagereference.
* Parameters : None.
***********/
    public PageReference generateTotalSalesPdf(){
        PageReference  pg=new PageReference('/apex/ZTS_US_IXHTotalSalesPdf');
        pg.setRedirect(false);
        return  pg;
    }
    
    //Checked By Abir
    /***********
* Method name : DownloadTotalSalesExcel
* Description : This method is called for excel functionality on TotalSales Tab.
* Return Type : pagereference.
* Parameters : None.
***********/
    //Download Method to download Table Data in Excel Sheet
    public pagereference DownloadTotalSalesExcel(){
        PageReference pg=new PageReference('/apex/ZTS_US_IXHTotalSalesExcelDownload');
        pg.setRedirect(false);
        return  pg;
    }
    
    
    /***********
* Method name : salesPreference
* Description : This method is called for preset functionality on TotalSales Tab.
* Return Type : None.
* Parameters : None.
***********/    
    public void salesPreference(){
        displayPopup = true;
        displayErrPopup = false;
        userPreference();
        updateProductHierarchyDetails();
    }
    
    
    /***********
* Method name : salesPreference
* Description : This method is used to update the Product Hierarchy details based on the selection
* Return Type : None.
* Parameters : None.
***********/
    private void updateProductHierarchyDetails(){
        
        //Start:Code to update the Species      
        salesProductSpecies = new List<selectOption>();     
        salesProductSpecies = buildProductHierarchyFilterListOptions(salesProductSpecies, speciesMap);           
        
        for(SelectOption slctOptn : selectedMultiSpeciesOpt){
            for(Integer index =0; index < salesProductSpecies.size(); index++){
                if(salesProductSpecies[index].getValue() == slctOptn.getValue()){
                    salesProductSpecies.remove(index);
                    break;
                }
            }
        }
        //End:Code to update the Species
        
        //Start:Code to update the Product  
        salesProductList = new List<selectOption>(); 
        salesProductList = buildProductHierarchyFilterListOptions(salesProductList, brandMap);   
        
        for(SelectOption slctOptn : selectedMultiProductOpt){
            for(Integer index =0; index < salesProductList.size(); index++){
                if(salesProductList[index].getValue() == slctOptn.getValue()){
                    salesProductList.remove(index);
                    break;
                }
            }
        }
        //END:Code to update the Product
        
        //Start:Code to update the Therapeutic Group
        therapeuticGroup = new List<selectOption>(); 
        therapeuticGroup = buildProductHierarchyFilterListOptions(therapeuticGroup, thGrpMap);
        
        for(SelectOption slctOptn : selectedMultiTherapeuticGrpOpt){
            for(Integer index =0; index < therapeuticGroup.size(); index++){
                if(therapeuticGroup[index].getValue() == slctOptn.getValue()){
                    therapeuticGroup.remove(index);
                    break;
                }
            }
        }
        //End:Code to update the Therapeutic Group
    }
    
    /***********
* Method name : userPreference
* Description : This method is called from salesPreference to perform business logic on the basis of sales preset action.
* Return Type : None.
* Parameters : None.
***********/    
    public void userPreference(){
        listMultiTherapeuticGrp = new List<SelectOption>();
        Set<string> setTherGrp = new Set<String>();
        
        selectedMultiTherapeuticGrpOpt = new List<SelectOption>();
        selectedMultiProductOpt = new List<SelectOption>();
        selectedMultiSpeciesOpt = new List<SelectOption>();
        List<String> selectedMultiTherapeuticGrp1 = new List<String>();
        List<String> selectedMultiProduct1 = new List<String>();
        Map<String,String> MultiTherapeuticGrp = new map<String,String>();
        Map<String,String> MultiProduct = new map<String,String>();
        
        if(selectedPreset != '--None--'){
            displayErrPopup = false;
            if(salesPresetAction == 'New'){
                salesPresets = new ZTS_EU_Sales_Presets__c();
                
            }
            if(salesPresetAction == 'Delete' || salesPresetAction == 'Edit'){
                salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c,ZTS_EU_Selected_Preferred_Brands_Ids__c, ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c,ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c,ZTS_EU_Selected_Preferred_Species__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                //system.debug('##SalesPresets; ' + salesPresets); 
                if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c != null && salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c != null){
                    selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                    selectedMultiTherapeuticGrp1 = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c.split(';');
                    if(selectedMultiTherapeuticGrp1 != Null && selectedMultiTherapeuticGrp1.size()>0){                  
                        for (integer i = 0; i < selectedMultiTherapeuticGrp1.size(); i++) {
                            MultiTherapeuticGrp.put(selectedMultiTherapeuticGrp1.get(i), selectedMultiTherapeuticGrp.get(i));
                        }
                        selectedMultiTherapeuticGrpOpt = listSelOptPopulate1(MultiTherapeuticGrp);
                    }
                }
                
                if(salesPresets.ZTS_EU_Selected_Preferred_Brands__c != null && salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c != null){
                    selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                    selectedMultiProduct1 = salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c.split(';');
                    if(selectedMultiProduct1 != Null && selectedMultiProduct1.size()>0){
                        for (integer i = 0; i < selectedMultiProduct1.size(); i++) {
                            MultiProduct.put(selectedMultiProduct1.get(i), selectedMultiProduct.get(i));
                        }
                        selectedMultiProductOpt = listSelOptPopulate1(MultiProduct);
                    }    
                }
                if(salesPresets.ZTS_EU_Selected_Preferred_Species__c != null){
                    selectedMultiSpecies = salesPresets.ZTS_EU_Selected_Preferred_Species__c.split(';');
                }
                
                if(selectedMultiSpecies != null){
                    selectedMultiSpeciesOpt = listSelOptPopulate(selectedMultiSpecies);
                }
                
            }
        }
        else{
            if(salesPresetAction == 'New'){
                salesPresets = new ZTS_EU_Sales_Presets__c();
                displayErrPopup = false;
                displayPopup = true;
            }else{
                displayErrPopup = true;
                displayPopup = false;
            }
        }
    }
    
    //Checked by Abir
    /***********
* Method name : savePreferences
* Description : This method is called from salesPresets popup save button.
* Return Type : void.
* Parameters : None.
***********/
    public void savePreferences() {     
        isDMLbeforeCallout = true;
        selectedMultiBusinessUnits = new List<String>();
        if(salesPresets.Name == null || salesPresets.Name == ''){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Sales Preset Name is mandatory'));
            ispopupErr = true;
            return;
        }
        displayPopup = false;
        if(selectedMultiTherapeuticGrpOpt!=null)
            selectedMultiTherapeuticGrp = listStringPopulate(selectedMultiTherapeuticGrpOpt);
        if(selectedMultiProductOpt!=null)
            selectedMultiProduct = listStringPopulate(selectedMultiProductOpt);
        if(selectedMultiSpeciesOpt != null){
            List<String> buList = listStringPopulate(selectedMultiSpeciesOpt);
            for(String bu: buList){
                selectedMultiBusinessUnits.add(bu);
            }
        }
        if(salesPresetAction == 'New'){
            string presetName = salesPresets.Name;
            string presetGLRType = salesPresets.ZTS_EU_Selected_GLR_Type__c;
            string presetPreferredTime = salesPresets.ZTS_EU_Selected_Preferred_Time__c;
            
            salesPresets = new ZTS_EU_Sales_Presets__c();
            salesPresets.Name = presetName;
            salesPresets.ZTS_EU_Selected_GLR_Type__c = presetGLRType;
            salesPresets.ZTS_EU_Selected_Preferred_Time__c = presetPreferredTime;
            salesPresets.ZTS_EU_User__c = UserInfo.getUserId();
            if(selectedMultiTherapeuticGrp!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c  = multiSelectPopulate(listStringPopulate(selectedMultiTherapeuticGrpOpt));
                salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = multiSelectPopulate(listStringPopulate1(selectedMultiTherapeuticGrpOpt));
            }
            if(selectedMultiProduct!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c  = multiSelectPopulate(listStringPopulate(selectedMultiProductOpt));
                salesPresets.ZTS_EU_Selected_Preferred_Brands__c = multiSelectPopulate(listStringPopulate1(selectedMultiProductOpt));
            }
            if(selectedMultiBusinessUnits!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Species__c = multiSelectPopulate(selectedMultiBusinessUnits);
                //salesPresets.ZTS_EU_Selected_Preferred_Species__c = multiSelectPopulate(selectedMultiBusinessUnits);
            }
            //system.debug('----------------salesPresets: ' + salesPresets);
            //Abir: DML not allowed before callout, so commented
            //insert salesPresets;
            selectedPreset = salesPresets.Name;
            multiSelectedValueQuery();
        }
        if(salesPresetAction == 'Delete' && salesPresets != Null){
            //Abir: DML not allowed before callout, so commented
            //delete salesPresets;
            selectedPreset = '--None--';
            multiSelectedValueQuery();
        }
        if(salesPresetAction == 'Edit' && salesPresets != Null){
            if(selectedMultiTherapeuticGrp!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c  = multiSelectPopulate(listStringPopulate(selectedMultiTherapeuticGrpOpt));
                SalesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = multiSelectPopulate(listStringPopulate1(selectedMultiTherapeuticGrpOpt));
            }
            if(selectedMultiProduct!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c  = multiSelectPopulate(listStringPopulate(selectedMultiProductOpt));
                SalesPresets.ZTS_EU_Selected_Preferred_Brands__c = multiSelectPopulate(listStringPopulate1(selectedMultiProductOpt));
            }
            if(selectedMultiBusinessUnits!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Species__c = multiSelectPopulate(selectedMultiBusinessUnits);
                //SalesPresets.ZTS_EU_Selected_Preferred_Species__c = multiSelectPopulate(selectedMultiBusinessUnits);
            }
            //Abir: DML not allowed before callout, so commented
            //update salesPresets;
            multiSelectedValueQuery();
        }
        
    }
    
    /***********
* Method name : multiSelectPopulate
* Description : This method returns a string with semi colon separated values from List of string.
* Return Type : String.
* Parameters : List<String>.
***********/
    public String multiSelectPopulate(List<String> listSelectedStr){
        String Interests = '';
        Boolean Start = true; 
        if(!listSelectedStr.isEmpty()) { 
            for(String Str : listSelectedStr) {
                if(!Str.contains('<')){
                    if(Start) {
                        Interests = Str;
                        Start = false;
                    } else {               
                        Interests = Interests + ';' + Str;
                    }
                }
            }
        }
        return Interests;
    }
    
    /***********
* Method name : listStringPopulate
* Description : This method returns a List of string from List of select option.
* Return Type : List<String>.
* Parameters : List<SelectOption>.
***********/
    public List<String> listStringPopulate(List<SelectOption> listSelOpt){
        List<String> listStrVal = new List<String>();
        
        for ( SelectOption so : listSelOpt ) {           
            listStrVal.add(so.getvalue());            
        }
        return listStrVal;
        
    }
    
    /***********
* Method name : listStringPopulate1
* Description : This method returns a List of string from List of select option.
* Return Type : List<String>.
* Parameters : List<SelectOption>.
***********/
    public List<String> listStringPopulate1(List<SelectOption> listSelOpt){
        List<String> listStrVal = new List<String>();
        for ( SelectOption so : listSelOpt ) {           
            listStrVal.add(so.getlabel());            
        }
        return listStrVal;
    }
    
    /***********
* Method name : listSelOptPopulate
* Description : This method returns a List of select option from List of string.
* Return Type : List<SelectOption>.
* Parameters : List<String>.
***********/
    public List<SelectOption> listSelOptPopulate(List<String> listStr){
        List<SelectOption> listSelOpt = new List<SelectOption>();
        for ( String str : listStr ) {           
            listSelOpt.add(new selectOption(str,str));
        }
        return listSelOpt;
    }
    
    /***********
* Method name : listSelOptPopulate1
* Description : This method returns a List of select option from Map of string,string.
* Return Type : List<SelectOption>.
* Parameters : Map<String,String>.
***********/
    public List<SelectOption> listSelOptPopulate1(map<String,String> listStr){
        List<SelectOption> listSelOpt = new List<SelectOption>();
        for ( String str : listStr.keySet() ) {           
            listSelOpt.add(new selectOption(str,liststr.get(str)));
        }
        return listSelOpt;
    }
    
    //Checked by Abir   
    /***********
* Method name : closePopup
* Description : This method is called for closing the popup.
* Return Type : void.
* Parameters : None.
***********/
    public void closePopup() {        
        displayPopup = false;
        displayErrPopup = false;
    }
    
    // sorting code starts
    private String sortDirection = 'ASC';
    private String sortExp = 'ZTS_US_Account__r.Name';
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    //Checked by Abir
    /***********
* Method name : ViewSortData
* Description : This method is called for changing the data in the grid on the basis of sorting.
* Return Type : PageReference.
* Parameters : None.
***********/
    public PageReference ViewSortData() {
        getcreateDataTable();
        return null;
    }
    // sorting code ends
    
    /***********
* Method name : refreshTable
* Description : This method is called for refreshing the data grid.
* Return Type : PageReference.
* Parameters : None.
***********/
    public PageReference refreshTable() {
        //build the full sort expression
        //Commented by Abir
        //createQueryStr();
        getcreateDataTable();
        return null;
    }
    
    /***********
* Method name : CustomSettSalesData
* Description : This is wrapper class.
* Return Type : None.
* Parameters : None.
***********/
    public class CustomSettSalesData{      
        public String accntName{get;set;}       
        public String accntId{get;set;}
        public String narcId{get;set;}  
        public List<ActualSalesDataValue> salesDataWrapp{get;set;}
        
        public CustomSettSalesData(String narcId, String accntId, String accntName, List<ActualSalesDataValue> salesDataWrapp){
            this.salesDataWrapp = salesDataWrapp;
            this.accntName= accntName; 
            this.narcId= narcId;
            this.accntId= accntId;      
            
        }
        
        public List<dataYTD> listYTDData {get;set;}
        public Map<String, List<String>> monthValueMap {get;set;}
        
        public CustomSettSalesData(String narcId, String accntId, String accntName, List<ActualSalesDataValue> salesDataWrapp, List<dataYTD> listYTDData){
            this.salesDataWrapp = salesDataWrapp;
            this.accntName= accntName;          
            this.accntId= accntId;
            this.narcId= narcId;
            this.listYTDData= listYTDData;
        }
        public CustomSettSalesData(String narcId, String accntId, String accntName, List<ActualSalesDataValue> salesDataWrapp, Map<String, List<String>> monthValueMap){
            this.salesDataWrapp = salesDataWrapp;
            this.accntName= accntName;          
            this.accntId= accntId;  
            this.narcId= narcId;
            this.monthValueMap= monthValueMap;
        }
    }
    
    
    // for YTD
    /***********
* Method name : dataYTD
* Description : This is wrapper class for YTD.
* Return Type : None.
* Parameters : None.
***********/
    public class dataYTD{
        public String colMnthName{get;set;}
        public List<String> colValues{get;set;}     
        public dataYTD(String colMnthName, List<String> colValues){
            this.colMnthName = colMnthName;
            this.colValues= colValues;
        }
    }
    
    /***********
* Method name : ActualSalesDataValue
* Description : This is wrapper class.
* Return Type : None.
* Parameters : None.
***********/    
    public class ActualSalesDataValue{
        public List<String> therapeuticGrp{get;set;}
        public List<String> prodValue{get;set;}
        public List<String> prodLineItem{get;set;}
        public List<String> valueType{get;set;}
        public List<String> grandTotal{get;set;}
        public List<String> monthOne{get;set;}
        public List<String> monthTwo{get;set;}
        public List<String> monthThree{get;set;}
        public List<String> monthFour{get;set;}
        public List<String> monthFive{get;set;}
        public List<String> monthSix{get;set;}
        public List<String> monthSeven{get;set;}
        public List<String> monthEight{get;set;}
        public List<String> monthNine{get;set;}
        public List<String> monthTen{get;set;}
        public List<String> monthEleven{get;set;}
        public List<String> monthTwelve{get;set;}
        
        public ActualSalesDataValue(List<String> valueType, List<String> grandTotal,List<String> monthOne,List<String> monthTwo,List<String> monthThree,List<String> monthFour,List<String> monthFive,List<String> monthSix,List<String> monthSeven,
                                    List<String> monthEight,List<String> monthNine,List<String> monthTen,List<String> monthEleven,List<String> monthTwelve){
                                        this.valueType = valueType;
                                        this.grandTotal = grandTotal;
                                        this.monthOne = monthOne;
                                        this.monthTwo = monthTwo;
                                        this.monthThree = monthThree;
                                        this.monthFour = monthFour;
                                        this.monthFive = monthFive;
                                        this.monthSix = monthSix;
                                        this.monthSeven = monthSeven;
                                        this.monthEight = monthEight;
                                        this.monthNine = monthNine;
                                        this.monthTen = monthTen;
                                        this.monthEleven = monthEleven;
                                        this.monthTwelve = monthTwelve;
                                    }
        
        public ActualSalesDataValue(List<String> therapeuticGrp,List<String> prodValue,List<String> valueType, List<String> grandTotal,List<String> monthOne,List<String> monthTwo,List<String> monthThree,List<String> monthFour,List<String> monthFive,List<String> monthSix,List<String> monthSeven,
                                    List<String> monthEight,List<String> monthNine,List<String> monthTen,List<String> monthEleven,List<String> monthTwelve){
                                        this.therapeuticGrp = therapeuticGrp;
                                        this.prodValue = prodValue;
                                        this.valueType = valueType;
                                        this.grandTotal = grandTotal;
                                        this.monthOne = monthOne;
                                        this.monthTwo = monthTwo;
                                        this.monthThree = monthThree;
                                        this.monthFour = monthFour;
                                        this.monthFive = monthFive;
                                        this.monthSix = monthSix;
                                        this.monthSeven = monthSeven;
                                        this.monthEight = monthEight;
                                        this.monthNine = monthNine;
                                        this.monthTen = monthTen;
                                        this.monthEleven = monthEleven;
                                        this.monthTwelve = monthTwelve;
                                    }
        
        public ActualSalesDataValue(List<String> therapeuticGrp, List<String> prodValue, List<String> prodLineItem, List<String> valueType, List<String> grandTotal,List<String> monthOne,List<String> monthTwo,List<String> monthThree,List<String> monthFour,List<String> monthFive,List<String> monthSix,List<String> monthSeven,
                                    List<String> monthEight,List<String> monthNine,List<String> monthTen,List<String> monthEleven,List<String> monthTwelve){
                                        this.therapeuticGrp = therapeuticGrp;
                                        this.prodValue = prodValue;
                                        this.prodLineItem = prodLineItem;
                                        this.valueType = valueType;
                                        this.grandTotal = grandTotal;
                                        this.monthOne = monthOne;
                                        this.monthTwo = monthTwo;
                                        this.monthThree = monthThree;
                                        this.monthFour = monthFour;
                                        this.monthFive = monthFive;
                                        this.monthSix = monthSix;
                                        this.monthSeven = monthSeven;
                                        this.monthEight = monthEight;
                                        this.monthNine = monthNine;
                                        this.monthTen = monthTen;
                                        this.monthEleven = monthEleven;
                                        this.monthTwelve = monthTwelve;
                                    }
    }
    
    
    /***********
* Method name : AccntSalesDataValue
* Description : This is wrapper class.
* Return Type : None.
* Parameters : None.
***********/
    public class AccntSalesDataValue{
        public String accntSalesDataValue1{get;set;}
        public String accntSalesDataValue2{get;set;}
        public String accntSalesDataValue3{get;set;}
        public String accntSalesDataValue4{get;set;}
        public AccntSalesDataValue(String accntSalesDataValue1,String accntSalesDataValue2,String accntSalesDataValue3,String accntSalesDataValue4){
            this.accntSalesDataValue1 = accntSalesDataValue1;
            this.accntSalesDataValue2 = accntSalesDataValue2;
            this.accntSalesDataValue3 = accntSalesDataValue3;
            this.accntSalesDataValue4 = accntSalesDataValue4;
        }
        
    }  
    
        public PageReference redirect()
    {
        if (accntCurrent == null)
        {
            //US Call not returned in query above
            PageReference pageRef = new PageReference('/apex/ZTS_EU_IXHsalesAnalysis?Id=' + accntId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            getcreateDataTable();
            
            return null;            
        }
    } 
    public void FirstPage()
    {
        OffsetSize = 0;
        queryAccData();
    }
    public void previous()
    {
        System.debug('entered previous button & OffsetSize = '+OffsetSize);
        isNext = false;
        isPrevious = true;
        OffsetSize = (OffsetSize-LimitSize);
        queryAccData();
    }
    public void next()
    {
        isNext = true;
        isPrevious = false;
        OffsetSize = OffsetSize + LimitSize;
        queryAccData();
    }
    public void LastPage()
    {
        isNext = true;
        OffsetSize = wrapperObj.totalRecords - math.mod(wrapperObj.totalRecords,LimitSize);
              queryAccData();
    }
    public boolean getprev()
    {
        
        if(OffsetSize == 0){
            
            return true;
        }
        else {
            return false;
        }
    }
    public boolean getnxt()
    {
        if((OffsetSize + LimitSize) > wrapperObj.totalRecords){
            return true;
        }
        else {
            return false;
        }
    }
}