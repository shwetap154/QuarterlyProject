/*************************************************************************************
* Name          :    ZTS_EU_salesDataReportingController
* Description   :    Controller for a Sales Analysis page
* Created By    :    Mayank
* Created Date  :    04-08-2014 

Modification Log
---------------------------------------------------------------------------------------
Developer           Date             Modification ID        Comments
---------------------------------------------------------------------------------------
Mayank              04/08/2014                              Created
Ilirjana Predojević 5-Feb-2015                              Fixed the bug
Ilirjana Predojević 25-Feb-2015                             Fixed the bug
Shreyas Ringe       20-Jun-2015                             Added enhancement for Spain DGs
Sohil Shah          10th July, 2015                         Added Currency Symbol(Currency Type in Total Sales Also) DEF-001063
Sohil Shah          6th Oct, 2015                           Added logic to populate Sales Through Date of Sales Data and Net Sales Data Resp. REF- INC0461833
Sohil Shah          7th Oct, 2015                           Added logic to Remove Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
**************************************************************************************/

public with sharing class ZTS_EU_IXHsalesDataReportingController {
    
    Public Account accntCurrent                                 {get;set;}
    Public Account accntActual                                  {get;set;}
    Public Account accnPrevious                                 {get;set;}
    Public Account accntParent                                  {get;set;}
    Public Account accntChild                                   {get;set;}
    Public String queryAccName                                  {get;set;}
    public String queryAccID                                    {get;set;}
    Public String selectedAccnt                                 {get;set;}
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
    Public String selectedMATYTD                                {get;set;}
    Public String selectedReport                                {get;set;}
    Public String soqlQuery                                     {get;set;}
    Public ZTS_EU_Sales_Date__c salesDateCustSett               {get;set;}
    Public List<ZTS_EU_Sales__c> listSalesData;
    List<Account> listChildAccnt;
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
    public boolean displayErrPopup {get; set;}
    List<User> listUser;
    public ZTS_EU_Sales_Presets__c salesPresets {get; set;}
    Public String selectedPreset{get;set;} 
    Public String salesPresetAction{get;set;}
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
    public Boolean isChild                                     {get;set;}
    public String selectedLevelValue                            {get;set;}  
    public List<Account> listAccnt;
    public Boolean toDisplayGross                                   {get;set;}
    public boolean showFootNote                                 {get; set;}
    public boolean showProductPicklist                                 {get; set;}
    public Account passAccount                                  {get;set;} // This will copy the current account id and use for passing a s aparameter +   Added by Sohil Shah for Sales Through Date of Sales Data and Net Sales
    public  boolean isGermanyRegion                             {get;set;} // Sohil Shah Removed Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
    
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
    public String testTab;
    
    public ZTS_EU_IXHsalesDataReportingController(ApexPages.StandardController controller) {
        displayErrPopup = false;
        isGermanyRegion = false;
        noParent = false;
        ispopupErr = false;
        //apStartDate = system.today();
        currencyISO = '';
        createQueryStr();
       userPreference();
        Id accntIdQuery;
        selectedMATYTD = 'MAT';
        selectedReport = 'TotalSales';
        salesDateCustSett = ZTS_EU_Sales_Date__c.getAll().values()[0];
        monthAPMap = new Map<Integer, String>();
        monthNumberMap = new Map<String, String>();
        monthAPList =  new List<String>();
        parentAccntNotAvailable =  false;
        selectedLevelValue ='Branch'; // Set to 'Branch' to ensure initial page load gets this value, logic will alter the sales data based on 'Head Office' radio selection
        Account accntRec = (Account)controller.getrecord();
        
        //[Ali Mohammed:] - Initialize filter parameters map
        httpSvcFilterParamMap = new Map<String, String>();
        
        prodBrandMap = new Map<String, String>();
        prodBUMap = new Map<String, String>();
        prodThGrpMap = new Map<String, String>();
        prodSpeciesMap = new Map<String, String>();
        
        
        System.debug('****** Account Record ' + accntRec);
        
        List<Account> listAccnt = [Select Id, Name,ParentId, ZTS_EU_Market__c,Parent.Name, ZTS_EU_Loyalty_Flag__c,  (select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null),
                                   (select id, ZTS_EU_Date__c, CurrencyIsoCode from Net_Sales__r where ZTS_EU_Date__c <> null)
                                   from Account where Id =: accntRec.Id AND ZTS_EU_Market__c != 'United States']; //IP 26-Feb-15 Added Net Sales
      //  system.debug('--------------------listAccnt: ' + listAccnt);
        passAccount =listAccnt[0];
        System.debug('passAccount-------'+passAccount);
        showFootNote = false;
        showProductPicklist = true;
        // Sohil Shah Removed Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
        if(listAccnt[0].ZTS_EU_Market__c == 'Germany' || listAccnt[0].ZTS_EU_Market__c == 'Austria' || listAccnt[0].ZTS_EU_Market__c == 'Switzerland')
        {
            isGermanyRegion = true;
        }
        // EOC Sohil Shah Removed Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
     //   System.debug('****** Account Market'  + listAccnt[0].ZTS_EU_Market__c);
        if(listAccnt != Null && listAccnt.size()>0){
            
            if(listAccnt[0].ZTS_EU_Market__c == 'Turkey'){
                showFootNote = true;
            }
            if(listAccnt[0].ZTS_EU_Market__c == 'Spain'){
                showProductPicklist = false;
                selectedProduct = '<Product>';
            }
            
            List<SalesRadioButtonsDisplay__c> custValues = SalesRadioButtonsDisplay__c.getAll().values();
            
            for(SalesRadioButtonsDisplay__c c : custValues){
                if(c.Name == listAccnt[0].ZTS_EU_Market__c && c.DisplayOn__c == true){                           
                    selectedSalesType = 'Gross';
                    
                    toDisplayGross = true;
                    break; //IP 5-Feb-15 Fixed bug
                }
                
                else if(c.Name == listAccnt[0].ZTS_EU_Market__c && c.DisplayNetSalesOnly__c == true){ //IP 25-Feb-15 Fixed bug
                    selectedSalesType = 'Net';
                    
                    toDisplayGross =false;
                    break;
                    
                }
                else{
                    selectedSalesType = 'Gross'; //IP 25-Feb-15 Fixed bug
                    toDisplayGross =false;  
                }
            }
            
            
            
            /*               generateSalesThroughDate(listAccnt[0]); // populate Default SalesThrough Date i.e. for Sales Data - By Sohil Shah
//               generateMonthMapping(listAccnt[0]);

if(monthNumberMap == null || monthNumberMap.size() == 0 || monthAPMap == null || monthAPMap.size() == 0){
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.label.ZTS_EU_Error_Invalid_Date_for_Sales));
//return;
}//else{
*/
            accntCurrent = listAccnt[0];
            accntActual = listAccnt[0];
            accnPrevious = null;
            
            List<Account> listParentAcc = [select Id, Name, ParentId,ZTS_EU_Market__c, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where Id=: accntCurrent.ParentId limit 1];
            if(listParentAcc != null && listParentAcc.size() > 0){
                accntParent = listParentAcc[0];
            }else{
                accntParent = null;
            }
            
            accntChild = null;
            //}
        }
        System.Debug('****** Debug Calling calculateLevelValue');
        calculateLevelValues(accntRec);
        //selectedSalesType = 'Gross';
        if(accntCurrent.ParentId == NULL){
            parentAccntNotAvailable = true;
        }
        accntIdQuery = accntCurrent.Id;
        listChildAccnt = [Select Id, Name, ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where (ParentId =: accntIdQuery OR Id =: accntIdQuery)];
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
        generateSalesThroughDate(passAccount);
        getcreateDataTable();
    }
    /******
    * Method Name   : generateSalesThroughDate
    * Description   : This method will populate Sales Through Date
    * Return Type   : Account
    * Parameters    : None
    *********/
    public void generateSalesThroughDate(Account acc)
    {
        
        if(acc.Sales__r != null && acc.Sales__r.size()>0 && selectedSalesType == 'Gross' )
        {                                      
            
           // apStartDate = acc.Sales__r[0].ZTS_EU_Date__c;               
        }
        if(acc.Sales__r.isEmpty() && selectedSalesType == 'Gross')
        {
            apStartDate = null;
        }
        if(acc.Net_Sales__r != null && acc.Net_Sales__r.size()>0 && (selectedSalesType == 'Net' || selectedSalesType == 'Net Sales' ))
        {
         //   apStartDate = acc.Net_Sales__r[0].ZTS_EU_Date__c;
        }
        if(acc.Net_Sales__r.isEmpty() && (selectedSalesType == 'Net' || selectedSalesType == 'Net Sales' ))
        {
            
            apStartDate = null;
        }
    }
    
    // EOC by sohil shah - SalesThrough Date logic 
    /*********
    * Method Name   : generateMonthMapping
    * Description   : This method will generate the map to be used to identify 
    * Return Type   : void
    * Parameters    : None
    *********/
    
    /* Commented by Ali as we don't use this function anymore, we are getting the month map from the service result directly
    private void generateMonthMapping(Account account){
        Integer startCounter = 0;
        Integer mapCounter = 1;
        tempMonthAPMap = new Map<Integer, Integer>();           
        if(account.Sales__r != null && account.Sales__r.size() > 0){
            //apStartDate = account.Sales__r[0].ZTS_EU_Date__c; // Commented by Sohil - logic is above
            //added by Shefali 12/01/2014 Currency Symbol according to the Sales Data
            currencyISO = account.Sales__r[0].CurrencyIsoCode;
           system.debug('currency code>>>>'+currencyISO);
            Map<String,CurrencySymbolMapping__c> symbolsMap = CurrencySymbolMapping__c.getAll();
            for(String key : symbolsMap.keySet()){
                if(currencyISO != null && currencyISO.equalsIgnoreCase(key)){
                    currencyType = symbolsMap.get(key).Currency_Symbol__c ;
                    system.debug('Currency Symbol>>>>>'+currencyType);
                }
            }
            //EOC Shefali
            List<ZTS_EU_Accounting_Period__c> listAccPeriod = [select Id, ZTS_EU_Account_Period__c from ZTS_EU_Accounting_Period__c where 
                                                               ZTS_EU_AP_Start__c <=: account.Sales__r[0].ZTS_EU_Date__c and ZTS_EU_AP_End__c >=: account.Sales__r[0].ZTS_EU_Date__c limit 1];
            if(listAccPeriod != null && listAccPeriod.size() > 0){
                startCounter = Integer.valueOf(listAccPeriod[0].ZTS_EU_Account_Period__c);
                
                for(Integer i = startCounter; i >= 1; i--){
                    monthAPMap.put(mapCounter, 'AP-'+i);
                    tempMonthAPMap.put(i, mapCounter);
                    mapCounter++;
                }
                if(mapCounter < 12){
                    for(Integer i = 12; i > startCounter; i--){
                        monthAPMap.put(mapCounter, 'AP-'+i);
                        tempMonthAPMap.put(i, mapCounter);
                        mapCounter++;
                    }
                }
                
                // my code start here/////
                mapCounter = 1;
                Integer firstValue = tempMonthAPMap.get(startCounter);
                for(Integer i = startCounter-1; i >= 1; i--){
                    monthAPList.add('AP-'+i);
                }
                for(Integer i = 12; i >= startCounter; i--){
                    monthAPList.add('AP-'+i);
                }
                for(Integer i = firstValue; i <= 12; i++){
                    monthNumberMap.put(String.valueOf(mapCounter), String.valueOf(i));
                    mapCounter++;
                }
                
                if(mapCounter < 12){
                    for(Integer i = 1; i < firstValue; i++){
                        monthNumberMap.put(String.valueOf(mapCounter), String.valueOf(i));
                        mapCounter++;
                    }
                }
                
                List<String> finalList = new List<String>();
                for(Integer i = monthAPList.size()-1; i>=0;i--){
                    finalList.add(monthAPList.get(i));
                }
                monthAPList = new List<String>();
                monthAPList = finalList;
                system.debug('------------------monthNumberMap: ' + monthNumberMap);
                // my code end here//////
            }
            
        }else if(account.Net_Sales__r != null && account.Net_Sales__r.size() > 0){ //IP 26-Feb-15 Added Net Sales
            //apStartDate = account.Net_Sales__r[0].ZTS_EU_Date__c; // Commented by Sohil - logic is above
            currencyISO = account.Net_Sales__r[0].CurrencyIsoCode;
            Map<String,CurrencySymbolMapping__c> symbolsMap = CurrencySymbolMapping__c.getAll();
            for(String key : symbolsMap.keySet()){
                if(currencyISO != null && currencyISO.equalsIgnoreCase(key)){
                    currencyType = symbolsMap.get(key).Currency_Symbol__c ;
                }
            }
            List<ZTS_EU_Accounting_Period__c> listAccPeriod = [select Id, ZTS_EU_Account_Period__c from ZTS_EU_Accounting_Period__c where 
                                                               ZTS_EU_AP_Start__c <=: account.Net_Sales__r[0].ZTS_EU_Date__c and ZTS_EU_AP_End__c >=: account.Net_Sales__r[0].ZTS_EU_Date__c limit 1];
            if(listAccPeriod != null && listAccPeriod.size() > 0){
                startCounter = Integer.valueOf(listAccPeriod[0].ZTS_EU_Account_Period__c);
                
                for(Integer i = startCounter; i >= 1; i--){
                    monthAPMap.put(mapCounter, 'AP-'+i);
                    tempMonthAPMap.put(i, mapCounter);
                    mapCounter++;
                }
                if(mapCounter < 12){
                    for(Integer i = 12; i > startCounter; i--){
                        monthAPMap.put(mapCounter, 'AP-'+i);
                        tempMonthAPMap.put(i, mapCounter);
                        mapCounter++;
                    }
                }
                
                mapCounter = 1;
                Integer firstValue = tempMonthAPMap.get(startCounter);
                for(Integer i = startCounter-1; i >= 1; i--){
                    monthAPList.add('AP-'+i);
                }
                for(Integer i = 12; i >= startCounter; i--){
                    monthAPList.add('AP-'+i);
                }
                for(Integer i = firstValue; i <= 12; i++){
                    monthNumberMap.put(String.valueOf(mapCounter), String.valueOf(i));
                    mapCounter++;
                }
                
                if(mapCounter < 12){
                    for(Integer i = 1; i < firstValue; i++){ 
                        monthNumberMap.put(String.valueOf(mapCounter), String.valueOf(i));
                        mapCounter++;
                    }
                }
                
                List<String> finalList = new List<String>();
                for(Integer i = monthAPList.size()-1; i>=0;i--){
                    finalList.add(monthAPList.get(i));
                }
                monthAPList = new List<String>();
                monthAPList = finalList;
                
            }
        }else{
            apStartDate = null;
        }
    }
 
    */
    /***********
    * Method name : createQueryStr
    * Description : This will create query string for querying the sales data records.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void createQueryStr(){
        String SobjectApiName;
        if(selectedSalesType == 'Gross'){
            SobjectApiName = 'ZTS_EU_Sales__c';
        }else{
            SobjectApiName = 'ZTS_EU_Net_Sales__c';
        }
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        
        soqlQuery = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' where ';
        soqlQuery+= 'ZTS_EU_Account__c IN: accntIds  ';
    }
    
    /***********
    * Method name : queryAccData
    * Description : This method is called for toggling parent and child account on clicking the link.
    * Return Type : PageReference.
    * Parameters : None.
    ***********/
    public PageReference queryAccData() {
        //build the full sort expression
      //  system.debug('-------------------------accntParent: ' + accntParent);
        if(!isChildSelected && (monthNumberMap == null || monthNumberMap.size() <= 0)){
            accntParent = [Select Id, Name,ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c, (select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null),
                           (select id, ZTS_EU_Date__c, CurrencyIsoCode from Net_Sales__r where ZTS_EU_Date__c <> null) 
                           from Account where Id =: accntParent.Id]; //IP 26-Feb-15 Added Net Sales
            //generateSalesThroughDate();
            //generateMonthMapping(accntParent);
        }
        
        createQueryStr();
        soqlQuery+= 'AND ZTS_EU_Account__r.Name = \''+queryAccName+'\' ';
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
                List<Account> listParentAcc = [select Id, Name,ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where Id=: accntCurrent.ParentId limit 1];
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
                accntCurrent = accntParent;
                
                List<Account> listParentAcc = [select Id, Name,ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where Id=: accntCurrent.ParentId limit 1];
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
        customSetList = new List<CustomSettSalesData>();
        System.debug('Entered getCreateDataTable');
        
        
        selectedAccnt = accntCurrent.Name;
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
        Set<Id> accntIds = new Set<Id>();
        List<CustomSettSalesData> listCustomSettSalesData = new List<CustomSettSalesData>();
        List<ActualSalesDataValue> listAccntSalesDataValue;
        
        Map<Id, String> mapAccntIdAccntName =  new Map<Id, String>();
        Map<Id, String> mapAccntIdNarcId =  new Map<Id, String>();
        
        Map<String, Decimal> currentSumMap = new Map<String,Decimal>();
        Map<String, Decimal> prevSumMap = new Map<String, Decimal>();
        Map<String, Decimal> diffSumMap = new Map<String, Decimal>();
        
        List<SalesDataRestClientHelper.SalesItems> saleItemListByAccount;
        List< SalesDataRestClientHelper.SalesItems > salesItemsList = new List< SalesDataRestClientHelper.SalesItems >();
        
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
        String namedCredential = 'MiB_Sales_Inbound_Service';
        
        //Initialize the filter map and build new
        httpSvcFilterParamMap.clear();
        httpSvcFilterParamMap.put('accountId', (String)accntIds.iterator().next());
        buildHttpSvcParamMap();
        
        HttpRequest request = buildHttpRequest(namedCredential, httpSvcFilterParamMap);
        system.debug('MOHAMED: http req: ' + request );
        HTTPResponse response = getHTTPCalloutResponse(request);
        system.debug('MOHAMED: http res: ' + response );

        String strSalesDataFromRestCall;
        if(response != null)
            strSalesDataFromRestCall  = response.getBody();
        else if(runningTest){
            if(selectedReport == 'TotalSales')
              strSalesDataFromRestCall = jsonProductSales;
            else if(selectedReport == 'ProductSales')    
              strSalesDataFromRestCall = jsonProductSales;
            else if(selectedReport == 'UnitSales')
              strSalesDataFromRestCall = jsonProductSales;
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
            system.debug('Service did not return any data for this account');
            return null;              
        }
        
        
        System.debug('Returned data from REST Service: ' + strSalesDataFromRestCall);
        
        
        SalesDataRestClientHelper salesDataHelper = new SalesDataRestClientHelper(System.JSON.createParser(strSalesDataFromRestCall));          
        salesItemsList =  salesDataHelper.salesItems;
        system.debug('No of Sales Items returned: ' + salesItemsList.size());
        System.debug('Returned data from REST Service: ' + strSalesDataFromRestCall);
        system.debug('=======================salesItems: '+ salesItemsList+'\n');
        
        //this line below is only needed for testing the json result from service call. Not needed in production
        //            prettyJSON = System.JSON.serializePretty(salesDataHelper);
        //            system.debug('=======================prettyJSON: '+ prettyJSON+'\n');
        
        Map < String, List<SalesDataRestClientHelper.SalesItems>> accountSalesItemsMap = new Map<String, List<SalesDataRestClientHelper.SalesItems>>();
        String accCRMKey;
        String Salesdate;
        //setup currency symbol:
        if(salesItemsList != null && salesItemsList.size() > 0){
            setCurrencySymbol(salesItemsList[0].account.currencyIsoCode);
            apStartDate = salesItemsList[0].asOfDate;
            //apStartDate = Date.parse(Salesdate);
            //Retrieve AP Names from ServiceResult and update MonthList with it
            //Can't be sure if the records will always be in sequence so create a map and then add them to list.
            if(selectedMATYTD != 'YTD'){
                Map<Integer, String> mapAPNames = new Map<Integer, String>();
                for(SalesDataRestClientHelper.SalesRecords record : salesItemsList[0].salesRecords){
                    mapAPNames.put(record.period, record.accountingPeriod);
                }
                monthAPTitleList = new List<String>();
                for(Integer i=1; i<=12; i++){
                    monthAPTitleList.add(mapAPNames.get(i));
                }
            }
            else{
                monthAPTitleList = new List<String>();
                for(Integer i=1; i<=12; i++){
                    monthAPTitleList.add('AP-' + i);
                }
            }
            
            system.debug('monthAPTitleList: ' + monthAPTitleList);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No data returned'));
            System.debug('No sales data returned from the service for this account');
            return null;
            
        }
        
        for(SalesDataRestClientHelper.SalesItems salesItem : salesItemsList){
            accCRMKey = salesItem.account.crmTechnicalKey;
            mapAccntIdAccntName.put(accCRMKey, salesItem.account.businessName);
            mapAccntIdNarcId.put(accCRMKey, salesItem.account.erpBusinessKey);
            if(accountSalesItemsMap.get(accCRMKey) == null){
                List<SalesDataRestClientHelper.SalesItems> itemList = new List<SalesDataRestClientHelper.SalesItems>();
                itemList.add(salesItem);
                accountSalesItemsMap.put(accCRMKey, itemList);
            }
            else{
                accountSalesItemsMap.get(accCRMKey).add(salesItem); 
            }
        }
       // system.debug('accountSalesItemsMap: ' + accountSalesItemsMap);
        for(Id oaccntId : accountSalesItemsMap.keySet()){
            
            //Initialize data structures
            //
            String accName ;            
            String accId ;
            String narcId;
            SalesDataRestClientHelper.SalesItems saleItem;
            saleItemListByAccount = accountSalesItemsMap.get(oaccntId);
            CustomSettSalesData oCustomSettSalesData;
            Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
            Map<String, List<Double>> mapSalesDataTotal = new Map<String, List<Double>>();
            mapSalesDataTotal.put(System.label.ZTS_EU_Current_Year, null);
            mapSalesDataTotal.put(System.label.ZTS_EU_Previous_Year, null);
            mapSalesDataTotal.put(System.label.ZTS_EU_Diff_Sales, null);
            mapSalesDataTotal.put('%'+System.label.ZTS_EU_Diff_Sales, null);
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
            System.debug( '======================= Tab Selected ' + selectedReport + ' =======================');
            
            for(SalesDataRestClientHelper.SalesItems osalesData : saleItemListByAccount){
                
                system.debug('oSalesData: ' + osalesData);
                String productName = '';
                
                //Get the count of salesrecords in the list. In YTD scenario, there may not be all 12 records returned.
                salesRecordCount = osalesData.salesRecords.size();
                
                updateProductHierarchyMaps(osalesData);
                
                //if UnitSales tab is selected
                if(selectedReport == 'UnitSales'){
                    List<String> oaccntSalesData1a = new List<String>{getProductHierarchyValueByKey('THERAPEUTIC_GROUP', osalesData)};
                        List<String> oaccntSalesData1b = new List<String>{getProductHierarchyValueByKey('BRAND', osalesData)};
                            if(osalesData.product != null && osalesData.product.productName != null)
                                productName = osalesData.product.productName;
                            //else
                              //  productName = 'Not returned by service';
                    List<String> oaccntSalesData1c = new List<String>{productName};
                        List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year};
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
                    System.debug( '======================= Entering Total Sales Section =======================');
                    List<Double> listIntCurrent = mapSalesDataTotal.get(System.label.ZTS_EU_Current_Year);
                    List<Double> listIntPrior = mapSalesDataTotal.get(System.label.ZTS_EU_Previous_Year);
                    List<Double> listIntDollDiff = mapSalesDataTotal.get(System.label.ZTS_EU_Diff_Sales);
                    List<Double> listIntPerDiff = mapSalesDataTotal.get('%'+System.label.ZTS_EU_Diff_Sales);
                    Double intCurrent = osalesData.totalSalesRecord.currentYearSalesTotal;
                    Double intPrior = osalesData.totalSalesRecord.previousYearSalesTotal;
                    Double intDollDiff = osalesData.totalSalesRecord.diffSalesTotal;
                    Double intPerDiff = osalesData.totalSalesRecord.percDiffSalesTotal;
                    
                    
                    //System.debug( '======================= Total Sales Numbers =======================');
                    //System.debug('intCurrent: ' + intCurrent + '\n' + 'listIntPrior: ' + listIntPrior + '\n' 
                    //             + 'listIntDollDiff: ' + listIntDollDiff + '\n' + 'listIntPerDiff: ' + listIntPerDiff + '\n' );
                    
                    SalesDataRestClientHelper.SalesRecords currRec;
                    
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
                    mapSalesDataTotal.put(System.label.ZTS_EU_Current_Year,listIntCurrent);              
                    
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
                    mapSalesDataTotal.put(System.label.ZTS_EU_Previous_Year,listIntPrior); 
                    
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
                    mapSalesDataTotal.put(System.label.ZTS_EU_Diff_Sales,listIntDollDiff); 
                    
                    
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
                    mapSalesDataTotal.put('%' + System.label.ZTS_EU_Diff_Sales,listIntPerDiff); 
                    System.debug('Entering second if condition for TotalSales');
                List<String> listStr = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales,'%'+System.label.ZTS_EU_Diff_Sales};
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
                    // By Sohil Shah Added Currency Symbol(Currency Type in Total Sales Also) DEF-001063
                    //String preStrAppend = '' + currencyISO;
                    String preStrAppend = '';
                    String postStrAppend = '';
                    oaccntSalesData1total.add(oStr);
                    if(oStr == '%'+System.label.ZTS_EU_Diff_Sales){
                        postStrAppend = '%';
                        //preStrAppend = '';
                    }
                  //  System.debug('Map ' + oStr + ' count: ' + mapSalesDataTotal.get(oStr).size());
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
                    
                    
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())});                                                    
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                        }
                    }                                                
                monthNoValueMap.put('1',oaccntSalesData3total);monthNoValueMap.put('2',oaccntSalesData4total);monthNoValueMap.put('3',oaccntSalesData5total);
                monthNoValueMap.put('4',oaccntSalesData6total);monthNoValueMap.put('5',oaccntSalesData7total);monthNoValueMap.put('6',oaccntSalesData8total);
                monthNoValueMap.put('7',oaccntSalesData9total);monthNoValueMap.put('8',oaccntSalesData10total);monthNoValueMap.put('9',oaccntSalesData11total);
                monthNoValueMap.put('10',oaccntSalesData12total);monthNoValueMap.put('11',oaccntSalesData13total);monthNoValueMap.put('12',oaccntSalesData14total);
                
                system.debug('------------------------ monthNoValueMap: ' + monthNoValueMap);
                
                
                System.debug('Creating ActualSalesDataValue object');
                system.debug('----------------monthNumberMap.get12: ' + monthNumberMap.get('12')+'\n'+oaccntSalesData14total);
                
                oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1total,oaccntSalesData2total,oaccntSalesData3total,oaccntSalesData4total,oaccntSalesData5total,
                                                         oaccntSalesData6total,oaccntSalesData7total,oaccntSalesData8total,oaccntSalesData9total,oaccntSalesData10total,
                                                         oaccntSalesData11total,oaccntSalesData12total,oaccntSalesData13total,oaccntSalesData14total);
                system.debug('----------------------oAccntSalesDV: ' + oAccntSalesDV);
                listAccntSalesDataValue.add(oAccntSalesDV);
                    
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
                    
                    List<String> oaccntSalesData1a = new List<String>{getProductHierarchyValueByKey('THERAPEUTIC_GROUP', osalesData)};
                        List<String> oaccntSalesData1b = new List<String>{getProductHierarchyValueByKey('BRAND', osalesData)};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales};
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
                    
                    
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())});                                                    
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                        }
                    }                                                
                    
                    
                   // system.debug('-------------------in here--------------------');
                    
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1,oaccntSalesData2,listOfoaccntSalesData[0], listOfoaccntSalesData[1],
                                                             listOfoaccntSalesData[2],listOfoaccntSalesData[3],listOfoaccntSalesData[4],listOfoaccntSalesData[5],listOfoaccntSalesData[6],listOfoaccntSalesData[7],
                                                             listOfoaccntSalesData[8],listOfoaccntSalesData[9],listOfoaccntSalesData[10],listOfoaccntSalesData[11]);
                    
                   // system.debug('-------------------in here after call--------------------:');
                    system.debug('oaccntSalesData1a:- ' + oaccntSalesData1a);
                    system.debug('oaccntSalesData1b:- ' + oaccntSalesData1b);
                    system.debug('oaccntSalesData1:- ' + oaccntSalesData1);
                    system.debug('oaccntSalesData2:- ' + oaccntSalesData2);
                    system.debug('oAccntSalesDV:- ' + oAccntSalesDV);
                    
                    listAccntSalesDataValue.add(oAccntSalesDV);
                }     
                
            }
            if(selectedReport == 'TotalSales'){
                
            }
            oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue);
            
            listCustomSettSalesData.add(oCustomSettSalesData);
          //  system.debug('-----------------listCustomSettSalesData from REST Call: ' + listCustomSettSalesData);
        }
        
        if(salesItemsList.size()>0){
                // my code here for total
                
                if(selectedReport == 'UnitSales'){
                	List< List<String> > listOfoaccntSalesData = new List< List<String>>();
                    
                    ActualSalesDataValue oAccntSalesDV;
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(currentSumMap.get(String.valueOf(i)).format()),String.valueOf(prevSumMap.get(String.valueOf(i)).format())});                                                    
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                        }
                    }                                            
                    List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Previous_Year};
                    
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
                    system.debug('Sales Records in oSalesData: ' + salesRecordCount);
                    List<String> oaccntSalesData;
                    for(integer i=0; i<salesRecordCount; i++){
                        //oaccntSalesData = new List<String>{String.valueOf(osalesData.salesRecords[i].currentSales.format()),String.valueOf(osalesData.salesRecords[i].previousSales.format()),String.valueOf(osalesData.salesRecords[i].diffSales.format())};                                                    
                        listOfoaccntSalesData.add(new List<String>{String.valueOf(currentSumMap.get(String.valueOf(i)).format()),String.valueOf(prevSumMap.get(String.valueOf(i)).format()),String.valueOf(DiffSumMap.get(String.valueOf(i)))});                                                    
                    }
                    /**/
                    if(salesRecordCount < 12){
                        for(Integer cnt=salesRecordCount; cnt<12; cnt++){                                    
                            listOfoaccntSalesData.add(new List<String>());
                        }
                    }                                            
                    List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Total + ' '+System.label.ZTS_EU_Diff_Sales};
                    
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
    public String getProductHierarchyValueByKey(String key, SalesDataRestClientHelper.SalesItems oData){
        String value='';
        if(oData.product != null && oData.product.productHierarchies != null){
            for(SalesDataRestClientHelper.ProductHierarchies item : oData.product.productHierarchies){
      //          system.debug('key = ' + key + '\t item code: ' + item.code);
                if(key == item.code){
                    value = item.name;
                    break;
                }
            }
        }
        return value;
    }
    
    public void updateProductHierarchyMaps(SalesDataRestClientHelper.SalesItems oData){
        
        String value='';
        String phId = '';
        String key = '';
        System.debug('Entering updateProductHierarchyMaps');
        if(oData.product != null && oData.product.productHierarchies != null){
            for(SalesDataRestClientHelper.ProductHierarchies item : oData.product.productHierarchies){
                key = item.code;
                value = item.name;
                phId = item.crmTechnicalKey;
                if(key == 'BRAND'){
                    prodBrandMap.put(phId, value);   
                 //   system.debug('BRAND MAP:' + prodBrandMap);                        
                }
                else if(key == 'BUSINESS_UNITS'){
                    prodBUMap.put(phId, value);                         
                 //   system.debug('BUSINESS_UNITS MAP:' + prodBUMap);                        
                }
                else if(key == 'THERAPEUTIC_GROUP'){
                    prodThGrpMap.put(phId, value);                         
                //    system.debug('THERAPEUTIC_GROUP MAP:' + prodThGrpMap);                        
                }
            }
        }
        System.debug('Exiting updateProductHierarchyMaps');
    }
    
    public List<selectoption> buildProductHierarchyFilterListOptions(List<selectoption> optionList, Map <String, String> paramMap){
        Set<String> paramKeys = paramMap.keySet();
        String sep = '&';
        for(String key : paramKeys){
            optionList.add(new selectoption(key, paramMap.get(key)));
            
        }
        System.debug('OptionList: ' + optionList);
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
        reportTypeMap.put('UnitSales', 'SKU');
        reportTypeMap.put('ProductSales', 'BRAND');
        reportTypeMap.put('TotalSales', 'TOTAL');
        
        Map<String, String> salesTypeMap = new Map<String, String>();
        salesTypeMap.put('Gross', 'G');
        salesTypeMap.put('Net', 'N');
        
        
        //Waiting for service implementation to include these filter parameters
        httpSvcFilterParamMap.put('aggregationLevel', reportTypeMap.get(selectedReport));
        httpSvcFilterParamMap.put('target', 'INTERNATIONAL');
        
        if(selectedMATYTD == null || selectedMATYTD.length() == 0)
            selectedMATYTD = 'MAT';
        httpSvcFilterParamMap.put('selectedMATYTD', selectedMATYTD);
        
        if(selectedSalesType == null || selectedSalesType.length() == 0)
            selectedSalesType = 'Gross';
        httpSvcFilterParamMap.put('salesType', salesTypeMap.get(selectedSalesType));
        
        
        // Apply filters only when Product Sales or Unit Sales tab is selected
        if(selectedReport == 'UnitSales' || selectedReport == 'ProductSales'){
            if(selectedTherapeuticGrp != null && selectedTherapeuticGrp != '' && selectedTherapeuticGrp != '<Therapeutic Group>')
                httpSvcFilterParamMap.put('therapeuticGroupIds', selectedTherapeuticGrp);
            
            if(selectedProduct != null && selectedProduct != '' && selectedProduct != '<Product>') 
                httpSvcFilterParamMap.put('brandIds', selectedProduct);
            
            if(selectedBusinessUnit != null && selectedBusinessUnit != '' && selectedBusinessUnit != '<BusinessUnit>')
                httpSvcFilterParamMap.put('businessUnitIds', selectedBusinessUnit);
         /*if Preset is selected, then apply these filters */
                if(selectedPreset != '--None--'){
                    salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c,ZTS_EU_Sellected_Business_Unit_Ids__c, ZTS_EU_Selected_Preferred_Brands_Ids__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                    selectedMATYTD = salesPresets.ZTS_EU_Selected_Preferred_Time__c;
                
                    if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c != Null){
                      httpSvcFilterParamMap.put('therapeuticGroupIds', salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c);
                      }
                    if(salesPresets.ZTS_EU_Sellected_Business_Unit_Ids__c != Null){
                         httpSvcFilterParamMap.put('brandIds', salesPresets.ZTS_EU_Sellected_Business_Unit_Ids__c);
                    }
                    if(salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c != Null){
                        httpSvcFilterParamMap.put('businessUnitIds', salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c);
                    }
                          
                    
                }       
            
        } // End Apply filters only when Product Sales or Unit Sales tab is selected
        
        
        
        //Waiting for service implementation to include these filter parameters
        if(selectedLevelValue =='Head Office'){
            httpSvcFilterParamMap.put('accountAggregationLevel', 'HEAD_OFFICE');
        } else {
            httpSvcFilterParamMap.put('accountAggregationLevel', 'BRANCH');
        } //END
        
        
      /*  if(listAccnt[0].ZTS_EU_Market__c == 'Spain'){
            httpSvcFilterParamMap.put('aggregationLevel', 'SKU');     
        }
        else{
            httpSvcFilterParamMap.put('aggregationLevel', 'BRAND');
        }*/
        
        
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
        String queryString = buildQueryString(paramMap);
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
    * Method Name   : checkUserCurrency
    * Description   : This method will identify the currency based on user's market value
    * Return Type   : void
    * Parameters    : None
    ***********/
    private void checkUserCurrency(){
        List<User> listUser = [select ZTS_EU_Market__c,ID from User where Id=: UserInfo.getUserId()];
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
        selectedTherapeuticGrp = '<' + System.label.ZTS_EU_Therapeutic_Group + '>';
        selectedProduct = '<' + System.label.ZTS_EU_Product + '>';
        selectedSpecies = '<' + System.label.ZTS_EU_Species + '>';
        selectedBusinessUnit = '<BusinessUnit>';
        if(selectedPreset == '--None--'){
            selectedMATYTD = 'MAT';
        }
        getcreateDataTable();
    }
    
    
    /***********
    * Method name : getSalesPresetsData
    * Description : This will create Sales Preset with values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<selectOption> getSalesPresetsData() {
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesPreset = new Set<String>();
        options.add(new selectOption('--None--', '--'+ System.label.ap_None +'--'));
        for (ZTS_EU_Sales_Presets__c listSalesPresetData : [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Business_Unit__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() ORDER BY Name] ) {
            options.add(new selectOption(listSalesPresetData.name, listSalesPresetData.Name));               
        }
        return options; //return the picklist options
    }
    
    /***********
    * Method name : getTherapeuticGrp
    * Description : This will create Therapeutic Group with values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ** poulates the therapeutic group values on the new filter with the therapeutic grp values available to the users**
    ***********/
   
    public List<selectOption> getTherapeuticGrp() {
        //selectedMultiTherapeuticGrpOpt = new List<selectOption>();
        Set<String> setTheraGrp = new Set<String>();
        if(selectedMultiTherapeuticGrpOpt != null && selectedMultiTherapeuticGrpOpt.size() > 0){
            List<String> listTheraGrp = listStringPopulate(selectedMultiTherapeuticGrpOpt);
            setTheraGrp.addAll(listTheraGrp);
        }else{
            selectedMultiTherapeuticGrpOpt = new List<selectOption>();
        }
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setTherapeuticGrp = new Set<String>();
        options.add(new selectOption('<Therapeutic Group>', '<' + System.label.ZTS_EU_Therapeutic_Group + '>'));
        for (ZTS_EU_Species_Product__c listSalesData : [select Id, ZTS_EU_Type__c,Name from ZTS_EU_Species_Product__c where ZTS_EU_Type__c = 'Therapeutic Group' ORDER BY Name]) { 
            if(listSalesData.Name != Null && !setTherapeuticGrp.contains(listSalesData.Name)){
                if(setTheraGrp != null && setTheraGrp.size() > 0 && !setTheraGrp.contains(listSalesData.Name)){
                    options.add(new selectOption(listSalesData.id, listSalesData.Name)); 
                    setTherapeuticGrp.add(listSalesData.Name);
                }else if(setTheraGrp == null || setTheraGrp.size() <= 0){
                    options.add(new selectOption(listSalesData.id, listSalesData.Name)); 
                    setTherapeuticGrp.add(listSalesData.name);
                }
            }
        }
        return options;
        
        
    }
    
    
    /***********
    * Method name : getTherapeuticGrpList
    * Description : This will create Therapeutic Group with values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<selectOption> getTherapeuticGrpList() { 
        List<selectOption> options;
        options = new List<selectOption>(); 
        Set<String> setTherapeuticGrp = new Set<String>();
        options.add(new selectOption('<Therapeutic Group>', '<' + System.label.ZTS_EU_Therapeutic_Group + '>'));
        try{
            //system.debug('retrieving therapeutic group options');
            options = buildProductHierarchyFilterListOptions(options, prodThGrpMap);
            
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
    * Method name : getSalesDataProd
    * Description : This will create Product filter values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
  
    public List<selectOption> getSalesDataProd() {
        
        Set<String> setProdData = new Set<String>();
        if(selectedMultiProductOpt != null && selectedMultiProductOpt.size() > 0){
            List<String> listProdData = listStringPopulate(selectedMultiProductOpt);
            setProdData.addAll(listProdData);
        }else{
            selectedMultiProductOpt = new List<selectOption>();
        }
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesDataProd = new Set<String>();
        options.add(new selectOption('<Product>', '<' + System.label.ZTS_EU_Product + '>'));
        for (ZTS_EU_Species_Product__c listSalesData : [select Id, ZTS_EU_Type__c,Name from ZTS_EU_Species_Product__c where ZTS_EU_Type__c = 'Brand' ORDER BY Name]) { 
            if(listSalesData.Name != Null && !setSalesDataProd.contains(listSalesData.Name)){
                if(setProdData != null && setProdData.size() > 0 && !setProdData.contains(listSalesData.Name)){
                    options.add(new selectOption(listSalesData.Id, listSalesData.Name)); 
                    setSalesDataProd.add(listSalesData.Name);
                }else if(setProdData == null || setProdData.size() <= 0){
                    options.add(new selectOption(listSalesData.Id, listSalesData.Name)); 
                    setSalesDataProd.add(listSalesData.name);
                }
            }
        }
        return options; //return the picklist options
    }
    
    
    /***********
    * Method name : getSalesDataProdList
    * Description : This will create Product filter values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<selectOption> getSalesDataProdList() {
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesDataProd = new Set<String>();
        options.add(new selectOption('<Product>', '<' + System.label.ZTS_EU_Product + '>'));
        try{
            //system.debug('retrieving product/brand options');
            options = buildProductHierarchyFilterListOptions(options, prodBrandMap);
            
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
    * Method name : getSalesSpecies
    * Description : This will create Species filter values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
  
    public List<selectOption> getSalesSpecies() {
        
        Set<String> setSpeciesData = new Set<String>();
        if(selectedMultiSpeciesOpt != null && selectedMultiSpeciesOpt.size() > 0){
            List<String> listSpeciesData = listStringPopulate(selectedMultiSpeciesOpt);
            setSpeciesData.addAll(listSpeciesData);
        }else{
            selectedMultiSpeciesOpt = new List<selectOption>();
        }
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesSpeciesData = new Set<String>();
        options.add(new selectOption('<Species>', '<' + System.label.ZTS_EU_Species + '>'));
        for (ZTS_EU_Species__c listSalesData : [select Id, ZTS_EU_Species__c,Name,ZTS_EU_Business_Unit__c from ZTS_EU_Species__c ORDER BY ZTS_EU_Species__c]) { 
            if(listSalesData.ZTS_EU_Species__c != Null && !setSalesSpeciesData.contains(listSalesData.ZTS_EU_Species__c)){
                if(setSpeciesData != null && setSpeciesData.size() > 0 && !setSpeciesData.contains(listSalesData.ZTS_EU_Species__c)){
                    options.add(new selectOption(listSalesData.ZTS_EU_Species__c, listSalesData.ZTS_EU_Species__c)); 
                    setSalesSpeciesData.add(listSalesData.ZTS_EU_Species__c);
                }else if(setSpeciesData == null || setSpeciesData.size() <= 0){
                    options.add(new selectOption(listSalesData.ZTS_EU_Species__c, listSalesData.ZTS_EU_Species__c)); 
                    setSalesSpeciesData.add(listSalesData.ZTS_EU_Species__c);
                }
            }
        }
        return options; //return the picklist options
    }
    
    
    /***********
    * Method name : getSalesSpeciesList
    * Description : This will create Species filter values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    
    public List<selectOption> getSalesSpeciesList() {
        
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSpecies = new Set<String>();
        options.add(new selectOption('<Species>', '<' + System.label.ZTS_EU_Species + '>'));
        for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Species__c from ZTS_EU_Sales__c where ZTS_EU_Account__r.Name =: selectedAccnt  AND ZTS_EU_IsDataFromBatchJob__c = false ORDER BY ZTS_EU_Species__c]) {                 
            if(listSalesData.ZTS_EU_Species__c != Null && !setSpecies.contains(listSalesData.ZTS_EU_Species__c)){
                options.add(new selectOption(listSalesData.ZTS_EU_Species__c, listSalesData.ZTS_EU_Species__c)); 
                setSpecies.add(listSalesData.ZTS_EU_Species__c);
            }
        }
        return options; //return the picklist options
    }
    
    /***********
    * Method name : getBusinessUnitsList
    * Description : This will create Species filter values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<selectOption> getBusinessUnitsList() {
        
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setBusinessUnits = new Set<String>();
        List<String> allBUList;
        options.add(new selectOption('<BusinessUnit>', '<' + System.label.ZTS_EU_Business_Units + '>'));
        
        try{
           // system.debug('retrieving business units options');
            options = buildProductHierarchyFilterListOptions(options, prodBUMap);
            
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
    * Method name : getSalesBusinessUnits
    * Description : This will create Business Unit filter values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    
    public List<selectOption> getSalesBusinessUnits() {
        
        Set<String> setBUData = new Set<String>();
        List<String> allBUList;
        if(selectedMultiBusinessUnitOpt != null && selectedMultiBusinessUnitOpt.size() > 0){
            List<String> listBusinessData = listStringPopulate(selectedMultiBusinessUnitOpt);
            for(String str: listBusinessData){
                List<String> strList = str.split(' ');
                for(String bu: strList){
                    setBUData.add(bu);
                }
            }
        }else{
            selectedMultiBusinessUnitOpt = new List<selectOption>();
        }
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesBUData = new Set<String>();
        options.add(new selectOption('<BusinessUnit>', '<' + System.label.ZTS_EU_Business_Units + '>'));
        for (ZTS_EU_Species_Product__c listSalesData : [select Id, ZTS_EU_Business_Units__c,Name from ZTS_EU_Species_Product__c ORDER BY ZTS_EU_Business_Units__c 
                                                        limit: Limits.getLimitQueryRows() - Limits.getQueryRows()]) { 
                                                            if(listSalesData.ZTS_EU_Business_Units__c != Null && !setBUData.contains(listSalesData.ZTS_EU_Business_Units__c)){
                                                                allBUList = listSalesData.ZTS_EU_Business_Units__c.split(' ');
                                                                for(String bu: allBUList){
                                                                    if(setBUData != null && setBUData.size() > 0 && !setBUData.contains(bu) && bu != null && bu != '' && bu != '\n'){
                                                                        options.add(new selectOption(bu, bu)); 
                                                                        setBUData.add(bu);
                                                                    }else if(setBUData == null || setBUData.size() <= 0 && bu != null && bu != '' && bu != '\n'){
                                                                        options.add(new selectOption(bu, bu)); 
                                                                        setBUData.add(bu);
                                                                    }
                                                                }
                                                            }
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
        options.add(new SelectOption('Bill-To',System.label.ZTS_EU_Bill_To));
        options.add(new SelectOption('Ship-To',System.label.ZTS_EU_Ship_To));
        return options;
    }
    
    /***********
    * Method name : getradioOptionsSales
    * Description : This will create radio button values for Bill-To,Ship-To.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<SelectOption> getradioOptionsSales() { 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Gross',System.label.ZTS_EU_Gross_Price));
        options.add(new SelectOption('Net',System.label.ZTS_EU_Net_Price));
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
        options.add(new SelectOption('Branch',system.label.ZTS_EU_Branch,false));   // code Modified by Shefali
        options.add(new SelectOption('Head Office',system.label.ZTS_EU_Head_Office,false));  // code Modified by Shefali
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
        listAccnt=[Select Id, Name,ParentId,ZTS_EU_Market__c, ZTS_EU_Loyalty_Flag__c from Account where ID =: accntRec.Id];
        if(listAccnt[0].ParentId != null){
            isChild=true;
        }else{
            isChild=false;
        }
    }
    
    /***********
    * Method name : generateUnitSalesPdf
    * Description : This method is called for pdf functionality on UnitSales Tab.
    * Return Type : pagereference.
    * Parameters : None.
    ***********/
    public PageReference generateUnitSalesPdf(){
        PageReference  pg=new PageReference('/apex/ZTS_EU_IXHUnitSalesPdf');
        pg.setRedirect(false);
        return  pg;
    }
    
    /***********
    * Method name : DownloadUnitSalesExcel
    * Description : This method is called for excel functionality on UnitSales Tab.
    * Return Type : pagereference.
    * Parameters : None.
    ***********/
    //Download Method to download Table Data in Excel Sheet
   public pagereference DownloadUnitSalesExcel(){
        PageReference pg=new PageReference('/apex/ZTS_EU_IXHUnitSalesExcelDownload');
        pg.setRedirect(false);
        return  pg;
    }
    
    /***********
    * Method name : generateProductSalesPdf
    * Description : This method is called for pdf functionality on ProductSales Tab.
    * Return Type : pagereference.
    * Parameters : None.
    ***********/
    public PageReference generateProductSalesPdf(){
        PageReference  pg=new PageReference('/apex/ZTS_EU_IXHProductSalesPdf');
        pg.setRedirect(false);
        return  pg;
    }
    
    /***********
    * Method name : DownloadProductSalesExcel
    * Description : This method is called for excel functionality on ProductSales Tab.
    * Return Type : pagereference.
    * Parameters : None.
    ***********/
    //Download Method to download Table Data in Excel Sheet
    public pagereference DownloadProductSalesExcel(){    
        PageReference pg=new PageReference('/apex/ZTS_EU_IXHProductSalesExcelDownload');
        pg.setRedirect(false);
        return  pg;
    }
    
    /***********
    * Method name : generateTotalSalesPdf
    * Description : This method is called for pdf functionality on TotalSales Tab.
    * Return Type : pagereference.
    * Parameters : None.
    ***********/
    public PageReference generateTotalSalesPdf(){
        PageReference  pg=new PageReference('/apex/ZTS_EU_IXHTotalSalesPdf');
        pg.setRedirect(false);
        return  pg;
    }
    
    /***********
    * Method name : DownloadTotalSalesExcel
    * Description : This method is called for excel functionality on TotalSales Tab.
    * Return Type : pagereference.
    * Parameters : None.
    ***********/
    //Download Method to download Table Data in Excel Sheet
    public pagereference DownloadTotalSalesExcel(){
        PageReference pg=new PageReference('/apex/ZTS_EU_IXHTotalSalesExcelDownload');
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
                salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c,ZTS_EU_Selected_Preferred_Brands_Ids__c, ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c,ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Business_Unit__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c != Null){
                    selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                    selectedMultiTherapeuticGrp1 = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c.split(';');
                    if(selectedMultiTherapeuticGrp1 != Null && selectedMultiTherapeuticGrp1.size()>0){
                  
                        for (integer i = 0; i < selectedMultiTherapeuticGrp1.size(); i++) {
                MultiTherapeuticGrp.put(selectedMultiTherapeuticGrp1.get(i), selectedMultiTherapeuticGrp.get(i));
             }
             selectedMultiTherapeuticGrpOpt = listSelOptPopulate1(MultiTherapeuticGrp);
                    }
                }
                
                if(salesPresets.ZTS_EU_Selected_Preferred_Brands__c != Null){
                    selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                    selectedMultiProduct1 = salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c.split(';');
                    if(selectedMultiProduct1 != Null && selectedMultiProduct1.size()>0){
                    
                      for (integer i = 0; i < selectedMultiProduct1.size(); i++) {
                MultiProduct.put(selectedMultiProduct1.get(i), selectedMultiProduct.get(i));
            }
            selectedMultiProductOpt = listSelOptPopulate1(MultiProduct);
                    }    
                }
                if(salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c != Null)
                    selectedMultiSpecies = salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c.split(';');
                
                
                system.debug('selectedMultiProductOpt >>>>>>>>>>>>>>>>>>>>>>>'+selectedMultiProductOpt);
                if(selectedMultiSpecies != Null && selectedMultiProduct.size()>0){
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
   
    /***********
    * Method name : savePreferences
    * Description : This method is called from salesPresets popup save button.
    * Return Type : void.
    * Parameters : None.
    ***********/
    public void savePreferences() {        
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
        if(selectedMultiSpeciesOpt!=null)
            selectedMultiSpecies = listStringPopulate(selectedMultiSpeciesOpt);
        if(selectedMultiBusinessUnitOpt != null){
            List<String> buList = listStringPopulate(selectedMultiBusinessUnitOpt);
            for(String bu: buList){
                selectedMultiBusinessUnits.add(bu);
            }
        }
        if(salesPresetAction == 'New'){
            ZTS_EU_Sales_Presets__c newSalesPresets = new ZTS_EU_Sales_Presets__c();
            newSalesPresets.Name = salesPresets.Name;
            newSalesPresets.ZTS_EU_Selected_GLR_Type__c = salesPresets.ZTS_EU_Selected_GLR_Type__c;
            newSalesPresets.ZTS_EU_Selected_Preferred_Time__c = salesPresets.ZTS_EU_Selected_Preferred_Time__c;
            newSalesPresets.ZTS_EU_User__c = UserInfo.getUserId();
            if(selectedMultiTherapeuticGrp!=null){
                newSalesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c = multiSelectPopulate(listStringPopulate(selectedMultiTherapeuticGrpOpt));
                newSalesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = multiSelectPopulate(listStringPopulate1(selectedMultiTherapeuticGrpOpt));
            }
            if(selectedMultiProduct!=null){
                newSalesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c = multiSelectPopulate(listStringPopulate(selectedMultiProductOpt));
                newSalesPresets.ZTS_EU_Selected_Preferred_Brands__c = multiSelectPopulate(listStringPopulate1(selectedMultiProductOpt));
            }
            if(selectedMultiBusinessUnits!=null){
                newSalesPresets.ZTS_EU_Sellected_Business_Unit_Ids__c = multiSelectPopulate(selectedMultiBusinessUnits);
                newSalesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c = multiSelectPopulate(selectedMultiBusinessUnits);
            }
            system.debug('----------------newSalesPresets: ' + newSalesPresets);
            insert newSalesPresets;
            selectedPreset = newSalesPresets.Name;
            multiSelectedValueQuery();
        }
        if(salesPresetAction == 'Delete' && salesPresets != Null){
            delete salesPresets;
            selectedPreset = '--None--';
            multiSelectedValueQuery();
        }
        if(salesPresetAction == 'Edit' && salesPresets != Null){
            if(selectedMultiTherapeuticGrp!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps_Ids__c = multiSelectPopulate(listStringPopulate(selectedMultiTherapeuticGrpOpt));
                SalesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = multiSelectPopulate(listStringPopulate1(selectedMultiTherapeuticGrpOpt));
            }
            if(selectedMultiProduct!=null){
                salesPresets.ZTS_EU_Selected_Preferred_Brands_Ids__c = multiSelectPopulate(listStringPopulate(selectedMultiProductOpt));
                SalesPresets.ZTS_EU_Selected_Preferred_Brands__c = multiSelectPopulate(listStringPopulate1(selectedMultiProductOpt));
            }
            if(selectedMultiBusinessUnits!=null){
                salesPresets.ZTS_EU_Sellected_Business_Unit_Ids__c = multiSelectPopulate(selectedMultiBusinessUnits);
                SalesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c = multiSelectPopulate(selectedMultiBusinessUnits);
            }
            update salesPresets;
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
    private String sortExp = 'ZTS_EU_Account__r.Name';
    
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
        createQueryStr();
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
        Public String accntName{get;set;}       
        Public String accntId{get;set;}
        Public String narcId{get;set;}  
        Public List<ActualSalesDataValue> salesDataWrapp{get;set;}
        
        public CustomSettSalesData(String narcId, String accntId, String accntName, List<ActualSalesDataValue> salesDataWrapp){
            this.salesDataWrapp = salesDataWrapp;
            this.accntName= accntName; 
            this.narcId= narcId;
            this.accntId= accntId;      
            
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
    
    /***********
    * Variable name : json
    * Description : This variable holds the dummy string for testing purpose 
    * to parse the results returned from REST call. To be deleted once the REST call is live
    ***********/
    
/*
     String jsonTotalSales = '\"salesItems\": ['+
    '    {'+
    '      \"name\": \"dummy account\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"TOTAL\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy account\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"EUR\"'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 108236,'+
    '          \"currentUnits\": 49151,'+
    '          \"previousSales\": 106427,'+
    '          \"previousUnits\": 51883,'+
    '          \"diffSales\": 1809,'+
    '          \"diffUnits\": -2732,'+
    '          \"percDiffSales\": 1.7,'+
    '          \"percDiffUnits\": -5.27'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 101834,'+
    '          \"currentUnits\": 54667,'+
    '          \"previousSales\": 106610,'+
    '          \"previousUnits\": 61456,'+
    '          \"diffSales\": -4776,'+
    '          \"diffUnits\": -6789,'+
    '          \"percDiffSales\": -4.48,'+
    '          \"percDiffUnits\": -11.05'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 114777,'+
    '          \"currentUnits\": 47740,'+
    '          \"previousSales\": 104399,'+
    '          \"previousUnits\": 47793,'+
    '          \"diffSales\": 10378,'+
    '          \"diffUnits\": -53,'+
    '          \"percDiffSales\": 9.94,'+
    '          \"percDiffUnits\": -0.11'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 104926,'+
    '          \"currentUnits\": 47960,'+
    '          \"previousSales\": 103478,'+
    '          \"previousUnits\": 51105,'+
    '          \"diffSales\": 1448,'+
    '          \"diffUnits\": -3145,'+
    '          \"percDiffSales\": 1.4,'+
    '          \"percDiffUnits\": -6.15'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 104145,'+
    '          \"currentUnits\": 46988,'+
    '          \"previousSales\": 105380,'+
    '          \"previousUnits\": 56453,'+
    '          \"diffSales\": -1235,'+
    '          \"diffUnits\": -9465,'+
    '          \"percDiffSales\": -1.17,'+
    '          \"percDiffUnits\": -16.77'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 117067,'+
    '          \"currentUnits\": 41423,'+
    '          \"previousSales\": 111211,'+
    '          \"previousUnits\": 55619,'+
    '          \"diffSales\": 5856,'+
    '          \"diffUnits\": -14196,'+
    '          \"percDiffSales\": 5.27,'+
    '          \"percDiffUnits\": -25.52'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 115879,'+
    '          \"currentUnits\": 49974,'+
    '          \"previousSales\": 104284,'+
    '          \"previousUnits\": 51399,'+
    '          \"diffSales\": 11595,'+
    '          \"diffUnits\": -1425,'+
    '          \"percDiffSales\": 11.12,'+
    '          \"percDiffUnits\": -2.77'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 101252,'+
    '          \"currentUnits\": 55867,'+
    '          \"previousSales\": 102114,'+
    '          \"previousUnits\": 64484,'+
    '          \"diffSales\": -862,'+
    '          \"diffUnits\": -8617,'+
    '          \"percDiffSales\": -0.84,'+
    '          \"percDiffUnits\": -13.36'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 107421,'+
    '          \"currentUnits\": 50014,'+
    '          \"previousSales\": 112263,'+
    '          \"previousUnits\": 57139,'+
    '          \"diffSales\": -4842,'+
    '          \"diffUnits\": -7125,'+
    '          \"percDiffSales\": -4.31,'+
    '          \"percDiffUnits\": -12.47'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 110530,'+
    '          \"currentUnits\": 49625,'+
    '          \"previousSales\": 114197,'+
    '          \"previousUnits\": 46124,'+
    '          \"diffSales\": -3667,'+
    '          \"diffUnits\": 3501,'+
    '          \"percDiffSales\": -3.21,'+
    '          \"percDiffUnits\": 7.59'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 117396,'+
    '          \"currentUnits\": 56510,'+
    '          \"previousSales\": 103385,'+
    '          \"previousUnits\": 52028,'+
    '          \"diffSales\": 14011,'+
    '          \"diffUnits\": 4482,'+
    '          \"percDiffSales\": 13.55,'+
    '          \"percDiffUnits\": 8.61'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 108223,'+
    '          \"currentUnits\": 51376,'+
    '          \"previousSales\": 108068,'+
    '          \"previousUnits\": 58320,'+
    '          \"diffSales\": 155,'+
    '          \"diffUnits\": -6944,'+
    '          \"percDiffSales\": 0.14,'+
    '          \"percDiffUnits\": -11.91'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 1311686,'+
    '        \"previousYearSalesTotal\": 1281816,'+
    '        \"diffSalesTotal\": 29870,'+
    '        \"percDiffSalesTotal\": 2.33,'+
    '        \"currentYearUnitTotal\": 601295,'+
    '        \"previousYearUnitTotal\": 653803'+
    '      }'+
    '    }'+
    '  ]'+
    '}';
*/
    String jsonProductSales = '{\"salesItems\": ['+
    '    {'+
    '      \"name\": \"dummy account - Other Health Feed - Poultry\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy account\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"EUR\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"Other Health Feed - Poultry - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPc&amp;pv1=Other Health Feed - Poultry\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPc&amp;pv1=Other Health Feed - Poultry\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOPcAAO\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"Other Health Feed - Poultry\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQAAA4\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"Poultry Bios\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 36020,'+
    '          \"currentUnits\": 19192,'+
    '          \"previousSales\": 34642,'+
    '          \"previousUnits\": 22178,'+
    '          \"diffSales\": 1378,'+
    '          \"diffUnits\": -2986,'+
    '          \"percDiffSales\": 3.98,'+
    '          \"percDiffUnits\": -13.46'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 32689,'+
    '          \"currentUnits\": 22159,'+
    '          \"previousSales\": 35435,'+
    '          \"previousUnits\": 24594,'+
    '          \"diffSales\": -2746,'+
    '          \"diffUnits\": -2435,'+
    '          \"percDiffSales\": -7.75,'+
    '          \"percDiffUnits\": -9.9'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 37320,'+
    '          \"currentUnits\": 16455,'+
    '          \"previousSales\": 33396,'+
    '          \"previousUnits\": 14954,'+
    '          \"diffSales\": 3924,'+
    '          \"diffUnits\": 1501,'+
    '          \"percDiffSales\": 11.75,'+
    '          \"percDiffUnits\": 10.04'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 36286,'+
    '          \"currentUnits\": 14417,'+
    '          \"previousSales\": 37346,'+
    '          \"previousUnits\": 19761,'+
    '          \"diffSales\": -1060,'+
    '          \"diffUnits\": -5344,'+
    '          \"percDiffSales\": -2.84,'+
    '          \"percDiffUnits\": -27.04'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 36541,'+
    '          \"currentUnits\": 16132,'+
    '          \"previousSales\": 35183,'+
    '          \"previousUnits\": 21125,'+
    '          \"diffSales\": 1358,'+
    '          \"diffUnits\": -4993,'+
    '          \"percDiffSales\": 3.86,'+
    '          \"percDiffUnits\": -23.64'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 41229,'+
    '          \"currentUnits\": 16208,'+
    '          \"previousSales\": 34479,'+
    '          \"previousUnits\": 17297,'+
    '          \"diffSales\": 6750,'+
    '          \"diffUnits\": -1089,'+
    '          \"percDiffSales\": 19.58,'+
    '          \"percDiffUnits\": -6.3'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 37288,'+
    '          \"currentUnits\": 16435,'+
    '          \"previousSales\": 33074,'+
    '          \"previousUnits\": 21015,'+
    '          \"diffSales\": 4214,'+
    '          \"diffUnits\": -4580,'+
    '          \"percDiffSales\": 12.74,'+
    '          \"percDiffUnits\": -21.79'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 35362,'+
    '          \"currentUnits\": 21737,'+
    '          \"previousSales\": 33535,'+
    '          \"previousUnits\": 26261,'+
    '          \"diffSales\": 1827,'+
    '          \"diffUnits\": -4524,'+
    '          \"percDiffSales\": 5.45,'+
    '          \"percDiffUnits\": -17.23'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 33424,'+
    '          \"currentUnits\": 20029,'+
    '          \"previousSales\": 39959,'+
    '          \"previousUnits\": 23354,'+
    '          \"diffSales\": -6535,'+
    '          \"diffUnits\": -3325,'+
    '          \"percDiffSales\": -16.35,'+
    '          \"percDiffUnits\": -14.24'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 37324,'+
    '          \"currentUnits\": 16974,'+
    '          \"previousSales\": 42080,'+
    '          \"previousUnits\": 18242,'+
    '          \"diffSales\": -4756,'+
    '          \"diffUnits\": -1268,'+
    '          \"percDiffSales\": -11.3,'+
    '          \"percDiffUnits\": -6.95'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 39658,'+
    '          \"currentUnits\": 22403,'+
    '          \"previousSales\": 37865,'+
    '          \"previousUnits\": 24577,'+
    '          \"diffSales\": 1793,'+
    '          \"diffUnits\": -2174,'+
    '          \"percDiffSales\": 4.74,'+
    '          \"percDiffUnits\": -8.85'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 36891,'+
    '          \"currentUnits\": 17548,'+
    '          \"previousSales\": 33426,'+
    '          \"previousUnits\": 23737,'+
    '          \"diffSales\": 3465,'+
    '          \"diffUnits\": -6189,'+
    '          \"percDiffSales\": 10.37,'+
    '          \"percDiffUnits\": -26.07'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 440032,'+
    '        \"previousYearSalesTotal\": 430420,'+
    '        \"diffSalesTotal\": 9612,'+
    '        \"percDiffSalesTotal\": 2.23,'+
    '        \"currentYearUnitTotal\": 219689,'+
    '        \"previousYearUnitTotal\": 257095'+
    '      }'+
    '    },'+
    '    {'+
    '      \"name\": \"dummy account - FD Swine Yelcin\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"TWD\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"FD Swine Yelcin - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQW&amp;pv1=FD Swine Yelcin\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQW&amp;pv1=FD Swine Yelcin\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQWAA4\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"FD Swine Yelcin\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQ5AAO\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"Other\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 10543,'+
    '          \"currentUnits\": 6561,'+
    '          \"previousSales\": 11598,'+
    '          \"previousUnits\": 4055,'+
    '          \"diffSales\": -1055,'+
    '          \"diffUnits\": 2506,'+
    '          \"percDiffSales\": -9.1,'+
    '          \"percDiffUnits\": 61.8'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 10244,'+
    '          \"currentUnits\": 5721,'+
    '          \"previousSales\": 12188,'+
    '          \"previousUnits\": 6204,'+
    '          \"diffSales\": -1944,'+
    '          \"diffUnits\": -483,'+
    '          \"percDiffSales\": -15.95,'+
    '          \"percDiffUnits\": -7.79'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 12380,'+
    '          \"currentUnits\": 7444,'+
    '          \"previousSales\": 10376,'+
    '          \"previousUnits\": 8138,'+
    '          \"diffSales\": 2004,'+
    '          \"diffUnits\": -694,'+
    '          \"percDiffSales\": 19.31,'+
    '          \"percDiffUnits\": -8.53'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 12647,'+
    '          \"currentUnits\": 7205,'+
    '          \"previousSales\": 10641,'+
    '          \"previousUnits\": 6490,'+
    '          \"diffSales\": 2006,'+
    '          \"diffUnits\": 715,'+
    '          \"percDiffSales\": 18.85,'+
    '          \"percDiffUnits\": 11.02'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 10504,'+
    '          \"currentUnits\": 6342,'+
    '          \"previousSales\": 10304,'+
    '          \"previousUnits\": 7587,'+
    '          \"diffSales\": 200,'+
    '          \"diffUnits\": -1245,'+
    '          \"percDiffSales\": 1.94,'+
    '          \"percDiffUnits\": -16.41'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 9822,'+
    '          \"currentUnits\": 4548,'+
    '          \"previousSales\": 12341,'+
    '          \"previousUnits\": 7110,'+
    '          \"diffSales\": -2519,'+
    '          \"diffUnits\": -2562,'+
    '          \"percDiffSales\": -20.41,'+
    '          \"percDiffUnits\": -36.03'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 12778,'+
    '          \"currentUnits\": 8143,'+
    '          \"previousSales\": 11154,'+
    '          \"previousUnits\": 5836,'+
    '          \"diffSales\": 1624,'+
    '          \"diffUnits\": 2307,'+
    '          \"percDiffSales\": 14.56,'+
    '          \"percDiffUnits\": 39.53'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 11572,'+
    '          \"currentUnits\": 8545,'+
    '          \"previousSales\": 13311,'+
    '          \"previousUnits\": 7802,'+
    '          \"diffSales\": -1739,'+
    '          \"diffUnits\": 743,'+
    '          \"percDiffSales\": -13.06,'+
    '          \"percDiffUnits\": 9.52'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 12053,'+
    '          \"currentUnits\": 8318,'+
    '          \"previousSales\": 11782,'+
    '          \"previousUnits\": 4394,'+
    '          \"diffSales\": 271,'+
    '          \"diffUnits\": 3924,'+
    '          \"percDiffSales\": 2.3,'+
    '          \"percDiffUnits\": 89.3'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 14343,'+
    '          \"currentUnits\": 5495,'+
    '          \"previousSales\": 12306,'+
    '          \"previousUnits\": 4361,'+
    '          \"diffSales\": 2037,'+
    '          \"diffUnits\": 1134,'+
    '          \"percDiffSales\": 16.55,'+
    '          \"percDiffUnits\": 26'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 14547,'+
    '          \"currentUnits\": 6543,'+
    '          \"previousSales\": 11220,'+
    '          \"previousUnits\": 6249,'+
    '          \"diffSales\": 3327,'+
    '          \"diffUnits\": 294,'+
    '          \"percDiffSales\": 29.65,'+
    '          \"percDiffUnits\": 4.7'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 10682,'+
    '          \"currentUnits\": 5691,'+
    '          \"previousSales\": 13853,'+
    '          \"previousUnits\": 5892,'+
    '          \"diffSales\": -3171,'+
    '          \"diffUnits\": -201,'+
    '          \"percDiffSales\": -22.89,'+
    '          \"percDiffUnits\": -3.41'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 142115,'+
    '        \"previousYearSalesTotal\": 141074,'+
    '        \"diffSalesTotal\": 1041,'+
    '        \"percDiffSalesTotal\": 0.74,'+
    '        \"currentYearUnitTotal\": 80556,'+
    '        \"previousYearUnitTotal\": 74118'+
    '      }'+
    '    },'+
    '    {'+
    '      \"name\": \"dummy - Other Agricultural Products-Cattle\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"TWD\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"Other Agricultural Products-Cattle - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQZ&amp;pv1=Other Agricultural Products-Cattle\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOQZ&amp;pv1=Other Agricultural Products-Cattle\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQZAA4\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"Other Agricultural Products-Cattle\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOQ5AAO\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"Other\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 48737,'+
    '          \"currentUnits\": 17847,'+
    '          \"previousSales\": 49194,'+
    '          \"previousUnits\": 20995,'+
    '          \"diffSales\": -457,'+
    '          \"diffUnits\": -3148,'+
    '          \"percDiffSales\": -0.93,'+
    '          \"percDiffUnits\": -14.99'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 47178,'+
    '          \"currentUnits\": 20261,'+
    '          \"previousSales\": 48524,'+
    '          \"previousUnits\": 22782,'+
    '          \"diffSales\": -1346,'+
    '          \"diffUnits\": -2521,'+
    '          \"percDiffSales\": -2.77,'+
    '          \"percDiffUnits\": -11.07'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 51972,'+
    '          \"currentUnits\": 16810,'+
    '          \"previousSales\": 49258,'+
    '          \"previousUnits\": 19537,'+
    '          \"diffSales\": 2714,'+
    '          \"diffUnits\": -2727,'+
    '          \"percDiffSales\": 5.51,'+
    '          \"percDiffUnits\": -13.96'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 43237,'+
    '          \"currentUnits\": 18561,'+
    '          \"previousSales\": 44853,'+
    '          \"previousUnits\": 18688,'+
    '          \"diffSales\": -1616,'+
    '          \"diffUnits\": -127,'+
    '          \"percDiffSales\": -3.6,'+
    '          \"percDiffUnits\": -0.68'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 43695,'+
    '          \"currentUnits\": 19894,'+
    '          \"previousSales\": 45943,'+
    '          \"previousUnits\": 23445,'+
    '          \"diffSales\": -2248,'+
    '          \"diffUnits\": -3551,'+
    '          \"percDiffSales\": -4.89,'+
    '          \"percDiffUnits\": -15.15'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 50937,'+
    '          \"currentUnits\": 16545,'+
    '          \"previousSales\": 50699,'+
    '          \"previousUnits\": 22426,'+
    '          \"diffSales\": 238,'+
    '          \"diffUnits\": -5881,'+
    '          \"percDiffSales\": 0.47,'+
    '          \"percDiffUnits\": -26.22'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 50990,'+
    '          \"currentUnits\": 20001,'+
    '          \"previousSales\": 46829,'+
    '          \"previousUnits\": 17672,'+
    '          \"diffSales\": 4161,'+
    '          \"diffUnits\": 2329,'+
    '          \"percDiffSales\": 8.89,'+
    '          \"percDiffUnits\": 13.18'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 42917,'+
    '          \"currentUnits\": 19162,'+
    '          \"previousSales\": 44350,'+
    '          \"previousUnits\": 22178,'+
    '          \"diffSales\": -1433,'+
    '          \"diffUnits\": -3016,'+
    '          \"percDiffSales\": -3.23,'+
    '          \"percDiffUnits\": -13.6'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 48234,'+
    '          \"currentUnits\": 13947,'+
    '          \"previousSales\": 46833,'+
    '          \"previousUnits\": 20452,'+
    '          \"diffSales\": 1401,'+
    '          \"diffUnits\": -6505,'+
    '          \"percDiffSales\": 2.99,'+
    '          \"percDiffUnits\": -31.81'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 43914,'+
    '          \"currentUnits\": 20421,'+
    '          \"previousSales\": 46725,'+
    '          \"previousUnits\": 19317,'+
    '          \"diffSales\": -2811,'+
    '          \"diffUnits\": 1104,'+
    '          \"percDiffSales\": -6.02,'+
    '          \"percDiffUnits\": 5.72'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 48622,'+
    '          \"currentUnits\": 20246,'+
    '          \"previousSales\": 42889,'+
    '          \"previousUnits\": 16748,'+
    '          \"diffSales\": 5733,'+
    '          \"diffUnits\": 3498,'+
    '          \"percDiffSales\": 13.37,'+
    '          \"percDiffUnits\": 20.89'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 46157,'+
    '          \"currentUnits\": 20069,'+
    '          \"previousSales\": 47357,'+
    '          \"previousUnits\": 20505,'+
    '          \"diffSales\": -1200,'+
    '          \"diffUnits\": -436,'+
    '          \"percDiffSales\": -2.53,'+
    '          \"percDiffUnits\": -2.13'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 566590,'+
    '        \"previousYearSalesTotal\": 563454,'+
    '        \"diffSalesTotal\": 3136,'+
    '        \"percDiffSalesTotal\": 0.56,'+
    '        \"currentYearUnitTotal\": 223764,'+
    '        \"previousYearUnitTotal\": 244745'+
    '      }'+
    '    },'+
    '    {'+
    '      \"name\": \"dummy - Rimadyl Chewable\",'+
    '      \"market\": \"Taiwan\",'+
    '      \"marketIsoCode\": \"TW\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"BRAND\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016\\/03\\/30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"TWN-\",'+
    '        \"srcBusinessKey\": \"301210\",'+
    '        \"crmTechnicalKey\": \"001230000030KasAAE\",'+
    '        \"businessName\": \"dummy\",'+
    '        \"accountType\": \"Vet Practice\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"TWD\"'+
    '      },'+
    '      \"product\": {'+
    '        \"productNameAndReportUri\": \"Rimadyl Chewable - <a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPw&amp;pv1=Rimadyl Chewable\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productSalesReportUri\": \"<a href=\\\"\\/00OL0000000OcOi?pv0=a0o23000000QOPw&amp;pv1=Rimadyl Chewable\\\" target=\\\"_new\\\">SR<\\/a>\",'+
    '        \"productHierarchies\": ['+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOPwAAO\",'+
    '            \"code\": \"BRAND\",'+
    '            \"name\": \"Rimadyl Chewable\"'+
    '          },'+
    '          {'+
    '            \"crmTechnicalKey\": \"a0o23000000QOPqAAO\",'+
    '            \"code\": \"THERAPEUTIC_GROUP\",'+
    '            \"name\": \"NSAID\"'+
    '          }'+
    '        ]'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 12936,'+
    '          \"currentUnits\": 5551,'+
    '          \"previousSales\": 10993,'+
    '          \"previousUnits\": 4655,'+
    '          \"diffSales\": 1943,'+
    '          \"diffUnits\": 896,'+
    '          \"percDiffSales\": 17.67,'+
    '          \"percDiffUnits\": 19.25'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 11723,'+
    '          \"currentUnits\": 6526,'+
    '          \"previousSales\": 10463,'+
    '          \"previousUnits\": 7876,'+
    '          \"diffSales\": 1260,'+
    '          \"diffUnits\": -1350,'+
    '          \"percDiffSales\": 12.04,'+
    '          \"percDiffUnits\": -17.14'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 13105,'+
    '          \"currentUnits\": 7031,'+
    '          \"previousSales\": 11369,'+
    '          \"previousUnits\": 5164,'+
    '          \"diffSales\": 1736,'+
    '          \"diffUnits\": 1867,'+
    '          \"percDiffSales\": 15.27,'+
    '          \"percDiffUnits\": 36.15'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 12756,'+
    '          \"currentUnits\": 7777,'+
    '          \"previousSales\": 10638,'+
    '          \"previousUnits\": 6166,'+
    '          \"diffSales\": 2118,'+
    '          \"diffUnits\": 1611,'+
    '          \"percDiffSales\": 19.91,'+
    '          \"percDiffUnits\": 26.13'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 13405,'+
    '          \"currentUnits\": 4620,'+
    '          \"previousSales\": 13950,'+
    '          \"previousUnits\": 4296,'+
    '          \"diffSales\": -545,'+
    '          \"diffUnits\": 324,'+
    '          \"percDiffSales\": -3.91,'+
    '          \"percDiffUnits\": 7.54'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 15079,'+
    '          \"currentUnits\": 4122,'+
    '          \"previousSales\": 13692,'+
    '          \"previousUnits\": 8786,'+
    '          \"diffSales\": 1387,'+
    '          \"diffUnits\": -4664,'+
    '          \"percDiffSales\": 10.13,'+
    '          \"percDiffUnits\": -53.08'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 14823,'+
    '          \"currentUnits\": 5395,'+
    '          \"previousSales\": 13227,'+
    '          \"previousUnits\": 6876,'+
    '          \"diffSales\": 1596,'+
    '          \"diffUnits\": -1481,'+
    '          \"percDiffSales\": 12.07,'+
    '          \"percDiffUnits\": -21.54'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 11401,'+
    '          \"currentUnits\": 6423,'+
    '          \"previousSales\": 10918,'+
    '          \"previousUnits\": 8243,'+
    '          \"diffSales\": 483,'+
    '          \"diffUnits\": -1820,'+
    '          \"percDiffSales\": 4.42,'+
    '          \"percDiffUnits\": -22.08'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 13710,'+
    '          \"currentUnits\": 7720,'+
    '          \"previousSales\": 13689,'+
    '          \"previousUnits\": 8939,'+
    '          \"diffSales\": 21,'+
    '          \"diffUnits\": -1219,'+
    '          \"percDiffSales\": 0.15,'+
    '          \"percDiffUnits\": -13.64'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 14949,'+
    '          \"currentUnits\": 6735,'+
    '          \"previousSales\": 13086,'+
    '          \"previousUnits\": 4204,'+
    '          \"diffSales\": 1863,'+
    '          \"diffUnits\": 2531,'+
    '          \"percDiffSales\": 14.24,'+
    '          \"percDiffUnits\": 60.2'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 14569,'+
    '          \"currentUnits\": 7318,'+
    '          \"previousSales\": 11411,'+
    '          \"previousUnits\": 4454,'+
    '          \"diffSales\": 3158,'+
    '          \"diffUnits\": 2864,'+
    '          \"percDiffSales\": 27.68,'+
    '          \"percDiffUnits\": 64.3'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 14493,'+
    '          \"currentUnits\": 8068,'+
    '          \"previousSales\": 13432,'+
    '          \"previousUnits\": 8186,'+
    '          \"diffSales\": 1061,'+
    '          \"diffUnits\": -118,'+
    '          \"percDiffSales\": 7.9,'+
    '          \"percDiffUnits\": -1.44'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 162949,'+
    '        \"previousYearSalesTotal\": 146868,'+
    '        \"diffSalesTotal\": 16081,'+
    '        \"percDiffSalesTotal\": 10.95,'+
    '        \"currentYearUnitTotal\": 77286,'+
    '        \"previousYearUnitTotal\": 77845'+
    '      }'+
    '    }'+
    '  ]'+
    '}';

/*    
     String jsonUnitSales = '{'+
    '  \"salesItems\": ['+
    '    {'+
    '      \"name\": \"\\uccad\\uc8fc\\uc2dc\\uccad(\\uba85\\uce6d\\ubcc0\\uacbd)\",'+
    '      \"market\": \"South Korea\",'+
    '      \"marketIsoCode\": \"KR\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"TOTAL\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016.03.30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"KOR-\",'+
    '        \"srcBusinessKey\": \"1000047048\",'+
    '        \"crmTechnicalKey\": \"0018A000003idkTQAQ\",'+
    '        \"accountType\": \"Administration\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"EUR\"'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 147,'+
    '          \"currentUnits\": 23,'+
    '          \"previousSales\": 27,'+
    '          \"previousUnits\": 10,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 13,'+
    '          \"percDiffSales\": 444.44,'+
    '          \"percDiffUnits\": 130'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 157,'+
    '          \"currentUnits\": 14,'+
    '          \"previousSales\": 37,'+
    '          \"previousUnits\": 13,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 1,'+
    '          \"percDiffSales\": 324.32,'+
    '          \"percDiffUnits\": 7.69'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 167,'+
    '          \"currentUnits\": 13,'+
    '          \"previousSales\": 47,'+
    '          \"previousUnits\": 6,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 7,'+
    '          \"percDiffSales\": 255.32,'+
    '          \"percDiffUnits\": 116.67'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 177,'+
    '          \"currentUnits\": 20,'+
    '          \"previousSales\": 57,'+
    '          \"previousUnits\": 14,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 6,'+
    '          \"percDiffSales\": 210.53,'+
    '          \"percDiffUnits\": 42.86'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 187,'+
    '          \"currentUnits\": 9,'+
    '          \"previousSales\": 67,'+
    '          \"previousUnits\": 24,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -15,'+
    '          \"percDiffSales\": 179.1,'+
    '          \"percDiffUnits\": -62.5'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 197,'+
    '          \"currentUnits\": 14,'+
    '          \"previousSales\": 77,'+
    '          \"previousUnits\": 18,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -4,'+
    '          \"percDiffSales\": 155.84,'+
    '          \"percDiffUnits\": -22.22'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 207,'+
    '          \"currentUnits\": 5,'+
    '          \"previousSales\": 87,'+
    '          \"previousUnits\": 18,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -13,'+
    '          \"percDiffSales\": 137.93,'+
    '          \"percDiffUnits\": -72.22'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 217,'+
    '          \"currentUnits\": 23,'+
    '          \"previousSales\": 97,'+
    '          \"previousUnits\": 12,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 11,'+
    '          \"percDiffSales\": 123.71,'+
    '          \"percDiffUnits\": 91.67'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 227,'+
    '          \"currentUnits\": 9,'+
    '          \"previousSales\": 107,'+
    '          \"previousUnits\": 15,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -6,'+
    '          \"percDiffSales\": 112.15,'+
    '          \"percDiffUnits\": -40'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 237,'+
    '          \"currentUnits\": 25,'+
    '          \"previousSales\": 117,'+
    '          \"previousUnits\": 16,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 9,'+
    '          \"percDiffSales\": 102.56,'+
    '          \"percDiffUnits\": 56.25'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 247,'+
    '          \"currentUnits\": 1,'+
    '          \"previousSales\": 127,'+
    '          \"previousUnits\": 7,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -6,'+
    '          \"percDiffSales\": 94.49,'+
    '          \"percDiffUnits\": -85.71'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 247,'+
    '          \"currentUnits\": 5,'+
    '          \"previousSales\": 137,'+
    '          \"previousUnits\": 11,'+
    '          \"diffSales\": 110,'+
    '          \"diffUnits\": -6,'+
    '          \"percDiffSales\": 80.29,'+
    '          \"percDiffUnits\": -54.55'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 2414,'+
    '        \"previousYearSalesTotal\": 984,'+
    '        \"diffSalesTotal\": 1430,'+
    '        \"percDiffSalesTotal\": 145.33,'+
    '        \"currentYearUnitTotal\": 161,'+
    '        \"previousYearUnitTotal\": 164'+
    '      }'+
    '    },'+

    '    {'+
    '      \"name\": \"\\uccad\\uc8fc\\uc2dc\\uccad(\\uba85\\uce6d\\ubcc0\\uacbd)\",'+
    '      \"market\": \"South Korea\",'+
    '      \"marketIsoCode\": \"KR\",'+
    '      \"salesType\": \"G\",'+
    '      \"aggregationLevel\": \"TOTAL\",'+
    '      \"accountAggregationLevel\": \"BRANCH\",'+
    '      \"asOfDate\": \"2016.03.30\",'+
    '      \"account\": {'+
    '        \"masterId\": \"KOR-\",'+
    '        \"srcBusinessKey\": \"1000047048\",'+
    '        \"crmTechnicalKey\": \"0018A000003idkTQAQ\",'+
    '        \"accountType\": \"Administration\",'+
    '        \"accountParentUri\": \"<a href=\\\" \\\" target=\\\"_blank\\\"> <\\/a>\",'+
    '        \"currencyIsoCode\": \"KRW\"'+
    '      },'+
    '      \"salesRecords\": ['+
    '        {'+
    '          \"period\": 1,'+
    '          \"accountingPeriod\": \"AP-1\",'+
    '          \"currentSales\": 147,'+
    '          \"currentUnits\": 23,'+
    '          \"previousSales\": 27,'+
    '          \"previousUnits\": 10,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 13,'+
    '          \"percDiffSales\": 444.44,'+
    '          \"percDiffUnits\": 130'+
    '        },'+
    '        {'+
    '          \"period\": 2,'+
    '          \"accountingPeriod\": \"AP-2\",'+
    '          \"currentSales\": 157,'+
    '          \"currentUnits\": 14,'+
    '          \"previousSales\": 37,'+
    '          \"previousUnits\": 13,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 1,'+
    '          \"percDiffSales\": 324.32,'+
    '          \"percDiffUnits\": 7.69'+
    '        },'+
    '        {'+
    '          \"period\": 3,'+
    '          \"accountingPeriod\": \"AP-3\",'+
    '          \"currentSales\": 167,'+
    '          \"currentUnits\": 13,'+
    '          \"previousSales\": 47,'+
    '          \"previousUnits\": 6,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 7,'+
    '          \"percDiffSales\": 255.32,'+
    '          \"percDiffUnits\": 116.67'+
    '        },'+
    '        {'+
    '          \"period\": 4,'+
    '          \"accountingPeriod\": \"AP-4\",'+
    '          \"currentSales\": 177,'+
    '          \"currentUnits\": 20,'+
    '          \"previousSales\": 57,'+
    '          \"previousUnits\": 14,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 6,'+
    '          \"percDiffSales\": 210.53,'+
    '          \"percDiffUnits\": 42.86'+
    '        },'+
    '        {'+
    '          \"period\": 5,'+
    '          \"accountingPeriod\": \"AP-5\",'+
    '          \"currentSales\": 187,'+
    '          \"currentUnits\": 9,'+
    '          \"previousSales\": 67,'+
    '          \"previousUnits\": 24,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -15,'+
    '          \"percDiffSales\": 179.1,'+
    '          \"percDiffUnits\": -62.5'+
    '        },'+
    '        {'+
    '          \"period\": 6,'+
    '          \"accountingPeriod\": \"AP-6\",'+
    '          \"currentSales\": 197,'+
    '          \"currentUnits\": 14,'+
    '          \"previousSales\": 77,'+
    '          \"previousUnits\": 18,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -4,'+
    '          \"percDiffSales\": 155.84,'+
    '          \"percDiffUnits\": -22.22'+
    '        },'+
    '        {'+
    '          \"period\": 7,'+
    '          \"accountingPeriod\": \"AP-7\",'+
    '          \"currentSales\": 207,'+
    '          \"currentUnits\": 5,'+
    '          \"previousSales\": 87,'+
    '          \"previousUnits\": 18,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -13,'+
    '          \"percDiffSales\": 137.93,'+
    '          \"percDiffUnits\": -72.22'+
    '        },'+
    '        {'+
    '          \"period\": 8,'+
    '          \"accountingPeriod\": \"AP-8\",'+
    '          \"currentSales\": 217,'+
    '          \"currentUnits\": 23,'+
    '          \"previousSales\": 97,'+
    '          \"previousUnits\": 12,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 11,'+
    '          \"percDiffSales\": 123.71,'+
    '          \"percDiffUnits\": 91.67'+
    '        },'+
    '        {'+
    '          \"period\": 9,'+
    '          \"accountingPeriod\": \"AP-9\",'+
    '          \"currentSales\": 227,'+
    '          \"currentUnits\": 9,'+
    '          \"previousSales\": 107,'+
    '          \"previousUnits\": 15,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -6,'+
    '          \"percDiffSales\": 112.15,'+
    '          \"percDiffUnits\": -40'+
    '        },'+
    '        {'+
    '          \"period\": 10,'+
    '          \"accountingPeriod\": \"AP-10\",'+
    '          \"currentSales\": 237,'+
    '          \"currentUnits\": 25,'+
    '          \"previousSales\": 117,'+
    '          \"previousUnits\": 16,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": 9,'+
    '          \"percDiffSales\": 102.56,'+
    '          \"percDiffUnits\": 56.25'+
    '        },'+
    '        {'+
    '          \"period\": 11,'+
    '          \"accountingPeriod\": \"AP-11\",'+
    '          \"currentSales\": 247,'+
    '          \"currentUnits\": 1,'+
    '          \"previousSales\": 127,'+
    '          \"previousUnits\": 7,'+
    '          \"diffSales\": 120,'+
    '          \"diffUnits\": -6,'+
    '          \"percDiffSales\": 94.49,'+
    '          \"percDiffUnits\": -85.71'+
    '        },'+
    '        {'+
    '          \"period\": 12,'+
    '          \"accountingPeriod\": \"AP-12\",'+
    '          \"currentSales\": 247,'+
    '          \"currentUnits\": 5,'+
    '          \"previousSales\": 137,'+
    '          \"previousUnits\": 11,'+
    '          \"diffSales\": 110,'+
    '          \"diffUnits\": -6,'+
    '          \"percDiffSales\": 80.29,'+
    '          \"percDiffUnits\": -54.55'+
    '        }'+
    '      ],'+
    '      \"totalSalesRecord\": {'+
    '        \"currentYearSalesTotal\": 2414,'+
    '        \"previousYearSalesTotal\": 984,'+
    '        \"diffSalesTotal\": 1430,'+
    '        \"percDiffSalesTotal\": 145.33,'+
    '        \"currentYearUnitTotal\": 161,'+
    '        \"previousYearUnitTotal\": 164'+
    '      }'+
    '    }'+         
    '  ]'+
    '}';
*/
    
}