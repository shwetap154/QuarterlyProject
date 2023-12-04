/**
 * @description       : Logic for the Atlas Integration for sending Pets and Contacts to Atlas. Also approves/rejects Anonymization requests
 * @author            : Neil Kapoor @ Slalom
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   10-28-2021   Neil Kapoor @ Zoetis Inc    Initial Version
 * 1.1   03-17-2022   Ethan Hirsch @ Zoetis       Added additional logic to prevent integration calls if required fields are missing.
 * 1.2   08-24-2022   Chelsea Paice @ Zoetis Inc  Added check for pet owner contact to be pet owner record type in order to send pet
 * 1.3   01--6-2023   Padma Nerella @ Zoetis Inc  Bypass the Account Trigger when updating Accounts (TPDEV-80)
**/

global without sharing class AtlasIntegrationHelper implements Queueable, Database.AllowsCallouts
{
    @TestVisible
    private static final String CREATE_PET_OWNER_URI = '/2.0/third-party/identities/';
    @TestVisible
    private static final String CREATE_PET_URI = '/2.0/third-party/pets/';
    @TestVisible
    public static final String POST_METHOD = 'POST';
    private List<Contact> contactList;
    private List<ZTS_US_Animal__c> petList;
    private Boolean isPetOwner;
    private Map<Id, Contact> petOwnerMap;

    public static final Id PET_OWNER_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_Pet_Owner').getRecordTypeId();


    global AtlasIntegrationHelper( List<Contact> petOwnersList )
    {
        this.contactList = petOwnersList;
        this.isPetOwner = true;
        System.debug( 'in helper' );
    }

    global AtlasIntegrationHelper( List<ZTS_US_Animal__c> petsList, Map<Id, Contact> petOwnerMap)
    {
        this.petList = petsList;
        this.isPetOwner = false;
        this.petOwnerMap = petOwnerMap;
    }

    /**
    * @description Execute method for the Queueable. This method will kick off the Atlas Integration for a Pet or Pet Owner.
           If there is more than one Contact/Pet to integrate, 
           this method will kick off another Queueable to integrate the next record.
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param qc 
    **/
    global void execute( QueueableContext qc )
    {
        AtlasIntegrationHelper helperClass;

        if ( isPetOwner )
        {
            Contact petOwnerToCreate = contactList.remove( 0 );
            createPetOwner( petOwnerToCreate );

            if ( contactList.size() > 0 )
            {
                helperClass = new AtlasIntegrationHelper( contactList );
            }
            
        }
        else 
        {
            ZTS_US_Animal__c petToCreate = petList.remove( 0 );
            createPet( petToCreate, petOwnerMap.get(petToCreate.ZTS_US_Pet_Owner__c) );
            if ( petList.size() > 0 )
            {
                helperClass = new AtlasIntegrationHelper( petList, petOwnerMap );
            }
        }

        if ( helperClass != null )
        {
            System.enqueueJob( helperClass );
        }
    }

    /**
    * @description Integrates a Pet Owner to Atlas
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param petOwnerToCreate 
    **/
    global static void createPetOwner( Contact petOwnerToCreate )
    {
        //  lets build our base request
        HttpRequest theRequest = buildBaseHttpRequest( 'callout:Atlas_API' + CREATE_PET_OWNER_URI, POST_METHOD ); 
        
        // lets wrap our contact
        ContactWrapper aContactWrapper = new ContactWrapper( petOwnerToCreate );

        // lets generate the json for our request body
        JSONGenerator jsonGen = JSON.createGenerator( false );
        jsonGen.writeStartObject();
        jsonGen.writeFieldName( 'identity' );
        jsonGen.writeObject( aContactWrapper );
        jsonGen.writeEndObject();

        String requestBody = jsonGen.getAsString();

        jsonGen.close();

        theRequest.setBody( requestBody );

        System.debug( 'request body: ' + requestBody );
        System.debug( 'auth header: ' + theRequest.getHeader( 'Authorization' ) );
        // lets instantiate a new http object
        Http httpObj = new Http();

        // lets send the request and get the response
        HttpResponse theResponse = httpObj.send( theRequest );

        String responseBody = theResponse.getBody();

        System.debug( 'response: ' + responseBody );
        // lets parse the response
        JSONParser parser = JSON.createParser( responseBody );

        String atlasId;
        String error;
        String errorMessage;

        while ( parser.nextToken() != null )
        {
            if ( parser.getCurrentToken() == JSONToken.FIELD_NAME ) 
            {
                if ( parser.getText() == 'id' )
                {
                    parser.nextToken();
                    atlasId = parser.getText();
                    break;
                } 
                else if ( parser.getText() == 'error' )
                {
                    parser.nextToken();
                    error = parser.getText();
                }
                else if ( parser.getText() == 'message' )
                {
                    parser.nextToken();
                    errorMessage = parser.getText();
                }
            }
        }

        if ( String.isNotBlank( atlasId ) )
        {
            try 
            {
                Contact contactToUpdate = new Contact( Id = petOwnerToCreate.Id, ZTS_US_Atlas_Id__c = atlasId );
                update contactToUpdate;
            } 
            catch ( Exception e ) 
            {
                System.debug( 'error: ' + e.getMessage() );
            }
        }
        else 
        {
            System.debug( 'error thrown: ' + error + ' : ' + errorMessage );
        }
        
    }

    /**
    * @description Integrates a Pet to Atlas
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param petToCreate 
    **/
    global static void createPet( ZTS_US_Animal__c petToCreate, Contact petOwner )
    {
         //  lets build our base request
        HttpRequest theRequest = buildBaseHttpRequest( 'callout:Atlas_API' + CREATE_PET_URI, POST_METHOD ); 
        
        // lets wrap our contact
        PetWrapper aPetWrapper = new PetWrapper( petToCreate, petOwner);

        // lets generate the json for our request body
        JSONGenerator jsonGen = JSON.createGenerator( false );
        jsonGen.writeStartObject();
        jsonGen.writeFieldName( 'pet' );
        jsonGen.writeObject( aPetWrapper );
        jsonGen.writeEndObject();

        String requestBody = jsonGen.getAsString();

        jsonGen.close();

        theRequest.setBody( requestBody );

        // lets instantiate a new http object
        Http httpObj = new Http();

        // lets send the request and get the response
        HttpResponse theResponse = httpObj.send( theRequest );

        String responseBody = theResponse.getBody();
        System.debug( 'response: ' + responseBody );

        // lets parse the response
        JSONParser parser = JSON.createParser( responseBody );

        String atlasId;
        String error;
        String errorMessage;

        while ( parser.nextToken() != null )
        {
            if ( parser.getCurrentToken() == JSONToken.FIELD_NAME ) 
            {
                if ( parser.getText() == 'id' )
                {
                    parser.nextToken();
                    atlasId = parser.getText();
                    break;
                } 
                else if ( parser.getText() == 'error' )
                {
                    parser.nextToken();
                    error = parser.getText();
                }
                else if ( parser.getText() == 'message' )
                {
                    parser.nextToken();
                    errorMessage = parser.getText();
                }
            }
        }

        if ( String.isNotBlank( atlasId ) )
        {
            try 
            {
                ZTS_US_Animal__c petToUpdate = new ZTS_US_Animal__c( Id = petToCreate.Id, ZTS_US_Atlas_Id__c = atlasId );
                update petToUpdate;
            } 
            catch ( Exception e ) 
            {
                System.debug( 'error: ' + e.getMessage() );
            }
        }
        else 
        {
            System.debug( 'error thrown: ' + error + ' : ' + errorMessage );
        }
    }

    /**
    * @description Builds the HTTP Request for integrating to Atlas
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param endpoint 
    * @param method 
    * @return HttpRequest 
    **/
    global static HttpRequest buildBaseHttpRequest( String endpoint, String method )
    {
        HttpRequest theRequest = new HttpRequest();
        theRequest.setEndpoint( endpoint );
        theRequest.setMethod( method );
        theRequest.setHeader( 'Content-Type', 'application/json' );
        theRequest.setTimeout( 30000 );
        theRequest.setHeader( 'Accept', 'application/json' );

        return theRequest;
    }

    global class ContactWrapper
    {
        global String email;
        global String first_name;
        global String last_name;
        global String address_city;
        global String address_state;
        global String address_street_address1;
        global String address_street_address_2;
        global String zip;
        global String mobile_phone;
        global String sf_account_id;
        global String sf_contact_id;

        global ContactWrapper( Contact aContact )
        {
            this.email = aContact.Email;
            this.first_name = aContact.FirstName;
            this.last_name = aContact.LastName;
            this.address_city = aContact.MailingCity;
            this.address_state = aContact.MailingState;
            this.address_street_address1 = aContact.MailingStreet;
            this.zip = aContact.MailingPostalCode;
            this.mobile_phone = aContact.MobilePhone; // TODO: ask if this should jsut be their phone number
            this.sf_account_id = aContact.AccountId;
            this.sf_contact_id = aContact.Id;
        }

    }

    global class PetWrapper
    {   
        global String owner_id;
        global String email;
        global String sf_account_id;
        global String sf_contact_id;
        global String name;
        global Integer species_id;
        global Boolean is_male;
        global String date_of_birth;


        global PetWrapper( ZTS_US_Animal__c aPet, Contact petOwner )
        {
            this.owner_id = petOwner?.ZTS_US_Atlas_Id__c;
            this.email = petOwner?.Email;
            this.sf_account_id = aPet.ZTS_US_Animal_Household__c;
            this.sf_contact_id = aPet.ZTS_US_Pet_Owner__c;
            this.name = aPet.Name;
            this.species_id = aPet.ZTS_US_Species__c == 'Canine' ? 1 : aPet.ZTS_US_Species__c == 'Feline' ? 2 : 0;
            this.is_male = aPet.ZTS_US_Sex__c == 'Male';
            this.date_of_birth = aPet.ZTS_US_Date_of_Birth__c != null ? String.valueOf( aPet.ZTS_US_Date_of_Birth__c ) : null;
        }
    }

    /**
    * @description Filters Contact records to only Contacts that meet the following criteria and 
        kicks off a Queueable to integrate them to Atlas.
        Criteria:
        1. Have Pet Owner Record Type.
        2. Do not have an Atlas Id
        3. Have Email set (Required field for Atlas Integration)
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param triggerNew 
    **/
    global static void filterAndCreatePetOwners( List<Contact> triggerNew )
    {
        System.debug( 'entering atlas filtering' );
        List<Contact> contactsToCreate = new List<Contact>();
        for ( Contact aContact : triggerNew )
        {
            if ( aContact.RecordTypeId == PET_OWNER_RT_ID && aContact.ZTS_US_Atlas_Id__c == null &&
                // Email is a required paramater in the Atlas API
                string.isNotBlank(aContact.Email))
            {
                contactsToCreate.add( aContact );
            }
        }

        if ( !contactsToCreate.isEmpty() )
        {
            System.enqueueJob( new AtlasIntegrationHelper( contactsToCreate ) );
        }
    }

    /**
    * @description Filters Pet records to only Pets that meet the following criteria and 
        kicks off a Queueable to integrate them to Atlas.
        Criteria:
        1. Have a Species of Canine or Feline
        2. Do not have an Atlas Id
        3. Have Name and Owner set (Required field for Atlas Integration)
        4. Their Owner has an Email or Atlas Id specified (Required field for Atlas Integration)
		5. Pet should not be sent if Owner is not a Pet Owner record type contact
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param triggerNew 
    **/
    global static void filterAndCreatePets( List<ZTS_US_Animal__c> triggerNew )
    {
        Map<Id, List<ZTS_US_Animal__c>> petsToCreateByContact = new Map<Id, List<ZTS_US_Animal__c>>();
        for ( ZTS_US_Animal__c aPet : triggerNew )
        {
            if ( ( aPet.ZTS_US_Species__c == 'Canine' || aPet.ZTS_US_Species__c == 'Feline' ) && aPet.ZTS_US_Atlas_Id__c == null &&
                // Required fields for Atlas API. 
                // Species is also required, but covered by the Canine/Feline check.
                // Is Male (Sex field) is also technically required, but defaults to false if null. As a result, it's not checked.
                string.isNotBlank(aPet.Name) && aPet.ZTS_US_Pet_Owner__c != null)
            {
                if (petsToCreateByContact.containsKey(aPet.ZTS_US_Pet_Owner__c) == false) {
                    petsToCreateByContact.put(aPet.ZTS_US_Pet_Owner__c, new List<ZTS_US_Animal__c>());
                }

                petsToCreateByContact.get(aPet.ZTS_US_Pet_Owner__c).add(aPet);
            }
        }

        List<ZTS_US_Animal__c> petsToCreate = new List<ZTS_US_Animal__c>();
        Map<Id, Contact> petOwnerMap = new Map<Id, Contact>();
        if (!petsToCreateByContact.isEmpty()) {
            // On the Pet Owner, Email or Atlas Id are required, and pet owner must be Pet Owner record type
            for (Contact contact : ContactSelector.newInstance().selectPetOwnerContactsById(new List<Id>(petsToCreateByContact.keyset()))) {
                if (contact.RecordTypeId == PET_OWNER_RT_ID && (string.isNotBlank(contact.Email) || string.isNotBlank(contact.ZTS_US_Atlas_Id__c))) {
                    petsToCreate.addAll(petsToCreateByContact.get(contact.Id));
                    petOwnerMap.put(contact.Id, contact);
                }
            }
        }

        if ( !petsToCreate.isEmpty() )
        {
            System.enqueueJob( new AtlasIntegrationHelper( petsToCreate, petOwnerMap ) );
        }
    }

    /**
    * @description Approves or rejects an Anonymization of a Contact by 
        setting ZTS_US_Anonymization_Request_Message__c and ZTS_US_Anonymization_Date__c.
        Anonymization is approved if the Contact is not currently related to an Animal Support Case 
        of Type Animal Complain or Human Exposure.
        If Approved and this is the only Contact on its related Account or all Contacts on the Household are anonymized,
        the related Household Account's Name will be updated to "[Contact.Name] Household".
        If Approved, but there are other non-anonymized Contacts, the Household Name is updated to "[otherContact.Name Household]".
        These checks just determine whether the Contact can be anonymized. If it can, Atlas triggers the data update from its side.
    * @author Neil Kapoor @ Slalom | 10-28-2021
    * @param triggerNew 
    * @param triggerOldMap 
    **/
    global static void handleContactsForAnonymization( List<Contact> triggerNew, Map<Id, Contact> triggerOldMap )
    {
        System.debug( 'anonymizing' );
        // first lets check to see if there is an anonymization request coming through
        List<Contact> filteredContacts = new List<Contact>();
        for ( Contact aContact : triggerNew )
        {
            Contact oldContact = triggerOldMap.get( aContact.Id );
            if ( aContact.ZTS_US_Anonymized__c && aContact.ZTS_US_Anonymization_Date__c == null )
            {
                filteredContacts.add( aContact );
            }
        }

        // if we have any anonymization requests coming in, we have 2 things to check: 
        // 1. is it potentially related to a reportable case?
        // 2. can we just anonymize
        if ( !filteredContacts.isEmpty() )
        {
            final Set<String> caseTypes = new Set<String>{ 'Animal Complaint', 'Human Exposure' };
            // lets query for related cases for these contacts
            List<Case_Contact__c> relatedCaseContacts = [ SELECT Id, 
                                                                Case__c,
                                                                Case__r.CaseNumber,
                                                                Case__r.RecordTypeId,
                                                                Case__r.RecordType.DeveloperName,
                                                                Case__r.Type,
                                                                Contact__c
                                                            FROM Case_Contact__c 
                                                            WHERE Contact__c IN :filteredContacts 
                                                                AND Case__r.RecordType.DeveloperName = 'Animal_Support'
                                                                AND Case__r.Type IN :caseTypes ];

            // if we have related case contact records, lets group them by contact id => list of case contacts
            Map<Id, List<Case_Contact__c>> contactToCaseContacts = new Map<Id, List<Case_Contact__c>>();
            if ( !relatedCaseContacts.isEmpty() )
            {
                for ( Case_Contact__c aCaseContact : relatedCaseContacts )
                {
                    List<Case_Contact__c> innerCaseContacts = contactToCaseContacts.containsKey( aCaseContact.Contact__c ) 
                                                                    ? contactToCaseContacts.get( aCaseContact.Contact__c )
                                                                    : new List<Case_Contact__c>();

                    innerCaseContacts.add( aCaseContact );
                    contactToCaseContacts.put( aCaseContact.Contact__c, innerCaseContacts );
                }
            }

            // now lets pluck out the related account ids for the contacts
            Set<Id> accountIds = new Set<Id>();

            for ( Contact aContact : filteredContacts )
            {
                if ( aContact.AccountId != null )
                {
                    accountIds.add( aContact.AccountId );
                }
            }

            // lets query the related accounts and the contacts under them
            Map<Id, Account> relatedAccounts = new Map<Id, Account>( [ SELECT Id, 
                                                                            Name, 
                                                                            ( SELECT Id, 
                                                                                    Name, 
                                                                                    ZTS_US_Anonymized__c
                                                                                FROM Contacts )
                                                                        FROM Account 
                                                                        WHERE Id IN :accountIds ] );

            
            List<Account> accountsToUpdate = new List<Account>();

            // now lets do the following:
            // 1. lets iterate over the filtered contacts
            for ( Contact aContact : filteredContacts )
            {
                // 2. lets check to see if the filtered contact is related to a case - the query filtered the ones we need to not anonymize for
                if ( contactToCaseContacts.containsKey( aContact.Id ) )
                {
                    Contact oldContact = triggerOldMap.get( aContact.Id );
                    List<Case_Contact__c> caseContacts = contactToCaseContacts.get( aContact.Id );
                    String caseAnonymizationMessage = 'The following contact could not be anonymized due to being related to the following reportable cases: \n\n';

                    for ( Case_Contact__c aCaseContact : caseContacts )
                    {
                        caseAnonymizationMessage += aCaseContact.Case__r.CaseNumber + '\n';
                    }

                    // 3. lets reject the anonymization request

                    aContact.FirstName = oldContact.FirstName;
                    aContact.LastName = oldContact.LastName;
                    aContact.Email = oldContact.Email;
                    aContact.Interface_Email__c = oldContact.Email;
                    aContact.Phone = oldContact.Phone;
                    aContact.MobilePhone = oldContact.MobilePhone;
                    aContact.MailingStreet = oldContact.MailingStreet;
                    aContact.MailingCity = oldContact.MailingCity;
                    aContact.MailingState = oldContact.MailingState;
                    aContact.MailingPostalCode = oldContact.MailingPostalCode;
                    aContact.ZTS_US_Anonymization_Date__c = DateTime.now();
                    aContact.ZTS_US_Anonymization_Request_Message__c = caseAnonymizationMessage;
                }               
                // 4. we don't have any related cases we need to worry about so lets anonymize the contact
                else 
                {
                    // lets check to see if there is another contact on the account
                    if ( relatedAccounts.containsKey( aContact.AccountId ) )
                    {
                        Account relatedAccount = relatedAccounts.get( aContact.AccountId );

                        // if there is not, lets anonymize the contact and propage the change to the account
                        if ( relatedAccount.Contacts.size() ==  0 || relatedAccount.Contacts.size() == 1 )
                        {
                            aContact.ZTS_US_Anonymization_Date__c = DateTime.now();
                            aContact.ZTS_US_Anonymization_Request_Message__c = 'Approved';
                            System.debug( 'account name before: ' + relatedAccount.Name );
                            relatedAccount.Name = aContact.FirstName + ' ' + aContact.LastName + ' Household';
                            // relatedAccount.Name.replace( relatedAccount.Name, aContact.FirstName + ' ' + aContact.LastName );
                            System.debug( 'account name after: ' + relatedAccount.Name );
                            accountsToUpdate.add( relatedAccount );
                        }
                        // if there is, lets anonymize the contact but not propagate the change to the account
                        else if ( relatedAccount.Contacts.size() > 1 ) 
                        {
                            Boolean otherContactDetected = false;
                            for ( Contact subContact : relatedAccount.Contacts )
                            {
                                if ( subContact.Id != aContact.Id && !subContact.ZTS_US_Anonymized__c )
                                {
                                    otherContactDetected = true;
                                    relatedAccount.Name = subContact.Name + ' Household';
                                    accountsToUpdate.add( relatedAccount );
                                    break;
                                }
                            }

                            if ( otherContactDetected )
                            {
                                aContact.ZTS_US_Anonymization_Date__c = DateTime.now();
                                aContact.ZTS_US_Anonymization_Request_Message__c = 'Approved, another Pet Owner detected in Household';
                            }
                            else 
                            {
                                aContact.ZTS_US_Anonymization_Date__c = DateTime.now();
                                aContact.ZTS_US_Anonymization_Request_Message__c = 'Approved';
                                // relatedAccount.Name.replace( relatedAccount.Name, aContact.FirstName + ' ' + aContact.LastName );
                                // relatedAccount.Name = aContact.Name + ' Household';
                                relatedAccount.Name = aContact.FirstName + ' ' + aContact.LastName + ' Household';

                                accountsToUpdate.add( relatedAccount );
                            }
                        }

                    }          

                }
            }

            // lets update our accounts if we have any to update
            if ( !accountsToUpdate.isEmpty() )
            {
                try 
                {
                    DispatchTriggerHandler.bypass('AccountTriggerHandler');
                    update accountsToUpdate;
                    DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
                }
                catch ( Exception e )
                {
                    System.debug( 'exception updating accounts - ' + e.getMessage() );
                }
            }
        }
    }

}