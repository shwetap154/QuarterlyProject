/**
 * @description       : Interface for UserSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectUsersByIdNotExcludedFromIntegrations
**/
public interface IUserSelector extends fflib_ISObjectSelector {
    List<User> selectUsersByIdNotExcludedFromIntegrations(Set<Id> userIds, Set<String> excludeIntegrations);
}