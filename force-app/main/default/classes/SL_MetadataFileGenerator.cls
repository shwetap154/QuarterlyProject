public without sharing class SL_MetadataFileGenerator {

    public static void generateMetadataFilesForOrg() {
        Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
        List<String> typesToProcess = new List<String>();
        for (String sobjectTypeName : globalMap.keySet()) {
            typesToProcess.add(sobjectTypeName);
            if (typesToProcess.size() >= 50) {
                createFilesForTypes(typesToProcess);
                typesToProcess = new List<String>();
            }
        }

        createFilesForTypes(typesToProcess);
    }

    public static void createFileForType(String sObjectTypeName) {
        Map<String, Map<String, Object>> fieldTripData = getFieldTripDataByFieldByObject(new List<String> { sObjectTypeName });
        ContentVersion file = createFileFromSObjectType(sobjectTypeName, fieldTripData.get(sobjectTypeName.toLowerCase()));
        insert file;
    }

    @Future
    public static void createFilesForTypes(List<String> sObjectTypeNames) {
        Map<String, Map<String, Object>> fieldTripData = getFieldTripDataByFieldByObject(sObjectTypeNames);
        List<ContentVersion> files = new List<ContentVersion>();
        for (String sobjectTypeName : sObjectTypeNames) {
            files.add(createFileFromSObjectType(sobjectTypeName, fieldTripData.get(sobjectTypeName.toLowerCase())));
        }
        //insert files;
    }

    public static ContentVersion createFileFromSObjectType(String sobjectTypeName, Map<String, Object> fieldTripData) {
        List<String> csv = new List<String>();
        csv.add(createCsvHeader());
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobjectTypeName).getDescribe().fields.getMap();
        //Map<String, String> fieldReferences = getFieldReferences(fieldMap);
        for (Schema.SObjectField fieldMetadataObject : fieldMap.values()) {
            List<String> fieldValues = createValuesForField(fieldMetadataObject.getDescribe(), fieldTripData);
            csv.add(String.join(fieldValues, ','));
            
        }

        return createFile(csv, Schema.getGlobalDescribe().get(sobjectTypeName).getDescribe().getLabel());
    }

    private static ContentVersion createFile(List<String> csv, String fileName) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = blob.valueOf(String.join(csv, '\n'));
        cv.Title = fileName;
        cv.PathOnClient = fileName + '.csv';

        return cv;
    }

    private static String createCsvHeader() {
        List<String> headerValues = new List<String>();
        headerValues.add('Byte Length');
        headerValues.add('Calculated Formula');
        headerValues.add('Controller');
        headerValues.add('Default Value');
        headerValues.add('Default Value Formula');
        headerValues.add('Digits');
        headerValues.add('Inline Help Text');
        headerValues.add('Label');
        headerValues.add('Length');
        headerValues.add('Local Name');
        headerValues.add('Name');
        headerValues.add('Picklist Values');
        headerValues.add('Precision');
        headerValues.add('Reference Target Field');
        headerValues.add('Reference To');
        headerValues.add('Relationship Name');
        headerValues.add('Relationship Order');
        headerValues.add('Scale');
        headerValues.add('SOAP Type');
        headerValues.add('SObject Field');
        headerValues.add('Type');
        //headerValues.add('isAccessible');
        headerValues.add('is Ai Prediction Field');
        headerValues.add('is Auto Number');
        headerValues.add('is Calculated');
        headerValues.add('is Cascade Delete');
        headerValues.add('is Case Sensitive');
        //headerValues.add('isCreateable');
        headerValues.add('is Custom');
        headerValues.add('is Defaulted On Create');
        headerValues.add('is Dependent Picklist');
        headerValues.add('is Deprecated And Hidden');
        headerValues.add('is External ID');
        headerValues.add('is Filterable');
        headerValues.add('is Formula Treat Null Number As Zero');
        headerValues.add('is Groupable');
        headerValues.add('is Html Formatted');
        headerValues.add('is Id Lookup');
        headerValues.add('is Name Field');
        headerValues.add('is Name Pointing');
        headerValues.add('is Nillable');
        headerValues.add('is Permissionable');
        headerValues.add('is Restricted Delete');
        headerValues.add('is Restricted Picklist');
        headerValues.add('is Search Prefilterable');
        headerValues.add('is Sortable');
        headerValues.add('is Unique');
        //headerValues.add('isUpdateable');
        headerValues.add('is Write Requires Master Read');
        headerValues.add('Field Trip Data');
        return String.join(headerValues, ',');
    }

    private static List<String> createValuesForField(Schema.DescribeFieldResult fieldDescribeMetadata, Map<String, Object> fieldTripData) {
        List<String> fieldValues = new List<String>();
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getByteLength()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getCalculatedFormula()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getController()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getDefaultValue()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getDefaultValueFormula()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getDigits()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getInlineHelpText()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getLabel()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getLength()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getLocalName()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getName()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getPicklistValues()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getPrecision()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getReferenceTargetField()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getReferenceTo()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getRelationshipName()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getRelationshipOrder()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getScale()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getSOAPType()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getSObjectField()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.getType()));
        //fieldValues.add(getObjectAsString(fieldDescribeMetadata.isAccessible()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isAiPredictionField()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isAutoNumber()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isCalculated()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isCascadeDelete()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isCaseSensitive()));
        //fieldValues.add(getObjectAsString(fieldDescribeMetadata.isCreateable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isCustom()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isDefaultedOnCreate()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isDependentPicklist()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isDeprecatedAndHidden()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isExternalID()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isFilterable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isFormulaTreatNullNumberAsZero()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isGroupable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isHtmlFormatted()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isIdLookup()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isNameField()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isNamePointing()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isNillable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isPermissionable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isRestrictedDelete()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isRestrictedPicklist()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isSearchPrefilterable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isSortable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isUnique()));
        //fieldValues.add(getObjectAsString(fieldDescribeMetadata.isUpdateable()));
        fieldValues.add(getObjectAsString(fieldDescribeMetadata.isWriteRequiresMasterRead()));

        fieldValues.add(getObjectAsString(fieldTripData.get(fieldDescribeMetadata.getName().toLowerCase())));
        return fieldValues;
    }

    private static String getObjectAsString(Object objectToStringify) {
        String value = String.valueOf(objectToStringify);

        if (value != null) {
            value = value.replace('"', '""');
            value = value.replace('\n', ' ');
        }

        return '"' + value + '"';
    }
    
    private static Map<String, Map<String, Object>> getFieldTripDataByFieldByObject(List<String> objectList) {
        List<Field_Trip__Field_Analysis__c> analysisData = [SELECT Name, Field_Trip__Populated_On_Percent__c, Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c FROM Field_Trip__Field_Analysis__c WHERE Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c IN :objectList];

        Map<String, Map<String, Object>> dataMap = new Map<String, Map<String, Object>>();
        for (Field_Trip__Field_Analysis__c fieldData : analysisData) {
            if (!dataMap.containsKey(fieldData.Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c)) {
                dataMap.put(fieldData.Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c, new Map<String, Object>());
            }

            dataMap.get(fieldData.Field_Trip__Object_Analysis__r.Field_Trip__Object_Name__c).put(fieldData.Name, fieldData.Field_Trip__Populated_On_Percent__c);
        }

        return dataMap;
    }

    @TestVisible private static Map<String, String> getFieldReferences(Map<String, Schema.SObjectField> fieldMap) {
        Set<Id> ids = buildFieldIdList(fieldMap);
        //List<Schema.MetadataComponentDependency> test = [SELECT MetadataComponentName, MetadataComponentType FROM MetadataComponentDependency WHERE RefMetadataComponentId IN :ids];
        return null;
    }
    
    private static Set<Id> buildFieldIdList(Map<String, Schema.SObjectField> fieldMap) {
        Set<Id> idsToReturn = new Set<Id>();
        for (String fieldName : fieldMap.keySet()) {
            //idsToReturn.add(fieldMap.get(fieldName).Id;
        }
        return idsToReturn;
    }
}