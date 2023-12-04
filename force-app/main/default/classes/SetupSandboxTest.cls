/**
 * @description Test class for SetupSandbox
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 11-11-2022
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with tests for running the script with and without existing data
 */
@isTest
private class SetupSandboxTest {
    @isTest
    private static void runApexClass_NoDataTest() {
        SetupSandbox runSetupSandbox = new SetupSandbox();
        Test.startTest();
            Test.testSandboxPostCopyScript(runSetupSandbox, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationName());
        Test.stopTest();

        List<RingLeadTrigger__Batch_Settings__c> ringLeadTriggerSettings = [
            SELECT Id, RingLeadTrigger__Batch_Size__c
            FROM RingLeadTrigger__Batch_Settings__c
            LIMIT 2];

        System.assertEquals(1, ringLeadTriggerSettings.size(), 'More/Less Ring Lead Trigger Settings were created than expected.');
        
        System.assertEquals(2000, ringLeadTriggerSettings[0].RingLeadTrigger__Batch_Size__c,
            'Batch Size was not set to 2000 as expected.');

        Map<String, SetupSandbox.ServiceCloudEntitlementData> expectedEntitlementMap = new Map<String, SetupSandbox.ServiceCloudEntitlementData>();
        for (SetupSandbox.ServiceCloudEntitlementData entitlementData : SetupSandbox.serviceCloudEntitlementDataByFields.values()) {
            expectedEntitlementMap.put(entitlementData.name, entitlementData);
        }

        List<Entitlement> entitlements = [
            SELECT Id, Name, AccountId, Type, StartDate, EndDate, BusinessHours.Name, SlaProcess.Name
            FROM Entitlement
            WHERE Name in: expectedEntitlementMap.keySet()];

        System.assertEquals(expectedEntitlementMap.size(), entitlements.size(),
            'More/Less Entitlements were created than expected.');

        for (Entitlement entitlementRecord: entitlements) {
            System.assert(expectedEntitlementMap.containsKey(entitlementRecord.Name), 
                String.format('Entitlement {0} Not Found', new List<String> {entitlementRecord.Name}));

            SetupSandbox.ServiceCloudEntitlementData entitlementData = expectedEntitlementMap.get(entitlementRecord.Name);
            System.assertEquals(entitlementData.name, entitlementRecord.Name, 'Name was not set correctly.');
            System.assertEquals(entitlementData.businessHoursName, entitlementRecord.BusinessHours.Name, 
                'Business Hours was not set correctly');
            
            System.assertEquals(entitlementData.entitlementProcessName, entitlementRecord.SlaProcess.Name,
                'Entitlement Process as not set correctly.');

            System.assertNotEquals(null, entitlementRecord.AccountId, 'Account was not set as expected.');
            System.assertEquals('Phone Support', entitlementRecord.Type, 'Type was not set as expected.');
            System.assertEquals(System.today(), entitlementRecord.StartDate, 'Start Date was not set as expected.');
            System.assertEquals(Date.newInstance(2050, 1, 25), entitlementRecord.EndDate,
                'End Date was not set as expected.');
        }

    }

