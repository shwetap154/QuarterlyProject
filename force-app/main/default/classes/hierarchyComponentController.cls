/************************************************************************************* 
* Name: hierarchyComponentController
* Description: Controller class for VF page 'Account_Hierarchy_Page' (SC-009096/SC-008493)
* Created By: Aritra (Cognizant)
* Created: January 12 2022
*Modified: Pooja for SC-009787
**************************************************************************************/ 
public class hierarchyComponentController { 
    
    public string recordid{get;set;}
    public string accountname{get;set;}
    public string accountmarket{get;set;}
    public String objectAPIName{get;set;}
    public String parentFieldAPIName{get;set;}
    public String columnList{get;set;}
    public String ColumnsLabelList{get;set;}
    public String fieldAPINameForRecordLink{get;set;}
    public list<HierarchyWrapper> sortedHierarchyData{get;set;}
    public list<HierarchyWrapper> sortedHierarchyExcelData{get;set;} //SC-009787
    public string queryStringForUltimateParent;
    public string queryStringForHierarchy;
    public List<String> fieldAPINameList{get;set;} 
    public List<String> ColumnsLabelListForUI{get;set;}
    public List<String> ColumnsLabelListForExcelUI{get;set;}//SC-009787
    public String UltimateParentId{get;set;}
    public String exportType{get;set;}//SC-009787
    public List<String> fieldApiNameExcelList{get;set;}//SC-009787
    
