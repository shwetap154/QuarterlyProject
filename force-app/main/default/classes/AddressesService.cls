/**
 * @description       : Service class for Address
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with isActiveDirectShipToAddress method
 * 1.1   04-13-2022   Ethan Hirsch @ Zoetis Inc   Update unblockRelatedRefLabOnboardingCases to work with new Addresses
 * 1.2   05-25-2022   Ethan Hirsch @ Zoetis Inc   Add mergeRelatedAddressesByAddressTypeAndDetails to merge duplicate Addresses. 
 *                                                Primarly for INTL Accounts.
 * 1.3   06-02-2022   Ethan Hirsch @ Zoetis Inc   Update mergeRelatedAddressesByAddressTypeAndDetails method to use helper method for generating unique keys to reduce duplicated patterns
 * 1.4   06-27-2022   Ethan Hirsch @ Zoetis Inc   Add logic to mergeRelatedAddressesByAddressTypeAndDetails to keep duplicate Addresses with different Address IDs.
 *                                                Use ZTS_EU_Address_ID__c instead of ZTS_US_Source_Account_Number__c and Name instead of ZTS_Address_Line_1__c for merges.
 * 1.5   07-11-2022   Ethan Hirsch @ Zoetis Inc   Update matching logic to take into account both Address Id and Source Account Number
 *                                                to account for edge cases and avoid merging different Addresses.
 *                                                Update merge logic to pass along additional details for a Child Relationship
 * 1.6   09-08-2022   Ethan Hirsch @ Zoetis Inc   Change mergeRelatedAddressesByAddressTypeAndDetails to keep the newest
 *                                                Address instead of the oldest as the last prioritization logic. 
 *                                                Business has requested this as the newest Address is likely more accurate.
 * 1.7   09-09-2022   Ethan Hirsch @ Zoetis Inc   Add logic to mergeRelatedAddressesByAddressTypeAndDetails to keep the
 *                                                Main Phone of a duplicate Account to avoid data loss.
 * 1.8   09-15-2022   Ethan Hirsch @ Zoetis Inc   Make the Address merge logic case insensitive to better compare Addresses.
 * 1.9   09-19-2022   Ethan Hirsch @ Zoetis Inc   Change the logic of mergeRelatedAddressesByAddressTypeAndDetails to change how relationships are processed
 **/
