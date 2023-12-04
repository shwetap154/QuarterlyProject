/******************************************************************************************************************************************
* Class Name   : USAccountTriggerService
* Description  : Logic for all US Account triggers housed here.
* Created By   : Slalom/David Stern
* Created Date : 06 February 2020
*
* Modification Log:
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------/
* David Stern(Slalom)     02/06/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
 
public without sharing class USAccountTriggerService
{
    @testVisible static final String ACCOUNT_ERROR_LOG_ORIGIN_TYPE = 'USAccountTriggerService - USStatusAndFieldUpdates: update accounts';
    @testVisible static final String RELATED_ERROR_LOG_ORIGIN_TYPE = 'USAccountTriggerService - USStatusAndFieldUpdates: update affiliations, contacts, account positions';
    @testVisible private static Boolean mockException = false;

    public static void beforeInsert(List<Account> triggerNew)
    {
        for (Account acct : triggerNew) {
            if (acct.Phone != null) {
                acct.Phone = UtilityService.getE164FormattedPhoneNumber(acct.Phone,'1',10,'US');
            }
        }
        USSL_AccountTriggerHandler objHandler = new USSL_AccountTriggerHandler();
        //Only Process US records if there are such
        if (!triggerNew.isEmpty()) objHandler.onBeforeInsert(triggerNew);
        USStatusAndFieldUpdatesForAccountOnly(null, null, triggerNew, null);
       
    }

    public static void beforeUpdate(List<Account> triggerOld, Map<Id, Account> triggerOldMap, List<Account> triggerNew, Map<Id, Account> triggerNewMap)
    {
        populateLISOrgCode(triggerNew);
        for (Account acct : triggerNew) {
            if (acct.Phone != null && acct.Phone != triggerOldMap.get(acct.Id).Phone) {
                acct.Phone = UtilityService.getE164FormattedPhoneNumber(acct.Phone,'1',10,'US');
            }
        }
        USSL_AccountTriggerHandler objHandler = new USSL_AccountTriggerHandler();
        //Only Process US records if there are such
        if (!triggerNew.isEmpty() && !triggerOldMap.isEmpty()) objHandler.onBeforeUpdate(triggerNew, triggerOldMap);
        USStatusAndFieldUpdatesForAccountOnly(triggerOld, triggerOldMap, triggerNew, triggerNewMap);
       
    }
    
    public static void populateLISOrgCode(List<Account> triggerNew){
        Set<Id> accountIdSet = new Set<Id>();

        for ( Account acc : triggerNew ) {
            if ( String.isBlank( acc.LIS_Org_Code__c ) && acc.Reference_Lab_Customer__c ) {
                accountIdSet.add(acc.Id);
            }
        }

        Map<Id,Account> mapAccountToAddress = getAccountShipToAddresses( accountIdSet );

        for ( Account acc : triggerNew ) {
            if ( mapAccountToAddress.ContainsKey( acc.Id ) && !mapAccountToAddress.get( acc.Id ).Addresses__r.isEmpty() ) {
                acc.LIS_Org_Code__c = mapAccountToAddress.get(acc.Id).Addresses__r[0].LIS_Number__c;
            }
        }
    }

     //Method to get existing Ship To address on Account
     public static Map<Id,Account> getAccountShipToAddresses ( Set<Id> accountIdSet ) {

        return new Map<Id,Account>
        (   [   SELECT  Id,
                    (   SELECT  Id, ZTS_US_Source_Account_Number__c, Reference_Labs_Ship_to__c, LIS_Number__c
                        FROM    Addresses__r
                        WHERE   (   ZTS_EU_Address_Type__c IN (  'Ship To', 'Shipping', 'Ship Address', 'Bill/Ship Address' )
                                AND Is_Active__c = true
                                AND Ship_Indirect__c != 'Y'
                                AND LIS_Number__c != null
                                )
                        ORDER BY Reference_Labs_Ship_to__c DESC
                    )
                FROM    Account 
                WHERE   Id IN :accountIdSet
            ]
        );
    } 

    public static void sendReportingContactsToLIS( List<Account> triggerNew, Map<Id, Account> triggerOldMap ) {

        Set<Id> updatedAccountsSet = new Set<Id>();
        for( Account updatedAccount : triggerNew ){
            if( String.isNotBlank( updatedAccount.LIS_Org_Code__c ) && updatedAccount.LIS_Org_Code__c != triggerOldMap.get( updatedAccount.Id ).LIS_Org_Code__c ) {
                updatedAccountsSet.add( updatedAccount.Id );
            }
        }

        List<Contact> relatedReportingContacts =
        [   SELECT  Id, Send_To_LIS__c
            FROM    Contact
            WHERE   (   AccountId IN :updatedAccountsSet
                    AND Reference_Lab_Contact__c = true
                    AND Send_To_LIS__c = false  
                    )                  
        ];

        if( relatedReportingContacts.isEmpty() ) return;

        for( Contact reportingContact : relatedReportingContacts ) {
            reportingContact.Send_To_LIS__c = true;
        }
		// Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 		Database.DMLOptions dml = new Database.DMLOptions(); 
 		dml.DuplicateRuleHeader.allowSave = true;
 		dml.DuplicateRuleHeader.runAsCurrentUser = true;
 		List<Database.SaveResult> sr = Database.update(relatedReportingContacts,dml);
        //update relatedReportingContacts;-- commented for SC-008149

    }

    public static void beforeDelete(List<Account> triggerOld, Map<Id, Account> triggerOldMap) 
    {
        USSL_AccountTriggerHandler objHandler = new USSL_AccountTriggerHandler();
        objHandler.onBeforeDelete(triggerOld);
    }

    public static void afterInsert(List<Account> triggerNew, Map<Id, Account> triggerNewMap)
    {
        USSL_AccountTriggerHandler objHandler = new USSL_AccountTriggerHandler();
        // create Address record on creation of accountRecord.
        ZTS_US_addrCreationAndUpdateFromAccount.createAddressRecord(triggerNew);
        // creation of Animal Count and FTE records based on Business Class value on Account Creation.
        ZTS_US_addrCreationAndUpdateFromAccount.createAnimalCountFTE(triggerNew);
        // Filling Contract Details for an account
        if(ZTS_US_checkTriggerRun.runOnce())
        ZTS_US_addrCreationAndUpdateFromAccount.updateAccountContractDetails(triggerNew);
        //Added by Shah Shah DEF-001244 create AccountTeam Records
        ZTS_createAccountTeams.AccountTeamCreation(triggerNew);
       
        if(!System.isFuture() && !System.isBatch()) {
            String triggerNewJSON = JSON.serialize(triggerNew);
            USStatusAndFieldUpdatesRelatedObjects(null, null, triggerNewJSON, null);
        }
        // Passing empty map because Old Map does not exist in after insert.
        //FAUtils.sFFACustomerSync(triggerNew, new Map<Id, Account>(), triggerNewMap, true, false);
    }

    public static void afterUpdate(List<Account> triggerOld, Map<Id, Account> triggerOldMap, List<Account> triggerNew, Map<Id, Account> triggerNewMap)
    {
        sendReportingContactsToLIS( triggerNew, triggerOldMap );
        USSL_AccountTriggerHandler objHandler = new USSL_AccountTriggerHandler();
        objHandler.onAfterUpdate(triggerNew, triggerOldMap, triggerNewMap);
       
        if(!System.isFuture() && !System.isBatch()) {
            String triggerOldJSON = JSON.serialize(triggerOld);
            String triggerOldMapJSON = JSON.serialize(triggerOldMap);
            String triggerNewJSON = JSON.serialize(triggerNew);
            String triggerNewMapJSON = JSON.serialize(triggerNewMap);
            USStatusAndFieldUpdatesRelatedObjects(triggerOldJSON, triggerOldMapJSON, triggerNewJSON, triggerNewMapJSON);
        }
       
        //FAUtils.sFFACustomerSync(triggerNew, triggerOldMap, triggerNewMap, false, true);
    }

    public static void afterDelete(List<Account> triggerOld, Map<Id, Account> triggerOldMap)
    {
        USSL_AccountTriggerHandler objHandler = new USSL_AccountTriggerHandler();
        objHandler.onAfterDelete(Trigger.Old);
    }
   
    @future
    static void USStatusAndFieldUpdatesRelatedObjects(String triggerOldJSON, String triggerOldMapJSON, String triggerNewJSON, String triggerNewMapJSON)
    {
        List<Account> triggerOld = triggerOldJSON == null ? null : (List<Account>)JSON.deserialize(triggerOldJSON, List<Account>.class);
        Map<Id, Account> triggerOldMap = triggerOldMapJSON == null ? null : (Map<Id, Account>)JSON.deserialize(triggerOldMapJSON, Map<Id, Account>.class);
        List<Account> triggerNew = triggerNewJSON == null ? null : (List<Account>)JSON.deserialize(triggerNewJSON, List<Account>.class);
        Map<Id, Account> triggerNewMap = triggerNewMapJSON == null ? null : (Map<Id, Account>)JSON.deserialize(triggerNewMapJSON, Map<Id, Account>.class);
       
       
        List<ZTS_EU_Affiliations__c> affiliationsFromAccounts = [
        SELECT Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c
        FROM ZTS_EU_Affiliations__c
        WHERE ZTS_EU_Account__c IN :triggerNew
        ];
       
        Map<Id, List<ZTS_EU_Affiliations__c>> accountIdToAffiliation = new Map<Id, List<ZTS_EU_Affiliations__c>>();
        for (ZTS_EU_Affiliations__c affiliation : affiliationsFromAccounts)
        {
            if (accountIdToAffiliation.get(affiliation.ZTS_EU_Account__c) == null)
            {
                accountIdToAffiliation.put(affiliation.ZTS_EU_Account__c, new List<ZTS_EU_Affiliations__c>{affiliation});
            }
            else
            {
                List<ZTS_EU_Affiliations__c> currentList = accountIdToAffiliation.get(affiliation.ZTS_EU_Account__c);
                currentList.add(affiliation);
                accountIdToAffiliation.put(affiliation.ZTS_EU_Account__c, currentList);
            }
        }
       
        List<Contact> contactsFromAccounts = [
                    SELECT Id, MZR_Contact__c, AccountId
                    FROM Contact
                    WHERE AccountId IN :triggerNew
                    ];
       
        Map<Id, List<Contact>> accountIdToContacts = new Map<Id, List<Contact>>();
        for (Contact contact : contactsFromAccounts)
        {
            if (accountIdToContacts.get(contact.AccountId) == null)
            {
                accountIdToContacts.put(contact.AccountId, new List<Contact>{contact});
            }
            else
            {
                List<Contact> currentList = accountIdToContacts.get(contact.AccountId);
                currentList.add(contact);
                accountIdToContacts.put(contact.AccountId, currentList);
            }
        }
       
        List<ZTS_EU_Account_Position__c> accountPositionsFromAccounts = [
            SELECT Id, MZR_Program_Owner__c, ZTS_EU_Account__c
            FROM ZTS_EU_Account_Position__c
            WHERE ZTS_EU_Account__c IN :triggerNew
        ];
       
        Map<Id, List<ZTS_EU_Account_Position__c>> accountIdToAccountPositions = new Map<Id, List<ZTS_EU_Account_Position__c>>();
        for (ZTS_EU_Account_Position__c accountPosition : accountPositionsFromAccounts)
        {
            if (accountIdToAccountPositions.get(accountPosition.ZTS_EU_Account__c) == null)
            {
                accountIdToAccountPositions.put(accountPosition.ZTS_EU_Account__c, new List<ZTS_EU_Account_Position__c>{accountPosition});
            }
            else
            {
                List<ZTS_EU_Account_Position__c> currentList = accountIdToAccountPositions.get(accountPosition.ZTS_EU_Account__c);
                currentList.add(accountPosition);
                accountIdToAccountPositions.put(accountPosition.ZTS_EU_Account__c, currentList);
            }
        }
        /* changed the logic of this future method for SC-008697
         * New Logic: The method will check if the mentioned fields on account is updated, then only it will add the associated records in the list
         * Old Logic: after creating accountid-to-Affiliated records map, irrespective of any update or not, all affiliated records were updated
         */
        List<SObject> affiliationRecordsToUpdated = new List<SObject>();
		List<SObject> contactsRecordsToUpdated = new List<SObject>();
		List<SObject> accountPositionsRecordsToUpdated = new List<SObject>();
        for (Account accountRecord : triggerNew)
        {
            if((accountRecord.ZTS_EU_Account_Status__c == 'Inactive')
            && ((triggerOld == null) || (triggerOld != null && (triggerOldMap.get(accountRecord.Id).ZTS_EU_Market__c != triggerNewMap.get(accountRecord.Id).ZTS_EU_Market__c))))
            {
                if (accountIdToAffiliation.get(accountRecord.Id) != null)
                {
                    for (ZTS_EU_Affiliations__c affiliation : accountIdToAffiliation.get(accountRecord.Id))
                    {
                        affiliation.ZTS_EU_Affiliation_Status__c = 'Inactive';
                        affiliationRecordsToUpdated.add(affiliation); //Added this line for SC-008697
                    }
                   
                }
               
            }
           
            if ((accountRecord.MZR_Account__c == false)
            && ((triggerOld == null) || (triggerOld != null && (triggerOldMap.get(accountRecord.Id).MZR_Account__c != triggerNewMap.get(accountRecord.Id).MZR_Account__c))))
            {
                if (accountIdToContacts.get(accountRecord.Id) != null)
                {
                    for (Contact contact : accountIdToContacts.get(accountRecord.Id))
                    {
                        contact.MZR_Contact__c = null;
                        contactsRecordsToUpdated.add(contact); //Added this line for SC-008697
                    }
                }
               
                if (accountIdToAccountPositions.get(accountRecord.Id) != null)
                {
                    for (ZTS_EU_Account_Position__c accountPosition : accountIdToAccountPositions.get(accountRecord.Id))
                    {
                        accountPosition.MZR_Program_Owner__c = null;
                        accountPositionsRecordsToUpdated.add(accountPosition); //Added this line for SC-008697
                    }
                }
            }
           
        }
        try{
            if(mockException){
                throw new DMLException();
            }
			if(accountIdToAffiliation.values().size()>0) {
			update affiliationRecordsToUpdated;
			}
			if(accountIdToContacts.values().size()>0) {
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 			Database.DMLOptions dml = new Database.DMLOptions(); 
		    dml.DuplicateRuleHeader.allowSave = true;
 			dml.DuplicateRuleHeader.runAsCurrentUser = true;
			List<Database.SaveResult> sr = Database.update(contactsRecordsToUpdated,dml);    
			//update contactsRecordsToUpdated;-- commented for SC-008149
			}
			if(accountIdToAccountPositions.values().size()>0) {
			update accountPositionsRecordsToUpdated;
		}  
}
            catch(DmlException dex) {
                String errorMessages = '';
                Integer dmlCount = mockException ? 1 : dex.getNumDml();
                String dmlMessage;
                for (Integer i = 0; i < dmlCount; i++) {
                    if(mockException) dmlMessage = 'Mock Exception';
                    else dmlMessage = dex.getDmlMessage(i) + '\n';
                    errorMessages += dmlMessage;
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, RELATED_ERROR_LOG_ORIGIN_TYPE);
            }
     
       
    }
   
    static void USStatusAndFieldUpdatesForAccountOnly(List<Account> triggerOld, Map<Id, Account> triggerOldMap, List<Account> triggerNew, Map<Id, Account> triggerNewMap) {
       
        for (Account accountRecord : triggerNew)
        {
           
            if ((accountRecord.MZR_Account__c == false)
            && ((triggerOld == null) || (triggerOld != null && (triggerOldMap.get(accountRecord.Id).MZR_Account__c != triggerNewMap.get(accountRecord.Id).MZR_Account__c))))
            {
                accountRecord.MZR_Accepted_Declined_Date__c = null;
                accountRecord.MZR_End_Date__c = null;
                accountRecord.MZR_Enrollment_Date__c = null;
                accountRecord.MZR_Enrollment_Start_Date__c = null;
                accountRecord.MZR_Program_Owner__c = null;
                accountRecord.MZR_Program_Owner_email__c = null;
                accountRecord.MZR_Status__c = null;
                accountRecord.MZR_Tier__c = null;
            }
           
            if (triggerOld != null && (triggerOldMap.get(accountRecord.Id).LE_Program_Owner__c != triggerNewMap.get(accountRecord.Id).LE_Program_Owner__c))
            {
                accountRecord.Previous_LE_Program_Owner__c = triggerOldMap.get(accountRecord.Id).LE_Program_Owner__c;
            }
           
            if (triggerOld != null && (triggerOldMap.get(accountRecord.Id).MZR_Program_Owner__c != triggerNewMap.get(accountRecord.Id).MZR_Program_Owner__c))
            {
                accountRecord.Previous_MZR_Program_Owner__c = triggerOldMap.get(accountRecord.Id).MZR_Program_Owner__c;
            }
           
            if (triggerOld != null && (triggerOldMap.get(accountRecord.Id).VGP_Program_Owner__c != triggerNewMap.get(accountRecord.Id).VGP_Program_Owner__c))
            {
                accountRecord.Previous_VGP_Program_Owner__c = triggerOldMap.get(accountRecord.Id).VGP_Program_Owner__c;
            }
           
            if ((accountRecord.ZFS_Status__c == 'Member')
            && (accountRecord.MZR_Status__c == 'Eligible')
            && ((triggerOld == null) || (triggerOld != null && (triggerOldMap.get(accountRecord.Id).ZFS_Status__c != triggerNewMap.get(accountRecord.Id).ZFS_Status__c))))
            {
                accountRecord.MZR_Status__c = 'Not Eligible';
                accountRecord.MZR_Tier__c = null;
            }
           
            if (accountRecord.MZR_PARAs_Account__c && accountRecord.ZTS_US_MVP_Account__c)
            {
                accountRecord.MZR_Derm_Rebate__c = true;
            }
           
            if (!accountRecord.MZR_PARAs_Account__c && !accountRecord.ZTS_US_MVP_Account__c)
            {
                accountRecord.MZR_Derm_Rebate__c = false;
            }
        }
       
    }
}