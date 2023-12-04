/**
 * @description       : Trigger Handler for Diagnostic Cases (Reference Labs Onboarding and Reference Lab Support)
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-09-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   04-23-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   05-09-2022   Ethan Hirsch @ Zoetis Inc      Add onBeforeInsert method
**/
public with sharing class DiagnosticCaseTriggerHandler {

    public void onAfterUpdate(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
        List<Case> closedRefLabOnboardingCases = DiagnosticCaseService.returnClosedRefLabOnboardingCases(newCaseMap.values(), oldCaseMap);

        if(!closedRefLabOnboardingCases.isEmpty()){
            DiagnosticCaseService.createRefLabsInServiceCases(closedRefLabOnboardingCases);    
        }
    }

    public void onBeforeInsert(List<Case> newCases) {
        List<Case> nonClosedReferenceLabCases = DiagnosticCaseService.returnNonClosedRefLabOnboardingSupportCasesWithAccountOrContact(
            newCases);

        if (!nonClosedReferenceLabCases.isEmpty()) {
            DiagnosticCaseService.setReferenceLabFieldsByAccount(nonClosedReferenceLabCases);
        }
    }
}