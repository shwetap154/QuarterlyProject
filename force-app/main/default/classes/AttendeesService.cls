/**
 * @description       : Master Service Class for the Attendee__c Object
 * @author            : Namrata Patane @ Zoetis Inc
 * @group             : ServiceClass
 * @last modified on  : 08-05-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   12-06-2021   Namrata Patane @ Zoetis Inc   Initial Version
 * 1.1   12-09-2021   Morgan Marchese @ Zoetis Inc  Formatting Changes
 * 1.2   08-04-2022   Ethan Hirsch @ Zoetis Inc     Reupload and fix bugs with setting Recent Callers from a blank 
 *                                                  value and handling the same Contact on multiple Attendees.
 * 1.3   08-05-2022   Ethan Hirsch @ Zoetis Inc     Add logic to exit early before querying data if no Attendees have Contact set.
 *                                                  Add logic to calculate the length of Max Recent Callers using metadata for safety
 *                                                  Populate Recent Callers using String.format for performance benefits.
 *                                                  Only update Contacts if there are Contacts to update.
 **/
public class AttendeesService {
    /**
     * @description Updates Data on Contact Records related to Attendee__c Records
     * @author Morgan Marchese @ Zoetis Inc | 12-09-2021
     * @param List<Attendee__c> triggerNew
     **/
    public static void updateRelatedContacts(List<Attendee__c> lstAttendee) {
      Map<Id, Contact> updateContactMap = new Map<Id,Contact>();

      List<Attendee__c> attendeesToProcess = new List<Attendee__c>();
      for (Attendee__c objAttendee : lstAttendee) {
        if (objAttendee.ZTS_EU_Contact__c == null) {
          continue;
        }

        attendeesToProcess.add(objAttendee);
      }

      if (attendeesToProcess.isEmpty()) {
        return;
      }
  
      Id currentUserId = UserInfo.getUserId();
      // Max Length is the max size of Recent Callers, minus the length of the User Id, minus 1 character for the semicolon,
      // and 1 extra character for the starting semicolon
      Integer maxRecentCallersLength = Contact.RecentCallers__c.getDescribe().getLength() - String.valueOf(currentUserId).length() - 2;
      
      // Requery Records with Necessary Related Data
      for (Attendee__c objAttendee : [
          SELECT
            Id,
            ZTS_EU_Contact__c,
            ZTS_EU_call__r.ZTS_EU_Call_Owner__r.Name,
            ZTS_EU_call__r.ZTS_EU_Call_Owner__r.Email,
            ZTS_EU_Contact__r.RecentCallers__c
          FROM Attendee__c
          WHERE Id = :attendeesToProcess
        ]) {
        String recentCallers = objAttendee.ZTS_EU_Contact__r.RecentCallers__c;
        // Set Recent Callers to an empty string if it's blank to avoid issues contatenating User Ids
        if (String.isBlank(recentCallers)) {
            recentCallers = '';
        }

        Contact objCon;
        Id contactId = objAttendee.ZTS_EU_Contact__c;

        // Grab the Contact if it's currently being processed
        if (updateContactMap.containsKey(contactId)) {
            objCon = updateContactMap.get(contactId);
        }
        else {
            objCon = new Contact(Id = contactId);
        }

        objCon.Last_Call_Created_by__c = objAttendee.ZTS_EU_call__r.ZTS_EU_Call_Owner__r.Name;
        objCon.Last_Call_Created_by_Email__c = objAttendee.ZTS_EU_call__r.ZTS_EU_Call_Owner__r.Email;

        // Do not add the User to RecentCallers if it's already present or it would exceed the length of the field.
        if (
          recentCallers.length() <= maxRecentCallersLength &&
          !recentCallers.contains(UserInfo.getUserId())
        ) {
          objCon.RecentCallers__c = String.format('{0};{1}', new List<Object>{recentCallers, UserInfo.getUserId() });
        }

        updateContactMap.put(objCon.Id, objCon);
      }
      
      if (!updateContactMap.isEmpty()) {
        new WithoutSharing().updateContact(updateContactMap.values());
      }
    }
  
    private without sharing class WithoutSharing {
      /**
       * @description
       * @author Morgan Marchese @ Zoetis Inc | 12-09-2021
       * @param List<Contact> lstToUpdateContact
       **/
      public void updateContact(List<Contact> lstToUpdateContact) {
        update lstToUpdateContact;
      }
    }
  }