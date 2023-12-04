/**
 * @description       : Main QUery class for ZTS_EU_Colleague__c
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-07-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectById, selectByCallAccountId, 
 *                                                selectByCallAccountIdExcludeCallIds, selectByCallAccountIdAndUserId,
 *                                                and selectByCallAccountIdAndUserIdAndExcludeColleagueIds
 **/
public inherited sharing class ColleaguesSelector extends fflib_SObjectSelector implements IColleaguesSelector {
    public static IColleaguesSelector newInstance() {
        return (IColleaguesSelector)Application.Selector.newInstance(
            ZTS_EU_Colleague__c.SObjectType
        );
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ZTS_EU_Colleague__c.Id,
            ZTS_EU_Colleague__c.ZTS_EU_User__c,
            ZTS_EU_Colleague__c.ZTS_EU_Call__c
        };
    }

    public Schema.SObjectType getSobjectType() {
        return ZTS_EU_Colleague__c.SObjectType;
    }

    public List<ZTS_EU_Colleague__c> selectById(Set<Id> ids) {
        fflib_QueryFactory colleagueQueryFactory = newQueryFactory();
        Set<String> queryFields = new Set<String>{
            'ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c',
            'ZTS_EU_Call__r.ZTS_EU_Account__c'
        };

        colleagueQueryFactory.selectFields(queryFields);
        colleagueQueryFactory.setCondition('id IN :ids');

        return (List<ZTS_EU_Colleague__c>) Database.query(colleagueQueryFactory.toSOQL());
    }

    public List<ZTS_EU_Colleague__c> selectByCallAccountId(Set<Id> accountIds) {
        fflib_QueryFactory colleagueQueryFactory = newQueryFactory();
        Set<String> queryFields = new Set<String>{
            'ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c',
            'ZTS_EU_Call__r.ZTS_EU_Account__c'
        };

        colleagueQueryFactory.selectFields(queryFields);
        colleagueQueryFactory.setCondition(
            'ZTS_EU_Call__r.ZTS_EU_Account__c IN :accountIds');
        
        return (List<ZTS_EU_Colleague__c>) Database.query(colleagueQueryFactory.toSOQL()); 
    }

    public List<ZTS_EU_Colleague__c> selectByCallAccountIdExcludeCallIds(Set<Id> accountIds, Set<Id> callIds) {
        fflib_QueryFactory colleagueQueryFactory = newQueryFactory();
        Set<String> queryFields = new Set<String>{
            'ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c',
            'ZTS_EU_Call__r.ZTS_EU_Account__c'
        };

        colleagueQueryFactory.selectFields(queryFields);
        colleagueQueryFactory.setCondition(
            'ZTS_EU_Call__r.ZTS_EU_Account__c IN :accountIds AND ZTS_EU_Call__c NOT IN :callIds');
        
        return (List<ZTS_EU_Colleague__c>) Database.query(colleagueQueryFactory.toSOQL()); 
    }

    public List<ZTS_EU_Colleague__c> selectByCallAccountIdAndUserId(Set<Id> accountIds, Set<Id> userIds) {
        fflib_QueryFactory colleagueQueryFactory = newQueryFactory();
        Set<String> queryFields = new Set<String>{
            'ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c',
            'ZTS_EU_Call__r.ZTS_EU_Account__c'
        };

        colleagueQueryFactory.selectFields(queryFields);
        colleagueQueryFactory.setCondition(
            'ZTS_EU_Call__r.ZTS_EU_Account__c IN :accountIds AND ZTS_EU_User__c IN :userIds');
        
        return (List<ZTS_EU_Colleague__c>) Database.query(colleagueQueryFactory.toSOQL()); 
    }

    public List<ZTS_EU_Colleague__c> selectByCallAccountIdAndUserIdAndExcludeColleagueIds(Set<Id> accountIds, Set<Id> userIds, Set<Id> colleagueIds) {
        fflib_QueryFactory colleagueQueryFactory = newQueryFactory();
        Set<String> queryFields = new Set<String>{
            'ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c',
            'ZTS_EU_Call__r.ZTS_EU_Account__c'
        };

        colleagueQueryFactory.selectFields(queryFields);
        colleagueQueryFactory.setCondition(
            'ZTS_EU_Call__r.ZTS_EU_Account__c IN :accountIds AND ZTS_EU_User__c IN :userIds AND Id NOT IN :colleagueIds');
        
        return (List<ZTS_EU_Colleague__c>) Database.query(colleagueQueryFactory.toSOQL()); 
    }
}