trigger PropelSAPIntegrationPreFilteringAndFieldUpdateTrigger on SAP_Integration_Event__e (after insert) {
    //Call the Service Apex Class
    if (Trigger.isAfter && Trigger.isInsert){
        PropelSapEventServiceClass.afterInsert(Trigger.new);
    }
}