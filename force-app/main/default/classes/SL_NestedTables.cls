public class SL_NestedTables
{    
 
    public static String recordId;
    public static set<ID> setId = new set<ID>();

    @AuraEnabled
    public static String dynQry(        String fieldList,
        String objName,
        String sortFld,
        String sortDir,
        String queryFilter,
        String parentRecordId,
        String relationshipField,
        String parentField,
        Boolean filterByParent,
        String nestedObjectName,
        String nestedfieldName,
        String nestedQueryFilter
    ) {
        if (String.isBlank(sortDir) || (sortDir != 'ASC' && sortDir != 'DESC')) {
            sortDir = 'ASC';
        }
        recordId = parentRecordId;
        String errMsg = '';
        String queryString = '';
        String[] fieldArray = fieldList.replaceAll(' ', '').split(',');
        String sortField = sortFld;
        String nestedRelField = null;

        //if(String.isBlank(sortField)) {
        //    sortField = fieldArray[0];
        //}

        SL_NestedTables_FieldObject[] fieldMap = getfieldMap(fieldArray, objName);
        
        queryString += 'Select ';
        String[] queryFieldArray = new String[]{
        };

        for (SL_NestedTables_FieldObject fm : fieldMap) {
            // API and Name would be the same if field is 'Id'
            // due to how we handle Id field to display as a link
            if (String.isNotBlank(fm.fieldType)) {
                if (fm.isRef && fm.lkupRelAPI != fm.lookupFieldName) {
                    queryFieldArray.add(fm.lkupRelAPI);
                    queryFieldArray.add(fm.lookupFieldName);

                    if (sortField == fm.apiName) {
                        sortField = fm.lookupFieldName;
                    }
                } else {
                // Changes based on LIB-789 by Divyansh Sinha
                if(fm.fieldType == 'Picklist') 
                   queryFieldArray.add('toLabel('+fm.apiName+')');
                else
                   queryFieldArray.add(fm.apiName);

                }
            }
        }


        if (String.isNotBlank(nestedObjectName)) {
            nestedRelField = getChildRelationshipName(nestedObjectName, objName, nestedfieldName);
            if (nestedRelField != null && String.isNotBlank(nestedRelField)) {
                String whereQuery = (String.isNotBlank(nestedQueryFilter) && String.isNotEmpty(nestedQueryFilter)) ? ' WHERE '+nestedQueryFilter : '' ;
                System.debug(whereQuery);
                queryFieldArray.add('(SELECT Id FROM ' + nestedRelField + whereQuery+')' );
            }
        }
        
        //LIB-615 Bug fix. UserRecordAccess is not a recognized relation in SOQL for certain sObjects like AccountContactRelation.        
        if(isUserRecordAccessValid(objName)){
            if(!queryFieldArray.contains('UserRecordAccess.HasEditAccess')){ 
                queryFieldArray.add('UserRecordAccess.HasEditAccess');
            }
            if(!queryFieldArray.contains('UserRecordAccess.HasDeleteAccess')){ 
                queryFieldArray.add('UserRecordAccess.HasDeleteAccess');
            }
        }
        
        queryString += String.join(queryFieldArray,',')+' ';
        queryString += 'FROM ' + objName + prepareWhereClause(queryFilter, parentRecordId, objName);
        if(filterByParent && String.isNotBlank(parentField) && String.isNotBlank(relationshipField)) {
            
            //Added By Parth for - LIB-699 NRL: Fix the errors from the results in Clayton - Start Here
            //List<Sobject> lstTempList = Database.query('SELECT Id,' + parentField + ' FROM ' + Id.valueOf(parentRecordId).getSObjectType().getDescribe().getName() + ' WHERE ' + parentField + ' != NULL AND Id = \'' + parentRecordId + '\' ');
            
            String objectNameForTemplate = Id.valueOf(parentRecordId).getSObjectType().getDescribe().getName();
            
            final String queryTemplate;
            queryTemplate = 'SELECT Id, {0} FROM {1} WHERE {2} != NULL AND Id = {3}   AND ';
            
            List<Sobject> lstTempList = Database.query(String.format(
                                                                    queryTemplate, new List<String> {
                                                                        String.escapeSingleQuotes(parentField),
                                                                        String.escapeSingleQuotes(objectNameForTemplate),
                                                                        String.escapeSingleQuotes(parentField),
                                                                        String.escapeSingleQuotes(parentRecordId)
                                                                    }
                                                                )
                                                        );
                                                        
            //Added By Parth for - LIB-699 NRL: Fix the errors from the results in Clayton - End Here
            
            if(!lstTempList.isEmpty()) {
                Id parentId = (Id)lstTempList[0].get(parentField);
                queryString += queryString.contains(' WHERE ')
                        ? ' AND ' + relationshipField + '=\'' + parentId + '\''
                        : ' WHERE ' + relationshipField + '=\'' + parentId + '\'';
            }
            queryString +=  '';
        }
		// Fix added for issue reported in LIB-776 by Divyansh Sinha
        if(!filterByParent && String.isNotBlank(parentRecordId) && String.isNotBlank(relationshipField)) {
            if(queryString.contains(' WHERE ')) {
                List<String> lstString = queryString.split(',');
                Integer count = 0;
                for(String str : lstString) {
                    if(str.contains(' WHERE '))
                        count++;
                    
                }       
                if((String.isBlank(nestedObjectName) || String.isEmpty(nestedObjectName))) {
                    if(count >= 1) {
                        queryString += ' AND ' + relationshipField + '=\'' + parentRecordId + '\'';
                    }else {
                        queryString += ' WHERE ' + relationshipField + '=\'' + parentRecordId + '\'';
                    }
                } else {
                    if(count == 1 && (String.isBlank(nestedQueryFilter) || String.isEmpty(nestedQueryFilter))) {
                        queryString += ' AND ' + relationshipField + '=\'' + parentRecordId + '\'';
                    }else if(count == 1 && (String.isNotBlank(nestedQueryFilter) || String.isNotEmpty(nestedQueryFilter))){
                        queryString += ' WHERE ' + relationshipField + '=\'' + parentRecordId + '\'';
                    }if(count == 2) {
                        queryString += ' AND ' + relationshipField + '=\'' + parentRecordId + '\'';
                    }
                }
            } else {
                queryString += ' WHERE ' + relationshipField + '=\'' + parentRecordId + '\'';
            }
            queryString +=  '';
        }

        if(String.isNotBlank(sortField)){
            queryString += ' ORDER BY ' + sortField + ' ' + sortDir;
            if(sortDir == 'ASC') {
                queryString += ' NULLS FIRST';
            }
            else if(sortDir == 'DESC') {
                queryString += ' NULLS LAST';
            }
        }
        //System.debug('Final query:: '+queryString);
        sObject[] recs = new sObject[]{};

        SL_NestedTables_ResponseWrapper[] wrappedRecs = new SL_NestedTables_ResponseWrapper[]{};
        System.debug('$$$ query: '+queryString);
        try {

            //queryString = 'Select Account__c,Account__r.Name From Knowledge__kav';
            recs = Database.query(queryString);
            for (SObject rec : recs) {
                Integer relSize = 0;

                if (nestedRelField != null && rec.getSObjects(nestedRelField) != null) {
                    relSize = rec.getSObjects(nestedRelField).size();
                }
                wrappedRecs.add(new SL_NestedTables_ResponseWrapper(rec, relSize));
            }
        }
        catch(Exception e) {
            System.debug('$$$ ERROR:: '+e.getMessage() + '\n' + e.getStackTraceString());
            errMsg = 'Please check field(s) and object API Names';
        }

        // Need to do something more efficient than sending all the rows.
//        if (nestedRelField != null and recs.Assets) {
//
//        }

        Schema.DescribeSObjectResult result = Schema.getGlobalDescribe().get(objName).getDescribe();
        String jsonRes = JSON.serialize(new SL_NestedTables_Response(wrappedRecs,fieldMap,sortDir,sortField,errMsg,result.isCreateable(),result.getName()));
        
        return jsonRes;
    }        

    private static boolean isUserRecordAccessValid(String objName){
        system.debug('===objName==>>'+objName);
        final set<String> UserREcordAccessExemptions = new set<string>{'AccountContactRelation'};
        return !UserREcordAccessExemptions.contains(objName);
    }
    
    private static string sanitizeSOQLInput(String value){
        return string.escapeSingleQuotes(value);
    }

//    private static String handlePlaceHolderFields(String filtercriteria,String recordId,String objName){
//        if(recordId == null)
//            return filtercriteria;
//
//        pattern myPattern = pattern.compile('<<([a-zA-Z0-9_]+)\\.([a-zA-Z0-9_]+)(__c)?>>');
//        matcher myMatcher = myPattern.matcher(filtercriteria);
//
//        if(!myMatcher.find()) {
//            return filtercriteria;
//        }
//
//        String expression;
//        set<String> fields = new set<String>();
//        set<String> sObjects = new set<String>();
//
//        do {
//            integer startIdx = myMatcher.start();
//            integer endIdx = myMatcher.end();
//            expression = filtercriteria.substring(startIdx, endIdx);
//
//            integer IndexOfDot = expression.indexOf('.');
//            integer IndexOfClose = expression.indexOf('>>');
//            fields.add(expression.substring(IndexOfDot + 1, IndexOfClose));
//            sObjects.add(expression.substring(2, IndexOfDot));
//        } while(myMatcher.find());
//
//        if(sObjects.size() > 1) {
//            return filtercriteria;
//        }
//
//        List<String> fieldsList = new List<String>();
//        fieldsList.addAll(fields);
//        String fieldsCS = String.join(fieldsList, ',');
//
//        for(String obj : sObjects) {
//            sObject record =  Database.query('SELECT ' + fieldsCS + ' FROM ' +  obj +
//                                                ' WHERE Id=\'' + recordId + '\  LIMIT 1');
//            for(String field : fields) {
//                String exprToReplace = '<<' + obj + '.' + field + '>>';
//                String replacingVal = '\''+ (String)record.get(field) + '\'';
//                filtercriteria = filtercriteria.replaceFirst(exprToReplace, replacingVal);
//            }
//            break;
//        }
//        return filtercriteria;
//    }
  
    private static String prepareWhereClause(String strFilterCriteria,String recordId,String objName) {
        if(String.isNotBlank(strFilterCriteria)) {
            strFilterCriteria = strFilterCriteria.trim();

            /*Handle place holder fields - Start*/
            //strFilterCriteria = handlePlaceHolderFields(strFilterCriteria, recordId, objName);
            /*andle place holder fields - Stop*/

            List<User> lstUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserid() AND ZTS_EU_Market__c != 'United States'];
            
            //Supporting CurrentUser in filtercriteria
            while(strFilterCriteria.containsIgnoreCase('currentuser')) {
                Integer index = strFilterCriteria.indexOfIgnoreCase('currentuser');
                String temp = strFilterCriteria.substring(index, index+11);
                strFilterCriteria = strFilterCriteria.replaceFirst(temp, '\''+UserInfo.getUserid()+'\'');
            }
            
            //Supporting CurrentUserContact in filtercriteria
            while(strFilterCriteria.containsIgnoreCase('current_user_contact')) {
                String strContactId = '';
                if(!lstUser.isEmpty() && lstUser[0].ContactId != null) {
                    strContactId = lstUser[0].ContactId;
                    Integer index = strFilterCriteria.indexOfIgnoreCase('current_user_contact');
                    String temp = strFilterCriteria.substring(index, index+20);
                    strFilterCriteria = strFilterCriteria.replaceFirst(temp, '\''+strContactId+'\'');
                }
                else
                    strFilterCriteria = strFilterCriteria.substringAfter('current_user_contact');
            }
            
            if(String.isNotBlank(strFilterCriteria.trim())) {
                strFilterCriteria = strFilterCriteria.trim();
                
                if(strFilterCriteria.startsWithIgnoreCase('AND')) {
                    Integer index = strFilterCriteria.indexOfIgnoreCase('AND');
                    String temp = strFilterCriteria.substring(index, index+4);
                    strFilterCriteria = strFilterCriteria.replaceFirst(temp, '');
                }
                else if(strFilterCriteria.startsWithIgnoreCase('OR')) {
                    Integer index = strFilterCriteria.indexOfIgnoreCase('OR');
                    String temp = strFilterCriteria.substring(index, index+3);
                    strFilterCriteria = strFilterCriteria.replaceFirst(temp, '');
                }
            }
            if(String.isNotBlank(strFilterCriteria.trim()))
                return ' WHERE (' + strFilterCriteria.trim() +') ';
        }
        return '';
    }

    private static SL_NestedTables_FieldObject[] getfieldMap(String[] flds, String objName) {
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult rootObj = gdMap.get(objName).getDescribe();
        Map<String, Schema.SObjectField> rootfieldMap = rootObj.fields.getMap();
        String strInvalidField = '';
        SL_NestedTables_FieldObject[] fieldMap = new SL_NestedTables_FieldObject[]{};

        for(String key : flds) {
            key = rootfieldMap.containsKey(key) ? rootfieldMap.get(key).getDescribe().getName() : key; 
            String[] tempArry = key.split('\\.');

            if(tempArry.size() > 1) {
                Integer lstSize = tempArry.size();
                String finalFld = tempArry[lstSize-1].toLowerCase(); 
                
                Schema.Describesobjectresult finalObj;
                Schema.DescribeFieldResult finalFldRes;
                
                String[] actLabelArry = new String[]{};
                String actLabel = '';

                if(lstSize > 2) {
                    for(Integer i=0;i<=lstSize-2;i++) {
                        String tempFld = tempArry[i].toLowerCase();
                        System.debug('263:'+ tempFld);
        
                        if(tempFld.endsWith('__r')) {
                            tempFld = tempFld.removeEnd('__r') + '__c';
                        }
                        else {
                            tempFld += 'Id';
                        }
                        System.debug('271:'+ tempFld);
                        
                        strInvalidField = tempFld;
                        if(rootfieldMap.containsKey(tempFld) || finalObj.fields.getMap().containsKey(tempFld)) {
                            strInvalidField = '';
                            if(i == 0) {
                                Schema.DescribeFieldResult dfr = rootfieldMap.get(tempFld).getDescribe();
                                Schema.sObjectType[] refs = dfr.getReferenceTo();
                                
                                finalObj = refs[0].getDescribe();
                                actLabelArry.add(dfr.getLabel());
                            }
                            else {
                                Schema.DescribeFieldResult dfr = finalObj.fields.getMap().get(tempFld).getDescribe();
                                Schema.sObjectType[] refs = dfr.getReferenceTo();
                                
                                finalObj = refs[0].getDescribe();
                                actLabelArry.add(dfr.getLabel());
                            }
                        }
                    }
    
                    actLabel = String.join(actLabelArry,' > ');
                }
                else {
                    String tempFld = tempArry[0].toLowerCase();
    
                    if(tempFld.endsWith('__r')) {
                        tempFld = tempFld.removeEnd('__r') + '__c';
                    }
                    else {
                        tempFld += 'Id';
                    }
                    System.debug('304' + tempFld);
                    strInvalidField = tempFld;
                    if(rootfieldMap.containsKey(tempFld)) {
                        strInvalidField = '';
                        Schema.DescribeFieldResult dfr = rootfieldMap.get(tempFld).getDescribe();
                        Schema.sObjectType[] refs = dfr.getReferenceTo();
        
                        finalObj = refs[0].getDescribe();
                    }
                }

                Map<String, Schema.SObjectField> fieldMapTemp = finalObj.fields.getMap();
                System.debug('316' + fieldMapTemp);
                
                strInvalidField = finalFld;
                if(fieldMapTemp.containsKey(finalFld)) {
                    strInvalidField = '';
                    Schema.DescribeFieldResult dfrTemp = fieldMapTemp.get(finalFld).getDescribe();
                    
                    actLabel += ((actLabel != '')?('.' + dfrTemp.getLabel()):(dfrTemp.getLabel()));
                    
                    String fieldType = String.valueOf(dfrTemp.getType());
        
                    fieldMap.add(createfieldMap(key, actLabel, dfrTemp,strInvalidField));
                }
                else {
                    fieldMap.add(createfieldMap(key,'',null,strInvalidField)); 
                }
            }
            else {
                strInvalidField = key;
                if(rootfieldMap.containsKey(key)) {
                    strInvalidField = '';
                    Schema.DescribeFieldResult dfr = rootfieldMap.get(key).getDescribe();
                    fieldMap.add(createfieldMap(key,dfr.getLabel(),dfr,strInvalidField)); 
                }
                else {
                    fieldMap.add(createfieldMap(key,'',null,strInvalidField)); 
                }
            }
        }
        return fieldMap;
    }

    private static SL_NestedTables_FieldObject createfieldMap(String apiName, String lbl, Schema.DescribeFieldResult dfr, String strInvalidField) {
        if(dfr != null) {
            String fieldType = String.valueOf(dfr.getType());
            String lookupFieldName = '';
            String lkupRelApiName = apiName;
            Boolean isRef;
    
            if(fieldType == 'REFERENCE') {
                String[] tempArry = apiName.split('\\.');
                
                String[] relNameArry = new String[]{};
    
                if(tempArry.size()>2) {
                    for(Integer i=0;i<=tempArry.size()-2;i++) {
                        relNameArry.add(tempArry[i]);
                    }
    
                    lookupFieldName = String.join(relNameArry,'.')+'.'+dfr.getRelationshipName()+'.Name';
                }
                else if(tempArry.size()==2) {
                    lookupFieldName = tempArry[0]+'.'+dfr.getRelationshipName()+'.Name';
                }
                else {
                    lookupFieldName = dfr.getRelationshipName()+'.Name';
                }
                isRef = true;
    
                // Id or Name should link to the record being displayed in the table
            } 
            else if(apiName == 'Id') {
                lookupFieldName = apiName;
                isRef = true;
            } 
            else if(apiName == 'Name') {
                lookupFieldName = apiName;
                lkupRelApiName = 'Id';
                isRef = true;
            } 
            else {
                isRef = false;
            }
            return new SL_NestedTables_FieldObject(apiName,lbl,fieldType,isRef,lkupRelApiName,lookupFieldName,strInvalidField);
        }
        else {
            return new SL_NestedTables_FieldObject(apiName,'','',false,'','',strInvalidField);
        }
    }

    @AuraEnabled
    public static void deleteRecord(Id recordId){
        String objParent=recordId.getSObjectType().getDescribe().getName();
        String queryString='SELECT Id FROM '+objParent+' WHERE Id = \''+recordId+'\' ';
        list<SObject> lstSObject=Database.query(queryString);
        Delete lstSObject;
    }

    @AuraEnabled
    public static UserRecordAccess getUserPemissions(String recordId) {
        UserRecordAccess ura = [SELECT RecordId, HasEditAccess, HasDeleteAccess from UserRecordAccess where UserId = :UserInfo.getUserId() and RecordId = :recordId];

        return ura;
    }

    public static String getChildRelationshipName(
        String childName,
        String parentName,
        String strFieldName
    )
    {
        SObjectType childSObjectType = Schema.getGlobalDescribe().get(childName);
        List<ChildRelationship> childRelationships = Schema.getGlobalDescribe().get(parentName).getDescribe().getChildRelationships();
        for (ChildRelationship current : childRelationships) {
            SObjectType curChildSObject = current.getChildSObject();
            String strRelationShipFieldName = current.getField().getDescribe().getName();
            if (curChildSObject == childSObjectType) {
                if(strFieldName == Null || strRelationShipFieldName == strFieldName)
                    return current.getRelationshipName();
            }
        }

        return null;
    }
    
    @AuraEnabled
    public static list<RecordType> getRecordType(String strObjectName){
         return [SELECT Id,Name FROM RecordType WHERE SobjectType=: strObjectName];
    }
    
    @AuraEnabled
    public static String getName(String selectedObject){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
        return String.valueOf(ObjectSchema.getDescribe().getLabel());
    }
    
    @AuraEnabled
    public static ProfileAccessForObject getProfileAccessForMainObj(String selectedObject){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get(selectedObject);
        return new ProfileAccessForObject(ObjectSchema.getDescribe().isCreateable(),ObjectSchema.getDescribe().isUpdateable() ,ObjectSchema.getDescribe().isDeletable());
    }
    
    Public class ProfileAccessForObject{
        @AuraEnabled Boolean isCreatable {get; set;}
        @AuraEnabled Boolean isEditable {get; set;}
        @AuraEnabled Boolean isDeletable {get; set;}
        
        Public ProfileAccessForObject(Boolean isCreatable, Boolean isEditable, Boolean isDeletable) {
            this.isCreatable = isCreatable;
            this.isEditable = isEditable;
            this.isDeletable = isDeletable;
        }
    }
}