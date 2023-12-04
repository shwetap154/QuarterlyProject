global with sharing class PropelUpdateOverallInterfaceStatusBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    public Integer batchSize = 200;
    public List<Id> revIds = new List<Id>();

    //
    // Schedulable
    //
    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, batchSize);
    }

    //
    // Batchable
    //
    public PropelUpdateOverallInterfaceStatusBatch() {
        System.debug(Logginglevel.warn, 'PropelUpdateOverallInterfaceStatusBatch batchSize:'+ batchSize);
    }


    public class PropelUpdateOverallInterfaceStatusBatchException extends Exception {}

    //Where the Batch starts
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, PDLM__Related_Change__c, SAP_Material_Interface_Status__c, SAP_BOM_Interface_Status__c ' +
                       'FROM PDLM__Item_Revision__c WHERE PDLM__Related_Change__r.Overall_Interface_Status__c = \'In Process\' ' +
                       'AND PDLM__Related_Change__r.PDLM__Status_lk__r.Name = \'Released\' ' +
                       'AND PDLM__Related_Change__r.PDLM__Category__r.Name IN (\'ECO\', \'ECO-QMS\', \'BCO\', \'BCO-QMS\', \'VCO\')';
        System.debug('query:' + query);
        return Database.getQueryLocator(query);
    }

    //When the Batch executes
    public void execute(Database.BatchableContext bc, List<PDLM__Item_Revision__c> scope) {
        List<PDLM__Change__c> changeRecordsToUpdate = new List<PDLM__Change__c>();
        List<Id> failedChangeIds = new List<Id>();
        List<Id> succeededChangeIds = new List<Id>();
        Set<Id> batchChangeIds = new Set<Id>();
        Map<Id, String> changeOverallStatusMap = new Map<Id, String>();
        Map<Id, Integer> changeIdRevTotalCount = new Map<Id, Integer>();
        Map<Id, Integer> changeIdRevSuccessCount = new Map<Id, Integer>();

        System.debug('scope:' + scope);

        for (PDLM__Item_Revision__c rev : scope) {
            batchChangeIds.add(rev.PDLM__Related_Change__c);

            if (!changeIdRevTotalCount.containsKey(rev.PDLM__Related_Change__c)){
                changeIdRevTotalCount.put(rev.PDLM__Related_Change__c, 0);
            }

            if (!changeIdRevSuccessCount.containsKey(rev.PDLM__Related_Change__c)){
                changeIdRevSuccessCount.put(rev.PDLM__Related_Change__c, 0);
            }

            Integer tempTotalCount = changeIdRevTotalCount.get(rev.PDLM__Related_Change__c) + 1;
            changeIdRevTotalCount.put(rev.PDLM__Related_Change__c, tempTotalCount);

            if (rev.SAP_Material_Interface_Status__c == 'Failed' || rev.SAP_BOM_Interface_Status__c == 'Failed'){
                failedChangeIds.add(rev.PDLM__Related_Change__c);
                break;
            }
            else if ((rev.SAP_Material_Interface_Status__c == 'Completed' || rev.SAP_Material_Interface_Status__c == 'Manually Completed' ||
            rev.SAP_Material_Interface_Status__c == '<<< Not Applicable >>>') && 
            (rev.SAP_BOM_Interface_Status__c == 'Completed' || rev.SAP_BOM_Interface_Status__c == 'Manually Completed' || 
            rev.SAP_BOM_Interface_Status__c == '<<< Not Applicable >>>')){
                Integer tempSuccessCount = changeIdRevSuccessCount.get(rev.PDLM__Related_Change__c) + 1;
                changeIdRevSuccessCount.put(rev.PDLM__Related_Change__c, tempSuccessCount);
            }
        }

        /**
         * Update Overall_Interface_Status__c = 'Completed' or 'Failed'
         * If either SAP_Material_Interface_Status__c or SAP_BOM_Interface_Status__c is Failed --> Failed
         * If both SAP_Material_Interface_Status__c and SAP_BOM_Interface_Status__c are Completed or Manually Completed --> Completed
         */
        
        for (Id changeId : batchChangeIds){
            if (changeIdRevSuccessCount.get(changeId) == changeIdRevTotalCount.get(changeId)){
                changeOverallStatusMap.put(changeId, 'Completed');
            }
            else if (failedChangeIds.contains(changeId)){
                changeOverallStatusMap.put(changeId, 'Failed');
            }
        }   

        //Set the Overall_Interface_Status__c field on Change
        for (PDLM__Change__c change : [SELECT Id, Overall_Interface_Status__c FROM PDLM__Change__c 
                                       WHERE Id in :batchChangeIds and Overall_Interface_Status__c = 'In Process']) {
            if (changeOverallStatusMap.containsKey(change.Id)){
                change.Overall_Interface_Status__c = changeOverallStatusMap.get(change.Id);
                changeRecordsToUpdate.add(change);
            }
        }

        System.debug('batchChangeIds: ' + batchChangeIds);
        System.debug('changeRecordsToUpdate: ' + changeRecordsToUpdate);

        //DML Statement
        if (changeRecordsToUpdate.size() > 0){
            update changeRecordsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug(Logginglevel.WARN, 'PropelUpdateOverallInterfaceStatusBatch: finish()');
    }
}