/**
 * @description       : Common class for logic and classes used to Merge data together
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-25-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with setLookupField, getChildRelationshipsForObjects, 
 *                                                and setLookupFieldsAndDeleteRecords methods and UpdateRelatedRecordsMap class.
 * 1.1   06-02-2022   Ethan Hirsch @ Zoetis Inc   Add setUniqueKeyField method to allow for setting unique key fields in a consistent way
 * 1.2   09-08-2022   Ethan Hirsch @ Zoetis Inc   Fix a bug in setUniqueKeyField where there was an unnecessary cast that could cause errors.
 *                                                Add setFieldValue to the UpdateRelatedRecordsMap class to make it easier to set an existing field..
 * 1.3   09-19-2022   Ethan Hirsch @ Zoetis Inc   Add logic for retrieving related data that can be used in a Selector
 *                                                class to avoid the child relationship limit.
 **/
public with sharing class MergeService {
    private static final Integer MAX_CHILD_RELATIONSHIPS_IN_SOQL = 20;
    /**
    * @description Sets the specified lookup field on the passed in records.
    *              This method uses updateRelatedRecordsMap to make sure only one instance of a record is created per transaction.
    * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
    * @param records 
    * @param lookupField 
    * @param value 
    * @param updateRelatedRecordsMap 
    **/
    public static void setLookupField(List<SObject> records, string lookupField, Id value,
        UpdateRelatedRecordsMap updateRelatedRecordsMap, String checkboxField) {
        if (records == null) {
            return;
        }

        for (SObject record : records) {
            // Make sure only one instance of a record is created and updates to other fields are not lost
            Schema.SObjectType objectType = record.getSObjectType();
            SObject updateRecord = updateRelatedRecordsMap.get(objectType, record.Id);
            if (updateRecord == null) {
                updateRecord = objectType.newSObject(record.Id);
            }

            updateRecord.put(lookupField, value);

            if (String.isNotBlank(checkboxField)) {
                updateRecord.put(checkboxField, true);
            }

            updateRelatedRecordsMap.add(updateRecord);
        }
    }

    /**
    * @description This method consolidates common logic in merge logic for doing two things:
    *              1. Identifying the records to be deleted due to a duplicate being found
    *              2. Transfer child records of the duplicate record being deleted to its matching record being kept.
    * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
    * @param uniqueKey 
    * @param keepRecordsByUniqueKey 
    * @param recordsByUniqueKey 
    * @param childRelationships 
    * @param updateRelatedRecordsMap 
    * @return DeleteRecordsAndKeepRecord 
    **/
    public static DeleteRecordsAndKeepRecord setLookupFieldsAndDeleteRecords(String uniqueKey,
        Map<String, SObject> keepRecordsByUniqueKey, Map<String, List<SObject>> recordsByUniqueKey, 
        List<MergeChildRelationship> childRelationships, 
        Map<Id, MergeService.RecordAndRelationships> recordsAndRelationshipsMap,
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        List<SObject> deleteRecords = new List<SObject>();
        SObject keepRecord = keepRecordsByUniqueKey.get(uniqueKey);

        for (SObject record : recordsByUniqueKey.get(uniqueKey)) {
            if (record.Id == keepRecord.Id) {
                continue;
            }

            RecordAndRelationships recordAndRelationships = recordsAndRelationshipsMap.get(record.Id);
            for (MergeChildRelationship childRelationship : childRelationships) {
                List<SObject> childRecords = recordAndRelationships.relationshipsMap.get(
                    childRelationship.childRelationship.getRelationshipName());
                    
                MergeService.setLookupField(childRecords, 
                    childRelationship.childRelationship.getField().getDescribe().getName(), 
                    keepRecord.Id, updateRelatedRecordsMap, childRelationship.CheckboxField);
            }

            deleteRecords.add(record);
        }

        return new DeleteRecordsAndKeepRecord(keepRecord, deleteRecords);
    }

    /**
    * @description Gets the Relationship Metadata for the child objects for the passed in SObject Type.
    *              All relationships for the Child Object will be returned if there are multiples
    * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
    * @param childObjects 
    * @param parentType 
    * @return List<Schema.ChildRelationship> 
    **/
    public static List<MergeChildRelationship> getChildRelationshipsForObjects(Map<String, MergeRelatedRecordLookupsSelector.ChildObject> childObjectsByName, Schema.SObjectType parentType) {
        List<MergeChildRelationship> childRelationships = new List<MergeChildRelationship>();
        
        for (Schema.ChildRelationship childRelationship : parentType.getDescribe().getChildRelationships()) {
            String objectName = childRelationship.getChildSObject().getDescribe().getName();
            if (childObjectsByName.containsKey(objectName) && 
                childRelationship.getRelationshipName() != null) {
                childRelationships.add(new MergeChildRelationship(childRelationship, 
                    childObjectsByName.get(objectName).CheckboxField));
            }
        }

        return childRelationships;
    }

    /**
    * @description Sets the passed in unique key field if it's not blank and does not match the expected value
    * @author Ethan Hirsch @ Zoetis Inc | 06-02-2022 
    * @param record 
    * @param fieldName 
    * @param expectedValue 
    * @param updateRelatedRecordsMap 
    **/
    public static void setUniqueKeyField(SObject record, string fieldName, string expectedValue, 
        string compareValue, MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        string uniqueKeyValue = (String)record.get(fieldName);
        if (string.isNotBlank(uniqueKeyValue) &&
            // To avoid unnecssary updates, the Key is only updated if the compareValue is not present in the key
            !uniqueKeyValue.contains(compareValue)) {

            Schema.SObjectType objectType = record.getSObjectType();
            updateRelatedRecordsMap.setFieldValue(objectType, fieldName, expectedValue, record.Id);
        }
    }

    /**
     * @description This method should be called from a Selector class and is meant to execute queries for records and
     *     child relationships. It does this in a way to prevent issues with querying more than 20 relationships at once.
     * @author Ethan Hirsch @ Zoetis Inc | 09-19-2022 
     * @param queryBase 
     * @param querySuffix 
     * @param childRelationships 
     * @return List<MergeService.RecordAndRelationships>
     */
    public static Map<Id, RecordAndRelationships> queryRelatedData(String queryBase, String querySuffix, 
        List<MergeChildRelationship> childRelationships) {
        // Queries are built using a List<String> and String.join for performance reasons
        Map<Id, RecordAndRelationships> recordsAndRelationshipMap = new Map<Id, RecordAndRelationships>();

        List<String> queryBuilder = new List<String>();
        queryBuilder.add(queryBase);

        List<String> relationships = new List<String>();

        for (MergeService.MergeChildRelationship childRelationship : childRelationships) {
            String relationshipName = childRelationship.ChildRelationship.getRelationshipName();
            relationships.add(relationshipName);
        
            queryBuilder.add(String.format(' , (SELECT Id from {0})', 
                new List<String> {relationshipName}));
        
            if (relationships.size() >= MAX_CHILD_RELATIONSHIPS_IN_SOQL) {
                executeQueryRelatedData(queryBuilder, querySuffix, relationships, recordsAndRelationshipMap);
                relationships = new List<String>();
        
                queryBuilder = new List<String>();
                queryBuilder.add(queryBase);
            }
        }
        
        if (!relationships.isEmpty()) {
            executeQueryRelatedData(queryBuilder, querySuffix, relationships, recordsAndRelationshipMap);
        }
    
        return recordsAndRelationshipMap;
    }

    /**
     * @description Executes a query for a record and its related data and stores the results in a map. 
     *     This is done to cache relationships results when more than 20 relationships need to be queried. 
     * @author Ethan Hirsch @ Zoetis Inc | 09-19-2022 
     * @param queryBuilder 
     * @param querySuffix 
     * @param relationships 
     * @param recordsAndRelationshipMap 
     */
    private static void executeQueryRelatedData(List<String> queryBuilder, String querySuffix, List<String> relationships,
        Map<Id, MergeService.RecordAndRelationships> recordsAndRelationshipMap) {

        queryBuilder.add(querySuffix);
    
        for (SObject record : Database.query(String.join(queryBuilder, ''))) {
            if (recordsAndRelationshipMap.containsKey(record.Id) == false) {
                recordsAndRelationshipMap.put(record.Id, new MergeService.RecordAndRelationships(record));
            }
    
            MergeService.RecordAndRelationships recordAndRelationships = recordsAndRelationshipMap.get(record.Id);
    
            recordAndRelationships.addRelationships(record, relationships);
        }
    }

    // This class encapsulates the map of records to update by Object.
    public class UpdateRelatedRecordsMap {
        public Map<String, Map<Id, SObject>> updateRecordsMapByName {private set; get;}

        public UpdateRelatedRecordsMap() {
            this.updateRecordsMapByName = new Map<String, Map<Id, SObject>>();
        }

        /**
        * @description return the record being updated.
        * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
        * @param type 
        * @param recordId 
        * @return SObject 
        **/
        public SObject get(Schema.SObjectType type, Id recordId) {
            string objectName = type.getDescribe().getName();
            
            if (updateRecordsMapByName.containsKey(objectName) == false) {
                return null;
            }

            Map<Id, SObject> recordMap = updateRecordsMapByName.get(objectName);
            return recordMap.get(recordId);
        }

        /**
        * @description Add a record to be updated.
        * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
        * @param record 
        **/
        public void add(SObject record) {
            string objectName = record.getSObjectType().getDescribe().getName();
            if (!this.updateRecordsMapByName.containsKey(objectName)) {
                this.updateRecordsMapByName.put(objectName, new Map<Id, SObject>());
            }

            this.updateRecordsMapByName.get(objectName).put(record.Id, record);
        }

        /**
        * @description Set the value of an existing record's field
        * @author Ethan Hirsch @ Zoetis Inc | 09-08-2022 
        * @param objectType 
        * @param fieldName 
        * @param value 
        * @param recordId 
        **/
        public void setFieldValue(Schema.SObjectType objectType, String fieldName, object value, Id recordId) {
            SObject updateRecord = get(
                objectType, recordId);

            if (updateRecord == null) {
                updateRecord = objectType.newSObject(recordId);
            }

            updateRecord.put(fieldName, value);

            add(updateRecord);
        }
    }

    // This class enables the ability to return both records to delete and the record to keep from a method.
    public class DeleteRecordsAndKeepRecord {
        public SObject keepRecord;
        public List<SObject> deleteRecords;

        public DeleteRecordsAndKeepRecord(SObject keepRecord, List<SObject> deleteRecords) {
            this.keepRecord = keepRecord;
            this.deleteRecords = deleteRecords;
        }
    }

    public class MergeChildRelationship {
        public Schema.ChildRelationship ChildRelationship {get; private set;}
        public String CheckboxField {get; private set;}

        public MergeChildRelationship(Schema.ChildRelationship childRelationship, String checkboxField) {
            this.ChildRelationship = childRelationship;
            this.CheckboxField = checkboxField;
        }
    }

    public class RecordAndRelationships {
        public SObject record {get; private set;}
        public Map<String, List<SObject>> relationshipsMap {get; private set;}

        public RecordAndRelationships(SObject record) {
            this.record = record;
            this.relationshipsMap = new Map<String, List<SObject>>();
        }

        public void addRelationships(SObject record, List<String> relationships) {
            for (String relationship : relationships) {
                relationshipsMap.put(relationship, record.getSObjects(relationship));
            }
        }
    }
}