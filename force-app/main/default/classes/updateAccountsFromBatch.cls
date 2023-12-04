/*
    @@ Puropose: (Scheduled batch class) Update all Existing accounts of France with Gross sales values from current year and Previous year 
    @@ Author: Sohil Shah(Cloud Sense) 
    @@ Reference: DEF-001051
    
    Modification LOG:
    
    Date             Author Name            DEFECT NO                    Description
    -------------------------------------------------------------------------------------------------------
   
*/
public class updateAccountsFromBatch
{   
        public List<Account> listAccnt = new List<Account>();
        public Date apStartDate;
        public String currencyISO;  
        public String currencyType ;
        public Account accntCurrent;
        public Account accntActual ;
        public Account accnPrevious;
        public Account accntParent ;
        public Account accntChild  ;
        public boolean myflag;
        public Id accntIdQuery;
        public List<Account> listChildAccnt;
        public boolean parentAccntNotAvailable;
        public boolean isChild ;
        public Map<Integer, String> monthAPMap;
        public List<String> monthAPList;
        public Map<String, String> monthNumberMap;
        public List<CustomSettSalesData> customSetList;
        public String selectedAccnt;
        public Map<String,List<String>> monthVsValuesMap;
        public Map<Integer, Integer> tempMonthAPMap;
        public String soqlQuery;
        public String selectedSalesType ;
        public String selectedMATYTD = 'MAT';
        public String selectedReport = 'TotalSales';
        //public List<dataYTD> listdataYTD ;
        public Map<String,List<String>> mapTotalSalesYTD ;
        public List<String> monthList;
        public boolean noParent ;
        public String selectedLevelValue;
        public String queryAccName;                                 
        public String queryAccID  ;  
        public Boolean isChildSelected;
        public Integer counter = 0;
        public boolean toggleFlagParent;
        Map<String,Account> mapParentToChildValues = new Map<String, Account>();
        public updateAccountsFromBatch(List<Account> acclst)
        {
             listAccnt = [Select Id, Name,ParentId, ZTS_EU_Market__c,Parent.Name, ZTS_EU_Loyalty_Flag__c,Current_Year_Grand_Total__c,Previous_Year_Grand_Total__c,AP_11_CY_TS__c,AP_11_PY_TS__c,AP_12_CY_TS__c,AP_12_PY_TS__c,AP_10_CY_TS__c,AP_10_PY_TS__c,AP_09_CY_TS__c,AP_09_PY_TS__c,AP_08_PY_TS__c,AP_08_CY_TS__c,AP_07_PY_TS__c,AP_07_CY_TS__c,AP_06_CY_TS__c,AP_06_PY_TS__c,AP_05_PY_TS__c,AP_05_CY_TS__c,AP_04_PY_TS__c,AP_04_CY_TS__c,AP_03_CY_TS__c,AP_03_PY_TS__c,AP_02_PY_TS__c,AP_02_CY_TS__c,AP_01_CY_TS__c,AP_01_PY_TS__c,  (select id, ZTS_EU_Date__c, CurrencyIsoCode from Sales__r where ZTS_EU_Date__c <> null),
                                       (select id, ZTS_EU_Date__c, CurrencyIsoCode from Net_Sales__r where ZTS_EU_Date__c <> null)
                                        from Account where Id =: acclst[0].id AND ZTS_EU_Market__c != 'United States']; //IP 26-Feb-15 Added Net Sales
            system.debug('--------------------listAccnt: ' + listAccnt);
            apStartDate = system.today();
             currencyISO ='';
             selectedLevelValue = 'Branch';
             noParent = false;  
             accntCurrent = new Account();  
             accntActual  = new Account();   
             accnPrevious = new Account();
             accntParent  = new Account();          
             accntChild   = new Account();
             myflag = false;                        
             parentAccntNotAvailable =  false;          
             monthAPMap = new Map<Integer, String>();
             monthAPList =  new List<String>();
             monthNumberMap = new Map<String, String>();
             monthVsValuesMap = new Map<String,List<String>>();
            if(listAccnt != Null && listAccnt.size()>0){ 
                generateMonthMapping(listAccnt[0]);             
                if(monthNumberMap == null || monthNumberMap.size() == 0 || monthAPMap == null || monthAPMap.size() == 0){
                    myflag = true;                      
                }
                accntCurrent = listAccnt[0];
                accntActual = listAccnt[0];
                accnPrevious = null;                                     
                List<Account> listParentAcc = [select Id, Name, ParentId,ZTS_EU_Market__c, Parent.Name, ZTS_EU_Loyalty_Flag__c,Current_Year_Grand_Total__c,Previous_Year_Grand_Total__c,AP_11_CY_TS__c,AP_11_PY_TS__c,AP_12_CY_TS__c,AP_12_PY_TS__c,AP_10_CY_TS__c,AP_10_PY_TS__c,AP_09_CY_TS__c,AP_09_PY_TS__c,AP_08_PY_TS__c,AP_08_CY_TS__c,AP_07_PY_TS__c,AP_07_CY_TS__c,AP_06_CY_TS__c,AP_06_PY_TS__c,AP_05_PY_TS__c,AP_05_CY_TS__c,AP_04_PY_TS__c,AP_04_CY_TS__c,AP_03_CY_TS__c,AP_03_PY_TS__c,AP_02_PY_TS__c,AP_02_CY_TS__c,AP_01_CY_TS__c,AP_01_PY_TS__c from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c != 'United States' limit 1];
                if(listParentAcc != null && listParentAcc.size() > 0){
                    accntParent = listParentAcc[0];
                    
                }else{
                    accntParent = null;
                    noParent = true;
                }              
                accntChild = null;              
            }
            calculateLevelValues(listAccnt[0]); 
            selectedSalesType = 'Gross';    
            if(accntCurrent.ParentId == NULL){
                parentAccntNotAvailable = true;
            }
            accntIdQuery = accntCurrent.Id;
            listChildAccnt = [Select Id, Name, ParentId, Parent.Name, ZTS_EU_Loyalty_Flag__c,Current_Year_Grand_Total__c,Previous_Year_Grand_Total__c,AP_11_CY_TS__c,AP_11_PY_TS__c,AP_12_CY_TS__c,AP_12_PY_TS__c,AP_10_CY_TS__c,AP_10_PY_TS__c,AP_09_CY_TS__c,AP_09_PY_TS__c,AP_08_PY_TS__c,AP_08_CY_TS__c,AP_07_PY_TS__c,AP_07_CY_TS__c,AP_06_CY_TS__c,AP_06_PY_TS__c,AP_05_PY_TS__c,AP_05_CY_TS__c,AP_04_PY_TS__c,AP_04_CY_TS__c,AP_03_CY_TS__c,AP_03_PY_TS__c,AP_02_PY_TS__c,AP_02_CY_TS__c,AP_01_CY_TS__c,AP_01_PY_TS__c from Account where (ParentId =: accntIdQuery OR Id =: accntIdQuery) AND ZTS_EU_Market__c != 'United States'];
            System.debug('noParent---'+noParent);
            System.debug('isChild---'+isChild);
            
            
            getcreateDataTable();
           getData();
        }
        
        
        
