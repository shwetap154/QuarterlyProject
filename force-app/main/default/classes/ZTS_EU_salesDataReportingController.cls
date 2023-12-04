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
    Aritra Chakraborty	1-Nov-2017								Added logic for Gregorian Calendar for all markets (except Korea and Taiwan) REF - SC-002108
**************************************************************************************/
    public with sharing class ZTS_EU_salesDataReportingController {        
            
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
        Public String selectedDisplayType                           {get;set;}
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
        public String percentagesymbol 							{get;set;}
        Public Map<String,List<String>> mapTotalSalesYTD ;
        //Public Map<String,List<String>> mapProdSalesYTD ;
        //Public Map<String,List<String>> mapUnitSalesYTD ;
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
        public Date apStartDate                                     {get;set;}
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
        public Account passAccount                                  {get;set;} // This will copy the current account id and use for passing as a parameter +   Added by Sohil Shah for Sales Through Date of Sales Data and Net Sales
        public  boolean isGermanyRegion                             {get;set;} // Sohil Shah Removed Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
        
        public boolean hasSalesData {get;set;}
        public boolean hasNetSalesData {get;set;}
        public boolean hasGrossSalesData {get;set;}
        
        //Gregorian Calendar SR Start
        public Map<String,String> monthNameMap;
        public List<User> currentUserDetails;
        public List<String> monthNameList   {get;set;}
        public String currentUserMarket {get;set;}
        public List<String> finalAPList                             {get;set;} // This list will have the order in which to display the AP values
        public List<String> finalMonthList                          {get;set;} // This list will have the order in which to display the Greg. month values
        public List<String> monthNameListYTDGreg   {get;set;}
        public List<String> monthListYTDGreg						{get;set;}	
        public Map<String, List<Decimal>> monthValueMapGreg;
        public Map<String, List<String>> monthStringValueMapGreg;
        //Gregorian Calendar SR End
        
        public ZTS_EU_salesDataReportingController(ApexPages.StandardController controller) {
            displayErrPopup = false;
            isGermanyRegion = false;
            noParent = false;
            ispopupErr = false;
            apStartDate = system.today();
            currencyISO = '';
            createQueryStr();
            userPreference();
            Id accntIdQuery;
            selectedMATYTD = 'MAT';
            selectedDisplayType = 'Accounting Period';
            selectedReport = 'TotalSales';
            salesDateCustSett = ZTS_EU_Sales_Date__c.getAll().values()[0];
            monthAPMap = new Map<Integer, String>();
            monthNumberMap = new Map<String, String>();
            monthAPList =  new List<String>();
            parentAccntNotAvailable =  false;
            selectedLevelValue ='Branch'; // Set to 'Branch' to ensure initial page load gets this value, logic will alter the sales data based on 'Head Office' radio selection
            
            //Gregorian Calendar SR Start
            monthNameMap = new Map<String,String>();
            monthNameMap.put('AP-1','DEC');
            monthNameMap.put('AP-2','JAN');
            monthNameMap.put('AP-3','FEB');
            monthNameMap.put('AP-4','MAR');
            monthNameMap.put('AP-5','APR');
            monthNameMap.put('AP-6','MAY');
            monthNameMap.put('AP-7','JUN');
            monthNameMap.put('AP-8','JUL');
            monthNameMap.put('AP-9','AUG');
            monthNameMap.put('AP-10','SEP');
            monthNameMap.put('AP-11','OCT');
            monthNameMap.put('AP-12','NOV');
                      
            //Gregorian Calendar SR End
            
            //[Ali M] - Assumption that every account has sales data.
            hasSalesData = true;
            hasNetSalesData = false;
            hasGrossSalesData = false;

            Account accntRec = (Account)controller.getrecord();
            
            List<Account> listAccnt = [Select Id, Name,ParentId, ZTS_EU_Market__c,Parent.Name, ZTS_EU_Loyalty_Flag__c,  (select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null),
                                       (select id, ZTS_EU_Date__c, CurrencyIsoCode from Net_Sales__r where ZTS_EU_Date__c <> null)
                                        from Account where Id =: accntRec.Id AND ZTS_EU_Market__c != 'United States']; //IP 26-Feb-15 Added Net Sales
            
            // Market was US
            if (listAccnt == null || listAccnt.isEmpty())
            {
                redirect(controller.getrecord().Id);
                return;
            }
            passAccount =listAccnt[0];
            showFootNote = false;
            showProductPicklist = true;

            //[Ali M] - Account doesn't have sales data.
            hasGrossSalesData = !passAccount.Sales__r.isEmpty();
            hasNetSalesData = !passAccount.Net_Sales__r.isEmpty();

            //[Ali M] - Display the Sales Data page if the account has gross or net sales otherwise display 'No Sales Data' message.
            hasSalesData = hasGrossSalesData || hasNetSalesData;
          
            // Sohil Shah Removed Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
            if(listAccnt[0].ZTS_EU_Market__c == 'Germany' || listAccnt[0].ZTS_EU_Market__c == 'Austria' || listAccnt[0].ZTS_EU_Market__c == 'Switzerland')
            {
                isGermanyRegion = true;
            }
            // EOC Sohil Shah Removed Currency from Last row %Diff Sales Ref : INC0427452 only For Germany Regions(Market = Germany/Austria/Switzerland)
            
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
                            selectedSalesType = 'Net Sales';
                            
                            toDisplayGross =false;
                            break;

                        }
                        else{
                            selectedSalesType = 'Gross'; //IP 25-Feb-15 Fixed bug
                            toDisplayGross =false;  
                        }
                    }
                
                if(hasSalesData){

                    generateSalesThroughDate(listAccnt[0]); // populate Default SalesThrough Date i.e. for Sales Data - By Sohil Shah
                    generateMonthMapping(listAccnt[0]);
                    
                    if(monthNumberMap == null || monthNumberMap.size() == 0 || monthAPMap == null || monthAPMap.size() == 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.label.ZTS_EU_Error_Invalid_Date_for_Sales));
                        //return;
                    }//else{
                    accntCurrent = listAccnt[0];
                    accntActual = listAccnt[0];
                    accnPrevious = null;
                    
                    // Added by Shefali for Displaying Gross and Net Sales radio buttons 29/12/2014
                    
                    //EOC Shefali 
                    List<Account> listParentAcc = [select Id, Name, ParentId,ZTS_EU_Market__c, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c != 'United States' limit 1];
                    if(listParentAcc != null && listParentAcc.size() > 0){
                        accntParent = listParentAcc[0];
                    }else{
                        accntParent = null;
                    }
                    
                    accntChild = null;
                    //}
                
                calculateLevelValues(accntRec);
                //selectedSalesType = 'Gross';
                if(accntCurrent.ParentId == NULL){
                    parentAccntNotAvailable = true;
                }
                accntIdQuery = accntCurrent.Id;
                listChildAccnt = [Select Id, Name, ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where (ParentId =: accntIdQuery OR Id =: accntIdQuery) AND ZTS_EU_Market__c != 'United States'];
                getcreateDataTable();
            }
            }
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
                    
                    apStartDate = acc.Sales__r[0].ZTS_EU_Date__c;               
                }
                if(acc.Sales__r.isEmpty() && selectedSalesType == 'Gross')
                {
                    apStartDate = null;                 
                }
                if(acc.Net_Sales__r != null && acc.Net_Sales__r.size()>0 && (selectedSalesType == 'Net' || selectedSalesType == 'Net Sales' ))
                {
                    apStartDate = acc.Net_Sales__r[0].ZTS_EU_Date__c;
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
        private void generateMonthMapping(Account account){
            Integer startCounter = 0;
            Integer mapCounter = 1;
            tempMonthAPMap = new Map<Integer, Integer>(); 
            if(account.Sales__r != null && account.Sales__r.size() > 0){
                //apStartDate = account.Sales__r[0].ZTS_EU_Date__c; // Commented by Sohil - logic is above
                //added by Shefali 12/01/2014 Currency Symbol according to the Sales Data
                currencyISO = account.Sales__r[0].CurrencyIsoCode;
                Map<String,CurrencySymbolMapping__c> symbolsMap = CurrencySymbolMapping__c.getAll();
                for(String key : symbolsMap.keySet()){
                    if(currencyISO != null && currencyISO.equalsIgnoreCase(key)){
                        currencyType = symbolsMap.get(key).Currency_Symbol__c ;
                       }
                }
                //EOC Shefali
                List<ZTS_EU_Accounting_Period__c> listAccPeriod = [select Id, ZTS_EU_Account_Period__c from ZTS_EU_Accounting_Period__c where 
                                                                ZTS_EU_AP_Start__c <=: account.Sales__r[0].ZTS_EU_Date__c and ZTS_EU_AP_End__c >=: account.Sales__r[0].ZTS_EU_Date__c and ZTS_EU_Market__c = :account.ZTS_EU_Market__c limit 1];
                                                     
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
                        //Gregorian SR Start
                        finalAPList = new List<String>();
                        finalMonthList = new List<String>();
                    for(Integer i = monthAPList.size()-1; i>=0;i--){
                        finalMonthList.add(monthNameMap.get(monthAPList.get(i)));    
                        finalAPList.add(monthAPList.get(i)); 
                        
                    }
                    //Gregorian SR End
                    
                    monthAPList = new List<String>();
                    monthAPList = finalList;
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
                percentagesymbol = '%';
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
                    finalAPList = new List<String>();
                        finalMonthList = new List<String>();
                    for(Integer i = monthAPList.size()-1; i>=0;i--){
                       finalMonthList.add(monthNameMap.get(monthAPList.get(i)));    
                       finalAPList.add(monthAPList.get(i)); 
                        
                    }
                    //Gregorian SR End
                    monthAPList = new List<String>();
                    monthAPList = finalList;

                }
            }else{
                apStartDate = null;
            }
        }
        
       
        
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
                    options.add(new selectOption(listSalesPresetData.Name, listSalesPresetData.Name));               
                }
            return options; //return the picklist options
        }

        /***********
        * Method name : getTherapeuticGrp
        * Description : This will create Therapeutic Group with values.
        * Return Type : List<selectOption>.
        * Parameters : None.
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
                            options.add(new selectOption(listSalesData.Name, listSalesData.Name)); 
                            setTherapeuticGrp.add(listSalesData.Name);
                        }else if(setTheraGrp == null || setTheraGrp.size() <= 0){
                            options.add(new selectOption(listSalesData.Name, listSalesData.Name)); 
                            setTherapeuticGrp.add(listSalesData.Name);
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
        List<selectOption> options = new List<selectOption>(); 
                Set<String> setTherapeuticGrp = new Set<String>();
                options.add(new selectOption('<Therapeutic Group>', '<' + System.label.ZTS_EU_Therapeutic_Group + '>'));
                if(selectedSalesType == 'Gross'){
                    for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Therapeutic_Group__c from ZTS_EU_Sales__c where ZTS_EU_Account__r.Name =: selectedAccnt AND ZTS_EU_IsDataFromBatchJob__c = false ORDER BY ZTS_EU_Therapeutic_Group__c]) { 
                        if(listSalesData.ZTS_EU_Therapeutic_Group__c != Null && !setTherapeuticGrp.contains(listSalesData.ZTS_EU_Therapeutic_Group__c))
                        options.add(new selectOption(listSalesData.ZTS_EU_Therapeutic_Group__c, listSalesData.ZTS_EU_Therapeutic_Group__c)); 
                        setTherapeuticGrp.add(listSalesData.ZTS_EU_Therapeutic_Group__c);
                    }
                }else{
                    for (ZTS_EU_Net_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Therapeutic_Group__c from ZTS_EU_Net_Sales__c where ZTS_EU_Account__r.Name =: selectedAccnt ORDER BY ZTS_EU_Therapeutic_Group__c]) { 
                        if(listSalesData.ZTS_EU_Therapeutic_Group__c != Null && !setTherapeuticGrp.contains(listSalesData.ZTS_EU_Therapeutic_Group__c))
                        options.add(new selectOption(listSalesData.ZTS_EU_Therapeutic_Group__c, listSalesData.ZTS_EU_Therapeutic_Group__c)); 
                        setTherapeuticGrp.add(listSalesData.ZTS_EU_Therapeutic_Group__c);
                    }
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
                            options.add(new selectOption(listSalesData.Name, listSalesData.Name)); 
                            setSalesDataProd.add(listSalesData.Name);
                        }else if(setProdData == null || setProdData.size() <= 0){
                            options.add(new selectOption(listSalesData.Name, listSalesData.Name)); 
                            setSalesDataProd.add(listSalesData.Name);
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
            
                if(selectedSalesType == 'Gross'){
                    for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Brand__c, ZTS_EU_Account__r.Name,ZTS_EU_Product__r.Name from ZTS_EU_Sales__c where ZTS_EU_Account__r.Name =: selectedAccnt AND ZTS_EU_IsDataFromBatchJob__c = false ORDER BY ZTS_EU_Brand__c]) { 
                        if( ( (listSalesData.ZTS_EU_Brand__c != Null && listAccnt[0].ZTS_EU_Market__c != 'Spain') || (listSalesData.ZTS_EU_Brand__c != Null && listAccnt[0].ZTS_EU_Market__c == 'Spain' && !listSalesData.ZTS_EU_Brand__c.containsIgnoreCase('dummy') )    ) && !setSalesDataProd.contains(listSalesData.ZTS_EU_Brand__c)  )
                        options.add(new selectOption(listSalesData.ZTS_EU_Brand__c, listSalesData.ZTS_EU_Brand__c)); 
                        setSalesDataProd.add(listSalesData.ZTS_EU_Brand__c);
                    }
                }else{
                    for (ZTS_EU_Net_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Brand__c, ZTS_EU_Account__r.Name,ZTS_EU_Product__r.Name from ZTS_EU_Net_Sales__c where ZTS_EU_Account__r.Name =: selectedAccnt ORDER BY ZTS_EU_Brand__c]) { 
                        if( ( (listSalesData.ZTS_EU_Brand__c != Null && listAccnt[0].ZTS_EU_Market__c != 'Spain') || (listSalesData.ZTS_EU_Brand__c != Null && listAccnt[0].ZTS_EU_Market__c == 'Spain' && !listSalesData.ZTS_EU_Brand__c.containsIgnoreCase('dummy') )    ) && !setSalesDataProd.contains(listSalesData.ZTS_EU_Brand__c)  )
                        options.add(new selectOption(listSalesData.ZTS_EU_Brand__c, listSalesData.ZTS_EU_Brand__c)); 
                        setSalesDataProd.add(listSalesData.ZTS_EU_Brand__c);
                    }
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
            if(selectedSalesType == 'Gross'){
                for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Business_Units__c from ZTS_EU_Sales__c 
                                                            where ZTS_EU_Account__r.Name =: selectedAccnt AND ZTS_EU_IsDataFromBatchJob__c = false ORDER BY ZTS_EU_Business_Units__c]) {                 
                    if(listSalesData.ZTS_EU_Business_Units__c != Null ){//&& !setBusinessUnits.contains(listSalesData.ZTS_EU_Business_Units__c)){
                        allBUList = listSalesData.ZTS_EU_Business_Units__c.split(' ');
                        for(String bu: allBUList){
                            if(!setBusinessUnits.contains(bu) && bu != ''){
                                options.add(new selectOption(bu, bu)); 
                                setBusinessUnits.add(bu);
                            }
                        }
                    }
                }
            }else{
                for (ZTS_EU_Net_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Business_Units__c from ZTS_EU_Net_Sales__c 
                                                            where ZTS_EU_Account__r.Name =: selectedAccnt ORDER BY ZTS_EU_Business_Units__c]) {                 
                    if(listSalesData.ZTS_EU_Business_Units__c != Null ){//&& !setBusinessUnits.contains(listSalesData.ZTS_EU_Business_Units__c)){
                        allBUList = listSalesData.ZTS_EU_Business_Units__c.split(' ');
                        for(String bu: allBUList){
                            if(!setBusinessUnits.contains(bu) && bu != ''){
                                options.add(new selectOption(bu, bu)); 
                                setBusinessUnits.add(bu);
                            }
                        }
                    }
                }
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
            listAccnt=[Select Id, Name,ParentId,ZTS_EU_Market__c, ZTS_EU_Loyalty_Flag__c from Account where ID =: accntRec.Id AND ZTS_EU_Market__c != 'United States'];
            if(listAccnt[0].ParentId != null){
                isChild=true;
            }else{
                isChild=false;
            }
        }
        
        /***********
        * Method name : getSalesData
        * Description : This method is responsible for showing the data in the grid according to business logic
        * Return Type : List<CustomSettSalesData>.
        * Parameters : None.
        ***********/
        public List<CustomSettSalesData> getSalesData() {
            List<String> prodLevel;
            Set<Id> accntIds = new Set<Id>();
            List<CustomSettSalesData> listCustomSettSalesData = new List<CustomSettSalesData>();
            List<ActualSalesDataValue> listAccntSalesDataValue;
            Map<Id, List<ZTS_EU_Sales__c>> mapAccntIdlistSalesData =  new Map<Id, List<ZTS_EU_Sales__c>>();
            Map<Id, List<ZTS_EU_Net_Sales__c>> mapAccntIdlistSalesDataNetSales =  new Map<Id, List<ZTS_EU_Net_Sales__c>>(); 
            Map<Id, String> mapAccntIdAccntName =  new Map<Id, String>();
            Map<Id, String> mapAccntIdNarcId =  new Map<Id, String>();
            if(queryAccID != null && queryAccID != ''){
                accntIds.add((ID)queryAccID);
            }
            
            if(accntCurrent == null){ 
                accntIds.add(queryAccId);
            }else{
                accntIds.add(accntCurrent.Id);
            }
            for(Account oAcc : [Select Id,Name,ZTS_EU_Customer_ID__c from Account where Id IN: accntIds AND ZTS_EU_Market__c != 'United States']){            
                mapAccntIdAccntName.put(oAcc.Id,oAcc.Name);
                mapAccntIdNarcId.put(oAcc.Id,oAcc.ZTS_EU_Customer_ID__c);
            }
            createQueryStr();
            
            // Apply filters only when Product Sales or Unit Sales tab is selected
            if(selectedReport == 'UnitSales' || selectedReport == 'ProductSales'){
                if((selectedTherapeuticGrp != null && selectedTherapeuticGrp != '') || (selectedProduct != null && selectedProduct != '') 
                                 || (selectedBusinessUnit != null && selectedBusinessUnit != '') ){
                    if(selectedTherapeuticGrp != '<Therapeutic Group>'){                
                        soqlQuery+= 'AND ZTS_EU_Therapeutic_Group__c =: selectedTherapeuticGrp ';
                    }
                    if(selectedProduct != '<Product>'){
                        soqlQuery+= 'AND ZTS_EU_Brand__c =: selectedProduct ';
                    }
                    /*if(selectedSpecies != '<Species>'){
                        soqlQuery+= 'AND ZTS_EU_Species__c =: selectedSpecies ';
                    } */ 
                    //Natasa Cvrlje bug fix for business unit filtering 1/10/2014
                    if(selectedBusinessUnit != '<BusinessUnit>'){
                        String bunit = '%' + selectedBusinessUnit.trim() + '%';
                        soqlQuery+= ' AND ZTS_EU_Business_Units__c like \'' + bunit + '\' ';// + selectedBusinessUnit + ' ';
                    }         
                }
                /*if Preset is selected, then apply these filters */
                if(selectedPreset != '--None--'){
                    salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Business_Unit__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                    selectedMATYTD = salesPresets.ZTS_EU_Selected_Preferred_Time__c;
                
                    if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c != Null)
                    selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                    if(salesPresets.ZTS_EU_Selected_Preferred_Brands__c != Null)
                    selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                    if(salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c != Null){
                        selectedMultiBusinessUnits = salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c.split(';');
                    }
                    if(selectedMultiTherapeuticGrp != Null && selectedMultiTherapeuticGrp.size()>0)
                        selectedMultiTherapeuticGrpOpt = listSelOptPopulate(selectedMultiTherapeuticGrp);
                    if(selectedMultiProduct != Null && selectedMultiProduct.size()>0)
                        selectedMultiProductOpt = listSelOptPopulate(selectedMultiProduct);
                    if(selectedMultiBusinessUnits != Null && selectedMultiBusinessUnits.size()>0)
                        selectedMultiSpeciesOpt = listSelOptPopulate(selectedMultiBusinessUnits);
                   
                    if(!(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c == Null || salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c == '')){                
                        selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                        soqlQuery+= 'AND ZTS_EU_Therapeutic_Group__c IN: selectedMultiTherapeuticGrp ';
                    }
                    if(!(salesPresets.ZTS_EU_Selected_Preferred_Brands__c == Null || salesPresets.ZTS_EU_Selected_Preferred_Brands__c == '')){
                        selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                        soqlQuery+= 'AND ZTS_EU_Brand__c IN: selectedMultiProduct ';
                    }
                    selectedMultiBusinessUnits = new List<String>();
                    if(!(salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c == Null || salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c == '')){
                        List<String> tempList = salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c.split(';');
                        for(String bu : tempList){
                            String bunit = '%' + bu + '%';
                            selectedMultiBusinessUnits.add(bunit);
                        }
                        soqlQuery+= 'AND ZTS_EU_Business_Units__c LIKE: selectedMultiBusinessUnits ';
                    }           
                    //}
                }
            }//Aritra : don't change anything here
              
            prodLevel = new List<String>();
            if(selectedReport == 'UnitSales'){
                
                if((isChildSelected != null && !isChildSelected) || (accntChild != null && accntParent != null && !accntActual.Name.equalsIgnoreCase(accntParent.Name)) ){
                    if((!noParent && !soqlQuery.contains('ZTS_EU_Aggregated__c')) || (noParent && toggleFlagParent)){
                        soqlQuery += '  and ZTS_EU_Aggregated__c =true  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                    }else{
                        if(soqlQuery.contains('ZTS_EU_Aggregated__c')){
                            soqlQuery = soqlQuery.replace('ZTS_EU_Aggregated__c =true','ZTS_EU_Aggregated__c =false');
                            soqlQuery += '  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                        }else if(noParent){
                            soqlQuery += '  and ZTS_EU_Aggregated__c =false  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                        }
                    }
                //Start: Changes by Shefali for aggregation for Child Accounts based on radio selection.
                }else if(selectedLevelValue =='Head Office'){
                        soqlQuery+= ' and ZTS_EU_Aggregated__c =true AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                }
                
                else {
                    soqlQuery+= ' and ZTS_EU_Aggregated__c =false AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                } //END
                prodLevel.add('SKU');
                if(!soqlQuery.contains('prodLevel')){
                    soqlQuery+='AND ZTS_EU_Product__r.ZTS_EU_Type__c IN: prodLevel ';
                }
                
            }else if(selectedReport == 'ProductSales'){
                if((isChildSelected != null && !isChildSelected) || (accntChild != null && accntParent != null && !accntActual.Name.equalsIgnoreCase(accntParent.Name)) ){
                    if((!noParent && !soqlQuery.contains('ZTS_EU_Aggregated__c')) || (noParent && toggleFlagParent)){
                        soqlQuery += '  and ZTS_EU_Aggregated__c =true  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                    }else{
                        if(soqlQuery.contains('ZTS_EU_Aggregated__c')){
                            soqlQuery = soqlQuery.replace('ZTS_EU_Aggregated__c =true','ZTS_EU_Aggregated__c =false');
                            soqlQuery += '  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                        }else if(noParent){
                            soqlQuery += '  and ZTS_EU_Aggregated__c =false  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                        }
                    }
                //Start: Changes by Shefali for aggregation for Child Accounts based on radio selection.
                }else if(selectedLevelValue =='Head Office'){
                        soqlQuery+= ' and ZTS_EU_Aggregated__c =true AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                }
                
                else {
                    soqlQuery+= ' and ZTS_EU_Aggregated__c =false AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                }
                //END
                
                
                //prodLevel.add('Brand');
                
                if(listAccnt[0].ZTS_EU_Market__c == 'Spain'){
                    prodLevel.add('Therapeutic Group');
                }
                else{
                    prodLevel.add('Brand');
                }
                
                if(!soqlQuery.contains('prodLevel')){
                    soqlQuery+='AND ZTS_EU_Product__r.ZTS_EU_Type__c IN: prodLevel ';
                }
            }else if(selectedReport == 'TotalSales'){
                prodLevel.add('Account');
                
                if((isChildSelected != null && !isChildSelected) || (accntChild != null && accntParent != null && !accntActual.Name.equalsIgnoreCase(accntParent.Name)) ){
                    if((!noParent && !soqlQuery.contains('ZTS_EU_Aggregated__c')) || (noParent && toggleFlagParent)){
                        soqlQuery += '  and ZTS_EU_Aggregated__c =true ';
                    }else{
                        if(soqlQuery.contains('ZTS_EU_Aggregated__c')){
                            soqlQuery = soqlQuery.replace('ZTS_EU_Aggregated__c =true','ZTS_EU_Aggregated__c =false');
                        }else if(noParent){
                            soqlQuery += '  and ZTS_EU_Aggregated__c =false ';
                        }
                    }
                    /* commenting the below if statement since this is no longer required. 
                    if(!soqlQuery.contains('prodLevel')){
                        //soqlQuery+='AND ZTS_EU_Product__r.ZTS_EU_Type__c IN: prodLevel ';
                        soqlQuery+='AND ZTS_EU_Product__c = \'\' ';
                    }
                    */
                //Start: Changes by Shefali for aggregation for Child Accounts based on radio selection.
                }else if(selectedLevelValue =='Head Office'){
                        soqlQuery+= ' and ZTS_EU_Aggregated__c =true AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                }
                
                else {
                    soqlQuery+= ' and ZTS_EU_Aggregated__c =false AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                } // END
                //prodLevel.add('SKU');
                //prodLevel.add('Brand');
                if(!soqlQuery.contains('prodLevel')){
                //NC Fix bug - checking all sales data with empty product
                    soqlQuery+='AND ZTS_EU_Product__c = \'\' ';
                }
            }
            if(selectedSalesType == 'Gross'){
                soqlQuery += ' AND ZTS_EU_IsDataFromBatchJob__c = false ';
            }   
            string sortFullExp = sortExpression  + ' ' + sortDirection;
            soqlQuery+= 'ORDER BY '+sortFullExp; 
            List<ZTS_EU_Sales__c> listQuerySalesData ;
            List<ZTS_EU_Net_Sales__c> listQuerySalesDataNetSales;
            
            if(selectedSalesType == 'Gross'){
                listQuerySalesData = Database.query(soqlQuery);
                for(ZTS_EU_Sales__c listSalesData : listQuerySalesData){
                    if(mapAccntIdlistSalesData.containsKey(listSalesData.ZTS_EU_Account__c)){
                        mapAccntIdlistSalesData.get(listSalesData.ZTS_EU_Account__c).add(listSalesData);
                    }
                    else{
                        mapAccntIdlistSalesData.put(listSalesData.ZTS_EU_Account__c,new List<ZTS_EU_Sales__c>{listSalesData});
                    }
                } 
                
            }else{
                listQuerySalesDataNetSales = Database.query(soqlQuery);
                for(ZTS_EU_Net_Sales__c listSalesData : listQuerySalesDataNetSales){
                    if(mapAccntIdlistSalesDataNetSales.containsKey(listSalesData.ZTS_EU_Account__c)){
                        mapAccntIdlistSalesDataNetSales.get(listSalesData.ZTS_EU_Account__c).add(listSalesData);
                    }
                    else{
                        mapAccntIdlistSalesDataNetSales.put(listSalesData.ZTS_EU_Account__c,new List<ZTS_EU_Net_Sales__c>{listSalesData});
                    }
                }
               
            }
            
            Map<String, Decimal> currentSumMap = new Map<String,Decimal>();
            Map<String, Decimal> prevSumMap = new Map<String, Decimal>();
            Map<String, Decimal> diffSumMap = new Map<String, Decimal>();
            
            if(selectedSalesType == 'Gross'){
                for(Id oaccntId : mapAccntIdlistSalesData.keySet()){
                    String accName ;            
                    String accId ;
                    String narcId;
                    CustomSettSalesData oCustomSettSalesData;
                    Map<String, List<Decimal>> monthValueMap = new Map<String, List<Decimal>>();
                    Map<String, List<String>> monthStringValueMap = new Map<String, List<String>>();
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
                    List<Decimal> oaccntSalesData2total = new List<Decimal>();//for grand total
                    List<Decimal> oaccntSalesData3total = new List<Decimal>();
                    List<Decimal> oaccntSalesData4total = new List<Decimal>();
                    List<Decimal> oaccntSalesData5total = new List<Decimal>();
                    List<Decimal> oaccntSalesData6total = new List<Decimal>();
                    List<Decimal> oaccntSalesData7total = new List<Decimal>();
                    List<Decimal> oaccntSalesData8total = new List<Decimal>();
                    List<Decimal> oaccntSalesData9total = new List<Decimal>();
                    List<Decimal> oaccntSalesData10total = new List<Decimal>();
                    List<Decimal> oaccntSalesData11total = new List<Decimal>();
                    List<Decimal> oaccntSalesData12total = new List<Decimal>();
                    List<Decimal> oaccntSalesData13total = new List<Decimal>();
                    List<Decimal> oaccntSalesData14total = new List<Decimal>();
                    Integer gregUnitSalesIndex = 0;
                    Integer gregProdSalesIndex = 0;
                    for(ZTS_EU_Sales__c osalesData : mapAccntIdlistSalesData.get(oaccntId)){
                        //if UnitSales tab is selected
                        if(selectedReport == 'UnitSales'){
                            
                            List<String> oaccntSalesData1a = new List<String>{String.valueOf(osalesData.ZTS_EU_Therapeutic_Group__c)};
                            List<String> oaccntSalesData1b = new List<String>{String.valueOf(osalesData.ZTS_EU_Brand__c)};
                            List<String> oaccntSalesData1c = new List<String>{String.valueOf(osalesData.ZTS_EU_Product_Line_Item__c)};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year};
                            List<Decimal> oaccntSalesData2;
                            if(selectedMATYTD == 'YTD'){
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_CYTD_Units__c,osalesData.ZTS_EU_Total_PYTD_Units__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_CYTD_Units__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_PYTD_Units__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_CYTD_Units__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_PYTD_Units__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                }
                            }else{
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_MAT_Current_Units__c,osalesData.ZTS_EU_Total_MAT_Prior_Units__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Current_Units__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Prior_Units__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Current_Units__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Prior_Units__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                }
                            }
                            
                            // Calculate sum of current and previous values for all sales records
                            if(!currentSumMap.containsKey('1') && !prevSumMap.containsKey('1')){
                                currentSumMap.put('1',osalesData.ZTS_EU_01_Current_Units__c);
                                prevSumMap.put('1',osalesData.ZTS_EU_01_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('1') + osalesData.ZTS_EU_01_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('1') + osalesData.ZTS_EU_01_Previous_Units__c;
                                currentSumMap.put('1', currVal);
                                prevSumMap.put('1', prevVal);
                            }
                            if(!currentSumMap.containsKey('2') && !prevSumMap.containsKey('2')){
                                currentSumMap.put('2',osalesData.ZTS_EU_02_Current_Units__c);
                                prevSumMap.put('2',osalesData.ZTS_EU_02_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('2') + osalesData.ZTS_EU_02_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('2') + osalesData.ZTS_EU_02_Previous_Units__c;
                                currentSumMap.put('2', currVal);
                                prevSumMap.put('2', prevVal);
                            }
                            if(!currentSumMap.containsKey('3') && !prevSumMap.containsKey('3')){
                                currentSumMap.put('3',osalesData.ZTS_EU_03_Current_Units__c);
                                prevSumMap.put('3',osalesData.ZTS_EU_03_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('3') + osalesData.ZTS_EU_03_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('3') + osalesData.ZTS_EU_03_Previous_Units__c;
                                currentSumMap.put('3', currVal);
                                prevSumMap.put('3', prevVal);
                            }
                            if(!currentSumMap.containsKey('4') && !prevSumMap.containsKey('4')){
                                currentSumMap.put('4',osalesData.ZTS_EU_04_Current_Units__c);
                                prevSumMap.put('4',osalesData.ZTS_EU_04_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('4') + osalesData.ZTS_EU_04_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('4') + osalesData.ZTS_EU_04_Previous_Units__c;
                                currentSumMap.put('4', currVal);
                                prevSumMap.put('4', prevVal);
                            }
                            if(!currentSumMap.containsKey('5') && !prevSumMap.containsKey('5')){
                                currentSumMap.put('5',osalesData.ZTS_EU_05_Current_Units__c);
                                prevSumMap.put('5',osalesData.ZTS_EU_05_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('5') + osalesData.ZTS_EU_05_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('5') + osalesData.ZTS_EU_05_Previous_Units__c;
                                currentSumMap.put('5', currVal);
                                prevSumMap.put('5', prevVal);
                            }
                            if(!currentSumMap.containsKey('6') && !prevSumMap.containsKey('6')){
                                currentSumMap.put('6',osalesData.ZTS_EU_06_Current_Units__c);
                                prevSumMap.put('6',osalesData.ZTS_EU_06_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('6') + osalesData.ZTS_EU_06_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('6') + osalesData.ZTS_EU_06_Previous_Units__c;
                                currentSumMap.put('6', currVal);
                                prevSumMap.put('6', prevVal);
                            }
                            if(!currentSumMap.containsKey('7') && !prevSumMap.containsKey('7')){
                                currentSumMap.put('7',osalesData.ZTS_EU_07_Current_Units__c);
                                prevSumMap.put('7',osalesData.ZTS_EU_07_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('7') + osalesData.ZTS_EU_07_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('7') + osalesData.ZTS_EU_07_Previous_Units__c;
                                currentSumMap.put('7', currVal);
                                prevSumMap.put('7', prevVal);
                            }
                            if(!currentSumMap.containsKey('8') && !prevSumMap.containsKey('8')){
                                currentSumMap.put('8',osalesData.ZTS_EU_08_Current_Units__c);
                                prevSumMap.put('8',osalesData.ZTS_EU_08_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('8') + osalesData.ZTS_EU_08_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('8') + osalesData.ZTS_EU_08_Previous_Units__c;
                                currentSumMap.put('8', currVal);
                                prevSumMap.put('8', prevVal);
                            }
                            if(!currentSumMap.containsKey('9') && !prevSumMap.containsKey('9')){
                                currentSumMap.put('9',osalesData.ZTS_EU_09_Current_Units__c);
                                prevSumMap.put('9',osalesData.ZTS_EU_09_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('9') + osalesData.ZTS_EU_09_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('9') + osalesData.ZTS_EU_09_Previous_Units__c;
                                currentSumMap.put('9', currVal);
                                prevSumMap.put('9', prevVal);
                            }
                            if(!currentSumMap.containsKey('10') && !prevSumMap.containsKey('10')){
                                currentSumMap.put('10',osalesData.ZTS_EU_10_Current_Units__c);
                                prevSumMap.put('10',osalesData.ZTS_EU_10_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('10') + osalesData.ZTS_EU_10_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('10') + osalesData.ZTS_EU_10_Previous_Units__c;
                                currentSumMap.put('10', currVal);
                                prevSumMap.put('10', prevVal);
                            }
                            if(!currentSumMap.containsKey('11') && !prevSumMap.containsKey('11')){
                                currentSumMap.put('11',osalesData.ZTS_EU_11_Current_Units__c);
                                prevSumMap.put('11',osalesData.ZTS_EU_11_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('11') + osalesData.ZTS_EU_11_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('11') + osalesData.ZTS_EU_11_Previous_Units__c;
                                currentSumMap.put('11', currVal);
                                prevSumMap.put('11', prevVal);
                            }
                            if(!currentSumMap.containsKey('12') && !prevSumMap.containsKey('12')){
                                currentSumMap.put('12',osalesData.ZTS_EU_12_Current_Units__c);
                                prevSumMap.put('12',osalesData.ZTS_EU_12_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('12') + osalesData.ZTS_EU_12_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('12') + osalesData.ZTS_EU_12_Previous_Units__c;
                                currentSumMap.put('12', currVal);
                                prevSumMap.put('12', prevVal);
                            }
                            
                            List<List<Decimal>> oaccntSalesDataList = new List<List<Decimal>>();
                            Map<String, List<Decimal>> monthNoValueMap = new Map<String, List<Decimal>>();
                            List<Decimal> fieldValueList ;
                            Integer counter=1;
                            for(Integer i=1; i<=12;i ++){
                                if(i == 1){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_01_Current_Units__c,osalesData.ZTS_EU_01_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 2){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_02_Current_Units__c,osalesData.ZTS_EU_02_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 3){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_03_Current_Units__c,osalesData.ZTS_EU_03_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 4){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_04_Current_Units__c,osalesData.ZTS_EU_04_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 5){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_05_Current_Units__c,osalesData.ZTS_EU_05_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 6){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_06_Current_Units__c,osalesData.ZTS_EU_06_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 7){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_07_Current_Units__c,osalesData.ZTS_EU_07_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 8){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_08_Current_Units__c,osalesData.ZTS_EU_08_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 9){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_09_Current_Units__c,osalesData.ZTS_EU_09_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 10){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_10_Current_Units__c,osalesData.ZTS_EU_10_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 11){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_11_Current_Units__c,osalesData.ZTS_EU_11_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 12){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_12_Current_Units__c,osalesData.ZTS_EU_12_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }
                            }
                            
                            
                            if(selectedMATYTD == 'YTD'){
                                listdataYTD = new List<dataYTD>();
                                Integer j = 1;
                                dataYTD odataYTD;                       
                                monthList = new List<String>();                     
                                monthNameList = new List<String>();
                                Integer ytdStartCounter = tempMonthAPMap.get(1);
                                for(Integer i=ytdStartCounter-1; i> 0; i--){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                               List<Decimal> values = monthValueMap.get(colMnthName);
                                               values.addAll(colValues);
                                               monthValueMap.remove(colMnthName);
                                               monthValueMap.put(colMnthName,values);
                                    }else{
                                        monthValueMap.put(colMnthName,colValues);
                                    }
                                	monthList.add(colMnthName);
                                    monthNameList.add(monthNameMap.get(colMnthName));
                                    
                                    listdataYTD.add(odataYTD);
                                }  
                                
                                if(ytdStartCounter < 12){
                                    for(Integer i=ytdStartCounter; i<= 12; i++){
                                        String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                        List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                        j = j + 1;
                                        odataYTD = new dataYTD(colMnthName,colValues);
                                        if(monthValueMap.containsKey(colMnthName)){
                                                   List<Decimal> values = monthValueMap.get(colMnthName);
                                                   values.addAll(colValues);
                                                   monthValueMap.remove(colMnthName);
                                                   monthValueMap.put(colMnthName,new List<Decimal>());
                                        }else{
                                            monthValueMap.put(colMnthName,new List<Decimal>());
                                        }
                                        monthList.add(colMnthName);
                                        monthNameList.add(monthNameMap.get(colMnthName));
                                        listdataYTD.add(odataYTD);
                                    }
                                }
                                if(selectedDisplayType == 'Gregorian Calendar')
                                {
                                    monthStringValueMapGreg = new Map<String,List<String>>();
                                    Integer prodindex = 2*gregUnitSalesIndex;
                                    GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getGregorianYTDUnitSalesData(monthNameMap,monthValueMap,prodindex);
                                    oaccntSalesData2.clear();
                                    oaccntSalesData2 = gregwrappobj.oaccntSalesData2;
                                    monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                    monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                    monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                    gregUnitSalesIndex = gregUnitSalesIndex+1;
                                    for(String s: monthValueMapGreg.keySet())
                                    {
                                        monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                    }
                                    
                                }
                                for(String s: monthValueMap.keySet())
                                {
                                    monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                                }
                                
                              
                            }
                            oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1c,oaccntSalesData1,new List<String>(convertDecimaltoString(oaccntSalesData2)),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('1')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('2')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('3')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('4')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('5')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('6')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('7')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('8')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('9')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('10')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('11')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('12')))));
                            listAccntSalesDataValue.add(oAccntSalesDV);
                        }
                        //if TotalSales tab is selected
                        else if(selectedReport == 'TotalSales'){                
                            // new code added
                            List<Double> listIntCurrent = mapSalesDataTotal.get(System.label.ZTS_EU_Current_Year);
                            List<Double> listIntPrior = mapSalesDataTotal.get(System.label.ZTS_EU_Previous_Year);
                            List<Double> listIntDollDiff = mapSalesDataTotal.get(System.label.ZTS_EU_Diff_Sales);
                            List<Double> listIntPerDiff = mapSalesDataTotal.get('%'+System.label.ZTS_EU_Diff_Sales);
                            Double intCurrent = osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                            Double intPrior = osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                            Double intDollDiff = osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                            Double intPerDiff = osalesData.ZTS_EU_Total_MAT_P_Diff_Sales__c;
                            if(selectedMATYTD == 'YTD'){
                                intCurrent = osalesData.ZTS_EU_Total_CYTD_Sales__c;
                                intPrior = osalesData.ZTS_EU_Total_PYTD_Sales__c;
                                intDollDiff = osalesData.ZTS_EU_Total_YTD_Diff_Sales__c;
                                intPerDiff = osalesData.ZTS_EU_Total_YTD_P_Diff_Sales__c;
                            }
                            if(listIntCurrent == null){
                                listIntCurrent = new List<Double>{intCurrent,osalesData.ZTS_EU_01_Current_Sales__c,osalesData.ZTS_EU_02_Current_Sales__c,osalesData.ZTS_EU_03_Current_Sales__c,osalesData.ZTS_EU_04_Current_Sales__c,osalesData.ZTS_EU_05_Current_Sales__c,osalesData.ZTS_EU_06_Current_Sales__c,osalesData.ZTS_EU_07_Current_Sales__c,osalesData.ZTS_EU_08_Current_Sales__c,osalesData.ZTS_EU_09_Current_Sales__c,osalesData.ZTS_EU_10_Current_Sales__c,osalesData.ZTS_EU_11_Current_Sales__c,osalesData.ZTS_EU_12_Current_Sales__c};     
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntCurrent[0]+intCurrent);
                                listTemp.add(listIntCurrent[1]+osalesData.ZTS_EU_01_Current_Sales__c);
                                listTemp.add(listIntCurrent[2]+osalesData.ZTS_EU_02_Current_Sales__c);
                                listTemp.add(listIntCurrent[3]+osalesData.ZTS_EU_03_Current_Sales__c);
                                listTemp.add(listIntCurrent[4]+osalesData.ZTS_EU_04_Current_Sales__c);
                                listTemp.add(listIntCurrent[5]+osalesData.ZTS_EU_05_Current_Sales__c);
                                listTemp.add(listIntCurrent[6]+osalesData.ZTS_EU_06_Current_Sales__c);
                                listTemp.add(listIntCurrent[7]+osalesData.ZTS_EU_07_Current_Sales__c);
                                listTemp.add(listIntCurrent[8]+osalesData.ZTS_EU_08_Current_Sales__c);
                                listTemp.add(listIntCurrent[9]+osalesData.ZTS_EU_09_Current_Sales__c);
                                listTemp.add(listIntCurrent[10]+osalesData.ZTS_EU_10_Current_Sales__c);
                                listTemp.add(listIntCurrent[11]+osalesData.ZTS_EU_11_Current_Sales__c);
                                listTemp.add(listIntCurrent[12]+osalesData.ZTS_EU_12_Current_Sales__c);
                                listIntCurrent.clear();
                                listIntCurrent = listTemp;
                            }
                            mapSalesDataTotal.put(System.label.ZTS_EU_Current_Year,listIntCurrent);              
                            if(listIntPrior == null){
                                listIntPrior = new List<Double>{intPrior,osalesData.ZTS_EU_01_Previous_Sales__c,osalesData.ZTS_EU_02_Previous_Sales__c,osalesData.ZTS_EU_03_Previous_Sales__c,osalesData.ZTS_EU_04_Previous_Sales__c,osalesData.ZTS_EU_05_Previous_Sales__c,osalesData.ZTS_EU_06_Previous_Sales__c,osalesData.ZTS_EU_07_Previous_Sales__c,osalesData.ZTS_EU_08_Previous_Sales__c,osalesData.ZTS_EU_09_Previous_Sales__c,osalesData.ZTS_EU_10_Previous_Sales__c,osalesData.ZTS_EU_11_Previous_Sales__c,osalesData.ZTS_EU_12_Previous_Sales__c};                    
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntPrior[0]+intPrior);
                                listTemp.add(listIntPrior[1]+osalesData.ZTS_EU_01_Previous_Sales__c);
                                listTemp.add(listIntPrior[2]+osalesData.ZTS_EU_02_Previous_Sales__c);
                                listTemp.add(listIntPrior[3]+osalesData.ZTS_EU_03_Previous_Sales__c);
                                listTemp.add(listIntPrior[4]+osalesData.ZTS_EU_04_Previous_Sales__c);
                                listTemp.add(listIntPrior[5]+osalesData.ZTS_EU_05_Previous_Sales__c);
                                listTemp.add(listIntPrior[6]+osalesData.ZTS_EU_06_Previous_Sales__c);
                                listTemp.add(listIntPrior[7]+osalesData.ZTS_EU_07_Previous_Sales__c);
                                listTemp.add(listIntPrior[8]+osalesData.ZTS_EU_08_Previous_Sales__c);
                                listTemp.add(listIntPrior[9]+osalesData.ZTS_EU_09_Previous_Sales__c);
                                listTemp.add(listIntPrior[10]+osalesData.ZTS_EU_10_Previous_Sales__c);
                                listTemp.add(listIntPrior[11]+osalesData.ZTS_EU_11_Previous_Sales__c);
                                listTemp.add(listIntPrior[12]+osalesData.ZTS_EU_12_Previous_Sales__c);
                                listIntPrior = listTemp;
                            }
                            mapSalesDataTotal.put(System.label.ZTS_EU_Previous_Year,listIntPrior);              
                            if(listIntDollDiff == null){
                                listIntDollDiff = new List<Double>{intDollDiff,osalesData.ZTS_EU_01_Diff_Sales__c,osalesData.ZTS_EU_02_Diff_Sales__c,osalesData.ZTS_EU_03_Diff_Sales__c,osalesData.ZTS_EU_04_Diff_Sales__c,osalesData.ZTS_EU_05_Diff_Sales__c,osalesData.ZTS_EU_06_Diff_Sales__c,osalesData.ZTS_EU_07_Diff_Sales__c,osalesData.ZTS_EU_08_Diff_Sales__c,osalesData.ZTS_EU_09_Diff_Sales__c,osalesData.ZTS_EU_10_Diff_Sales__c,osalesData.ZTS_EU_11_Diff_Sales__c,osalesData.ZTS_EU_12_Diff_Sales__c};                  
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntDollDiff[0]+intDollDiff);
                                listTemp.add(listIntDollDiff[1]+osalesData.ZTS_EU_01_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[2]+osalesData.ZTS_EU_02_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[3]+osalesData.ZTS_EU_03_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[4]+osalesData.ZTS_EU_04_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[5]+osalesData.ZTS_EU_05_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[6]+osalesData.ZTS_EU_06_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[7]+osalesData.ZTS_EU_07_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[8]+osalesData.ZTS_EU_08_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[9]+osalesData.ZTS_EU_09_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[10]+osalesData.ZTS_EU_10_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[11]+osalesData.ZTS_EU_11_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[12]+osalesData.ZTS_EU_12_Diff_Sales__c);
                                listIntDollDiff = listTemp;
                            }
                            mapSalesDataTotal.put(System.label.ZTS_EU_Diff_Sales,listIntDollDiff);               
                            if(listIntPerDiff == null){
                                listIntPerDiff = new List<Double>{intPerDiff,osalesData.ZTS_EU_01_P_Diff_Sales__c,osalesData.ZTS_EU_02_P_Diff_Sales__c,osalesData.ZTS_EU_03_P_Diff_Sales__c,osalesData.ZTS_EU_04_P_Diff_Sales__c,osalesData.ZTS_EU_05_P_Diff_Sales__c,osalesData.ZTS_EU_06_P_Diff_Sales__c,osalesData.ZTS_EU_07_P_Diff_Sales__c,osalesData.ZTS_EU_08_P_Diff_Sales__c,osalesData.ZTS_EU_09_P_Diff_Sales__c,osalesData.ZTS_EU_10_P_Diff_Sales__c,osalesData.ZTS_EU_11_P_Diff_Sales__c,osalesData.ZTS_EU_12_P_Diff_Sales__c};                 
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntPerDiff[0]+intPerDiff);
                                listTemp.add(listIntPerDiff[1]+osalesData.ZTS_EU_01_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[2]+osalesData.ZTS_EU_02_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[3]+osalesData.ZTS_EU_03_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[4]+osalesData.ZTS_EU_04_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[5]+osalesData.ZTS_EU_05_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[6]+osalesData.ZTS_EU_06_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[7]+osalesData.ZTS_EU_07_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[8]+osalesData.ZTS_EU_08_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[9]+osalesData.ZTS_EU_09_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[10]+osalesData.ZTS_EU_10_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[11]+osalesData.ZTS_EU_11_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[12]+osalesData.ZTS_EU_12_P_Diff_Sales__c);
                                listIntPerDiff = listTemp;
                            }
                            mapSalesDataTotal.put('%'+System.label.ZTS_EU_Diff_Sales,listIntPerDiff);
                        }
                        //if ProductSales tab is selected
                        else if(selectedReport == 'ProductSales'){
                            List<String> oaccntSalesData1a = new List<String>{String.valueOf(osalesData.ZTS_EU_Therapeutic_Group__c)};
                            List<String> oaccntSalesData1b = new List<String>{String.valueOf(osalesData.ZTS_EU_Brand__c)};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales};
                            List<Decimal> oaccntSalesData2;
                            if(selectedMATYTD == 'YTD'){
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_CYTD_Sales__c,osalesData.ZTS_EU_Total_PYTD_Sales__c,osalesData.ZTS_EU_Total_YTD_Diff_Sales__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total') && !diffSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_CYTD_Sales__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_PYTD_Sales__c);
                                    diffSumMap.put('total',osalesData.ZTS_EU_Total_YTD_Diff_Sales__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_CYTD_Sales__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_PYTD_Sales__c;
                                    Decimal diffVal = diffSumMap.get('total') + osalesData.ZTS_EU_Total_YTD_Diff_Sales__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                    diffSumMap.put('total', diffVal);
                                }
                            }else{
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_MAT_Current_Sales__c,osalesData.ZTS_EU_Total_MAT_Prior_Sales__c,osalesData.ZTS_EU_Total_MAT_Diff_Sales__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total') && !diffSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Current_Sales__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Prior_Sales__c);
                                    diffSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Diff_Sales__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                                    Decimal diffVal = diffSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                    diffSumMap.put('total', diffVal);
                                }
                            }
                            
                            // Calculate sum of current and previous values for all sales records
                            if(!currentSumMap.containsKey('1') && !prevSumMap.containsKey('1') && !diffSumMap.containsKey('1')){
                                currentSumMap.put('1',osalesData.ZTS_EU_01_Current_Sales__c);
                                prevSumMap.put('1',osalesData.ZTS_EU_01_Previous_Sales__c);
                                diffSumMap.put('1',osalesData.ZTS_EU_01_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('1') + osalesData.ZTS_EU_01_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('1') + osalesData.ZTS_EU_01_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('1') + osalesData.ZTS_EU_01_Diff_Sales__c;
                                currentSumMap.put('1', currVal);
                                prevSumMap.put('1', prevVal);
                                diffSumMap.put('1', diffVal);
                            }
                            if(!currentSumMap.containsKey('2') && !prevSumMap.containsKey('2') && !diffSumMap.containsKey('2')){
                                currentSumMap.put('2',osalesData.ZTS_EU_02_Current_Sales__c);
                                prevSumMap.put('2',osalesData.ZTS_EU_02_Previous_Sales__c);
                                diffSumMap.put('2',osalesData.ZTS_EU_02_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('2') + osalesData.ZTS_EU_02_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('2') + osalesData.ZTS_EU_02_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('2') + osalesData.ZTS_EU_02_Diff_Sales__c;
                                currentSumMap.put('2', currVal);
                                prevSumMap.put('2', prevVal);
                                diffSumMap.put('2', diffVal);
                            }
                            if(!currentSumMap.containsKey('3') && !prevSumMap.containsKey('3') && !diffSumMap.containsKey('3')){
                                currentSumMap.put('3',osalesData.ZTS_EU_03_Current_Sales__c);
                                prevSumMap.put('3',osalesData.ZTS_EU_03_Previous_Sales__c);
                                diffSumMap.put('3',osalesData.ZTS_EU_03_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('3') + osalesData.ZTS_EU_03_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('3') + osalesData.ZTS_EU_03_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('3') + osalesData.ZTS_EU_03_Diff_Sales__c;
                                currentSumMap.put('3', currVal);
                                prevSumMap.put('3', prevVal);
                                diffSumMap.put('3', diffVal);
                            }
                            if(!currentSumMap.containsKey('4') && !prevSumMap.containsKey('4') && !diffSumMap.containsKey('4')){
                                currentSumMap.put('4',osalesData.ZTS_EU_04_Current_Sales__c);
                                prevSumMap.put('4',osalesData.ZTS_EU_04_Previous_Sales__c);
                                diffSumMap.put('4',osalesData.ZTS_EU_04_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('4') + osalesData.ZTS_EU_04_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('4') + osalesData.ZTS_EU_04_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('4') + osalesData.ZTS_EU_04_Diff_Sales__c;
                                currentSumMap.put('4', currVal);
                                prevSumMap.put('4', prevVal);
                                diffSumMap.put('4', diffVal);
                            }
                            if(!currentSumMap.containsKey('5') && !prevSumMap.containsKey('5') && !diffSumMap.containsKey('5')){
                                currentSumMap.put('5',osalesData.ZTS_EU_05_Current_Sales__c);
                                prevSumMap.put('5',osalesData.ZTS_EU_05_Previous_Sales__c);
                                diffSumMap.put('5',osalesData.ZTS_EU_05_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('5') + osalesData.ZTS_EU_05_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('5') + osalesData.ZTS_EU_05_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('5') + osalesData.ZTS_EU_05_Diff_Sales__c;
                                currentSumMap.put('5', currVal);
                                prevSumMap.put('5', prevVal);
                                diffSumMap.put('5', diffVal);
                            }
                            if(!currentSumMap.containsKey('6') && !prevSumMap.containsKey('6') && !diffSumMap.containsKey('6')){
                                currentSumMap.put('6',osalesData.ZTS_EU_06_Current_Sales__c);
                                prevSumMap.put('6',osalesData.ZTS_EU_06_Previous_Sales__c);
                                diffSumMap.put('6',osalesData.ZTS_EU_06_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('6') + osalesData.ZTS_EU_06_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('6') + osalesData.ZTS_EU_06_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('6') + osalesData.ZTS_EU_06_Diff_Sales__c;
                                currentSumMap.put('6', currVal);
                                prevSumMap.put('6', prevVal);
                                diffSumMap.put('6', diffVal);
                            }
                            if(!currentSumMap.containsKey('7') && !prevSumMap.containsKey('7') && !diffSumMap.containsKey('7')){
                                currentSumMap.put('7',osalesData.ZTS_EU_07_Current_Sales__c);
                                prevSumMap.put('7',osalesData.ZTS_EU_07_Previous_Sales__c);
                                diffSumMap.put('7',osalesData.ZTS_EU_07_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('7') + osalesData.ZTS_EU_07_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('7') + osalesData.ZTS_EU_07_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('7') + osalesData.ZTS_EU_07_Diff_Sales__c;
                                currentSumMap.put('7', currVal);
                                prevSumMap.put('7', prevVal);
                                diffSumMap.put('7', diffVal);
                            }
                            if(!currentSumMap.containsKey('8') && !prevSumMap.containsKey('8') && !diffSumMap.containsKey('8')){
                                currentSumMap.put('8',osalesData.ZTS_EU_08_Current_Sales__c);
                                prevSumMap.put('8',osalesData.ZTS_EU_08_Previous_Sales__c);
                                diffSumMap.put('8',osalesData.ZTS_EU_08_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('8') + osalesData.ZTS_EU_08_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('8') + osalesData.ZTS_EU_08_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('8') + osalesData.ZTS_EU_08_Diff_Sales__c;
                                currentSumMap.put('8', currVal);
                                prevSumMap.put('8', prevVal);
                                diffSumMap.put('8', diffVal);
                            }
                            if(!currentSumMap.containsKey('9') && !prevSumMap.containsKey('9') && !diffSumMap.containsKey('9')){
                                currentSumMap.put('9',osalesData.ZTS_EU_09_Current_Sales__c);
                                prevSumMap.put('9',osalesData.ZTS_EU_09_Previous_Sales__c);
                                diffSumMap.put('9',osalesData.ZTS_EU_09_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('9') + osalesData.ZTS_EU_09_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('9') + osalesData.ZTS_EU_09_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('9') + osalesData.ZTS_EU_09_Diff_Sales__c;
                                currentSumMap.put('9', currVal);
                                prevSumMap.put('9', prevVal);
                                diffSumMap.put('9', diffVal);
                            }
                            if(!currentSumMap.containsKey('10') && !prevSumMap.containsKey('10') && !diffSumMap.containsKey('10')){
                                currentSumMap.put('10',osalesData.ZTS_EU_10_Current_Sales__c);
                                prevSumMap.put('10',osalesData.ZTS_EU_10_Previous_Sales__c);
                                diffSumMap.put('10',osalesData.ZTS_EU_10_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('10') + osalesData.ZTS_EU_10_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('10') + osalesData.ZTS_EU_10_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('10') + osalesData.ZTS_EU_10_Diff_Sales__c;
                                currentSumMap.put('10', currVal);
                                prevSumMap.put('10', prevVal);
                                diffSumMap.put('10', diffVal);
                            }
                            if(!currentSumMap.containsKey('11') && !prevSumMap.containsKey('11') && !diffSumMap.containsKey('11')){
                                currentSumMap.put('11',osalesData.ZTS_EU_11_Current_Sales__c);
                                prevSumMap.put('11',osalesData.ZTS_EU_11_Previous_Sales__c);
                                diffSumMap.put('11',osalesData.ZTS_EU_11_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('11') + osalesData.ZTS_EU_11_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('11') + osalesData.ZTS_EU_11_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('11') + osalesData.ZTS_EU_11_Diff_Sales__c;
                                currentSumMap.put('11', currVal);
                                prevSumMap.put('11', prevVal);
                                diffSumMap.put('11', diffVal);
                            }
                            if(!currentSumMap.containsKey('12') && !prevSumMap.containsKey('12') && !diffSumMap.containsKey('12')){
                                currentSumMap.put('12',osalesData.ZTS_EU_12_Current_Sales__c);
                                prevSumMap.put('12',osalesData.ZTS_EU_12_Previous_Sales__c);
                                diffSumMap.put('12',osalesData.ZTS_EU_12_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('12') + osalesData.ZTS_EU_12_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('12') + osalesData.ZTS_EU_12_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('12') + osalesData.ZTS_EU_12_Diff_Sales__c;
                                currentSumMap.put('12', currVal);
                                prevSumMap.put('12', prevVal);
                                diffSumMap.put('12', diffVal);
                            }
                            
            
                            List<Decimal> oaccntSalesData3 = new List<Decimal>{osalesData.ZTS_EU_01_Current_Sales__c,osalesData.ZTS_EU_01_Previous_Sales__c,osalesData.ZTS_EU_01_Diff_Sales__c};
                            List<Decimal> oaccntSalesData4 = new List<Decimal>{osalesData.ZTS_EU_02_Current_Sales__c,osalesData.ZTS_EU_02_Previous_Sales__c,osalesData.ZTS_EU_02_Diff_Sales__c};
                            List<Decimal> oaccntSalesData5 = new List<Decimal>{osalesData.ZTS_EU_03_Current_Sales__c,osalesData.ZTS_EU_03_Previous_Sales__c,osalesData.ZTS_EU_03_Diff_Sales__c};
                            List<Decimal> oaccntSalesData6 = new List<Decimal>{osalesData.ZTS_EU_04_Current_Sales__c,osalesData.ZTS_EU_04_Previous_Sales__c,osalesData.ZTS_EU_04_Diff_Sales__c};
                            List<Decimal> oaccntSalesData7 = new List<Decimal>{osalesData.ZTS_EU_05_Current_Sales__c,osalesData.ZTS_EU_05_Previous_Sales__c,osalesData.ZTS_EU_05_Diff_Sales__c};
                            List<Decimal> oaccntSalesData8 = new List<Decimal>{osalesData.ZTS_EU_06_Current_Sales__c,osalesData.ZTS_EU_06_Previous_Sales__c,osalesData.ZTS_EU_06_Diff_Sales__c};
                            List<Decimal> oaccntSalesData9 = new List<Decimal>{osalesData.ZTS_EU_07_Current_Sales__c,osalesData.ZTS_EU_07_Previous_Sales__c,osalesData.ZTS_EU_07_Diff_Sales__c};
                            List<Decimal> oaccntSalesData10 = new List<Decimal>{osalesData.ZTS_EU_08_Current_Sales__c,osalesData.ZTS_EU_08_Previous_Sales__c,osalesData.ZTS_EU_08_Diff_Sales__c};
                            List<Decimal> oaccntSalesData11 = new List<Decimal>{osalesData.ZTS_EU_09_Current_Sales__c,osalesData.ZTS_EU_09_Previous_Sales__c,osalesData.ZTS_EU_09_Diff_Sales__c};
                            List<Decimal> oaccntSalesData12 = new List<Decimal>{osalesData.ZTS_EU_10_Current_Sales__c,osalesData.ZTS_EU_10_Previous_Sales__c,osalesData.ZTS_EU_10_Diff_Sales__c};
                            List<Decimal> oaccntSalesData13 = new List<Decimal>{osalesData.ZTS_EU_11_Current_Sales__c,osalesData.ZTS_EU_11_Previous_Sales__c,osalesData.ZTS_EU_11_Diff_Sales__c};
                            List<Decimal> oaccntSalesData14 = new List<Decimal>{osalesData.ZTS_EU_12_Current_Sales__c,osalesData.ZTS_EU_12_Previous_Sales__c,osalesData.ZTS_EU_12_Diff_Sales__c};
                            
                            Map<String, List<Decimal>> monthNoValueMap = new Map<String, List<Decimal>>();
                            monthNoValueMap.put('1',oaccntSalesData3);monthNoValueMap.put('2',oaccntSalesData4);monthNoValueMap.put('3',oaccntSalesData5);
                            monthNoValueMap.put('4',oaccntSalesData6);monthNoValueMap.put('5',oaccntSalesData7);monthNoValueMap.put('6',oaccntSalesData8);
                            monthNoValueMap.put('7',oaccntSalesData9);monthNoValueMap.put('8',oaccntSalesData10);monthNoValueMap.put('9',oaccntSalesData11);
                            monthNoValueMap.put('10',oaccntSalesData12);monthNoValueMap.put('11',oaccntSalesData13);monthNoValueMap.put('12',oaccntSalesData14);
                            
                            if(selectedMATYTD == 'YTD'){
                                listdataYTD = new List<dataYTD>();
                                
                                Integer j = 1;
                                dataYTD odataYTD;
                                monthList = new List<String>();                     
                                monthNameList = new List<String>();
                                Integer ytdStartCounter = tempMonthAPMap.get(1);
                                for(Integer i=ytdStartCounter-1; i> 0; i--){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                               List<Decimal> values = monthValueMap.get(colMnthName);
                                               values.addAll(colValues);
                                               monthValueMap.remove(colMnthName);
                                               monthValueMap.put(colMnthName,values);
                                    }else{
                                        monthValueMap.put(colMnthName,colValues);
                                    }
                                    
                                    monthNameList.add(monthNameMap.get(colMnthName));    
                                    monthList.add(colMnthName);
                                    listdataYTD.add(odataYTD);
                                }  
                               
                                if(ytdStartCounter < 12){
                                    for(Integer i=ytdStartCounter; i<= 12; i++){
                                        String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                        List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                        j = j + 1;
                                        odataYTD = new dataYTD(colMnthName,colValues);
                                        if(monthValueMap.containsKey(colMnthName)){
                                                   List<Decimal> values = monthValueMap.get(colMnthName);
                                                   values.addAll(colValues);
                                                   monthValueMap.remove(colMnthName);
                                                   monthValueMap.put(colMnthName,new List<Decimal>());
                                        }else{
                                            monthValueMap.put(colMnthName,new List<Decimal>());
                                        }
                                        
										monthNameList.add(monthNameMap.get(colMnthName));    
                                        monthList.add(colMnthName);
                                        listdataYTD.add(odataYTD);
                                    }
                                }
                                if(selectedDisplayType == 'Gregorian Calendar')
                                {
                                    monthStringValueMapGreg = new Map<String,List<String>>();
                                    Integer prodindex = 3*gregProdSalesIndex;
                                    GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getGregorianYTDProductSalesData(monthNameMap,monthValueMap,prodindex);
                                    oaccntSalesData2.clear();
                                    oaccntSalesData2 = gregwrappobj.oaccntSalesData2;
                                    monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                    monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                    monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                    gregProdSalesIndex = gregProdSalesIndex+1;
                                    for(String s: monthValueMapGreg.keySet())
                                    {
                                        monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                    }
                                    
                                }
                                for(String s: monthValueMap.keySet())
                                {
                                    monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                                }
                                
                               
                            }
                            oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1,new List<String>(convertDecimaltoString(oaccntSalesData2)),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('1')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('2')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('3')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('4')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('5')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('6')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('7')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('8')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('9')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('10')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('11')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('12')))));
							listAccntSalesDataValue.add(oAccntSalesDV);
                            
                        }     
                        
                    }
                    if(selectedReport == 'TotalSales'){
                        List<String> listStr = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales,'%'+System.label.ZTS_EU_Diff_Sales};
                        Map<String, List<Decimal>> monthNoValueMap = new Map<String, List<Decimal>>();
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
                                
                                oaccntSalesData2total.add(mapSalesDataTotal.get(oStr)[0]);
                                oaccntSalesData3total.add(mapSalesDataTotal.get(oStr)[1]);
                                oaccntSalesData4total.add(mapSalesDataTotal.get(oStr)[2]);
                                oaccntSalesData5total.add(mapSalesDataTotal.get(oStr)[3]);
                                oaccntSalesData6total.add(mapSalesDataTotal.get(oStr)[4]);
                                oaccntSalesData7total.add(mapSalesDataTotal.get(oStr)[5]);
                                oaccntSalesData8total.add(mapSalesDataTotal.get(oStr)[6]);
                                oaccntSalesData9total.add(mapSalesDataTotal.get(oStr)[7]);
                                oaccntSalesData10total.add(mapSalesDataTotal.get(oStr)[8]);
                                oaccntSalesData11total.add(mapSalesDataTotal.get(oStr)[9]);
                                oaccntSalesData12total.add(mapSalesDataTotal.get(oStr)[10]);
                                oaccntSalesData13total.add(mapSalesDataTotal.get(oStr)[11]);
                                oaccntSalesData14total.add(mapSalesDataTotal.get(oStr)[12]);
                            
                                
                            }
                            monthNoValueMap.put('1',oaccntSalesData3total);monthNoValueMap.put('2',oaccntSalesData4total);monthNoValueMap.put('3',oaccntSalesData5total);
                            monthNoValueMap.put('4',oaccntSalesData6total);monthNoValueMap.put('5',oaccntSalesData7total);monthNoValueMap.put('6',oaccntSalesData8total);
                            monthNoValueMap.put('7',oaccntSalesData9total);monthNoValueMap.put('8',oaccntSalesData10total);monthNoValueMap.put('9',oaccntSalesData11total);
                            monthNoValueMap.put('10',oaccntSalesData12total);monthNoValueMap.put('11',oaccntSalesData13total);monthNoValueMap.put('12',oaccntSalesData14total);
                                                
						if(selectedMATYTD == 'YTD')
                        {
                            listdataYTD = new List<dataYTD>();
                            /*mapTotalSalesYTD = new Map<String,List<String>>();
                            mapTotalSalesYTD.put('1a',oaccntSalesData1total);
                            mapTotalSalesYTD.put('1b',oaccntSalesData2total);*/
                            Integer j = 1;
                            dataYTD odataYTD;                   
                            monthList = new List<String>(); 
                            monthNameList = new List<String>();
                            Integer ytdStartCounter = tempMonthAPMap.get(1);
                            for(Integer i=ytdStartCounter-1; i> 0; i--){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                        if(monthValueMap.containsKey(colMnthName)){
                                            List<Decimal> values = monthValueMap.get(colMnthName);
                                            values.addAll(colValues);
                                            monthValueMap.remove(colMnthName);
                                            monthValueMap.put(colMnthName,values);
                                        }
                                        else{
                                        monthValueMap.put(colMnthName,colValues);
                                        }
                                        monthNameList.add(monthNameMap.get(colMnthName));    
                                        monthList.add(colMnthName);
                                        listdataYTD.add(odataYTD);
                                }           
                            if(ytdStartCounter < 12){
                                for(Integer i=ytdStartCounter; i<= 12; i++){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                        List<Decimal> values = monthValueMap.get(colMnthName);
                                        values.addAll(colValues);
                                        monthValueMap.remove(colMnthName);
                                        monthValueMap.put(colMnthName,new List<Decimal>());
                                    }
                                    else{
                                    monthValueMap.put(colMnthName,new List<Decimal>());
                                    }
                                    monthNameList.add(monthNameMap.get(colMnthName));    
                                    monthList.add(colMnthName);
                                    
                                    listdataYTD.add(odataYTD);
                                }
                            }
                            system.debug('monthValueMap in total sales before greg code call-->>'+monthValueMap);
                            if(selectedDisplayType == 'Gregorian Calendar')
                            {
                                monthStringValueMapGreg = new Map<String,List<String>>();
                                GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getGregorianYTDTotalSalesData(monthNameMap,monthValueMap);
                                oaccntSalesData2total.clear();
                                oaccntSalesData2total = gregwrappobj.oaccntSalesData2total;
                                monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                //mapTotalSalesYTD.remove('1b');
                                //mapTotalSalesYTD.put('1b',oaccntSalesData2total);
                                for(String str: monthValueMapGreg.keySet())
                                {
                                     monthStringValueMapGreg.put(str, new List<String>(convertDecimaltoString(monthValueMapGreg.get(str))));
                                }
                                
                            }
                            for(String s: monthValueMap.keySet())
                            {
                                 monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                            }
                            
                            
                        }
                        
                        
                        oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1total,new List<String>(convertDecimaltoString(oaccntSalesData2total)),
                                                                 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('12')))),
                                                                 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('11')))),
                                                                 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('10')))),
                        										 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('9')))),
                                                                                  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('8')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('7')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('6')))),
																			      new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('5')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('4')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('3')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('2')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('1')))));                                                                                                   
                                                                                  
                                         
                        
                        listAccntSalesDataValue.add(oAccntSalesDV);
                    }
                    if(selectedMATYTD == 'YTD'){
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue,listdataYTD);
                        if(selectedDisplayType != 'Gregorian Calendar')
                        	oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue, monthStringValueMap);
                        else
                            oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue, monthStringValueMapGreg); 
                    }
                    else {
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue);
                    }
                    listCustomSettSalesData.add(oCustomSettSalesData);
                    
                }//for loop end
            }//code for gross sales end
			else{//code for net sales start
                for(Id oaccntId : mapAccntIdlistSalesDataNetSales.keySet()){
                    String accName ;            
                    String accId ;
                    String narcId;
                    CustomSettSalesData oCustomSettSalesData;
                    Map<String, List<Decimal>> monthValueMap = new Map<String, List<Decimal>>();
                    Map<String, List<String>> monthStringValueMap = new Map<String, List<String>>();
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
                    List<Decimal> oaccntSalesData2total = new List<Decimal>();//for grand total
                    List<Decimal> oaccntSalesData3total = new List<Decimal>();
                    List<Decimal> oaccntSalesData4total = new List<Decimal>();
                    List<Decimal> oaccntSalesData5total = new List<Decimal>();
                    List<Decimal> oaccntSalesData6total = new List<Decimal>();
                    List<Decimal> oaccntSalesData7total = new List<Decimal>();
                    List<Decimal> oaccntSalesData8total = new List<Decimal>();
                    List<Decimal> oaccntSalesData9total = new List<Decimal>();
                    List<Decimal> oaccntSalesData10total = new List<Decimal>();
                    List<Decimal> oaccntSalesData11total = new List<Decimal>();
                    List<Decimal> oaccntSalesData12total = new List<Decimal>();
                    List<Decimal> oaccntSalesData13total = new List<Decimal>();
                    List<Decimal> oaccntSalesData14total = new List<Decimal>();
                    Integer gregUnitSalesIndex = 0;
                    Integer gregProdSalesIndex = 0;
                    for(ZTS_EU_Net_Sales__c osalesData : mapAccntIdlistSalesDataNetSales.get(oaccntId)){
                        //if UnitSales tab is selected
                        if(selectedReport == 'UnitSales'){
                            List<String> oaccntSalesData1a = new List<String>{String.valueOf(osalesData.ZTS_EU_Therapeutic_Group__c)};
                            List<String> oaccntSalesData1b = new List<String>{String.valueOf(osalesData.ZTS_EU_Brand__c)};
                            List<String> oaccntSalesData1c = new List<String>{String.valueOf(osalesData.ZTS_EU_Product_Line_Item__c)};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year};
                            List<Decimal> oaccntSalesData2;
                            if(selectedMATYTD == 'YTD'){
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_CYTD_Units__c,osalesData.ZTS_EU_Total_PYTD_Units__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_CYTD_Units__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_PYTD_Units__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_CYTD_Units__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_PYTD_Units__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                }
                            }else{
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_MAT_Current_Units__c,osalesData.ZTS_EU_Total_MAT_Prior_Units__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Current_Units__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Prior_Units__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Current_Units__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Prior_Units__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                }
                            }
                            
                            // Calculate sum of current and previous values for all sales records
                            if(!currentSumMap.containsKey('1') && !prevSumMap.containsKey('1')){
                                currentSumMap.put('1',osalesData.ZTS_EU_01_Current_Units__c);
                                prevSumMap.put('1',osalesData.ZTS_EU_01_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('1') + osalesData.ZTS_EU_01_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('1') + osalesData.ZTS_EU_01_Previous_Units__c;
                                currentSumMap.put('1', currVal);
                                prevSumMap.put('1', prevVal);
                            }
                            if(!currentSumMap.containsKey('2') && !prevSumMap.containsKey('2')){
                                currentSumMap.put('2',osalesData.ZTS_EU_02_Current_Units__c);
                                prevSumMap.put('2',osalesData.ZTS_EU_02_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('2') + osalesData.ZTS_EU_02_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('2') + osalesData.ZTS_EU_02_Previous_Units__c;
                                currentSumMap.put('2', currVal);
                                prevSumMap.put('2', prevVal);
                            }
                            if(!currentSumMap.containsKey('3') && !prevSumMap.containsKey('3')){
                                currentSumMap.put('3',osalesData.ZTS_EU_03_Current_Units__c);
                                prevSumMap.put('3',osalesData.ZTS_EU_03_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('3') + osalesData.ZTS_EU_03_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('3') + osalesData.ZTS_EU_03_Previous_Units__c;
                                currentSumMap.put('3', currVal);
                                prevSumMap.put('3', prevVal);
                            }
                            if(!currentSumMap.containsKey('4') && !prevSumMap.containsKey('4')){
                                currentSumMap.put('4',osalesData.ZTS_EU_04_Current_Units__c);
                                prevSumMap.put('4',osalesData.ZTS_EU_04_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('4') + osalesData.ZTS_EU_04_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('4') + osalesData.ZTS_EU_04_Previous_Units__c;
                                currentSumMap.put('4', currVal);
                                prevSumMap.put('4', prevVal);
                            }
                            if(!currentSumMap.containsKey('5') && !prevSumMap.containsKey('5')){
                                currentSumMap.put('5',osalesData.ZTS_EU_05_Current_Units__c);
                                prevSumMap.put('5',osalesData.ZTS_EU_05_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('5') + osalesData.ZTS_EU_05_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('5') + osalesData.ZTS_EU_05_Previous_Units__c;
                                currentSumMap.put('5', currVal);
                                prevSumMap.put('5', prevVal);
                            }
                            if(!currentSumMap.containsKey('6') && !prevSumMap.containsKey('6')){
                                currentSumMap.put('6',osalesData.ZTS_EU_06_Current_Units__c);
                                prevSumMap.put('6',osalesData.ZTS_EU_06_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('6') + osalesData.ZTS_EU_06_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('6') + osalesData.ZTS_EU_06_Previous_Units__c;
                                currentSumMap.put('6', currVal);
                                prevSumMap.put('6', prevVal);
                            }
                            if(!currentSumMap.containsKey('7') && !prevSumMap.containsKey('7')){
                                currentSumMap.put('7',osalesData.ZTS_EU_07_Current_Units__c);
                                prevSumMap.put('7',osalesData.ZTS_EU_07_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('7') + osalesData.ZTS_EU_07_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('7') + osalesData.ZTS_EU_07_Previous_Units__c;
                                currentSumMap.put('7', currVal);
                                prevSumMap.put('7', prevVal);
                            }
                            if(!currentSumMap.containsKey('8') && !prevSumMap.containsKey('8')){
                                currentSumMap.put('8',osalesData.ZTS_EU_08_Current_Units__c);
                                prevSumMap.put('8',osalesData.ZTS_EU_08_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('8') + osalesData.ZTS_EU_08_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('8') + osalesData.ZTS_EU_08_Previous_Units__c;
                                currentSumMap.put('8', currVal);
                                prevSumMap.put('8', prevVal);
                            }
                            if(!currentSumMap.containsKey('9') && !prevSumMap.containsKey('9')){
                                currentSumMap.put('9',osalesData.ZTS_EU_09_Current_Units__c);
                                prevSumMap.put('9',osalesData.ZTS_EU_09_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('9') + osalesData.ZTS_EU_09_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('9') + osalesData.ZTS_EU_09_Previous_Units__c;
                                currentSumMap.put('9', currVal);
                                prevSumMap.put('9', prevVal);
                            }
                            if(!currentSumMap.containsKey('10') && !prevSumMap.containsKey('10')){
                                currentSumMap.put('10',osalesData.ZTS_EU_10_Current_Units__c);
                                prevSumMap.put('10',osalesData.ZTS_EU_10_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('10') + osalesData.ZTS_EU_10_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('10') + osalesData.ZTS_EU_10_Previous_Units__c;
                                currentSumMap.put('10', currVal);
                                prevSumMap.put('10', prevVal);
                            }
                            if(!currentSumMap.containsKey('11') && !prevSumMap.containsKey('11')){
                                currentSumMap.put('11',osalesData.ZTS_EU_11_Current_Units__c);
                                prevSumMap.put('11',osalesData.ZTS_EU_11_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('11') + osalesData.ZTS_EU_11_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('11') + osalesData.ZTS_EU_11_Previous_Units__c;
                                currentSumMap.put('11', currVal);
                                prevSumMap.put('11', prevVal);
                            }
                            if(!currentSumMap.containsKey('12') && !prevSumMap.containsKey('12')){
                                currentSumMap.put('12',osalesData.ZTS_EU_12_Current_Units__c);
                                prevSumMap.put('12',osalesData.ZTS_EU_12_Previous_Units__c);
                            }else{
                                Decimal currVal = currentSumMap.get('12') + osalesData.ZTS_EU_12_Current_Units__c;
                                Decimal prevVal = prevSumMap.get('12') + osalesData.ZTS_EU_12_Previous_Units__c;
                                currentSumMap.put('12', currVal);
                                prevSumMap.put('12', prevVal);
                            }
                            
                            List<List<Decimal>> oaccntSalesDataList = new List<List<Decimal>>();
                            Map<String, List<Decimal>> monthNoValueMap = new Map<String, List<Decimal>>();
                            List<Decimal> fieldValueList ;
                            Integer counter=1;
                            for(Integer i=1; i<=12;i ++){
                                if(i == 1){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_01_Current_Units__c,osalesData.ZTS_EU_01_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 2){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_02_Current_Units__c,osalesData.ZTS_EU_02_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 3){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_03_Current_Units__c,osalesData.ZTS_EU_03_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 4){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_04_Current_Units__c,osalesData.ZTS_EU_04_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 5){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_05_Current_Units__c,osalesData.ZTS_EU_05_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 6){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_06_Current_Units__c,osalesData.ZTS_EU_06_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 7){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_07_Current_Units__c,osalesData.ZTS_EU_07_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 8){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_08_Current_Units__c,osalesData.ZTS_EU_08_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 9){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_09_Current_Units__c,osalesData.ZTS_EU_09_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 10){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_10_Current_Units__c,osalesData.ZTS_EU_10_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 11){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_11_Current_Units__c,osalesData.ZTS_EU_11_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }else if(i == 12){
                                    fieldValueList = new List<Decimal>{osalesData.ZTS_EU_12_Current_Units__c,osalesData.ZTS_EU_12_Previous_Units__c};
                                    oaccntSalesDataList.add(fieldValueList);
                                    monthNoValueMap.put(String.valueOf(i),fieldValueList);
                                }
                                
                                
                            }
                            
                            if(selectedMATYTD == 'YTD'){
                                listdataYTD = new List<dataYTD>();
                                
                                Integer j = 1;
                                dataYTD odataYTD;                       
                                monthList = new List<String>();                     
                                monthNameList = new List<String>();
                                Integer ytdStartCounter = tempMonthAPMap.get(1);
                                for(Integer i=ytdStartCounter-1; i> 0; i--){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                               List<Decimal> values = monthValueMap.get(colMnthName);
                                               values.addAll(colValues);
                                               monthValueMap.remove(colMnthName);
                                               monthValueMap.put(colMnthName,values);
                                    }else{
                                        monthValueMap.put(colMnthName,colValues);
                                    }
                                 
                                    monthList.add(colMnthName);
                                    monthNameList.add(monthNameMap.get(colMnthName));
                                    listdataYTD.add(odataYTD);
                                }  
                                
                                if(ytdStartCounter < 12){
                                    for(Integer i=ytdStartCounter; i<= 12; i++){
                                        String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                        List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                        j = j + 1;
                                        odataYTD = new dataYTD(colMnthName,colValues);
                                        if(monthValueMap.containsKey(colMnthName)){
                                                   List<Decimal> values = monthValueMap.get(colMnthName);
                                                   values.addAll(colValues);
                                                   monthValueMap.remove(colMnthName);
                                                   monthValueMap.put(colMnthName,new List<Decimal>());
                                        }else{
                                            monthValueMap.put(colMnthName,new List<Decimal>());
                                        }
                                       monthList.add(colMnthName);
                                        monthNameList.add(monthNameMap.get(colMnthName));
                                        listdataYTD.add(odataYTD);
                                    }
								}
                             if(selectedDisplayType == 'Gregorian Calendar')
                                {
                                    monthStringValueMapGreg = new Map<String,List<String>>();
									Integer prodindex = 2*gregUnitSalesIndex;
                                    GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getGregorianYTDUnitSalesData(monthNameMap,monthValueMap,prodindex);
                                    oaccntSalesData2.clear();
                                    oaccntSalesData2 = gregwrappobj.oaccntSalesData2;
                                    monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                    monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                    monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                    gregUnitSalesIndex = gregUnitSalesIndex+1;
                                    for(String s: monthValueMapGreg.keySet())
                                    {
                                        monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                    }
                                    
                                }
                                for(String s: monthValueMap.keySet())
                                {
                                    monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                                }
                                
                            }
                            oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1c,oaccntSalesData1,new List<String>(convertDecimaltoString(oaccntSalesData2)),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('1')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('2')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('3')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('4')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('5')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('6')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('7')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('8')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('9')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('10')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('11')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('12')))));
                            listAccntSalesDataValue.add(oAccntSalesDV);
                        }
                        //if TotalSales tab is selected
                        else if(selectedReport == 'TotalSales'){                
                            // new code added
                            List<Double> listIntCurrent = mapSalesDataTotal.get(System.label.ZTS_EU_Current_Year);
                            List<Double> listIntPrior = mapSalesDataTotal.get(System.label.ZTS_EU_Previous_Year);
                            List<Double> listIntDollDiff = mapSalesDataTotal.get(System.label.ZTS_EU_Diff_Sales);
                            List<Double> listIntPerDiff = mapSalesDataTotal.get('%'+System.label.ZTS_EU_Diff_Sales);
                            Double intCurrent = osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                            Double intPrior = osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                            Double intDollDiff = osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                            Double intPerDiff = osalesData.ZTS_EU_Total_MAT_P_Diff_Sales__c;
                            if(selectedMATYTD == 'YTD'){
                                intCurrent = osalesData.ZTS_EU_Total_CYTD_Sales__c;
                                intPrior = osalesData.ZTS_EU_Total_PYTD_Sales__c;
                                intDollDiff = osalesData.ZTS_EU_Total_YTD_Diff_Sales__c;
                                intPerDiff = osalesData.ZTS_EU_Total_YTD_P_Diff_Sales__c;
                            }
                            
                            if(listIntCurrent == null){
                                listIntCurrent = new List<Double>{intCurrent,osalesData.ZTS_EU_01_Current_Sales__c,osalesData.ZTS_EU_02_Current_Sales__c,osalesData.ZTS_EU_03_Current_Sales__c,osalesData.ZTS_EU_04_Current_Sales__c,osalesData.ZTS_EU_05_Current_Sales__c,osalesData.ZTS_EU_06_Current_Sales__c,osalesData.ZTS_EU_07_Current_Sales__c,osalesData.ZTS_EU_08_Current_Sales__c,osalesData.ZTS_EU_09_Current_Sales__c,osalesData.ZTS_EU_10_Current_Sales__c,osalesData.ZTS_EU_11_Current_Sales__c,osalesData.ZTS_EU_12_Current_Sales__c};     
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntCurrent[0]+intCurrent);
                                listTemp.add(listIntCurrent[1]+osalesData.ZTS_EU_01_Current_Sales__c);
                                listTemp.add(listIntCurrent[2]+osalesData.ZTS_EU_02_Current_Sales__c);
                                listTemp.add(listIntCurrent[3]+osalesData.ZTS_EU_03_Current_Sales__c);
                                listTemp.add(listIntCurrent[4]+osalesData.ZTS_EU_04_Current_Sales__c);
                                listTemp.add(listIntCurrent[5]+osalesData.ZTS_EU_05_Current_Sales__c);
                                listTemp.add(listIntCurrent[6]+osalesData.ZTS_EU_06_Current_Sales__c);
                                listTemp.add(listIntCurrent[7]+osalesData.ZTS_EU_07_Current_Sales__c);
                                listTemp.add(listIntCurrent[8]+osalesData.ZTS_EU_08_Current_Sales__c);
                                listTemp.add(listIntCurrent[9]+osalesData.ZTS_EU_09_Current_Sales__c);
                                listTemp.add(listIntCurrent[10]+osalesData.ZTS_EU_10_Current_Sales__c);
                                listTemp.add(listIntCurrent[11]+osalesData.ZTS_EU_11_Current_Sales__c);
                                listTemp.add(listIntCurrent[12]+osalesData.ZTS_EU_12_Current_Sales__c);
                                listIntCurrent.clear();
                                listIntCurrent = listTemp;
                            }
                            mapSalesDataTotal.put(System.label.ZTS_EU_Current_Year,listIntCurrent);              
                            if(listIntPrior == null){
                                listIntPrior = new List<Double>{intPrior,osalesData.ZTS_EU_01_Previous_Sales__c,osalesData.ZTS_EU_02_Previous_Sales__c,osalesData.ZTS_EU_03_Previous_Sales__c,osalesData.ZTS_EU_04_Previous_Sales__c,osalesData.ZTS_EU_05_Previous_Sales__c,osalesData.ZTS_EU_06_Previous_Sales__c,osalesData.ZTS_EU_07_Previous_Sales__c,osalesData.ZTS_EU_08_Previous_Sales__c,osalesData.ZTS_EU_09_Previous_Sales__c,osalesData.ZTS_EU_10_Previous_Sales__c,osalesData.ZTS_EU_11_Previous_Sales__c,osalesData.ZTS_EU_12_Previous_Sales__c};                    
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntPrior[0]+intPrior);
                                listTemp.add(listIntPrior[1]+osalesData.ZTS_EU_01_Previous_Sales__c);
                                listTemp.add(listIntPrior[2]+osalesData.ZTS_EU_02_Previous_Sales__c);
                                listTemp.add(listIntPrior[3]+osalesData.ZTS_EU_03_Previous_Sales__c);
                                listTemp.add(listIntPrior[4]+osalesData.ZTS_EU_04_Previous_Sales__c);
                                listTemp.add(listIntPrior[5]+osalesData.ZTS_EU_05_Previous_Sales__c);
                                listTemp.add(listIntPrior[6]+osalesData.ZTS_EU_06_Previous_Sales__c);
                                listTemp.add(listIntPrior[7]+osalesData.ZTS_EU_07_Previous_Sales__c);
                                listTemp.add(listIntPrior[8]+osalesData.ZTS_EU_08_Previous_Sales__c);
                                listTemp.add(listIntPrior[9]+osalesData.ZTS_EU_09_Previous_Sales__c);
                                listTemp.add(listIntPrior[10]+osalesData.ZTS_EU_10_Previous_Sales__c);
                                listTemp.add(listIntPrior[11]+osalesData.ZTS_EU_11_Previous_Sales__c);
                                listTemp.add(listIntPrior[12]+osalesData.ZTS_EU_12_Previous_Sales__c);
                                listIntPrior = listTemp;
                            }
                            mapSalesDataTotal.put(System.label.ZTS_EU_Previous_Year,listIntPrior);              
                            if(listIntDollDiff == null){
                                listIntDollDiff = new List<Double>{intDollDiff,osalesData.ZTS_EU_01_Diff_Sales__c,osalesData.ZTS_EU_02_Diff_Sales__c,osalesData.ZTS_EU_03_Diff_Sales__c,osalesData.ZTS_EU_04_Diff_Sales__c,osalesData.ZTS_EU_05_Diff_Sales__c,osalesData.ZTS_EU_06_Diff_Sales__c,osalesData.ZTS_EU_07_Diff_Sales__c,osalesData.ZTS_EU_08_Diff_Sales__c,osalesData.ZTS_EU_09_Diff_Sales__c,osalesData.ZTS_EU_10_Diff_Sales__c,osalesData.ZTS_EU_11_Diff_Sales__c,osalesData.ZTS_EU_12_Diff_Sales__c};                  
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntDollDiff[0]+intDollDiff);
                                listTemp.add(listIntDollDiff[1]+osalesData.ZTS_EU_01_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[2]+osalesData.ZTS_EU_02_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[3]+osalesData.ZTS_EU_03_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[4]+osalesData.ZTS_EU_04_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[5]+osalesData.ZTS_EU_05_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[6]+osalesData.ZTS_EU_06_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[7]+osalesData.ZTS_EU_07_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[8]+osalesData.ZTS_EU_08_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[9]+osalesData.ZTS_EU_09_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[10]+osalesData.ZTS_EU_10_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[11]+osalesData.ZTS_EU_11_Diff_Sales__c);
                                listTemp.add(listIntDollDiff[12]+osalesData.ZTS_EU_12_Diff_Sales__c);
                                listIntDollDiff = listTemp;
                            }
                            mapSalesDataTotal.put(System.label.ZTS_EU_Diff_Sales,listIntDollDiff);               
                            if(listIntPerDiff == null){
                                listIntPerDiff = new List<Double>{intPerDiff,osalesData.ZTS_EU_01_P_Diff_Sales__c,osalesData.ZTS_EU_02_P_Diff_Sales__c,osalesData.ZTS_EU_03_P_Diff_Sales__c,osalesData.ZTS_EU_04_P_Diff_Sales__c,osalesData.ZTS_EU_05_P_Diff_Sales__c,osalesData.ZTS_EU_06_P_Diff_Sales__c,osalesData.ZTS_EU_07_P_Diff_Sales__c,osalesData.ZTS_EU_08_P_Diff_Sales__c,osalesData.ZTS_EU_09_P_Diff_Sales__c,osalesData.ZTS_EU_10_P_Diff_Sales__c,osalesData.ZTS_EU_11_P_Diff_Sales__c,osalesData.ZTS_EU_12_P_Diff_Sales__c};                 
                            }
                            else {
                                List<Double> listTemp = new List<Double>();
                                listTemp.add(listIntPerDiff[0]+intPerDiff);
                                listTemp.add(listIntPerDiff[1]+osalesData.ZTS_EU_01_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[2]+osalesData.ZTS_EU_02_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[3]+osalesData.ZTS_EU_03_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[4]+osalesData.ZTS_EU_04_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[5]+osalesData.ZTS_EU_05_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[6]+osalesData.ZTS_EU_06_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[7]+osalesData.ZTS_EU_07_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[8]+osalesData.ZTS_EU_08_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[9]+osalesData.ZTS_EU_09_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[10]+osalesData.ZTS_EU_10_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[11]+osalesData.ZTS_EU_11_P_Diff_Sales__c);
                                listTemp.add(listIntPerDiff[12]+osalesData.ZTS_EU_12_P_Diff_Sales__c);
                                listIntPerDiff = listTemp;
                            }
                            mapSalesDataTotal.put('%'+System.label.ZTS_EU_Diff_Sales,listIntPerDiff);
                        }
                        //if ProductSales tab is selected
                        else if(selectedReport == 'ProductSales'){
                            List<String> oaccntSalesData1a = new List<String>{String.valueOf(osalesData.ZTS_EU_Therapeutic_Group__c)};
                            List<String> oaccntSalesData1b = new List<String>{String.valueOf(osalesData.ZTS_EU_Brand__c)};
                            List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales};
                            List<Decimal> oaccntSalesData2;
                            if(selectedMATYTD == 'YTD'){
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_CYTD_Sales__c,osalesData.ZTS_EU_Total_PYTD_Sales__c,osalesData.ZTS_EU_Total_YTD_Diff_Sales__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total') && !diffSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_CYTD_Sales__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_PYTD_Sales__c);
                                    diffSumMap.put('total',osalesData.ZTS_EU_Total_YTD_Diff_Sales__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_CYTD_Sales__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_PYTD_Sales__c;
                                    Decimal diffVal = diffSumMap.get('total') + osalesData.ZTS_EU_Total_YTD_Diff_Sales__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                    diffSumMap.put('total', diffVal);
                                }
                            }else{
                                oaccntSalesData2 = new List<Decimal>{osalesData.ZTS_EU_Total_MAT_Current_Sales__c,osalesData.ZTS_EU_Total_MAT_Prior_Sales__c,osalesData.ZTS_EU_Total_MAT_Diff_Sales__c};
                                if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total') && !diffSumMap.containsKey('total')){
                                    currentSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Current_Sales__c);
                                    prevSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Prior_Sales__c);
                                    diffSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Diff_Sales__c);
                                }else{
                                    Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                                    Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                                    Decimal diffVal = diffSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                                    currentSumMap.put('total', currVal);
                                    prevSumMap.put('total', prevVal);
                                    diffSumMap.put('total', diffVal);
                                }
                            }
                            
                            // Calculate sum of current and previous values for all sales records
                            if(!currentSumMap.containsKey('1') && !prevSumMap.containsKey('1') && !diffSumMap.containsKey('1')){
                                currentSumMap.put('1',osalesData.ZTS_EU_01_Current_Sales__c);
                                prevSumMap.put('1',osalesData.ZTS_EU_01_Previous_Sales__c);
                                diffSumMap.put('1',osalesData.ZTS_EU_01_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('1') + osalesData.ZTS_EU_01_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('1') + osalesData.ZTS_EU_01_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('1') + osalesData.ZTS_EU_01_Diff_Sales__c;
                                currentSumMap.put('1', currVal);
                                prevSumMap.put('1', prevVal);
                                diffSumMap.put('1', diffVal);
                            }
                            if(!currentSumMap.containsKey('2') && !prevSumMap.containsKey('2') && !diffSumMap.containsKey('2')){
                                currentSumMap.put('2',osalesData.ZTS_EU_02_Current_Sales__c);
                                prevSumMap.put('2',osalesData.ZTS_EU_02_Previous_Sales__c);
                                diffSumMap.put('2',osalesData.ZTS_EU_02_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('2') + osalesData.ZTS_EU_02_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('2') + osalesData.ZTS_EU_02_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('2') + osalesData.ZTS_EU_02_Diff_Sales__c;
                                currentSumMap.put('2', currVal);
                                prevSumMap.put('2', prevVal);
                                diffSumMap.put('2', diffVal);
                            }
                            if(!currentSumMap.containsKey('3') && !prevSumMap.containsKey('3') && !diffSumMap.containsKey('3')){
                                currentSumMap.put('3',osalesData.ZTS_EU_03_Current_Sales__c);
                                prevSumMap.put('3',osalesData.ZTS_EU_03_Previous_Sales__c);
                                diffSumMap.put('3',osalesData.ZTS_EU_03_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('3') + osalesData.ZTS_EU_03_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('3') + osalesData.ZTS_EU_03_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('3') + osalesData.ZTS_EU_03_Diff_Sales__c;
                                currentSumMap.put('3', currVal);
                                prevSumMap.put('3', prevVal);
                                diffSumMap.put('3', diffVal);
                            }
                            if(!currentSumMap.containsKey('4') && !prevSumMap.containsKey('4') && !diffSumMap.containsKey('4')){
                                currentSumMap.put('4',osalesData.ZTS_EU_04_Current_Sales__c);
                                prevSumMap.put('4',osalesData.ZTS_EU_04_Previous_Sales__c);
                                diffSumMap.put('4',osalesData.ZTS_EU_04_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('4') + osalesData.ZTS_EU_04_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('4') + osalesData.ZTS_EU_04_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('4') + osalesData.ZTS_EU_04_Diff_Sales__c;
                                currentSumMap.put('4', currVal);
                                prevSumMap.put('4', prevVal);
                                diffSumMap.put('4', diffVal);
                            }
                            if(!currentSumMap.containsKey('5') && !prevSumMap.containsKey('5') && !diffSumMap.containsKey('5')){
                                currentSumMap.put('5',osalesData.ZTS_EU_05_Current_Sales__c);
                                prevSumMap.put('5',osalesData.ZTS_EU_05_Previous_Sales__c);
                                diffSumMap.put('5',osalesData.ZTS_EU_05_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('5') + osalesData.ZTS_EU_05_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('5') + osalesData.ZTS_EU_05_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('5') + osalesData.ZTS_EU_05_Diff_Sales__c;
                                currentSumMap.put('5', currVal);
                                prevSumMap.put('5', prevVal);
                                diffSumMap.put('5', diffVal);
                            }
                            if(!currentSumMap.containsKey('6') && !prevSumMap.containsKey('6') && !diffSumMap.containsKey('6')){
                                currentSumMap.put('6',osalesData.ZTS_EU_06_Current_Sales__c);
                                prevSumMap.put('6',osalesData.ZTS_EU_06_Previous_Sales__c);
                                diffSumMap.put('6',osalesData.ZTS_EU_06_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('6') + osalesData.ZTS_EU_06_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('6') + osalesData.ZTS_EU_06_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('6') + osalesData.ZTS_EU_06_Diff_Sales__c;
                                currentSumMap.put('6', currVal);
                                prevSumMap.put('6', prevVal);
                                diffSumMap.put('6', diffVal);
                            }
                            if(!currentSumMap.containsKey('7') && !prevSumMap.containsKey('7') && !diffSumMap.containsKey('7')){
                                currentSumMap.put('7',osalesData.ZTS_EU_07_Current_Sales__c);
                                prevSumMap.put('7',osalesData.ZTS_EU_07_Previous_Sales__c);
                                diffSumMap.put('7',osalesData.ZTS_EU_07_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('7') + osalesData.ZTS_EU_07_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('7') + osalesData.ZTS_EU_07_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('7') + osalesData.ZTS_EU_07_Diff_Sales__c;
                                currentSumMap.put('7', currVal);
                                prevSumMap.put('7', prevVal);
                                diffSumMap.put('7', diffVal);
                            }
                            if(!currentSumMap.containsKey('8') && !prevSumMap.containsKey('8') && !diffSumMap.containsKey('8')){
                                currentSumMap.put('8',osalesData.ZTS_EU_08_Current_Sales__c);
                                prevSumMap.put('8',osalesData.ZTS_EU_08_Previous_Sales__c);
                                diffSumMap.put('8',osalesData.ZTS_EU_08_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('8') + osalesData.ZTS_EU_08_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('8') + osalesData.ZTS_EU_08_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('8') + osalesData.ZTS_EU_08_Diff_Sales__c;
                                currentSumMap.put('8', currVal);
                                prevSumMap.put('8', prevVal);
                                diffSumMap.put('8', diffVal);
                            }
                            if(!currentSumMap.containsKey('9') && !prevSumMap.containsKey('9') && !diffSumMap.containsKey('9')){
                                currentSumMap.put('9',osalesData.ZTS_EU_09_Current_Sales__c);
                                prevSumMap.put('9',osalesData.ZTS_EU_09_Previous_Sales__c);
                                diffSumMap.put('9',osalesData.ZTS_EU_09_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('9') + osalesData.ZTS_EU_09_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('9') + osalesData.ZTS_EU_09_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('9') + osalesData.ZTS_EU_09_Diff_Sales__c;
                                currentSumMap.put('9', currVal);
                                prevSumMap.put('9', prevVal);
                                diffSumMap.put('9', diffVal);
                            }
                            if(!currentSumMap.containsKey('10') && !prevSumMap.containsKey('10') && !diffSumMap.containsKey('10')){
                                currentSumMap.put('10',osalesData.ZTS_EU_10_Current_Sales__c);
                                prevSumMap.put('10',osalesData.ZTS_EU_10_Previous_Sales__c);
                                diffSumMap.put('10',osalesData.ZTS_EU_10_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('10') + osalesData.ZTS_EU_10_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('10') + osalesData.ZTS_EU_10_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('10') + osalesData.ZTS_EU_10_Diff_Sales__c;
                                currentSumMap.put('10', currVal);
                                prevSumMap.put('10', prevVal);
                                diffSumMap.put('10', diffVal);
                            }
                            if(!currentSumMap.containsKey('11') && !prevSumMap.containsKey('11') && !diffSumMap.containsKey('11')){
                                currentSumMap.put('11',osalesData.ZTS_EU_11_Current_Sales__c);
                                prevSumMap.put('11',osalesData.ZTS_EU_11_Previous_Sales__c);
                                diffSumMap.put('11',osalesData.ZTS_EU_11_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('11') + osalesData.ZTS_EU_11_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('11') + osalesData.ZTS_EU_11_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('11') + osalesData.ZTS_EU_11_Diff_Sales__c;
                                currentSumMap.put('11', currVal);
                                prevSumMap.put('11', prevVal);
                                diffSumMap.put('11', diffVal);
                            }
                            if(!currentSumMap.containsKey('12') && !prevSumMap.containsKey('12') && !diffSumMap.containsKey('12')){
                                currentSumMap.put('12',osalesData.ZTS_EU_12_Current_Sales__c);
                                prevSumMap.put('12',osalesData.ZTS_EU_12_Previous_Sales__c);
                                diffSumMap.put('12',osalesData.ZTS_EU_12_Diff_Sales__c);
                            }else{
                                Decimal currVal = currentSumMap.get('12') + osalesData.ZTS_EU_12_Current_Sales__c;
                                Decimal prevVal = prevSumMap.get('12') + osalesData.ZTS_EU_12_Previous_Sales__c;
                                Decimal diffVal = diffSumMap.get('12') + osalesData.ZTS_EU_12_Diff_Sales__c;
                                currentSumMap.put('12', currVal);
                                prevSumMap.put('12', prevVal);
                                diffSumMap.put('12', diffVal);
                            }
                            List<Decimal> oaccntSalesData3 = new List<Decimal>{osalesData.ZTS_EU_01_Current_Sales__c,osalesData.ZTS_EU_01_Previous_Sales__c,osalesData.ZTS_EU_01_Diff_Sales__c};
                            List<Decimal> oaccntSalesData4 = new List<Decimal>{osalesData.ZTS_EU_02_Current_Sales__c,osalesData.ZTS_EU_02_Previous_Sales__c,osalesData.ZTS_EU_02_Diff_Sales__c};
                            List<Decimal> oaccntSalesData5 = new List<Decimal>{osalesData.ZTS_EU_03_Current_Sales__c,osalesData.ZTS_EU_03_Previous_Sales__c,osalesData.ZTS_EU_03_Diff_Sales__c};
                            List<Decimal> oaccntSalesData6 = new List<Decimal>{osalesData.ZTS_EU_04_Current_Sales__c,osalesData.ZTS_EU_04_Previous_Sales__c,osalesData.ZTS_EU_04_Diff_Sales__c};
                            List<Decimal> oaccntSalesData7 = new List<Decimal>{osalesData.ZTS_EU_05_Current_Sales__c,osalesData.ZTS_EU_05_Previous_Sales__c,osalesData.ZTS_EU_05_Diff_Sales__c};
                            List<Decimal> oaccntSalesData8 = new List<Decimal>{osalesData.ZTS_EU_06_Current_Sales__c,osalesData.ZTS_EU_06_Previous_Sales__c,osalesData.ZTS_EU_06_Diff_Sales__c};
                            List<Decimal> oaccntSalesData9 = new List<Decimal>{osalesData.ZTS_EU_07_Current_Sales__c,osalesData.ZTS_EU_07_Previous_Sales__c,osalesData.ZTS_EU_07_Diff_Sales__c};
                            List<Decimal> oaccntSalesData10 = new List<Decimal>{osalesData.ZTS_EU_08_Current_Sales__c,osalesData.ZTS_EU_08_Previous_Sales__c,osalesData.ZTS_EU_08_Diff_Sales__c};
                            List<Decimal> oaccntSalesData11 = new List<Decimal>{osalesData.ZTS_EU_09_Current_Sales__c,osalesData.ZTS_EU_09_Previous_Sales__c,osalesData.ZTS_EU_09_Diff_Sales__c};
                            List<Decimal> oaccntSalesData12 = new List<Decimal>{osalesData.ZTS_EU_10_Current_Sales__c,osalesData.ZTS_EU_10_Previous_Sales__c,osalesData.ZTS_EU_10_Diff_Sales__c};
                            List<Decimal> oaccntSalesData13 = new List<Decimal>{osalesData.ZTS_EU_11_Current_Sales__c,osalesData.ZTS_EU_11_Previous_Sales__c,osalesData.ZTS_EU_11_Diff_Sales__c};
                            List<Decimal> oaccntSalesData14 = new List<Decimal>{osalesData.ZTS_EU_12_Current_Sales__c,osalesData.ZTS_EU_12_Previous_Sales__c,osalesData.ZTS_EU_12_Diff_Sales__c};
                            
                            Map<String, List<Decimal>> monthNoValueMap = new Map<String, List<Decimal>>();
                            monthNoValueMap.put('1',oaccntSalesData3);monthNoValueMap.put('2',oaccntSalesData4);monthNoValueMap.put('3',oaccntSalesData5);
                            monthNoValueMap.put('4',oaccntSalesData6);monthNoValueMap.put('5',oaccntSalesData7);monthNoValueMap.put('6',oaccntSalesData8);
                            monthNoValueMap.put('7',oaccntSalesData9);monthNoValueMap.put('8',oaccntSalesData10);monthNoValueMap.put('9',oaccntSalesData11);
                            monthNoValueMap.put('10',oaccntSalesData12);monthNoValueMap.put('11',oaccntSalesData13);monthNoValueMap.put('12',oaccntSalesData14);
                            if(selectedMATYTD == 'YTD'){
                                listdataYTD = new List<dataYTD>();
                                
                                Integer j = 1;
                                dataYTD odataYTD;
                                monthList = new List<String>();                     
                                monthNameList = new List<String>();
                                Integer ytdStartCounter = tempMonthAPMap.get(1);
                                for(Integer i=ytdStartCounter-1; i> 0; i--){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                               List<Decimal> values = monthValueMap.get(colMnthName);
                                               values.addAll(colValues);
                                               monthValueMap.remove(colMnthName);
                                               monthValueMap.put(colMnthName,values);
                                    }else{
                                        monthValueMap.put(colMnthName,colValues);
                                    }
                                    
                                    monthNameList.add(monthNameMap.get(colMnthName));    
                                    monthList.add(colMnthName);
                                    listdataYTD.add(odataYTD);
                                }  
                               
                                if(ytdStartCounter < 12){
                                    for(Integer i=ytdStartCounter; i<= 12; i++){
                                        String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                        List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                        j = j + 1;
                                        odataYTD = new dataYTD(colMnthName,colValues);
                                        if(monthValueMap.containsKey(colMnthName)){
                                                   List<Decimal> values = monthValueMap.get(colMnthName);
                                                   values.addAll(colValues);
                                                   monthValueMap.remove(colMnthName);
                                                   monthValueMap.put(colMnthName,new List<Decimal>());
                                        }else{
                                            monthValueMap.put(colMnthName,new List<Decimal>());
                                        }
                                        
										monthNameList.add(monthNameMap.get(colMnthName));    
                                        monthList.add(colMnthName);
                                        listdataYTD.add(odataYTD);
                                    }
                                }
                                if(selectedDisplayType == 'Gregorian Calendar')
                                {
                                    monthStringValueMapGreg = new Map<String,List<String>>();
                                    Integer prodindex = 3*gregProdSalesIndex;
                                    GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getGregorianYTDProductSalesData(monthNameMap,monthValueMap,prodindex);
                                    oaccntSalesData2.clear();
                                    oaccntSalesData2 = gregwrappobj.oaccntSalesData2;
                                    monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                    monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                    monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                    gregProdSalesIndex = gregProdSalesIndex+1;
                                    for(String s: monthValueMapGreg.keySet())
                                    {
                                        monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                    }
                                }
                                for(String s: monthValueMap.keySet())
                                {
                                    monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                                }
                                
                               
                            }
                            oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1,new List<String>(convertDecimaltoString(oaccntSalesData2)),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('1')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('2')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('3')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('4')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('5')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('6')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('7')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('8')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('9')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('10')))),
                            new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('11')))),new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('12')))));
                              
                            listAccntSalesDataValue.add(oAccntSalesDV);
                             
                        }     
                        
                    }
                    if(selectedReport == 'TotalSales'){
                        List<String> listStr = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales,'%'+System.label.ZTS_EU_Diff_Sales};
                        Map<String, List<Decimal>> monthNoValueMap = new Map<String, List<Decimal>>();
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
                                oaccntSalesData2total.add(mapSalesDataTotal.get(oStr)[0]);
                                oaccntSalesData3total.add(mapSalesDataTotal.get(oStr)[1]);
                                oaccntSalesData4total.add(mapSalesDataTotal.get(oStr)[2]);
                                oaccntSalesData5total.add(mapSalesDataTotal.get(oStr)[3]);
                                oaccntSalesData6total.add(mapSalesDataTotal.get(oStr)[4]);
                                oaccntSalesData7total.add(mapSalesDataTotal.get(oStr)[5]);
                                oaccntSalesData8total.add(mapSalesDataTotal.get(oStr)[6]);
                                oaccntSalesData9total.add(mapSalesDataTotal.get(oStr)[7]);
                                oaccntSalesData10total.add(mapSalesDataTotal.get(oStr)[8]);
                                oaccntSalesData11total.add(mapSalesDataTotal.get(oStr)[9]);
                                oaccntSalesData12total.add(mapSalesDataTotal.get(oStr)[10]);
                                oaccntSalesData13total.add(mapSalesDataTotal.get(oStr)[11]);
                                oaccntSalesData14total.add(mapSalesDataTotal.get(oStr)[12]);
                                
                            }
                            monthNoValueMap.put('1',oaccntSalesData3total);monthNoValueMap.put('2',oaccntSalesData4total);monthNoValueMap.put('3',oaccntSalesData5total);
                            monthNoValueMap.put('4',oaccntSalesData6total);monthNoValueMap.put('5',oaccntSalesData7total);monthNoValueMap.put('6',oaccntSalesData8total);
                            monthNoValueMap.put('7',oaccntSalesData9total);monthNoValueMap.put('8',oaccntSalesData10total);monthNoValueMap.put('9',oaccntSalesData11total);
                            monthNoValueMap.put('10',oaccntSalesData12total);monthNoValueMap.put('11',oaccntSalesData13total);monthNoValueMap.put('12',oaccntSalesData14total);
                        if(selectedMATYTD == 'YTD')
                        {
                            listdataYTD = new List<dataYTD>();
                            //mapTotalSalesYTD = new Map<String,List<String>>();
                            //mapTotalSalesYTD.put('1a',oaccntSalesData1total);
                            //mapTotalSalesYTD.put('1b',oaccntSalesData2total);
                            Integer j = 1;
                            dataYTD odataYTD;                   
                            monthList = new List<String>(); 
                            monthNameList = new List<String>();
                            Integer ytdStartCounter = tempMonthAPMap.get(1);
                            for(Integer i=ytdStartCounter-1; i> 0; i--){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                        if(monthValueMap.containsKey(colMnthName)){
                                            List<Decimal> values = monthValueMap.get(colMnthName);
                                            values.addAll(colValues);
                                            monthValueMap.remove(colMnthName);
                                            monthValueMap.put(colMnthName,values);
                                        }
                                        else{
                                        monthValueMap.put(colMnthName,colValues);
                                        }
                                        monthNameList.add(monthNameMap.get(colMnthName));    
                                        monthList.add(colMnthName);
                                        listdataYTD.add(odataYTD);
                                }           
                            if(ytdStartCounter < 12){
                                for(Integer i=ytdStartCounter; i<= 12; i++){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<Decimal> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                        List<Decimal> values = monthValueMap.get(colMnthName);
                                        values.addAll(colValues);
                                        monthValueMap.remove(colMnthName);
                                        monthValueMap.put(colMnthName,new List<Decimal>());
                                    }
                                    else{
                                    monthValueMap.put(colMnthName,new List<Decimal>());
                                    }
                                    monthNameList.add(monthNameMap.get(colMnthName));    
                                    monthList.add(colMnthName);
                                    
                                    listdataYTD.add(odataYTD);
                                }
                            }
                            if(selectedDisplayType == 'Gregorian Calendar')
                            {
                                monthStringValueMapGreg = new Map<String,List<String>>();
                                GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getGregorianYTDTotalSalesData(monthNameMap,monthValueMap);
                                oaccntSalesData2total.clear();
                                oaccntSalesData2total = gregwrappobj.oaccntSalesData2total;
                                monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                //mapTotalSalesYTD.remove('1b');
                                //mapTotalSalesYTD.put('1b',oaccntSalesData2total);
                                for(String s: monthValueMapGreg.keySet())
                                {
                                    monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                }
                                
                            }
                            for(String s: monthValueMap.keySet())
                            {
                                monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                            }
                                
                        }
                        
                        oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1total,new List<String>(convertDecimaltoString(oaccntSalesData2total)),
                                                                 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('12')))),
                                                                 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('11')))),
                                                                 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('10')))),
                        										 new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('9')))),
                                                                                  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('8')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('7')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('6')))),
																			      new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('5')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('4')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('3')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('2')))),
																				  new List<String>(convertDecimaltoString(monthNoValueMap.get(monthNumberMap.get('1')))));         
                        
                        listAccntSalesDataValue.add(oAccntSalesDV);
                    }
                    if(selectedMATYTD == 'YTD'){
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue,listdataYTD);
                        if(selectedDisplayType != 'Gregorian Calendar')
                        	oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue, monthStringValueMap);
                        else
                            oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue, monthStringValueMapGreg);
                    }
                    else {
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue);
                    }
                    listCustomSettSalesData.add(oCustomSettSalesData);
                }
            }
            //The below part is for the total Previous and Current year sales for Product and Unit Sales
            if((listQuerySalesData != Null && listQuerySalesData.size()>0) || (listQuerySalesDataNetSales != null && listQuerySalesDataNetSales.size()> 0)){
                // my code here for total
                if(selectedReport == 'UnitSales'){//For Unit Sales
                    CustomSettSalesData oCustomSettSalesData;
                    CustomWrapBottomTableData obj = getunitsalesbottomDataTable(currentSumMap,prevSumMap);
                    listAccntSalesDataValue = obj.listAccntSalesDataValue;
                    Map<String, List<String>> monthStringValueMap = obj.monthValueMap;
                    monthStringValueMapGreg = obj.monthValueMapGreg;
                    if(selectedMATYTD == 'YTD'){
                    oCustomSettSalesData = new CustomSettSalesData('','', '', listAccntSalesDataValue, listdataYTD);
                    if(selectedDisplayType != 'Gregorian Calendar')
                        oCustomSettSalesData  = new CustomSettSalesData('','','',listAccntSalesDataValue, monthStringValueMap);
                    else
                        oCustomSettSalesData  = new CustomSettSalesData('','','',listAccntSalesDataValue, monthStringValueMapGreg);
                    }else{
                        oCustomSettSalesData = new CustomSettSalesData(null,null,null,listAccntSalesDataValue);
                    }
                    if(listCustomSettSalesData != null && listCustomSettSalesData.size() > 0)
                        listCustomSettSalesData.add(oCustomSettSalesData);
                    
                }//Unit Sales code Ends here
                
                if(selectedReport == 'ProductSales'){
                    CustomSettSalesData oCustomSettSalesData;
                    CustomWrapBottomTableData obj = getProdsalesbottomDataTable(currentSumMap,prevSumMap,diffSumMap);
                    listAccntSalesDataValue = obj.listAccntSalesDataValue;
                    Map<String, List<String>> monthStringValueMap = obj.monthValueMap;
                    monthStringValueMapGreg = obj.monthValueMapGreg;
                    if(selectedMATYTD == 'YTD'){
                    oCustomSettSalesData = new CustomSettSalesData('','', '', listAccntSalesDataValue, listdataYTD);
                    if(selectedDisplayType != 'Gregorian Calendar')
                        oCustomSettSalesData  = new CustomSettSalesData('','','',listAccntSalesDataValue, monthStringValueMap);
                    else
                        oCustomSettSalesData  = new CustomSettSalesData('','','',listAccntSalesDataValue, monthStringValueMapGreg);
                    }else{
                        oCustomSettSalesData = new CustomSettSalesData(null,null,null,listAccntSalesDataValue);
                    }
                    if(listCustomSettSalesData != null && listCustomSettSalesData.size() > 0)
                        listCustomSettSalesData.add(oCustomSettSalesData);
                    
                }//Product Sales ends here
            }
            
            return listCustomSettSalesData;
        }
        
        /***********
        * Method name : getcreateDataTable
        * Description : This method is responsible for populating the values in the table.
        * Return Type : List<CustomSettSalesData>.
        * Parameters : None.
        ***********/
        public void getcreateDataTable(){
            customSetList = new List<CustomSettSalesData>();
            if(monthNumberMap == null || monthNumberMap.size() == 0 || monthAPMap == null || monthAPMap.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.label.ZTS_EU_Error_Invalid_Date_for_Sales));
                return;
            }
            
            selectedAccnt = accntCurrent.Name;
            customSetList = getSalesData(); 
            
        }
        
        /***********
        * Method name : getunitsalesbottomDataTable
        * Description : This method is responsible for populating the bottom most table in unit sales which shows Total Current year and Prev year sales.
        * Return Type : List<CustomSettSalesData>.
        * Parameters : None.
        ***********/
		public CustomWrapBottomTableData getunitsalesbottomDataTable(Map<String, Decimal> currentSumMap,Map<String, Decimal> prevSumMap)
		{
					List<Decimal> allUnitAPTotal = new List<Decimal>();
                    List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Previous_Year};
                    CustomSettSalesData oCustomSettSalesData;
                    listdataYTD = new List<dataYTD>();
                    Map<String, List<Decimal>> monthValueMap = new Map<String, List<Decimal>>();
                    Map<String, List<String>> monthStringValueMap = new Map<String, List<String>>();
                    ActualSalesDataValue oAccntSalesDV = new ActualSalesDataValue(null,null,null,oaccntSalesData1,new List<String>{String.valueof(currentSumMap.get('total').format()),String.valueof(prevSumMap.get('total').format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('1')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('1')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('2')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('2')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('3')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('3')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('4')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('4')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('5')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('5')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('6')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('6')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('7')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('7')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('8')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('8')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('9')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('9')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('10')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('10')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('11')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('11')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('12')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('12')).format())});
                    List<ActualSalesDataValue> listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
                    
                    if(selectedMATYTD == 'YTD'){
                        Integer j = 1;
                        
                        Integer ytdStartCounter = tempMonthAPMap.get(1);
                        for(Integer i=ytdStartCounter-1; i> 0; i--){
                            String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                            //List<String> colValues = monthNoValueMap.get(String.Valueof(i));
                            List<Decimal> colValues = new List<Decimal>{currentSumMap.get(String.valueOf(i)),prevSumMap.get(String.valueOf(i))};
                            j = j + 1;
                            dataYTD odataYTD = new dataYTD(colMnthName,colValues);
                            if(odataYTD != null)
                                listdataYTD.add(odataYTD);
                            monthValueMap.put(colMnthName,colValues);
                        }           
                        if(ytdStartCounter < 12){
                            for(Integer i=ytdStartCounter; i<= 12; i++){
                                String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                j++;
                                List<Decimal> colValues = new List<Decimal>();
                                dataYTD odataYTD = new dataYTD(colMnthName,colValues);
                                listdataYTD.add(odataYTD);
                                monthValueMap.put(colMnthName,colValues);
                            }
                            
                        }
                         if(selectedDisplayType == 'Gregorian Calendar')
                            {
                                monthStringValueMapGreg = new Map<String,List<String>>();
                                GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getUnitTotSalesYTDGreg(monthNameMap,monthValueMap);
                                allUnitAPTotal = gregwrappobj.totUnitSales;
                                monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                listdataYTD.clear();
                                for(String cmname: monthValueMapGreg.keySet())
                                {
                                    dataYTD odataYTD = new dataYTD(cmname,monthValueMapGreg.get(cmname));
                                    listdataYTD.add(odataYTD);
                                }
                                for(String s: monthValueMapGreg.keySet())
                                {
                                  monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                }
                            }
                        else{
                            allUnitAPTotal = new List<Decimal>{currentSumMap.get('total'),prevSumMap.get('total')};
                            }
                        for(String s: monthValueMap.keySet())
                        {
                          monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                         }
                        
                    listAccntSalesDataValue.clear();
                    ActualSalesDataValue oAccntSalesDV1 = new ActualSalesDataValue(null,null,null,oaccntSalesData1,new List<String>(convertDecimaltoString(allUnitAPTotal)),
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('1')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('1')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('2')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('2')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('3')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('3')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('4')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('4')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('5')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('5')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('6')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('6')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('7')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('7')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('8')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('8')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('9')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('9')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('10')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('10')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('11')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('11')).format())}, 
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('12')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('12')).format())});
                    listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV1};
                        
			}
			return new CustomWrapBottomTableData(listAccntSalesDataValue,monthStringValueMap,monthStringValueMapGreg);
		}
        
        
		/***********
        * Method name : getProdsalesbottomDataTable
        * Description : This method is responsible for populating the bottom most table in unit sales which shows Total Current year and Prev year sales.
        * Return Type : List<CustomSettSalesData>.
        * Parameters : None.
        ***********/
		public CustomWrapBottomTableData getProdsalesbottomDataTable(Map<String, Decimal> currentSumMap,Map<String, Decimal> prevSumMap,Map<String, Decimal> diffSumMap)
		{
					List<Decimal> allUnitAPTotal = new List<Decimal>();
                    List<String> oaccntSalesData1 = new List<String>{System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Total + ' ' + System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Total + ' '+System.label.ZTS_EU_Diff_Sales};
                    CustomSettSalesData oCustomSettSalesData;
                    listdataYTD = new List<dataYTD>();
                    Map<String, List<Decimal>> monthValueMap = new Map<String, List<Decimal>>();
            		Map<String, List<String>> monthStringValueMap = new Map<String, List<String>>();
                    ActualSalesDataValue oAccntSalesDV = new ActualSalesDataValue(null,null,oaccntSalesData1,new List<String>{String.valueof(currentSumMap.get('total').format()),String.valueof(prevSumMap.get('total').format()),String.valueof(diffSumMap.get('total').format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('1')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('1')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('1')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('2')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('2')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('2')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('3')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('3')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('3')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('4')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('4')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('4')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('5')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('5')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('5')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('6')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('6')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('6')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('7')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('7')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('7')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('8')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('8')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('8')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('9')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('9')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('9')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('10')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('10')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('10')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('11')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('11')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('11')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('12')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('12')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('12')).format())});
                    List<ActualSalesDataValue> listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
                    
                    if(selectedMATYTD == 'YTD'){
                        Integer j = 1;
                        
                        Integer ytdStartCounter = tempMonthAPMap.get(1);
                        for(Integer i=ytdStartCounter-1; i> 0; i--){
                            String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                            //List<String> colValues = monthNoValueMap.get(String.Valueof(i));
                            List<Decimal> colValues = new List<Decimal>{currentSumMap.get(String.valueOf(i)),prevSumMap.get(String.valueOf(i)),diffSumMap.get(String.valueOf(i))};
                            j = j + 1;
                            dataYTD odataYTD = new dataYTD(colMnthName,colValues);
                            if(odataYTD != null)
                                listdataYTD.add(odataYTD);
                            monthValueMap.put(colMnthName,colValues);
                        }           
                        if(ytdStartCounter < 12){
                            for(Integer i=ytdStartCounter; i<= 12; i++){
                                String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                j++;
                                List<Decimal> colValues = new List<Decimal>();
                                dataYTD odataYTD = new dataYTD(colMnthName,colValues);
                                listdataYTD.add(odataYTD);
                                monthValueMap.put(colMnthName,colValues);
                            }
                            
                        }
                         if(selectedDisplayType == 'Gregorian Calendar')
                            {
                                monthStringValueMapGreg = new Map<String,List<String>>();
                                GregSalesWrapper gregwrappobj = ZTS_EU_SalesDataReportingHelper.getProdTotSalesYTDGreg(monthNameMap,monthValueMap);
                                allUnitAPTotal = gregwrappobj.totUnitSales;
                                monthValueMapGreg = gregwrappobj.monthValueMapGreg;
                                monthNameListYTDGreg = gregwrappobj.monthNameListYTDGreg;
                                monthListYTDGreg = gregwrappobj.monthListYTDGreg;
                                listdataYTD.clear();
                                for(String cmname: monthValueMapGreg.keySet())
                                {
                                    dataYTD odataYTD = new dataYTD(cmname,monthValueMapGreg.get(cmname));
                                    listdataYTD.add(odataYTD);
                                }
                                for(String s: monthValueMapGreg.keySet())
                                {
                                  monthStringValueMapGreg.put(s, new List<String>(convertDecimaltoString(monthValueMapGreg.get(s))));
                                }
                            }
                        else{
                            allUnitAPTotal = new List<Decimal>{currentSumMap.get('total'),prevSumMap.get('total'),diffSumMap.get('total')};
                            }
                         for(String s: monthValueMap.keySet())
                        {
                          monthStringValueMap.put(s, new List<String>(convertDecimaltoString(monthValueMap.get(s))));
                         }
                        
                    listAccntSalesDataValue.clear();
                    ActualSalesDataValue oAccntSalesDV1 = new ActualSalesDataValue(null,null,oaccntSalesData1,new List<String>(convertDecimaltoString(allUnitAPTotal)),
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('1')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('1')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('1')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('2')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('2')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('2')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('3')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('3')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('3')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('4')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('4')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('4')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('5')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('5')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('5')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('6')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('6')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('6')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('7')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('7')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('7')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('8')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('8')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('8')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('9')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('9')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('9')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('10')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('10')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('10')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('11')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('11')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('11')).format())},
                    new List<String>{String.valueof(currentSumMap.get(monthNumberMap.get('12')).format()),String.valueof(prevSumMap.get(monthNumberMap.get('12')).format()),String.valueof(diffSumMap.get(monthNumberMap.get('12')).format())});
                    listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV1};
			}
			return new CustomWrapBottomTableData(listAccntSalesDataValue,monthStringValueMap,monthStringValueMapGreg);
		}
        
		/***********
        * Method name : convertDecimaltoString
        * Description : This method is responsible for converting the list of decimal values to list of string
        * Return Type : List<String>.
        * Parameters : List<Decimal>.
        ***********/
        public List<String> convertDecimaltoString(List<Decimal> listDecimal)
        {
            List<String> listString = new List<String>();
            if(listDecimal.size()==4)
            {
                for (Integer i=0;i<4;i++)
                {
                    if(i!=3){listString.add(String.valueof(listDecimal[i].format()));}
                    if(i==3){listString.add(String.valueof(listDecimal[i].format())+'%');}
                    
                }
            }
            else{
                for(Decimal d: listDecimal) {
              		listString.add(String.valueof(d.format()));  
                }
            }
            return listString;
        }
        
        /***********
        * Method name : CustomWrapBottomTableData
        * Description : This is wrapper class.
        * Return Type : None.
        * Parameters : None.
        ***********/
        public class CustomWrapBottomTableData{      
           Public List<ActualSalesDataValue> listAccntSalesDataValue{get;set;}       
           Public Map<String, List<String>> monthValueMap {get;set;}
           Public Map<String, List<String>> monthValueMapGreg {get;set;} 
           
           public CustomWrapBottomTableData(List<ActualSalesDataValue> listAccntSalesDataValue, Map<String, List<String>> monthValueMap, Map<String, List<String>> monthValueMapGreg){
               this.listAccntSalesDataValue = listAccntSalesDataValue;
               this.monthValueMap= monthValueMap; 
               this.monthValueMapGreg= monthValueMapGreg;
              
           }
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
            
            //For Total Sales
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
            //For Product Sales
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
			//For Unit Sales
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
        * Method name : dataYTD
        * Description : This is wrapper class for YTD.
        * Return Type : None.
        * Parameters : None.
        ***********/
        public class dataYTD{
           Public String colMnthName{get;set;}
           Public List<Decimal> colValues{get;set;}     
           public dataYTD(String colMnthName, List<Decimal> colValues){
               this.colMnthName = colMnthName;
               this.colValues= colValues;
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
        * Method name : generateUnitSalesPdf
        * Description : This method is called for pdf functionality on UnitSales Tab.
        * Return Type : pagereference.
        * Parameters : None.
        ***********/
        public PageReference generateUnitSalesPdf(){
            PageReference  pg=new PageReference('/apex/ZTS_EU_UnitSalesPdf');
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
            PageReference pg=new PageReference('/apex/ZTS_EU_UnitSalesExcelDownload');
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
            PageReference  pg=new PageReference('/apex/ZTS_EU_ProductSalesPdf');
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
            PageReference pg=new PageReference('/apex/ZTS_EU_ProductSalesExcelDownload');
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
            PageReference  pg=new PageReference('/apex/ZTS_EU_TotalSalesPdf');
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
            PageReference pg=new PageReference('/apex/ZTS_EU_TotalSalesExcelDownload');
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
            
            if(selectedPreset != '--None--'){
                displayErrPopup = false;
                if(salesPresetAction == 'New'){
                    salesPresets = new ZTS_EU_Sales_Presets__c();
                   
                }
                if(salesPresetAction == 'Delete' || salesPresetAction == 'Edit'){
                    salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Business_Unit__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                    if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c != Null){
                        selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                        if(selectedMultiTherapeuticGrp != Null && selectedMultiTherapeuticGrp.size()>0)
                            selectedMultiTherapeuticGrpOpt = listSelOptPopulate(selectedMultiTherapeuticGrp);
                       
                    }
                    
                    if(salesPresets.ZTS_EU_Selected_Preferred_Brands__c != Null)
                        selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                    if(salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c != Null)
                        selectedMultiSpecies = salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c.split(';');
                    
                    if(selectedMultiProduct != Null && selectedMultiProduct.size()>0)
                        selectedMultiProductOpt = listSelOptPopulate(selectedMultiProduct);
                    if(selectedMultiSpecies != Null && selectedMultiSpecies.size()>0)
                        selectedMultiSpeciesOpt = listSelOptPopulate(selectedMultiSpecies);
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
                if(selectedMultiTherapeuticGrp!=null)
                newSalesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = multiSelectPopulate(selectedMultiTherapeuticGrp);
                if(selectedMultiProduct!=null)
                newSalesPresets.ZTS_EU_Selected_Preferred_Brands__c = multiSelectPopulate(selectedMultiProduct);
                if(selectedMultiBusinessUnits!=null)
                newSalesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c = multiSelectPopulate(selectedMultiBusinessUnits);
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
                if(selectedMultiTherapeuticGrp!=null)
                salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c = multiSelectPopulate(selectedMultiTherapeuticGrp);
                if(selectedMultiProduct!=null)
                salesPresets.ZTS_EU_Selected_Preferred_Brands__c = multiSelectPopulate(selectedMultiProduct);
                if(selectedMultiBusinessUnits!=null)
                salesPresets.ZTS_EU_Selected_Preferred_Business_Unit__c = multiSelectPopulate(selectedMultiBusinessUnits);
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
                listStrVal.add(so.getValue());            
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
        * Method name : queryAccData
        * Description : This method is called for toggling parent and child account on clicking the link.
        * Return Type : PageReference.
        * Parameters : None.
        ***********/
           public PageReference queryAccData() {
                //build the full sort expression
               
                if(!isChildSelected && (monthNumberMap == null || monthNumberMap.size() <= 0)){
                    accntParent = [Select Id, Name,ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c, (select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null),
                                   (select id, ZTS_EU_Date__c, CurrencyIsoCode from Net_Sales__r where ZTS_EU_Date__c <> null) 
                                    from Account where Id =: accntParent.Id AND ZTS_EU_Market__c != 'United States']; //IP 26-Feb-15 Added Net Sales
                    generateMonthMapping(accntParent);
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
                        List<Account> listParentAcc = [select Id, Name,ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c != 'United States' limit 1];
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
                       
                        List<Account> listParentAcc = [select Id, Name,ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c != 'United States' limit 1];
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
        * Method name  : redirect
        * Description  : This method is used to redirect to the US version of Sales Call
        * Return Type  : PageReference.
        * Parameters   : None
    ***********/
     public PageReference redirect(Id accountId)
     {
        //US Call not returned in query above
            PageReference pageRef = new PageReference('/apex/ZTS_US_salesDataReportingController?Id=' + accountId);
            pageRef.setRedirect(true);
            return pageRef;
     } 
    }