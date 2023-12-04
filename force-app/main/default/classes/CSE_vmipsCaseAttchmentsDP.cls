/******************************************************//**
@class      cseVmipsCaseAttchmentsDP
@brief      Data Provider Class for Attached Documents Component on VMIPS Case Layout. Needed for Hypercare
issue  CSEPVW-95: Display "Send to PV Works" checkbox on file page not behaving as expected

@revision   04-08-2022  Ahmed Elawad
Created. 537

@copyright  (c)2022, Zoetis
**********************************************************/

global with sharing class CSE_vmipsCaseAttchmentsDP implements sortablegrid.sdgIDataProvider {
   
     //Whether to show this class in the AppBuilder.
    //Usually set to true.  Set to false if you intend to inherit this class and you don't want this class to be visible.
    global static Boolean isUserSelectable() {
        return true;
    }
    
    //  Method to retrieve data:
    //  SDG object - which is usually irrelevant in the case of custom Apex data providers
    //  SDGRequest - provides the details of what's being requested:
    //  String ParentRecordID: recordId of the page
    //  Integer Pagesize: how many records the client is requesting
    //  Integer PageId: Number of the page of data (note this is 1 based)
    //  String SortColumn:  Id of column that's being searched for (Id from the SDGField created in LoadSDG)
    //  String SortOrder: A or D
    //  List<sortablegrid.SDGFilter> Filters: list of filters
    //      String FilterValue: value provided in UI for filtering
    //      String FilterOperator: value provided as operator ie GT greater than, = equals, etc
    //Note there are other fields available in the request, but they're for routing to other data providers - in this case, you can ignore them.
    global static sortablegrid.SDGResult getData(sortablegrid.SDG coreSDG,  sortablegrid.SDGRequest request) {
        
        sortablegrid.SDGResult result = new sortablegrid.SDGResult();
        
        try {
            
            integer dataoffset = (request.pageid-1) * request.pagesize;
            integer datalimit = request.PageSize;        
            List<String> filters = new List<String>();
            
            // create list of fields
            List<String> fields = new List<String>();
            // create map to track sort order to field api name
            Map<String, String> sortordertofieldAPIname = new Map<String, String>();
            // retrieve fields with sort order from Sortable Data Grid: Case Attachments VMIPS entry
            // loop over the results adding field mappings to field list and sort order map
            List<sortablegrid.SDGField> vmipsFields = CSE_vmipsCaseAttchmentsDP.getVmipsFields();
            for (sortablegrid.SDGField fld :vmipsFields)
            {
                fields.add(fld.ColumnName);
                Integer intId = Integer.valueOf(fld.FieldOrder);
                String stringId = String.valueOf(intId);
                sortordertofieldAPIname.put(stringId, fld.ColumnName);
            }
            
            
            // if filters provided add filters to filter string list.
            // extend filter criteria as more fields are added to related list
            if (request.Filters!=null) {
                // iterate each filter from component
                for(sortablegrid.SDGFilter filter: request.filters) {
                    CSE_vmipsCaseAttchmentsDP.constructFilterString(filters,filter,sortordertofieldAPIname);        
                }
            }
            
            // get emails for case and add email IDS to caseAndEmailIds
            List<Id> caseAndEmailIds = new List<Id>();
            for (EmailMessage msg : [SELECT Id, ParentId FROM EmailMessage WHERE ParentId=:request.ParentRecordID]) {
                caseAndEmailIds.add(msg.Id);
            }
            caseAndEmailIds.add(request.ParentRecordID);
            
            // construct filter for query
            String filterstring = '';
            filterstring = 'WHERE LinkedEntityId IN (\'' + String.join(caseAndEmailIds, '\', \'' ) + '\')';
            if (!filters.isEmpty()) {
                filterstring += ' AND ' + String.join(filters, ' AND ');
            }
            
            // construct query for contentDocLink using set of IDs
            string query = 'select Id, ' + String.join(fields, ',') + '  FROM ContentDocumentLink ' + filterstring + ' ' + ' limit :datalimit offset :dataoffset';
            result.data = database.query(query);
            result.query=query; //Only used for the debug log
            result.FullQueryCount = 0;
            
            if (result.data!=null) {
                result.FullQueryCount = result.data.size();
            }
            
            result.pagecount = 1;
            result.isError = false;
            result.ErrorMessage = '';
            
        } catch (Exception ex){
            result.isError = true;
            result.ErrorMessage = ex.getMessage();
        }
        return result;
    }
    
    //Entry point to get the configuration.
    //Implement this to return a full SDG of fields and actions
    global sortablegrid.SDG LoadSDG(String SDGTag, String ParentRecordId)
    {
        system.debug('CustomDataProviderExample:LoadSDG');
        sortablegrid.SDG CoreSDG = new sortablegrid.SDG( 'CustomDataProviderExample' );
        CoreSDG.SDGActions = getActions();
        CoreSDG.SDGFields = getFields();
        return CoreSDG;
    }
    
    //Specify the actions available on the grid:
    //String Id: unique identifier
    //String Label: for the link
    //String Event: Lightning Event to raise
    //String Type: Render as a 'List Button', 'Row Button', 'Row', 'List', 'Multi List'
    //String Payload: payload for the event - can be parameterised with #delimited# values
    //String Icon: Icon to render
    //Integer actionorder: Order of buttons/menuitems
    private List<sortablegrid.SDGAction> GetActions()
    {
        List<sortablegrid.SDGAction> actions = new List<sortablegrid.SDGAction>();
        // Added method as a part of TPDEV-310, provide different buttons for admin user.
        boolean hasEleatedPermission = FeatureManagement.checkPermission('VMIPS_Elevated_Permission');
        if(hasEleatedPermission){
            actions.add(new sortablegrid.SDGAction('1', 'Edit', 'e.force:navigateToURL', 'Row Button', '{"url":"/flow/Document_Elevated_Permission?DocumentId=#ContentDocument.LatestPublishedVersionId#&CaseId=#parentrecordId#&Type=edit&retURL=#parentrecordId#"}', '', 1));
            actions.add(new sortablegrid.SDGAction('2', 'Delete', 'e.force:navigateToURL', 'Row Button', '{"url":"/flow/Document_Elevated_Permission?DocumentId=#ContentDocument.LatestPublishedVersionId#&Type=delete&retURL=#parentrecordId#"}', '', 2));
        }else{
        	actions.add(new sortablegrid.SDGAction('1', 'Edit', 'e.force:editRecord', 'Row Button', '{"recordId": "#ContentDocument.LatestPublishedVersionId#"}', 'utility:edit', 1));
        }
        return actions;
    }
    
    //Specify the behaviour of the grid - ie which fields to display on the page:
    //String ID - used to key filters back to the request
    //String Label: Column Header text
    //String ColumnName: Name within the SOQL - used by the LC to retrieve the value from the query results
    //String FieldType: STRING, NUMBER, DATE etc - determines rendering
    //String FieldStyle: Custom Renderer options:  Summarize:Total, Age etc
    //Boolean canSort: Make the columns click to sort (does not actually perform sorting)
    //Boolean canFilter: Renders a filter component (does not actually perform filtering)
    //Boolean isHTMLFormatted: Do you want to render the output as raw unescaped html.  Usually false.
    //List<sortablegrid.AuraSelectOption> options: List of piclist options for dropdowns for filters
    //Integer FieldOrder: order on the page
    private List<sortablegrid.SDGField> GetFields() {
        return CSE_vmipsCaseAttchmentsDP.getVmipsFields();
    }
    
    global static void constructFilterString(List<String> filters, sortablegrid.SDGFilter filter, Map<String, String>  sortordertofieldAPIname) {
        String  fo = filter.FilterOperator;
        String fv = String.escapeSingleQuotes(filter.FilterValue.trim());
        String fid = filter.SDGFieldID;
        String fieldname = sortordertofieldAPIname.get(fid);
        String dateTimeString;
        
        // try to construct a datetime string catching the error if the field filter value
        // isn't a datetime filter value
        try {
            List<String> splitString = fv.split('-');
            Integer year = (splitString.size() > 2 ? Integer.valueOf(splitString[0]) : null);
            Integer month = (splitString.size() > 2 ? Integer.valueOf(splitString[1]) : null);
            Integer day = (splitString.size() > 2 ? Integer.valueOf(splitString[2]) : null);
            DateTime dateTimeFilterValue = DateTime.newInstance(year,month,day,0,0,0);
            dateTimeString = dateTimeFilterValue.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }catch(Exception e) {}
        
        
        if (fieldname != null) {
            // fid 6 maps to boolean field on component. append fv which is either true or false
            if (fid =='6') {
                filters.add(fieldname +' = ' + fv); // ex: isChild = true
                return;
            }
            // fid 4 maps to date time field on component. append filter value without wrapping quotes
            if (fid == '4') {
                // switch on the matching value
                // else clause assumes date literal for filter string like: YESTERDAY, TODAY, LAST_WEEK
                switch on fo {
                    when 'NOT=' { 
                        filters.add('(NOT ' + fieldname +' = ' + dateTimeString + ')');
                    }
                    when '=' {
                        filters.add(fieldname +' = ' + dateTimeString);
                    }
                    when 'LT' { 
                        filters.add(fieldname +' < ' + dateTimeString);
                    }
                    when 'GT'{
                        filters.add(fieldname +' > ' + dateTimeString);
                    }
                    when else {
                        filters.add(fieldname +' = ' + fo);
                    }
                }
                Return;
            }
            
            // handle basic string based filters
            if (fo == '=' ) {
                filters.add(fieldname +' = \'' + fv + '\'');
            }
            if (fo == 'NOT=') {
                filters.add(fieldname +' <> \'' + fv + '\'');
            }
            if (fo=='STARTS') {
                filters.add(fieldname +' like \'' + fv + '%\'');
            }
            if (fo=='ENDS') {
                filters.add(fieldname +' like \'%' + fv + '\'');
            }
            if(fo=='CONTAINS') {
                filters.add(fieldname +' like \'%' + fv + '%\'');
            }
            if (fo=='NOTCONTAINS') {
                filters.add(' (not ' + fieldname + ' like \'%' + fv + '%\')');
            }
        }
        
        return;
    }

    global static List<sortablegrid.SDGField> getVmipsFields() {
        List<sortablegrid.SDGField> fields = new List<sortablegrid.SDGField>();
        fields.add( new sortablegrid.SDGField('1', 'Title', 'ContentDocument.LatestPublishedVersion.Title', 'STRING', '', true, true, false, null, 1));
        fields.add( new sortablegrid.SDGField('2', 'File Type', 'ContentDocument.LatestPublishedVersion.FileType', 'STRING', '', false, true, false, null, 2));
        fields.add( new sortablegrid.SDGField('3', 'Size', 'ContentDocument.LatestPublishedVersion.ContentSize', 'INTEGER', '', false, true, false, null, 3));
        fields.add( new sortablegrid.SDGField('4', 'Upload Date', 'ContentDocument.CreatedDate', 'DATETIME', '', false, true, false, null, 4));
        fields.add( new sortablegrid.SDGField('5', 'Document ID', 'ContentDocument.LatestPublishedVersionId', 'STRING', '', false, true, false, null, 5));
        fields.add( new sortablegrid.SDGField('6', 'Send To PV Works', 'ContentDocument.LatestPublishedVersion.Send_to_PV_Works__c', 'BOOLEAN', '', false, true, false, null, 6));
        return fields;
    }
}