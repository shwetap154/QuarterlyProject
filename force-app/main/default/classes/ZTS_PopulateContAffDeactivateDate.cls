/****************************************************************************************************************************************** 
* Class Name   : ZTS_PopulateContAffDeactivateDate
* Description  : This class will update the "Contact Affiliation Deactivated Date" field based on Contact on new ACA insert or
Existing ACA update. (SC-008471)
                (1) When ACA status is changed to Inactive,it checks if there is no other active ACA under the contact, then it populates 
                the Affiliation deactivate date on contact.
                (2) When ACA status is changed to Active, it clears out the Affiliation deactivate date on contact.
                (3) When ACA is inserted with status=Active, it clears out the Affiliation deactivate date on contact if anys.
* Created By   : Aritra(Cognizant)
* Created Date : 01-Apr-2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      01-Apr-2021      Created this class (SC-008471)
* Morgan Marchese         26-May-2021      Formatting and removal of unnecessary comments
*****************************************************************************************************************************************/
public class ZTS_PopulateContAffDeactivateDate {
  List<Contact> listContact = new List<Contact>();

  public void updateAffDeactDate(
    List<ZTS_EU_Affiliations__c> Triggernew,
    Map<id, ZTS_EU_Affiliations__c> triggerOldMap,
    boolean isUpdate,
    boolean isInsert
  ) {
    Set<Id> affectedInactiveAffIds = new Set<Id>();
    Set<Id> affectedActiveAffIds = new Set<Id>();
    Set<Id> affectedInactiveContactIds = new Set<Id>();
    Map<Id, List<ZTS_EU_Affiliations__c>> mapConToActiveAff = new Map<Id, List<ZTS_EU_Affiliations__c>>();
    //When ACA is updated
    if (isUpdate) {
      for (ZTS_EU_Affiliations__c aff : Triggernew) {
        system.debug(
          'triggerOldMap.get(aff.Id).ZTS_EU_Affiliation_Status__c>>' +
          triggerOldMap.get(aff.Id).ZTS_EU_Affiliation_Status__c
        );
        system.debug(
          'aff.ZTS_EU_Affiliation_Status__c>>' +
          aff.ZTS_EU_Affiliation_Status__c
        );
        if (
          ((triggerOldMap.get(aff.Id).ZTS_EU_Affiliation_Status__c) <>
          aff.ZTS_EU_Affiliation_Status__c) &&
          ((triggerOldMap.get(aff.Id).ZTS_EU_Contact__c) ==
          aff.ZTS_EU_Contact__c)
        ) {
          if (aff.ZTS_EU_Affiliation_Status__c == 'Inactive') {
            affectedInactiveContactIds.add(aff.ZTS_EU_Contact__c);
            affectedInactiveAffIds.add(aff.id);
          } else if (aff.ZTS_EU_Affiliation_Status__c == 'Active') {
            affectedActiveAffIds.add(aff.id);
          }
        }
      }
      //When ACA status is changed to Inactive,it checks if there is no other active ACA under the contact,
      //then it populates the Affiliation deactivate date on contact
      if (affectedInactiveAffIds.size() > 0) {
        List<ZTS_EU_Affiliations__c> lstActiveAffinContacts = [
          SELECT Id, ZTS_EU_Contact__c, ZTS_EU_Affiliation_Status__c
          FROM ZTS_EU_Affiliations__c
          WHERE
            ZTS_EU_Contact__c IN :affectedInactiveContactIds
            AND Id NOT IN :affectedInactiveAffIds
            AND ZTS_EU_Affiliation_Status__c = 'Active'
        ];
        if (lstActiveAffinContacts.size() > 0) {
          for (Id id : affectedInactiveContactIds) {
            mapConToActiveAff.put(id, new List<ZTS_EU_Affiliations__c>());
            for (ZTS_EU_Affiliations__c aff : lstActiveAffinContacts) {
              if (id == aff.ZTS_EU_Contact__c) {
                mapConToActiveAff.get(id).add(aff);
                break;
              }
            }
          }
        } else {
          for (Id id : affectedInactiveContactIds) {
            mapConToActiveAff.put(id, new List<ZTS_EU_Affiliations__c>());
          }
        }
        for (Id i : mapConToActiveAff.keySet()) {
          if (mapConToActiveAff.get(i).size() == 0) {
            listContact.add(
              new Contact(
                id = i,
                ZTS_Contact_Affiliation_Deactivated_Date__c = system.now()
              )
            );
          }
        }
      }
      //When ACA status is changed to Active, it clears out the Affiliation deactivate date on contact
      if (affectedActiveAffIds.size() > 0) {
        List<ZTS_EU_Affiliations__c> lstAff1 = [
          SELECT
            ZTS_EU_Contact__c,
            ZTS_EU_Contact__r.ZTS_Contact_Affiliation_Deactivated_Date__c
          FROM ZTS_EU_Affiliations__c
          WHERE
            Id IN :affectedActiveAffIds
            AND ZTS_EU_Contact__r.ZTS_Contact_Affiliation_Deactivated_Date__c != NULL
        ];
        for (ZTS_EU_Affiliations__c a : lstAff1) {
          listContact.add(
            new Contact(
              Id = a.ZTS_EU_Contact__c,
              ZTS_Contact_Affiliation_Deactivated_Date__c = null
            )
          );
        }
      }
      if (listContact.size() > 0) {
        update listContact;
      }
    }
    //When ACA is inserted
    if (isInsert) {
      List<Id> lstContactId = new List<Id>();
      List<Contact> lstApplicableContacts = new List<Contact>();
      for (ZTS_EU_Affiliations__c aff : Triggernew) {
        if (aff.ZTS_EU_Affiliation_Status__c == 'Active') {
          lstContactId.add(aff.ZTS_EU_Contact__c);
        }
      }
      if (lstContactId.size() > 0) {
        lstApplicableContacts = [
          SELECT Id, ZTS_Contact_Affiliation_Deactivated_Date__c
          FROM Contact
          WHERE
            Id IN :lstContactId
            AND ZTS_Contact_Affiliation_Deactivated_Date__c != NULL
        ];
        for (Contact c : lstApplicableContacts) {
          c.ZTS_Contact_Affiliation_Deactivated_Date__c = null;
          listContact.add(c);
        }
      }
      if (listContact.size() > 0) {
        update listContact;
      }
    }
  }
}