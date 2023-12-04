// Main Class 
global class ZTS_US_RemoveDuplicateAP implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        string market;
        String query = 'SELECT Id,LastModifiedById,LastModifiedDate,ZTS_EU_Employee__c,ZTS_EU_Position__c,ZTS_AccountTerritory__c,ZTS_US_NARC_ID__c' 
            + ' FROM ZTS_EU_Account_Position__c WHERE'
            +  ' ZTS_EU_Market__c = \'United States\' ORDER BY CreatedDate ASC';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Account_Position__c> APsList) 
    {
        Map<String,List<ZTS_EU_Account_Position__c>> accountPositionMap = new Map<String,List<ZTS_EU_Account_Position__c>>();
        List<ZTS_EU_Account_Position__c> positionsToBeDeleted = new List<ZTS_EU_Account_Position__c>();
        for(ZTS_EU_Account_Position__c position:APsList)
        { 
            string StrPos=position.ZTS_EU_Position__c;
            string StrNARC=position.ZTS_US_NARC_ID__c;
            String StrEmp=position.ZTS_EU_Employee__c;
            String uKey = StrPos+StrNARC+StrEmp;
            if(accountPositionMap.containsKey(uKey)){
                accountPositionMap.get(uKey).add(position);
            }
            else
            {
                accountPositionMap.put(uKey,new List<ZTS_EU_Account_Position__c>{position});
            }
        }    
       
        for(String uKey: accountPositionMap.keySet()){
            List<ZTS_EU_Account_Position__c> extraPositionList = accountPositionMap.get(uKey);
            if(accountPositionMap.get(uKey).size() > 1){
                for(Integer i=0; i<extraPositionList.size()-2;i++ )
                	positionsToBeDeleted.add(extraPositionList[i]);
            }
        }
        delete positionsToBeDeleted;
    }
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}