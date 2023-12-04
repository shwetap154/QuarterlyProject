trigger PropelSAPIntegrationBOMStatusUpdate on SAP_BOM_Status_Event__e (after insert) {
    /**
     * It syncs SAP_BOM_Interface_Status__c from the SAP_BOM_Status_Event__e object to the Item Revision object
     * It grabs the first value and then perform the update
     */

    List<PDLM__Item_Revision__c> revRecordsToUpdate = new List<PDLM__Item_Revision__c>();
    List<Id> itemRevIdsList = new List<Id>();
    Map<Id, String> revIdStatusMap = new Map<Id, String>();

    if (Trigger.isAfter && Trigger.isInsert){
        //Loop through records that trigger the Process Builder or Flow
        for (SAP_BOM_Status_Event__e event : Trigger.New){
            itemRevIdsList.add(event.Rev_Record_Id__c);
            if (!revIdStatusMap.containsKey(event.Rev_Record_Id__c)){
                revIdStatusMap.put(event.Rev_Record_Id__c, event.SAP_BOM_Interface_Status__c);
            }
        }
    }

    System.debug('itemRevIdsList: ' + itemRevIdsList);
    System.debug('revIdStatusMap: ' + revIdStatusMap);

    if (itemRevIdsList.size() == 0){return;}

    for (PDLM__Item_Revision__c rev : [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c
                                       WHERE Id in :itemRevIdsList]){
        rev.SAP_BOM_Interface_Status__c = revIdStatusMap.get(rev.Id);
        revRecordsToUpdate.add(rev);
    }

    System.debug('revRecordsToUpdate: ' + revRecordsToUpdate);
    
    if (revRecordsToUpdate.size() > 0){
        try{
            update revRecordsToUpdate;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}