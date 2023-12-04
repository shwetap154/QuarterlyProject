public with sharing class GetUserAvailableRecordTypes {

    @InvocableMethod(label = 'Get Contact and Case Patient Record Types User has access to' description='Retrieve visible record types based on user permission')
    public static List<List<RecordType>> getRecordTypes(){
        List<RecordType> recordTypes = [Select Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType='Contact' OR  SObjectType='ZTS_US_Case_Animal__c' ];
        
        Schema.DescribeSobjectResult contactSchema = Schema.SobjectType.Contact;
        Schema.DescribeSobjectResult casePatientSchema = Schema.SobjectType.ZTS_US_Case_Animal__c;

        Map<Id,Schema.RecordTypeInfo> rtContactMapById = contactSchema.getRecordTypeInfosById();
        Map<Id,Schema.RecordTypeInfo> rtCasePatientMapById = casePatientSchema.getRecordTypeInfosById();

        Map<Id,Schema.RecordTypeInfo> rtMapById = new Map<Id,Schema.RecordTypeInfo>();
        rtMapById.putAll(rtContactMapById);
        rtMapById.putAll(rtCasePatientMapById);

        List<RecordType> filteredRecordTypes = new List<RecordType>();
        for(RecordType rtype: recordTypes){
            if(rtype.SobjectType=='Contact' && contactSchema.isCreateable()){
                Schema.RecordTypeInfo recordTypeInfo = rtMapById.get(rtype.Id);
                if(recordTypeInfo.isAvailable()){
                    filteredRecordTypes.add(rtype);
                }
            }

            if(rtype.SobjectType=='ZTS_US_Case_Animal__c' && casePatientSchema.isCreateable()){
                Schema.RecordTypeInfo recordTypeInfo = rtMapById.get(rtype.Id);
                if(recordTypeInfo.isAvailable()){
                    filteredRecordTypes.add(rtype);
                }
            }
        }

        List<List<RecordType>> result = new List<List<RecordType>>();
        result.add(filteredRecordTypes);
        return result;
    }
}