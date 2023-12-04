/**
 * @description       : Interface for ColleaguesSelector
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
public interface IColleaguesSelector extends fflib_ISObjectSelector  {
    List<ZTS_EU_Colleague__c> selectById(Set<Id> ids);
    List<ZTS_EU_Colleague__c> selectByCallAccountId(Set<Id> accountIds);
    List<ZTS_EU_Colleague__c> selectByCallAccountIdExcludeCallIds(Set<Id> accountIds, Set<Id> callIds);
    List<ZTS_EU_Colleague__c> selectByCallAccountIdAndUserId(Set<Id> accountIds, Set<Id> userIds);
    List<ZTS_EU_Colleague__c> selectByCallAccountIdAndUserIdAndExcludeColleagueIds(Set<Id> accountIds, Set<Id> userIds, Set<Id> callIds);
}