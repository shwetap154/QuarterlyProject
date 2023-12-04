/*
  @File Name          : ConfigurableRelatedListController.cls
  @Description        : This file containes the code needed for getting the related list records, label names,
                        and user permissions to edit, create, and delete on related record list.
  @Author             : Slalom run:CRM
  @Group              : run:CRM
  @Last Modified By   : marshall.lanners@slalom.com
  @Last Modified On   : 6/18/2020, 10:00:00 AM
*/

public class ConfigurableRelatedListController {

    // this wrapper class is used to make an easy return type used for accessing values in the LWC component.
    public class Wrapper {

        @AuraEnabled public List<SObject> recordList;
        @AuraEnabled public String objectName;
        @AuraEnabled public String objectLabel;
        @AuraEnabled public Map<String, Map<String,String>> labelNames;
        @AuraEnabled public Boolean canCreate;
        @AuraEnabled public Boolean canDelete;
        @AuraEnabled public String parentRecordField;
        @AuraEnabled public String RecordTypeId;
        @AuraEnabled public List<String> createFields;

        public Wrapper(List<SObject> recordList, String objectName, String objectLabel, Map<String, Map<String,String>> labelNames, Boolean canCreate, Boolean canDelete, String parentRecordField, String RecordTypeId, List<String> createFields){
            this.recordList = recordList;
            this.objectName = objectName;
            this.objectLabel = objectLabel;
            this.labelNames = labelNames;
            this.canCreate = canCreate;
            this.canDelete = canDelete;
            this.parentRecordField = parentRecordField;
            this.RecordTypeId = RecordTypeId;
            this.createFields = createFields;
        }
    }

    public static ConfigurableRelatedList__mdt createMetadataRecord(){
        ConfigurableRelatedList__mdt customMetadata = new ConfigurableRelatedList__mdt();
        customMetadata.Display_Fields__c = 'Name,StageName,Amount';
        customMetadata.Name__c = 'test record';
        customMetadata.Parent_Record_Field__c = 'AccountId';
        customMetadata.SObject__c = 'Opportunity';
        customMetadata.Where_Clause__c = 'Stagename = ' + '\''+ 'Prospecting' + '\'';
        return customMetadata;
    }

    // gets record Id. Only used if RecordType_Name__c field was filled out in metadata record.
    public static String getRecordTypeId(String recordTypeName){
        return [SELECT Id FROM RecordType WHERE Name = :recordTypeName LIMIT 1].Id;
    }

    // gets the boolean value of whether or not the current user can create new objects in the related list.
    public static Boolean canCreate(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }

    // gets the boolean value of whether or not the current user can delete objects in the related list.
    public static Boolean canDelete(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }

    // gets label of the object
    public static String getLabel(String objectName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(objectName);
        return schemaType.getDescribe().getLabel();
    }

