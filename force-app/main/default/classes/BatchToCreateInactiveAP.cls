global class BatchToCreateInactiveAP implements Database.Batchable <sObject>{
    String s = system.label.ECC_Correction_Market;
    List<String> marketlst = s.split(',');
    String newstr='';
    String StartDate = system.label.ECC_Correction_Starting_Date;
    DateTime stDate = (DateTime) JSON.deserialize(StartDate, DateTime.class);
    String formatedstDt = stDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    Set<Id> accIdSet = new Set<Id>();
    Map<Id,Id> PosMap = new Map<Id,Id>();
    Map<String,Id> APMap = new Map<String,ID>();
    List<ZTS_EU_Account_Position__c> newAPListtocreate = new List<ZTS_EU_Account_Position__c>();
    global Database.QueryLocator start (Database.BatchableContext BC) 
    {
        for(String str: marketlst){
            newstr += '\'' + str + '\',';
            
        }
        newstr = newstr.lastIndexOf(',')> 0 ? '(' + newstr.substring(0,newstr.lastIndexOf(',')) + ')' : newstr ;
        String query = 'Select Id,ZTS_EU_Call__c,ZTS_EU_Call__r.ZTS_EU_Account__c,ZTS_EU_User__c,No_of_ECC__c ,ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c,ZTS_EU_Call__r.ZTS_EU_Status__c,ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c from ZTS_EU_Colleague__c where ZTS_EU_User__r.ZTS_EU_Market__c in '+ newstr+' and ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c >'+formatedstDt+ ' and No_of_ECC__c = 0';   
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<ZTS_EU_Colleague__c> scope){
        accIdSet.clear();
        for(ZTS_EU_Colleague__c c: scope)
        {
            accIdSet.add(c.ZTS_EU_Call__r.ZTS_EU_Account__c);
        }
        //Create User-Position Map
        system.debug('marketlst-->'+marketlst);
        List<ZTS_EU_Position__c> lstpos = [Select Id,Name,ZTS_EU_Employee__c,Market__c from ZTS_EU_Position__c where Market__c in:marketlst and ZTS_EU_Is_Active__c = TRUE and ZTS_EU_Employee__c <> NULL];
         system.debug('lstpos->'+lstpos);
        for(ZTS_EU_Position__c p: lstpos)
        {
            if(!PosMap.containsKey(p.ZTS_EU_Employee__c))
            {
                PosMap.put(p.ZTS_EU_Employee__c, p.Id);//Map<user_id,position_id>
            }
        }
        system.debug('PosMap->'+PosMap);
        //Check if AP is present
        List<ZTS_EU_Account_Position__c> lstAP = [Select Id,ZTS_EU_Account__c,ZTS_Employee_ID__c from ZTS_EU_Account_Position__c 
                                                  where Account_Market__c in : marketlst and ZTS_EU_Employee__c <>'' and ZTS_EU_Account__c in :accIdSet AND ZTS_EU_Market__c != 'United States'];
        for (ZTS_EU_Account_Position__c ap: lstAP)
        {
            APMap.put(ap.ZTS_EU_Account__c+':'+ap.ZTS_Employee_ID__c,ap.Id);
        }
		for(ZTS_EU_Colleague__c clg: scope){
			if(!APMap.containskey(clg.ZTS_EU_Call__r.ZTS_EU_Account__c+':'+clg.ZTS_EU_User__c) && (PosMap.get(clg.ZTS_EU_User__c)<>NULL) 
               && (clg.ZTS_EU_Call__r.ZTS_EU_Account__c<> NULL)) //If AP not found then create new AP
			{
				ZTS_EU_Account_Position__c ap = new ZTS_EU_Account_Position__c();
                ap.ZTS_EU_Account__c = clg.ZTS_EU_Call__r.ZTS_EU_Account__c;
                ap.ZTS_EU_Position__c = PosMap.get(clg.ZTS_EU_User__c);
                ap.ZTS_EU_Active__c = FALSE;
                ap.ZTS_EU_Bring_offline__c = FALSE;
                ap.Exclude_Sales__c = TRUE;
				newAPListtocreate.add(ap);
			}
		}
        try{
            if(newAPListtocreate.Size()>0)
            {
                system.debug('Size newAPListtocreate->'+newAPListtocreate.Size());
                Database.Insert(newAPListtocreate,false);
            }
        }
        catch(Exception e)
        {
            System.debug('The following exception has occurred on AP Creation: ' + e.getMessage());
        }
        
    }
    
    
    
    global void finish(database.BatchableContext BC){
        DataBase.ExecuteBatch(new BatchToCreateMissingECC());
    }

}