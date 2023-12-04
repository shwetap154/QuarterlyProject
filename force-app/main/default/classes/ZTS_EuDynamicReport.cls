//Author : Pankaj Mishra
    public class ZTS_EuDynamicReport{
          
        public list<report> utList         =     new list<report>();
        public string rURL = URL.getSalesforceBaseUrl().toExternalForm();
        public string reportName        {get;set;}
        public boolean error            {get;set;}
        public string businessUnit      {get;set;}
        public String businessUnitMS    {get;set;}
        public string filterValue       {get;set;}
        public boolean renderRating     {get;set;}
        public Boolean isBrand          {get;set;}
        public String selectedProduct   {get;set;}
        public string currencyOfSales   {set;get;}
        public string reportSecName     {set;get;}
        public String reportURL         {get;set;}
        public Boolean isStdReport      {get;set;}
        public ID rId; 
        public List<MonthlySegmentWrapper> listMonthlySegment   {get;set;}
        public List<SelectOption> listProductNames  {get;set;}
        public Map<String,String> reportBusinessUnits = new Map<String,String>();
        public String userMarket;
        // map that stores field name of current sales along with month		
        public Map<Integer,String> mapOfCurrentSales = new Map<Integer,String>{1=>'ZTS_EU_01_Current_Sales__c',
        																	  2=>'ZTS_EU_02_Current_Sales__c',
        																	  3=>'ZTS_EU_03_Current_Sales__c',
        																	  4=>'ZTS_EU_04_Current_Sales__c',
        																	  5=>'ZTS_EU_05_Current_Sales__c',
        																	  6=>'ZTS_EU_06_Current_Sales__c',
        																	  7=>'ZTS_EU_07_Current_Sales__c',
        																	  8=>'ZTS_EU_08_Current_Sales__c',
        																	  9=>'ZTS_EU_09_Current_Sales__c',
        																	  10=>'ZTS_EU_10_Current_Sales__c',
        																	  11=>'ZTS_EU_11_Current_Sales__c',
        																	  12=>'ZTS_EU_12_Current_Sales__c'};
        // map that stores field name of previous sales along with month																	 
        public Map<Integer,String> mapOfPreviousSales = new Map<Integer,String>{1=>'ZTS_EU_01_Previous_Sales__c',
        																	  2=>'ZTS_EU_02_Previous_Sales__c',
        																	  3=>'ZTS_EU_03_Previous_Sales__c',
        																	  4=>'ZTS_EU_04_Previous_Sales__c',
        																	  5=>'ZTS_EU_05_Previous_Sales__c',
        																	  6=>'ZTS_EU_06_Previous_Sales__c',
        																	  7=>'ZTS_EU_07_Previous_Sales__c',
        																	  8=>'ZTS_EU_08_Previous_Sales__c',
        																	  9=>'ZTS_EU_09_Previous_Sales__c',
        																	  10=>'ZTS_EU_10_Previous_Sales__c',
        																	  11=>'ZTS_EU_11_Previous_Sales__c',
        																	  12=>'ZTS_EU_12_Previous_Sales__c'};
        																	  
        public Map<Integer,String> mapOfData = new Map<Integer,String>{1=>'0',
        															   2=>'0',
        															   3=>'0',
        														       4=>'0',
        															   5=>'0',
        															   6=>'0',
        															   7=>'0',
        															   8=>'0',
        															   9=>'0',
        															   10=>'0',
        															   11=>'0',
        															   12=>'0'};
        
        public ZTS_EuDynamicReport()
        {
            renderRating = true;
            error = false;
            isBrand = false;
            reportURL = '';
            isStdReport = true;
            // considering that the currency is consistent. The code will verify it by looping through the sales records
            listMonthlySegment = new List<MonthlySegmentWrapper>();
            listProductNames = new List<SelectOption>();
        }
        public List<selectOption> getReports() 
        {
           List<selectOption> options = new List<selectOption>();
           //Get all reports from the custom settings
           Map<String, ZTS_EU_Report_Names__c> allReports = ZTS_EU_Report_Names__c.getall();
           List<String> reportNames = new List<String>();
           reportNames.addAll(allReports.keySet());
           reportNames.sort();
           for(String reports : reportNames)
           {
                ZTS_EU_Report_Names__c name = allReports.get(reports);
                options.add(new SelectOption(name.Report_Name__c, name.Name));
                reportBusinessUnits.put(name.Name,name.ZTS_EU_Business_Unit__c != null?name.ZTS_EU_Business_Unit__c:'');
                system.debug('***************reportBusinessUnits********'+reportBusinessUnits);
           }
         return options;
         }
         
         public List<selectOption> getbusinessUnits() 
         {
           List<selectOption> options = new List<selectOption>();
           options.add(new SelectOption('', 'None'));
           Map<String, ZTS_EU_Business_Units__c> allBusinessUnits = ZTS_EU_Business_Units__c.getall();
           List<String> buNames = new List<String>();
           buNames.addAll(allBusinessUnits.keySet());
           buNames.sort();
           for(String businessUnits : buNames)
           {
                ZTS_EU_Business_Units__c name = allBusinessUnits.get(businessUnits);
                options.add(new SelectOption(name.name, name.name));
           }
           return options;
         }
        
        public List<selectOption> getbusinessUnitsMS() 
        {
           List<selectOption> options = new List<selectOption>();
           Map<String, ZTS_EU_Business_Units__c> allBusinessUnits = ZTS_EU_Business_Units__c.getall();
           List<String> buNames = new List<String>();
           buNames.addAll(allBusinessUnits.keySet());
           buNames.sort();
           for(String businessUnits : buNames)
           {
                ZTS_EU_Business_Units__c name = allBusinessUnits.get(businessUnits);
                options.add(new SelectOption(name.name, name.name));
           }
           return options;
        }
         
        
        public void showProducts(){
            String bunit = '%' + businessUnit + '%';
            listProductNames = new List<SelectOption>();
            Set<String> productNameSet = new Set<String>();
            List<String> productNameList = new List<String>();
            Set<Id> setTerritoryID = ZOE_FindTerritoryByUserId.findTerritoriesForUserId(UserInfo.getUserId(), true);
            Set<ID> setAccountID = ZOE_FindTerritoryByUserId.getAllAccountsByTerritory(setTerritoryID, UserInfo.getUserId());
            List<ZTS_EU_Sales__c> listSalesData;
            
            if(!test.isRunningTest()){
                listSalesData  = [Select CurrencyIsoCode,ZTS_EU_Account__r.Name, ZTS_EU_Product__r.Name, ZTS_EU_Account__r.ZTS_EU_RAT_CA__c, ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c, 
                                        ZTS_EU_Account__r.ZTS_EU_RAT_PY__c, ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, 
                                        ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c From ZTS_EU_Sales__c where ZTS_EU_Account__c IN: setAccountID and
                                        ZTS_EU_Business_Units__c like: bunit AND ZTS_EU_IsDataFromBatchJob__c = false limit: LIMITS.getLimitQueryRows() - LIMITS.getQueryRows() ];
            }else{
                listSalesData  = [Select CurrencyIsoCode,ZTS_EU_Account__r.Name, ZTS_EU_Product__r.Name, ZTS_EU_Account__r.ZTS_EU_RAT_CA__c, ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c, 
                                        ZTS_EU_Account__r.ZTS_EU_RAT_PY__c, ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, 
                                        ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c From ZTS_EU_Sales__c WHERE ZTS_EU_IsDataFromBatchJob__c = false limit: LIMITS.getLimitQueryRows() - LIMITS.getQueryRows()];
            }
            for(ZTS_EU_Sales__c sales: listSalesData){
                productNameSet.add(sales.ZTS_EU_Product__r.Name);
            }
            productNameList.addAll(productNameSet);
            productNameList.sort();
            for(String str: productNameList){
                listProductNames.add(new SelectOption(str, str));
            }
            listProductNames.add(new SelectOption('All','All'));
        }
        
        public void changeReportType(){
            // If the selected report type is standard, then set the isStdReport variable to true
            if(reportName != null && (reportName.equalsIgnoreCase('Monthly Segment Sales') || reportName.equalsIgnoreCase('Monthly Brand Sales'))){
                isStdReport = false;
            }else{
                isStdReport = true;
            }
            filterValue = null;
            businessUnit = null;
            selectedProduct = null;
        }
         
        public List<selectOption> getaddFilter() 
        {
            List<selectOption> options = new List<selectOption>();
            if(businessUnit!=null)
            {
                
                renderRating = false;
                String splitString;
                String allString;
                Map<String, ZTS_EU_Business_Units__c> allBusinessUnits = ZTS_EU_Business_Units__c.getall();
                List<String> buNames = new List<String>();
                buNames.addAll(allBusinessUnits.keySet());
                ZTS_EU_Business_Units__c name = allBusinessUnits.get(businessUnit);
                splitString = name.Ratings__c;
                List<String> ratings = splitString.split(',');
                for(String addRatings : ratings)
                {
                    if(!addRatings.equalsIgnoreCase('All'))
                    {
                        if(allString!=null)
                        {
                            allString = allString + ',' + addRatings;
                        }
                        else
                        {
                            allString = addRatings;
                        }
                        options.add(new SelectOption(addRatings, addRatings));
                    }
                    else
                    {
                        options.add(new SelectOption(allString, addRatings));
                    }
                }
            }
            
           return options;
         }
         
         public pagereference showReport()
         {
            listMonthlySegment = new List<MonthlySegmentWrapper>();
            //PageReference newPage = new PageReference(rURL+'/'+rId+'?'+'pv0='+filterValue+'&'+'pv1='+filterValue);
            PageReference newPage = null;
            List<User> userData = [SELECT ZTS_EU_Market__c FROM User where Id =: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];
            if(userData != null && userData.size() > 0){
            	if(userData[0].ZTS_EU_Market__c != null)
            	userMarket = userData[0].ZTS_EU_Market__c;
            }
            if(businessUnit!=null ){
                /* If the selected report is Monthly Segment Sales, redirect to the VF page displaying the report */
                if(reportName != null && (reportName.equalsIgnoreCase('Monthly Segment Sales') || reportName.equalsIgnoreCase('Monthly Brand Sales')) ){
                	if(userMarket != null && userMarket.trim().length() > 0){
	                if(reportName != null && reportName.equalsIgnoreCase('Monthly Segment Sales') ){
	                    showProducts();
	                    generateReportData(businessUnit, true);
	                }else if(reportName != null && reportName.equalsIgnoreCase('Monthly Brand Sales')){
	                    isStdReport = false;
	                    generateReportData(businessUnit, false);
	                }
                 } else {
                	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'There is no market for the user:'+UserInfo.getFirstName()+' '+UserInfo.getLastName());
                	ApexPages.addMessage(errorMsg);
                	error = true;
                }
                }else{
	                	system.debug('***************reportBusinessUnits11111********'+reportBusinessUnits);
	                    String reportName = reportName + ((reportBusinessUnits.get(reportName)!= null && reportBusinessUnits.get(reportName).length() > 0 
	                    							   && reportBusinessUnits.get(reportName).contains(businessUnit))? ' - '+ businessUnit : '');
	                    system.debug('***************reportName********'+reportName);
	                    List<Report> report = [Select Id from report where Name =:reportName limit 1];
	                    if(report.size()>0)
	                    {
	                        filterValue = filterValue.replace('[','').replace(']','');
	                        reportURL = rURL+'/'+report[0].Id+'?'+'pv0='+filterValue;
	                        isStdReport = true;
	                        newPage = new PageReference(rURL+'/'+report[0].Id+'?'+'pv0='+filterValue);
	                    }
	                    else
	                    {
	                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The selected report does not exist. Please select a different report');
	                        ApexPages.addMessage(errorMsg);
	                        error = true;
	                    }
	                }
                }else if(reportName.equalsIgnoreCase('Activity Analysis') || reportName.equalsIgnoreCase('Time Management')){
                List<Report> report = [Select Id from report where Name =:reportName limit 1];
                if(report.size()>0){
                    if(reportName.equalsIgnoreCase('Time Management')){
                        List<User> listUser = [select ZTS_EU_Market__c from User where Id=: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];
                        if(listUser != null && listUser.size() > 0 && listUser[0].ZTS_EU_Market__c != null){
                            newPage = new PageReference(rURL+'/'+report[0].Id+'?pv1='+listUser[0].ZTS_EU_Market__c);
                            reportURL = rURL+'/'+report[0].Id+'?pv1='+listUser[0].ZTS_EU_Market__c;
                        }
                    }else{
                        newPage = new PageReference(rURL+'/'+report[0].Id);
                        reportURL = rURL+'/'+report[0].Id;
                    }
                    isStdReport = true;
                }else{
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The selected report does not exist. Please select a different report');
                    ApexPages.addMessage(errorMsg);
                    error = true;
                }
            }else if(businessUnitMS != null && reportName.equalsIgnoreCase('Brand Sales Report YTD')){
                List<Report> report = [Select Id from report where Name =:reportName limit 1];
                if(report.size()>0){
                    businessUnitMS = businessUnitMS.replace('[','').replace(']','');
                    newPage = new PageReference(rURL+'/'+report[0].Id+'?'+'pv1='+businessUnitMS);
                    reportURL = rURL+'/'+report[0].Id+'?'+'pv1='+businessUnitMS;
                    isStdReport = true;
                }else{
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The selected report does not exist. Please select a different report');
                    ApexPages.addMessage(errorMsg);
                    error = true;
                }
            }                
            else
            {
                String message = '';
                if(reportName != null && reportName.equalsIgnoreCase('Monthly Segment Sales') ){
                    message = 'Please select Business Unit and Product to view the report';
                }else if(reportName != null && reportName.equalsIgnoreCase('Monthly Brand Sales') ){
                    message = 'Please select Business Unit and Rating to view the report';
                }
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.WARNING, message);
                ApexPages.addMessage(errorMsg);
                error = true;
            }
            
            return newPage;
         }
        
        /* Generate the data for Monthly Segment Sales Report based on the business unit selected */
        public void generateReportData(String businessUnit, Boolean isSegment){
            listMonthlySegment = new List<MonthlySegmentWrapper>();
            List<String> listSegment = new List<String>();
            Set<Id> setTerritoryID = ZOE_FindTerritoryByUserId.findTerritoriesForUserId(UserInfo.getUserId(), true);
            Set<ID> setAccountID = ZOE_FindTerritoryByUserId.getAllAccountsByTerritory(setTerritoryID, UserInfo.getUserId());
            List<ZTS_EU_Sales__c> listSalesData;
            List<ZTS_EU_Sales__c> listSalesDataOriginal;
            Map<String, List<ZTS_EU_Sales__c>> mapSegmentSales = new Map<String, List<ZTS_EU_Sales__c>>();
            
            String soqlQuery = 'Select CurrencyIsoCode,ZTS_EU_Account__r.Name, ZTS_EU_Parent_Account__c, ZTS_EU_Product__c, ZTS_EU_Account__c, ZTS_EU_12_Previous_Units__c, '+
                                'ZTS_EU_12_Previous_Sales__c,  ZTS_EU_12_Current_Sales__c, ZTS_EU_11_Previous_Sales__c, ZTS_EU_11_Current_Sales__c, ZTS_EU_10_Previous_Sales__c, '+
                                'ZTS_EU_10_Current_Sales__c, ZTS_EU_09_Previous_Sales__c,  ZTS_EU_09_Current_Sales__c, ZTS_EU_08_Previous_Sales__c, ZTS_EU_08_Current_Sales__c, '+
                                'ZTS_EU_07_Previous_Sales__c, ZTS_EU_07_Current_Sales__c, ZTS_EU_06_Previous_Sales__c, ZTS_EU_06_Current_Sales__c, ZTS_EU_05_Previous_Sales__c, '+
                                'ZTS_EU_05_Current_Sales__c, ZTS_EU_04_Current_Sales__c, ZTS_EU_04_Previous_Sales__c, ZTS_EU_03_Previous_Sales__c,ZTS_EU_03_Current_Sales__c, '+
                                'ZTS_EU_02_Previous_Sales__c, ZTS_EU_02_Current_Sales__c, ZTS_EU_01_Previous_Sales__c, ZTS_EU_Brand__c, ZTS_EU_01_Current_Sales__c, Name, '+
                                'Id, ZTS_EU_Product_Line_Item__c, ZTS_EU_Business_Units__c, ZTS_EU_Product__r.Name, ZTS_EU_Account__r.ZTS_EU_RAT_CA__c, '+
                                'ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c, ZTS_EU_Account__r.ZTS_EU_RAT_PY__c, ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, '+
                                'ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c,ZTS_EU_Date__c From ZTS_EU_Sales__c where ';
            if(isSegment){
                isBrand = false;
                List<SelectOption> ratingList;
                ratingList = getaddFilter();
                
                List<String> listAllRatings = new List<String>();
                String selectedRatingType = '';
                for(SelectOption str: ratingList){
                    if(str.getlabel() != 'All'){ listAllRatings.add(str.getvalue()); }
                }
                
                businessUnit = String.escapeSingleQuotes(businessUnit);
                businessUnit = '%' + businessUnit + '%';
                soqlQuery += ' ZTS_EU_Account__c IN: setAccountID AND ZTS_EU_IsDataFromBatchJob__c = false AND ZTS_EU_Business_Units__c like \'%' + businessUnit + '%\'  '  ;
                if(selectedProduct != null && selectedProduct != '' && selectedProduct != 'All'){
                    soqlQuery += ' and ZTS_EU_Product__r.Name like: selectedProduct ';
                }
                soqlQuery += ' order by ZTS_EU_Account__r.ZTS_EU_RAT_CA__c asc, ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c asc, ZTS_EU_Account__r.ZTS_EU_RAT_PY__c asc, ';
                soqlQuery += 'ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c ';
                if(test.isRunningTest()){
                    soqlQuery = 'Select CurrencyIsoCode,ZTS_EU_Account__r.Name, ZTS_EU_Parent_Account__c, ZTS_EU_Product__c, ZTS_EU_Account__c, ZTS_EU_12_Previous_Units__c, '+
                                'ZTS_EU_12_Previous_Sales__c,  ZTS_EU_12_Current_Sales__c, ZTS_EU_11_Previous_Sales__c, ZTS_EU_11_Current_Sales__c, ZTS_EU_10_Previous_Sales__c, '+
                                'ZTS_EU_10_Current_Sales__c, ZTS_EU_09_Previous_Sales__c,  ZTS_EU_09_Current_Sales__c, ZTS_EU_08_Previous_Sales__c, ZTS_EU_08_Current_Sales__c, '+
                                'ZTS_EU_07_Previous_Sales__c, ZTS_EU_07_Current_Sales__c, ZTS_EU_06_Previous_Sales__c, ZTS_EU_06_Current_Sales__c, ZTS_EU_05_Previous_Sales__c, '+
                                'ZTS_EU_05_Current_Sales__c, ZTS_EU_04_Current_Sales__c, ZTS_EU_04_Previous_Sales__c, ZTS_EU_03_Previous_Sales__c,ZTS_EU_03_Current_Sales__c, '+
                                'ZTS_EU_02_Previous_Sales__c, ZTS_EU_02_Current_Sales__c, ZTS_EU_01_Previous_Sales__c, ZTS_EU_Brand__c, ZTS_EU_01_Current_Sales__c, Name, Id, '+
                                'ZTS_EU_Product_Line_Item__c, ZTS_EU_Business_Units__c, ZTS_EU_Product__r.Name, ZTS_EU_Account__r.ZTS_EU_RAT_CA__c, '+
                                'ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c, ZTS_EU_Account__r.ZTS_EU_RAT_PY__c, ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, '+
                                'ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c,ZTS_EU_Date__c From ZTS_EU_Sales__c';
                }
                //soqlQuery += ' limit: LIMITS.getLimitQueryRows() - LIMITS.getQueryRows()';
                listSalesData = Database.query(soqlQuery);
                if(listSalesData != null && listSalesData.size() > 0){
                	 
                	system.debug('**************listSalesData[0].ZTS_EU_Date__c********************'+listSalesData[0].ZTS_EU_Date__c);	
                	List<ZTS_EU_Accounting_Period__c> listAccPeriod = [select Id, ZTS_EU_Account_Period__c from ZTS_EU_Accounting_Period__c where 
                                                            ZTS_EU_AP_Start__c <=: listSalesData[0].ZTS_EU_Date__c and ZTS_EU_AP_End__c >=: listSalesData[0].ZTS_EU_Date__c AND ZTS_EU_Market__c =: userMarket limit 1];
                     system.debug('**************listAccPeriod********************'+listAccPeriod);
                     if(listAccPeriod != null && listAccPeriod.size() > 0){
		                Integer startCounter = Integer.valueOf(listAccPeriod[0].ZTS_EU_Account_Period__c) - 1;
		                Integer keyValue = 1;
		                for(Integer i = startCounter; i >= 1; i--){
		                	mapOfData.put(i, String.valueOf(keyValue));
		                    keyValue++;
		                    system.debug('**************mapOfData222222222222*******************'+mapOfData);	
		                }
		                system.debug('**************mapOfData3333333333333333333*******************'+mapOfData);	
		          	 }                                        
                }
                // filtering the listSalesData based on the currency of context user
                listSalesDataOriginal = listSalesData;
                listSalesData = ZTS_EuDynamicReportHelper.filterSalesRecordOnCurrency(listSalesDataOriginal);
                
                for(ZTS_EU_Sales__c sales: listSalesData){
                    if(businessUnit.equalsIgnoreCase('%CA%')){
                        if(!mapSegmentSales.containsKey(sales.ZTS_EU_Account__r.ZTS_EU_RAT_CA__c) && sales.ZTS_EU_Account__r.ZTS_EU_RAT_CA__c != null){
                            mapSegmentSales.put(sales.ZTS_EU_Account__r.ZTS_EU_RAT_CA__c, new List<ZTS_EU_Sales__c>{sales});
                            listSegment.add(sales.ZTS_EU_Account__r.ZTS_EU_RAT_CA__c);
                        }else if(sales.ZTS_EU_Account__r.ZTS_EU_RAT_CA__c != null){
                            mapSegmentSales.get(sales.ZTS_EU_Account__r.ZTS_EU_RAT_CA__c).add(sales);
                        }
                    }else if(businessUnit.equalsIgnoreCase('%EQ%')){
                        if(!mapSegmentSales.containsKey(sales.ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c) && sales.ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c != null){
                            mapSegmentSales.put(sales.ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c, new List<ZTS_EU_Sales__c>{sales});
                            listSegment.add(sales.ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c);
                        }else if(sales.ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c != null){
                            mapSegmentSales.get(sales.ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c).add(sales);
                        }
                    }else if(businessUnit.equalsIgnoreCase('%PY%')){
                        if(!mapSegmentSales.containsKey(sales.ZTS_EU_Account__r.ZTS_EU_RAT_PY__c) && sales.ZTS_EU_Account__r.ZTS_EU_RAT_PY__c != null){
                            mapSegmentSales.put(sales.ZTS_EU_Account__r.ZTS_EU_RAT_PY__c, new List<ZTS_EU_Sales__c>{sales});
                            listSegment.add(sales.ZTS_EU_Account__r.ZTS_EU_RAT_PY__c);
                        }else if(sales.ZTS_EU_Account__r.ZTS_EU_RAT_PY__c != null){
                            mapSegmentSales.get(sales.ZTS_EU_Account__r.ZTS_EU_RAT_PY__c).add(sales);
                        }
                    }else if(businessUnit.equalsIgnoreCase('%RU%')){
                        if(!mapSegmentSales.containsKey(sales.ZTS_EU_Account__r.ZTS_EU_RAT_RU__c) && sales.ZTS_EU_Account__r.ZTS_EU_RAT_RU__c != null){
                            mapSegmentSales.put(sales.ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, new List<ZTS_EU_Sales__c>{sales});
                            listSegment.add(sales.ZTS_EU_Account__r.ZTS_EU_RAT_RU__c);
                        }else if(sales.ZTS_EU_Account__r.ZTS_EU_RAT_RU__c != null){
                            mapSegmentSales.get(sales.ZTS_EU_Account__r.ZTS_EU_RAT_RU__c).add(sales);
                        }
                    }else if(businessUnit.equalsIgnoreCase('%SW%')){
                        if(!mapSegmentSales.containsKey(sales.ZTS_EU_Account__r.ZTS_EU_RAT_SW__c) && sales.ZTS_EU_Account__r.ZTS_EU_RAT_SW__c != null){
                            mapSegmentSales.put(sales.ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, new List<ZTS_EU_Sales__c>{sales});
                            listSegment.add(sales.ZTS_EU_Account__r.ZTS_EU_RAT_SW__c);
                        }else if(sales.ZTS_EU_Account__r.ZTS_EU_RAT_SW__c != null){
                            mapSegmentSales.get(sales.ZTS_EU_Account__r.ZTS_EU_RAT_SW__c).add(sales);
                        }
                    }else if(businessUnit.equalsIgnoreCase('%VPS%')){
                        if(!mapSegmentSales.containsKey(sales.ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c) && sales.ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c != null){
                            mapSegmentSales.put(sales.ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c, new List<ZTS_EU_Sales__c>{sales});
                            listSegment.add(sales.ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c);
                        }else if(sales.ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c != null){
                            mapSegmentSales.get(sales.ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c).add(sales);
                        }
                    }
                    
                }
            }else{
                isBrand = true;
                businessUnit = String.escapeSingleQuotes(businessUnit);
                businessUnit = '%' + businessUnit + '%';
                //soqlQuery += ' ZTS_EU_Account__c IN: setAccountID  AND ZTS_EU_Business_Units__c like \'%' + businessUnit + '%\'  '  ;
                soqlQuery += 'ZTS_EU_Account__c IN: setAccountID AND ZTS_EU_IsDataFromBatchJob__c = false AND ZTS_EU_Product_Type__c = ' +'\'Brand\'  AND ZTS_EU_Business_Units__c like \'%' + businessUnit + '%\'  '  ;
                
                if(!filterValue.contains(',')){
                    filterValue = filterValue.replace('[','').replace(']','');
                    if(businessUnit.equalsIgnoreCase('%CA%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_CA__c =: filterValue'  ;
                    }else if(businessUnit.equalsIgnoreCase('%EQ%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c =: filterValue' ;
                    }else if(businessUnit.equalsIgnoreCase('%PY%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_PY__c =: filterValue' ;
                    }else if(businessUnit.equalsIgnoreCase('%RU%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_RU__c =: filterValue' ;
                    }else if(businessUnit.equalsIgnoreCase('%SW%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_SW__c =: filterValue' ;
                    }else if(businessUnit.equalsIgnoreCase('%VPS%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c =: filterValue' ;
                    }
                }else{
                    List<String> listFilterVal = new List<String>();
                    listFilterVal = filterValue.replace('[','').replace(']','').split(',');
                    if(businessUnit.equalsIgnoreCase('%CA%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_CA__c IN: listFilterVal'  ;
                    }else if(businessUnit.equalsIgnoreCase('%EQ%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c IN: listFilterVal' ;
                    }else if(businessUnit.equalsIgnoreCase('%PY%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_PY__c IN: listFilterVal' ;
                    }else if(businessUnit.equalsIgnoreCase('%RU%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_RU__c IN: listFilterVal' ;
                    }else if(businessUnit.equalsIgnoreCase('%SW%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_SW__c IN: listFilterVal' ;
                    }else if(businessUnit.equalsIgnoreCase('%VPS%')){
                        soqlQuery += ' AND ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c IN: listFilterVal' ;
                    }
                }
                
                
                if(test.isRunningTest()){
                    soqlQuery = 'Select CurrencyIsoCode,ZTS_EU_Account__r.Name, ZTS_EU_Parent_Account__c, ZTS_EU_Product__c, ZTS_EU_Account__c, ZTS_EU_12_Previous_Units__c, '+
                                'ZTS_EU_12_Previous_Sales__c,  ZTS_EU_12_Current_Sales__c, ZTS_EU_11_Previous_Sales__c, ZTS_EU_11_Current_Sales__c, ZTS_EU_10_Previous_Sales__c, '+
                                'ZTS_EU_10_Current_Sales__c, ZTS_EU_09_Previous_Sales__c,  ZTS_EU_09_Current_Sales__c, ZTS_EU_08_Previous_Sales__c, ZTS_EU_08_Current_Sales__c, '+
                                'ZTS_EU_07_Previous_Sales__c, ZTS_EU_07_Current_Sales__c, ZTS_EU_06_Previous_Sales__c, ZTS_EU_06_Current_Sales__c, ZTS_EU_05_Previous_Sales__c, '+
                                'ZTS_EU_05_Current_Sales__c, ZTS_EU_04_Current_Sales__c, ZTS_EU_04_Previous_Sales__c, ZTS_EU_03_Previous_Sales__c,ZTS_EU_03_Current_Sales__c, '+
                                'ZTS_EU_02_Previous_Sales__c, ZTS_EU_02_Current_Sales__c, ZTS_EU_01_Previous_Sales__c, ZTS_EU_Brand__c, ZTS_EU_01_Current_Sales__c, Name, Id, '+
                                'ZTS_EU_Product_Line_Item__c, ZTS_EU_Business_Units__c, ZTS_EU_Product__r.Name, ZTS_EU_Account__r.ZTS_EU_RAT_CA__c, '+
                                'ZTS_EU_Account__r.ZTS_EU_RAT_EQ__c, ZTS_EU_Account__r.ZTS_EU_RAT_PY__c, ZTS_EU_Account__r.ZTS_EU_RAT_RU__c, ZTS_EU_Account__r.ZTS_EU_RAT_SW__c, '+
                                'ZTS_EU_Account__r.ZTS_EU_RAT_VPS__c,ZTS_EU_Date__c From ZTS_EU_Sales__c';
                }
                //soqlQuery += ' limit: '+LIMITS.getLimitQueryRows() +' - ' + LIMITS.getQueryRows();
                listSalesData = Database.query(soqlQuery);
                
                // filtering the listSalesData based on the currency of context user
                listSalesDataOriginal = listSalesData;
                listSalesData = ZTS_EuDynamicReportHelper.filterSalesRecordOnCurrency(listSalesDataOriginal);
                if(listSalesData != null && listSalesData.size() > 0){
                	system.debug('**************listSalesData[0].ZTS_EU_Date__c********************'+listSalesData[0].ZTS_EU_Date__c);	
                	List<ZTS_EU_Accounting_Period__c> listAccPeriod = [select Id, ZTS_EU_Account_Period__c from ZTS_EU_Accounting_Period__c where 
                                                            ZTS_EU_AP_Start__c <=: listSalesData[0].ZTS_EU_Date__c and ZTS_EU_AP_End__c >=: listSalesData[0].ZTS_EU_Date__c AND ZTS_EU_Market__c =: userMarket limit 1];
                     system.debug('**************listAccPeriod********************'+listAccPeriod);
                     if(listAccPeriod != null && listAccPeriod.size() > 0){
		                Integer startCounter = Integer.valueOf(listAccPeriod[0].ZTS_EU_Account_Period__c)-1;
		                Integer keyValue = 1;
		                for(Integer i = startCounter; i >= 1; i--){
		                	mapOfData.put(i, String.valueOf(keyValue));
		                    keyValue++;
		                    system.debug('**************mapOfData222222222222*******************'+mapOfData);	
		                }
		                system.debug('**************mapOfData3333333333333333333*******************'+mapOfData);	
		          	 }                                        
                }
                for(ZTS_EU_Sales__c sales: listSalesData){
                    if(!mapSegmentSales.containsKey(sales.ZTS_EU_Product__r.name)){
                        mapSegmentSales.put(sales.ZTS_EU_Product__r.name, new List<ZTS_EU_Sales__c>{sales});
                        listSegment.add(sales.ZTS_EU_Product__r.name);
                    }else{
                        mapSegmentSales.get(sales.ZTS_EU_Product__r.name).add(sales);
                    }
                }
            }
            
            //adding info message if there are no sales record found
            if(listSalesDataOriginal.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.ZTS_EU_DynamicReport_NoRecordsMsg));
            }
            
            //adding warning message to the page when some accounts where removed due to mismatch in currency
            if(listSalesDataOriginal.size() != listSalesData.size()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.ZTS_EU_DynamicReport_AccountRemovalMsg));
            }
            
            listSegment.sort();
            MonthlySegmentWrapper monthlySegment;
            //for(String sgmnt : mapSegmentSales.keySet()){
            for(String sgmnt : listSegment){ 
                ValueWrapper monthValuesCY = new ValueWrapper();
                ValueWrapper monthValuesPY = new ValueWrapper();
                Decimal mon1ValCY = 0; Decimal  mon2ValCY = 0; Decimal  mon3ValCY = 0; Decimal  mon4ValCY = 0; Decimal  mon5ValCY = 0; Decimal  mon6ValCY = 0;
                Decimal mon7ValCY = 0; Decimal  mon8ValCY = 0; Decimal  mon9ValCY = 0; Decimal  mon10ValCY = 0; Decimal mon11ValCY = 0; Decimal mon12ValCY = 0;
                Decimal mon1Val = 0; Decimal    mon2Val = 0; Decimal    mon3Val = 0; Decimal    mon4Val = 0; Decimal    mon5Val = 0; Decimal    mon6Val = 0;
                Decimal mon7Val = 0; Decimal    mon8Val = 0; Decimal    mon9Val = 0; Decimal    mon10Val = 0; Decimal   mon11Val = 0; Decimal   mon12Val = 0;
                Decimal totalValCY = 0; Decimal totalValPY = 0;
                for(ZTS_EU_Sales__c segmtSales: mapSegmentSales.get(sgmnt)){
                	system.debug('*************mapOfData**********'+mapOfData);
                	if(mapOfData != null){
	                    mon1ValCY += mapOfData.get(1)!= '' && mapOfData.get(1) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(1))))) : 0;
	                    mon1Val   += mapOfData.get(1)!= '' && mapOfData.get(1) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(1))))) : 0;
	                    
	                   mon2ValCY += mapOfData.get(2)!= '' && mapOfData.get(2) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(2))))) : 0;
	                    mon2Val += mapOfData.get(2)!= '' && mapOfData.get(2) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(2))))) : 0;
	                    
	                    mon3ValCY += mapOfData.get(3)!= '' && mapOfData.get(3) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(3))))) : 0;
	                    mon3Val += mapOfData.get(3)!= '' && mapOfData.get(3) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(3))))) : 0;
	                    
	                    mon4ValCY += mapOfData.get(4)!= '' && mapOfData.get(4) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(4))))) : 0;
	                    mon4Val += mapOfData.get(4)!= '' && mapOfData.get(4) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(4))))) : 0;
	                    
	                    mon5ValCY += mapOfData.get(5)!= '' && mapOfData.get(5) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(5))))) : 0;
	                    mon5Val += mapOfData.get(5)!= '' && mapOfData.get(5) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(5))))) : 0;
	                    
	                    mon6ValCY += mapOfData.get(6)!= '' && mapOfData.get(6) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(6))))) : 0;
	                    mon6Val += mapOfData.get(6)!= '' && mapOfData.get(6) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(6))))) : 0;
	                    
	                    mon7ValCY += mapOfData.get(7)!= '' && mapOfData.get(7) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(7))))) : 0;
	                    mon7Val += mapOfData.get(7)!= '' && mapOfData.get(7) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(7))))) : 0;
	                    
	                    mon8ValCY += mapOfData.get(8)!= '' && mapOfData.get(8) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(8))))) : 0;
	                    mon8Val += mapOfData.get(8)!= '' && mapOfData.get(8) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(8))))) : 0;
	                    
	                    mon9ValCY += mapOfData.get(9)!= '' && mapOfData.get(9) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(9))))) : 0;
	                    mon9Val += mapOfData.get(9)!= '' && mapOfData.get(9) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(9))))) : 0;
	                    
	                    mon10ValCY += mapOfData.get(10)!= '' && mapOfData.get(10) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(10))))) : 0;
	                    mon10Val += mapOfData.get(10)!= '' && mapOfData.get(10) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(10))))) : 0;
	                    
	                    mon11ValCY += mapOfData.get(11)!= '' && mapOfData.get(11) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(11))))) : 0;
	                    mon11Val += mapOfData.get(11)!= '' && mapOfData.get(11) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(11))))) : 0;
	                    
	                    mon12ValCY += mapOfData.get(12)!= '' && mapOfData.get(12) != '0' ?Integer.valueOf(segmtSales.get(mapOfCurrentSales.get(Integer.valueOf(mapOfData.get(12))))) : 0;
	                    mon12Val += mapOfData.get(12)!= '' && mapOfData.get(12) != '0' ?Integer.valueOf(segmtSales.get(mapOfPreviousSales.get(Integer.valueOf(mapOfData.get(12))))) : 0;
	                   /* mon1Val += segmtSales.ZTS_EU_01_Previous_Sales__c.setScale(0);
	                    
	                   /mon2ValCY += segmtSales.ZTS_EU_02_Current_Sales__c.setScale(0);
	                    mon2Val += segmtSales.ZTS_EU_02_Previous_Sales__c.setScale(0);
	                    
	                    mon3ValCY += segmtSales.ZTS_EU_03_Current_Sales__c.setScale(0);
	                    mon3Val += segmtSales.ZTS_EU_03_Previous_Sales__c.setScale(0);
	                    
	                    mon4ValCY += segmtSales.ZTS_EU_04_Current_Sales__c.setScale(0);
	                    mon4Val += segmtSales.ZTS_EU_04_Previous_Sales__c.setScale(0);
	                    
	                    mon5ValCY += segmtSales.ZTS_EU_05_Current_Sales__c.setScale(0);
	                    mon5Val += segmtSales.ZTS_EU_05_Previous_Sales__c.setScale(0);
	                    
	                    mon6ValCY += segmtSales.ZTS_EU_06_Current_Sales__c.setScale(0);
	                    mon6Val += segmtSales.ZTS_EU_06_Previous_Sales__c.setScale(0);
	                    
	                    mon7ValCY += segmtSales.ZTS_EU_07_Current_Sales__c.setScale(0);
	                    mon7Val += segmtSales.ZTS_EU_07_Previous_Sales__c.setScale(0);
	                    
	                    mon8ValCY += segmtSales.ZTS_EU_08_Current_Sales__c.setScale(0);
	                    mon8Val += segmtSales.ZTS_EU_08_Previous_Sales__c.setScale(0);
	                    
	                    mon9ValCY += segmtSales.ZTS_EU_09_Current_Sales__c.setScale(0);
	                    mon9Val += segmtSales.ZTS_EU_09_Previous_Sales__c.setScale(0);
	                    
	                    mon10ValCY += segmtSales.ZTS_EU_10_Current_Sales__c.setScale(0);
	                    mon10Val += segmtSales.ZTS_EU_10_Previous_Sales__c.setScale(0);
	                    
	                    mon11ValCY += segmtSales.ZTS_EU_11_Current_Sales__c.setScale(0);
	                    mon11Val += segmtSales.ZTS_EU_11_Previous_Sales__c.setScale(0);
	                    
	                    mon12ValCY += segmtSales.ZTS_EU_12_Current_Sales__c.setScale(0);
	                    mon12Val += segmtSales.ZTS_EU_12_Previous_Sales__c.setScale(0);*/
                	}
                }
                totalValCY = mon1ValCY + mon2ValCY + mon3ValCY + mon4ValCY + mon5ValCY + mon6ValCY + mon7ValCY + mon8ValCY + mon9ValCY + mon10ValCY + mon11ValCY + mon12ValCY;
                totalValPY = mon1Val + mon2Val + mon3Val + mon4Val + mon5Val + mon6Val + mon7Val + mon8Val + mon9Val + mon10Val + mon11Val + mon12Val;
                monthValuesCY.mon1Val = mon1ValCY; monthValuesCY.mon2Val = mon2ValCY; monthValuesCY.mon3Val = mon3ValCY; monthValuesCY.mon4Val = mon4ValCY; monthValuesCY.mon5Val = mon5ValCY;
                monthValuesCY.mon6Val = mon6ValCY; monthValuesCY.mon7Val = mon7ValCY; monthValuesCY.mon8Val = mon8ValCY; monthValuesCY.mon9Val = mon9ValCY; monthValuesCY.mon10Val = mon10ValCY;
                monthValuesCY.mon11Val = mon11ValCY; monthValuesCY.mon12Val = mon12ValCY; monthValuesCY.totalVal = totalValCY;
                
                monthValuesPY.mon1Val = mon1Val; monthValuesPY.mon2Val = mon2Val; monthValuesPY.mon3Val = mon3Val; monthValuesPY.mon4Val = mon4Val; monthValuesPY.mon5Val = mon5Val;
                monthValuesPY.mon6Val = mon6Val; monthValuesPY.mon7Val = mon7Val; monthValuesPY.mon8Val = mon8Val; monthValuesPY.mon9Val = mon9Val; monthValuesPY.mon10Val = mon10Val;
                monthValuesPY.mon11Val = mon11Val; monthValuesPY.mon12Val = mon12Val; monthValuesPY.totalVal = totalValPY;
                monthlySegment = new MonthlySegmentWrapper();
                monthlySegment.segment = sgmnt;
                monthlySegment.type = 'CY';
                monthlySegment.values = monthValuesCY;
                listMonthlySegment.add(monthlySegment);
                monthlySegment = new MonthlySegmentWrapper();
                monthlySegment.segment = sgmnt;
                monthlySegment.type = 'LY';
                monthlySegment.values = monthValuesPY;
                listMonthlySegment.add(monthlySegment);
            }
            // setting the title of the page block section where the report table is displayed
            reportSecName = reportName + '   ( ' + Label.ZTS_EU_ReportSectionMsg + ' ' + UserInfo.getDefaultCurrency() + ' )';
            
        }
        
        public class MonthlySegmentWrapper{
            public String segment           {get;set;}
            public String type              {get;set;}
            public ValueWrapper values      {get;set;}
        }
        
        public class ValueWrapper{
            public Decimal mon1Val      {get;set;}
            public Decimal mon2Val      {get;set;}
            public Decimal mon3Val      {get;set;}
            public Decimal mon4Val      {get;set;}
            public Decimal mon5Val      {get;set;}
            public Decimal mon6Val      {get;set;}
            public Decimal mon7Val      {get;set;}
            public Decimal mon8Val      {get;set;}
            public Decimal mon9Val      {get;set;}
            public Decimal mon10Val     {get;set;}
            public Decimal mon11Val     {get;set;}
            public Decimal mon12Val     {get;set;}
            public Decimal totalVal     {get;set;}
        }
    }