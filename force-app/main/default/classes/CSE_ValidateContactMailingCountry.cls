public with sharing class CSE_ValidateContactMailingCountry {
    /**
     * Helper method to validate if MailingCountry has a value United States before sending it to PV Works
     * @param List<Case_Contact__c> caseContactRecords - case contact records
     * @param Map<Id, Contact> queriedContactsMap - contact records
     * @param Set<String> fieldSetMembers - set of field api names from the field set on the corresponding object
     * 
     * @return void
     */

    public static void validateContactMailingCountry(List<Case_Contact__c> caseContactRecords, Map<Id, Contact> queriedContactsMap, Set<String> fieldSetMembers)
    {
        //empty list to hold the contact that needs to be updated
        List<Contact> aContactList = new List<Contact>();

        //iterate over the caseContactRecords list
        for ( Case_Contact__c caseContactRecord : caseContactRecords )
        {
            System.debug( 'Entered inside the for loop : ' + JSON.serializePretty( caseContactRecord ) );
            // get animal record from the queried animal map
            ID contactId = caseContactRecord.Contact__c;
            Contact contactRecord = queriedContactsMap.get(contactId);
            System.debug('Contact Record - MailingCountry = ' + contactRecord);
            //empty VMIPSMailingCountry String
            String VMIPSMailingCountry = '';
            //check if the contact's Mailing country is null or it contains value other than United States.
            if(contactRecord.MailingCountry == null || contactRecord.MailingCountry == '' || contactRecord.MailingCountry != 'United States')
            {
                System.debug('Mailing Country before update = ' + contactRecord.MailingCountry );
                VMIPSMailingCountry = contactRecord.VMIPS_Mailing_Country__c;
                System.debug('VMIPS Mailing Country Assignment = ' + VMIPSMailingCountry);
                Contact newContact = new Contact();
                newContact.MailingCountry = VMIPSMailingCountry;
                newContact.Id = contactId;
                aContactList.add(newContact);
            }
        }
        Database.SaveResult[] srList = Database.update(aContactList, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }

        for(Case_Contact__c caseContactRecord : caseContactRecords)
        {
            ID contactId = caseContactRecord.Contact__c;
            Contact contactRecord = queriedContactsMap.get(contactId);

            for(Contact aContact: aContactList)
            {
                //assigning the value to the main class instance so that it gets updated in the system.
                contactRecord.MailingCountry = aContact.MailingCountry;

            }
        }

    }
}