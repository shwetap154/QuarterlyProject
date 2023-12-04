/**
 * @description       : Interface for ContactSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-17-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-17-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
 * 1.1   05-03-2022   Ethan Hirsch @ Zoetis Inc   Add selectById Method
 * 1.2   04-11-2023   Padma Nerella @ Zoetis Inc  Add selectInternationalContactsByIdwithAffiliations
**/
public interface IContactSelector extends fflib_ISObjectSelector {
    List<Contact> selectPetOwnerContactsById(List<Id> contactIds);
    List<Contact> selectById(Set<Id> ids);
    List<Contact> selectContactsToUpdateEmail(List<Account> accountIds);
    List<Contact> selectInternationalContactsByIdwithAffiliations(Set<Id> contactsIds);
}