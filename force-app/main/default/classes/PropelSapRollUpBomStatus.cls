global with sharing class PropelSapRollUpBomStatus implements Schedulable, Database.Batchable<sObject>, Database.Stateful{
    public static final integer DEFAULT_BATCHSIZE = 200;
    public static Integer batchSize;
    PDLM__Configuration__c batchScope = [SELECT PDLM__Value__c FROM PDLM__Configuration__c WHERE Name = 'SapBomBatchScope' LIMIT 1];

    /**
     * When all the site BOMs are processed, update PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c = Completed
     * When one of them failed, update PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c to Failed
     * When status rolled up as Completed, update SAP_BOM_Interface_Status__c.Status_Rolled_Up_to_Rev = TRUE
     */

    /**
     * getBatchSize the as configured size is available to use
     * as a default or as configured with 'SapBomBatchScope'
     * custom Configuration setting, default is DEFAULT_BATCHSIZE
     */
    public Integer getBatchSize() {
        Integer batchSize = DEFAULT_BATCHSIZE;

        if (batchScope != null && Integer.valueof(batchScope.PDLM__Value__c) > 0 && Integer.valueof(batchScope.PDLM__Value__c) <= 200) {
            batchSize = Integer.valueof(batchScope.PDLM__Value__c) ;
        }

        return batchSize;
    }

    //
    // Schedulable
    //
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, this.getBatchSize());
    }

    //
    // Batchable
    //
    public PropelSapRollUpBomStatus() {
        batchSize = getBatchSize();
    }

    //
    // Batchable Interface
    //

    //Where the Batch starts
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT Id, Item_Revision__c, Site__c, SAP_BOM_Interface_Status__c, Completed__c, Status_Rolled_Up_to_Rev__c 
                FROM SAP_BOM_Interface_Status__c 
                WHERE Completed__c = FALSE
            ]
        );
    }

    //Where the Batch executes
    public void execute(Database.BatchableContext bc, List<SAP_BOM_Interface_Status__c> scope) {
        // List<SAP_BOM_Interface_Status__c> statuses = (List<SAP_BOM_Interface_Status__c>) scope;
        List<SAP_BOM_Status_Event__e> eventsToInsert = new List<SAP_BOM_Status_Event__e>();
        List<SAP_BOM_Interface_Status__c> bomStatusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        Map<Id, Integer> revIdTotalStatusCountMap = new Map<Id, Integer>();
        Map<Id, Integer> revIdSuccessStatusCountMap = new Map<Id, Integer>();
        Map<Id, Integer> revIdFailedStatusCountMap = new Map<Id, Integer>();
        Map<Id, Integer> revIdNonBlankStatusCountMap = new Map<Id, Integer>();
        Map<Id, List<SAP_BOM_Interface_Status__c>> revIdStatusRecordsMap = new Map<Id, List<SAP_BOM_Interface_Status__c>>();
        List<Id> revIds = new List<Id>();

        System.debug('statuses in the current batch: ' + scope);
        
        //Prepare the revIds
        for (SAP_BOM_Interface_Status__c status : scope){
            Id tempRevId = status.Item_Revision__c;
            revIds.add(tempRevId);

            if (!revIdTotalStatusCountMap.containsKey(tempRevId)){
                revIdTotalStatusCountMap.put(tempRevId, 0);
            }

            if (!revIdSuccessStatusCountMap.containsKey(tempRevId)){
                revIdSuccessStatusCountMap.put(tempRevId, 0);
            }

            if (!revIdFailedStatusCountMap.containsKey(tempRevId)){
                revIdFailedStatusCountMap.put(tempRevId, 0);
            }

            if (!revIdNonBlankStatusCountMap.containsKey(tempRevId)){
                revIdNonBlankStatusCountMap.put(tempRevId, 0);
            }

            if (status.SAP_BOM_Interface_Status__c != null){
                revIdNonBlankStatusCountMap.put(tempRevId,revIdNonBlankStatusCountMap.get(tempRevId)+1);

                if (status.SAP_BOM_Interface_Status__c == 'Completed' ||
                status.SAP_BOM_Interface_Status__c == 'Manually Completed'){
                    revIdSuccessStatusCountMap.put(tempRevId,revIdSuccessStatusCountMap.get(tempRevId)+1);
                }
                else if (status.SAP_BOM_Interface_Status__c == 'Failed'){
                    revIdFailedStatusCountMap.put(tempRevId,revIdFailedStatusCountMap.get(tempRevId)+1);
                }
            }

            revIdTotalStatusCountMap.put(tempRevId,revIdTotalStatusCountMap.get(tempRevId)+1);

            if (!revIdStatusRecordsMap.containsKey(tempRevId)){
                revIdStatusRecordsMap.put(tempRevId, new List<SAP_BOM_Interface_Status__c> {status});
            }
            else{
                revIdStatusRecordsMap.get(tempRevId).add(status);
            }
        }

        System.debug('revIds:' + revIds);
        System.debug('revIdSuccessStatusCountMap:' + revIdSuccessStatusCountMap);
        System.debug('revIdFailedStatusCountMap:' + revIdFailedStatusCountMap);
        System.debug('revIdTotalStatusCountMap:' + revIdTotalStatusCountMap);
        System.debug('revIdNonBlankStatusCountMap:' + revIdNonBlankStatusCountMap);
        System.debug('revIdStatusRecordsMap:' + revIdStatusRecordsMap);

        List<PDLM__Item_Revision__c> revsToLoop = [SELECT Id, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c WHERE Id in : revIds];
        
        for (PDLM__Item_Revision__c rev : revsToLoop){
            if (revIdSuccessStatusCountMap.get(rev.Id) == revIdTotalStatusCountMap.get(rev.Id) &&
            revIdNonBlankStatusCountMap.get(rev.Id) == revIdTotalStatusCountMap.get(rev.Id)){
                //Update SAP_BOM_Interface_Status__c.Status_Rolled_Up_to_Rev__c and SAP_BOM_Interface_Status__c.Completed__c
                for (SAP_BOM_Interface_Status__c statusToLoop: revIdStatusRecordsMap.get(rev.Id)){
                    if (statusToLoop.Status_Rolled_Up_to_Rev__c != true || statusToLoop.Completed__c != true){
                        statusToLoop.Status_Rolled_Up_to_Rev__c = true;
                        statusToLoop.Completed__c = true;
                        bomStatusesToUpdate.add(statusToLoop);
                    }
                }

                //Update PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c = Completed
                SAP_BOM_Status_Event__e event = new SAP_BOM_Status_Event__e();
                event.Rev_Record_Id__c = rev.Id;
                event.SAP_BOM_Interface_Status__c = 'Completed';
                eventsToInsert.add(event);
            }
            else if (revIdFailedStatusCountMap.get(rev.Id) > 0){
                //Update SAP_BOM_Interface_Status__c.Status_Rolled_Up_to_Rev__c
                for (SAP_BOM_Interface_Status__c statusToLoop: revIdStatusRecordsMap.get(rev.Id)){
                    if (statusToLoop.Status_Rolled_Up_to_Rev__c != true){
                        statusToLoop.Status_Rolled_Up_to_Rev__c = true;
                        bomStatusesToUpdate.add(statusToLoop);
                    }
                }

                //Update PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c = Failed
                SAP_BOM_Status_Event__e event = new SAP_BOM_Status_Event__e();
                event.Rev_Record_Id__c = rev.Id;
                event.SAP_BOM_Interface_Status__c = 'Failed';
                eventsToInsert.add(event);
            }
        }

        System.debug('eventsToInsert:' + eventsToInsert);
        System.debug('bomStatusesToUpdate:' + bomStatusesToUpdate);

        //DMLs
        if (eventsToInsert.size() > 0){
            EventBus.publish(eventsToInsert);
        }

        if (bomStatusesToUpdate.size() > 0){
            update bomStatusesToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
            System.debug(Logginglevel.WARN, 'PropelPushPlantSpecBomsToSap: finish()');
    }
}