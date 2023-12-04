global class BatchToCreateMissingECC implements Database.Batchable <sObject> {
   
    String s = system.label.ECC_Correction_Market;
    List<String> marketlst = s.split(',');
    String newstr='';
    String StartDate = system.label.ECC_Correction_Starting_Date;
    DateTime stDate = (DateTime) JSON.deserialize(StartDate, DateTime.class);
    String formatedstDt = stDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    Map<String,Id> APMap = new Map<String,ID>();
    List<ZTS_EU_Employee_Call_Credit__c> lstECCtoCreate = new List<ZTS_EU_Employee_Call_Credit__c>();
    Set<Id> accIdSet = new Set<Id>();
    
    global Database.QueryLocator start (Database.BatchableContext BC) 
    {
        if (Test.isRunningTest()) {
            marketlst = new List<String>();
            marketlst.add('New Zealand');
        }
        for(String str: marketlst){
            newstr += '\'' + str + '\',';
        }
        newstr = newstr.lastIndexOf(',')> 0 ? '(' + newstr.substring(0,newstr.lastIndexOf(',')) + ')' : newstr ;
        String query = 'Select Id,ZTS_EU_Call__c,ZTS_EU_Call__r.ZTS_EU_Account__c,ZTS_EU_User__c,No_of_ECC__c ,ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c,ZTS_EU_Call__r.ZTS_EU_Status__c,ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c from ZTS_EU_Colleague__c where ZTS_EU_User__r.ZTS_EU_Market__c in '+ newstr+' and ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c >'+formatedstDt+ ' and No_of_ECC__c = 0';   
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<ZTS_EU_Colleague__c> scope){
        if (Test.isRunningTest()) {
            marketlst = new List<String>();
            marketlst.add('New Zealand');
        }
        accIdSet.clear();
        for(ZTS_EU_Colleague__c c: scope)
        {
            accIdSet.add(c.ZTS_EU_Call__r.ZTS_EU_Account__c);
        }
        List<ZTS_EU_Account_Position__c> lstAP = [Select Id,ZTS_EU_Account__c,ZTS_Employee_ID__c from ZTS_EU_Account_Position__c 
                                                  where Account_Market__c in: marketlst and ZTS_EU_Employee__c <>'' and ZTS_EU_Account__c in :accIdSet
                                                  AND ZTS_EU_Market__c != 'United States'];
        List<ECC_FY__mdt> eccFYList = new list<ECC_FY__mdt>([select id,DeveloperName,Year__c,Start_Date_Time_for_FY__c,End_DateTime_for_FY__c,End_Date__c from ECC_FY__mdt ]);
        for (ZTS_EU_Account_Position__c ap: lstAP)
        {
            APMap.put(ap.ZTS_EU_Account__c+':'+ap.ZTS_Employee_ID__c,ap.Id);
        }
        for (ZTS_EU_Colleague__c clg: scope)
        {
            if(APMap.containskey(clg.ZTS_EU_Call__r.ZTS_EU_Account__c+':'+clg.ZTS_EU_User__c))
            {
                ZTS_EU_Employee_Call_Credit__c ecc = new ZTS_EU_Employee_Call_Credit__c();
                ecc.ZTS_EU_Account_Position__c = APMap.get(clg.ZTS_EU_Call__r.ZTS_EU_Account__c+':'+clg.ZTS_EU_User__c);
                ecc.ZTS_EU_Call__c = clg.ZTS_EU_Call__c;
                ecc.ZTS_EU_Employee_Colleague__c = clg.Id;
                ecc.Call_End_Date__c =clg.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c;
                if(clg.ZTS_EU_Call__r.ZTS_EU_Status__c == 'Completed' || clg.ZTS_EU_Call__r.ZTS_EU_Status__c == 'Submitted' )
                {
                    ecc.Is_Call_status_Completed__c = TRUE;
                }
                else
                {
                    ecc.Is_Call_status_Completed__c = FALSE;
                }
                for(ECC_FY__mdt rec: eccFYList)
                {
                    if((clg.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c>=rec.Start_Date_Time_for_FY__c) && (clg.ZTS_EU_Call__r.ZTS_EU_Start_Date_Time__c<=rec.End_DateTime_for_FY__c))
                    {
                        ecc.ZTS_EU_FY_EndDate__c = rec.End_Date__c;
                        
                    }
                }
               if((clg.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c == null || clg.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c.year() == system.today().year()) && (clg.ZTS_EU_Call__r.ZTS_EU_Status__c == 'Completed' || clg.ZTS_EU_Call__r.ZTS_EU_Status__c == 'Submitted'))
                {
                    ecc.Is_Call_Completed_In_Current_FY__c = TRUE;
                }
               else{ecc.Is_Call_Completed_In_Current_FY__c = FALSE;}
                
                lstECCtoCreate.add(ecc); 
            }
        }
        try{
            if(lstECCtoCreate.size()>0)
            {
                Database.Insert(lstECCtoCreate);
            }
           }
        catch(DMLException e){
           System.debug('The following exception has occurred on ECC Creation: ' + e.getMessage());
        }
        
    }
    global void finish(database.BatchableContext BC){
        
    }
   


}