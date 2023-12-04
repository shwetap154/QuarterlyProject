/**
 * @description       : All Trigger Test Logic for AtlasIntegrationHelper.
 * @author            : Neil Kapoor @ Slalom | 10-28-2021
 * @group             : 
 * @last modified on  : 03-17-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   10-28-2021   Neil Kapoor @ Slalom        Initial Version
 * 1.1   10-28-2021   Ethan Hirsch @ Zoetis Inc   Added tests to verify the integration does not run if required fields are missing. 
 *                                                Also light refactoring/code cleanup
 * 1.2   08-24-2022   Chelsea Paice @ Zoetis Inc  Adapted contact creation in pass/fail tests to overcome duplicate prevention
**/
@IsTest
private class AtlasIntegrationHelperTest 
{
    static final String FIRST_NAME = 'Test';
    static final String LAST_NAME = 'Pet Owner Contact';
    static final String EMAIL_ADDR = 'testemail+123@atlastest.com';

    static final String SECOND_FIRST_NAME = 'Sample';
    static final String SECOND_LAST_NAME = 'LastName';
    static final String SECOND_EMAIL_ADDR = 'testemail+456@atlastest.com';

    static final String PETOWNER_ATLAS_ID = 'abc1234';
    static final String TESTPETOWNER_ATLAS_ID = 'abc1235';
    static final String PET_ATLAS_ID = 'def5678';
    static final Integer SUCCESS_CODE = 201;
    static final Integer ERROR_CODE = 400;
    static final String ERROR_TEXT = 'Test Error';
    static final String ERROR_MESSAGE = 'test error message';
    static final String ANONYMIZED_NAME = 'Anonymous';
    static final String ANONYMIZED_EMAIL = 'anon@anonymized.com';

    static final String MULTI_CONTACT_A = 'abc';
    static final String MULTI_CONTACT_B = 'def';
    static final String MULTI_CONTACT_C = 'ghi';

    static final String VMIPS_CASE_RT = 'Animal_Support';
    static final String ANIMAL_COMPLAINT_CASE_TYPE = 'Animal Complaint';

    @TestSetup
    static void setup()
    {
        Contact aContact = new Contact( 
            FirstName = FIRST_NAME + MULTI_CONTACT_A,
            LastName = LAST_NAME + MULTI_CONTACT_A,
            RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID,
            Interface_Email__c = EMAIL_ADDR + MULTI_CONTACT_A,
            Email = EMAIL_ADDR + MULTI_CONTACT_A,
            ZTS_US_Atlas_Id__c = PETOWNER_ATLAS_ID + MULTI_CONTACT_A
        );

        Contact secondContact = new Contact(
            FirstName = FIRST_NAME + MULTI_CONTACT_B,
            LastName = LAST_NAME + MULTI_CONTACT_B,
            RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID,
            Interface_Email__c = EMAIL_ADDR + MULTI_CONTACT_B,
            Email = EMAIL_ADDR + MULTI_CONTACT_B,
            ZTS_US_Atlas_Id__c = PETOWNER_ATLAS_ID + MULTI_CONTACT_B
        );

        Contact thirdContact = new Contact(
            FirstName = FIRST_NAME + MULTI_CONTACT_C,
            LastName = LAST_NAME + MULTI_CONTACT_C,
            RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID,
            Interface_Email__c = EMAIL_ADDR + MULTI_CONTACT_C,
            Email = EMAIL_ADDR + MULTI_CONTACT_C,
            ZTS_US_Atlas_Id__c = PETOWNER_ATLAS_ID + MULTI_CONTACT_C
        );

        Contact testPetOwnerContact = new Contact( 
            FirstName = FIRST_NAME,
            LastName = LAST_NAME,
            RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID,
            Interface_Email__c = EMAIL_ADDR,
            Email = EMAIL_ADDR,
            ZTS_US_Atlas_Id__c = TESTPETOWNER_ATLAS_ID
        );

        insert new List<Contact>{ aContact, secondContact, thirdContact, testPetOwnerContact };

        // A Household Account is created via the Create Pet Owner Account Flow
        Contact queriedSecondContact = [ SELECT Id, AccountId FROM Contact WHERE Id = :secondContact.Id ];
        thirdContact.AccountId = queriedSecondContact.AccountId;

        update thirdContact;

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( VMIPS_CASE_RT ).getRecordTypeId();

        // Use a value for Status other than Open. 
        // Setting Status to open kicks off logic in CSE Milestone Automation that is data dependent on an Entitlement
        // in the Service Cloud Settings Custom Metadata Type's CSE Entitlment Name field.
        Case testestCase = ( Case ) SL_TestDataFactory.createSObject( 
            new Case(
                RecordTypeId = caseRecordTypeId,
                Subject = 'Test Case for ',
                Type = ANIMAL_COMPLAINT_CASE_TYPE,
                ZTS_EU_Sub_Type__c = 'VMIPS',
                Origin = 'Phone',
                Priority = 'Medium',
                Status = 'New'
            ), true );

        ZTS_US_Breed__c breed = ZTS_DataUtilityTest.createBreeds(1, 'Canine')[0];
        insert breed;
        
    }

