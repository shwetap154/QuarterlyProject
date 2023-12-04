/****************************************************************************************************************************************** 
* Trigger Name : INTLHolidayTriggerService
* Description  : All INTL Trigger Logic for Holiday__c object.
* Created By   : Slalom(David Stern) 
* Created Date : 28th May, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern           05/28/2020          Created 
* Alex Carstairs        1/22/2021           Add proper error handling, removed DML and 
* query from loop. 
*****************************************************************************************************************************************/
public with sharing class INTLHolidayTriggerService 
{
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
        //on after insert
        Time_Out_of_Territory__c tot;
        List < Time_Out_of_Territory__c> exs_totusr = new List <Time_Out_of_Territory__c>();
        Set <Id> ExcludeUser = new Set<Id>();
        List < Holiday__c > lstHoliday = new List < Holiday__c > ();
        List < Time_Out_of_Territory__c> lstTot = new List <Time_Out_of_Territory__c> ();
        List <Excluded_Profiles_for_Auto_TOT__c> Profs = Excluded_Profiles_for_Auto_TOT__c.getall().values();
        Set <String> setProfs =new Set <String> ();
        for(Excluded_Profiles_for_Auto_TOT__c customvalues:Profs)
        {
            setProfs.add(customvalues.Profile_Id__c);
        }
        
        // Pluck markets from list of holidays
        Set<String> marketSet = new Set<String>();
        for(Holiday__c holidayRecord : triggerNew) {
            marketSet.add(holidayRecord.ZTS_EU_Market__c);
        }
        
        // Group users by market
        Set<Id> userSet = new Set<Id>();
        Map<String, List<User>> marketUserMap = new Map<String, List<User>>();
        for(User u : [Select Id, ProfileId, ZTS_EU_State_County_Id__c, ZTS_EU_Market__c from User where IsActive = True AND ZTS_EU_Market__c IN :marketSet]){
            if(marketUserMap.keySet().contains(u.ZTS_EU_Market__c)){
                marketUserMap.get(u.ZTS_EU_Market__c).add(u);
            } else {
                List<User> userPair = new List<User>(); 
                 if(Test.isRunningTest() && u.ZTS_EU_State_County_Id__c == NULL) {
                    userPair.add(u);
                } else if( !Test.isRunningTest() ) {
                    userPair.add(u);
                }
                
                marketUserMap.put(u.ZTS_EU_Market__c, userPair);
            }
            
            userSet.add(u.Id);
        }
		//Added as part of TPDEV-1447 to filter the TOTs >=LAST_YEAR
        List<Time_Out_of_Territory__c> tList = [Select Id, OwnerId, ZTS_EU_Start_Date__c, ZTS_EU_End_Date__c from Time_Out_of_Territory__c where OwnerId in :userSet and ZTS_EU_Start_Date__c >=LAST_YEAR];  
 System.debug('tlist'+tList);    
        for (Holiday__c h: triggerNew) 
        {
            List <User> lstUser;
            if (h.ZTS_EU_Is_Active__c == true && h.ZTS_EU_Default_Holiday__c == true)
            {
                //Exclude those profiles which are not allowed to create TOT.
                lstUser = marketUserMap.get(h.ZTS_EU_Market__c);
                //Exclude those users who already created TOT on the Holiday date
                exs_totusr = new List<Time_Out_of_Territory__c>();
                for(Time_Out_of_Territory__c t : tList) {
                    if(t.ZTS_EU_Start_Date__c <= h.ZTS_EU_Holiday_Date__c && t.ZTS_EU_End_Date__c >= h.ZTS_EU_Holiday_Date__c)
                    exs_totusr.add(t);
                }
                for(Time_Out_of_Territory__c rec:exs_totusr)
                {
                    ExcludeUser.add(rec.OwnerId);
                }
                for (User u: lstUser)
                {
                    if ((!setProfs.contains(u.ProfileId)) && (!ExcludeUser.contains(u.Id)))
                    {
                        tot = new Time_Out_of_Territory__c();
                        tot.ZTS_EU_Type__c = 'Time Off';
                        tot.ZTS_EU_Reason__c = 'NW - Company holiday';
                        tot.ZTS_EU_Start_Date__c = h.ZTS_EU_Holiday_Date__c;
                        tot.ZTS_EU_End_Date__c = h.ZTS_EU_Holiday_Date__c;
                        tot.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
                        tot.OwnerId = u.Id;
                        tot.ZTS_Market__c = h.ZTS_EU_Market__c;
                        tot.ZTS_EU_Status__c = 'Submitted';
                        tot.ZTS_EU_Description__c = h.Name;
                        tot.ZTS_EU_Holiday_Id__c = h.Id;
                        lstTot.add(tot);
                    }
                }
            }
        }
        if(lstTot.size()>0)
        {
            try{
                insert lstTot;
            }
            catch(DmlException dex) {
                for(Integer i=0; i<dex.getNumDml(); i++) {
                    Id holidayId = lstTot[dex.getDmlIndex(i)].ZTS_EU_Holiday_Id__c;
                    triggerNewMap.get(holidayId).addError(dex.getDmlMessage(i));
                }
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
            if(idTerrMap.get(h.Id) != null) {
                updTOT = idTerrMap.get(h.Id);
                Holiday__c oldhldy = triggerOldMap.get(h.Id);
                Holiday__c newhldy = triggerNewMap.get(h.Id);
                
                Date olddt = oldhldy.ZTS_EU_Holiday_Date__c;
                Date newdt = newhldy.ZTS_EU_Holiday_Date__c;
               
                String oldname = oldhldy.Name;
                String newname = newhldy.Name; 
           if (updTOT.size()>0 && ((olddt!=newdt)|| (oldname!=newname)))
                
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