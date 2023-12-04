@isTest
public with sharing class CaseAgencySubmissionTriggerHandlerTest {
    @isTest
    public static void beforeInsertTest(){
        CaseAgencySubmissionTriggerHandler.beforeInsert(new List<SObject>());
    }
    @isTest
    public static void beforeUpdateTest(){
        CaseAgencySubmissionTriggerHandler.beforeUpdate(new List<SObject>(), new Map<Id, SObject>(), new List<SObject>(), new Map<Id, SObject>());
    }
    @isTest
    public static void beforeDeleteTest(){
        CaseAgencySubmissionTriggerHandler.beforeDelete(new List<SObject>(),new Map<Id, SObject>());
    }
    @isTest
    public static void afterUpdateTest(){
        CaseAgencySubmissionTriggerHandler.afterUpdate(new List<SObject>(),new Map<Id, SObject>(),new List<SObject>(),new Map<Id, SObject>());
    }
    @isTest
    public static void afterUndeleteTest(){
        CaseAgencySubmissionTriggerHandler.afterUndelete(new List<SObject>(), new Map<Id, SObject>());
    }
}