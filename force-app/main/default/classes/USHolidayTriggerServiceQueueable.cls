/****************************************************************************************************************************************** 
* Trigger Name : USHolidayTriggerServiceQueueable
* Description  : All US Trigger Logic for Holiday__c object.
* Created By   : Sreekanth
* Created Date : 19th Oct, 2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sreekanth Battala      19/10/2022          Created 
*****************************************************************************************************************************************/
public class USHolidayTriggerServiceQueueable implements Queueable{
	
    private List<Holiday__c> triggerNew;
    private Map<Id, Holiday__c> triggerNewMap;
    
    public USHolidayTriggerServiceQueueable(List<Holiday__c> triggerNewL,Map<Id, Holiday__c> triggerNewMapL) {
        this.triggerNew = triggerNewL;
        this.triggerNewMap = triggerNewMapL;
    }
    
    public void execute(QueueableContext context) 
    {
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
        for(User u : [Select Id, ProfileId, ZTS_EU_State_County_Id__c, ZTS_EU_Market__c from User where IsActive = True AND UserRoleId != null AND ZTS_EU_Market__c IN :marketSet]){
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
        List<Time_Out_of_Territory__c> tList;
        if(!Test.isRunningTest()){
        	tList = [Select Id, OwnerId, ZTS_EU_Start_Date__c, ZTS_EU_End_Date__c from Time_Out_of_Territory__c where OwnerId in :userSet];  
        }else{
        	tList = [Select Id, OwnerId, ZTS_EU_Start_Date__c, ZTS_EU_End_Date__c from Time_Out_of_Territory__c];  
        }
        
        //System.enqueueJob(new USHolidayTriggerServiceQueueable(Trigger.New,tList));
        
        
        for (Holiday__c h: triggerNew) 
        {
            List <User> lstUser;
            if (h.ZTS_EU_Is_Active__c == true && h.ZTS_EU_Default_Holiday__c == true)
            {
                //Exclude those profiles which are not allowed to create TOT.
                lstUser = marketUserMap.get(h.ZTS_EU_Market__c);
                //Exclude those users who already created TOT on the Holiday date
                exs_totusr = new List<Time_Out_of_Territory__c>();
                if(!tList.isEmpty()){
                    for(Time_Out_of_Territory__c t : tList) {
                        if(t.ZTS_EU_Start_Date__c <= h.ZTS_EU_Holiday_Date__c && t.ZTS_EU_End_Date__c >= h.ZTS_EU_Holiday_Date__c)
                            exs_totusr.add(t);
                    }
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
                        tot.ZTS_EU_Reason__c = 'Company holiday';
                        tot.ZTS_EU_Start_Date__c = h.ZTS_EU_Holiday_Date__c;
                        tot.ZTS_EU_End_Date__c = h.ZTS_EU_Holiday_Date__c;
                        tot.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
                        tot.OwnerId = u.Id;
                        tot.ZTS_Market__c = h.ZTS_EU_Market__c;
                        tot.ZTS_EU_Status__c = 'Planned';
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
}