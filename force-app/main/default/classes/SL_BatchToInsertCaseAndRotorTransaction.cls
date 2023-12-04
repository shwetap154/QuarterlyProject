/**
* @ClassName    : SL_BatchToInsertCaseAndRotorTransaction 
* @JIRATicket   : LIGHTNI-1802
* @CreatedOn    : 20th November, 2019
* @CreatedBy    : Chetna
* @ModifiedBy   : 
* @Description  : Batch for inserting Case and Rotor transaction records
*/
global class SL_BatchToInsertCaseAndRotorTransaction implements Database.Batchable<sObject>{

	global Database.QueryLocator start(Database.BatchableContext BC){
        String strQuery = 'SELECT Id, Name, ZTS_EU_Market__c, Rotor_Credit_Roll_Up_Sum__c '+
            'FROM Account '+
            'WHERE Rotor_Credit_Roll_Up_Sum__c > 0';
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext BC, List<Account> lstAccounts){
        
        map<String, Integer> mapMarketMetadataLabeltoCredit = new map<String, Integer>();
        List<Case> lstInsertCases = new List<Case>();
        List<Rotor_Transaction__c> lstRotorTransactions = new List<Rotor_Transaction__c>();
        Id caseRecordType = Schema.Sobjecttype.Case.getRecordTypeInfosByDeveloperName().get('Rotor_Credit').getRecordTypeId();
        for(Market_Metadata_Record__mdt objMarketMetadata: [SELECT MasterLabel, Rotor_Credit_Threshold__c FROM Market_Metadata_Record__mdt]){
            mapMarketMetadataLabeltoCredit.put(objMarketMetadata.MasterLabel , (Integer)objMarketMetadata.Rotor_Credit_Threshold__c);
        }
        for(Account objAccount: lstAccounts){
            Integer marketCredit = mapMarketMetadataLabeltoCredit.get(objAccount.ZTS_EU_Market__c);
            Integer result = (Integer)(objAccount.Rotor_Credit_Roll_Up_Sum__c)/marketCredit;
            if(result > 0){
                Case objCase = new Case(RecordTypeId = caseRecordType, AccountId = objAccount.Id, Number_of_Boxes__c = result);
                lstInsertCases.add(objCase);
                Rotor_Transaction__c objRotorTransaction = new Rotor_Transaction__c(Account__c = objAccount.Id, Rotor_Credit__c = -((result*marketCredit ) > 999 ? 999 : (result*marketCredit )));
                lstRotorTransactions.add(objRotorTransaction);  
            }        
        }
        for(Rotor_Transaction__c objRotorTransaction: [SELECT Id, Account__c, Rotor_Credit__c, Locked__c FROM Rotor_Transaction__c WHERE Account__c IN: lstAccounts AND Locked__c = FALSE]){
            objRotorTransaction.Locked__c = TRUE;
            lstRotorTransactions.add(objRotorTransaction);
        }
        upsert lstRotorTransactions;
        insert lstInsertCases;
     	
     }
    global void finish(Database.BatchableContext BC){ 
    }	
}