    @isTest
    private static void runApexClass_ExistingDataTest() {
        // To keep this class isolated, and because this is from a managed package, no Utils class is used
        insert new RingLeadTrigger__Batch_Settings__c(
            RingLeadTrigger__Batch_Size__c = 2000
        );

        Account entitlementAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        insert entitlementAccount;

        List<Entitlement> existingEntitlementRecords = new List<Entitlement>();
        Map<String, Schema.SObjectField> expectedSettingFieldsByEntitlementName = new Map<String, Schema.SObjectField>();
        for (Schema.SobjectField metadataField : SetupSandbox.serviceCloudEntitlementDataByFields.keySet()) {
            SetupSandbox.ServiceCloudEntitlementData entitlementData = SetupSandbox.serviceCloudEntitlementDataByFields.get(metadataField);
            existingEntitlementRecords.add(
                ZTS_DataUtilityTest.createEntitlement(entitlementData.name, entitlementAccount.Id));

            expectedSettingFieldsByEntitlementName.put(entitlementData.name, metadataField);
        }

        insert existingEntitlementRecords;

        Service_Cloud_Settings__mdt serviceCloudSettings = new Service_Cloud_Settings__mdt();
        for (Entitlement entitlementRecord : existingEntitlementRecords) {
            serviceCloudSettings.put(expectedSettingFieldsByEntitlementName.get(entitlementRecord.Name),
                entitlementRecord.Id);
        }

        SetupSandbox setupSandbox = new SetupSandbox();
        setupSandbox.serviceCloudSettings = serviceCloudSettings;
        Test.startTest();
            Test.testSandboxPostCopyScript(setupSandbox, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationName());
        Test.stopTest();


        List<RingLeadTrigger__Batch_Settings__c> allRingLeadTriggerSettings = [
            SELECT Id, RingLeadTrigger__Batch_Size__c
            FROM RingLeadTrigger__Batch_Settings__c
            LIMIT 2];

        System.assertEquals(1, allRingLeadTriggerSettings.size(),
            'An additional Ring Lead Trigger Settings was created unexpectedly.');
            
        List<Entitlement> allEntitlements = [
            SELECT Id
            FROM Entitlement
            WHERE Name in: expectedSettingFieldsByEntitlementName.keySet()];

        System.assertEquals(expectedSettingFieldsByEntitlementName.size(), allEntitlements.size(),
            'More Entitlements were created than expected.');
    }

    @isTest
    private static void runApexClass_SomeExistingEntitlementsTest() {
        Account entitlementAccount = ZTS_DataUtilityTest.createAccountRecord(1)[0];
        insert entitlementAccount;

        List<Entitlement> existingEntitlementRecords = new List<Entitlement>();
        Map<String, Schema.SObjectField> expectedSettingFieldsByEntitlementName = new Map<String, Schema.SObjectField>();

        // Create half of the Entitlement records
        integer maxEntitlements = SetupSandbox.serviceCloudEntitlementDataByFields.size() / 2;
        for (Schema.SObjectField metadataField : SetupSandbox.serviceCloudEntitlementDataByFields.keySet()) {
            SetupSandbox.ServiceCloudEntitlementData entitlementData = SetupSandbox.serviceCloudEntitlementDataByFields.get(metadataField);
            existingEntitlementRecords.add(
                ZTS_DataUtilityTest.createEntitlement(entitlementData.name, entitlementAccount.Id));

            expectedSettingFieldsByEntitlementName.put(entitlementData.name, metadataField);

            // Stop the loop once the max limit is reached
            if (expectedSettingFieldsByEntitlementName.size() >= maxEntitlements) {
                break;
            }
        }

        insert existingEntitlementRecords;

        Set<Id> existingEntitlementRecordIds = new Map<Id, Entitlement>(existingEntitlementRecords).keySet();

        Service_Cloud_Settings__mdt serviceCloudSettings = new Service_Cloud_Settings__mdt();
        for (Entitlement entitlementRecord : existingEntitlementRecords) {
            serviceCloudSettings.put(expectedSettingFieldsByEntitlementName.get(entitlementRecord.Name),
                entitlementRecord.Id);
        }

        SetupSandbox runSetupSandbox = new SetupSandbox();
        runSetupSandbox.serviceCloudSettings = serviceCloudSettings;
        Test.startTest();
            Test.testSandboxPostCopyScript(runSetupSandbox, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationName());
        Test.stopTest();

        List<RingLeadTrigger__Batch_Settings__c> ringLeadTriggerSettings = [
            SELECT Id, RingLeadTrigger__Batch_Size__c
            FROM RingLeadTrigger__Batch_Settings__c
            LIMIT 2];

        System.assertEquals(1, ringLeadTriggerSettings.size(), 'More/Less Ring Lead Trigger Settings were created than expected.');
        
        System.assertEquals(2000, ringLeadTriggerSettings[0].RingLeadTrigger__Batch_Size__c,
            'Batch Size was not set to 2000 as expected.');

        Map<String, SetupSandbox.ServiceCloudEntitlementData> expectedEntitlementMap = new Map<String, SetupSandbox.ServiceCloudEntitlementData>();
        for (SetupSandbox.ServiceCloudEntitlementData entitlementData : SetupSandbox.serviceCloudEntitlementDataByFields.values()) {
            expectedEntitlementMap.put(entitlementData.name, entitlementData);
        }

        List<Entitlement> allEntitlements = [
            SELECT Id, Name, AccountId, Type, StartDate, EndDate, BusinessHours.Name, SlaProcess.Name
            FROM Entitlement
            WHERE Name in: expectedEntitlementMap.keySet()];

        System.assertEquals(expectedEntitlementMap.size(), allEntitlements.size(),
            'More/Less Entitlements were created than expected.');

        for (Entitlement entitlementRecord: allEntitlements) {
            System.assert(expectedEntitlementMap.containsKey(entitlementRecord.Name), 
                String.format('Entitlement {0} Not Found', new List<String> {entitlementRecord.Name}));

            // Skip checking that pre-created Entitlements are setup correctly
            if (existingEntitlementRecordIds.contains(entitlementRecord.Id)) {
                continue;
            }

            SetupSandbox.ServiceCloudEntitlementData entitlementData = expectedEntitlementMap.get(entitlementRecord.Name);
            System.assertEquals(entitlementData.name, entitlementRecord.Name, 'Name was not set correctly.');
            System.assertEquals(entitlementData.businessHoursName, entitlementRecord.BusinessHours.Name, 
                'Business Hours was not set correctly');
            
            System.assertEquals(entitlementData.entitlementProcessName, entitlementRecord.SlaProcess.Name,
                'Entitlement Process as not set correctly.');

            System.assertNotEquals(null, entitlementRecord.AccountId, 'Account was not set as expected.');
            System.assertEquals('Phone Support', entitlementRecord.Type, 'Type was not set as expected.');
            System.assertEquals(System.today(), entitlementRecord.StartDate, 'Start Date was not set as expected.');
            System.assertEquals(Date.newInstance(2050, 1, 25), entitlementRecord.EndDate,
                'End Date was not set as expected.');
        }
    }

