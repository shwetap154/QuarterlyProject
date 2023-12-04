global class AffiliationReverseRecordCreationBatch implements Database.Batchable <sObject>{
    
    @testVisible static final String ERROR_LOG_ORIGIN_TYPE = 'AffiliationReverseRecordCreationBatch - execute: create reverse record creation';

    public final List<ZTS_EU_Account_Affiliations__c> affilationRecords;
    
    public AffiliationReverseRecordCreationBatch(List<ZTS_EU_Account_Affiliations__c> affiliationRecordsFromTrigger) {
        affilationRecords = affiliationRecordsFromTrigger;
    }

    global List<ZTS_EU_Account_Affiliations__c> start (Database.BatchableContext BC) {

        return affilationRecords;
    }

    global void execute(Database.BatchableContext BC,List<ZTS_EU_Account_Affiliations__c> scope){

        
        if(scope.size() > 0) {
            try {
                insert scope;
            }
            catch(DmlException dex) {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug('AffiliationReverseRecordCreationBatch - execute');
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, ERROR_LOG_ORIGIN_TYPE);
            }
        }

    }
    
    global void finish(database.BatchableContext BC){}
    
}