    @IsTest
    static void testCreatePetOwner_pass()
    {
        setupSuccessMock(PETOWNER_ATLAS_ID);
		String nameMod = LAST_NAME + 'jkl';
        Contact testPetOwnerContact = new Contact( 
            FirstName = FIRST_NAME,
            LastName = nameMod,
            RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID,
            Interface_Email__c = EMAIL_ADDR,
            Email = EMAIL_ADDR
        );

        Test.startTest();
        
        insert testPetOwnerContact;

        Test.stopTest();

        Contact queriedContact = [ SELECT Id, 
                                          ZTS_US_Atlas_Id__c 
                                    FROM Contact 
                                    WHERE Id = :testPetOwnerContact.Id ];

        System.assertEquals( PETOWNER_ATLAS_ID, queriedContact.ZTS_US_Atlas_Id__c, 'We expect to have successfully done a callout to Atlas and updated the pet owner with an Atlas Id.' );
    }

    @IsTest
    static void testCreatePetOwner_fail()
    {
        String nameMod = LAST_NAME + 'jkl';
        setupErrorMock();
        Contact testPetOwnerContact = new Contact( 
            FirstName = FIRST_NAME,
            LastName = nameMod,
            RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID,
            Interface_Email__c = EMAIL_ADDR,
            Email = EMAIL_ADDR
        );

        Test.startTest();
        
        insert testPetOwnerContact;

        Test.stopTest();

        Contact queriedContact = [ SELECT Id, 
                                          ZTS_US_Atlas_Id__c 
                                    FROM Contact 
                                    WHERE Id = :testPetOwnerContact.Id ];

        System.assert( String.isBlank( queriedContact.ZTS_US_Atlas_Id__c ), 'We expect to not have an Atlas Id set on the Contact when there is an error creating the Pet Owner in Atlas.' ) ;
    }

    @IsTest
    static void testCreatePetOwner_fail_MissingRequiredField()
    {
        // Setup a success mock so that Atlas Id is set if the integration succeeds incorrectly.
        setupSuccessMock(PETOWNER_ATLAS_ID);

        Contact testPetOwnerContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
        testPetOwnerContact.RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID;
        // Email is a required field, so the integration should not run with it set to null
        testPetOwnerContact.Email = null;

        Test.startTest();
            insert testPetOwnerContact;
        Test.stopTest();

        Contact queriedContact = [ SELECT Id, 
                                          ZTS_US_Atlas_Id__c 
                                    FROM Contact 
                                    WHERE Id = :testPetOwnerContact.Id ];

        System.assert( String.isBlank( queriedContact.ZTS_US_Atlas_Id__c ), 
            'We expect to not have an Atlas Id set on the Contact when there is a missing required field creating the Pet Owner in Atlas.' ) ;
    }

    @IsTest
    static void testCreatePet_pass()
    {
        Contact testPetOwnerContact = retrievePetOwnerContact();

        setupSuccessMock(PET_ATLAS_ID);

        ZTS_US_Animal__c testPet = new ZTS_US_Animal__c(
            Name = 'Bailey',
            ZTS_US_Pet_Owner__c = testPetOwnerContact.Id,
            ZTS_US_Species__c = 'Canine',
            ZTS_US_Sex__c = 'Female',
            // Set Date of Birth to a past date so Age is calculate to be more than zero.
            ZTS_US_Date_of_Birth__c = Date.today().addDays(-21),
            ZTS_US_Breed__c = retrieveTestBreed().Id
        );

        Test.startTest();
            
            insert testPet;

        Test.stopTest();

        ZTS_US_Animal__c queriedAnimal = [ SELECT Id, 
                                                  ZTS_US_Atlas_Id__c
                                            FROM ZTS_US_Animal__c
                                            WHERE Id = :testPet.Id ];

        System.assertEquals( PET_ATLAS_ID, queriedAnimal.ZTS_US_Atlas_Id__c, 'We expect to have updated the Pet record with an Atlas Id when it is succesfully created in Atlas. ' );
    }