    @isTest
    private static void runApexClass_InvalidEntitlementIdsTest() {
        // Create half of the Entitlement records with bad values and half with invalid ids
        integer invalidIdCount = SetupSandbox.serviceCloudEntitlementDataByFields.size() / 2;
        Service_Cloud_Settings__mdt serviceCloudSettings = new Service_Cloud_Settings__mdt();
        Integer i = 0;
        for (Schema.SObjectField metadataField : SetupSandbox.serviceCloudEntitlementDataByFields.keySet()) {
            i++;
            String entitlementIdValue;
            if (invalidIdCount >= i) {
                entitlementIdValue = 'INVALID';
            }
            else {
                entitlementIdValue = '5505C0000000SZSQA2';
            }

            serviceCloudSettings.put(metadataField, entitlementIdValue);
        }

        SetupSandbox runSetupSandbox = new SetupSandbox();
        runSetupSandbox.serviceCloudSettings = serviceCloudSettings;
        Test.startTest();
            Test.testSandboxPostCopyScript(runSetupSandbox, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationName());
        Test.stopTest();

        List<RingLeadTrigger__Batch_Settings__c> ringLeadTriggerSettings = [
            SELECT Id, RingLeadTrigger__Batch_Size__c
            FROM RingLeadTrigger__Batch_Settings__c
            LIMIT 2];

        System.assertEquals(1, ringLeadTriggerSettings.size(), 'More/Less Ring Lead Trigger Settings were created than expected.');
        
        System.assertEquals(2000, ringLeadTriggerSettings[0].RingLeadTrigger__Batch_Size__c,
            'Batch Size was not set to 2000 as expected.');

        Map<String, SetupSandbox.ServiceCloudEntitlementData> expectedEntitlementMap = new Map<String, SetupSandbox.ServiceCloudEntitlementData>();
        for (SetupSandbox.ServiceCloudEntitlementData entitlementData : SetupSandbox.serviceCloudEntitlementDataByFields.values()) {
            expectedEntitlementMap.put(entitlementData.name, entitlementData);
        }

        List<Entitlement> allEntitlements = [
            SELECT Id, Name, AccountId, Type, StartDate, EndDate, BusinessHours.Name, SlaProcess.Name
            FROM Entitlement
            WHERE Name in: expectedEntitlementMap.keySet()];

        System.assertEquals(expectedEntitlementMap.size(), allEntitlements.size(),
            'More/Less Entitlements were created than expected.');

        for (Entitlement entitlementRecord: allEntitlements) {
            System.assert(expectedEntitlementMap.containsKey(entitlementRecord.Name), 
                String.format('Entitlement {0} Not Found', new List<String> {entitlementRecord.Name}));

            SetupSandbox.ServiceCloudEntitlementData entitlementData = expectedEntitlementMap.get(entitlementRecord.Name);
            System.assertEquals(entitlementData.name, entitlementRecord.Name, 'Name was not set correctly.');
            System.assertEquals(entitlementData.businessHoursName, entitlementRecord.BusinessHours.Name, 
                'Business Hours was not set correctly');
            
            System.assertEquals(entitlementData.entitlementProcessName, entitlementRecord.SlaProcess.Name,
                'Entitlement Process as not set correctly.');

            System.assertNotEquals(null, entitlementRecord.AccountId, 'Account was not set as expected.');
            System.assertEquals('Phone Support', entitlementRecord.Type, 'Type was not set as expected.');
            System.assertEquals(System.today(), entitlementRecord.StartDate, 'Start Date was not set as expected.');
            System.assertEquals(Date.newInstance(2050, 1, 25), entitlementRecord.EndDate,
                'End Date was not set as expected.');
        }
    }

