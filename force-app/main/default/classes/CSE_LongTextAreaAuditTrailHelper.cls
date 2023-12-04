/**
* @ClassName    : CSE_LongTextAreaAuditTrailHelper
* @JIRATicket   : CSE-49
* @CreatedOn    : 12/07/2021
* @CreatedBy    : Jyothsna Jogi
* @Description  : Helper Class to insert the new records when ever long Text area fields
                  are updated for certain objects as a part of filed tracking
**/
public with sharing class CSE_LongTextAreaAuditTrailHelper {
    public void filterTextAreaChangedRecords(List<SObject> newList, Map<Id, SObject> oldMap, String fieldSetName) {
       System.debug('data from filtertextarachanges records newList ' + newList);
       System.debug('data from filtertextarachanges records  oldMap' + oldMap);
       System.debug('data from filtertextarachanges records fieldSetName ' + fieldSetName);
        Schema.DescribeSObjectResult objDescribe = newList.get(0).getSObjectType().getDescribe();
        //get the field set
        Map<String, Schema.FieldSet> fieldSet = objDescribe.fieldSets.getMap();
        List<ZTS_US_CSE_Audit_Trail__c> auditTrailsToInsert = new List<ZTS_US_CSE_Audit_Trail__c>();
       
        if(fieldSet != null && fieldSet.get(fieldSetName) != null) {
            //get the field api names from fieldset
            List<String> filedsToConsider = getFieldApiName(fieldSet.get(fieldSetName).getFields());
            
            for(SObject obj : newList) {
                //iterate each field from fieldset
                for(String longTextField : filedsToConsider) {
                    if(obj.get(longTextField) != oldMap.get(obj.Id).get(longTextField)) {
                        //if value is changed create new audit
                        auditTrailsToInsert.add(generateAuditTrail(oldMap.get(obj.Id), obj, objDescribe.getName(), objDescribe.getLabel(), longTextField));
                    }
                }
            }
        }
        if(!auditTrailsToInsert.isEmpty()) {
            System.debug('line34&&&---'+auditTrailsToInsert);
            insert auditTrailsToInsert;
        }
    }
    // Method to get the field name
    private static List<String> getFieldApiName(List<Schema.FieldSetMember> fields) {
        List<String> fieldsApiNames = new List<String>();
        for(Schema.FieldSetMember fieldMem : fields) {
            fieldsApiNames.add(fieldMem.getFieldPath());
        }

        return fieldsApiNames;
    }
    // Method to create Audit trail record
    private static ZTS_US_CSE_Audit_Trail__c generateAuditTrail(sObject oldObj, sObject newObj,String objName, String objLabel, String fieldName) {
        return new ZTS_US_CSE_Audit_Trail__c(
            Field_Name__c = fieldName,
            New_Value__c = (String)newObj.get(fieldName),
            Old_Value__c = (String)oldObj.get(fieldName),
            Object_Name__c = objName,
            Object_Label__c = objLabel,
            Record_Id__c = (String)newObj.get('Id')
        );
    }
}