    @IsTest
    static void testCreatePet_fail()
    {
        Contact testPetOwnerContact = retrievePetOwnerContact();
        setupErrorMock();

        ZTS_US_Animal__c testPet = new ZTS_US_Animal__c(
            Name = 'Bailey',
            ZTS_US_Pet_Owner__c = testPetOwnerContact.Id,
            ZTS_US_Species__c = 'Canine',
            ZTS_US_Sex__c = 'Female',
            // Set Date of Birth to a past date so Age is calculate to be more than zero.
            ZTS_US_Date_of_Birth__c = Date.today().addDays(-21),
            ZTS_US_Breed__c = retrieveTestBreed().Id
        );

        Test.startTest();
            
            insert testPet;

        Test.stopTest();

        ZTS_US_Animal__c queriedAnimal = [ SELECT Id, 
                                                  ZTS_US_Atlas_Id__c
                                            FROM ZTS_US_Animal__c
                                            WHERE Id = :testPet.Id ];

        System.assert( String.isBlank( queriedAnimal.ZTS_US_Atlas_Id__c ), 'We expect to not have updated the Pet record with an Atlas Id when it fails being created in Atlas. ' );
    }

    @IsTest
    static void testCreatePet_fail_MissingRequiredFieldPet()
    {
        // Setup a success mock so that Atlas Id is set if the integration succeeds incorrectly.
        setupSuccessMock(PET_ATLAS_ID);

        // Set Date of Birth to a past date so Age is calculate to be more than zero.
        ZTS_US_Animal__c testPet = ZTS_DataUtilityTest.createAnimals(1, Date.today().addDays(-21))[0];
        // Pet Owner is required for the integration to run. Confirm that if it's not populated the integration doesn't run.
        testPet.ZTS_US_Pet_Owner__c = null;
        testPet.ZTS_US_Species__c = 'Canine';
        testPet.ZTS_US_Sex__c = 'Female';
        testPet.ZTS_US_Breed__c = retrieveTestBreed().Id;

        Test.startTest();
            insert testPet;
        Test.stopTest();

        ZTS_US_Animal__c queriedAnimal = [ SELECT Id, 
                                                  ZTS_US_Atlas_Id__c
                                            FROM ZTS_US_Animal__c
                                            WHERE Id = :testPet.Id ];

        System.assert(string.isBlank(queriedAnimal.ZTS_US_Atlas_Id__c), 
            'We expect to not have updated the Pet record with an Atlas Id when there is a missing field for the integration.');
    }

    @IsTest
    static void testCreatePet_fail_MissingRequiredFieldOnPetOwner()
    {
        // Setup a success mock so that Atlas Id is set if the integration succeeds incorrectly.
        setupSuccessMock(PET_ATLAS_ID);

        // Email or Alias must be set on the Pet Owner for the integration to succeed.
        // Create a new Contact rather than update the existing one due to logic preventing Email from being cleared out.
        Contact testPetOwnerContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
        testPetOwnerContact.RecordTypeId = AtlasIntegrationHelper.PET_OWNER_RT_ID;
        testPetOwnerContact.Email = null;
        testPetOwnerContact.ZTS_US_Atlas_Id__c = null;
        insert testPetOwnerContact;

        // Set Date of Birth to a past date so Age is calculate to be more than zero.
        ZTS_US_Animal__c testPet = ZTS_DataUtilityTest.createAnimals(1, Date.today().addDays(-21))[0];
        testPet.ZTS_US_Pet_Owner__c = testPetOwnerContact.Id;
        testPet.ZTS_US_Species__c = 'Canine';
        testPet.ZTS_US_Sex__c = 'Female';
        testPet.ZTS_US_Breed__c = retrieveTestBreed().Id;

        Test.startTest();
            insert testPet;
        Test.stopTest();

        ZTS_US_Animal__c queriedAnimal = [ SELECT Id, 
                                                  ZTS_US_Atlas_Id__c
                                            FROM ZTS_US_Animal__c
                                            WHERE Id = :testPet.Id ];

        System.assert(string.isBlank( queriedAnimal.ZTS_US_Atlas_Id__c ), 
            'We expect to not have updated the Pet record with an Atlas Id when there is a missing field for the integration.');
    }

