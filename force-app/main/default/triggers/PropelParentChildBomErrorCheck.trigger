trigger PropelParentChildBomErrorCheck on PDLM__Change__c (before update) {
    //Call the Service Apex Class
    if (Trigger.isBefore && Trigger.isUpdate){
        for (PDLM__Change__c chg : Trigger.new){
            PDLM__Change__c oldChg = Trigger.oldMap.get(chg.id);

            if (chg.PDLM__Status_lk__c != oldChg.PDLM__Status_lk__c && 
            (oldChg.Change_Status_Name__c == 'Pending' || oldChg.Change_Status_Name__c == 'Final File Creation')){
                PropelBomErrorCheckServiceClass.afterUpdate(Trigger.new);
            }
        }
    }
}