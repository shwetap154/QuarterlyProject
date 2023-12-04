/****************************************************************************************************************************************** 
* Class Name   : INTLCallTriggerService
* Description  : Logic for all INTL Call__c triggers housed here.
* Created By   : Slalom/Mohamed Seliman
* Created Date : 17 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mohamed Seliman(Slalom)     02/17/2020          Created, Logic from all triggers moved to this class.
* Triggers(logic) added below:
*****************************************************************************************************************************************
 * Trigger Name   : CallTrigger
 * Description  : This is trigger on Call__c for After Insert, After Update, Before Delete events.
 *                
 *                  After Insert
 *                  -------------
 *                  1) Create a colleague for logged in user when a call is created. 
 *                  2) Create standard salesforce event whenever call is created
 *                  3) 
 *
 *                  After Update
 *                  -------------
 *                  1)  update the Salesforce event whenever call date is updated
 *                  2) 
 *
 *                  Before Delete
 *                  ------------
 *                  1) delete the Salesforce event whenever call is deleted
 *                  2) 
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
 * CloudSense(Bimba)       05/12/2014          Updated to add a check to bypass trigger
 * CloudSense(Shefali)     09/12/2014          Modified to update Call owner field
 * CloudSense(Shreyas)     03/18/2015          Added the method 'populateDaySinceLastCalled_FromCall' to populate the 'Days since last called' on account position
 * CloudSense(Sohil)       04/06/2015          Calling class 'taskUpdateonCallUpdate' update task on call update DEF-001215
 * CloudSense(Sohil)       07/21/2015          Added Code for Call Type Transaltion DEF - 001862 on call inserte and update
 * Cognizant (Mayukh Deb)  01/05/2018          Added Code to allow Specific users to delete Calls without updating the Account Position's 'Days since last called' field
 * Cognizant (Aritra)      08/01/2018          Added code to call the "CallNaming" method when Account on Call object is updated (Defect SC-003799)
 * Slalom (Elton Barbosa)  09/02/2020          Added code to translate call subtype   
 * Cognizant (Chanbasha)   05/10/2021          Added code for Pitcher Unplanned calls to calculate end date time based on start date time and duration (SC-008151)     
 * Cognizant (Aritra)      06/17/2021          Added Validation on Before Delete Call (SC-008096)
 * Cognizant (Sree Harsha) 09/07/2021          Commented the profile criteria to populate Last Call Date in call associated contacts(SC-008874)
 * Zoetis (Ethan Hirsch)   04/07/2022          Move AccountPositionsService.updateLastCallDateFromCalls from beforeUpdate to afterUpdate
* Cognizant (Deepshikha Tyagi) 24/08/2023     Added logic to populate Type field with Call owner's Position Type on Call in beforeInsert method
 ------------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : PIT_Call
 * Description  : This is trigger on Call__c for After Insert, After Delete, After Update events.
*****************************************************************************************************************************************/
public class INTLCallTriggerService 
{
    public static void beforeInsert(List<Call__c> triggerNew) 
    {
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();
        
        //Added by Shefali for Call Owner update 09 Dec 2014
        Map<Id,List<Call__c>> OwnerCallListMap = new Map<Id,List<Call__c>>();
        
        for(Call__c c: triggerNew){
            //TPDEV-420 - Start
            if(c.ZTS_EU_Call_Owner__c==null){
                c.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
            }//TPDEV-420 - End
            if(!OwnerCallListMap.containsKey(c.ZTS_EU_Call_Owner__c)){
                OwnerCallListMap.put(c.ZTS_EU_Call_Owner__c,new List<Call__c>{c});
            }else{
                OwnerCallListMap.get(c.ZTS_EU_Call_Owner__c).add(c);
            }
            //c.Name = c.ZTS_EU_Sub_Type__c +' - '+ c.ZTS_EU_Start_Date_Time__c.day() + '/'+ c.ZTS_EU_Start_Date_Time__c.month() +'/' + c.ZTS_EU_Start_Date_Time__c.year(); //Shefali 26-05-2015 DEF-0001356
            //Chanbasha added below code to calculate end date time based on start time and duration for Pitcher Unplanned Calls (SC-008151)
            //Commented out the below Completed status check because the call end date time calculation for all Calls in new LWC page will now be be donw through this class only.(SC-004726)
            //if(c.ZTS_EU_Status__c == 'Completed')
            //{
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
        //Populate the Type field on call with the Call Owner's position type
        if(OwnerCallListMap.size()>0){
            for(AggregateResult pos : [SELECT ZTS_EU_Employee__c,ZTS_EU_Type__c,count(Id)
                                       FROM ZTS_EU_Position__c 
                                       WHERE ZTS_EU_Employee__c IN :OwnerCallListMap.keyset() 
                                       AND ZTS_EU_Is_Active__c = true
                                       GROUP BY ZTS_EU_Employee__c,ZTS_EU_Type__c LIMIT 1000]){
                                           if(OwnerCallListMap.containsKey((string)pos.get('ZTS_EU_Employee__c'))){
                                               for(Call__c call : OwnerCallListMap.get((string)pos.get('ZTS_EU_Employee__c'))){
                                                   call.Type__c = (string)pos.get('ZTS_EU_Type__c');
                                               }
                                           }
                                       }
        }
    }
    public static void beforeUpdate(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap, List<Call__c> triggerNew, Map<Id, Call__c> triggerNewMap)
    {
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();

        // Added by Priya for SC-002380 (call owner update)
        for(Call__c c: triggerNew){       
           
                c.ZTS_EU_Call_Owner__c = triggerOldMap.get(c.id).ZTS_EU_Call_Owner__c;
         }
            
        //Eoc - Priya
        for(Integer i = 0; i < triggerNew.size(); i++){ 
            if(triggerNew[i].ZTS_EU_Start_Date_Time__c != triggerOld[i].ZTS_EU_Start_Date_Time__c){
                if(triggerNew[i].ZTS_EU_Duration__c == null) {triggerNew[i].ZTS_EU_Duration__c = '0.5 Hour';}
                if(triggerNew[i].ZTS_EU_Start_Date_Time__c != null)
                {
                    if(triggerNew[i].ZTS_EU_Duration__c.split(' ')[0].trim() != null)
                    {
                        Integer durationInMinutes =  Integer.valueOf(Double.valueOf(triggerNew[i].ZTS_EU_Duration__c.split(' ')[0].trim()) * 60);
                      	triggerNew[i].ZTS_EU_End_Date_Time__c = triggerNew[i].ZTS_EU_Start_Date_Time__c.addMinutes(durationInMinutes);
                    }
                }
            }
        }
    }
    public static void beforeDelete(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap)
    {
        Id currUsrId = UserInfo.getUserId();
        //Added below Call Validations for SC-008096
        String userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
        if(!userProfile.containsIgnoreCase('ADMIN'))
        {
            for(Call__c call: triggerOld)
            {
                if(call.ZTS_EU_Call_Owner__c != currUsrId)
                {
                    call.addError('You cannot delete others call');
                    return;
                }
                else if((call.ZTS_EU_Status__c == 'Completed') || (Call.ZTS_EU_Status__c == 'Submitted'))
                {
                    call.addError('You cannot delete a completed call.');
                    return;
                }
            }
        }
        //EOC - Added below Call Validations for SC-008096
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        
        
        if(!GlobalVariablesService.isEventDeletingCall){
            GlobalVariablesService.isCallDeletingEvent = true;
            CallService.deleteRelatedEvents(triggerOldMap);
        }
        //Added by Mayukh as part of SC-003446 on 01/05/2018
        List <AchiveUsernameAndId__c> aUsr = AchiveUsernameAndId__c.getall().values();
        Set <String> setUsr =new Set <String> ();
        for(AchiveUsernameAndId__c customvals:aUsr){
            setUsr.add(customvals.UserId__c);
        }
        if(!setUsr.contains(currUsrId)){
            AccountPositionsService.updateLastCallDateFromCalls(triggerOld, true);
        }
    }
    public static void afterInsert(List<Call__c> triggerNew, Map<Id, Call__c> triggerNewMap) 
    {
        
        System.debug('We are in after insert blokc ******');
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();

        boolean updateName =false;
        //List<ZTS_EU_Colleague__c> usercol = new List<ZTS_EU_Colleague__c>();
        //update account teams with last call date
        List<Id> callIds = new List<Id>();
        List<Call__c> callupdate = new List<Call__c>();
        Map<Id,List<Id>> callOwnerIdMap = new Map<Id,List<Id>>();//TPDEV-1752
        for(Call__c call:triggerNew){
            if(call.ZTS_EU_Start_Date_Time__c!=null){
                callIds.add(call.id);
            }
            if(call.ZTS_EU_Status__c == 'Completed')
            {
                callupdate.add(call);
            }
            //Added by Akanksha to create a colleague for logged in user when a call is created.
            
            //TPDEV-1752 start
            if(callOwnerIdMap.containsKey(call.ZTS_EU_Call_Owner__c)){
                List<Id> existingCallIdList = callOwnerIdMap.get(call.ZTS_EU_Call_Owner__c);
                existingCallIdList.add(call.Id);
                callOwnerIdMap.put(call.ZTS_EU_Call_Owner__c,existingCallIdList);
            }else{
                List<Id> newCallIdList = new List<Id>();
                newCallIdList.add(call.Id);
                callOwnerIdMap.put(call.ZTS_EU_Call_Owner__c,newCallIdList);
            }
        }
        
        if (callOwnerIdMap.size() != 0) {
            List<ZTS_EU_Colleague__c> colleagueList = new List<ZTS_EU_Colleague__c>();
            List<User> callOwnerList = [SELECT FirstName, LastName, Id FROM User WHERE Id = :callOwnerIdMap.keySet()];
            for(User u:callOwnerList){
                String name = u.FirstName + ' ' + u.LastName;
                for(Id var:callOwnerIdMap.get(u.Id)){
                    ZTS_EU_Colleague__c col = new ZTS_EU_Colleague__c(ZTS_EU_Call__c = var, ZTS_EU_User__c = u.Id, Name = name);
                    if(!colleagueList.contains(col)){
                        colleagueList.add(col);
                    }
                }
            }
            if(colleagueList.size() > 0){
                INSERT colleagueList;
            }
        }
        
        //TPDEV-1752 end
        
        /*if(usercol!=null && usercol.size()>0){
            System.debug('$$$ userCol: '+userCol);
            insert usercol;
}*/
        if(!callIds.isEmpty()){
            //  CallService.historicalOwner(Trigger.new);
            // Sohil Shah DEF - 001862 - Call type Translation
            CallService.callNaming(trigger.new);
        }
        if(!callupdate.isEmpty()){
            ZTS_EU_ECCUpdateOnCallSubmit.updateECC(callupdate);
        }
        for(call__C call:triggerNew)
        {
            if(Userinfo.getUserId() != '005F0000003wxnb')
            {
                updateName = true;
            }
        }

        CallService.generateAndSetupEventsFromCalls(triggerNew);
        //TOT modified code
        //ZTS_GL_CallManager callMgr=new ZTS_GL_CallManager();
        Set<Id> sIds2Recalc = new Set<Id>(); 

      for(Call__c c1 : triggerNew){
            //Changes Added by Aritra as part of SC-003970
            if(c1.PIT_Coaching_Guide__c!=NULL)
            {
              sIds2Recalc.add(c1.PIT_Coaching_Guide__c);
            }
        }
        
        if(sIds2Recalc.size() > 0){
            PIT_Coaching_Guide__c[] pcg = [select Id, PIT_No_of_Account_Calls__c, (Select Id From Calls__r) from PIT_Coaching_Guide__c where Id in :sIds2Recalc AND ZTS_EU_Market__c != 'United States'];
            if(pcg.size() > 0){
                for(PIT_Coaching_Guide__c p1 : pcg){
                    if(p1.Calls__r != null){
                        p1.PIT_No_of_Account_Calls__c = p1.Calls__r.size(); 
                    } else {
                        p1.PIT_No_of_Account_Calls__c = 0;
                    }
                }
                update pcg;
            }
    }
    }
    public static void afterUpdate(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap, List<Call__c> triggerNew, Map<Id, Call__c> triggerNewMap) 
    {
        System.debug('We are in after update blokc ******');
        
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();

        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        list<call__c> callupd = new list<call__c>();
        List<Call__c> recalculateLastCallDateCalls = new List<Call__c>();
        
        if(!GlobalVariablesService.isEventUpdatingCall){
            GlobalVariablesService.isCallUpdatingEvent = true;
            CallService.updateAndSyncEventsFromCalls(triggerNewMap,triggerOldMap);               
        }
        for(call__c call:triggerNew){
            if(call.ZTS_EU_Status__c == 'Completed'||(triggerOldMap.get( call.Id ).ZTS_EU_Start_Date_Time__c != triggerNewMap.get( call.Id ).ZTS_EU_Start_Date_Time__c)){
                callupd.add(call);
            }
            if(!callupd.isEmpty()){
                ZTS_EU_ECCUpdateOnCallSubmit.updateECC(callupd);
            }

            if (call.ZTS_EU_Start_Date_Time__c != triggerOldMap.get(call.Id).ZTS_EU_Start_Date_Time__c) {
                recalculateLastCallDateCalls.add(call);
            }
        }

        if(recalculateLastCallDateCalls.size() > 0){
            AccountPositionsService.updateLastCallDateFromCalls(recalculateLastCallDateCalls, false);
        }
        
        //Check Call for a Diagnostic Equipment Discussion item.  If one exists, create a lead for this call and assign it.  
        //Update the call to indicate diagnostic equpiment lead was created to avoid recursion
        //Sree Harsha commented the profile criteria below as part of SC-008874
        //if(profileName == 'EU Admin' || profileName == 'EU_Demo Profile' || profileName == 'EU_Rep Profile'){
            ZTS_EU_Contact_populateCallDates oUpdate = new ZTS_EU_Contact_populateCallDates();
            oUpdate.getLastCAllDate(triggerNew);
       // }
        // CloudSense(Sohil)Calling class 'taskUpdateonCallUpdate' update task on call update DEF-001215  
        taskUpdateonCallUpdate.updateTaskOnCallUpdate(triggerNew);
        
        // ATG - This is being called from the CallTriggerHandler since it applies to US and INTL markets
        // Callutils.createLeadFromCall(triggerNew, triggerOldMap);    
        
        //Defect:SC-003760
        Set<Id> accountIdsSet = new Set<Id>();
        
        for(Call__c objCall : triggerNew) {
            if(triggerOldMap.get(objCall.id).ZTS_EU_Account__c != triggerNewMap.get(objCall.Id).ZTS_EU_Account__c) {
                accountIdsSet.add(objCall.Id);
            }
        }
        
        if(!accountIdsSet.isEmpty()) {
            List<Attendee__c> lstattend = [SELECT Id,ZTS_EU_call__c, Name FROM Attendee__c WHERE ZTS_EU_call__c IN: accountIdsSet AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            if(lstattend != null) {
                try{
                    delete lstattend;
                } catch(DMLException dmlEx){
                    system.debug('----DMLException-----' + dmlEx);
                }
            }
        }
        
        /* public void validateCallOnInsertAndUpdate(Call__c lstCall) {
            List <  Time_Out_of_Territory__c > lstTot = new List < Time_Out_of_Territory__c > ();
            Set < Id > srepId = new Set < Id > ();
            Set < Id > setToTId = new Set < Id > ();
           srepId.add(lstCall.ZTS_EU_Call_Owner__c);
            lstTot = [Select t.ZTS_EU_Start_Date_Time__c, t.ZTS_EU_End_Date_Time__c, t.Id, t.OwnerId From Time_Out_of_Territory__c t where t.OwnerId IN: srepId AND ZTS_Market__c != 'United States'];
            Map < id, List < Time_Out_of_Territory__c >> mapUsertoT = new Map < id, List < Time_Out_of_Territory__c > > ();
            if (lstTot != null && lstTot.size() > 0) {
                for (Time_Out_of_Territory__c Tot: lstTot) {
                if (!mapUsertoT.containsKey(Tot.OwnerId)) {
                    mapUsertoT.put(Tot.OwnerId, new List < Time_Out_of_Territory__c > ());
                }
                mapUsertoT.get(Tot.OwnerId).add(Tot);
            }
            }
            
            if(mapUsertoT.containsKey(lstCall.ZTS_EU_Call_Owner__c))
            {
            for (Time_Out_of_Territory__c t:mapUsertoT.get(lstCall.ZTS_EU_Call_Owner__c))
                {
                 if(t.ZTS_EU_Start_Date_Time__c !=null && t.ZTS_EU_End_Date_Time__c!=null){
                  if ((t.ZTS_EU_Start_Date_Time__c < lstCall.ZTS_EU_Start_Date_Time__c && lstCall.ZTS_EU_Start_Date_Time__c < t.ZTS_EU_End_Date_Time__c) ||
                      (t.ZTS_EU_Start_Date_Time__c < lstCall.ZTS_EU_End_Date_Time__c && lstCall.ZTS_EU_End_Date_Time__c < t.ZTS_EU_End_Date_Time__c)) {
                          lstCall.addError(System.Label.Call_Cannot_be_submitted_in_ToT_period);
                          }
                        }
                }
            }
        }*/
        Set<Id> sIds2Recalc = new Set<Id>(); 

        for(Call__c c1 : triggerNew){
            Call__c c1Old = triggerOldMap.get(c1.Id);
            //Changes Added by Aritra as part of SC-003970
            if(c1.PIT_Coaching_Guide__c!=NULL)
            {
                sIds2Recalc.add(c1.PIT_Coaching_Guide__c);
            }
            //Changes Added by Aritra as part of SC-003970
            if(c1Old.PIT_Coaching_Guide__c!=NULL)
            {
                sIds2Recalc.add(c1Old.PIT_Coaching_Guide__c);
            }
        }
        
        if(sIds2Recalc.size() > 0){
            PIT_Coaching_Guide__c[] pcg = [select Id, PIT_No_of_Account_Calls__c, (Select Id From Calls__r) from PIT_Coaching_Guide__c where Id in :sIds2Recalc AND ZTS_EU_Market__c != 'United States'];
            if(pcg.size() > 0){
                for(PIT_Coaching_Guide__c p1 : pcg){
                    if(p1.Calls__r != null){
                        p1.PIT_No_of_Account_Calls__c = p1.Calls__r.size(); 
                    } else {
                        p1.PIT_No_of_Account_Calls__c = 0;
                    }
                }
                update pcg;
            }
    }
    }
    public static void afterDelete(List<Call__c> triggerOld, Map<Id, Call__c> triggerOldMap)
    {
        /*** Added by Bimba-03/12/2014 ***/
        //Get logged in user id
        Id currUsrId = UserInfo.getUserId();

        Set<Id> sIds2Recalc = new Set<Id>(); 

        for(Call__c c1 : triggerOld)
        {
            //Changes Added by Aritra as part of SC-003970
            if(c1.PIT_Coaching_Guide__c!=NULL)
            {
                sIds2Recalc.add(c1.PIT_Coaching_Guide__c);
            }
        }
        if(sIds2Recalc.size() > 0){
            PIT_Coaching_Guide__c[] pcg = [select Id, PIT_No_of_Account_Calls__c, (Select Id From Calls__r) from PIT_Coaching_Guide__c where Id in :sIds2Recalc AND ZTS_EU_Market__c != 'United States'];
            if(pcg.size() > 0){
                for(PIT_Coaching_Guide__c p1 : pcg){
                    if(p1.Calls__r != null){
                        p1.PIT_No_of_Account_Calls__c = p1.Calls__r.size(); 
                    } else {
                        p1.PIT_No_of_Account_Calls__c = 0;
                    }
                }
                update pcg;
            }
      }
    }
}