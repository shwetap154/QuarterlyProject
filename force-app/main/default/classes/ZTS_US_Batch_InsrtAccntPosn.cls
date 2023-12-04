global class ZTS_US_Batch_InsrtAccntPosn implements Database.Batchable<sObject>
{
    String query;
    Map<String,String> TerrIdNameMap = new Map<String,String>();
    List<ZTS_EU_Position__c> posList = new List<ZTS_EU_Position__c>();
    List<string> accID = new List<String>();
    string accountId;
    global ZTS_US_Batch_InsrtAccntPosn(List<string> accId,Map<string,string> TerrIdNameMap, List<ZTS_EU_Position__c> posList)
    {
        System.debug('accId--------'+accId.size());
        string ids ;
        for(String str: accId)
        {
            ids = ids+','+str;
        }
        System.debug('ids0------------'+ids);
        this.TerrIdNameMap = TerrIdNameMap;
        this.posList = posList;
        this.accID = accId;
        query = 'select id, name,ZTS_EU_TSF_PBC__c  from account where id IN: accID AND ZTS_EU_Market__c != \'United States\'';
    }
    global Database.queryLocator start(Database.BatchableContext BC)
    {
        system.debug('Selected account--->'+query);     
        return Database.getqueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Account> scope)
    {
        System.debug('scope-------'+scope.size());
        
        Set<String> tsf_tokens=new Set<String>();
        Map<String, list<account>> AccountTerrMap = new Map<String, list<account>>();
        List<ZTS_EU_Account_Position__c> finalUpdateAccountPosition = new List<ZTS_EU_Account_Position__c>();
        AccountTerrMap.clear();
        finalUpdateAccountPosition.clear();
        for(account acc: scope ){
                
                
                if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                    tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC__c.split(';'));
                }
                
                for(String zipCode : tsf_tokens){
                    if(AccountTerrMap.containskey(zipCode)){
                        AccountTerrMap.get(zipCode).add(acc);
                    }
                    else{
                        AccountTerrMap.put(zipCode, new list<account>{acc}); //Initializing and adding element to the Map
                    }
                }
                
                tsf_tokens=new Set<String>(); // Added by Shreyas
            }             
                      
            
            if(!posList.isempty()){
            for(ZTS_EU_Position__c position: posList){
                if(AccountTerrMap != null && TerrIdNameMap != null && position.ZTS_EU_Territory__c != null && !AccountTerrMap.isEmpty() && !TerrIdNameMap.isEmpty()){
                    system.debug('inside if+++++++');
                    if(AccountTerrMap.get(TerrIdNameMap.get(position.ZTS_EU_Territory__c)) != null){
                        for(account a: AccountTerrMap.get(TerrIdNameMap.get(position.ZTS_EU_Territory__c))){                
                          accountId = accountId+','+a.id;
                          ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c();
                          accPos.ZTS_EU_Account__c = a.id;
                          accPos.ZTS_EU_Position__c = position.id;
                          accPos.ZTS_EU_Active__c  = true;
                          finalUpdateAccountPosition.add(accPos);      
                    }
                    }
                    
                }             
            }
            }
            try{
                if(!finalUpdateAccountPosition.isempty()){
                    System.debug('accountId--------'+accountId);
                    Database.SaveResult[] srList = Database.insert(finalUpdateAccountPosition,false);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
            }
            }catch(DMLException e){
                ZTS_EU_Logger.error('DMLException *******'+e.getMessage(), null, 'ZTS_EU_PositionUtilityClass.InsertAccountPosition');
            }
                 
    }
    global void finish(Database.BatchableContext BC){
    //yet to be defined
    }
}