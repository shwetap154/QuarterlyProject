public class NewCaseFromAddressOverride {
    
    public class RecordTypeInfoWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String developerName { get; set; }
        @AuraEnabled public String RTDesc { get; set; }
        
        public RecordTypeInfoWrapper(String label, String developerName, String Id, String RTDesc) {
            this.label = label;
            this.developerName = developerName;
            this.Id = Id;
            this.RTDesc = RTDesc;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Id getAccountIdFromContact(Id contactId) {
        Contact con = [SELECT AccountId FROM Contact WHERE Id = :contactId LIMIT 1];
        if(con.AccountId!= null)
            return con.AccountId;
        else 
            return null;
    }
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeInfoWrapper> getRecordTypes(String objectName) {
        List<RecordTypeInfoWrapper> result = new List<RecordTypeInfoWrapper>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<Id, RecordType> recordTypeMapSOQLToBringDescriptions = new Map<Id, RecordType>([SELECT Id, Description FROM RecordType WHERE SobjectType=:objectName]);
        Schema.RecordTypeInfo defaultRecordType = null;
        
        
        for (Schema.RecordTypeInfo rtInfo : objectDescribe.getRecordTypeInfos()) {
            if (rtInfo.isDefaultRecordTypeMapping()) {
                defaultRecordType = rtInfo;
                break;
            }
        }
        
        
        if (defaultRecordType != null && recordTypeMapSOQLToBringDescriptions.containsKey(defaultRecordType.getRecordTypeId()) && !String.isBlank(recordTypeMapSOQLToBringDescriptions.get(defaultRecordType.getRecordTypeId()).Description)) {
            result.add(new RecordTypeInfoWrapper(defaultRecordType.getName(), defaultRecordType.getDeveloperName(), defaultRecordType.getRecordTypeId(),recordTypeMapSOQLToBringDescriptions.get(defaultRecordType.getRecordTypeId()).Description));
        } 

        
        // Add other record types
        for (Schema.RecordTypeInfo rtInfo : objectDescribe.getRecordTypeInfos()) {
            if (rtInfo.isAvailable() && !rtInfo.isDefaultRecordTypeMapping() && !rtInfo.isMaster()) {
                if (recordTypeMapSOQLToBringDescriptions.containsKey(rtInfo.getRecordTypeId()) && !String.isBlank(recordTypeMapSOQLToBringDescriptions.get(rtInfo.getRecordTypeId()).Description)) {
                    result.add(new RecordTypeInfoWrapper(rtInfo.getName(), rtInfo.getDeveloperName(), rtInfo.getRecordTypeId(),recordTypeMapSOQLToBringDescriptions.get(rtInfo.getRecordTypeId()).Description));
                    
                } else {
                    result.add(new RecordTypeInfoWrapper(rtInfo.getName(), rtInfo.getDeveloperName(), rtInfo.getRecordTypeId(),recordTypeMapSOQLToBringDescriptions.get(rtInfo.getRecordTypeId()).Description));
                }
            }
        }
        
        return result;
    }
}