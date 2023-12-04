@RestResource(urlMapping='/getUpdatedObjects/*')
global with sharing class PIT_UpdatedObjectService {
    
    @HttpPost
    global static Map<String,String> getUpdatedRecords(String objectName, DateTime since, String queryType, String[] relatedObjects, Boolean includeMainObjectIds, Integer offset, String whereClause,
                                                        String externalId) {
        Set<String> availableQueryTypes = new Set<String>{'deleted','updated','created','all'};
        Integer maxChunkSize = 2000;
        Boolean checkVisibility;
        
        Set<Id> updatedRecordsIds = new Set<Id>();
        Map<String,String> responseMap = new Map<String,String>();
        
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        SObjectType mainObjType = globalDescribe.get(objectName);
        
        if(mainObjType == null) {
            responseMap.put('Error', 'Incorrect objectName');
            return responseMap;
        }
        
        
        if(!availableQueryTypes.contains(queryType)) {
            responseMap.put('Error', 'Incorrect queryType ' + queryType + '. Possible values: ' + availableQueryTypes);
            return responseMap;
        }
        
        
        Schema.DescribeSObjectResult mainObjectDescribeResult = mainObjType.getDescribe(); 
        if(!mainObjectDescribeResult.isQueryable()) {
            responseMap.put('Error', 'The mainObject is not accessible for this user: ' + mainObjectDescribeResult.getName());
            return responseMap;
        }
        
        
        List<Schema.ChildRelationship> mainObjectChildRelationships = mainObjectDescribeResult.getChildRelationships();
        Map<String, Schema.ChildRelationship> mapNameToChildRelationship = new Map<String, Schema.ChildRelationship>();
        for(Schema.ChildRelationship childRel : mainObjectChildRelationships) {
            mapNameToChildRelationship.put(childRel.getRelationshipName(),childRel);
        }        
       
        if(relatedObjects == null) {
            relatedObjects = new List<String>();
        }
       
        List<Schema.ChildRelationship> childRelationshipsToQuery = new List<Schema.ChildRelationship>();
        for(String relatedObject : relatedObjects) {
            Schema.ChildRelationship childRel = mapNameToChildRelationship.get(relatedObject);
            if(childRel == null) {
                responseMap.put('Error', 'Incorrect relatedObject name ' + relatedObject);
                return responseMap;
            } else {
                SObjectType childObjType = childRel.getChildSObject();
                sObject childObject = childObjType.newSObject();
                Schema.DescribeSObjectResult childObjectDescribeResult = childObjType.getDescribe();
                if(!childObjectDescribeResult.isQueryable()) {
                    responseMap.put('Error', 'The relatedObject is not accessible for this user: ' + childObjectDescribeResult.getName());
                    return responseMap;
                }
                childRelationshipsToQuery.add(childRel); 
            }
        }
        
        if(includeMainObjectIds == null) {
            responseMap.put('Error', 'Please provide includeMainObjectIds value: true or false');
            return responseMap;
        }
        
        if((relatedObjects == null || relatedObjects.isEmpty()) && includeMainObjectIds == true) {
            checkVisibility = false;
        } else {
            checkVisibility = true;
        }    
        
        String queryFilter;
        if(queryType == 'updated') {
            queryFilter = ' WHERE SystemModstamp > :since AND CreatedDate < :since';
        }
        if(queryType == 'deleted') {
            queryFilter = ' WHERE SystemModstamp > :since AND isDeleted = true';
        }
        if(queryType == 'created') {
            queryFilter = ' WHERE CreatedDate > :since';
        }
        if(queryType == 'all') {
            queryFilter = ' WHERE SystemModstamp > :since';
        }
        
        
        Set<id> visibilitySet = new Set<id>();
        if(whereClause != null && whereClause != '' && checkVisibility) {
            try {
                String queryString = 'SELECT id FROM ' + mainObjectDescribeResult.getName() + ' WHERE ' + whereClause;
                if(queryType == 'deleted' || queryType == 'all') {
                     queryString += ' ALL ROWS';
                }
                System.debug('visibilityQuery: ' + queryString);
                for(SObject obj: Database.query(queryString)) {
                    visibilitySet.add(obj.id);
                }
            
            } catch (Exception e) {
                responseMap.put('Error', 'Problem with whereClause: ' + e.getMessage());
                return responseMap;
            }   
            
        }
        
        if(includeMainObjectIds) {
            String queryString = 'SELECT id FROM ' + mainObjectDescribeResult.getName() + queryFilter;
            if(whereClause != null && whereClause != '') {
                queryString += ' AND ' + whereClause;
            }
            if(queryType == 'deleted' || queryType == 'all') {
                     queryString += ' ALL ROWS';
            }
            System.debug('mainObjectQuery: ' + queryString);
           
            try {                
                for(SObject obj : Database.query(queryString)) {
                    updatedRecordsIds.add(obj.id);
                }
            } catch (Exception e) {
                responseMap.put('Error', 'Problem with whereClause: ' + e.getMessage());
                return responseMap;
            }                  
        }    
        
        for(Schema.ChildRelationship childRel : childRelationshipsToQuery) {
            String queryString = 'SELECT ' + childRel.getField() + ' FROM ' + childRel.getChildSObject().getDescribe().getName() + queryFilter;
            if(checkVisibility && whereClause != null && whereClause != '') {
                queryString += ' AND ' + childRel.getField() + ' IN :visibilitySet';
            }
            queryString += ' AND ' + childRel.getField() + ' NOT IN :updatedRecordsIds';
            if(queryType == 'deleted' || queryType == 'all') {
                     queryString += ' ALL ROWS';
            }
            System.debug('childQuery: ' + queryString);                      

            for(SObject childObject : Database.query(queryString)) {
                Id parentSobjectId = (Id) childObject.get(childRel.getField());
                if(parentSobjectId != null) {
                    updatedRecordsIds.add(parentSobjectId);
                }
            }
        }
        
        List<Id> updatedRecordsIdsList = new List<Id>();
        updatedRecordsIdsList.addAll(updatedRecordsIds);
        updatedRecordsIdsList.sort();
        
       /* List<Id> updatedRecordsIdsListVisibility = new List<Id>();
        if(whereClause != null && whereClause != '' && checkVisibility == true) {
            for(id updatedId : updatedRecordsIdsList) {
                if(visibilitySet.contains(updatedId)) {
                    updatedRecordsIdsListVisibility.add(updatedId);
                }
            }
            
            updatedRecordsIdsList = updatedRecordsIdsListVisibility;
        }*/
        
        Integer recordCount = updatedRecordsIdsList.size();
        if(offset == null) {
            offset = 0;
        }
        
        if(recordCount < offset) {
            responseMap.put('Error', 'The offset parameter: ' + offset + ' is greater than recordCount: ' + recordCount);
            return responseMap;
        }
        
       
        
        List<Id> updatedRecordIdsListToReturn = new List<Id>();
        
        for(Integer i=offset; (i < offset+maxChunkSize && i < recordCount); i++) {
            updatedRecordIdsListToReturn.add(updatedRecordsIdsList[i]);
        }
        
        List<String> updatedRecordExternalIdList = new List<String>();
        if(externalId != null && externalId != '') {
            try {
                 String queryString = 'SELECT ' + externalId + ' FROM ' + mainObjectDescribeResult.getName() + ' WHERE id IN ' + updatedRecordIdsListToReturn;
                 if(queryType == 'deleted' || queryType == 'all') {
                     queryString += ' ALL ROWS';
                 }
                 
                 for(sObject mainObject : Database.query('SELECT ' + externalId + ' FROM ' + mainObjectDescribeResult.getName() + ' WHERE id IN :updatedRecordIdsListToReturn' ) ){
                     updatedRecordExternalIdList.add(String.valueOf(mainObject.get(externalId)));
                 }
            } catch (Exception e) {
                responseMap.put('Error: problem with ExternalId. ', e.getMessage());
                return responseMap;
            }
        }
        
        if(externalId != null && externalId != '') {
            responseMap.put('updatedRecordsIds', JSON.serialize(updatedRecordExternalIdList));
        } else {
            responseMap.put('updatedRecordsIds', JSON.serialize(updatedRecordIdsListToReturn));
        }    
        responseMap.put('offset', String.valueOf(offset));
        responseMap.put('currentChunkSize', String.valueOf(updatedRecordIdsListToReturn.size()));        
        responseMap.put('allUpdatedRecordsCount', String.valueOf(recordCount));
        return responseMap;
    }
    
   
}