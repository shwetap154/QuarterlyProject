/**
 * @description       : Main query class for Case
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-12-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectById and 
 *                                                selectyByAccountIdsAndRecordTypeDeveloperNames methods
 * 1.1   10-31-2023   Dephney Dsouza              Added getCaseDetail to get case record details- TPDEV-661
**/
public with sharing class CasesSelector extends fflib_SObjectSelector implements ICasesSelector {
    public static ICasesSelector newInstance() {
        return (ICasesSelector)Application.Selector.newInstance(
            Case.SObjectType
        );
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SobjectField> {
            Case.Id,
            Case.Status
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
      }

    public List<Case> selectById(Set<Id> idSet) {
        return (List<Case>)selectSObjectsById(idSet);
    }

    public List<Case> selectyByAccountIdsAndRecordTypeDeveloperNames(Set<Id> accountIds, Set<String> recordTypes) {
        fflib_QueryFactory recordQueryFactory = newQueryFactory();
        recordQueryFactory.selectField(Case.Has_RefLabs_Multiple_Ship_To__c);
        recordQueryFactory.setCondition(
            'AccountId in: accountIds AND RecordType.DeveloperName in: recordTypes'
        );

        return (List<Case>)Database.query(recordQueryFactory.toSOQL());
    }

    @AuraEnabled(cacheable=true)
    public static Case getCaseDetail(Id caseId) {
        return [Select Id, ContactId, No_Contact__c from Case Where Id =:caseId LIMIT 1];
    }
}