/* -----------------------------------------------------------------------------------------------------------------------
    Name:        ZTS_EU_BatchEventCreateToT.cls
Description: Batch used for Inserting/Updating missing events for ToT in all markets                    
Date         Version    Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
04-06-2015   1.0        Shefali               Initial Version    
11-06-2015   2.0        Priya                Modified Version

------------------------------------------------------------------------------------------------------------------------*/

global class ZTS_EU_BatchEventCreateToT implements Database.Batchable<sObject> {
    // Variable declaration 
    
    string query = 'SELECT  ZTS_EU_Sales_Representative__c,ZTS_EU_DurationInMinutes__c, ZTS_EU_Coaching_Day_Sub_Type__c, ZTS_EU_Reason__c, ZTS_EU_Description__c, CreatedById, CurrencyIsoCode, IsDeleted, OwnerId, Name, ZTS_EU_Accounting_Period__c, ZTS_EU_Current_Year_ToT__c, ZTS_EU_Duration__c, CreatedDate, Id, ZTS_EU_End_Date_Time__c, ZTS_EU_End_Date__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_Start_Date__c, ZTS_EU_State_County__c, ZTS_EU_Status__c, ZTS_EU_ToT_Day_Count__c, ZTS_EU_Type__c, ZTS_Market__c'+
        +' FROM Time_Out_of_Territory__c'
       +' WHERE ZTS_Market__c = \'Australia\'' ;
   
    // Start Method 
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('query========>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Time_Out_of_Territory__c> totList){
        ZTS_EU_TOT_Utils.IsTotDelete = true;
        List<Event> events= [select id, whatid, Ownerid from Event where  whatid in : totList AND ZTS_EU_Market__c != 'United States'];
        system.debug('events========>'+events);
        database.delete(events);
        system.debug('events========>'+events);
        list<Time_Out_of_Territory__c> totoff = new list<Time_Out_of_Territory__c>();
        list<Time_Out_of_Territory__c> toton = new list<Time_Out_of_Territory__c>();
        
        if(totList != null )
        {
            system.debug('totList========>'+totList);
            system.debug('totList==Size======>'+totList.Size());
            for(Time_Out_of_Territory__c tot :totList)
            {
                if(tot.ZTS_EU_Type__c == 'Time Off')
                {
                    system.debug('time off----');
                    
                    totoff.add(tot);
                }
                else if(tot.ZTS_EU_Type__c == 'Time On')
                {
                    system.debug('time on----');
                    toton.add(tot);
                }
            }
        }
        
        system.debug('totoffList========>'+totoff);
        system.debug('totonList======>'+toton);
        if(totoff.size()>0 && totoff!=null){
            system.debug('inside insert time off----');
            TOTService_ForCreateduser.generateAndSetupEventsFromToTs(totoff);
        }
        if(toton.size()>0 && toton!=null){
            system.debug('inside insert time on----');
            TOTService_ForCreateduser.generateAndSetupEventsFromToTs(toton);
            //TOTService_Forsalesrep.generateAndSetupEventsFromToTs(toton);
        }
    }

    global void finish(Database.BatchableContext BC){    
    }
}