    @IsTest 
    static void testAnonymize_SingleContact_pass()
    {
        String queryEmailAddr = EMAIL_ADDR + MULTI_CONTACT_A;

        Contact queriedPetOwner = [ SELECT Id,
                                           FirstName, 
                                           LastName,
                                           Email,
                                           Interface_Email__c,
                                           ZTS_US_Anonymized__c
                                    FROM Contact 
                                    WHERE Email = :queryEmailAddr ];

        queriedPetOwner.FirstName = ANONYMIZED_NAME;
        queriedPetOwner.LastName = ANONYMIZED_NAME;
        queriedPetOwner.Email = ANONYMIZED_EMAIL;
        queriedPetOwner.Interface_Email__c = ANONYMIZED_EMAIL;
        queriedPetOwner.ZTS_US_Anonymized__c = true;

        System.debug( 'queried pet owner in test: ' + JSON.serializePretty( queriedPetOwner ) );

        Test.startTest();
            update queriedPetOwner;
        Test.stopTest();

        Contact queriedContact = [ SELECT Id,
                                          FirstName,
                                          LastName,
                                          Email, 
                                          Account.Name, 
                                          ZTS_US_Anonymized__c,
                                          ZTS_US_Anonymization_Date__c,
                                          ZTS_US_Anonymization_Request_Message__c
                                    FROM Contact
                                    WHERE Id = :queriedPetOwner.Id ];


    
        
        System.assertEquals( ANONYMIZED_NAME, queriedContact.FirstName, 'We expect the first name field to be anonymized.' );
        System.assertEquals( ANONYMIZED_NAME, queriedContact.LastName, 'We expect the last name field to be anonymized.' );
        System.assertEquals( ANONYMIZED_EMAIL, queriedContact.Email, 'We expect the email field to be anonymized.'  + JSON.serialize( queriedContact ));
        System.assert( queriedContact.Account.Name.contains( ANONYMIZED_NAME ), 'We expect the household name to be anonymized' );
        System.assertNotEquals( null, queriedContact.ZTS_US_Anonymization_Date__c, 'We expect the anonymization date to be set when an anonymiozation is succesful.' );
        System.assert( String.isNotBlank( queriedContact.ZTS_US_Anonymization_Request_Message__c ), 'We expect the anonymization message to not be blank when an anonymization request is successful.' );
    }

    @IsTest
    static void testAnonymize_multicontact_pass()
    {
        String queryEmailAddr = EMAIL_ADDR + MULTI_CONTACT_B;

        Contact queriedPetOwner = [ SELECT Id,
                                           FirstName, 
                                           LastName,
                                           Email,
                                           Interface_Email__c,
                                           ZTS_US_Anonymized__c
                                    FROM Contact 
                                    WHERE Email = :queryEmailAddr ];

        queriedPetOwner.FirstName = ANONYMIZED_NAME;
        queriedPetOwner.LastName = ANONYMIZED_NAME;
        queriedPetOwner.Email = ANONYMIZED_EMAIL;
        queriedPetOwner.Interface_Email__c = ANONYMIZED_EMAIL;
        queriedPetOwner.ZTS_US_Anonymized__c = true;

        Test.startTest();
            update queriedPetOwner;
        Test.stopTest();

        Contact queriedContact = [ SELECT Id,
                                          FirstName,
                                          LastName,
                                          Email, 
                                          Account.Name, 
                                          ZTS_US_Anonymized__c,
                                          ZTS_US_Anonymization_Date__c,
                                          ZTS_US_Anonymization_Request_Message__c
                                    FROM Contact
                                    WHERE Id = :queriedPetOwner.Id ];


    
        
        System.assertEquals( ANONYMIZED_NAME, queriedContact.FirstName, 'We expect the first name field to be anonymized.' );
        System.assertEquals( ANONYMIZED_NAME, queriedContact.LastName, 'We expect the last name field to be anonymized.' );
        System.assertEquals( ANONYMIZED_EMAIL, queriedContact.Email, 'We expect the email field to be anonymized.'  + JSON.serialize( queriedContact ));
        System.assert( !queriedContact.Account.Name.contains( ANONYMIZED_NAME ), 'We expect the household name not to be anonymized' );
        System.assert( queriedContact.Account.Name.contains( LAST_NAME + MULTI_CONTACT_C ), 'We expect the household name to be updated to the 2nd contact on the account\'s name.' );
        System.assertNotEquals( null, queriedContact.ZTS_US_Anonymization_Date__c, 'We expect the anonymization date to be set when an anonymiozation is succesful.' );
        System.assert( String.isNotBlank( queriedContact.ZTS_US_Anonymization_Request_Message__c ), 'We expect the anonymization message to not be blank when an anonymization request is successful.' );
    }

