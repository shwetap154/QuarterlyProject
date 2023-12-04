@isTest
public with sharing class CaseReviewCardTriggerHandlerTest {
    @isTest
    public static void beforeInsertTest(){
        CaseReviewCardTriggerHandler.beforeInsert(new List<SObject>());
    }
    @isTest
    public static void beforeUpdateTest(){
        CaseReviewCardTriggerHandler.beforeUpdate(new List<SObject>(), new Map<Id, SObject>(), new List<SObject>(), new Map<Id, SObject>());
    }
    @isTest
    public static void beforeDeleteTest(){
        CaseReviewCardTriggerHandler.beforeDelete(new List<SObject>(),new Map<Id, SObject>());
    }
    @isTest
    public static void afterUpdateTest(){
        CaseReviewCardTriggerHandler.afterUpdate(new List<SObject>(),new Map<Id, SObject>(),new List<SObject>(),new Map<Id, SObject>());
    }
    @isTest
    public static void afterUndeleteTest(){
        CaseReviewCardTriggerHandler.afterUndelete(new List<SObject>(), new Map<Id, SObject>());
    }
}