    public hierarchyComponentController(){
        recordid = ApexPages.currentPage().getParameters().get('id');//SC-009787
        exportType = ApexPages.currentPage().getParameters().get('type');//SC-009787

        Account a =[Select Name,ZTS_EU_Market__c from Account where Id =: recordid limit 1][0];
        accountname = a.Name;
        accountmarket = a.ZTS_EU_Market__c.deleteWhiteSpace();//Please ensure metadata record label does not have any whitespace in it
        system.debug('accountmarket->'+accountmarket);
        objectAPIName = 'Account';
        parentFieldAPIName = 'ParentId';
        Account_Hierarchy_Columns_Market_Wise__mdt metadata = Account_Hierarchy_Columns_Market_Wise__mdt.getInstance(accountmarket); 
        columnList = metadata.Column_API_Names__c.length()>0? metadata.Column_API_Names__c: 'Name, ZTS_EU_Address_Line_1__c, ZTS_EU_City__c, ZTS_EU_State_County, Phone, Email__c';
        ColumnsLabelList = metadata.Column_Labels__c.length()>0? metadata.Column_Labels__c: 'Account Name, Address Line 1, City, State, Phone, Email';
        fieldAPINameForRecordLink = 'Name';
        sortedHierarchyData = new List<HierarchyWrapper>();   
        sortedHierarchyExcelData = new List<HierarchyWrapper>();//SC-009787
        
        if(recordid !=null && recordid !=''){//SC-009787
            fieldApiNameExcelList = new List<String>{'Name', 'Name1','Name2','Name3','ZTS_US_NARC_ID__c', 'BillingStreet', 'BillingCity', 'BillingState', 'Phone', 'Email__c'};
            ColumnsLabelListForExcelUI = new List<String>{'Account Name', 'Child Account Level 1','Child Account Level 2','Child Account Level 3','NARC ID', 'Street', 'City', 'State', 'Phone', 'Email'};
            generateQueryString();
            generateHierarchyData();
         }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please specify the record id in URL for id parameter.'));
            
        }
    }
    
    //This method composes the query strings to look for hierarchy and ultimate parent
    public void generateQueryString(){
        queryStringForUltimateParent = 'Select Id,  ';
        queryStringForHierarchy = 'Select   Id,';
        string fieldQuery = '';
        fieldAPINameList = new List<String>();
        ColumnsLabelListForUI = new List<String>();
        if(ColumnsLabelList!=null){
            List<string> columnlabels= ColumnsLabelList.trim().split(',');//ColumnsLabelList -> String consisting column labels separated by comma
            if(columnlabels.size() > 0 ){
                for(string ss : columnlabels){
                    if(ss != null && ss != ''){
                        ColumnsLabelListForUI.add(ss.trim());//ColumnsLabelListForUI -> List of column labels
                    }
                }
            }
        }
        if(parentFieldAPIName!=null){
            queryStringForUltimateParent = queryStringForUltimateParent + parentFieldAPIName ;  //concatenating parent id field api name in query string
            queryStringForHierarchy = queryStringForHierarchy + parentFieldAPIName ; //concatenating parent id field api name in query string
        }
        if(columnList!=null){
            List<string> fieldNames = columnList.trim().split(','); // columnList -> String consisting column API Names separated by comma
            if(fieldNames.size() > 0 ){
                if(fieldAPINameForRecordLink==null || fieldAPINameForRecordLink == ''){
                    fieldAPINameForRecordLink=fieldNames[0].trim(); // fieldAPINameForRecordLink -> this will hold the first field API Name from columnList which will have the link
                }
                for(string ss : fieldNames){
                    if(ss != null && ss != ''){
                        if(ss != parentFieldAPIName){
                            fieldQuery = fieldQuery + ' , ' + ss.trim(); // fieldQuery -> list of field API names separated by comma which will be concatenated in "queryStringForHierarchy"
                        }
                        fieldAPINameList.add(ss.trim()); // fieldAPINameList -> It is a list of field API Names for columns shown in grid 
                    }
                }
            }
            queryStringForHierarchy = queryStringForHierarchy + fieldQuery;
        }
        if(objectAPIName!=null){ // objectAPIName -> this will hold the object API Name where the queries will be run
            queryStringForUltimateParent = queryStringForUltimateParent + ' from ' + objectAPIName ;
            queryStringForHierarchy = queryStringForHierarchy + ' from ' + objectAPIName ;
        }if(fieldAPINameList.size() != ColumnsLabelListForUI.size()){
            ColumnsLabelListForUI = new List<String>();
            ColumnsLabelListForUI = fieldAPINameList;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Mismatch between number of fields and labels. So System generates table with column label as field API name'));
        }
    }
    
    public String GetUltimateParentId( String queryString ){
        string objId = recordid;
        queryString = queryString +  '  where id =:objId Limit 1';
        
        if(queryString!=null){
            Boolean top = false;
            if(Limits.getLimitQueries()-Limits.getQueries()>0){
                while ( !top ) { //Until the top node is reached 
                    try{
                        sObject rec = database.query(queryString);
                        if ( rec.get(parentFieldAPIName) != null ) { //if current record has value in parentfield, then it is not the top node
                            objId = string.valueof(rec.get(parentFieldAPIName));
                        }
                        else {
                            top = true; // else it is the top node
                        }
                    }catch(exception ex){ 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Something is wrong with either sobject or field API names. Please check and provide correct API names.'+ ex.getmessage()));
                        system.debug('****Exception while finding GetUltimateParentId.'+ ex.getmessage());
                        //top = true;
                    }
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Limit reached for number of SOQL Queries.'));
            }
        } 
        UltimateParentId = objId;
        return objId ;
    }
    
    
    public List<HierarchyWrapper> dataForHierarchy{get;set;}
    
    public void generateHierarchyData(){
        dataForHierarchy = new List<HierarchyWrapper>();
        //section to generate query string for account ends--------
        system.debug('*******current recordidid:' + recordid);
        List<String> currentParent      = new List<String>{};
        Integer count               = 0;
        Integer level               = 0;
        Boolean endOfStructure      = false;
        Map<String,String> maptoUltimateParent = new Map<String,String>();
        if(GetUltimateParentId(queryStringForUltimateParent)!=null){
            currentParent.add( GetUltimateParentId(queryStringForUltimateParent));
        }else{
            currentParent.add(recordid);
        }
        //Loop though all children
        List<sobject> sbList            = new List<sobject>{};
        string queryStr = '';
        while ( !endOfStructure ){  
            if( level == 0 ){
                queryStr = queryStringForHierarchy + ' where id IN : CurrentParent ORDER BY '+ parentFieldAPIName +'  Limit 500'; // if no parentid populated then details of self will be shown
            } 
            else {
                queryStr = queryStringForHierarchy + ' where ParentID IN : CurrentParent ORDER BY '+ parentFieldAPIName+ ' Limit 500'; 
            }
            if(queryStr != null && queryStr !=''){
                try{
                    if(Limits.getLimitQueries()-Limits.getQueries()>0){
                        sbList = database.query(queryStr);
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Limit reached for number of SOQL Queries.'));
                        endOfStructure = true;
                    }
                }catch(exception ex){ 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Something is wrong with either sobject or field API names. Please check and provide correct API names.'+ex.getmessage()));
                    endOfStructure = true;
                }
            }
            if( sbList.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                for ( Integer i = 0 ; i < sbList.size(); i++ ){
                    //Change below
                    sobject sb = sbList[i];
                    HierarchyWrapper aw = new HierarchyWrapper();
                    aw.recordId =string.valueof(sb.get('id'));
                    String pathtoUltimateParent = '';
                    if(sb.get('ParentId')!=null){
                        aw.idForNode = 'treegrid-'+ sb.get('id') +' treegrid-parent-'+ sb.get('ParentId');
                        System.debug('level '+level);
                        String lvl = '|_';
                        for(Integer j =0 ; j< level; j++)
                        {
                            lvl = '---'+ lvl;
                        }
                        
                        aw.accountLevel = lvl;
                        pathtoUltimateParent =maptoUltimateParent.get(string.valueof(sb.get('ParentId')))+'-'+string.valueof(sb.get('id'));
                        
                    }else{
                        aw.idForNode = 'treegrid-'+ sb.get('id');
                        aw.accountLevel = '  ';
                        pathtoUltimateParent =string.valueof(sb.get('id'));
                    }
                    maptoUltimateParent.put(string.valueof(sb.get('id')),pathtoUltimateParent);
                    aw.pathtoUltimateParent = pathtoUltimateParent;
                    
                    //SC-009787 Condition for specific excel export and not used metadata
                    if(exportType == 'excel'){
                         for(String ss:fieldApiNameExcelList){
                             string colValue ='';
                             try{ 
                                 if(ss.containsIgnoreCase(String.valueOf(level))){
                                     colValue = string.valueof(sb.get('Name'));
                                 }else if((sb.get(ss)!=null && ss != 'Name' && level !=0 ) ||
										(sb.get(ss)!=null && ss == 'Name' && level ==0 ) || (sb.get(ss)!=null &&level ==0)){
                                     colValue = string.valueof(sb.get(ss));
                                     if(ss.trim().equalsignorecase(fieldAPINameForRecordLink.trim())){
                                         aw.hyperlinkColumnValue = colValue;
                                     }
                                 }
                                 System.debug('Key '+ss +'Value '+colValue);
                                 aw.recordtDetails.add(colValue);
                             }catch(exception ex){ 
                                 system.debug('*******Error in some Field API Name.'+ ex.getmessage());
                                 aw.recordtDetails.add(colValue);
                            }
                        } 
                    }
                    else{
                        for(String ss:FieldAPINameList){
                            try{
                                string colValue ='';
                                if(sb.get(ss)!=null){
                                    colValue = string.valueof(sb.get(ss));
                                    if(ss.trim().equalsignorecase(fieldAPINameForRecordLink.trim())){
                                        aw.hyperlinkColumnValue = colValue;
                                    }
                                }
                                aw.recordtDetails.add(colValue);
                            }catch(exception ex){ 
                                system.debug('*******Error in some Field API Name.'+ ex.getmessage());
                            }
                        }
                    }
                    currentParent.add(string.valueof(sb.get('id')) );
                    dataForHierarchy.add(aw); 
                }
            }
            level = level + 1;
        }
       //Below part is done to sort the data based on hierarchy
       List<String> listOfPath = new List<String>();
       for(HierarchyWrapper hw: dataForHierarchy)
       {
           listOfPath.add(hw.pathtoUltimateParent);
       }
       listOfPath.sort(); 
       for(String s: listOfPath) 
       {
           for(HierarchyWrapper h: dataForHierarchy)
           {
               if(h.pathtoUltimateParent == s)
               {
                   sortedHierarchyData.add(h);
                   sortedHierarchyExcelData.add(h);
               }
           }
       }
       system.debug('Printing Sorted Data-->'+sortedHierarchyData) ;
    }
    
    public class HierarchyWrapper{
        public string idForNode{get;set;}
        public string recordId{get;set;}
        public string pathtoUltimateParent{get;set;}
        public string hyperlinkColumnValue{get;set;}
        public string accountLevel{get;set;}
        public List<String> recordtDetails{get;set;}
        HierarchyWrapper(){
            idForNode= '';
            recordId='';
            pathtoUltimateParent='';
            hyperlinkColumnValue='';
            accountLevel = '';
            recordtDetails= new List<String>();
        }
    }
    
}