    @IsTest
    static void test_reject_anonymization()
    {
        String queryEmailAddr = EMAIL_ADDR + MULTI_CONTACT_A;
        
        Case testCase = [ SELECT Id FROM Case ];
        Contact testContact = [ SELECT Id,
                                       FirstName, 
                                       LastName,
                                       Email,
                                       Interface_Email__c,
                                       ZTS_US_Anonymized__c
                                    FROM Contact 
                                    WHERE Email = :queryEmailAddr ];
        
        Case_Contact__c aCaseContact = new Case_Contact__c(
            Case__c = testCase.Id, 
            Contact__c = testContact.Id 
        );

        insert aCaseContact;

        testContact.FirstName = ANONYMIZED_NAME;
        testContact.LastName = ANONYMIZED_NAME;
        testContact.Email = ANONYMIZED_EMAIL;
        testContact.Interface_Email__c = ANONYMIZED_EMAIL;
        testContact.ZTS_US_Anonymized__c = true;

        Test.startTest();
            update testContact;
        Test.stopTest();

        Contact queriedContact = [ SELECT Id,
                                          FirstName,
                                          LastName,
                                          Email, 
                                          Account.Name, 
                                          ZTS_US_Anonymized__c,
                                          ZTS_US_Anonymization_Date__c,
                                          ZTS_US_Anonymization_Request_Message__c
                                    FROM Contact
                                    WHERE Id = :testContact.Id ];

        System.assertNotEquals( ANONYMIZED_NAME, queriedContact.FirstName, 'We expect the first name field to be not anonymized as there is a related reportable case.' );
        System.assertNotEquals( ANONYMIZED_NAME, queriedContact.LastName, 'We expect the last name field to be not anonymized as there is a related reportable case.' );
        System.assertNotEquals( ANONYMIZED_EMAIL, queriedContact.Email, 'We expect the email field to be not anonymized as there is a related reportable case.'  + JSON.serialize( queriedContact ));
        System.assert( !queriedContact.Account.Name.contains( ANONYMIZED_NAME ), 'We expect the household name not to be anonymized' );
        System.assertNotEquals( null, queriedContact.ZTS_US_Anonymization_Date__c, 'We expect the anonymization date to be set when an anonymiozation is succesful.' );
        System.assert( String.isNotBlank( queriedContact.ZTS_US_Anonymization_Request_Message__c ), 'We expect the anonymization message to not be blank when an anonymization request is successful.' );
    }

    private static ZTS_US_Breed__c retrieveTestBreed() {
        return [SELECT ID FROM ZTS_US_Breed__c LIMIT 1];
    }

    private static Contact retrievePetOwnerContact() {
        return [SELECT Id FROM Contact WHERE ZTS_US_Atlas_Id__c =: TESTPETOWNER_ATLAS_ID LIMIT 1];
    }

    private static void setupSuccessMock(string id) {
        JSONGenerator jsonGen = JSON.createGenerator( false );
        jsonGen.writeStartObject();
        jsonGen.writeStringField( 'id', id );
        jsonGen.writeEndObject();

        String responseBody = jsonGen.getAsString();

        jsonGen.close();

        AtlasIntegrationMock mock = new AtlasIntegrationMock( SUCCESS_CODE, responseBody );

        Test.setMock( HttpCalloutMock.class, mock );
    }

    private static void setupErrorMock() {
        JSONGenerator jsonGen = JSON.createGenerator( false );
        jsonGen.writeStartObject();
        jsonGen.writeStringField( 'error', ERROR_TEXT );
        jsonGen.writeStringField( 'message', ERROR_MESSAGE );
        jsonGen.writeEndObject();

        String responseBody = jsonGen.getAsString();

        jsonGen.close();

        AtlasIntegrationMock mock = new AtlasIntegrationMock( ERROR_CODE, responseBody );

        Test.setMock( HttpCalloutMock.class, mock );
    }
}