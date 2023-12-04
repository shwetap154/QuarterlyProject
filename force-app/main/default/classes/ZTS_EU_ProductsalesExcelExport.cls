/*************************************************************************************
* Name          :    ZTS_EU_ProductsalesExcelExport
* Description   :    Controller for a Product Sales Analysis page
* Created By    :    Laxmikanth
* Created Date  :    08-31-2016 

Modification Log
---------------------------------------------------------------------------------------
Developer           Date             Modification ID        Comments
---------------------------------------------------------------------------------------
Laxmikanth              08/31/2016                              Created
*************************************************************************************/

public with sharing class ZTS_EU_ProductsalesExcelExport{
    
    Public ZTS_EU_Species_Product__c prdCurrent                                 {get;set;}
    Public ZTS_EU_Species_Product__c prdActual                                  {get;set;}
    Public ZTS_EU_Species_Product__c prdPrevious                                 {get;set;}
    Public ZTS_EU_Species_Product__c prdParent                                  {get;set;}
    Public ZTS_EU_Species_Product__c prdChild                                   {get;set;}
    Public String queryPrdName                                  {get;set;}
    Public String prevPage                                  {get;set;}
    Public String nextPage                                  {get;set;}
    Public Integer offset                                  {get;set;}
    public String queryPrdID                                    {get;set;}
    Public String selectedPrd                                 {get;set;}
    Public String selectedTerr                                  {get;set;}
    Public String selectedTherapeuticGrp                        {get;set;}
    Public List<String> selectedMultiTherapeuticGrp             {get;set;}
    Public List<String> selectedMultiProduct                    {get;set;}
    Public List<String> selectedMultiSpecies                    {get;set;}
    Public List<String> selectedMultiBusinessUnits              {get;set;}
    Public List<SelectOption> selectedMultiTherapeuticGrpOpt    {get;set;}
    Public List<SelectOption> listMultiTherapeuticGrp           {get;set;} // list of select options to be shown on left in case of preset
    Public List<SelectOption> selectedMultiProductOpt           {get;set;}
    Public List<SelectOption> selectedMultiSpeciesOpt           {get;set;}
    Public List<SelectOption> selectedMultiBusinessUnitOpt      {get;set;}
    Public String selectedProduct                               {get;set;}
    Public String selectedSpecies                               {get;set;}
    public String selectedBusinessUnit                          {get;set;}
    public String selectedAccount                               {get;set;}
    public String selectedRating                                {get;set;}
    Public String selectedMATYTD                                {get;set;}
    Public String selectedReport                                {get;set;}
    Public String soqlQuery                                     {get;set;}
    Public ZTS_EU_Sales_Date__c salesDateCustSett               {get;set;}
    Public List<ZTS_EU_Sales__c> listSalesData;
    List<ZTS_EU_Species_Product__c> listChildPrd;
    Public Boolean parentAccntNotAvailable                      {get;set;}
    public Boolean isChildSelected                              {get;set;} // This variable will determine the type of Account selected
    Public List<CustomSettSalesData> customSetList              {get;set;}
    Public List<dataYTD> listdataYTD                            {get;set;}
    public String currencyISO                                  {get;set;} // This variable identifies the currency based on the Market
    public String currencyType                              {get;set;}
    Public Map<String,List<String>> mapTotalSalesYTD ;
    Public Map<String,List<String>> mapProdSalesYTD ;
    Public Map<String,List<String>> mapUnitSalesYTD ;
    Public Map<String,String> mapNoMonth ;
    public Map<String, String> dataNoMonthAPMap;
    public List<String> monthList{get;set;} 
    public boolean displayPopup {get; set;}
    public boolean linkPrev;
    public boolean linkNext;
    public boolean displayErrPopup {get; set;}
    List<User> listUser;
    public ZTS_EU_Sales_Presets__c salesPresets {get; set;}
    Public String selectedPreset{get;set;} 
    Public String salesPresetAction{get;set;}
    Integer counter = 0;
    Map<String,ZTS_EU_Species_Product__c> mapParentToChildValues = new Map<String, ZTS_EU_Species_Product__c>();
    Map<Integer, String> monthAPMap;
    Map<Integer, Integer> tempMonthAPMap;
    public String apStartDate                                     {get;set;}
    Map<String, String> monthNumberMap;
    public List<String> monthAPList                             {get;set;} // This list will have the order in which to display the AP values
    public boolean noParent                                     {get;set;}
    public boolean toggleFlagParent                             {get;set;}
    public String selectedSalesType                             {get;set;}
    public Boolean getAllRecords                                {get;set;}
    public Boolean ispopupErr                                   {get;set;}
    public Boolean isChild                                      {get;set;}
    public string allRecords                                   {get;set;}
    public String selectedLevelValue                            {get;set;}  
    public List<ZTS_EU_Species_Product__c> listPrd;
    public Boolean toDisplayGross                               {get;set;}
    public boolean showFootNote                                 {get; set;}
    public boolean showProductPicklist                          {get; set;}
    public ZTS_EU_Species_Product__c passAccount                {get;set;} // This will copy the current account id and use for passing a s aparameter +   Added by Sohil Shah for Sales Through Date of Sales Data and Net Sales
    Public List<CustomSettSalesData> customSetListREST          {get;set;}
    
    //[Ali Mohammed:] - Map that contains the filter parameters 
    public Map<String, String> httpSvcFilterParamMap;
    public boolean runningTest = false;
    public List<String> monthAPTitleList                             {get;set;} // This list will have the order in which to display the AP Title values
    public String prettyJSON                                    {get;set;}
    public Map<String, String> prodBrandMap;
    public Map<String, String> prodBUMap;
    public Map<String, String> prodThGrpMap;
    public Map<String, String> prodSpeciesMap;
    public Map<String, String> acctMap;
    public String testTab;
    public ZTS_EU_Species_Product__c prdRec;
    public Map<String, String> mapAccntIdAccntName;
    public Map<String, String> mapAccntIdBusinessName;
    public Map<String, String> mapRatingAccntName =  new Map<String, String>();
    public Map<String, String> mapPrdIdPrdName =  new Map<String, String>();
    
    public ZTS_EU_ProductsalesExcelExport(ApexPages.StandardController controller) {
        displayErrPopup = false;
        noParent = false;
        ispopupErr = false;
        offset=0;
        linkPrev=false;
        linkNext=false;
        allRecords='';
        currencyISO = '';
        prevPage='';
        nextPage='';
        Id accntIdQuery;
        selectedMATYTD = 'MAT';
        selectedReport = 'TotalSales';
        salesDateCustSett = ZTS_EU_Sales_Date__c.getAll().values()[0];
        monthAPMap = new Map<Integer, String>();
        monthNumberMap = new Map<String, String>();
        monthAPList =  new List<String>();
        parentAccntNotAvailable =  false;
        selectedLevelValue ='Branch'; // Set to 'Branch' to ensure initial page load gets this value, logic will alter the sales data based on 'Head Office' radio selection
        prdRec = (ZTS_EU_Species_Product__c)controller.getrecord();
        
        //[Ali Mohammed:] - Initialize filter parameters map
        httpSvcFilterParamMap = new Map<String, String>();
        
        prodBrandMap = new Map<String, String>();
        prodBUMap = new Map<String, String>();
        prodThGrpMap = new Map<String, String>();
        prodSpeciesMap = new Map<String, String>();
        mapAccntIdAccntName =  new Map<String, String>();
        mapAccntIdBusinessName = new Map<String, String>();
        //if(prdRec!=null)
        String prdId = ApexPages.currentPage().getParameters().get('prdId');
        String xyz = ApexPages.currentPage().getParameters().get('Report');
        String abc = ApexPages.currentPage().getParameters().get('Type');
        String def= ApexPages.currentPage().getParameters().get('allRecords');
        system.debug(PrdRec+'test...........'+prdId);
        if(prdId != null){
            prdRec.Id = prdId;
        }
        if(def!=null)
            allRecords = def;
        if(xyz!=null)
            SelectedReport = xyz;
        if(abc!=null)
            selectedMATYTD=abc;
            
        List<ZTS_EU_Species_Product__c> listPrd = [Select Id, Name, ZTS_EU_Type__c, ZTS_EU_Market__c,  ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where Id =: prdRec.Id]; //IP 26-Feb-15 Added Net Sales
        system.debug('--------------------listPrd: ' + listPrd);
        passAccount =listPrd[0];
        showFootNote = false;
        showProductPicklist = true;
        if(listPrd != Null && listPrd.size()>0){
            
            List<SalesRadioButtonsDisplay__c> custValues = SalesRadioButtonsDisplay__c.getAll().values();
            
            for(SalesRadioButtonsDisplay__c c : custValues){
                if(c.Name == listPrd[0].ZTS_EU_Market__c && c.DisplayOn__c == true){                           
                    selectedSalesType = 'Gross';
                    
                    toDisplayGross = true;
                    break; //IP 5-Feb-15 Fixed bug
                }
                
                else if(c.Name == listPrd[0].ZTS_EU_Market__c && c.DisplayNetSalesOnly__c == true){ //IP 25-Feb-15 Fixed bug
                    selectedSalesType = 'Net';
                    
                    toDisplayGross =false;
                    break;
                    
                }
                else{
                    selectedSalesType = 'Gross'; //IP 25-Feb-15 Fixed bug
                    toDisplayGross =false;  
                }
            }
            prdCurrent = listPrd[0];
            prdActual = listPrd[0];
            prdPrevious = null;
            
            List<ZTS_EU_Species_Product__c> listParentAcc = [select Id, Name, ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where Id=: prdCurrent.ZTS_EU_Parent_Species_Product__c limit 1];
            if(listParentAcc != null && listParentAcc.size() > 0){
                prdParent = listParentAcc[0];
            }else{
                prdParent = null;
            }
            
            prdChild = null;
        }
        //calculateLevelValues(prdRec);
        //selectedSalesType = 'Gross';
        if(prdCurrent.ZTS_EU_Parent_Species_Product__c == NULL){
            parentAccntNotAvailable = true;
        }
        accntIdQuery = prdCurrent.Id;
        listChildPrd = [Select Id, Name, ZTS_EU_Parent_Species_Product__c, ZTS_EU_Parent_Species_Product__r.Name from ZTS_EU_Species_Product__c where ZTS_EU_Parent_Species_Product__c =: accntIdQuery OR Id =: accntIdQuery];
        getcreateDataTable();
        
    }
    
    
    /*
    Added by sohil shah in order to change the Sales Through date when Salestype is changed from Sales to Net Sales and Vice Versa.
    */
    /******
    * Method Name   : callSalethroghtMethod
    * Description   : This method used in Vf page to toggle the SalesThrough Date
    * Return Type   : void
    * Parameters    : None
    * Author        : Sohil Shah
    *********/
    public void callSalethroghtMethod()
    {
        getcreateDataTable();
    }
   
    /***********
    * Method name : queryAccData
    * Description : This method is called for toggling parent and child Product on clicking the link.
    * Return Type : PageReference.
    * Parameters : None.
    ***********/
    public PageReference queryAccData() {
        //build the full sort expression
      //  system.debug('-------------------------prdParent: ' + prdParent);
        if(!isChildSelected && (monthNumberMap == null || monthNumberMap.size() <= 0)){
            prdParent = [Select Id, Name,ZTS_EU_Parent_Species_Product__c from ZTS_EU_Species_Product__c where Id =: prdParent.Id]; //IP 26-Feb-15 Added Net Sales
            //generateSalesThroughDate();
            //generateMonthMapping(prdParent);
        }
        
        //createQueryStr();
        soqlQuery+= 'AND ZTS_EU_Account__r.Name = \''+queryPrdName+'\' ';
        selectedPrd = queryPrdName;
        
        if(!noParent){
            // When the child record is selected
            if(isChildSelected == true){
                prdCurrent = prdChild;
                
                if(mapParentToChildValues.containsKey(prdChild.Name)){
                    prdChild = mapParentToChildValues.get(prdChild.Name);
                }else{
                    prdChild = null;
                }
                if(counter != 0 && prdParent!= null){
                    prdPrevious = prdParent;
                }else{
                    prdPrevious = prdActual;
                    counter++;
                }
                List<ZTS_EU_Species_Product__c> listParentAcc = [select Id, Name,ZTS_EU_Parent_Species_Product__c, ZTS_EU_Parent_Species_Product__r.Name from ZTS_EU_Species_Product__c where Id=: prdCurrent.ZTS_EU_Parent_Species_Product__c limit 1];
                if(listParentAcc != null && listParentAcc.size() > 0){
                    prdParent = listParentAcc[0];
                }else{
                    prdParent = null;
                }
            }else {
                List<String> prodLevel = new List<String>{'ZTS_EU_Species_Product__c'};
                    
                    if(prdParent != null){
                        mapParentToChildValues.put(prdParent.Name, prdCurrent);
                    }
                
                prdPrevious = prdChild;
                prdChild = prdCurrent;
                prdCurrent = prdParent;
                
                List<ZTS_EU_Species_Product__c> listParentAcc = [select Id, Name,ZTS_EU_Parent_Species_Product__c, ZTS_EU_Parent_Species_Product__r.Name from ZTS_EU_Species_Product__c where Id=: prdCurrent.ZTS_EU_Parent_Species_Product__c limit 1];
                if(listParentAcc != null && listParentAcc.size() > 0){
                    prdParent = listParentAcc[0];
                }else{
                    prdParent = null;
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
        customSetList = new List<CustomSettSalesData>();
        System.debug('Entered getCreateDataTable');
        
        
        selectedPrd = prdCurrent.Name;
        try{
            customSetList = getSalesDataFromIXH();
        }
        catch(Exception e){
            system.debug('Error Occurred: \n Line Number:' + e.getLineNumber() + '\n Cause: ' + e.getCause() + '\n Message: ' + e.getMessage() +'\n StackTrace: ' + e.getStackTraceString());
        }
        system.debug('Exiting : getCreateDataTable');
    }
    
    /***********
    * Method name : getSalesDataFromIXH
    * Description : This method is responsible for showing the data in the grid according to business logic. 
    * This data is retrieved by calling the REST service rather than querying Salesforce DB.
    * Return Type : List<CustomSettSalesData>.
    * Parameters : None.
    ***********/
    public List<CustomSettSalesData> getSalesDataFromIXH()
    {
        system.debug('======================= Entered getSalesDataFromRESTCall =======================\n');
        List<String> prodLevel;
        Set<Id> prdIds = new Set<Id>();
        List<CustomSettSalesData> listCustomSettSalesData = new List<CustomSettSalesData>();
        List<ActualSalesDataValue> listPrdSalesDataValue;
        
        Map<Id, String> mapAccntIdNarcId =  new Map<Id, String>();
        
        Map<String, Decimal> currentSumMap = new Map<String,Decimal>();
        Map<String, Decimal> prevSumMap = new Map<String, Decimal>();
        Map<String, Decimal> diffSumMap = new Map<String, Decimal>();
        
        List<ProductSalesRestClientHelper.SalesItems> saleItemListByProduct;
        List< ProductSalesRestClientHelper.SalesItems > salesItemsList = new List< ProductSalesRestClientHelper.SalesItems >();
        List< ProductSalesRestClientHelper.Links > linksList = new List< ProductSalesRestClientHelper.Links >();
        
        Integer salesRecordCount = 0;
        
        if(queryPrdID != null && queryPrdID != ''){
            prdIds.add((ID)queryPrdID);
        }
        
        if(prdCurrent == null){ 
            prdIds.add(queryPrdID);
        }else{
            prdIds.add(prdCurrent.Id);
        }
        
        //Use the named credential to connect to remote server
        String namedCredential = 'Product_Sales_Interface';
        
        //Initialize the filter map and build new
        httpSvcFilterParamMap.clear();
        //httpSvcFilterParamMap.put('brandIds', (String)prdIds.iterator().next());
        buildHttpSvcParamMap();
        //mapAccntIdAccntName.clear();
        HttpRequest request = buildHttpRequest(namedCredential, httpSvcFilterParamMap);
        HTTPResponse response = getHTTPCalloutResponse(request);
        
        String strSalesDataFromRestCall;
        if(response != null)
            strSalesDataFromRestCall  = response.getBody();
      /*  else if(runningTest){
            if(selectedReport == 'TotalSales')
              strSalesDataFromRestCall = jsonProductSales;
            else if(selectedReport == 'ProductSales')    
              strSalesDataFromRestCall = jsonProductSales;
            else if(selectedReport == 'UnitSales')
              strSalesDataFromRestCall = jsonProductSales;
        
        } */
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
            system.debug('Service did not return any data for this account');
            return null;              
        }
        
        
        System.debug('Returned data from REST Service: ' + strSalesDataFromRestCall);
        
        
        ProductSalesRestClientHelper salesDataHelper = new ProductSalesRestClientHelper(System.JSON.createParser(strSalesDataFromRestCall));          
        salesItemsList =  salesDataHelper.salesItems;
        linksList=salesDataHelper.Links;
        offset=salesDataHelper.offset;
        system.debug('No of Sales Items returned: ' + salesItemsList.size());
        System.debug('Returned data from REST Service: ' + strSalesDataFromRestCall);
        system.debug('=======================salesItems: '+ salesItemsList+'\n');
        
        //this line below is only needed for testing the json result from service call. Not needed in production
        //            prettyJSON = System.JSON.serializePretty(salesDataHelper);
        //            system.debug('=======================prettyJSON: '+ prettyJSON+'\n');
        
        Map < String, List<ProductSalesRestClientHelper.SalesItems>> productSalesItemsMap = new Map<String, List<ProductSalesRestClientHelper.SalesItems>>();
        String accCRMKey;
        String Salesdate;
        //setup currency symbol:
        if(salesItemsList != null && salesItemsList.size() > 0){
  
            setCurrencySymbol(salesItemsList[0].account.currencyIsoCode);
            apStartDate = salesItemsList[0].asOfDate;
            //Retrieve AP Names from ServiceResult and update MonthList with it
            //Can't be sure if the records will always be in sequence so create a map and then add them to list.
            if(selectedMATYTD != 'YTD'){
                Map<Integer, String> mapAPNames = new Map<Integer, String>();
                for(ProductSalesRestClientHelper.SalesRecords record : salesItemsList[0].salesRecords){
                    mapAPNames.put(record.period, record.accountingPeriod);
                }
                monthAPTitleList = new List<String>();
                for(Integer i=1; i<=12; i++){
                    monthAPTitleList.add(mapAPNames.get(i)+' CY');
                    monthAPTitleList.add(mapAPNames.get(i)+' PY');
                }
            }
            else{
                monthAPTitleList = new List<String>();
                for(Integer i=1; i<=12; i++){
                    monthAPTitleList.add('AP-' + i+' CY');
                    monthAPTitleList.add('AP-' + i+' PY');
                }
            }
            
            system.debug('monthAPTitleList: ' + monthAPTitleList);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No data returned'));
            System.debug('No sales data returned from the service for this account');
            return null;
            
        }
        
        if(linksList!=null){
        for(ProductSalesRestClientHelper.Links link : linksList){
            if(link.ref=='previousPage')
                prevPage=link.href;
            else if(link.ref=='nextPage')
                nextPage=link.href;
            system.debug('nextPage is '+nextPage);
        }
        }
        for(ProductSalesRestClientHelper.SalesItems salesItem : salesItemsList){
            accCRMKey = salesItem.account.crmTechnicalKey;
            if(accCRMKey!=null){
            mapAccntIdAccntName.put(accCRMKey, salesItem.account.businessName);
            mapAccntIdBusinessName.put(accCRMKey,salesItem.account.srcBusinessKey); 
            }
            mapAccntIdNarcId.put(accCRMKey, salesItem.account.erpBusinessKey);
            if(productSalesItemsMap.get(accCRMKey) == null){
                List<ProductSalesRestClientHelper.SalesItems> itemList = new List<ProductSalesRestClientHelper.SalesItems>();
                itemList.add(salesItem);
                productSalesItemsMap.put(accCRMKey, itemList);
            }
            else{
                productSalesItemsMap.get(accCRMKey).add(salesItem); 
            }
        }
       // system.debug('productSalesItemsMap: ' + productSalesItemsMap);
        for(Id oaccntId : productSalesItemsMap.keySet()){
            
            //Initialize data structures
            //
            String accName ;        
            String businessName;
            String accId ;
            String narcId;
            String prdId = prdCurrent.Id;
            String prdName = prdCurrent.Name ; 
            ProductSalesRestClientHelper.SalesItems saleItem;
            saleItemListByProduct = productSalesItemsMap.get(oaccntId);
            CustomSettSalesData oCustomSettSalesData;
            Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
            Map<String, List<Double>> mapSalesDataTotal = new Map<String, List<Double>>();
            mapSalesDataTotal.put(System.label.ZTS_EU_Current_Year, null);
            mapSalesDataTotal.put(System.label.ZTS_EU_Previous_Year, null);
            mapSalesDataTotal.put(System.label.ZTS_EU_Diff_Sales, null);
            mapSalesDataTotal.put('%'+System.label.ZTS_EU_Diff_Sales, null);
            listPrdSalesDataValue = new List<ActualSalesDataValue>();
            ActualSalesDataValue oAccntSalesDV;
            accName = mapAccntIdAccntName.get(oaccntId);
            businessName = mapAccntIdBusinessName.get(oaccntId);
            System.debug('******businessName is ******'+businessName);
            narcId = mapAccntIdNarcId.get(oaccntId);
            accId = oaccntId ;
            List<String> oaccntSalesData1total = new List<String>();
            List<String> oaccntSalesData2total = new List<String>();
            List<String> oaccntSalesData2totalPrev = new List<String>();
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
            System.debug( '======================= Tab Selected ' + selectedReport + ' =======================');
            
            for(ProductSalesRestClientHelper.SalesItems osalesData : saleItemListByProduct){
                
                system.debug('oSalesData: ' + osalesData);
                String productName = '';
                
                //Get the count of salesrecords in the list. In YTD scenario, there may not be all 12 records returned.
                salesRecordCount = osalesData.salesRecords.size();
                
                //updateProductHierarchyMaps(osalesData);
                
                //if UnitSales tab is selected
                if(selectedReport == 'UnitSales'){
                    List<String> oaccntSalesData1a = new List<String>{getProductHierarchyValueByKey('THERAPEUTIC_GROUP', osalesData)};
                    //List<String> oaccntSalesData1a = new List<String>();
                     //oaccntSalesData1a = mapAccntIdAccntName.values();
                        List<String> oaccntSalesData1b = new List<String>{getProductHierarchyValueByKey('BRAND', osalesData)};
                            if(osalesData.product != null && osalesData.product.productName != null)
                                productName = osalesData.product.productName;
                            else
                                productName = 'Not returned by service';
                    List<String> oaccntSalesData1c = new List<String>{productName};
                        //List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year};
                            
                    
                  List<String>  oaccntSalesData2a = new List<String>{String.valueOf(osalesData.totalSalesRecord.currentYearUnitTotal)};
               List<String>   oaccntSalesData2b = new List<String>{String.valueOf(osalesData.totalSalesRecord.previousYearUnitTotal)};

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
                    List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                    List< List<String> > listOfoaccntSalesDataprev = new List< List<String>>(); 
                    
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
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentUnits.format())});
                        listOfoaccntSalesDataprev.add(new List<String>{String.valueOf(osalesData.salesRecords[i].previousUnits.format())});

                            //oaccntSalesDataList.add(fieldValueList);
                          //  monthNoValueMap.put(String.valueOf(i),fieldValueList);
                        //system.debug('------------values in here----: ' +i+'---'+ fieldValueList);
                    }
                    
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<=12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                            listOfoaccntSalesDataprev.add(new List<String>());
                        }
                    }                                       
                    
                    
                    //system.debug('------------------monthNumberMap values here: ' + monthNoValueMap.get('0')+'---'+monthNoValueMap.get('1'));
                    //system.debug('------------------monthNumberMap values here: ' + monthNoValueMap.get('2')+'---'+monthNoValueMap.get('3'));
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1c,oaccntSalesData2a,oaccntSalesData2b,listOfoaccntSalesData[0],listOfoaccntSalesDataprev[0], listOfoaccntSalesData[1],listOfoaccntSalesDataprev[1],
                                                             listOfoaccntSalesData[2],listOfoaccntSalesDataprev[2],listOfoaccntSalesData[3],listOfoaccntSalesDataprev[3],listOfoaccntSalesData[4],listOfoaccntSalesDataprev[4],
                                                             listOfoaccntSalesData[5],listOfoaccntSalesDataprev[5],listOfoaccntSalesData[6],listOfoaccntSalesDataprev[6],listOfoaccntSalesData[7],listOfoaccntSalesDataprev[7],
                                                             listOfoaccntSalesData[8],listOfoaccntSalesDataprev[8],listOfoaccntSalesData[9],listOfoaccntSalesDataprev[9],listOfoaccntSalesData[10],listOfoaccntSalesDataprev[10],
                                                             listOfoaccntSalesData[11],listOfoaccntSalesDataprev[11]);
                    listPrdSalesDataValue.add(oAccntSalesDV);
                    
                    
                }
                //if TotalSales tab is selected
                else if(selectedReport == 'TotalSales'){                
                    // new code added
                    System.debug( '======================= Entering Total Sales Section =======================');
                    List<Double> listIntCurrent = mapSalesDataTotal.get(System.label.ZTS_EU_Current_Year);
                    List<Double> listIntPrior = mapSalesDataTotal.get(System.label.ZTS_EU_Previous_Year);
                    List<Double> listIntDollDiff = mapSalesDataTotal.get(System.label.ZTS_EU_Diff_Sales);
                    List<Double> listIntPerDiff = mapSalesDataTotal.get('%'+System.label.ZTS_EU_Diff_Sales);
                    Double intCurrent = osalesData.totalSalesRecord.currentYearSalesTotal;
                    Double intPrior = osalesData.totalSalesRecord.previousYearSalesTotal;
                    Double intDollDiff = osalesData.totalSalesRecord.diffSalesTotal;
                    Double intPerDiff = osalesData.totalSalesRecord.percDiffSalesTotal;
                    
                     
                    ProductSalesRestClientHelper.SalesRecords currRec;
                    
                    
                List<String> listStr = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales,'%'+System.label.ZTS_EU_Diff_Sales};
                    Map<String, List<String>> monthNoValueMap = new Map<String, List<String>>();
                
                oaccntSalesData2total = new List<String>{String.valueOf(osalesData.totalSalesRecord.currentYearSalesTotal.format())};
                oaccntSalesData2totalPrev = new List<String>{String.valueOf(osalesData.totalSalesRecord.previousYearSalesTotal.format())};
     
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
                    List< List<String> > listOfoaccntSalesDataPrev = new List< List<String>>();
                    
                    
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format())});                                                    
                        listOfoaccntSalesDataPrev.add(new List<String>{String.valueOf(osalesData.salesRecords[i].previousSales.format())});                                                    
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                            listOfoaccntSalesDataPrev.add(new List<String>());
                        }
                    }                                                
                monthNoValueMap.put('1',oaccntSalesData3total);monthNoValueMap.put('2',oaccntSalesData4total);monthNoValueMap.put('3',oaccntSalesData5total);
                monthNoValueMap.put('4',oaccntSalesData6total);monthNoValueMap.put('5',oaccntSalesData7total);monthNoValueMap.put('6',oaccntSalesData8total);
                monthNoValueMap.put('7',oaccntSalesData9total);monthNoValueMap.put('8',oaccntSalesData10total);monthNoValueMap.put('9',oaccntSalesData11total);
                monthNoValueMap.put('10',oaccntSalesData12total);monthNoValueMap.put('11',oaccntSalesData13total);monthNoValueMap.put('12',oaccntSalesData14total);
                
                system.debug('------------------------ monthNoValueMap: ' + monthNoValueMap);
                
                
                System.debug('Creating ActualSalesDataValue object');
                system.debug('----------------monthNumberMap.get12: ' + monthNumberMap.get('12')+'\n'+oaccntSalesData14total);
                
                oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData2total,oaccntSalesData2totalPrev,listOfoaccntSalesData[0],listOfoaccntSalesDataprev[0], listOfoaccntSalesData[1],listOfoaccntSalesDataprev[1],
                                                             listOfoaccntSalesData[2],listOfoaccntSalesDataprev[2],listOfoaccntSalesData[3],listOfoaccntSalesDataprev[3],listOfoaccntSalesData[4],listOfoaccntSalesDataprev[4],
                                                             listOfoaccntSalesData[5],listOfoaccntSalesDataprev[5],listOfoaccntSalesData[6],listOfoaccntSalesDataprev[6],listOfoaccntSalesData[7],listOfoaccntSalesDataprev[7],
                                                             listOfoaccntSalesData[8],listOfoaccntSalesDataprev[8],listOfoaccntSalesData[9],listOfoaccntSalesDataprev[9],listOfoaccntSalesData[10],listOfoaccntSalesDataprev[10],
                                                             listOfoaccntSalesData[11],listOfoaccntSalesDataprev[11]);
                system.debug('----------------------oAccntSalesDV: ' + oAccntSalesDV);
                listPrdSalesDataValue.add(oAccntSalesDV);
                    
                   // System.debug( '======================= Total Sales Lists =======================');
                   // System.debug('Current Totals: ' + listIntCurrent + '\n' + 'Prior Totals: ' + listIntPrior + '\n' 
                   //              + 'Diff Totals: ' + listIntDollDiff + '\n' + 'Percent Diff Totals: ' + listIntPerDiff + '\n' );
                }
                
                
                
                //if ProductSales tab is selected
                else if(selectedReport == 'ProductSales'){
                    Double intCurrent = osalesData.totalSalesRecord.currentYearSalesTotal;
                    Double intPrior = osalesData.totalSalesRecord.previousYearSalesTotal;
                    Double intDollDiff = osalesData.totalSalesRecord.diffSalesTotal;
                    //                            Double intPerDiff = osalesData.totalSalesRecord.percDiffSalesTotal;
                    
                    //List<String> oaccntSalesData1a = new List<String>{getProductHierarchyValueByKey('THERAPEUTIC_GROUP', osalesData)};
                      //  List<String> oaccntSalesData1b = new List<String>{getProductHierarchyValueByKey('BRAND', osalesData)};
                          //  List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales};
                                List<String> oaccntSalesData2a;
                    oaccntSalesData2a = new List<String>{String.valueOf(osalesData.totalSalesRecord.currentYearSalesTotal.format())};
                        List<String> oaccntSalesData2b =new List<String>{String.valueOf(osalesData.totalSalesRecord.previousYearSalesTotal.format())};
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
                    
                    List< List<String> > listOfoaccntSalesDataprev = new List< List<String>>();
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format())});                                                    
                        listOfoaccntSalesDataprev.add(new List<String>{String.valueOf(osalesData.salesRecords[i].previousSales.format())});
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                            listOfoaccntSalesDataprev.add(new List<String>());
                        }
                    }                                                
                    
                    
                   // system.debug('-------------------in here--------------------');
                    
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData2a,oaccntSalesData2b,listOfoaccntSalesData[0],listOfoaccntSalesDataprev[0], listOfoaccntSalesData[1],listOfoaccntSalesDataprev[1],
                                                             listOfoaccntSalesData[2],listOfoaccntSalesDataprev[2],listOfoaccntSalesData[3],listOfoaccntSalesDataprev[3],listOfoaccntSalesData[4],listOfoaccntSalesDataprev[4],
                                                             listOfoaccntSalesData[5],listOfoaccntSalesDataprev[5],listOfoaccntSalesData[6],listOfoaccntSalesDataprev[6],listOfoaccntSalesData[7],listOfoaccntSalesDataprev[7],
                                                             listOfoaccntSalesData[8],listOfoaccntSalesDataprev[8],listOfoaccntSalesData[9],listOfoaccntSalesDataprev[9],listOfoaccntSalesData[10],listOfoaccntSalesDataprev[10],
                                                             listOfoaccntSalesData[11],listOfoaccntSalesDataprev[11]);
                    
                   // system.debug('-------------------in here after call--------------------:');
                  //  system.debug('oaccntSalesData1a:- ' + oaccntSalesData1a);
                   // system.debug('oaccntSalesData1b:- ' + oaccntSalesData1b);
                   // system.debug('oaccntSalesData1:- ' + oaccntSalesData1);
                    system.debug('oaccntSalesData2a:- ' + oaccntSalesData2a);
                    system.debug('oAccntSalesDV:- ' + oAccntSalesDV);
                    
                    listPrdSalesDataValue.add(oAccntSalesDV);
                }     
                
            }
            oCustomSettSalesData  = new CustomSettSalesData(prdName, Accid, accName,businessName, listPrdSalesDataValue);
            
            listCustomSettSalesData.add(oCustomSettSalesData);
          //  system.debug('-----------------listCustomSettSalesData from REST Call: ' + listCustomSettSalesData);
        }
        
        if(salesItemsList.size()>0){
                // my code here for total
                
                if(selectedReport == 'UnitSales'){
                  List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                    
                  List< List<String> > listOfoaccntSalesDataPrev = new List< List<String>>();
                    ActualSalesDataValue oAccntSalesDV;
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(currentSumMap.get(String.valueOf(i)).format())});                                                    
                        listOfoaccntSalesDataPrev.add(new List<String>{String.valueOf(prevSumMap.get(String.valueOf(i)).format())});                                                    
 }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                            listOfoaccntSalesDataPrev.add(new List<String>());
                        }
                    }                                            
                    List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Previous_Year};
                    
                    CustomSettSalesData oCustomSettSalesData;
                    listdataYTD = new List<dataYTD>();
                    Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
                    
                    oAccntSalesDV = new ActualSalesDataValue(null,null,null,new List<String>{String.valueOf(currentSumMap.get('total').format())},new List<String>{String.valueOf(prevSumMap.get('total').format())},
                                                    listOfoaccntSalesData[0],listOfoaccntSalesDataPrev[0],listOfoaccntSalesData[1],listOfoaccntSalesDataPrev[1],listOfoaccntSalesData[2],listOfoaccntSalesDataPrev[2],
                                                    listOfoaccntSalesData[3],listOfoaccntSalesDataPrev[3],listOfoaccntSalesData[4],listOfoaccntSalesDataPrev[4],listOfoaccntSalesData[5],listOfoaccntSalesDataPrev[5],
                                                    listOfoaccntSalesData[6],listOfoaccntSalesDataPrev[6],listOfoaccntSalesData[7],listOfoaccntSalesDataPrev[7],listOfoaccntSalesData[8],listOfoaccntSalesDataPrev[8],
                                                    listOfoaccntSalesData[9],listOfoaccntSalesDataPrev[9],listOfoaccntSalesData[10],listOfoaccntSalesDataPrev[10],listOfoaccntSalesData[11],listOfoaccntSalesDataPrev[11]);
                                        listPrdSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
                    oCustomSettSalesData  = new CustomSettSalesData(null,null,null,null,listPrdSalesDataValue);
                    listCustomSettSalesData.add(oCustomSettSalesData);
            
                }
                if(selectedReport == 'ProductSales'){
                  List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                  List< List<String> > listOfoaccntSalesDataPrev = new List< List<String>>();
      
                    ActualSalesDataValue oAccntSalesDV;
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(currentSumMap.get(String.valueOf(i)).format())});                                                    
                        listOfoaccntSalesDataPrev.add(new List<String>{String.valueOf(prevSumMap.get(String.valueOf(i)).format())});
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                           listOfoaccntSalesDataPrev.add(new List<String>());

                        }
                    }                                            
                   // List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Total + ' '+System.label.ZTS_EU_Diff_Sales};
                    
                    CustomSettSalesData oCustomSettSalesData;
                    listdataYTD = new List<dataYTD>();
                    Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
                    
                    oAccntSalesDV = new ActualSalesDataValue(new List<String>{String.valueOf(currentSumMap.get('total').format())},new List<String>{String.valueOf(prevSumMap.get('total').format())},
                                                    listOfoaccntSalesData[0],listOfoaccntSalesDataPrev[0],listOfoaccntSalesData[1],listOfoaccntSalesDataPrev[1],listOfoaccntSalesData[2],listOfoaccntSalesDataPrev[2],
                                                    listOfoaccntSalesData[3],listOfoaccntSalesDataPrev[3],listOfoaccntSalesData[4],listOfoaccntSalesDataPrev[4],listOfoaccntSalesData[5],listOfoaccntSalesDataPrev[5],
                                                    listOfoaccntSalesData[6],listOfoaccntSalesDataPrev[6],listOfoaccntSalesData[7],listOfoaccntSalesDataPrev[7],listOfoaccntSalesData[8],listOfoaccntSalesDataPrev[8],
                                                             listOfoaccntSalesData[9],listOfoaccntSalesDataPrev[9],listOfoaccntSalesData[10],listOfoaccntSalesDataPrev[10],listOfoaccntSalesData[11],listOfoaccntSalesDataPrev[11]);
                                                    listPrdSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
                    oCustomSettSalesData  = new CustomSettSalesData(null,null,null,null,listPrdSalesDataValue);
                    listCustomSettSalesData.add(oCustomSettSalesData);
            
                }
            
        }
        system.debug('-------------listCustomSettSalesData before return : '+ listCustomSettSalesData);
        return listCustomSettSalesData;
    }
    
    /***********
    * Method name : getProductHierarchyValueByKey
    * Description : This method retrieves the product hierarchy values from the list based on the key.
    * Return Type : String.
    * Parameters :  key - attribute to be retrieved. e.g.: THERAPEUTIC GROUP or BRAND
    *               productHierarchies - list of product hierarchies returned from the service call
    ***********/
    public String getProductHierarchyValueByKey(String key, ProductSalesRestClientHelper.SalesItems oData){
        String value='';
        if(oData.product != null && oData.product.productHierarchies != null){
            for(ProductSalesRestClientHelper.ProductHierarchies item : oData.product.productHierarchies){
      //          system.debug('key = ' + key + '\t item code: ' + item.code);
                if(key == item.code){
                    value = item.name;
                    break;
                }
            }
        }
        return value;
    }
    
    /***********
    * Method name : buildHttpSvcParamMap
    * Description : This method creates the map of the filter parameters which is passed during the call to service.
    * Return Type : void.
    * Parameters : None.
    ***********/
    public void buildHttpSvcParamMap(){
        httpSvcFilterParamMap.clear();
        Map<String, String> reportTypeMap = new Map<String, String>();
        reportTypeMap.put('UnitSales', 'SKU');
        reportTypeMap.put('ProductSales', 'BRAND');
        reportTypeMap.put('TotalSales', 'USER_TOTAL_BRAND');
        
        Map<String, String> salesTypeMap = new Map<String, String>();
        salesTypeMap.put('Gross', 'G');
        salesTypeMap.put('Net', 'N');
        
        
        //Waiting for service implementation to include these filter parameters
        
        //httpSvcFilterParamMap.put('aggregationLevel', 'BRAND');
        httpSvcFilterParamMap.put('target', 'INTERNATIONAL');
        httpSvcFilterParamMap.put('aggregationLevel', reportTypeMap.get(selectedReport));
        if(selectedMATYTD == null || selectedMATYTD.length() == 0)
            selectedMATYTD = 'MAT';
        httpSvcFilterParamMap.put('selectedMATYTD', selectedMATYTD);
        
        if(selectedSalesType == null || selectedSalesType.length() == 0)
            selectedSalesType = 'Gross';
        httpSvcFilterParamMap.put('salesType', salesTypeMap.get(selectedSalesType));
        
        
        // Apply filters only when Product Sales or Unit Sales tab is selected
        system.debug('selected account is ' +selectedAccount );
        if(selectedAccount != null && selectedAccount != '' && selectedAccount != '<Account>') {
                httpSvcFilterParamMap.put('accountId', selectedAccount);
                linkNext=false;
                linkPrev=false;
                //mapAccntIdAccntName.clear();
        }
              else
                httpSvcFilterParamMap.put('userId',Userinfo.getUserId());
                              
            
         // End Apply filters only when Product Sales or Unit Sales tab is selected
         
            
        //Waiting for service implementation to include these filter parameters
        if(selectedLevelValue =='Head Office'){
            httpSvcFilterParamMap.put('accountAggregationLevel', 'HEAD_OFFICE');
        } else {
            httpSvcFilterParamMap.put('accountAggregationLevel', 'BRANCH');
        } //END
        
        
        if(PrdCurrent.ZTS_EU_Type__c=='Brand'){
        httpSvcFilterParamMap.put('brandIds',prdCurrent.Id);
        }
        else if(PrdCurrent.ZTS_EU_Type__c=='Therapeutic Group'){
        httpSvcFilterParamMap.put('therapeuticGroupIds',prdCurrent.Id);
        }
        else if(PrdCurrent.ZTS_EU_Type__c=='Business Unit'){
        httpSvcFilterParamMap.put('businessUnitIds',prdCurrent.Id);
        }
        else if(PrdCurrent.ZTS_EU_Type__c=='SKU'){
        httpSvcFilterParamMap.put('skuIds',prdCurrent.Id);
        }
        System.debug('allrecords is '+allRecords);
 
             
        if(allRecords=='check'){
          httpSvcFilterParamMap.put('getAllRecords','true');
            
            
        }else{
            httpSvcFilterParamMap.put('recordsPerPage', '20');

        }
       
        System.debug('Final Svc Params : ' + httpSvcFilterParamMap);
        
    }
    
    public void setCurrencySymbol(String CurrencyIsoCode){
        
        system.debug('currency code>>>>'+ CurrencyIsoCode);
        Map<String,CurrencySymbolMapping__c> symbolsMap = CurrencySymbolMapping__c.getAll();
        currencyType = symbolsMap.get(CurrencyIsoCode).Currency_Symbol__c;
        system.debug('currency symbol>>>>'+ currencyType);
        
    }
    
    public HttpRequest buildHttpRequest(String namedCred, Map<String, String> paramMap)
    {
        String queryString;
        if(linkPrev==true){
            queryString = PrevPage.substring(PrevPage.lastIndexOf('?') + 1);
        }
       else if(linkNext==true){
            queryString = NextPage.substring(NextPage.lastIndexOf('?') + 1);
        }
        else{
             queryString = buildQueryString(paramMap);
        }
        HttpRequest req = new HttpRequest();
        String endpointURL = 'callout:'  + namedCred + '/?' + queryString;
        System.debug('Endpoint URL: ' + endpointURL);
        req.setEndpoint(endpointURL);
        req.setMethod('POST');        
        return req;
    }
    
    public HTTPResponse getHTTPCalloutResponse(HttpRequest request)
    {   
        HTTPResponse response;
        Http http;
        try {
            if(!runningTest){
                http = new Http();
                response = http.send(request);
            }
            
            System.debug('Response returned: ' + response.getBody());
        } catch(Exception ex) {
            System.debug(ex);
        }
        return response;
    }
    
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
        System.debug('Query String: ' + queryString);
        return queryString;
    }
    
    /**********
    * Method Name   : checkClick
    * Description   : This method will identify if Previous Page is clicked
    * Return Type   : void
    * Parameters    : None
    ***********/
    public void checkClickPrevPage(){
        linkPrev =true;
        getcreateDataTable();
    }
     /**********
    * Method Name   : checkClickNextPage
    * Description   : This method will identify if Next Page is clicked
    * Return Type   : void
    * Parameters    : None
    ***********/
    public void checkClickNextPage(){
        linkNext =true;
        getcreateDataTable();
    }
    /**********
    * Method Name   : checkUserCurrency
    * Description   : This method will identify the currency based on user's market value
    * Return Type   : void
    * Parameters    : None
    ***********/
    private void checkUserCurrency(){
        List<User> listUser = [select ZTS_EU_Market__c,ID from User where Id=: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];
    }
    
    /***********
    * Method name : selectedValueQuery
    * Description : This method will modify the query according to filter value selected.
    * Return Type : None.
    * Parameters : None.
    ***********/
   public void selectedValueQuery(){
        //selectedPreset = '--None--';
        getcreateDataTable();
    }
    
   
    /***********
    * Method name : CustomSettSalesData
    * Description : This is wrapper class.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public class CustomSettSalesData{      
        Public String accntName{get;set;}   
        Public String prdName{get;set;}  
        Public String businessName{get;set;} 
        Public String accntId{get;set;}
        Public String narcId{get;set;}  
        Public List<ActualSalesDataValue> salesDataWrapp{get;set;}
        
        public CustomSettSalesData(String prdName, String accntId, String accntName,String businessName,  List<ActualSalesDataValue> salesDataWrapp){
            this.salesDataWrapp = salesDataWrapp;
            this.accntId = accntId;
            this.prdName = prdName;
            this.accntName= accntName;  
            this.businessName= businessName;
            
        }
        
        Public List<dataYTD> listYTDData {get;set;}
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
        Public String colMnthName{get;set;}
        Public List<String> colValues{get;set;}     
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
        Public List<String> therapeuticGrp{get;set;}
        Public List<String> prodValue{get;set;}
        Public List<String> prodLineItem{get;set;}
        Public List<String> valueType{get;set;}
        Public List<String> grandTotal{get;set;}
        Public List<String> monthOne{get;set;}
        Public List<String> monthTwo{get;set;}
        Public List<String> monthThree{get;set;}
        Public List<String> monthFour{get;set;}
        Public List<String> monthFive{get;set;}
        Public List<String> monthSix{get;set;}
        Public List<String> monthSeven{get;set;}
        Public List<String> monthEight{get;set;}
        Public List<String> monthNine{get;set;}
        Public List<String> monthTen{get;set;}
        Public List<String> monthEleven{get;set;}
        Public List<String> monthTwelve{get;set;}
        Public List<String> grandTotal1{get;set;}
        Public List<String> monthOne1{get;set;}
        Public List<String> monthTwo1{get;set;}
        Public List<String> monthThree1{get;set;}
        Public List<String> monthFour1{get;set;}
        Public List<String> monthFive1{get;set;}
        Public List<String> monthSix1{get;set;}
        Public List<String> monthSeven1{get;set;}
        Public List<String> monthEight1{get;set;}
        Public List<String> monthNine1{get;set;}
        Public List<String> monthTen1{get;set;}
        Public List<String> monthEleven1{get;set;}
        Public List<String> monthTwelve1{get;set;}
        
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
        public ActualSalesDataValue( List<String> grandTotal, List<String> grandTotal1,List<String> monthOne,List<String> monthOne1,List<String> monthTwo,List<String> monthTwo1
                                    ,List<String> monthThree,List<String> monthThree1,List<String> monthFour,List<String> monthFour1,List<String> monthFive,List<String> monthFive1
                                    ,List<String> monthSix,List<String> monthSix1,List<String> monthSeven,List<String> monthSeven1,List<String> monthEight,List<String> monthEight1
                                    ,List<String> monthNine,List<String> monthNine1,List<String> monthTen,List<String> monthTen1
                                    ,List<String> monthEleven,List<String> monthEleven1,List<String> monthTwelve,List<String> monthTwelve1){
                                        //this.valueType = valueType;
                                        this.grandTotal = grandTotal;
                                        this.grandTotal1 = grandTotal1;
                                        this.monthOne = monthOne;
                                        this.monthOne1 = monthOne1;
                                        this.monthTwo = monthTwo;
                                        this.monthTwo1 = monthTwo1;
                                        this.monthThree = monthThree;
                                        this.monthThree1 = monthThree1;
                                        this.monthFour = monthFour;
                                        this.monthFour1 = monthFour1;
                                        this.monthFive = monthFive;
                                        this.monthFive1 = monthFive1;
                                        this.monthSix = monthSix;
                                        this.monthSix1 = monthSix1;
                                        this.monthSeven = monthSeven;
                                        this.monthSeven1 = monthSeven1;
                                        this.monthEight = monthEight;
                                        this.monthEight1 = monthEight1;
                                        this.monthNine = monthNine;
                                        this.monthNine1 = monthNine1;
                                        this.monthTen = monthTen;
                                        this.monthTen1 = monthTen1;
                                        this.monthEleven = monthEleven;
                                        this.monthEleven1 = monthEleven1;
                                        this.monthTwelve = monthTwelve;
                                        this.monthTwelve1 = monthTwelve1;
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
        
        public ActualSalesDataValue(List<String> therapeuticGrp, List<String> prodValue, List<String> prodLineItem,  List<String> grandTotal, List<String> grandTotal1,List<String> monthOne,List<String> monthOne1,List<String> monthTwo,List<String> monthTwo1
                                    ,List<String> monthThree,List<String> monthThree1,List<String> monthFour,List<String> monthFour1,List<String> monthFive,List<String> monthFive1
                                    ,List<String> monthSix,List<String> monthSix1,List<String> monthSeven,List<String> monthSeven1,List<String> monthEight,List<String> monthEight1
                                    ,List<String> monthNine,List<String> monthNine1,List<String> monthTen,List<String> monthTen1
                                    ,List<String> monthEleven,List<String> monthEleven1,List<String> monthTwelve,List<String> monthTwelve1){
                                        this.therapeuticGrp = therapeuticGrp;
                                        this.prodValue = prodValue;
                                        this.prodLineItem = prodLineItem;
                                        //this.valueType = valueType;
                                        this.grandTotal = grandTotal;
                                        this.grandTotal1 = grandTotal1;
                                        this.monthOne = monthOne;
                                        this.monthOne1 = monthOne1;
                                        this.monthTwo = monthTwo;
                                        this.monthTwo1 = monthTwo1;
                                        this.monthThree = monthThree;
                                        this.monthThree1 = monthThree1;
                                        this.monthFour = monthFour;
                                        this.monthFour1 = monthFour1;
                                        this.monthFive = monthFive;
                                        this.monthFive1 = monthFive1;
                                        this.monthSix = monthSix;
                                        this.monthSix1 = monthSix1;
                                        this.monthSeven = monthSeven;
                                        this.monthSeven1 = monthSeven1;
                                        this.monthEight = monthEight;
                                        this.monthEight1 = monthEight1;
                                        this.monthNine = monthNine;
                                        this.monthNine1 = monthNine1;
                                        this.monthTen = monthTen;
                                        this.monthTen1 = monthTen1;
                                        this.monthEleven = monthEleven;
                                        this.monthEleven1 = monthEleven1;
                                        this.monthTwelve = monthTwelve;
                                        this.monthTwelve1 = monthTwelve1;
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
   
}