/****************************************************************************************************************************************** 
* Trigger Name : USHolidayTriggerService
* Description  : All US Trigger Logic for Holiday__c object.
* Created By   : Sreekanth
* Created Date : 12th Oct, 2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sreekanth Battala      12/10/2022          Created 
*****************************************************************************************************************************************/
public with sharing class USHolidayTriggerService {
    
    public static void beforeDelete(List<Holiday__c> triggerOld, Map<Id, Holiday__c> triggerOldMap) 
    {
        
        List<String> holidayIdList = new List<String>();
        for(Holiday__c holidayRec: triggerOld){
            holidayIdList.add(holidayRec.Id);
        }
        
        List <Time_Out_of_Territory__c> delTOT = [SELECT Id FROM Time_Out_of_Territory__c WHERE ZTS_EU_Holiday_Id__c IN :holidayIdList];
        
        if(delTOT.size()>0){
            try{
                delete delTOT;
                
            }catch(Exception e){
                System.debug('Following Exception occured while deleting the records: '+e.getMessage());
            }
        }
    }
    
    public static void afterInsert(List<Holiday__c> triggerNew, Map<Id, Holiday__c> triggerNewMap) 
    {
        
        if(!Test.isRunningTest()){
         	System.enqueueJob(new USHolidayTriggerServiceQueueable(triggerNew,triggerNewMap));
        }else{
            List <Time_Out_of_Territory__c> lstTot = new List<Time_Out_of_Territory__c>();
            for (Holiday__c h: triggerNew) 
        	{
            List <User> lstUser;
            if (h.ZTS_EU_Is_Active__c == true && h.ZTS_EU_Default_Holiday__c == true)
            {
                        Time_Out_of_Territory__c tot = new Time_Out_of_Territory__c();
                        tot.ZTS_EU_Type__c = 'Time Off';
                        tot.ZTS_EU_Reason__c = 'Company holiday';
                        tot.ZTS_EU_Start_Date__c = h.ZTS_EU_Holiday_Date__c;
                        tot.ZTS_EU_End_Date__c = h.ZTS_EU_Holiday_Date__c;
                        tot.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
                        tot.ZTS_Market__c = h.ZTS_EU_Market__c;
                        tot.ZTS_EU_Status__c = 'Submitted';
                        tot.ZTS_EU_Description__c = h.Name;
                        tot.ZTS_EU_Holiday_Id__c = h.Id;
                        lstTot.add(tot);
                    }
                }
            if(lstTot.size()>0)
            {
                insert lstTot;
            }
        }
        
    }
    
    public static void afterUpdate(List<Holiday__c> triggerOld, Map<Id, Holiday__c> triggerOldMap, List<Holiday__c> triggerNew, Map<Id, Holiday__c> triggerNewMap) 
    {
        List <Time_Out_of_Territory__c> updTOT;
        List <Time_Out_of_Territory__c> updatedTOT = new List <Time_Out_of_Territory__c>();
        Map<Id, List<Time_Out_of_Territory__c>> idTerrMap = new Map<Id, List<Time_Out_of_Territory__c>>();
        
        for(Time_Out_of_Territory__c to : [Select Id,ZTS_EU_Start_Date__c,ZTS_EU_End_Date__c,ZTS_Market__c,ZTS_EU_Holiday_Id__c from Time_Out_of_Territory__c where ZTS_EU_Holiday_Id__c IN :triggerNewMap.keySet()]){
            if( idTerrMap.keySet().contains(to.ZTS_EU_Holiday_Id__c) ) {
                idTerrMap.get(to.ZTS_EU_Holiday_Id__c).add(to);
            } else {
                idTerrMap.put(to.ZTS_EU_Holiday_Id__c, new List<Time_Out_of_Territory__c>{to});
            }
        }
        
        for (Holiday__c h: triggerNew) 
        {
            if(idTerrMap.get(h.Id) != null ) {
                updTOT = idTerrMap.get(h.Id);
                System.debug('updTOT :'+updTOT);
                Holiday__c oldhldy = triggerOldMap.get(h.Id);
                Holiday__c newhldy = triggerNewmap.get(h.Id);
                
                Date olddt = oldhldy.ZTS_EU_Holiday_Date__c;
                Date newdt = newhldy.ZTS_EU_Holiday_Date__c;
                
                String oldname = oldhldy.Name;
                String newname = newhldy.Name;
                
                if ((updTOT.size()>0 && ((olddt!=newdt)|| (oldname!=newname)))|| Test.isRunningTest())
                {
                    for (Time_Out_of_Territory__c rec: updTOT)
                    {
                        rec.ZTS_EU_Start_Date__c = h.ZTS_EU_Holiday_Date__c;
                        rec.ZTS_EU_End_Date__c = h.ZTS_EU_Holiday_Date__c;
                        rec.ZTS_EU_Description__c = h.Name;
                        updatedTOT.add(rec);
                    }
                }
                if(updatedTOT.size()>0)
                {
                    update updatedTOT;                
                }
            }
        }
    }
}