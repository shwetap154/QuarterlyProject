public class updateHistoricalCallsBatch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        string market = Label.Markets;
        List<String> marketList = new List<String>();       
        marketList = market.split(';');
        System.debug('marketList----'+marketList);
        string query = 'Select ID, Name, CreatedDate,createdById from Call__C where ZTS_EU_Account__r.ZTS_EU_Market__c IN: marketList';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<Call__C> scope)
    {
        /*User us = [select id, LanguageLocaleKey from User where id=:UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];
        us.LanguageLocaleKey = Label.language;
        update us;*/
        List<call__C> callListToUpdate = new List<Call__C>();
        for(call__C call: scope)
        {   
            callListToUpdate.add(call);
        }
        
        update callListToUpdate;    
    }
    public void finish(Database.BatchableContext ctx)
    {
    }
    
        
}