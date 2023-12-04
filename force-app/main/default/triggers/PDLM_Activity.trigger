trigger PDLM_Activity on PDLM__Deliverable__ChangeEvent (after insert) {
    system.debug('in trigger');
if (Trigger.isAfter && Trigger.isInsert) {
    system.debug('in after insert trigger');
      PDLM.AuditService.logEvent((List<SObject>) Trigger.new);
     }
}