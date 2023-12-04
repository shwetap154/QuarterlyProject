public with sharing class SL_FormLayoutHandler {
    
    @TestVisible
    public class FieldSetInfoWrapper {
        
        public set<String> fieldApiNames;
        public Map<String, Object> mapOfFieldApiToFieldsInfo;
        public map<String, String> mapFieldDependence;
        map<String,Integer> mpfldDecimal;
        
        @TestVisible    
        public FieldSetInfoWrapper(set<String> fieldApiNames, 
                                    Map<String, Object> mapOfFieldApiToFieldsInfo, 
                                    map<String, String> mapFieldDependence,
                                    map<String,Integer> mpfldDecimal) {
            this.fieldApiNames = fieldApiNames;
            this.mapOfFieldApiToFieldsInfo = mapOfFieldApiToFieldsInfo;
            this.mapFieldDependence = mapFieldDependence;
            this.mpfldDecimal = mpfldDecimal;
        }
    }
     @TestVisible
    public class returnDataWrapper {
        
        public UserRecordAccess recordLvlAccess;
        public Sobject recordData;
        
        @TestVisible    
        public returnDataWrapper(UserRecordAccess recordLvlAccess, Sobject recordData){
            this.recordLvlAccess = recordLvlAccess;
            this.recordData = recordData;
        }
        public returnDataWrapper(UserRecordAccess recordLvlAccess){
            this.recordLvlAccess = recordLvlAccess;
            this.recordData = recordData;
        }
    }
        
    @AuraEnabled
    public static String getCurrentRecord(String sObj, String fieldNames, String recordId, String parentAPIname, Boolean isfilterParentId) {
        String strObjName;
        if(isfilterParentId){
            strObjName = getSobjName(sObj, parentAPIname, isfilterParentId);
        }else{
            strObjName = sObj;
        }
        
        if(isfilterParentId == true){
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObj).getDescribe().fields.getMap();
            Schema.SobjectField  sField = fieldMap.get(parentAPIname);

            String escapesField = String.escapeSingleQuotes(String.valueOf(sField));
            String escapesObj = String.escapeSingleQuotes(sObj);
            String escaperecordId = String.escapeSingleQuotes(recordId);
            String strQuery = 'SELECT ' + escapesField + ' FROM ' + escapesObj + ' WHERE Id = \'' + escaperecordId + '\' AND ZTS_EU_Market__c != \'United States\'';

            Sobject objRec = ((List<Sobject>)(Database.query(strQuery)))[0];
            
            String getParentId = (String.valueOf(objRec.get(sField)));
            String query = 'SELECT '+fieldNames+' FROM '+sObj+' WHERE Id = \''+recordId+'\'';
            
            UserRecordAccess recLvlPermiss = getRecordLevelAcs(getParentId);
            if(recLvlPermiss.HasReadAccess || recLvlPermiss.HasEditAccess){
                
                String escapeFieldName = String.escapeSingleQuotes(fieldNames);
                String escapestrObjName = String.escapeSingleQuotes(strObjName);
                String escapestrParentId = String.escapeSingleQuotes(getParentId);
                String strQueryParentRecord = 'SELECT '+ escapeFieldName + ' FROM ' + escapestrObjName + ' WHERE Id = \''+escapestrParentId + '\' AND ZTS_EU_Market__c != \'United States\'';

                SObject record =  Database.query(strQueryParentRecord);
                returnDataWrapper ret = new returnDataWrapper(recLvlPermiss, record);
                
                return JSON.serialize(ret);
            }else{
                returnDataWrapper ret = new returnDataWrapper(recLvlPermiss);
                
                return JSON.serialize(ret);
            }
            //System.debug('query:'+query);
        }
        else
        {
            UserRecordAccess objRecAcc = getRecordLevelAcs(recordId);
            if(objRecAcc.HasReadAccess || objRecAcc.HasEditAccess){

                String escapeFieldNames = String.escapeSingleQuotes(fieldNames);
                String escapesObj = String.escapeSingleQuotes(sObj);
                String escapeRecordId = String.escapeSingleQuotes(recordId);
                String strQueryRecord = 'SELECT ' + escapeFieldNames + ' FROM ' + escapesObj + ' WHERE Id = \'' + escapeRecordId + '\' AND ZTS_EU_Market__c != \'United States\'';

                SObject record = Database.query(strQueryRecord);
                
                returnDataWrapper objRet = new returnDataWrapper(objRecAcc, record); 
                return JSON.serialize(objRet);  
            }else{
				returnDataWrapper objRet = new returnDataWrapper(objRecAcc);
                return JSON.serialize(objRet); 
            }           
        }
    }
    public static UserRecordAccess getRecordLevelAcs(String recordId){
        // checking record level access permission
        UserRecordAccess objPermission = [SELECT RecordId, HasReadAccess, HasEditAccess 
                                        FROM UserRecordAccess 
                                        WHERE UserId =: UserInfo.getUserId() AND RecordId =: recordId limit 1];
    
        //System.debug('test--permission--> '+objPermission);
        return objPermission;
    }
    @AuraEnabled
    public static String getSobjName(String currentObjType, String parentAPIname, Boolean isfilterParentId){
        String strNewObjName = currentObjType;
        try{
            if(isfilterParentId == true ){
                Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Map <String, Schema.SObjectField> fieldMap = schemaMap.get(currentObjType).getDescribe().fields.getMap();
                Schema.SobjectField  sField = fieldMap.get(parentAPIname);
                Schema.DescribeFieldResult dField = (sField != Null) ? sField.getDescribe() : Null;
                String strObjName = string.valueOf(dField.getReferenceTo());
                strObjName = strObjName.subString(1, strObjName.length() -1 );
                strNewObjName = strObjName;
                return strNewObjName;
            }
        }
        catch(Exception Ex){
            System.debug('ERRor:: '+Ex);
        }
        return null;
    }
    
    @AuraEnabled
    public static String describeFieldSet(String objType, String fieldSetName, String parentAPIname, boolean isfilterParentId) {
        try{
            // CAll your method and set the object Type...
            String strObjName;
            if(isfilterParentId){
                strObjName = getSobjName(objType, parentAPIname, isfilterParentId);
            }else{
                strObjName = objType;
            }  
            
            Set<String> setEditableFields = getCreatableFields(strObjName);
            set<String> lstFieldApiNames = new set<String>();
            map<String, String> mpOfDependence = new map<String, String>();
            
            Map<String, Object> result = new Map<String, Object>();
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fMap = schemaMap.get(strObjName).getDescribe().Fields.getMap();
            Schema.DescribeSObjectResult obj = schemaMap.get(strObjName).getDescribe();
            // checking object level access permission
            if(!obj.accessible){
                return '[{"message":"Insufficient Privileges","errorCode":"admin_insufficient_privileges"}]';
            }
            
            Map<String, Schema.FieldSet> fsMap = schemaMap.get(strObjName).getDescribe().fieldSets.getMap();
			
            //to get decimal val length
            map<String,Integer> mpfldDecimal = new map<String,Integer>();
            if(!fsMap.get(fieldSetName).getFields().isEmpty()) {
                for(Schema.FieldSetMember fsm : fsMap.get(fieldSetName).getFields()){
                    
                    String fieldPath = String.valueOf(fsm.getFieldPath());
                    if(fMap.get(fieldPath) == null){
                        continue;
                    }
                    Schema.DescribeFieldResult fld = fMap.get(fieldPath).getDescribe();
                    if(!fld.isAccessible()){
                        continue;
                    }
                    Map<String, Object> record = new Map<String, Object>();
                    record.put('label', fsm.getLabel());
                    record.put('fieldPath', fsm.getFieldPath());
                    record.put('editable', setEditableFields.contains(fsm.getFieldPath()));
                    
                    // Help text
                    record.put('helpText', Schema.getGlobalDescribe().get(strObjName).getDescribe().fields.getMap().get(fsm.getFieldPath()).getDescribe().getInlineHelpText());
                    
                    if(fieldPath.contains('.') ){
                        // this Conditon is to avoid 2nd level field override the 1st level field
                        if(!lstFieldApiNames.contains(fsm.getFieldPath())){
                            lstFieldApiNames.add(fsm.getFieldPath());
                            record.put('type', fsm.getType());
                            result.put(fsm.getFieldPath(), record);
                        }
                    }
                    else{
                        
                        mpfldDecimal.put(fieldPath,fld.getScale()); // adding decimal length
                        if(fsm.getType() == Schema.DisplayType.TEXTAREA ){
                            //Schema.DescribeFieldResult TestField = obj.Fields.getMap().get(fieldPath).getDescribe();
                            if(fld.isHtmlFormatted() || Test.isRunningTest()){
                                record.put('type', 'RICHTEXTAREA');
                            }else{
                                record.put('type', fsm.getType());
                            }
                        }else{
                            record.put('type', fsm.getType());
                        }
                        
                        String fieldAPI = fsm.getFieldPath();
                        if(String.valueOf(fsm.getType()) =='REFERENCE' ){
                            //Schema.DescribeFieldResult fld = fMap.get(fieldPath).getDescribe();
                            if(fieldAPI.endsWith('__c')){
                                lstFieldApiNames.add(fieldAPI.replace('__c','__r.Name'));
                                result.put(fieldAPI.replace('__c','__r.Name'), record);
                            }else if(fieldAPI.endsWithIgnoreCase('Id')){
                                lstFieldApiNames.add(fieldAPI.replace('Id', '.Name'));
                                result.put(fieldAPI.replace('Id', '.Name'), record);
                            }
                            String parentObj = String.valueOf(fld.getReferenceTo());
                            parentObj = parentObj.subString(1, parentObj.length() -1 );
                            record.put('parentObject', parentObj);
                            
                        }else{
                            lstFieldApiNames.add(fsm.getFieldPath());
                            record.put('parentObject',objType );
                            result.put(fsm.getFieldPath(), record);
                        }
                        if(String.valueOf(fsm.getType()) == 'PICKLIST' || String.valueOf(fsm.getType()) == 'MULTIPICKLIST'){
                                record.put('picklistVal',getselectOptions(String.valueOf(fsm.getFieldPath()), fMap));
                                record.put('isDependent', false);
                        }
                    }
                }
                //System.debug('RESULT>>>>>>>>'+result);
                FieldSetInfoWrapper objWrapper = new FieldSetInfoWrapper(lstFieldApiNames, result, mpOfDependence,mpfldDecimal);
                return JSON.serialize(objWrapper);
                
            } else {
                return '[{"message":"There is no fields present in provided fieldset. Please add some fields","errorCode":"NO_FIELDS_EXIST"}]';
            }
        } catch(Exception e) {
            System.debug('LINE NUMBER>>>>>>' + e.getLineNumber()+ '===========' + e.getMessage());
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }
    }
    @AuraEnabled
    public static String updateRecord(String sObj, String jsonObjArr) {
        try {
            //System.debug('jsonObjArr::::::'+jsonObjArr);
            Type listType = Type.forName('List<' + sObj + '>');
            List<SObject> objs = (List<SObject>)JSON.deserialize(jsonObjArr, listType);
            //System.debug('objs::::>>'+objs);
            update objs;
        } catch (Exception e) {
            return '[{"data":' + jsonObjArr + ',"message":"' + e.getMessage() + '","cause":"' + e.getCause() + '","typeName":"' + e.getTypeName() + '"}]';
        }
        return 'success';
    }
    
    @TestVisible
    private static Set<String> getCreatableFields(String objectName) {
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        
        Set<String> setEditableFields = new Set<String>();
        for (Schema.SObjectField ft : fMap.values()){
            Schema.DescribeFieldResult fd = ft.getDescribe();
            
            if (fd.isCreateable()  && fd.isUpdateable())
                setEditableFields.add(fd.getName());
        }
        return setEditableFields;
    }
    
    @TestVisible
    private static list<map<string,string>> getselectOptions(string fld,map <String,Schema.SObjectField>  fieldMap) {
        
        list<map<string,string>> options = new list<map<string,string>>();
        options.add(new map<string,string>{'class' => 'optionClass', 'label' => '--None--', 'value' => ''});
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            options.add(new map<string,string>{'class' => 'optionClass', 'label' => a.getLabel(), 'value' => a.getValue()});
        }
        return options;
    }

    public static String getSessionIdFromVF(){

        String strSessionId;

        PageReference reportPage = Page.SL_GetSessionIdVF;
        String vfContent = reportPage.getContent().toString();
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
        endP = vfContent.indexOf('End_Of_Session_Id');
        strSessionId = vfContent.substring(startP, endP);

        return strSessionId;
    }

    @AuraEnabled
    public static String getDisplayDensity(){
        Http httpServer = new Http();
        HttpRequest req = new HttpRequest();
        String strSessionId = getSessionIdFromVF();
        System.debug('SESSION ID::' + strSessionId);
        req.setHeader('Authorization', 'OAuth '+ strSessionId);
        // req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v44.0/ui-api/themes/active');
        req.setEndpoint('callout:Salesforce_UI_API');
        req.setMethod('GET');
        HttpResponse res = httpServer.send(req);
        Map<String, Object> mapObject =(Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('MAP>>>>'+mapObject.get('density'));

        return String.valueOf(mapObject.get('density'));
    }

    public static void dataSetup() {
        Account acc = new Account(Name = 'TestAcc', ZTS_EU_Market__c = 'Italy', ZTS_EU_Zip_Postal_Code__c = '00000');
        try {
           insert acc;
        } catch (Exception ex) {
           System.debug(ex.getMessage());
            throw ex;
        }
		ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        Contact con = new Contact(LastName = 'TestCon',
                                  FirstName = 'TestCon',
                                  AccountId = acc.Id,
                                  ZTS_EU_Market__c = 'Italy'
                                  );
        try {
           insert con;
        } catch (Exception ex) {
           System.debug(ex.getMessage());
            throw ex;
        }
    }
}