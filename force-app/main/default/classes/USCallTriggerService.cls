/****************************************************************************************************************************************** 
* Class Name   : USCallTriggerService
* Description  : Logic for all US Call__c triggers housed here.
* Created By   : Slalom/Mohamed Seliman
* Created Date : 17 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mohamed Seliman(Slalom)     02/17/2020          Created, Logic from all triggers moved to this class.
* Trigger(s) added below:
-----------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : CallTrigger
 * Description  : This is trigger on Call__c for After Insert, After Update, Before Delete events.
 *                
 *                  After Insert
 *                  -------------
 *                  1) Generates events from call records and insert them
 *                  2) Updates Account Teams LastCall date.
 *                  3) 
 *
 *                  After Update
 *                  -------------
 *                  1)  Updates the Event records & keeps them in sync with the Call.
 *                  2) 
 *
 *                  Before Delete
 *                  ------------
 *                  1) Deletes the related Events on deletion of the Call record.
 *                  2) Prevents user from deleting Submitted calls.
 *                  3) 
 *                  4)  
 *
 *      
 * Created By   : Deloitte Consulting/Fayas Mansoor
 * Created Date : 17 January 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Fayas Mansoor           01/17/2014          Created 
 * Raghu                   05/19/2014          Added/Modified to Call Credits
 * Akanksha                05/20/2014          Added logic for creation of colleague on creation of call.
 * Cognizant (Chanbasha)   05/10/2021          Added code for Pitcher Unplanned calls to calculate end date time based on start date time and duration (SC-008151)  
 * Aritra (Cognizant)      01/19/2022          Added beforeUpdate method and updated beforeDelete method (SC-008816)
 * Aritra (Cognizant)      06/02/2022          Removed Call Submitted checking in beforeInsert method to calculate end date for every call (SC-009653)
*****************************************************************************************************************************************/
public class USCallTriggerService 
{
    public static void beforeInsert(List<Call__c> triggerNew) 
    {
        //System.assert(false, triggerNew[0].Opportunity_Type__c);
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();
        Boolean deActFlag;
        ZTS_EU_Deactivation_Custom_Setting__c deactTrgCS = ZTS_EU_Deactivation_Custom_Setting__c.getInstance(currUsrId);
        //Ilirjana 8/12/14 Added null check
        if(deactTrgCS != null){
            deActFlag = deactTrgCS.ZTS_EU_DeactivateTrigger__c;
        } 
        if(deActFlag)
        {        
            return;
        }

        //Added by Shefali for Call Owner update 09 Dec 2014

        for(Call__c c: triggerNew){
            c.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
            // c.Name = c.ZTS_EU_Sub_Type__c +' - '+ c.ZTS_EU_Start_Date_Time__c.day() + '/'+ c.ZTS_EU_Start_Date_Time__c.month() +'/' + c.ZTS_EU_Start_Date_Time__c.year(); //Shefali 26-05-2015 DEF-0001356
        
        //Chanbasha added below code to calculate end date time based on start time and duration for Pitcher Unplanned Calls (SC-008151)
       /*if(c.ZTS_EU_Status__c == 'Submitted')
       {*/
                if(c.ZTS_EU_Duration__c == null) {c.ZTS_EU_Duration__c = '0.5 Hour';}
                if(c.ZTS_EU_Start_Date_Time__c != null)
                {
                    if(c.ZTS_EU_Duration__c.split(' ')[0].trim() != null)
                    {
                        Integer durationInMinutes =  Integer.valueOf(Double.valueOf(c.ZTS_EU_Duration__c.split(' ')[0].trim()) * 60);
                        c.ZTS_EU_End_Date_Time__c = c.ZTS_EU_Start_Date_Time__c.addMinutes(durationInMinutes);
                    }
                }
                
            //}
            //EOC - Chanbasha added below code to calculate end date time based on start time and duration for Pitcher Unplanned Calls (SC-008151)
        
        } 
    }
    public static void beforeDelete(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap)
    {
        Boolean allowEventDeletion = true;//Added for SC-008816
        //ByPass for integration user profile
        if(ZTS_US_UserProfileCheck.isIntegrationUser(UserInfo.getUserId())) return;
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;

        USCallService.delSampleDrop(triggerOld);
        if(profileName !='System Administrator'){
            USCallService.delSubmittedCall(triggerOld);
        }
        //Added by Aritra Chakraborty to validate call deletion (SC-008816)
        if(profileName != 'System Administrator' && profileName != 'Integration Profile' && profileName != 'Support Administrator'){
            USCallService.validateCallDeletion(triggerOld);
            //allowEventDeletion = false;  //SC-010247 Sreekanth - Commented as This flag check is blocking events delete for Call owners other than Admin profiles
        } 
        if(!USGlobalVariablesService.isEventDeletingCall){ // SC-010247 - Sreekanth - Removed allowEventDeletion check since this check is blocking events delete for Call owners other than Admin profiles
            USGlobalVariablesService.isCallDeletingEvent = true;
            USCallService.deleteRelatedEvents(triggerOldMap);
        }
    }
    public static void afterInsert(List<Call__c> triggerNew, Map<Id, Call__c> triggerNewMap) 
    {
        //ByPass for integration user profile
        if(ZTS_US_UserProfileCheck.isIntegrationUser(UserInfo.getUserId())) return; 
                    
        List<ZTS_EU_Colleague__c> usercol = new List<ZTS_EU_Colleague__c>();
        //update account teams with last call date
        List<Id> callIds=new List<Id>();
        List<Id> userIds= new List<id>();
        Map<Id,User> UserMap; //= 
        for(Call__c call:triggerNew){
            if(call.ZTS_EU_Call_Owner__c != null ){
                userIds.add(call.ZTS_EU_Call_Owner__c); 
            }
        }
        UserMap = new Map<Id,User>([Select Id,FirstName,LastName from User where Id in:userIds AND ZTS_EU_Market__c = 'United States']);
        for(Call__c call:triggerNew){
            if(call.ZTS_EU_Start_Date_Time__c!=null){
                callIds.add(call.id);
            }
            
            //Added by Akanksha to create a colleague for logged in user when a call is created.
            String name='';
            ZTS_EU_Colleague__c col;
            if(call.ZTS_EU_Call_Owner__c == null){
                if(UserInfo.getFirstName()==null || UserInfo.getFirstName()==''){
                    name=UserInfo.getLastName();
                }
                else{
                    name= UserInfo.getFirstName()+' '+UserInfo.getLastName();
                }
                col=new ZTS_EU_Colleague__c(ZTS_EU_Call__c=call.id,ZTS_EU_User__c=call.CreatedById,Name=name);
            }
            else{
                System.debug('else----');
                name=UserMap.get(call.ZTS_EU_Call_Owner__c).FirstName+' '+UserMap.get(call.ZTS_EU_Call_Owner__c).LastName;
                col=new ZTS_EU_Colleague__c(ZTS_EU_Call__c=call.id,ZTS_EU_User__c=call.ZTS_EU_Call_Owner__c,Name=name);
            }
            
            usercol.add(col);
        }
        
        if(usercol!=null && usercol.size()>0){
            insert usercol;
        }
        if(!callIds.isEmpty()){
        }
        
        USCallService.generateAndSetupEventsFromCalls(triggerNew);
        CallUtils.setCallTerritory(triggerNew);
        CallUtils.createCallCredits(triggerNew);
    }
    public static void afterUpdate(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap, List<Call__c> triggerNew, Map<Id, Call__c> triggerNewMap) 
    {
        //ByPass for integration user profile
        if(ZTS_US_UserProfileCheck.isIntegrationUser(UserInfo.getUserId())) return;
        
        List<Id> callIds = new List<Id>();
        Map<Id, Id> carystaCallIds = new Map<Id, Id>();
        List<Id> callAccIds = new List<Id>(); 
        for(Call__c con: triggerNew){
            if(!String.Isblank(con.Opportunity_Type__c) && con.ZTS_EU_Status__c =='submitted'){
                if(con.Opportunity_Type__c.containsIgnoreCase('CARYSTA')){
                    carystaCallIds.put(con.Id, con.ZTS_EU_Account__c);
                }else{
                    callIds.add(con.Id); 
                } 
            } 
        }
       
        Set<Id> filteredCarystaCallIds = new Set<Id>();
        if(carystaCallIds.size() > 0){
            //exclude CARYSTA oppty creationg if there are open CARYSTA oppty already for the Account
            List<String> carystaClosedStages = new List<String> {'Installed','Not Interested','To Be Nurtured for Future'};   
            List<Id> carystaAccsTobeExcluded = new List<Id>();
            for(Opportunity opp :[Select Id,AccountId,StageName,Type FROM Opportunity 
                                  WHERE AccountId in :carystaCallIds.values() AND StageName NOT IN :carystaClosedStages 
                                  AND Type LIKE '%CARYSTA%'
                                  AND ZTS_EU_Market__c = 'United States']){
                                      carystaAccsTobeExcluded.add(opp.AccountId);      
                                  }
            if(carystaAccsTobeExcluded.size() > 0){
                for(Id id : carystaCallIds.keySet()){
                    if(carystaCallIds.get(id) != null && !carystaAccsTobeExcluded.contains(carystaCallIds.get(id))){
                        filteredCarystaCallIds.add(id);
                    }
                }
            }else{
                callIds.addAll(carystaCallIds.keySet());
            }
        } 
        if(filteredCarystaCallIds.size() >0 ){
            callIds.addAll(filteredCarystaCallIds);
        }
        if(callIds.size() > 0){ 
            CallUtils.createOpportunity(callIds);
        }
        
        /*
        for(Call__c con: Trigger.new){
        
        if(!String.Isblank(con.Opportunity_Type__c) && con.ZTS_EU_Status__c =='submitted'){ 
        CallUtils.createOpportunity(Trigger.new);
        }
        } */
        if(!USGlobalVariablesService.isEventUpdatingCall){
            USGlobalVariablesService.isCallUpdatingEvent = true;
            USCallService.updateAndSyncEventsFromCalls(triggerNewMap,triggerOldMap);
        }
        
        CallUtils.createCallCredits(triggerNew);
    }
    //Added for SC-008816
    public static void beforeUpdate(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap, List<Call__c> triggerNew, Map<Id, Call__c> triggerNewMap){
        USCallService.calculateEndDate(triggerNew, triggerOldMap);
    }
}