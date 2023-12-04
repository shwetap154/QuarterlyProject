/**
 * @description       : Interface for AccountSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-18-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-16-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
 * 1.1   05-03-2022   Ethan Hirsch @ Zoetis Inc   Add selectAccountWithReferenceLabFields method
 * 1.2   04-06-2023   Padma Nerella @ Zoetis Inc  Add selectInternationalAccountByIdWithContacts method
 * 1.3   05-09-2023   Padma Nerella @ Zoetis Inc  Add selectInternationalParentAccountsById method
 * 1.4   05-10-2023   Padma Nerella @ Zoetis Inc  Add retrieveInternationalParentAccountsByIdQuery method
 * 1.5   05-12-2023   Padma Nerella @ Zoetis Inc  Add selectAccountsWithDiagnosticAPs method
 * 1.6   05-18-2023   Padma Nerella @ Zoetis Inc  Add SelectINTLParentAccs
**/
public interface IAccountSelector extends fflib_ISObjectSelector {
    List<Account> selectByIdAndMarket(List<Id> ids, boolean isUnitedStates);
    List<Account> selectAccountWithReferenceLabFields(Set<Id> ids);
    List<Account> selectInternationalAccountByIdWithContacts(Set<Id> accIds);
    List<Account> selectInternationalParentAccountsById(Set<Id> parentAccIds,Integer queryLimit);
    String retrieveInternationalParentAccountsByIdQuery(Set<Id> parentAccIds);
    List<Account> selectAccountsWithDiagnosticAPs(Set<Id> accountIds);
    List<Account> SelectINTLParentAccs(Set<Id> parentAccIds);
}