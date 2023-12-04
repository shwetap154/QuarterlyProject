/*************************************************************************************
* Name          :    ZTS_US_salesDataReportingController
* Description   :    Controller for a Sales Analysis page
* Created By    :    Mayank
* Created Date  :    04-08-2014 
 
Modification Log
---------------------------------------------------------------------------------------
Developer              Date             Modification ID        Comments
---------------------------------------------------------------------------------------
Mayank                 04/08/2014                              Created
SohilShah(CloudSense)                   01/29/2015             Modified the code for Enhancement (DEF-001246) Sales Data Display in a Reverse order based on
                                                               Custom Setting Sales Date month   
                                                               SohilShah(CloudSense)    23rd July,2015                          Replaced ZTS_EU_Total_MAT_Current_Sales__c > ZTS_US_Total_MAT_52_Current_Sales__c
                                                                         ZTS_EU_Total_MAT_Prior_Sales__c >  ZTS_US_Total_MAT_52_Prior_Sales__c  
                                                                         ZTS_EU_Total_MAT_Diff_Sales__c >   ZTS_US_Total_MAT_52_Diff_Sales__c
                                                                         ZTS_EU_Total_MAT_P_Diff_Sales__c > ZTS_US_Total_MAT_52_P_Diff_Sales__c 
                                                                DEF- 001695 - Sohil Shah    
**************************************************************************************/
public with sharing class ZTS_US_salesDataReportingController {        
        
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
    Public List<SelectOption> selectedMultiTherapeuticGrpOpt    {get;set;}
    Public List<SelectOption> listMultiTherapeuticGrp           {get;set;} // list of select options to be shown on left in case of preset
    Public List<SelectOption> selectedMultiProductOpt           {get;set;}
    Public List<SelectOption> selectedMultiSpeciesOpt           {get;set;}
    Public String selectedProduct                               {get;set;}
    Public String selectedSpecies                               {get;set;}
    Public String selectedBillToShipTo                          {get;set;}
    Public String selectedMATYTD                                {get;set;}
    Public String selectedReport                                {get;set;}
    public String selectedLevelValue                            {get;set;}  // The variable will store the selected value of level from the page
    Public String soqlQuery                                     {get;set;}
    Public ZTS_US_Sales_Date__c salesDateCustSett               {get;set;}
    Public List<ZTS_EU_Sales__c> listSalesData;
    List<Account> listChildAccnt;
    Public Boolean parentAccntNotAvailable                      {get;set;}
    public Boolean isChildSelected                              {get;set;} // This variable will determine the type of Account selected
    Public List<CustomSettSalesData> customSetList              {get;set;}
    Public List<dataYTD> listdataYTD                            {get;set;}
    Public List<dataMAT> listdataMAT                            {get;set;}  // Added by Sohil Shah for DEF-001246
    Public Map<String,List<String>> mapTotalSalesYTD ;
    Public Map<String,List<String>> mapProdSalesYTD ;
    Public Map<String,List<String>> mapUnitSalesYTD ;    
    Public Map<String,List<String>> mapTotalSalesMAT;
    Public Map<String,List<String>> mapProdSalesMAT;
    Public Map<String,List<String>> mapUnitSalesMAT;        
    Public Map<String,String> mapNoMonth ;
    public List<String> monthList                               {get;set;}
    public List<String> monthList_MAT                           {get;set;} //Added by Sohil Shah for DEF-001246
    public List<String> tempMonthList;//Added by Sohil Shah for DEF-001246
    public List<Integer> monthList_MAT_Integer                  {get;set;} //Added by Sohil Shah for DEF-001246
    public Map<Integer, List<String>> monthValueMapping         {get;set;} // Added by Sohil Shah for DEF-001246
    public Map<Integer,String> monthNoName                      {get;set;} // Added by Sohil Shah for DEF-001246     
    Public ActualSalesDataValue obj {get;set;}
    public boolean displayPopup                                 {get; set;}
    public boolean displayErrPopup                              {get; set;}    
    public ZTS_EU_Sales_Presets__c salesPresets                 {get; set;}
    Public String selectedPreset                                {get;set;} 
    Public String salesPresetAction                             {get;set;}
    Integer counter = 0;
    Map<String,Account> mapParentToChildValues = new Map<String, Account>();   
    public boolean noParent                                     {get;set;}
    public boolean noChild                                      {get;set;}
    public boolean aggCheck                                     {get;set;}
    public boolean toggleFlagParent                             {get;set;}
    List<Account> listAccnt;
    public Map<String, List<String>> monthValueMap_YTD  {get;set;}
    //public Map<String, List<String>> monthValueMap  {get;set;}
    /* Variables to store level 1 and level 2 accounts*/
    Account level1Account;
    Account level2Account;
    public Boolean disableL1                                    {get;set;}
    public Boolean disableL2                                    {get;set;}
    
    
    /***********
    * Method name : ZTS_US_salesDataReportingController (Constructor)
    * Description : This is the constructor.
    * Return Type : None.
    * Parameters : ApexPages.StandardController controller.
    ***********/
    public ZTS_US_salesDataReportingController(ApexPages.StandardController controller) {
        monthList_MAT = new List<String>();
        tempMonthList = new List<String>();
        noChild = false;
        noParent = false;
        aggCheck = false;
        toggleFlagParent = false;
        displayErrPopup = false;
        disableL1 = true;
        disableL2 = true;
        //selectedLevelValue = 'CHILD';
        createQueryStr();
        dataNoMonth();
        userPreference();
        Id accntIdQuery;      
        selectedMATYTD = 'MAT';
        selectedBillToShipTo = 'Bill-To';
        selectedReport = 'TotalSales';   
        level1Account = null;
        level2Account = null;
        salesDateCustSett = ZTS_US_Sales_Date__c.getAll().values()[0];
        parentAccntNotAvailable =  false;
        Account accntRec = (Account)controller.getrecord();
        calculateLevelValues(accntRec);
            accntCurrent = listAccnt[0];
            accntActual = listAccnt[0];
            accnPrevious = null;
            List<Account> listParentAcc = [select Id, Name,ZTS_US_NARC_ID__c, ParentId, Parent.Name from Account where Id=: accntCurrent.ParentId AND ZTS_EU_Market__c = 'United States' limit 1];
            if(listParentAcc != null && listParentAcc.size() > 0){
                accntParent = listParentAcc[0];
            }else{
                accntParent = null;
                noParent = true;
            }
            
            accntChild = null;
        
        if(accntCurrent.ParentId == NULL){
            parentAccntNotAvailable = true;
        }
        getcreateDataTable();
    }
    
    public void calculateLevelValues(Account accntRec){
        disableL1 = true;
        disableL2 = true;
        if(accnPrevious != null && accnPrevious.Id != null && !isChildSelected){
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
    
    /***********
    * Method name : createQueryStr
    * Description : This will create query string for querying the sales data records.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void createQueryStr(){
        String SobjectApiName = 'ZTS_EU_Sales__c';
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
        soqlQuery+= 'ZTS_EU_Account__c IN: accntIds AND ZTS_EU_GLR_Type__c =: selectedBillToShipTo ';
    }
    
    /***********
    * Method name : dataNoMonth
    * Description : This will create map of months with their month number for YTD.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void dataNoMonth(){
        mapNoMonth = new Map<String,String>();
        mapNoMonth.put('1','JAN');
        mapNoMonth.put('2','FEB');
        mapNoMonth.put('3','MAR');
        mapNoMonth.put('4','APR');
        mapNoMonth.put('5','MAY');
        mapNoMonth.put('6','JUN');
        mapNoMonth.put('7','JUL');
        mapNoMonth.put('8','AUG');
        mapNoMonth.put('9','SEP');
        mapNoMonth.put('10','OCT');
        mapNoMonth.put('11','NOV');
        mapNoMonth.put('12','DEC');
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
    * Description : This method will modify the query according to filter value selected on selecting sales presets.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public void multiSelectedValueQuery(){
        selectedTherapeuticGrp = '<Therapeutic Group>';
        selectedProduct = '<Product>';
        selectedSpecies = '<Species>';
        if(selectedPreset == '--None--'){
            selectedMATYTD = 'MAT';
            selectedBillToShipTo = 'Bill-To';
        }
        getcreateDataTable();
    }
    
    
    /***********
    * Method name : getSalesPresetsData
    * Description : This will create Sales Presets with values.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<selectOption> getSalesPresetsData() {
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setSalesPreset = new Set<String>();
        options.add(new selectOption('--None--', '--None--'));
            for (ZTS_EU_Sales_Presets__c listSalesPresetData : [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Species__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() ORDER BY Name]) {
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
        Set<String> setTheraGrp = new Set<String>();
        if(selectedMultiTherapeuticGrpOpt != null && selectedMultiTherapeuticGrpOpt.size() > 0){           
            List<String> listTheraGrp = listStringPopulate(selectedMultiTherapeuticGrpOpt);
            setTheraGrp.addAll(listTheraGrp);
        }else{
            selectedMultiTherapeuticGrpOpt = new List<selectOption>();
        }
        List<selectOption> options = new List<selectOption>(); 
        Set<String> setTherapeuticGrp = new Set<String>();
        options.add(new selectOption('<Therapeutic Group>', '<Therapeutic Group>'));
            for (ZTS_EU_Species_Product__c listSalesData : [select Id, ZTS_Hierarchy_Level__c,Name from ZTS_EU_Species_Product__c where ZTS_Hierarchy_Level__c = 'Therapeutic Group' ORDER BY Name]) { 
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
            options.add(new selectOption('<Therapeutic Group>', '<Therapeutic Group>'));
            for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Therapeutic_Group__c from ZTS_EU_Sales__c where ZTS_EU_Account__c =: accntCurrent.id ORDER BY ZTS_EU_Therapeutic_Group__c]) { 
                if(listSalesData.ZTS_EU_Therapeutic_Group__c != Null && !setTherapeuticGrp.contains(listSalesData.ZTS_EU_Therapeutic_Group__c))
                options.add(new selectOption(listSalesData.ZTS_EU_Therapeutic_Group__c, listSalesData.ZTS_EU_Therapeutic_Group__c)); 
                setTherapeuticGrp.add(listSalesData.ZTS_EU_Therapeutic_Group__c);
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
        options.add(new selectOption('<Product>', '<Product>'));
            for (ZTS_EU_Species_Product__c listSalesData : [select Id, ZTS_Hierarchy_Level__c,Name from ZTS_EU_Species_Product__c where ZTS_Hierarchy_Level__c = 'Product Line' ORDER BY Name]) { 
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
        options.add(new selectOption('<Product>', '<Product>'));
            for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Brand__c, ZTS_EU_Account__r.Name,ZTS_EU_Product__r.Name from ZTS_EU_Sales__c where ZTS_EU_Account__c =: accntCurrent.id ORDER BY ZTS_EU_Brand__c]) { 
                if(listSalesData.ZTS_EU_Brand__c != Null && !setSalesDataProd.contains(listSalesData.ZTS_EU_Brand__c))
                options.add(new selectOption(listSalesData.ZTS_EU_Brand__c, listSalesData.ZTS_EU_Brand__c)); 
                setSalesDataProd.add(listSalesData.ZTS_EU_Brand__c);
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
        options.add(new selectOption('<Species>', '<Species>'));
            for (ZTS_EU_Species_Product__c listSalesData : [select Id, ZTS_Hierarchy_Level__c,Name,ZTS_Species__c from ZTS_EU_Species_Product__c ORDER BY ZTS_Species__c]) { 
                if(listSalesData.ZTS_Species__c != Null && !setSalesSpeciesData.contains(listSalesData.ZTS_Species__c)){
                    if(setSpeciesData != null && setSpeciesData.size() > 0 && !setSpeciesData.contains(listSalesData.ZTS_Species__c)){
                        options.add(new selectOption(listSalesData.ZTS_Species__c, listSalesData.ZTS_Species__c)); 
                        setSalesSpeciesData.add(listSalesData.ZTS_Species__c);
                    }else if(setSpeciesData == null || setSpeciesData.size() <= 0){
                        options.add(new selectOption(listSalesData.ZTS_Species__c, listSalesData.ZTS_Species__c)); 
                        setSalesSpeciesData.add(listSalesData.ZTS_Species__c);
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
        options.add(new selectOption('<Species>', '<Species>'));
            for (ZTS_EU_Sales__c listSalesData : [select Id, ZTS_EU_Account__c, ZTS_EU_Account__r.Name,ZTS_EU_Species__c from ZTS_EU_Sales__c where ZTS_EU_Account__c =: accntCurrent.id ORDER BY ZTS_EU_Species__c]) {                
                if(listSalesData.ZTS_EU_Species__c != Null && !setSpecies.contains(listSalesData.ZTS_EU_Species__c)){
                options.add(new selectOption(listSalesData.ZTS_EU_Species__c, listSalesData.ZTS_EU_Species__c)); 
                setSpecies.add(listSalesData.ZTS_EU_Species__c);
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
        options.add(new SelectOption('Bill-To','Bill-To'));
        options.add(new SelectOption('Ship-To','Ship-To'));
        return options;
    }
    
    /***********
    * Method name : getradioOptions3
    * Description : This will create radio button values for Bill-To,Ship-To.
    * Return Type : List<selectOption>.
    * Parameters : None.
    ***********/
    public List<SelectOption> getradioOptions3() {
        List<SelectOption> options = new List<SelectOption>();
        if(disableL1){
            options.add(new SelectOption('CHILD','CHILD'));
        }else
        if(disableL2){
            options.add(new SelectOption('CHILD','CHILD')); 
            options.add(new SelectOption('L1','L1'));
        }else {
        options.add(new SelectOption('CHILD','CHILD')); 
        options.add(new SelectOption('L1','L1')); 
        options.add(new SelectOption('L2','L2')); 
        }
        return options;
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
        if(queryAccID != null && queryAccID != ''){
            accntIds.add((ID)queryAccID);
        }
        if(accntCurrent == null && (accntIds == null || accntIds.size() < 0)){ 
            accntIds.add(queryAccId);
        }else {
            accntIds.add(accntCurrent.Id);
        }        
        for(Account oAcc : [Select Id,Name,ZTS_US_NARC_ID__c, ParentId, Parent.Name from Account where Id IN: accntIds AND ZTS_EU_Market__c = 'United States']){            
            mapAccntIdAccntName.put(oAcc.Id,oAcc.Name);
            mapAccntIdNarcId.put(oAcc.Id,oAcc.ZTS_US_NARC_ID__c);
        }
        createQueryStr();
        
        // Apply filters only when Product Sales or Unit Sales tab is selected
        if(selectedReport == 'UnitSales' || selectedReport == 'ProductSales'){
            if((selectedTherapeuticGrp != null && selectedTherapeuticGrp != '') || (selectedProduct != null && selectedProduct != '') || (selectedSpecies != null && selectedSpecies != '')){
                if(selectedTherapeuticGrp != '<Therapeutic Group>'){                
                    soqlQuery+= 'AND ZTS_EU_Therapeutic_Group__c =: selectedTherapeuticGrp ';
                }
                if(selectedProduct != '<Product>'){

                    soqlQuery+= 'AND ZTS_EU_Brand__c =: selectedProduct ';
                }
                if(selectedSpecies != '<Species>'){
                    soqlQuery+= 'AND ZTS_EU_Species__c =: selectedSpecies ';
                }           
            }
            /*if Preset is selected, then apply these filters */
            if(selectedPreset != '--None--'){
                salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Species__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                
                selectedBillToShipTo = salesPresets.ZTS_EU_Selected_GLR_Type__c;
                selectedMATYTD = salesPresets.ZTS_EU_Selected_Preferred_Time__c;
            
                if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c != Null)
                selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                if(salesPresets.ZTS_EU_Selected_Preferred_Brands__c != Null)
                selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                if(salesPresets.ZTS_EU_Selected_Preferred_Species__c != Null)
                selectedMultiSpecies = salesPresets.ZTS_EU_Selected_Preferred_Species__c.split(';');
                if(selectedMultiTherapeuticGrp != Null && selectedMultiTherapeuticGrp.size()>0)
                selectedMultiTherapeuticGrpOpt = listSelOptPopulate(selectedMultiTherapeuticGrp);
                if(selectedMultiProduct != Null && selectedMultiProduct.size()>0)
                selectedMultiProductOpt = listSelOptPopulate(selectedMultiProduct);
                if(selectedMultiSpecies != Null && selectedMultiSpecies.size()>0)
                selectedMultiSpeciesOpt = listSelOptPopulate(selectedMultiSpecies);
               
                if(!(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c == Null || salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c == '')){                    
                    selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                    soqlQuery+= 'AND ZTS_EU_Therapeutic_Group__c IN: selectedMultiTherapeuticGrp ';
                }
                if(!(salesPresets.ZTS_EU_Selected_Preferred_Brands__c == Null || salesPresets.ZTS_EU_Selected_Preferred_Brands__c == '')){
                    selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                    soqlQuery+= 'AND ZTS_EU_Brand__c IN: selectedMultiProduct ';
                }
                if(!(salesPresets.ZTS_EU_Selected_Preferred_Species__c == Null || salesPresets.ZTS_EU_Selected_Preferred_Species__c == '')){
                    selectedMultiSpecies = salesPresets.ZTS_EU_Selected_Preferred_Species__c.split(';');
                    soqlQuery+= 'AND ZTS_EU_Species__c IN: selectedMultiSpecies ';
                }               
            }
        }
        
        prodLevel = new List<String>();
        System.debug('--1--'+selectedReport);
        if(selectedReport == 'UnitSales'){
            prodLevel.add('Item');
            if(!soqlQuery.contains('prodLevel')){
                soqlQuery+='AND ZTS_US_Product_Level__c IN: prodLevel ';
            }
            soqlQuery+= ' AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
            //soqlQuery += ' and ZTS_US_Aggregated__c = \''+selectedLevelValue+'\' ';
        }else if(selectedReport == 'ProductSales'){
            prodLevel.add('Product');
            if(!soqlQuery.contains('prodLevel')){
                soqlQuery+='AND ZTS_US_Product_Level__c IN: prodLevel ';
            }
            soqlQuery+= ' AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
           // soqlQuery += ' and ZTS_US_Aggregated__c = \''+selectedLevelValue+'\' ';
                
        }else if(selectedReport == 'TotalSales'){
            prodLevel.add('Account');
            if(!soqlQuery.contains('prodLevel')){
                soqlQuery+='AND ZTS_US_Product_Level__c IN: prodLevel ';
            }
            soqlQuery+= ' AND ZTS_EU_Account__r.Name = \''+String.escapeSingleQuotes(selectedAccnt)+'\' ';
            //soqlQuery += ' and ZTS_US_Aggregated__c = \''+selectedLevelValue+'\' ';
        }        
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        soqlQuery+= 'ORDER BY '+sortFullExp;
        List<ZTS_EU_Sales__c> listQuerySalesData = Database.query(soqlQuery);
        for(ZTS_EU_Sales__c listSalesData : listQuerySalesData){
            if(mapAccntIdlistSalesData.containsKey(listSalesData.ZTS_EU_Account__c)){
                mapAccntIdlistSalesData.get(listSalesData.ZTS_EU_Account__c).add(listSalesData);
            }
            else{
                mapAccntIdlistSalesData.put(listSalesData.ZTS_EU_Account__c,new List<ZTS_EU_Sales__c>{listSalesData});
            }
            System.debug('--2--'+selectedReport);   
        }
        System.debug('--3--'+selectedReport);   
        Decimal month1Sum = 0;
        List<Decimal> month2Sum = new List<Decimal>();
        List<Decimal> month3Sum = new List<Decimal>();
        List<Decimal> month4Sum = new List<Decimal>();
        List<Decimal> month5Sum = new List<Decimal>();
        List<Decimal> month6Sum = new List<Decimal>();
        List<Decimal> month7Sum = new List<Decimal>();
        List<Decimal> month8Sum = new List<Decimal>();
        List<Decimal> month9Sum = new List<Decimal>();
        List<Decimal> month10Sum = new List<Decimal>();
        List<Decimal> month11Sum = new List<Decimal>();
        List<Decimal> month12Sum = new List<Decimal>();
        List<Decimal> monthTotalSum = new List<Decimal>();
        Map<String, Decimal> currentSumMap = new Map<String,Decimal>();
        Map<String, Decimal> prevSumMap = new Map<String, Decimal>();
        Map<String, Decimal> diffSumMap = new Map<String, Decimal>();
        
        
        for(Id oaccntId : mapAccntIdlistSalesData.keySet()){
        System.debug('--4--'+selectedReport);
            String accName ;            
            String accId ;
            String narcId;
            CustomSettSalesData oCustomSettSalesData;
            Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
            Map<String, List<String>> monthValueMapMAT = new Map<String, List<String>>();
            Map<String, List<Double>> mapSalesDataTotal = new Map<String, List<Double>>();
            mapSalesDataTotal.put('Current Year', null);
            mapSalesDataTotal.put('Previous Year', null);
            mapSalesDataTotal.put('$Diff Sales', null);
            mapSalesDataTotal.put('%Diff Sales', null);
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
            System.debug('mpadata----------'+mapAccntIdlistSalesData.get(oaccntId));
            System.debug('--5--'+selectedReport);
            for(ZTS_EU_Sales__c osalesData : mapAccntIdlistSalesData.get(oaccntId)){
               System.debug('--6--'+selectedReport);
                //if UnitSales tab is selected
                if(selectedReport == 'UnitSales'){
                    List<String> oaccntSalesData1a = new List<String>{String.valueOf(osalesData.ZTS_EU_Therapeutic_Group__c)};
                    List<String> oaccntSalesData1b = new List<String>{String.valueOf(osalesData.ZTS_EU_Brand__c)};
                    List<String> oaccntSalesData1c = new List<String>{String.valueOf(osalesData.ZTS_EU_Product_Line_Item__c)};
                    List<String> oaccntSalesData1 = new List<String>{'Current Year','Previous Year'};
                    List<String> oaccntSalesData2;
                    if(selectedMATYTD == 'YTD'){
                        oaccntSalesData2 = new List<String>{String.valueOf(osalesData.ZTS_EU_Total_CYTD_Units__c),String.valueOf(osalesData.ZTS_EU_Total_PYTD_Units__c)};
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
                        oaccntSalesData2 = new List<String>{String.valueOf(osalesData.ZTS_EU_Total_MAT_Current_Units__c),String.valueOf(osalesData.ZTS_EU_Total_MAT_Prior_Units__c)};
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
                    month1Sum += osalesData.ZTS_EU_01_Current_Units__c;                   
                    
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
                    
                    List<String> oaccntSalesData3 = new List<String>{String.valueOf(osalesData.ZTS_EU_01_Current_Units__c),String.valueOf(osalesData.ZTS_EU_01_Previous_Units__c)};
                    List<String> oaccntSalesData4 = new List<String>{String.valueOf(osalesData.ZTS_EU_02_Current_Units__c),String.valueOf(osalesData.ZTS_EU_02_Previous_Units__c)};
                    List<String> oaccntSalesData5 = new List<String>{String.valueOf(osalesData.ZTS_EU_03_Current_Units__c),String.valueOf(osalesData.ZTS_EU_03_Previous_Units__c)};
                    List<String> oaccntSalesData6 = new List<String>{String.valueOf(osalesData.ZTS_EU_04_Current_Units__c),String.valueOf(osalesData.ZTS_EU_04_Previous_Units__c)};
                    List<String> oaccntSalesData7 = new List<String>{String.valueOf(osalesData.ZTS_EU_05_Current_Units__c),String.valueOf(osalesData.ZTS_EU_05_Previous_Units__c)};
                    List<String> oaccntSalesData8 = new List<String>{String.valueOf(osalesData.ZTS_EU_06_Current_Units__c),String.valueOf(osalesData.ZTS_EU_06_Previous_Units__c)};
                    List<String> oaccntSalesData9 = new List<String>{String.valueOf(osalesData.ZTS_EU_07_Current_Units__c),String.valueOf(osalesData.ZTS_EU_07_Previous_Units__c)};
                    List<String> oaccntSalesData10 = new List<String>{String.valueOf(osalesData.ZTS_EU_08_Current_Units__c),String.valueOf(osalesData.ZTS_EU_08_Previous_Units__c)};
                    List<String> oaccntSalesData11 = new List<String>{String.valueOf(osalesData.ZTS_EU_09_Current_Units__c),String.valueOf(osalesData.ZTS_EU_09_Previous_Units__c)};
                    List<String> oaccntSalesData12 = new List<String>{String.valueOf(osalesData.ZTS_EU_10_Current_Units__c),String.valueOf(osalesData.ZTS_EU_10_Previous_Units__c)};
                    List<String> oaccntSalesData13 = new List<String>{String.valueOf(osalesData.ZTS_EU_11_Current_Units__c),String.valueOf(osalesData.ZTS_EU_11_Previous_Units__c)};
                    List<String> oaccntSalesData14 = new List<String>{String.valueOf(osalesData.ZTS_EU_12_Current_Units__c),String.valueOf(osalesData.ZTS_EU_12_Previous_Units__c)};
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1c,oaccntSalesData1,oaccntSalesData2);
                    listAccntSalesDataValue.add(oAccntSalesDV);
                    
                    //Added by Sohil Shah for DEF-001246
                    integer j = salesDateCustSett.ZTS_US_Date__c.month();
                    monthList_MAT = new List<String>();  
                    if(selectedMATYTD == 'MAT' || selectedMATYTD == 'YTD'){
                        
                        for(Integer i = j; i >0 ;i --)
                        {
                            String colMnthName = mapNoMonth.get(String.Valueof(i));
                            monthList_MAT.add(colMnthName);
                            if(i==1)
                            {
                                for(Integer k = 12; k>j ;k--){
                                    String colMnthName1 = mapNoMonth.get(String.Valueof(k));                                
                                    monthList_MAT.add(colMnthName1);
                                }
                            }   
                        }
                    }
                    
                    monthNoName = new Map<Integer,String>();
                    mapUnitSalesMAT = new Map<String, List<String>>();
                    mapUnitSalesYTD = new Map<String,List<String>>();
                    mapUnitSalesYTD.put('1a',oaccntSalesData1a);
                    mapUnitSalesYTD.put('1b',oaccntSalesData1b);
                    mapUnitSalesYTD.put('1c',oaccntSalesData1c);
                    mapUnitSalesYTD.put('1d',oaccntSalesData1);
                    mapUnitSalesYTD.put('1e',oaccntSalesData2);                    
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        monthNoName.put(i,monthList_MAT[i]);      
                    }                 
                    for(Integer i: monthNoName.keyset())
                    {   
                        if(i==0)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData3);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData3);
                        }
                        if(i==1)
                        {
                             mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData4);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData4);
                        }
                        if(i==2)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData5);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData5);                      
                        }
                        if(i==3)
                        {                               
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData6);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData6);
                        }
                        if(i==4)
                        {
                           mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData7);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData7);   
                        }
                        if(i==5)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData8);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData8);
                        }
                        if(i==6)
                        {
                           mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData9);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData9);
                        }   
                        if(i==7)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData10);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData10);                        
                        }
                        if(i==8)
                        {
                           mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData11);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData11);
                        }
                        if(i==9)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData12);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData12);  
                        }
                        if(i==10)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData13);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData13); 
                        }
                        if(i==11)
                        {
                            mapUnitSalesMAT.put(monthNoName.get(i),oaccntSalesData14);
                            mapUnitSalesYTD.put(monthNoName.get(i),oaccntSalesData14);  
                        }                                               
                    }
                    
                        
                    System.debug('tempMonthList-Size------'+tempMonthList.Size());
                    //EOC by Sohil Shah for DEF-001246
                    if(selectedMATYTD == 'YTD'){
                        listdataYTD = new List<dataYTD>();
                        dataYTD odataYTD;                       
                        monthList = new List<String>();   
                        for(Integer i=0;i<monthList_MAT.size();i++)
                        {
                            String colMnthName = monthList_MAT[i];
                            
                                List<String> colValues = mapUnitSalesMAT.get(monthNoName.get(i));
                                odataYTD = new dataYTD(colMnthName,colValues);
                                if(monthValueMap.containsKey(colMnthName)){
                                List<String> values = monthValueMap.get(colMnthName);
                                values.addAll(colValues);
                                monthValueMap.remove(colMnthName);
                                monthValueMap.put(colMnthName,values);
                                }else{
                                    monthValueMap.put(colMnthName,colValues);
                                }
                                listdataYTD.add(odataYTD);                                                                                 
                        }
                        
                        // Added on 10th jun by sohil
                        System.debug('salesDateCustSett.ZTS_US_Date__c.month()+1----'+salesDateCustSett.ZTS_US_Date__c.month()+1);
                        
                        for(Integer i = salesDateCustSett.ZTS_US_Date__c.month()+1; i <= 12 ;i ++){
                            List<String> colValues = new List<String>();
                            String colMnthName = mapNoMonth.get(String.Valueof(i));
                            if(monthValueMap.containsKey(colMnthName)){
                                //List<String> values = monthValueMap.get(colMnthName);
                                List<String> values = new List<String>();
                                values.addAll(colValues);                               
                                monthValueMap.remove(colMnthName);                              
                                monthValueMap.put(colMnthName,values);
                            }else{
                                monthValueMap.put(colMnthName,colValues);
                            }
                           // monthList_MAT.add(colMnthName);
                           
                          
                        }
                        
                           System.debug('monthValueMap-Size---Y---'+monthValueMap.Size());  
                        
                        
                        
                    }
                    
                
                        
                    //Added by Sohil Shah for DEF-001246                           
                       if(selectedMATYTD == 'MAT'){
                           //monthValueMap = tempMap;
                            listdataMAT = new List<dataMAT>();
                            for(Integer i=0;i<monthList_MAT.size();i++)
                            {
                                String colMnthName = monthList_MAT[i];
                                System.debug('colMnthName--------'+colMnthName);    
                                List<String> colValues = mapUnitSalesMAT.get(monthNoName.get(i));
                                System.debug('colValues------'+colValues);  
                                dataMAT odataMAT = new dataMAT(colMnthName,colValues);
                                if(monthValueMapMAT.containsKey(colMnthName)){
                                    System.debug('contains--------');
                                List<String> values = new List<String>();
                                values = monthValueMapMAT.get(colMnthName);
                                System.debug('values--------'+values);
                                if(colValues != null)
                                {
                                     values.addAll(colValues);
                                }
                               
                                monthValueMapMAT.remove(colMnthName);
                                monthValueMapMAT.put(colMnthName,values);
                                }else{
                                    monthValueMapMAT.put(colMnthName,colValues);
                                }
                                listdataMAT.add(odataMAT);
                            }                   
                    }                    
                    //EOC  by Sohil Shah for DEF-001246
                }
                //if TotalSales tab is selected
                else if(selectedReport == 'TotalSales'){                
                    // new code added
                    List<Double> listIntCurrent = mapSalesDataTotal.get('Current Year');
                    List<Double> listIntPrior = mapSalesDataTotal.get('Previous Year');
                    List<Double> listIntDollDiff = mapSalesDataTotal.get('$Diff Sales');
                    List<Double> listIntPerDiff = mapSalesDataTotal.get('%Diff Sales');
                    //Double intCurrent = osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                    //Double intPrior = osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                    //Double intDollDiff = osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                     //Double intPerDiff = osalesData.ZTS_EU_Total_MAT_P_Diff_Sales__c;
                     /*
                     DEF - 001695 - Sohil Shah   
                     */
                    Double intCurrent = osalesData.ZTS_US_Total_MAT_52_Current_Sales__c;         
                    Double intPrior = osalesData.ZTS_US_Total_MAT_52_Prior_Sales__c;               
                    Double intDollDiff = osalesData.ZTS_US_Total_MAT_52_Diff_Sales__c;                
                    Double intPerDiff = osalesData.ZTS_US_Total_MAT_52_P_Diff_Sales__c;
                    // EOC - DEF-001695 - Sohil Shah    
                    
                    //Added by Sohil Shah for DEF-001246
                    if((selectedMATYTD == 'MAT') || (selectedMATYTD == 'YTD')){
                        integer j = salesDateCustSett.ZTS_US_Date__c.month();
                        monthList_MAT = new List<String>(); 
                       
                        for(Integer i = j; i >0 ;i --)
                        {
                            String colMnthName = mapNoMonth.get(String.Valueof(i));
                            monthList_MAT.add(colMnthName);
                            
                            if(i==1)
                            {
                                for(Integer k = 12; k>j ;k--){
                                    String colMnthName1 = mapNoMonth.get(String.Valueof(k));                                
                                    monthList_MAT.add(colMnthName1);
                                }
                            }   
                        }
                    }
                    //EOC Added by Sohil Shah for DEF-001246
                    
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
                    mapSalesDataTotal.put('Current Year',listIntCurrent);              
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
                    mapSalesDataTotal.put('Previous Year',listIntPrior);              
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
                    mapSalesDataTotal.put('$Diff Sales',listIntDollDiff);               
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
                    mapSalesDataTotal.put('%Diff Sales',listIntPerDiff);
                }
                //if ProductSales tab is selected
                else if(selectedReport == 'ProductSales'){
                    List<String> oaccntSalesData1a = new List<String>{String.valueOf(osalesData.ZTS_EU_Therapeutic_Group__c)};
                    List<String> oaccntSalesData1b = new List<String>{String.valueOf(osalesData.ZTS_EU_Brand__c)};
                    List<String> oaccntSalesData1 = new List<String>{'Current Year','Previous Year','$Diff Sales'};
                    List<String> oaccntSalesData2;
                    if(selectedMATYTD == 'YTD'){
                        oaccntSalesData2 = new List<String>{String.valueOf(osalesData.ZTS_EU_Total_CYTD_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_Total_PYTD_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_Total_YTD_Diff_Sales__c.format())};
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
                         //oaccntSalesData2 = new List<String>{String.valueOf(osalesData.ZTS_EU_Total_MAT_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_Total_MAT_Prior_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_Total_MAT_Diff_Sales__c.format())};
                        // DEF - 001695 - Sohil Shah
                       oaccntSalesData2 = new List<String>{String.valueOf(osalesData.ZTS_US_Total_MAT_52_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_US_Total_MAT_52_Prior_Sales__c.format()),String.valueOf(osalesData.ZTS_US_Total_MAT_52_Diff_Sales__c.format())}; 
                        if(!currentSumMap.containsKey('total') && !prevSumMap.containsKey('total') && !diffSumMap.containsKey('total')){
                            /*currentSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Current_Sales__c);
                            prevSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Prior_Sales__c);
                            diffSumMap.put('total',osalesData.ZTS_EU_Total_MAT_Diff_Sales__c);
                            */
                            /*DEF - 001695 - Sohil Shah
                            */
                            currentSumMap.put('total',osalesData.ZTS_US_Total_MAT_52_Current_Sales__c);
                            prevSumMap.put('total',osalesData.ZTS_US_Total_MAT_52_Prior_Sales__c);
                            diffSumMap.put('total',osalesData.ZTS_US_Total_MAT_52_Diff_Sales__c);
                        }else{
                            /*
                            Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Current_Sales__c;
                            Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Prior_Sales__c;
                            Decimal diffVal = diffSumMap.get('total') + osalesData.ZTS_EU_Total_MAT_Diff_Sales__c;
                            */
                            Decimal currVal = currentSumMap.get('total') + osalesData.ZTS_US_Total_MAT_52_Current_Sales__c;
                            Decimal prevVal = prevSumMap.get('total') + osalesData.ZTS_US_Total_MAT_52_Prior_Sales__c;
                            Decimal diffVal = diffSumMap.get('total') + osalesData.ZTS_US_Total_MAT_52_Diff_Sales__c;
                            // EOC DEF-001695 - Sohil Shah
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
                    
    
                    List<String> oaccntSalesData3 = new List<String>{String.valueOf(osalesData.ZTS_EU_01_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_01_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_01_Diff_Sales__c.format())};
                    List<String> oaccntSalesData4 = new List<String>{String.valueOf(osalesData.ZTS_EU_02_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_02_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_02_Diff_Sales__c.format())};
                    List<String> oaccntSalesData5 = new List<String>{String.valueOf(osalesData.ZTS_EU_03_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_03_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_03_Diff_Sales__c.format())};
                    List<String> oaccntSalesData6 = new List<String>{String.valueOf(osalesData.ZTS_EU_04_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_04_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_04_Diff_Sales__c.format())};
                    List<String> oaccntSalesData7 = new List<String>{String.valueOf(osalesData.ZTS_EU_05_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_05_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_05_Diff_Sales__c.format())};
                    List<String> oaccntSalesData8 = new List<String>{String.valueOf(osalesData.ZTS_EU_06_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_06_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_06_Diff_Sales__c.format())};
                    List<String> oaccntSalesData9 = new List<String>{String.valueOf(osalesData.ZTS_EU_07_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_07_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_07_Diff_Sales__c.format())};
                    List<String> oaccntSalesData10 = new List<String>{String.valueOf(osalesData.ZTS_EU_08_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_08_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_08_Diff_Sales__c.format())};
                    List<String> oaccntSalesData11 = new List<String>{String.valueOf(osalesData.ZTS_EU_09_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_09_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_09_Diff_Sales__c.format())};
                    List<String> oaccntSalesData12 = new List<String>{String.valueOf(osalesData.ZTS_EU_10_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_10_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_10_Diff_Sales__c.format())};
                    List<String> oaccntSalesData13 = new List<String>{String.valueOf(osalesData.ZTS_EU_11_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_11_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_11_Diff_Sales__c.format())};
                    List<String> oaccntSalesData14 = new List<String>{String.valueOf(osalesData.ZTS_EU_12_Current_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_12_Previous_Sales__c.format()),String.valueOf(osalesData.ZTS_EU_12_Diff_Sales__c.format())};
                    oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1a,oaccntSalesData1b,oaccntSalesData1,oaccntSalesData2,monthList_MAT,monthNoName,selectedMATYTD);
                    listAccntSalesDataValue.add(oAccntSalesDV);
                    //Added by Sohil Shah for DEF-001246
                        monthNoName = new Map<Integer,String>();
                        mapProdSalesMAT = new Map<String, List<String>>();
                        mapProdSalesYTD = new Map<String,List<String>>();
                        mapProdSalesYTD.put('1a1',oaccntSalesData1a);
                        mapProdSalesYTD.put('1a',oaccntSalesData1b);
                        mapProdSalesYTD.put('1b',oaccntSalesData1);
                        mapProdSalesYTD.put('1c',oaccntSalesData2);
                        for(Integer i=0;i<monthList_MAT.size();i++)
                        {
                            monthNoName.put(i,monthList_MAT[i]);  
                        }
                         for(Integer i: monthNoName.keyset())
                        {   
                            if(i==0)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData3);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData3);
                            }
                            if(i==1)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData4);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData4);
                            }
                            if(i==2)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData5);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData5);
                            }
                            if(i==3)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData6);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData6);
                            }
                           if(i==4)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData7);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData7);
                            }
                            if(i==5)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData8);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData8);
                            }
                           if(i==6)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData9);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData9);
                            } 
                           if(i==7)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData10);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData10);
                            }
                            if(i==8)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData11);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData11);
                            }
                            if(i==9)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData12);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData12);
                            }
                            if(i==10)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData13);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData13);
                            }
                           if(i==11)
                            {
                                mapProdSalesMAT.put(monthNoName.get(i),oaccntSalesData14);
                                mapProdSalesYTD.put(monthNoName.get(i),oaccntSalesData14);
                            }                              
                        }
                        
                    //EOC by Sohil Shah for DEF-001246
                    if(selectedMATYTD == 'YTD'){
                        listdataYTD = new List<dataYTD>();                      
                        dataYTD odataYTD;
                        monthList = new List<String>();  
                        for(Integer i=0;i<monthList_MAT.size();i++)
                        {
                            String colMnthName = monthList_MAT[i];
                            List<String> colValues = mapProdSalesMAT.get(monthNoName.get(i));
                            odataYTD = new dataYTD(colMnthName,colValues);
                            if(monthValueMap.containsKey(colMnthName)){
                            List<String> values = monthValueMap.get(colMnthName);
                            values.addAll(colValues);
                            monthValueMap.remove(colMnthName);
                            monthValueMap.put(colMnthName,values);
                            }else{
                                monthValueMap.put(colMnthName,colValues);
                            }
                            listdataYTD.add(odataYTD);
                        }
                    for(Integer i = salesDateCustSett.ZTS_US_Date__c.month()+1; i <= 12 ;i ++){
                        List<String> colValues = new List<String>();
                        String colMnthName = mapNoMonth.get(String.Valueof(i));
                        if(monthValueMap.containsKey(colMnthName)){
                            //List<String> values = monthValueMap.get(colMnthName);
                            List<String> values = new List<String>();
                            values.addAll(colValues);
                            monthValueMap.remove(colMnthName);
                            monthValueMap.put(colMnthName,values);
                        }else{
                            monthValueMap.put(colMnthName,colValues);
                        }
                       // monthList_MAT.add(colMnthName);
                    }
    
                            
                    }
                    
                    // Added by Sohil Shah for DEF-001246
                if(selectedMATYTD == 'MAT')
                {                                         
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        String colMnthName = monthList_MAT[i];
                        List<String> colValues = mapProdSalesMAT.get(monthNoName.get(i));
                        dataMAT odataMAT = new dataMAT(colMnthName,colValues);
                        if(monthValueMapMAT.containsKey(colMnthName)){
                        List<String> values = monthValueMapMAT.get(colMnthName);
                        values.addAll(colValues);
                        monthValueMapMAT.remove(colMnthName);
                        monthValueMapMAT.put(colMnthName,values);
                        }else{
                            monthValueMapMAT.put(colMnthName,colValues);
                        }
                        listdataMAT.add(odataMAT);
                    }                              
                }
            // EOC by Sohil Shah for DEF-001246
                }               
            }
            if(selectedReport == 'TotalSales'){
                List<String> listStr = new List<String>{'Current Year','Previous Year','$Diff Sales','%Diff Sales'};
                for(String oStr : listStr){
                        String preStrAppend = '$';
                        String postStrAppend = '';
                        oaccntSalesData1total.add(oStr);
                        if(oStr == '%Diff Sales'){
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
                    //Added by Sohil Shah for DEF-001246
                if(selectedMATYTD == 'YTD'){
                    listdataYTD = new List<dataYTD>();
                    mapTotalSalesYTD = new Map<String,List<String>>();
                    mapTotalSalesYTD.put('1a',oaccntSalesData1total);
                    mapTotalSalesYTD.put('1b',oaccntSalesData2total);  
                    dataYTD odataYTD;     
                    monthNoName = new Map<Integer,String>();                  
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        monthNoName.put(i,monthList_MAT[i]);
                        
                    }
                    for(Integer i: monthNoName.keyset())
                    {   
                        if(i==0)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData3total);
                        }
                       if(i==1)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData4total);
                        }
                        if(i==2)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData5total);
                        }
                        if(i==3)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData6total);
                        }
                        if(i==4)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData7total);
                        }
                        if(i==5)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData8total);
                        }
                        if(i==6)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData9total);
                        }  
                        if(i==7)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData10total);
                        }
                        if(i==8)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData11total);
                        }
                        if(i==9)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData12total);
                        }
                        if(i==10)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData13total);
                        }
                        if(i==11)
                        {                           
                            mapTotalSalesYTD.put(monthNoName.get(i),oaccntSalesData14total);
                        }                                               
                    }
                    //EOC Added by Sohil Shah for DEF-001246
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        String colMnthName = monthList_MAT[i];
                        List<String> colValues = mapTotalSalesYTD.get(monthNoName.get(i));                      
                        odataYTD = new dataYTD(colMnthName,colValues);
                        if(monthValueMap.containsKey(colMnthName)){
                        List<String> values = monthValueMap.get(colMnthName);
                        values.addAll(colValues);
                        monthValueMap.remove(colMnthName);
                        monthValueMap.put(colMnthName,values);
                        }else{
                            monthValueMap.put(colMnthName,colValues);
                        }
                        listdataYTD.add(odataYTD);
                    }
                    for(Integer i = salesDateCustSett.ZTS_US_Date__c.month()+1; i <= 12 ;i ++){
                        List<String> colValues = new List<String>();
                        String colMnthName = mapNoMonth.get(String.Valueof(i));
                        if(monthValueMap.containsKey(colMnthName)){
                            //List<String> values = monthValueMap.get(colMnthName);
                            List<String> values = new List<String>();
                            values.addAll(colValues);
                            monthValueMap.remove(colMnthName);
                            monthValueMap.put(colMnthName,values);
                        }else{
                            monthValueMap.put(colMnthName,colValues);
                        }
                       // monthList_MAT.add(colMnthName);
                    }
                        
                }
                oAccntSalesDV = new ActualSalesDataValue(oaccntSalesData1total,oaccntSalesData2total);
                listAccntSalesDataValue.add(oAccntSalesDV);
                
            // Added by Sohil Shah for DEF-001246
                if(selectedMATYTD == 'MAT')
                {   
                    
                    listdataMAT = new List<dataMAT>();                 
                    monthNoName = new Map<Integer,String>();                                    
                    mapTotalSalesMAT = new Map<String, List<String>>();
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        monthNoName.put(i,monthList_MAT[i]);
                         
                    }              
                    for(Integer i: monthNoName.keyset())
                    {   
                        if(i==0)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData3total);
                        }
                       if(i==1)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData4total);
                        }
                        if(i==2)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData5total);
                        }
                        if(i==3)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData6total);
                        }
                        if(i==4)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData7total);
                        }
                        if(i==5)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData8total);
                        }
                        if(i==6)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData9total);
                        }  
                        if(i==7)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData10total);
                        }
                        if(i==8)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData11total);
                        }
                        if(i==9)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData12total);
                        }
                        if(i==10)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData13total);
                        }
                        if(i==11)
                        {                           
                            mapTotalSalesMAT.put(monthNoName.get(i),oaccntSalesData14total);
                        }                                                 
                    }
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        String colMnthName = monthList_MAT[i];                      
                        List<String> colValues = mapTotalSalesMAT.get(monthNoName.get(i));                  
                        dataMAT odataMAT = new dataMAT(colMnthName,colValues);
                        if(monthValueMapMAT.containsKey(colMnthName)){
                        List<String> values = monthValueMapMAT.get(colMnthName);
                        values.addAll(colValues);
                        monthValueMapMAT.remove(colMnthName);
                        monthValueMapMAT.put(colMnthName,values);
                        }else{
                            monthValueMapMAT.put(colMnthName,colValues);
                        }
                        listdataMAT.add(odataMAT);
                    }                             
            }
            // EOC  by Sohil Shah for DEF-001246
            
            }
            if(selectedMATYTD == 'YTD'){
                oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue,listdataYTD);
                oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue,monthValueMap);
            }
            else {
                oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,listAccntSalesDataValue,listdataMAT);
                oCustomSettSalesData  = new CustomSettSalesData(narcId,accId,accName,monthValueMapMAT,listAccntSalesDataValue);
            }
            listCustomSettSalesData.add(oCustomSettSalesData);
        }
        if(listQuerySalesData != Null && listQuerySalesData.size()>0){
        // my code here for total
        if(selectedReport == 'UnitSales'){            
            List<String> oaccntSalesData1 = new List<String>{'Total CY','Total PY'};            
            CustomSettSalesData oCustomSettSalesData;
            listdataYTD = new List<dataYTD>();
            listdataMAT = new List<dataMAT>();
            Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
            Map<String, List<String>> monthValueMapMAT = new Map<String, List<String>>();
            
            ActualSalesDataValue oAccntSalesDV = new ActualSalesDataValue(null,null,null,oaccntSalesData1,new List<String>{String.valueOf(currentSumMap.get('total')),String.valueOf(prevSumMap.get('total'))});
            listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
            //Added by Sohil Shah for DEF-001246
            monthNoName = new Map<Integer,String>();
            for(Integer i=0;i<monthList_MAT.size();i++)
            {
                monthNoName.put(i,monthList_MAT[i]);                
            }          
                for(Integer i: monthNoName.keyset())
                {   
                    if(i==0)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('1')),String.valueOf(prevSumMap.get('1'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('1')),String.valueOf(prevSumMap.get('1'))});
                    }
                     if(i==1)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('2')),String.valueOf(prevSumMap.get('2'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('2')),String.valueOf(prevSumMap.get('2'))});
                    }
                     if(i==2)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('3')),String.valueOf(prevSumMap.get('3'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('3')),String.valueOf(prevSumMap.get('3'))});
                    }
                     if(i==3)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('4')),String.valueOf(prevSumMap.get('4'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('4')),String.valueOf(prevSumMap.get('4'))});
                    }
                     if(i==4)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('5')),String.valueOf(prevSumMap.get('5'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('5')),String.valueOf(prevSumMap.get('5'))});
                    }
                     if(i==5)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('6')),String.valueOf(prevSumMap.get('6'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('6')),String.valueOf(prevSumMap.get('6'))});
                    }
                     if(i==6)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('7')),String.valueOf(prevSumMap.get('7'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('7')),String.valueOf(prevSumMap.get('7'))});
                    }
                    if(i==7)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('8')),String.valueOf(prevSumMap.get('8'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('8')),String.valueOf(prevSumMap.get('8'))});
                    }
                     if(i==8)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('9')),String.valueOf(prevSumMap.get('9'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('9')),String.valueOf(prevSumMap.get('9'))});
                    }
                    if(i==9)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('10')),String.valueOf(prevSumMap.get('10'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('10')),String.valueOf(prevSumMap.get('10'))});
                    }
                    if(i==10)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('11')),String.valueOf(prevSumMap.get('11'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('11')),String.valueOf(prevSumMap.get('11'))});
                    }
                     if(i==11)
                    {
                        mapUnitSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('12')),String.valueOf(prevSumMap.get('12'))});
                        
                        mapUnitSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('12')),String.valueOf(prevSumMap.get('12'))});
                    }                                            
                }
                
            if(selectedMATYTD == 'YTD'){
                 for(Integer i=0;i<monthList_MAT.size();i++)
                {
                    String colMnthName = monthList_MAT[i];
                    List<String> colValues = mapUnitSalesMAT.get(monthNoName.get(i));
                    dataYTD odataYTD = new dataYTD(colMnthName,colValues);
                    if(monthValueMap.containsKey(colMnthName)){
                    List<String> values = monthValueMap.get(colMnthName);
                    values.addAll(colValues);
                    monthValueMap.remove(colMnthName);
                    monthValueMap.put(colMnthName,values);
                    }else{
                        monthValueMap.put(colMnthName,colValues);
                    }
                    listdataYTD.add(odataYTD);
                } 
                // Added on 10th jun by sohil
                        System.debug('salesDateCustSett.ZTS_US_Date__c.month()+1----'+salesDateCustSett.ZTS_US_Date__c.month()+1);
                        
                        for(Integer i = salesDateCustSett.ZTS_US_Date__c.month()+1; i <= 12 ;i ++){
                            List<String> colValues = new List<String>();
                            String colMnthName = mapNoMonth.get(String.Valueof(i));
                            if(monthValueMap.containsKey(colMnthName)){
                                //List<String> values = monthValueMap.get(colMnthName);
                                List<String> values = new List<String>();
                                values.addAll(colValues);                               
                                monthValueMap.remove(colMnthName);                              
                                monthValueMap.put(colMnthName,values);
                            }else{
                                monthValueMap.put(colMnthName,colValues);
                            }
                           // monthList_MAT.add(colMnthName);
                           
                          
                        }
                        System.debug('monthValueMap-Size---Y---'+monthValueMap.Size());
                           System.debug('monthValueMap-Size---Y---'+monthValueMap.Size());  
                        
                        
                oCustomSettSalesData = new CustomSettSalesData('', '', '', listAccntSalesDataValue, listdataYTD);
                oCustomSettSalesData  = new CustomSettSalesData('','','',listAccntSalesDataValue, monthValueMap);
            }else{
                            
                            for(Integer i=0;i<monthList_MAT.size();i++)
                            {
                                String colMnthName = monthList_MAT[i];
                                List<String> colValues = mapUnitSalesMAT.get(monthNoName.get(i));
                                dataMAT odataMAT = new dataMAT(colMnthName,colValues);
                                if(monthValueMapMAT.containsKey(colMnthName)){
                                List<String> values = monthValueMapMAT.get(colMnthName);
                                values.addAll(colValues);
                                monthValueMapMAT.remove(colMnthName);
                                monthValueMapMAT.put(colMnthName,values);
                                }else{
                                    monthValueMapMAT.put(colMnthName,colValues);
                                }
                                listdataMAT.add(odataMAT);
                            }       
              //EOC by Sohil Shah for DEF-001246
            
            
                oCustomSettSalesData = new CustomSettSalesData(null,null,null,listAccntSalesDataValue,listdataMAT);
                oCustomSettSalesData = new CustomSettSalesData(null,null,null,monthValueMapMAT,listAccntSalesDataValue);
            }
            if(listCustomSettSalesData != null && listCustomSettSalesData.size() > 0){
                listCustomSettSalesData.add(oCustomSettSalesData);
            }
        }
        
        if(selectedReport == 'ProductSales'){
            List<String> oaccntSalesData1 = new List<String>{'Total CY','Total PY','Total $Diff'};
            Map<String, List<String>> monthValueMap = new Map<String, List<String>>();
            Map<String, List<String>> monthValueMapMAT = new Map<String, List<String>>();
            CustomSettSalesData oCustomSettSalesData;
            
            ActualSalesDataValue oAccntSalesDV = new ActualSalesDataValue(null,null,oaccntSalesData1,new List<String>{String.valueOf(currentSumMap.get('total').format()),String.valueOf(prevSumMap.get('total').format()),String.valueOf(diffSumMap.get('total').format())},monthList_MAT,monthNoName,selectedMATYTD);
            listAccntSalesDataValue = new List<ActualSalesDataValue>{oAccntSalesDV};
            //Added by Sohil Shah for DEF-001246
                    monthNoName = new Map<Integer,String>();                 
                    for(Integer i=0;i<monthList_MAT.size();i++)
                    {
                        monthNoName.put(i,monthList_MAT[i]);
                        
                    }                 
                    for(Integer i: monthNoName.keyset())
                    {   
                        if(i==0)
                        {
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('1').format()),String.valueOf(prevSumMap.get('1').format()),String.valueOf(diffSumMap.get('1').format())});
                            
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('1').format()),String.valueOf(prevSumMap.get('1').format()),String.valueOf(diffSumMap.get('1').format())});
                        }
                        if(i==1)
                        {
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('2').format()),String.valueOf(prevSumMap.get('2').format()),String.valueOf(diffSumMap.get('2').format())});
                            
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('2').format()),String.valueOf(prevSumMap.get('2').format()),String.valueOf(diffSumMap.get('2').format())});
                        }
                       if(i==2)
                        {
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('3').format()),String.valueOf(prevSumMap.get('3').format()),String.valueOf(diffSumMap.get('3').format())});
                            
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('3').format()),String.valueOf(prevSumMap.get('3').format()),String.valueOf(diffSumMap.get('3').format())});
                        }
                       if(i==3)
                        {
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('4').format()),String.valueOf(prevSumMap.get('4').format()),String.valueOf(diffSumMap.get('4').format())});
                            
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('4').format()),String.valueOf(prevSumMap.get('4').format()),String.valueOf(diffSumMap.get('4').format())});
                        }
                        if(i==4)
                        {
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('5').format()),String.valueOf(prevSumMap.get('5').format()),String.valueOf(diffSumMap.get('5').format())});
                            
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('5').format()),String.valueOf(prevSumMap.get('5').format()),String.valueOf(diffSumMap.get('5').format())});
                        }
                        if(i==5)
                        {                               
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('6').format()),String.valueOf(prevSumMap.get('6').format()),String.valueOf(diffSumMap.get('6').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('6').format()),String.valueOf(prevSumMap.get('6').format()),String.valueOf(diffSumMap.get('6').format())});    
                        }
                        if(i==6)
                        {                               
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('7').format()),String.valueOf(prevSumMap.get('7').format()),String.valueOf(diffSumMap.get('7').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('7').format()),String.valueOf(prevSumMap.get('7').format()),String.valueOf(diffSumMap.get('7').format())});    
                        }
                        if(i==7)
                        {                               
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('8').format()),String.valueOf(prevSumMap.get('8').format()),String.valueOf(diffSumMap.get('8').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('8').format()),String.valueOf(prevSumMap.get('8').format()),String.valueOf(diffSumMap.get('8').format())});    
                        }
                        if(i==8)
                        {                               
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('9').format()),String.valueOf(prevSumMap.get('9').format()),String.valueOf(diffSumMap.get('9').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('9').format()),String.valueOf(prevSumMap.get('9').format()),String.valueOf(diffSumMap.get('9').format())});    
                        }
                        if(i==9)
                        {                               
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('10').format()),String.valueOf(prevSumMap.get('10').format()),String.valueOf(diffSumMap.get('10').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('10').format()),String.valueOf(prevSumMap.get('10').format()),String.valueOf(diffSumMap.get('10').format())});    
                        }
                        if(i==10)
                        {                               
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('11').format()),String.valueOf(prevSumMap.get('11').format()),String.valueOf(diffSumMap.get('11').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('11').format()),String.valueOf(prevSumMap.get('11').format()),String.valueOf(diffSumMap.get('11').format())});    
                        }
                       
                        if(i==11)
                        {
                            mapProdSalesMAT.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('12').format()),String.valueOf(prevSumMap.get('12').format()),String.valueOf(diffSumMap.get('12').format())});
                            mapProdSalesYTD.put(monthNoName.get(i),new List<String>{String.valueOf(currentSumMap.get('12').format()),String.valueOf(prevSumMap.get('12').format()),String.valueOf(diffSumMap.get('12').format())});                            
                        }                                               
                    
              
                    }
                    //EOC by Sohil Shah for DEF-001246
                if(selectedMATYTD != 'YTD'){
                    listdataMAT = new List<dataMAT>();                   
                   
                for(Integer i=0;i<monthList_MAT.size();i++)
                {
                    String colMnthName = monthList_MAT[i];
                    List<String> colValues = mapProdSalesMAT.get(monthNoName.get(i));
                    dataMAT odataMAT = new dataMAT(colMnthName,colValues);
                    if(monthValueMapMAT.containsKey(colMnthName)){
                    List<String> values = monthValueMapMAT.get(colMnthName);
                    values.addAll(colValues);
                    monthValueMapMAT.remove(colMnthName);
                    monthValueMapMAT.put(colMnthName,values);
                    }else{
                        monthValueMapMAT.put(colMnthName,colValues);
                    }
                    listdataMAT.add(odataMAT);
                }
                
                            
                oCustomSettSalesData = new CustomSettSalesData(null,null,null,listAccntSalesDataValue,listdataMAT); 
                oCustomSettSalesData = new CustomSettSalesData(null,null,null,monthValueMapMAT,listAccntSalesDataValue);    
                
            }else{              
                for(Integer i=0;i<monthList_MAT.size();i++){  
                    String colMnthName = monthList_MAT[i];
                    List<String> colValues = mapProdSalesMAT.get(monthNoName.get(i));                   
                    dataYTD odataYTD = new dataYTD(colMnthName,colValues);
                    if(odataYTD != null)
                    listdataYTD.add(odataYTD);
                    monthValueMap.put(colMnthName,colValues);
                }
                // Added on 10th jun by sohil
                        System.debug('salesDateCustSett.ZTS_US_Date__c.month()+1----'+salesDateCustSett.ZTS_US_Date__c.month()+1);
                        
                        for(Integer i = salesDateCustSett.ZTS_US_Date__c.month()+1; i <= 12 ;i ++){
                            List<String> colValues = new List<String>();
                            String colMnthName = mapNoMonth.get(String.Valueof(i));
                            if(monthValueMap.containsKey(colMnthName)){
                                //List<String> values = monthValueMap.get(colMnthName);
                                List<String> values = new List<String>();
                                values.addAll(colValues);                               
                                monthValueMap.remove(colMnthName);                              
                                monthValueMap.put(colMnthName,values);
                            }else{
                                monthValueMap.put(colMnthName,colValues);
                            }
                           // monthList_MAT.add(colMnthName);
                           
                          
                        }
                        
                           System.debug('monthValueMap-Size---Y---'+monthValueMap.Size());      
                oCustomSettSalesData = new CustomSettSalesData('', '', '', listAccntSalesDataValue, listdataYTD);
                oCustomSettSalesData  = new CustomSettSalesData('','','',listAccntSalesDataValue, monthValueMap);
            }
            if(listCustomSettSalesData != null && listCustomSettSalesData.size() > 0){
                listCustomSettSalesData.add(oCustomSettSalesData);
            }
        }
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
        if(selectedAccnt == null || selectedAccnt == '' ){
            selectedAccnt = accntCurrent.Name;
        }       
        customSetList = new List<CustomSettSalesData>();
        customSetList = getSalesData();  
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
         Public List<dataMAT> listMATData {get;set;} ////Added by Sohil Shah for DEF-001246
        Public Map<String,List<String>> monthValueMapMAT{get;set;}////Added by Sohil Shah for DEF-001246   
       
       public CustomSettSalesData(String narcId, String accntId, String accntName, List<ActualSalesDataValue> salesDataWrapp,List<dataMAT> listMATData){
           this.salesDataWrapp = salesDataWrapp;
           this.accntName= accntName; 
            this.narcId= narcId;
           this.accntId= accntId;
          this.listMATData = listMATData;   
            
       }
        public CustomSettSalesData(String narcId, String accntId, String accntName, Map<String,List<String>> monthValueMapMAT, List<ActualSalesDataValue> salesDataWrapp){
           this.salesDataWrapp = salesDataWrapp;
           this.accntName= accntName; 
            this.narcId= narcId;
           this.accntId= accntId;
            this.monthValueMapMAT = monthValueMapMAT;
            
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
    
    // for MAT
    /***********
    * Method name : dataYTD
    * Description : This is wrapper class for YTD.
    * Return Type : None.
    * Parameters : None.
    ***********/
    public class dataMAT{
       Public String colMnthName{get;set;}
       Public List<String> colValues{get;set;}     
       public dataMAT(String colMnthName, List<String> colValues){
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
        Public Map<Integer,List<String>> monthValueMapping_Product{get;set;}        
        public ActualSalesDataValue(List<String> valueType, List<String> grandTotal){
            this.valueType = valueType;
            this.grandTotal = grandTotal;                                
        }
        
        public ActualSalesDataValue(List<String> therapeuticGrp,List<String> prodValue,List<String> valueType, List<String> grandTotal,List<String> monthList_MAT, Map<Integer,String> monthNoName, String selectedMATYTD ){
            this.therapeuticGrp = therapeuticGrp;
            this.prodValue = prodValue;
            this.valueType = valueType;
            this.grandTotal = grandTotal;                       
        }

        public ActualSalesDataValue(List<String> therapeuticGrp, List<String> prodValue, List<String> prodLineItem, List<String> valueType, List<String> grandTotal){
            this.therapeuticGrp = therapeuticGrp;
            this.prodValue = prodValue;
            this.prodLineItem = prodLineItem;
            this.valueType = valueType;
            this.grandTotal = grandTotal;
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
        PageReference  pg=new PageReference('/apex/ZTS_US_UnitSalesPdf');
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
        PageReference pg=new PageReference('/apex/ZTS_US_UnitSalesExcelDownload');
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
        PageReference  pg=new PageReference('/apex/ZTS_US_ProductSalesPdf');
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
        PageReference pg=new PageReference('/apex/ZTS_US_ProductSalesExcelDownload');
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
        PageReference  pg=new PageReference('/apex/ZTS_US_TotalSalesPdf');
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
        PageReference pg=new PageReference('/apex/ZTS_US_TotalSalesExcelDownload');
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
                salesPresets = [select Id, Name, ZTS_EU_Selected_GLR_Type__c, ZTS_EU_Selected_Preferred_Brands__c,ZTS_EU_Selected_Preferred_Species__c, ZTS_EU_Selected_Preferred_Thera_Grps__c, ZTS_EU_Selected_Preferred_Time__c, ZTS_EU_User__c from ZTS_EU_Sales_Presets__c where ZTS_EU_User__c =: UserInfo.getUserId() and Name =: selectedPreset limit 1 ];
                if(salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c != Null){
                    selectedMultiTherapeuticGrp = salesPresets.ZTS_EU_Selected_Preferred_Thera_Grps__c.split(';');
                    if(selectedMultiTherapeuticGrp != Null && selectedMultiTherapeuticGrp.size()>0)
                        selectedMultiTherapeuticGrpOpt = listSelOptPopulate(selectedMultiTherapeuticGrp);
                   
                }                
                if(salesPresets.ZTS_EU_Selected_Preferred_Brands__c != Null)
                    selectedMultiProduct = salesPresets.ZTS_EU_Selected_Preferred_Brands__c.split(';');
                if(salesPresets.ZTS_EU_Selected_Preferred_Species__c != Null)
                    selectedMultiSpecies = salesPresets.ZTS_EU_Selected_Preferred_Species__c.split(';');                
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
        displayPopup = false;
        if(selectedMultiTherapeuticGrpOpt!=null)
        selectedMultiTherapeuticGrp = listStringPopulate(selectedMultiTherapeuticGrpOpt);
        if(selectedMultiProductOpt!=null)
        selectedMultiProduct = listStringPopulate(selectedMultiProductOpt);
        if(selectedMultiSpeciesOpt!=null)
        selectedMultiSpecies = listStringPopulate(selectedMultiSpeciesOpt);
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
            if(selectedMultiSpecies!=null)
            newSalesPresets.ZTS_EU_Selected_Preferred_Species__c = multiSelectPopulate(selectedMultiSpecies);
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
            if(selectedMultiSpecies!=null)
            salesPresets.ZTS_EU_Selected_Preferred_Species__c = multiSelectPopulate(selectedMultiSpecies);
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
    private String sortExp = 'ZTS_EU_Therapeutic_Group__c';
        
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
            createQueryStr();
            soqlQuery+= 'AND ZTS_EU_Account__r.Name = \''+queryAccName+'\' ';
            selectedAccnt = queryAccName;
            if(!noParent ){
                // When the child record is selected
                if(isChildSelected == true){
                    
                    accntCurrent = accntChild;
                    if(accntchild != null && mapParentToChildValues.containsKey(accntchild.Name)){
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
                    if(accntchild == null){
                        aggCheck = false;
                    }
               }else {
                    List<String> prodLevel = new List<String>{'Account'};
                    aggCheck = true;
                    if(accntParent != null){
                        mapParentToChildValues.put(accntParent.Name, accntCurrent);
                    }
                    
                    accnPrevious = accntchild;
                    accntchild = accntCurrent;
                    accntCurrent = accntParent;
                    
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
            calculateLevelValues(accntCurrent);
            /*if(!disableL2){
                selectedLevelValue = 'L2';
            }else if(!disableL1){
                selectedLevelValue = 'L1';
            }else{
                selectedLevelValue = 'CHILD';
            }*/
            getcreateDataTable();
            return null;
       }
    /************
    * Method Name   : checkAggData
    * Description   : This method is when the agg checkbox is selected from the page
    * Return Type   : PageReference.
    * Parameters    : None
    *************/
    public void checkAggData(){
        queryAccID = null;
        getcreateDataTable();
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
           selectedBillToShipTo = 'Bill-To';
           getcreateDataTable();
           return null;
       }
}