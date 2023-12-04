/****************************************************************************************************************************************** 
 * Trigger Name : CSE_CaseContactTriggerHandler
 * Description  : All Dispatch Trigger Logic for CaseContact object.
 * Created By   : Slalom(Venkat Joginapally) 
 * Created Date : 13th September, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                      Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Venkat Joginapally          09/13/2021             Created 
 * Christain Brandt                                   Added code  
*****************************************************************************************************************************************/

public with sharing class CSE_CaseContactTriggerHandler extends TriggerHandlerExtension implements TriggerHandlerInterface  
{
    
    @testVisible static final String CASE_CONTACT_APPROVEDCASE_DELETE_ERROR = System.Label.CSE_CaseContactTriggerHandler_Error_Text;
    @testVisible static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    public static final String OBJECT_API_NAME = 'Case_Contact__c';
    public static final String CASE_FIELD_API_NAME = 'Case__c';
    public static Boolean isBypass = false;

    public void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){   
        List<Case_Contact__c> lstOldCaseContacts = (List<Case_Contact__c>)triggerOld;
        //get all case Ids from CaseContacts into a set
        Map<Id, List<Case_Contact__c>> caseIdToCaseContactsMap = new Map<Id, List<Case_Contact__c>>();
        //Create a map with all the caseIds as key and related tobedeleted CaseContacts List as value
        for(Case_Contact__c caseContact: lstOldCaseContacts){
            List<Case_Contact__c> caseContactList = new List<Case_Contact__c>();
            //if Case Id already exists in the Map, add the case Contact record to the List in the map
            if(caseIdToCaseContactsMap.containsKey(caseContact.Case__c)){
                //get the existing case Contact list from the map for that case Id
                caseContactList = caseIdToCaseContactsMap.get(caseContact.Case__c);
                //add the current caseContact record to the above list
                caseContactList.add(caseContact);
                //Put the case Id and related case Contact list into the map which replaces the existing entry for that caseId
                caseIdToCaseContactsMap.put(caseContact.Case__c,  caseContactList);
            } else {
                // if case Id does not exist in the map, put new entry for the case Id and the List with the current case Contact record 
                caseIdToCaseContactsMap.put(caseContact.Case__c, new List<Case_Contact__c>{caseContact});
            }
        }     

        //SOQL to get all the Cases with Approved = true and with list of related Case Contacts 
        List<Case> casesWithCaseContacts = getCasesWithCaseContacts(caseIdToCaseContactsMap.keySet());

        //loop through each Case and check the size of the related case Contacts list, if size is =1, give error that Case Contact record cannot be deleted
        for(Case caseWithCaseContact: casesWithCaseContacts){
            List<Case_Contact__c> relatedToDeleteCaseContacts =  caseIdToCaseContactsMap.get(caseWithCaseContact.Id);
            //checking if total list of case Contacts on the case is equal to list of tobedeleted case Contacts size
            if(caseWithCaseContact.Case_Contacts__r.size() == relatedToDeleteCaseContacts.size()){
                //if the size is same, add error to the case Contact records so that they will not be deleted
                for(Case_Contact__c relatedToDeleteCaseContact: relatedToDeleteCaseContacts){
                    relatedToDeleteCaseContact.addError(CASE_CONTACT_APPROVEDCASE_DELETE_ERROR);
                }
            }
        }
    }

    private List<Case> getCasesWithCaseContacts(Set<Id> caseIds){
        //get cases and related case Contact records, get only cases that are approved = true
        List<Case> caseList =  [SELECT Id, (SELECT Id FROM Case_Contacts__r) FROM Case WHERE Id IN: caseIds AND Sync_Status__c != :VmipsCaseSyncStatusHandler.SYNC_UNAPPROVED
                                     AND RecordType.DeveloperName =: RECORDTYPE_CASE_ANIMAL_SUPPORT_STR];
        return caseList;
    }
    
    public void afterInsert(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
   
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerNew, null, OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType); 
    }
    public void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {
        
        //TPDEV-1768 - Bypass Phone_Five9__c from updating Case Sync Status
        
        Map<Id, case_contact__c> triggeroldMapCase =  (Map<Id, case_contact__c>)triggerOldMap;
        Map<Id, case_contact__c> triggernewMapCase =  (Map<Id, case_contact__c>)triggerNewMap;
        List<case_contact__c> triggerOldCaseCon = (List<case_contact__c>)triggerOld;
        for(case_contact__c caseCon : triggerOldCaseCon) { 
          
            if( triggeroldMapCase.get(caseCon.Id).Phone_Five9__c != triggernewMapCase.get(caseCon.Id).Phone_Five9__c){
                 isBypass = true;
            }
        }
       
        if(!isBypass)
        VmipsCaseSyncStatusHandler.checkCaseSendToPVWStatus(OBJECT_API_NAME,'Case__r',triggerNewMap);

    }
    public void afterDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap) {
        AuditAndSequenceHelper.createAuditLogForCaseRelatedRecords(triggerOld, triggerOldMap,OBJECT_API_NAME,CASE_FIELD_API_NAME,null,Trigger.operationType);
    }
    public void afterUndelete(List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
    public void beforeInsert(List<SObject> triggerNew) {
        system.debug('In Before Insert=');
   
        AuditAndSequenceHelper.createSequenceForObject(triggerNew,OBJECT_API_NAME,CASE_FIELD_API_NAME);
    }
    public void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap) {}
     
    

}