/**
* File Name     :  CustomLookupController
* @description  :  Apex controller to implement the custom lookup functionality offered from https://github.com/pozil/sfdc-ui-lookup-lwc.  
Each implementation of this lookup should have its own search method in this file.
* @author       :  Cory Bartholomew @ ATG - Advanced Technology Group
 */

public class CustomLookupController {
    
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchAccountShipToAddresses(String searchTerm, String quoteId, List<String> selectedAddressIds) {
        // Prepare query paramters
        searchTerm += '*';
        System.debug('quoteId: ' + quoteId);
        System.debug('Selected Address Ids: ' + selectedAddressIds);
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c FROM SBQQ__Quote__c WHERE Id = :quoteId];
        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                Address__c( Id, Name, Account_Name__c, ZTS_US_Source_Account_Number__c, ZTS_EU_Account__r.Type, ZTS_Address_Line_1__c
                                    WHERE  ZTS_EU_Account__c != '' AND
                                    ZTS_EU_Account__r.Type != 'Distributor'
                                    AND (ZTS_US_Source_Account_Number__c LIKE '1%' 
                                    OR ZTS_US_Source_Account_Number__c LIKE '2%'
                                    )  
                                    AND ZTS_EU_Account__c = :quote.SBQQ__Account__c
                                    AND Id NOT IN :selectedAddressIds
                                    AND Length_of_Source_Account_Number__c = 10
                )
            LIMIT :MAX_RESULTS
        ];

        System.debug(searchResults);

        //ZTS_EU_Account__c = :quote.SBQQ__Account__c AND

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String addressIcon = 'custom:custom24';
        Address__c[] addresses = (List<Address__c>) searchResults[0];
        for (Address__c address : addresses) {
            results.add(
                new LookupSearchResult(
                    address.Id,
                    'Address__c',
                    addressIcon,
                    address.Name,
                    address.Account_Name__c                                      
                )
            );
        }
        for(LookupSearchResult result : results){
            system.debug(result);
        }
        return results;
    }
    
}