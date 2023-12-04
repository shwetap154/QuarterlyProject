public class ZTS_CreateAPFromPositionBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    public ZTS_CreateAPFromPositionBatch(List<ZTS_EU_Position__c> postionList){
        this.postionList = postionList;        
    }
    
    public final String query;
    private List<ZTS_EU_Position__c> postionList;
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        	Set<String> terrIdentifierSet=new Set<String>();
   		 	for(ZTS_EU_Position__c position: postionList){
        		terrIdentifierSet.add(position.ZTS_EU_Territory__c);
          	}
                
			return Database.getQueryLocator([SELECT ZTS_EU_Territory__c,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c 
                                                        WHERE ZTS_EU_Territory__c IN :terrIdentifierSet]);
                        
          	}
    	
    
	public void execute(Database.BatchableContext BC, List<sObject> scope){
            ZTS_EU_createAccountPosition.createAccountPosition(postionList,(List<ZTS_AccountTerritory__c>)scope);
    }	

 	public void finish(Database.BatchableContext BC){
   	}

}