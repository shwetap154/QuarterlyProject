/**
 * @description       : Main Service class for ZTS_US_Contract_Doc_Id_search_string__c Custom Setting
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-16-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-16-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
**/
public with sharing class ZTSUSContractDocIdSearchStringService {
    /**
    * @description     Use to return ZTS_US_Contract_Doc_Id_search_string__c records in a Map by Identifier.
        A ZTS_US_Contract_Doc_Id_search_string__c can have multiple Identifiers specified using a semicolon delimited list
    * @author Ethan Hirsch @ Zoetis Inc | 03-16-2022 
    * @return Map<string, ZTS_US_Contract_Doc_Id_search_string__c> 
    **/
    public static Map<string, ZTS_US_Contract_Doc_Id_search_string__c> buildContractDocumentSearchStringByKeyMap() {
        List <ZTS_US_Contract_Doc_Id_search_string__c> contractSearchStrings = ZTS_US_Contract_Doc_Id_search_string__c.getall().values();
        Map<string, ZTS_US_Contract_Doc_Id_search_string__c> contractSearchStringByKey = new  Map<string, ZTS_US_Contract_Doc_Id_search_string__c>();

        for (ZTS_US_Contract_Doc_Id_search_string__c contractSearchString : contractSearchStrings) {
            // If Contract_Attachment_Identifier__c is blank, the key will be blank too
            List<string> identifiers = string.isNotEmpty(contractSearchString.Contract_Attachment_Identifier__c)
                ? contractSearchString.Contract_Attachment_Identifier__c.split(';')
                : new List<String> {contractSearchString.Contract_Attachment_Identifier__c};
            
            for (string identifier : identifiers) {
                contractSearchStringByKey.put(identifier, contractSearchString);
            }
        }

        return contractSearchStringByKey;
    }
}