public with sharing class AddressesService {
    private static List<String> shipToAddresses;

    static {
        shipToAddresses = new List<String> {'ship to', 'shipping', 'ship address', 'bill/ship address'};
    }

    /**
    * @description Returns true if an Address is an Active, Direct, Ship To Address.
    *   For flexibility reasons, this method does not check if an Account or Contact is present.
    * @author Ethan Hirsch @ Zoetis Inc | 04-11-2022 
    * @param address 
    * @return Boolean 
    **/
    public static Boolean isActiveDirectShipToAddress(Address__c address) {
        // Perform a Case inseensitive compare of Address Type to Ship To values to be cautious.
        return shipToAddresses.contains(address.ZTS_EU_Address_Type__c?.toLowerCase()) &&
            address.Is_Active__c &&
            address.Ship_Indirect__c != 'Y';
    }

    /**
    * @description When a Case is marked Reference Labs Ship To (Reference_Labs_Ship_to__c is set to true)
    *              update the Reference Lab Onboarding Cases related to the Address' Account to not have a Status of On Hold
    * @author Ethan Hirsch @ Zoetis Inc | 04-11-2022 
    * @param addresses 
    * @param oldAddressMap 
    **/
    public static void unblockRelatedRefLabOnboardingCases(List<Address__c> addresses, Map<Id, Address__c> oldAddressMap) {
        Set<Id> unblockCaseAccountIds = new Set<Id>();
        for (Address__c address : addresses) {
            Address__c oldAddress = oldAddressMap?.get(address.Id);
            // Only process Address that are Active, Direct Ship Tos, have Reference_Labs_Ship_to__c set to true,
            // are related to an Account, and if this is not running on insert (oldAddress is null) had one field change to make the previous conditions true.
            if (isActiveDirectShipToAddress(address) &&
                address.Reference_Labs_Ship_to__c &&
                address.ZTS_EU_Account__c != null &&
                (oldAddress == null || 
                address.ZTS_EU_Address_Type__c != oldAddress.ZTS_EU_Address_Type__c ||
                address.Is_Active__c != oldAddress.Is_Active__c ||
                address.Ship_Indirect__c != oldAddress.Ship_Indirect__c ||
                address.Reference_Labs_Ship_to__c != oldAddress.Reference_Labs_Ship_to__c ||
                address.ZTS_EU_Account__c != oldAddress.ZTS_EU_Account__c)) {
                unblockCaseAccountIds.add(address.ZTS_EU_Account__c);
            }
        }


        if (!unblockCaseAccountIds.isEmpty()) {
            CaseService.unblockRelatedRefLabOnboardingCases(unblockCaseAccountIds);
        }
    }

    @testVisible
    private static Id overwriteMergePrimaryAddressKeyId;

    /**
    * @description This method processes Addresses related to an Account after a merge to delete any duplicates.
    *              A duplicate Address is determined by looking for Addresses with the same Type and details (e.g. Street, City, Postal Code)
    *              Any child records of a deleted Address are transfered to the matching record to avoid them being lost.
    *              The child records are determined using the childObjectsToMerge Collection.
    *              This method also updated the unique key of an Address, ZTS_GL_Unique_Primary_Address_Key__c.
    *              This field is normally updated in triggers and Workflow Rules, but they do not run on merge.
    *              It is updated here to prevent duplicates or other issues in the future
    * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
    * @param accountIds 
    * @param childObjectsToMergeMap 
    * @param updateRelatedRecordsMap 
    * @return Map<Id, Address__c> 
    **/
    public static Map<Id, Address__c> mergeRelatedAddressesByAddressTypeAndDetails(Set<Id> accountIds, 
        Map<String, MergeRelatedRecordLookupsSelector.ChildObject> childObjectsToMergeMap,
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        Map<String, List<Address__c>> addressesByUniqueKey = new Map<String, List<Address__c>>();
        Map<String, Address__c> keepAddressByUniqueKey = new Map<String, Address__c>();
        List<Address__c> deleteAddresses = new List<Address__c>();

        List<MergeService.MergeChildRelationship> childRelationships = MergeService.getChildRelationshipsForObjects(
            childObjectsToMergeMap, Address__c.getSObjectType());

        // Build a blank Integration Id to check if both Ids are blank
        String blankIntegrationId = buildMergeAddressIntegrationId(new Address__c());
        
        Map<Id, MergeService.RecordAndRelationships> recordsAndRelationshipsMap = 
            AddressesSelector.newInstance().selectByAccountIdWithRelatedData(accountIds, childRelationships);

        for (Id addressId : recordsAndRelationshipsMap.keySet()) {
            Address__c address = (Address__c)recordsAndRelationshipsMap.get(addressId).record;

            // The unique Key contains the Account Id to allow duplicate addresses to exists across Accounts
            string uniqueKey = buildMergeAddressUniqueKey(address);
            if (!addressesByUniqueKey.containsKey(uniqueKey)) {
                addressesByUniqueKey.put(uniqueKey, new List<Address__c>());
            }

            if (!keepAddressByUniqueKey.containsKey(uniqueKey)) {
                keepAddressByUniqueKey.put(uniqueKey, address);
                addressesByUniqueKey.get(uniqueKey).add(address);
                continue;
            }
            
            Address__c matchingAddress = keepAddressByUniqueKey.get(uniqueKey);

            // Use both Address Id and Source Account Number as an Integration Id
            // Though most Addresses will have Address Id populated, some will only have Source Account Number populated
            // Or the Source Account Number will not be in the Address Id.
            // To avoid any issues, both Address Ids are used for duplicate checks
            String addressIntegrationId = buildMergeAddressIntegrationId(address);

            String matchingAddressIntegrationId = buildMergeAddressIntegrationId(matchingAddress);

            Boolean bothAddressesHaveOrDontHaveIntegrationIds = 
                (addressIntegrationId == blankIntegrationId &&
                matchingAddressIntegrationId == blankIntegrationId) ||
                (addressIntegrationId != blankIntegrationId &&
                matchingAddressIntegrationId != blankIntegrationId);

            // Deduplication logic. 
            // First keep the Address with a Address ID or Source Account Number. This is set by an integration and will be recreated if deleted.
            // Second, if both Address have a Address ID and/or Source Account Number, but have different values, keep both Addresses
            // If it can't be prioritized by an integration id, keep the newest Address.
            if (addressIntegrationId != blankIntegrationId &&
                matchingAddressIntegrationId == blankIntegrationId) {
                keepAddressByUniqueKey.put(uniqueKey, address);
            }
            // If both Integration Ids are not blank, perform a case-sensitive comparison so that only exact matches are treated as duplicates.
            else if (addressIntegrationId != blankIntegrationId && matchingAddressIntegrationId != blankIntegrationId &&
                addressIntegrationId?.equals(matchingAddressIntegrationId) == false) {

                // If the address have matching details, but different Address IDs, treat this Address as unique.
                // This logic still handles another Address with the same Address ID existing on the Account
                string updatedUniqueKey = String.format('{0}{1}', new List<String> {addressIntegrationId, uniqueKey});

                // Keep the first Address with these details and Address ID.
                if (!keepAddressByUniqueKey.containsKey(updatedUniqueKey)) {
                    keepAddressByUniqueKey.put(updatedUniqueKey, address);
                }

                // Add the Address to the map to process deletions if necessary.
                if (!addressesByUniqueKey.containsKey(updatedUniqueKey)) {
                    addressesByUniqueKey.put(updatedUniqueKey, new List<Address__c>());
                }

                addressesByUniqueKey.get(updatedUniqueKey).add(address);

                continue;
            }
            // Both Addresses must have a Source Number or no Source Number to move to the next prioritization logic.
            // This avoids deleting an Address with a Source Account Number.
            else if (bothAddressesHaveOrDontHaveIntegrationIds &&
                address.CreatedDate > matchingAddress.CreatedDate) {
                keepAddressByUniqueKey.put(uniqueKey, address);
            }

            // Add the Address to the full map only after determining if it's a duplicate or not.
            // This allows for an Address to not be treated as a duplicate
            addressesByUniqueKey.get(uniqueKey).add(address);

            // Copy the Phone Number from the Address being deleted to the Address being Kept if the Addess being Kept 
            // does not have a Phone Number.
            if (keepAddressByUniqueKey.get(uniqueKey) == address) {
                copyPhoneFromDuplicateAddressToKeepAddress(address, matchingAddress, updateRelatedRecordsMap);
            }
            else {
                copyPhoneFromDuplicateAddressToKeepAddress(matchingAddress, address, updateRelatedRecordsMap);
            }
        }

        // Pull the field name from schema to create a reference to the field in code
        string uniquePrimaryAddressKeyFieldName = Address__c.ZTS_GL_Unique_Primary_Address_Key__c.getDescribe().getName();
        for (String uniqueKey : addressesByUniqueKey.keySet()) {
            MergeService.DeleteRecordsAndKeepRecord deleteRecordsAndKeepRecord = MergeService.setLookupFieldsAndDeleteRecords(
                uniqueKey, keepAddressByUniqueKey, addressesByUniqueKey, childRelationships, recordsAndRelationshipsMap,
                updateRelatedRecordsMap);

            Address__c keepAddress = (Address__c)deleteRecordsAndKeepRecord.keepRecord;
            deleteAddresses.addAll((List<Address__c>)deleteRecordsAndKeepRecord.deleteRecords);


            // For Unit Tests to run this logic outside a merge, allow ZTS_GL_Unique_Primary_Address_Key__c to be overwritten.
            // ZTS_GL_Unique_Primary_Address_Key__c is set in a Workflow Rule and can't be avoided in a Unit Test.
            if (Test.isRunningTest() && overwriteMergePrimaryAddressKeyId == keepAddress.Id) {
                keepAddress.ZTS_GL_Unique_Primary_Address_Key__c = 'INCORRECT';
            }

            // Update ZTS_GL_Unique_Primary_Address_Key__c if it's not blank and inaccurate.
            // This is supposed to be set to the Account Id and true in Workflow Rule 
            // ZTS_GL_Address_Update_Address_When_it_is_Primary
            MergeService.setUniqueKeyField(keepAddress, uniquePrimaryAddressKeyFieldName,
                String.format('{0}True', new List<Object> {keepAddress.ZTS_EU_Account__c}),
                keepAddress.ZTS_EU_Account__c, updateRelatedRecordsMap);
        }

        return new Map<Id, Address__c>(deleteAddresses);
    }

    /**
    * @description Copies the Phone from the duplicate Address to the Address that will not be deleted.
    *              This is used by the merge process.
    * @author Ethan Hirsch @ Zoetis Inc | 09-09-2022 
    * @param keepAddress 
    * @param duplicateAddress 
    * @param updateRelatedRecordsMap 
    **/
    private static void copyPhoneFromDuplicateAddressToKeepAddress(Address__c keepAddress, Address__c duplicateAddress,
        MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
        // If Address already has a Phone or the duplicate Address does not have a Phone, exit early
        if (String.isNotBlank(keepAddress.ZTS_EU_Phone__c) || String.isBlank(duplicateAddress.ZTS_EU_Phone__c)) {
            return;
        }

        // Set phone on the Address object directly to prevent it from going through this logic multiple times
        keepAddress.ZTS_EU_Phone__c = duplicateAddress.ZTS_EU_Phone__c;

        updateRelatedRecordsMap.setFieldValue(keepAddress.getSObjectType(), 'ZTS_EU_Phone__c',
            duplicateAddress.ZTS_EU_Phone__c, keepAddress.Id);
    }

    /**
    * @description Concatenate Address fields together to identify duplicates. 
    * Perform a toLowerCase so the comparison is case-insensitive
    * @author Ethan Hirsch @ Zoetis Inc | 06-28-2022 
    * @param address 
    * @return String 
    **/
    private static String buildMergeAddressUniqueKey(Address__c address) {
        return String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}{12}', 
            new List<Object>{address.Name, address.ZTS_EU_Address_Line_2__c,
                address.ZTS_EU_Address_Line_3__c, address.Address_Line_4__c, address.ZTS_EU_Country__c,
                address.ZTS_EU_State_County__c, address.ZTS_EU_Commune_Lookup__c, address.ZTS_EU_District__c,
                address.ZTS_EU_City__c, address.ZTS_EU_City_Country__c, address.Zip_Postal_Code__c,
                address.ZTS_EU_Address_Type__c, address.ZTS_EU_Account__c}).toLowerCase();
    }

    /**
    * @description Concatenate Address Integration fields together to identify duplicates
    * @author Ethan Hirsch @ Zoetis Inc | 07-11-2022 
    * @param address 
    * @return String 
    **/
    private static String buildMergeAddressIntegrationId(Address__c address) {
        return String.format('AddressId:{0} Source Account Number:{1}', 
                new List<String>{address.ZTS_EU_Address_ID__c, address.ZTS_US_Source_Account_Number__c});
    }
}