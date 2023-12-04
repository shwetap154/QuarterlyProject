/**
 * @description       : Interface for CasesSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectById and 
 *                                                selectyByAccountIdsAndRecordTypeDeveloperNames methods
**/
public interface ICasesSelector extends fflib_ISObjectSelector {
    List<Case> selectById(Set<Id> idSet);
    List<Case> selectyByAccountIdsAndRecordTypeDeveloperNames(Set<Id> accountIds, Set<String> recordTypes);
}