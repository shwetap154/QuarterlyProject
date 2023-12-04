/**
 * @description       : Main Service Class for Attachments
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-17-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   03-16-2022   Ethan Hirsch @ Zoetis Inc      Initial Version
 * 1.1   03-17-2022   Ethan Hirsch @ Zoetis Inc      Additional additional comments.
 *                                                   Use AccountSelector.newInstance() to initialize AccountSelector.
 * 1.2   01-05-2023   Padma Nerella @ Zoetis Inc     Bypass the Account Trigger when updating Accounts (TPDEV-80)
 **/
public with sharing class AttachmentService {
    /**
    * @description     Sets Text fields that store Attachment Ids on Accounts.
        For RSA Attachments, name Contains _RSA_, the Account will also have RSA_Active__c set to true.
        The ZTS_US_Contract_Doc_Id_search_string__c Custom Setting is used keep track of:
            1. The text identifier use to identify the type of Attachments. 
                If the Attachment Name contains this string, the Account will be updated using this record.
            2. The field on Account to update. This is a text field that will be set to the Attachment Id
    * @author Ethan Hirsch @ Zoetis Inc | 03-16-2022 
    * @param attachments 
    * @param parentIds 
    **/
    public static void setAttachmentIdFieldsOnAccount(List<Attachment> attachments, List<Id> parentIds) {
        Map<Id, Account> parentAccountMap = new Map<Id, Account>(
            AccountSelector.newInstance().selectByIdAndMarket(parentIds, true));
        
        if (parentAccountMap.isEmpty()) {
            return;
        }
        
        Map<string, ZTS_US_Contract_Doc_Id_search_string__c> contractSearchStringByKey = 
            ZTSUSContractDocIdSearchStringService.buildContractDocumentSearchStringByKeyMap();

        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (Attachment attachment: attachments) {
            if (parentAccountMap.containsKey(attachment.ParentId) == false) {
                continue;
            }

            for (string identifier : contractSearchStringByKey.keyset()) {
                if(string.isNotBlank(identifier) && attachment.Name.containsIgnoreCase(identifier)) {
                    ZTS_US_Contract_Doc_Id_search_string__c contractSearchString = contractSearchStringByKey.get(identifier);

                    Account account = accountsToUpdate.containsKey(attachment.ParentId)
                        ? accountsToUpdate.get(attachment.ParentId)
                        : new Account(Id = attachment.ParentId);
                    
                    account.put(contractSearchString.Contract_Field_Name__c, attachment.Id);

                    //Added this part to update RSA Active flag based on RSA Document (SC-005631)
                    if(attachment.Name.containsIgnoreCase('_RSA_')) {
                        account.RSA_Active__c = true;
                    }

                    accountsToUpdate.put(account.Id, account);
                    // Exit looping through the Contract Search String Custom Setting once a match is found and processed.
                    // Move onto the next Attachment record.
                    break;
                }
            }
        }

        if (accountsToUpdate.size () > 0) {
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update accountsToUpdate.values();
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
}