        /*********
        * Method Name   : getData
        * Description   : This method will generate period wise values of Total sales for Current and previous year
        * Return Type   : void
        * Parameters    : None
        *********/
         
         public void getData()
        {                        
           if(myflag == false)
            {
                List<Account> listAccntToUpdate = new List<Account>();
                 System.debug('monthVsValuesMap--------'+monthVsValuesMap);
                 System.debug('monthVsValuesMap-Size-------'+monthVsValuesMap.Size());                           
                for(Account acc: listAccnt)
                {
                    
                    if(monthVsValuesMap.size() > 0)
                    {
                        acc.AP_12_CY_TS__c = monthVsValuesMap.get('AP-12')[0];
                        acc.AP_12_PY_TS__c = monthVsValuesMap.get('AP-12')[1];
                        
                        acc.AP_11_CY_TS__c = monthVsValuesMap.get('AP-11')[0];
                        acc.AP_11_PY_TS__c = monthVsValuesMap.get('AP-11')[1];
                        
                        acc.AP_10_PY_TS__c = monthVsValuesMap.get('AP-10')[1];
                        acc.AP_10_CY_TS__c = monthVsValuesMap.get('AP-10')[0];
                        
                        acc.AP_09_PY_TS__c = monthVsValuesMap.get('AP-9')[1];
                        acc.AP_09_CY_TS__c = monthVsValuesMap.get('AP-9')[0];
                        
                        acc.AP_08_PY_TS__c = monthVsValuesMap.get('AP-8')[1];
                        acc.AP_08_CY_TS__c = monthVsValuesMap.get('AP-8')[0];
                        
                        acc.AP_07_PY_TS__c = monthVsValuesMap.get('AP-7')[1];
                        acc.AP_07_CY_TS__c = monthVsValuesMap.get('AP-7')[0];
                        
                        acc.AP_06_PY_TS__c = monthVsValuesMap.get('AP-6')[1];
                        acc.AP_06_CY_TS__c = monthVsValuesMap.get('AP-6')[0];
                        
                        acc.AP_05_PY_TS__c = monthVsValuesMap.get('AP-5')[1];
                        acc.AP_05_CY_TS__c = monthVsValuesMap.get('AP-5')[0];
                        
                        acc.AP_04_PY_TS__c = monthVsValuesMap.get('AP-4')[1];
                        acc.AP_04_CY_TS__c = monthVsValuesMap.get('AP-4')[0];
                        
                        acc.AP_03_PY_TS__c = monthVsValuesMap.get('AP-3')[1];
                        acc.AP_03_CY_TS__c = monthVsValuesMap.get('AP-3')[0];
                        
                        acc.AP_02_PY_TS__c = monthVsValuesMap.get('AP-2')[1];
                        acc.AP_02_CY_TS__c = monthVsValuesMap.get('AP-2')[0];
                        
                        acc.AP_01_PY_TS__c = monthVsValuesMap.get('AP-1')[1];
                        acc.AP_01_CY_TS__c = monthVsValuesMap.get('AP-1')[0];
                        acc.Current_Year_Grand_Total__c = monthVsValuesMap.get('GT')[0];
                        acc.Previous_Year_Grand_Total__c = monthVsValuesMap.get('GT')[1];
                        listAccntToUpdate.add(acc);
                    }                                                 
                    
                }
                if(listAccntToUpdate.size()>0)
                {
                    //Bypass the Account Trigger when updating Accounts (TPDEV-80)
                    DispatchTriggerHandler.bypass('AccountTriggerHandler');
                    Database.update(listAccntToUpdate,false);
                    DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
                }
                
            }
            
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
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.label.ZTS_EU_Error_Invalid_Date_for_Sales));
                return;
            }
            selectedAccnt = accntCurrent.Name;
            customSetList = getSalesData();            
        }
        
        /*********
        * Method Name   : generateMonthMapping
        * Description   : This method will generate the map to be used to identify 
        * Return Type   : void
        * Parameters    : None
        *********/

        void generateMonthMapping(Account account){
            Integer startCounter = 0;
            Integer mapCounter = 1;
            tempMonthAPMap = new Map<Integer, Integer>();

            if(account.Sales__r != null && account.Sales__r.size() > 0){
                apStartDate = account.Sales__r[0].ZTS_EU_Date__c;
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
            }else{
            apStartDate = null;
            }   
        }
      /* Method name : calculateLevelValues
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
            Map<Id, String> mapAccntIdAccntName =  new Map<Id, String>();
            Map<Id, String> mapAccntIdNarcId =  new Map<Id, String>();
            String queryAccID = listAccnt[0].id;
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
            prodLevel = new List<String>();
            prodLevel.add('Account');
            soqlQuery+= ' and (ZTS_EU_Aggregated__c = false OR ZTS_EU_Aggregated__c = true)  AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
                
             if(!soqlQuery.contains('prodLevel')){
                //NC Fix bug - checking all sales data with empty product
                    soqlQuery+='AND ZTS_EU_Product__c = \'\' ';
                }   
                
            if(selectedSalesType == 'Gross'){
                soqlQuery += ' AND ZTS_EU_IsDataFromBatchJob__c = false ';
            }   
            //string sortFullExp = sortExpression  + ' ' + sortDirection;
           // soqlQuery+= 'ORDER BY '+sortFullExp; 
            List<ZTS_EU_Sales__c> listQuerySalesData ;
           
            system.debug('=======================soql formed: '+ soqlQuery+'\n'+ prodLevel);
            
            if(selectedSalesType == 'Gross'){
                listQuerySalesData = Database.query(soqlQuery);
                system.debug('soqlQuery: ' + soqlQuery);
                for(ZTS_EU_Sales__c listSalesData : listQuerySalesData){
                    if(mapAccntIdlistSalesData.containsKey(listSalesData.ZTS_EU_Account__c)){
                        mapAccntIdlistSalesData.get(listSalesData.ZTS_EU_Account__c).add(listSalesData);
                    }
                    else{
                        mapAccntIdlistSalesData.put(listSalesData.ZTS_EU_Account__c,new List<ZTS_EU_Sales__c>{listSalesData});
                    }
                } 
                system.debug('mapAccntIdlistSalesData:- ' + mapAccntIdlistSalesData);
                system.debug('mapAccntIdlistSalesData.size():- ' + mapAccntIdlistSalesData.size());
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
                    for(ZTS_EU_Sales__c osalesData : mapAccntIdlistSalesData.get(oaccntId)){                                            
                        //if TotalSales tab is selected
                         if(selectedReport == 'TotalSales'){                
                            // new code added
                            List<Double> listIntCurrent = mapSalesDataTotal.get(System.label.ZTS_EU_Current_Year);
                            List<Double> listIntPrior = mapSalesDataTotal.get(System.label.ZTS_EU_Previous_Year);
                            List<Double> listIntDollDiff = mapSalesDataTotal.get(System.label.ZTS_EU_Diff_Sales);
                            List<Double> listIntPerDiff = mapSalesDataTotal.get('%'+System.label.ZTS_EU_Diff_Sales);
                            Double intCurrent = osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                            Double intPrior = osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                            Double intDollDiff = osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                            Double intPerDiff = osalesData.ZTS_EU_Total_MAT_P_Diff_Sales__c;
                            /*if(selectedMATYTD == 'YTD'){
                                intCurrent = osalesData.ZTS_EU_Total_CYTD_Sales__c;
                                intPrior = osalesData.ZTS_EU_Total_PYTD_Sales__c;
                                intDollDiff = osalesData.ZTS_EU_Total_YTD_Diff_Sales__c;
                                intPerDiff = osalesData.ZTS_EU_Total_YTD_P_Diff_Sales__c;
                            }*/
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
                            /*if(listIntDollDiff == null){
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
                            mapSalesDataTotal.put('%'+System.label.ZTS_EU_Diff_Sales,listIntPerDiff);*/
                        }
                     
                        
                    
                    if(selectedReport == 'TotalSales'){
                        //List<String> listStr = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year,System.label.ZTS_EU_Diff_Sales,'%'+System.label.ZTS_EU_Diff_Sales};
                        List<String> listStr = new List<String>{System.label.ZTS_EU_Current_Year,System.label.ZTS_EU_Previous_Year};
                        Map<String, List<String>> monthNoValueMap = new Map<String, List<String>>();
                        for(String oStr : listStr){
                                String preStrAppend = '' + currencyISO;
                                String postStrAppend = '';
                                oaccntSalesData1total.add(oStr);
                                if(oStr == '%'+System.label.ZTS_EU_Diff_Sales){
                                    postStrAppend = '%';
                                    preStrAppend = '';
                                }
                                oaccntSalesData2total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[0].format())+postStrAppend);
                                oaccntSalesData3total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[1].format())+postStrAppend);
                                oaccntSalesData4total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[2].format())+postStrAppend);
                                oaccntSalesData5total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[3].format())+postStrAppend);
                                oaccntSalesData6total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[4].format())+postStrAppend);
                                oaccntSalesData7total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[5].format())+postStrAppend);
                                oaccntSalesData8total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[6].format())+postStrAppend);
                                oaccntSalesData9total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[7].format())+postStrAppend);
                                oaccntSalesData10total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[8].format())+postStrAppend);
                                oaccntSalesData11total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[9].format())+postStrAppend);
                                oaccntSalesData12total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[10].format())+postStrAppend);
                                oaccntSalesData13total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[11].format())+postStrAppend);
                                oaccntSalesData14total.add(preStrAppend+String.valueOf(mapSalesDataTotal.get(oStr)[12].format())+postStrAppend);
                                
                                
                            }
                            monthNoValueMap.put('1',oaccntSalesData3total);monthNoValueMap.put('2',oaccntSalesData4total);monthNoValueMap.put('3',oaccntSalesData5total);
                            monthNoValueMap.put('4',oaccntSalesData6total);monthNoValueMap.put('5',oaccntSalesData7total);monthNoValueMap.put('6',oaccntSalesData8total);
                            monthNoValueMap.put('7',oaccntSalesData9total);monthNoValueMap.put('8',oaccntSalesData10total);monthNoValueMap.put('9',oaccntSalesData11total);
                            monthNoValueMap.put('10',oaccntSalesData12total);monthNoValueMap.put('11',oaccntSalesData13total);monthNoValueMap.put('12',oaccntSalesData14total);
                     
                            
                            Integer s = 12;                                                         
                                for(String str: monthAPList)
                                {                                   
                                    monthVsValuesMap.put(str,monthNoValueMap.get(String.ValueOf(s)));                                   
                                    s--;                                    
                                }
                                monthVsValuesMap.put('GT',oaccntSalesData2total);
                            System.debug('monthVsValuesMap--------'+monthVsValuesMap);
                            System.debug('monthVsValuesMap-Size-------'+monthVsValuesMap.Size());
                            
                            
                       /* if(selectedMATYTD == 'YTD'){
                            listdataYTD = new List<dataYTD>();
                            mapTotalSalesYTD = new Map<String,List<String>>();
                            mapTotalSalesYTD.put('1a',oaccntSalesData1total);
                            mapTotalSalesYTD.put('1b',oaccntSalesData2total);                                                        
                            
                            Integer j = 1;
                            dataYTD odataYTD;                   
                            monthList = new List<String>();                 
                            
                            Integer ytdStartCounter = tempMonthAPMap.get(1);
                            for(Integer i=ytdStartCounter-1; i> 0; i--){
                                String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                List<String> colValues = monthNoValueMap.get(String.Valueof(i));
                                j = j + 1;
                                odataYTD = new dataYTD(colMnthName,colValues);
                                if(monthValueMap.containsKey(colMnthName)){
                                           List<String> values = monthValueMap.get(colMnthName);
                                           values.addAll(colValues);
                                           monthValueMap.remove(colMnthName);
                                           monthValueMap.put(colMnthName,values);
                                }else{
                                    monthValueMap.put(colMnthName,colValues);
                                }
                                monthList.add(colMnthName);
                                listdataYTD.add(odataYTD);
                            }           
                            if(ytdStartCounter < 12){
                                for(Integer i=ytdStartCounter; i<= 12; i++){
                                    String colMnthName = monthAPMap.get(tempMonthAPMap.get(j));
                                    List<String> colValues = monthNoValueMap.get(String.Valueof(i));
                                    j = j + 1;
                                    odataYTD = new dataYTD(colMnthName,colValues);
                                    if(monthValueMap.containsKey(colMnthName)){
                                               List<String> values = monthValueMap.get(colMnthName);
                                               values.addAll(colValues);
                                               monthValueMap.remove(colMnthName);
                                               monthValueMap.put(colMnthName,new List<String>());
                                    }else{
                                        monthValueMap.put(colMnthName,new List<String>());
                                    }
                                    monthList.add(colMnthName);
                                    listdataYTD.add(odataYTD);
                                }
                            }
                        }*/
                        
                        system.debug('----------------monthNumberMap.get12: ' + monthNumberMap.get('12')+'\n'+monthNoValueMap.get(monthNumberMap.get('12')));
                        oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1total,oaccntSalesData2total,monthNoValueMap.get(monthNumberMap.get('12')),monthNoValueMap.get(monthNumberMap.get('11')),monthNoValueMap.get(monthNumberMap.get('10')),
                        monthNoValueMap.get(monthNumberMap.get('9')),monthNoValueMap.get(monthNumberMap.get('8')),monthNoValueMap.get(monthNumberMap.get('7')),monthNoValueMap.get(monthNumberMap.get('6')),monthNoValueMap.get(monthNumberMap.get('5')),monthNoValueMap.get(monthNumberMap.get('4')),
                        monthNoValueMap.get(monthNumberMap.get('3')),monthNoValueMap.get(monthNumberMap.get('2')),monthNoValueMap.get(monthNumberMap.get('1')));
                        system.debug('-0---------------------oAccntSalesDV: ' + oAccntSalesDV);
                        listAccntSalesDataValue.add(oAccntSalesDV);
                    }
                   /* if(selectedMATYTD == 'YTD'){
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue,listdataYTD);
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue, monthValueMap);
                    }*/
                   // else {
                        oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue);
                   // }
                    listCustomSettSalesData.add(oCustomSettSalesData);
                    system.debug('-----------------listCustomSettSalesData: ' + listCustomSettSalesData);
                }
                }
            }           
            system.debug('-------------listCustomSettSalesData before return : '+ listCustomSettSalesData);
            return listCustomSettSalesData;
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
            soqlQuery += 'ZTS_EU_Account__c IN: accntIds ';
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
           
           //Public List<dataYTD> listYTDData {get;set;}
           //public Map<String, List<String>> monthValueMap {get;set;}
           
         /*  public CustomSettSalesData(String narcId, String accntId, String accntName, List<ActualSalesDataValue> salesDataWrapp, List<dataYTD> listYTDData){
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
           }*/
        }
        // for YTD
        /***********
        * Method name : dataYTD
        * Description : This is wrapper class for YTD.
        * Return Type : None.
        * Parameters : None.
        ***********/
       /* public class dataYTD{
           Public String colMnthName{get;set;}
           Public List<String> colValues{get;set;}     
           public dataYTD(String colMnthName, List<String> colValues){
               this.colMnthName = colMnthName;
               this.colValues= colValues;
           }
        }*/
          /***********
        * Method name : ActualSalesDataValue
        * Description : This is wrapper class.
        * Return Type : None.
        * Parameters : None.
        ***********/
        public class ActualSalesDataValue{
          
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
            
        

     
        }   
    }