@isTest
public with sharing class ProductInvestigationTriggerHandlerTest {
    @isTest
    public static void beforeUpdateTest(){
        ProductInvestigationTriggerHandler.beforeUpdate(new List<SObject>(), new Map<Id, SObject>(), new List<SObject>(), new Map<Id, SObject>());
    }
    @isTest
    public static void beforeDeleteTest(){
        ProductInvestigationTriggerHandler.beforeDelete(new List<SObject>(),new Map<Id, SObject>());
    }
    @isTest
    public static void afterUpdateTest(){
        ProductInvestigationTriggerHandler.afterUpdate(new List<SObject>(),new Map<Id, SObject>(),new List<SObject>(),new Map<Id, SObject>());
    }
    @isTest
    public static void afterUndeleteTest(){
        ProductInvestigationTriggerHandler.afterUndelete(new List<SObject>(), new Map<Id, SObject>());
    }
}