    // As the Queueable updates Custom Metadata, it cannot be tested in a Unit Test.
    // This test just makes sure the Queueable updates the data passed to it
    @isTest
    private static void runQueueable() {
        // The Ids used below are valid Ids, but do not represent actual Entitlement
        Map<Schema.SObjectField, Id> newEntitlementIdsByServiceCloudSettingField = new Map<Schema.SObjectField, Id> {
            Service_Cloud_Settings__mdt.Billing_Inquiry_Entitlement_Record_Id__c  => '5505C0000000SZSQA2',
            Service_Cloud_Settings__mdt.CSE_Entitlement_Name__c => '5505C0000000SZTQA2'
        };

        SetupSandbox.UpdateCustomMetadata queueable = new SetupSandbox.UpdateCustomMetadata(newEntitlementIdsByServiceCloudSettingField);

        Test.startTest();
            queueable.execute(null);
        Test.stopTest();

        List<Metadata.Metadata> metadataRecords = queueable.mdContainerResult.getMetadata();
        System.assertEquals(1, metadataRecords.size(), 'Only 1 CustomMetadata Record should be setup.');

        Map<String, Schema.SObjectField> serviceCloudSettingsFieldMap = Schema.SObjectType.Service_Cloud_Settings__mdt.fields.getMap();
        for (Metadata.Metadata metadataRecord : metadataRecords) {
            Metadata.CustomMetadata customMetadataRecord = (Metadata.CustomMetadata)metadataRecord;
            System.assertEquals(newEntitlementIdsByServiceCloudSettingField.size(), customMetadataRecord.values.size(),
                'More/Less FIelds were set than expected.');

            for (Metadata.CustomMetadataValue customField : customMetadataRecord.values) {
                System.assert(serviceCloudSettingsFieldMap.containsKey(customField.field) &&
                    newEntitlementIdsByServiceCloudSettingField.containsKey(serviceCloudSettingsFieldMap.get(customField.field)),
                    String.format('Unexpected field {0}', new List<String> {customField.field}));

                System.assertEquals(
                    newEntitlementIdsByServiceCloudSettingField.get(serviceCloudSettingsFieldMap.get(customField.field)),
                    customField.value,
                    String.format('Unexpected value for field {0}', new List<String> {customField.field}));
            }
        }
    }
}