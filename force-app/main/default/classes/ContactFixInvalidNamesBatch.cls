global class ContactFixInvalidNamesBatch implements Database.Batchable<sObject>, Database.Stateful {
    public ContactFixInvalidNamesBatch(){
        doInit();
    }
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    public List<String> lstStringToReplace= new List<String>();
    public List<String> lstStringOther = new List<String>();
    public Set<String> charMarketSet = new Set<String>();
    public Set<String> marketSet = new Set<String>();
    private Integer errorCount = 0;
    @testVisible
    private static final String ERROR_LOG_ORIGIN_TYPE = 'ContactFixInvalidNamesBatch Batch - execute: update bad contacts';
    private static final String ERROR_LOG_ORIGIN_TYPE_FIN = 'ContactFixInvalidNamesBatch Batch - finish: update bad contacts';

    public void doInit(){
        getInvalidStrings();
    }
    /**
     * @description getting the Invalid chars from the custom meta data
     */
    public void getInvalidStrings(){
    List <Contact_Invalid_Char__mdt> chars = [SELECT Label,ReplaceWithEmpty__c,Market__c FROM Contact_Invalid_Char__mdt];
        for(Contact_Invalid_Char__mdt cha:chars){
            String concat = cha.Label.toLowerCase() + '|' + cha.Market__c;
            charMarketSet.add(concat);
            marketSet.add(cha.Market__c);
            if(cha.ReplaceWithEmpty__c == true){
                lstStringToReplace.add(cha.Label.toLowerCase());
                    }else{
                        lstStringOther.add(cha.Label.toLowerCase());
                    } 
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String quote = '\'';
        String query = 'SELECT Id, FirstName, LastName, Email,ZTS_EU_Market__c FROM Contact WHERE '+
        '(ZTS_EU_Contact_Status__c != \'Inactive\') AND' +
        '(ZTS_EU_Contact_Status__c != \'Pending - Incorrect First or Last Name\') AND ' +
        'ZTS_EU_Market__c IN :marketSet AND ' +
        '('+
        '(FirstName IN:lstStringToReplace) OR '+
        '(LastName IN:lstStringToReplace) OR '+
        '(FirstName IN:lstStringOther) OR '+
        '(LastName IN:lstStringOther)' + ')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contacts){
        List<Contact> contactsToUpdate = new List<Contact>();
        List<ZTS_EU_Error_Log__c> errorLogs = new List<ZTS_EU_Error_Log__c>();
        for (Contact currentContact : contacts) {
            String contactConcatFirstName = currentContact.FirstName?.toLowerCase() + '|' + currentContact.ZTS_EU_Market__c;
            String contactConcatLastName = currentContact.LastName.toLowerCase() + '|' + currentContact.ZTS_EU_Market__c;

            if (charMarketSet.contains(contactConcatFirstName) || charMarketSet.contains(contactConcatLastName)) {
                // 1. Check for invalid chars to replace in the first name
                //Since Last name is Mandatory we cannot replace it as blank
                if(lstStringToReplace.contains(currentContact.FirstName?.toLowerCase()) ){
                    currentContact.FirstName = '';
                }
                
                //For the records which contains lstStringOther, it is already the part of queried contact
                //So just update the contact status
                currentContact.ZTS_EU_Contact_Status__c = 'Pending - Incorrect First or Last Name';
                contactsToUpdate.add(currentContact);
            }
        }
        if(!contactsToUpdate.isEmpty()){
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            List<Database.SaveResult> saveResultList = Database.update(contactsToUpdate,dml); 
 
            //List<Database.SaveResult> saveResultList = Database.update(contactsToUpdate,false); -- commented for SC-008149
            recordsProcessed = recordsProcessed + contacts.size();

            // collect any errors during update
            errorLogs.addAll(
                ZTS_EU_Logger.buildLogsByDMLResults(saveResultList, ERROR_LOG_ORIGIN_TYPE)
            );
            if(!errorLogs.isEmpty()){
                errorCount += errorLogs.size();
                List<Database.SaveResult> saveResults = Database.insert(errorLogs, false);  
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        if (errorCount > 0) {
            ZTS_EU_Logger.info('Total Errors In Batch: ' + errorCount, 'count', ERROR_LOG_ORIGIN_TYPE_FIN);
        }
    }
}