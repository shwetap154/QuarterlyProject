/**
 * @description This class is meant to be run after a Sandbox is created to setup custom metadata, custom settings, 
 *              and perform other setup operations that can be automated. 
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 11-18-2022
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version that creates Ring Lead Trigger Settings and Entitlements. Update Service Cloud Settings.
 * 1.1   11-15-2022   Ethan Hirsch @ Zoetis Inc   Fix Errors with the definition for some Entitlement records
 * 1.1   11-18-2022   Ethan Hirsch @ Zoetis Inc   Set fields on Account required by Validation Rules
 **/
global inherited sharing class SetupSandbox implements SandboxPostCopy  {
    // Keep track of Entitlement Fields and the Name, Business Hours, and Process in this map.
    // Schema.SObjectField is used to create a reference to the field.
    @testVisible
    private static Map<Schema.SObjectField, ServiceCloudEntitlementData> serviceCloudEntitlementDataByFields = new Map<Schema.SObjectField, ServiceCloudEntitlementData> {
        Service_Cloud_Settings__mdt.Billing_Inquiry_Entitlement_Record_Id__c => 
            new ServiceCloudEntitlementData('Billing Inquiry', 'Master Data Business Hours', 'Billing Inquiry'),
        Service_Cloud_Settings__mdt.CSE_Entitlement_Name__c =>
            new ServiceCloudEntitlementData('CSE', 'CSE Business Hours', 'CSE- Turn Around Time'),
        Service_Cloud_Settings__mdt.Data_Inquiry_Entitlement_Record_Id__c =>
            new ServiceCloudEntitlementData('Data Request', 'Master Data Business Hours', 'Data Request'),
        Service_Cloud_Settings__mdt.Feedback_Entitlement_Record_Id__c =>
            new ServiceCloudEntitlementData('Feedback', 'Vet Customer Service Business Hours', 'Feedback'),
        Service_Cloud_Settings__mdt.Mkt_Comm_Sup_Entitlement_Record_Id__c =>
            new ServiceCloudEntitlementData('Marketing and Commerce Support', 'Vet Customer Service Business Hours', 'Marketing and Commerce Support'),
        Service_Cloud_Settings__mdt.Order_Inquiry_Entitlement_Record_Id__c =>
            new ServiceCloudEntitlementData('Order Status', 'SOM Business Hours', 'Order Status'),
        Service_Cloud_Settings__mdt.RefLabs_Entitlement_Record_Id__c =>
            new ServiceCloudEntitlementData('Reference Labs', 'Reference Labs Hours', 'Reference Labs Entitlement Process')
    };

    // Primarily for easier Unit Tests, Service Cloud Settings is stored in a class level variable
    @testVisible
    private Service_Cloud_Settings__mdt serviceCloudSettings;

    /**
     * This method executes after a Sandbox is created. It calls multiple helper methods to setup configuration and 
     * data needed in a sandbox post-refresh.
     * @param context 
     */
    global void runApexClass(SandboxContext context) {
        createRingLeadTriggerBatchSettings();

        serviceCloudSettings = retrieveServiceCloudSettings();
        Map<Schema.SObjectField, Id> newEntitlementIdsByServiceCloudSettingField = createMissingEntitlements();

        // Custom Metadata only needs to be upserted if new Entitlements were created.
        // To avoid a mixed DML error, it must be upserted asynchronously.
        // Additional metadata usperts may be added to this method if needed.
        if (!newEntitlementIdsByServiceCloudSettingField.isEmpty()) {
            System.enqueueJob(new UpdateCustomMetadata(newEntitlementIdsByServiceCloudSettingField));
        }
    }

    /**
     * Creates a Ring Lead Trigger Batch Settings record with a Size of 2000 if one does not already exist.
     * This method is marked public so it can be run individually if needed.
     */
    public void createRingLeadTriggerBatchSettings() {
        List<RingLeadTrigger__Batch_Settings__c> existingBatchSettings = [
            SELECT Id 
            FROM RingLeadTrigger__Batch_Settings__c
            WHERE RingLeadTrigger__Batch_Size__c != NULL
            LIMIT 1];

        if (!existingBatchSettings.isEmpty()) {
            return;
        }

        insert new RingLeadTrigger__Batch_Settings__c(
            RingLeadTrigger__Batch_Size__c = 2000
        );
    }

    /**
     * Determines if the Entitlement records on Service Cloud Settings exist or not. If they do not, this method
     * creates new Entitlement records and a new Account to go with them. The new Entitlement record ids are returned by
     * their corresponding Service Cloud Setting field so that it can be put in the field later.
     * This method is marked public so it can be run individually if needed.
     * @return  `Map<Schema.SObjectField, Id>`
     */
    public Map<Schema.SObjectField, Id> createMissingEntitlements() {
        // String is used as a key to handle invalid ids
        Map<String, Set<Schema.SObjectField>> fieldsByEntitlementId = new Map<String, Set<Schema.SObjectField>>();
        Set<Schema.SObjectField> missingFields = new Set<Schema.SObjectField>();
        for (Schema.SObjectField field : serviceCloudEntitlementDataByFields.keySet()) {
            String entitlementId = String.valueOf(serviceCloudSettings.get(field));
            if (String.isNotBlank(entitlementId)) {
                if (!fieldsByEntitlementId.containsKey(entitlementId)) {
                    fieldsByEntitlementId.put(entitlementId, new Set<Schema.SObjectField>());
                }
                fieldsByEntitlementId.get(entitlementId).add(field);
            }
            else {
                missingFields.add(field);
            }
        }

        // Determine if the Entitlements in the Service Cloud Settings exist. 
        // If they do, remove its corresponding field from the list so it is not recreated.
        for (Entitlement entitlement : [SELECT Id FROM Entitlement WHERE Id in: fieldsByEntitlementId.keySet()]) {
            fieldsByEntitlementId.remove(entitlement.Id);
        }

        for (String entitlementId : fieldsByEntitlementId.keySet()) {
            missingFields.addAll(fieldsByEntitlementId.get(entitlementId));
        }
        
        // All Entitlements exist, no new data has to be created.
        if (missingFields.isEmpty()) {
            return new Map<Schema.SObjectField, Id>();
        }

        Set<String> businessHourNames = new Set<String>();
        Set<String> processNames = new Set<String>();
        for (Schema.SObjectField field : missingFields) {
            businessHourNames.add(serviceCloudEntitlementDataByFields.get(field).businessHoursName);
            processNames.add(serviceCloudEntitlementDataByFields.get(field).entitlementProcessName);
        }

        Map<String, Id> businessHoursIdsByName = retrieveBusinessHoursIdsByName(businessHourNames);
        Map<String, Id> entitlementProcessIdsByName = retrieveEntitlementProcessIdsByName(processNames);

        // Setup a new Account for the Entitlements as this is a required field
        Account entitlementAccount = new Account(
            Name = 'Sandbox Entitlement Account DO NOT DELETE',
            ZTS_EU_Market__c = 'United States',
            BillingPostalCode = '07005',
            BillingCity = 'Parsippany',
            BillingState = 'NJ',
            BillingStreet = '555 Main St');
        insert entitlementAccount;

        // Setup missing Entitlement records using predefined settings.
        Map<String, Schema.SObjectField> entitlementFieldsByEntitlementName = new Map<String, Schema.SObjectField>();
        List<Entitlement> entitlements = new List<Entitlement>();
        for (Schema.SObjectField missingField : missingFields) {
            // Set the Name of the Entitlement using the field label and prefixing it with Name.
            // Remove the "Record Id" and "Name" part of the Label for a cleaner name.
            ServiceCloudEntitlementData entitlementData = serviceCloudEntitlementDataByFields.get(missingField);

            Entitlement entitlement = new Entitlement(
                Name = entitlementData.name, 
                AccountId = entitlementAccount.Id,
                Type = 'Phone Support',
                StartDate = System.today(),
                EndDate = Date.newInstance(2050, 1, 25),
                BusinessHoursId = businessHoursIdsByName.get(entitlementData.businessHoursName),
                SlaProcessId = entitlementProcessIdsByName.get(entitlementData.entitlementProcessName));

            entitlements.add(entitlement);
            entitlementFieldsByEntitlementName.put(entitlement.Name, missingField);
        }

        insert new List<Entitlement>(entitlements);

        // Build a map of Entitlement Id by Service Cloud Setting field so the Entitlement record can be put in that field.
        // To avoid a Mixed DML Exception, Metadata must be upserted in a Queueable.
        Map<Schema.SObjectField, Id> newEntitlementIdsByServiceCloudSettingField = new Map<Schema.SObjectField, Id>();
        for (Entitlement entitlement : entitlements) {
            newEntitlementIdsByServiceCloudSettingField.put(entitlementFieldsByEntitlementName.get(entitlement.Name), entitlement.Id);
        } 

        return newEntitlementIdsByServiceCloudSettingField;
    }

    /**
     * Retrieves the Default Service Cloud Setting.
     * This method primarily exits so Service Cloud Settings can be overwriten in a Unit Test
     * @return  `Service_Cloud_Settings__mdt`
     */
    private Service_Cloud_Settings__mdt retrieveServiceCloudSettings() {
        if (Test.isRunningTest() && serviceCloudSettings != null) {
            return serviceCloudSettings;
        }

        return Service_Cloud_Settings__mdt.getInstance('DEFAULT');
    }

    /**
     * Retrieve Business Hour Ids by Name. To keep this class isolated, a Selector is not used to retrieve this data.
     * @param businessHourNames 
     * @return  `Map<String, Id>`
     */
    private Map<String, Id> retrieveBusinessHoursIdsByName(Set<String> businessHourNames) {
        Map<String, Id> businessHourIdsByName = new Map<String, Id>();
        for (BusinessHours hours : [SELECT Id, Name FROM BusinessHours WHERE Name in: businessHourNames]) {
            businessHourIdsByName.put(hours.Name, hours.Id);
        }

        return businessHourIdsByName;
    }

    /**
     * Retrieve Entitlement Process Ids by Name. To keep this class isolated, a Selector is not used to retrieve this data.
     * @param processNames 
     * @return  `Map<String, Id>`
     */
    private Map<String, Id> retrieveEntitlementProcessIdsByName(Set<String> processNames) {
        Map<String, Id> entitlementProcessIdsByName = new Map<String, Id>();
        for (SlaProcess process : [SELECT Id, Name FROM SlaProcess WHERE Name in: processNames]) {
            entitlementProcessIdsByName.put(process.Name, process.Id);
        }

        return entitlementProcessIdsByName;
    }

    // Queuable Class for updating Custom Metadata. It's marked public so it can be run individually if needed.
    public class UpdateCustomMetadata implements Queueable {
        private Map<Schema.SObjectField, Id> newEntitlementIdsByServiceCloudSettingField;
        private Service_Cloud_Settings__mdt serviceCloudSettings;
        @testVisible
        private Metadata.DeployContainer mdContainerResult;
        
        public UpdateCustomMetadata(Map<Schema.SObjectField, Id> newEntitlementIdsByServiceCloudSettingField) {
            this.newEntitlementIdsByServiceCloudSettingField = newEntitlementIdsByServiceCloudSettingField;
        }
        
        /**
         * Main execute method. This calls methods for setting up Custom Metadata
         * @param context 
         */
        public void execute(QueueableContext context) {
            setupServiceCloudSettings();
        }

        /**
         * Updates Entitlement fields on Service Cloud Settings using the newEntitlementIdsByServiceCloudSettingField.
         * It's marked public so it can be run individually if needed
         */
        public void setupServiceCloudSettings() {
            Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
            customMetadata.fullName = 'Service_Cloud_Settings.DEFAULT';
            customMetadata.label = 'DEFAULT';

            for (Schema.SObjectField metadataField : newEntitlementIdsByServiceCloudSettingField.keySet()) {
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = metadataField.getDescribe().getName();
                customField.value = (String)newEntitlementIdsByServiceCloudSettingField.get(metadataField);
                customMetadata.values.add(customField);
            }

            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);

            // This code cannot run in a Unit Test
            if (!Test.isRunningTest()) {
                // Fire and forget. If the metadata fails to update it will need to be manually updated
                Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            }
            else {
                // In a Test, set the result in a class variable to confirm the results
                mdContainerResult = mdContainer;
            }
        }
    }

    // Helper class for storing setup information for Entitlement records.
    @testVisible
    private class ServiceCloudEntitlementData
    {
        public String name {get; private set;}
        public String businessHoursName {get; private set;}
        public String entitlementProcessName {get; private set;}

        public ServiceCloudEntitlementData(String name, String businessHoursName, String processName) {
            this.name = name;
            this.businessHoursName = businessHoursName;
            this.entitlementProcessName = processName;
        }
    }
}