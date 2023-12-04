/* -----------------------------------------------------------------------------------------------------------------------
Name:        ZTS_EU_BatchECC.cls
Description: Batch used for Inserting/Updating missing events for calls and colleagues for all markets                    
Date         Version    Author              Summary of Changes 
-----------  ------- -----------------   ------------------------------------------------------------------------------
20-04-2016   1.0        Priya               Initial Version    
------------------------------------------------------------------------------------------------------------------------*/

global class ZTS_EU_BatchECC implements Database.Batchable<sObject> {
    // Variable declaration 
    string str = system.label.Market_Value; //for market value reusability
   // string str1 = 'a0N23000000L8U9';
   // string str2 = 'a0N23000000L8UC';
    //Query for fetching all the calls respective for the market
    string query = 'select id,ZTS_EU_Account__c,ZTS_EU_Active__c,ZTS_EU_Employee__c,ZTS_EU_Position__r.ZTS_EU_Employee__c,ZTS_EU_Market__c,ZTS_EU_Is_Active__c,ZTS_EU_Employee_Id__c, ZTS_EU_Position__c ' + 
        +' FROM ZTS_EU_Account_Position__c '
        +' WHERE ZTS_EU_Account__r.ZTS_EU_Market__c =: str AND ZTS_EU_Active__c = true AND ZTS_EU_Market__c != \'United States\'';
      //  +' WHERE id =: str1 OR id =: str2 ';
    
    // Start Method 
    global Database.queryLocator start(Database.BatchableContext BC){
        system.debug('query========>'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ZTS_EU_Account_Position__c> aplist){
        set<id> setaccid = new set<id>();	
    for(ZTS_EU_Account_Position__c a: aplist)
        {
            setaccid.add(a.ZTS_EU_Account__c);
        }
   
    list<call__c> callist = [SELECT id, name, ZTS_EU_Account__c, Contact_Employee_Count__c, Discussion_Item_Count__c, Contact_Employee__c,Discussion_Item__c,ZTS_EU_Next_Call_Date__c, ZTS_EU_Sub_Type__c, ZTS_EU_Next_Step__c, ZTS_EU_Local_Subtype__c, ZTS_EU_Call_Objectives__c, ZTS_EU_Account__r.ZTS_EU_Market__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_Call_Owner__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Status__c from call__c where  ZTS_EU_Account__c in: setaccid AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
	
	map<id,list<ZTS_EU_Colleague__c>> mapcoll = new map<id,list<ZTS_EU_Colleague__c>>();
	list<ZTS_EU_Colleague__c> colleaguelist = [select id,ZTS_EU_Call__c,ZTS_EU_User__c,ZTS_EU_Call__r.ZTS_EU_Call_Owner__c from ZTS_EU_Colleague__c where ZTS_EU_Call__c in : callist AND ZTS_EU_Market__c != 'United States'];
        list<ZTS_EU_Colleague__c> colllst = new list<ZTS_EU_Colleague__c>();
            for(ZTS_EU_Colleague__c coll: colleaguelist)
            {
                list<ZTS_EU_Colleague__c> colleague = new list<ZTS_EU_Colleague__c>();
                colleague.add(coll);
                if(mapcoll!=null && mapcoll.containsKey(coll.ZTS_EU_Call__c))
                    colleague.addall(mapcoll.get(coll.ZTS_EU_Call__c));
 	                mapcoll.put(coll.ZTS_EU_Call__c,colleague);
                	colllst.addAll(colleague);
            }
	
	if(colllst!=null && colllst.size()>0)
	{
		ZTS_EU_EmployeeCallCreditCreate.createEmployeeCallCredit(colllst);
    }
	}
   global void finish(Database.BatchableContext BC){    
    }
}