    // returns the related list, access variables, and object name based on metadata record in a new instance of the wrapper class.
    @AuraEnabled(cacheable=true)
    public static Wrapper getRelatedList(String customMetadataName, String id, Boolean baseCreate)
    {
        ConfigurableRelatedList__mdt customMetadata =
        (   baseCreate
        ?   ConfigurableRelatedListController.createMetadataRecord()
        :   [   SELECT  Create_Fields__c, Display_Fields__c,
                        SObject__c, Parent_Record_Field__c,
                        Where_Clause__c, RecordType_Name__c, Query_Fields__c
                FROM    ConfigurableRelatedList__mdt
                WHERE   Name__c = :customMetadataName
                LIMIT 1
            ]
        );
        if ( customMetadata == null ) return null;

        List<String> whereClauses = new List<String>();

        // in case filtering is needed for parent record
        if (customMetadata.Parent_Record_Field__c != null) {
            whereClauses.add( customMetadata.Parent_Record_Field__c + ' = \''+ id + '\'' );
        }

        // in case filtering is needed for record type
        String recordTypeId;
        if (customMetadata.RecordType_Name__c != null) {
            recordTypeId = getRecordTypeId(customMetadata.RecordType_Name__c);
            whereClauses.add( 'RecordTypeId = \''+ recordTypeId + '\'' );
        }

        // in case filtering is needed for where clause
        if (customMetadata.Where_Clause__c != null) {
            List<String> whereSplits = customMetadata.Where_Clause__c.split( '\\{@' );
            List<String> whereParts = new List<String>{ whereSplits[0] };
            Set<String> recordFields = new Set<String>();
            System.debug( 'whereSplits = ' + whereSplits );
            for ( String split : whereSplits )
            {
                List<String> splitParts = split.split( '\\}' );
                System.debug( 'splitParts = ' + splitParts );
                if ( splitParts.size() < 2 ) continue;
                recordFields.add( splitParts[0] );
            }
            sObject record;
            System.debug( 'recordFields = ' + recordFields );
            if ( !recordFields.isEmpty() )
            {
                record = Database.query
                (   'SELECT ' + String.join( new List<String>( recordFields ), ',' )
                +   ' FROM ' + ((Id) id).getSObjectType()
                +   ' WHERE Id = \'' + id + '\''
                )[0];
            }
            System.debug( 'whereSplits = ' + whereSplits );
            for ( String split : whereSplits )
            {
                List<String> splitParts = split.split( '\\}' );
                System.debug( 'splitParts = ' + splitParts );
                if ( splitParts.size() < 2 ) continue;
                whereParts.add( record?.get( splitParts[0] )?.toString() );
                whereParts.add( splitParts[1] );
            }
            whereClauses.add( '(' + String.join( whereParts, '' ) + ')' );
        }


        return  new Wrapper
        (   Database.query
            (   'SELECT ' + customMetadata.Display_Fields__c + (String.isBlank( customMetadata.Query_Fields__c ) ? '' : ',' + customMetadata.Query_Fields__c)
            +   ' FROM ' + customMetadata.SObject__c
            +   (   !whereClauses.isEmpty()
                ?   ' WHERE ' + String.join( whereClauses, ' AND ' )
                :   ''
                )
            )
        ,   customMetadata.SObject__c
        ,   getLabel( customMetadata.SObject__c )
        ,   getRelatedLabels( customMetadata, id, baseCreate )
        ,   canCreate( customMetadata.SObject__c )
        ,   canDelete( customMetadata.SObject__c )
        ,   customMetadata.Parent_Record_Field__c
        ,   recordTypeId
        ,   customMetadata.Create_Fields__c?.split( ',' )
        );

    }

    // This function brings the labels of the fields on the master Sobject. Used in making the columns with datatable in the lwc component.
    public static Map<String, Map<String,String>> getRelatedLabels(ConfigurableRelatedList__mdt customMetadata, String id, Boolean baseCreate)
    {
       
        String type = String.valueOf(customMetadata.get('SObject__c'));
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, Map<String,String>> fieldMapLabels =  new Map<String, Map<String,String>>() ;

        String labelFromMap;
        String apiNameFromMap;
        String typeFromMap;

        Set<String> displayFields = new Set<String>( customMetadata.Display_Fields__c.deleteWhitespace().toLowerCase().split(',') );
        displayFields.add('id');
        
        for (String fieldName: fieldMap.keySet())
        {
            if ( !displayFields.contains( fieldName ) ) continue;
            // list of all field API name
            //It provides to get the object fields label.
            apiNameFromMap = String.valueOf(fieldMap.get(fieldName));
            labelFromMap = fieldMap.get(fieldName).getDescribe().getLabel();
            typeFromMap = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());

            Map<String, String> fieldMapInfo =  new Map<String, String>() ;
            fieldMapInfo.put('label',labelFromMap);
            fieldMapInfo.put('type',typeFromMap);

            fieldMapLabels.put(apiNameFromMap,fieldMapInfo);
        }
        return fieldMapLabels;
    }
}