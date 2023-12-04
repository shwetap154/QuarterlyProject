/*
* @Name: CallUtils
* @Desciption: Used as the Utility class for the trigger on Call__c object.
*              Acts as controller to the CallActivitySync.
* @date Created:Jan 15, 2014
* @author Ketan Prakash Singh
*/

public class CallUtils{
    
    @testVisible static final String OPPORTUNITY_ERROR_LOG_ORIGIN_TYPE = 'CallUtils - createOpportunity: insert opportunities';
    @testVisible static final String EVENT_INS_ERROR_LOG_ORIGIN_TYPE = 'CallUtils - syncOnInsert: insert events';
    @testVisible static final String EVENT_UPD_ERROR_LOG_ORIGIN_TYPE = 'CallUtils - syncOnUpdate: update events';
    
    public Static Boolean  IsCallDelete = false;
    public static void syncOnInsert(List<Call__c> lstCall){
        List<Event> lstEvent = new List<Event>();
        Set<Id> setUserIds = new Set<Id>();
        
        for(Call__c callObj: lstCall){
            Event eventObj = new Event();
            eventObj.OwnerId = callObj.ZTS_EU_Call_Owner__c;       
            eventObj.Subject = callObj.ZTS_EU_Call_Objectives__c;        
            eventObj.WhatId = callObj.Id;       
            Date myDate = date.Today();
            datetime myDateTime = datetime.now();
            eventObj.ActivityDate = myDate ;
            eventObj.ActivityDateTime = myDateTime ;
            eventObj.DurationInMinutes = 120;
            
            //setUserIds.add(eventObj.OwnerId);
            lstEvent.add(eventObj);
            System.debug('@@@lstEvent is: '+lstEvent[0].id);
            
            
        }
        try{
            insert lstEvent;
        }
        catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(EVENT_INS_ERROR_LOG_ORIGIN_TYPE);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, EVENT_INS_ERROR_LOG_ORIGIN_TYPE);  
        }
        
        System.debug('@@@lstEvent is: '+lstEvent[0].id);
        
    }
    
    public static void syncOnUpdate(List<Call__c> lstCall){
        Set<Id> setCallId = new Set<Id>();
        
        for(Call__c c: lstCall){
            setCallId.add(c.Id);
            System.debug('@@@setCallId is: '+setCallId);
        }
        List<Call__c> lstCallsWithEvent = [Select Id,ZTS_EU_Call_Objectives__c,
                                           (Select Id from Events) from Call__c where id in :setCallId];
        List<Event> lstEvent = new List<Event>();
        Map<Id,List<Event>> mapCallIdAndLstEvent = new Map<Id,List<Event>>();
        for(Call__c c: lstCallsWithEvent){
            mapCallIdAndLstEvent.put(c.Id,c.Events); 
        }
        for(Call__c c: lstCallsWithEvent){
            if(c.ZTS_EU_Call_Objectives__c != null){
                for(Event e: mapCallIdAndLstEvent.get(c.Id))
                {
                    e.Subject = c.ZTS_EU_Call_Objectives__c;
                    lstEvent.add(e);
                    System.debug('@@@lstEvent is: '+lstEvent);
                }
            }
        }
        try{
            update lstEvent;
        }
        catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(EVENT_UPD_ERROR_LOG_ORIGIN_TYPE);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, EVENT_UPD_ERROR_LOG_ORIGIN_TYPE);  
        }
        
    }
    //If a call has been updated and has a discussion item of type "Diagnostic Equipment Lead" create a new lead and associate it to the account.
    public static void createLeadFromCall(List<Call__c> newList, Map<Id, Call__c> oldMap){
        Map<Id, Call__c> completedCallMap = new Map<Id,Call__c>();
        for(Call__c call : newList){
            System.debug('createLeadFromCall > Call Id ' + call.id + ' - fromList : ' + newList +  'status from that call ==>'+ call.ZTS_EU_Status__c);
            //Check for a completed call that has attendees
            System.debug('createLeadFromCall > Call Status: ' + call.ZTS_EU_Status__c + ' - OldMap: ' + oldMap);
            
            if((call.ZTS_EU_Status__c == 'Completed' || call.ZTS_EU_Status__c == 'Submitted')
               && (completedCallMap.containsKey(call.Id) == false ))
                //&& (oldMap == null || !oldMap.containsKey(call.Id) || call.ZTS_EU_Status__c != oldMap.get(call.Id).ZTS_EU_Status__c))
            {
                system.debug('count for the execution!');
                completedCallMap.put(call.Id, call);
            }
        }
        System.debug('completedCallMap before checking for Leads to create:===> '+ completedCallMap);           
        
        CreateLeadFromCall createLeadsFromCalls = new CreateLeadFromCall(completedCallMap);
        //Created for "Diagnostic Equipment Lead" discussions initailly
        //Mila imas revision
        createLeadsFromCalls.processCallDiscussions('Diagnostics Equipment Lead');
    }
    
    /***********
* Method name  : createOpportunity
* Description  : Inserts Oppotunity whenever LCP Opportunity Product is selected as Discussion Item.
* Return Type  : void.
* Parameters   : Updated Calls.
***********/
    public static void createOpportunity(List<Id> calls){ 
        //List<Call__c> calllist = [select id, ZTS_EU_Call_Owner__r.ManagerId, ZTS_EU_Account__r.Name,ZTS_EU_Account__c,ZTS_EU_Call_Owner__c,Opportunity_Type__c,ZTS_US_Call_Territory__c from Call__c where id IN:calls AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']; 
        //System.debug('...Inside createOpportunity calllist...' + calllist);
        // List<ZTS_US_Discussion__c> lst = new List<ZTS_US_Discussion__c>([select ZTS_US_Discussion_Items__r.name,name from ZTS_US_Discussion__c where ZTS_US_Call_Attendee__r.call__r.id IN:calls and ZTS_US_Discussion_Items__r.ZTS_US_Discussion_Item_Title__c='Leadership Certificate Program (LCP) - Opportunity']);
        //Set<ZTS_EU_Discussion__c> unique = new Set<ZTS_EU_Discussion__c>();
        //unique.addall(lst);
        //System.debug('*****LIst Is******' +lst.size());
        //System.debug('*****set Is******' +unique);
        //lst.clear();
        //lst.addall(unique);
        // Commented out by Mila Imas for SC-008118
        /* List<Opportunity> oppts = new List<Opportunity>(); 
for(Call__c disc : calllist){
boolean isPFPStype = false;
Opportunity opt = new Opportunity();
opt.accountid= disc.ZTS_EU_Account__c;
opt.ZTS_US_call__c=disc.id; 
System.debug('...Oppty Type disc.Opportunity_Type__c:: ' + disc.Opportunity_Type__c);
if(disc.Opportunity_Type__c=='KL Automation - Basic Plan Opportunity'){
opt.name= disc.ZTS_EU_Account__r.name+ ' - KL Automation - Basic Plan '+System.today().format();
opt.type='KL Automation - Basic';
}
else if(disc.Opportunity_Type__c=='KL Automation - Premium Plan Opportunity'){
opt.name= disc.ZTS_EU_Account__r.name+ ' - KL Automation - Premium Plan '+System.today().format();
opt.type='KL Automation - Premium';

}  else{ 
isPFPStype = true;
List<DiscussionMapping__c> ditemap = DiscussionMapping__c.getall().values();  
for(DiscussionMapping__c di: ditemap){  
if(disc.Opportunity_Type__c == di.Disc_Item__c){ 
Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
Schema.RecordTypeInfo rtInfo =  rtMapByName.get(di.Oppty_Type__c);
id recordTypeId = rtInfo.getRecordTypeId();
opt.RecordTypeId = recordTypeId;
opt.name = disc.ZTS_EU_Account__r.name+ ' - ' + di.Disc_Item__c + ' - '+System.today().format();
opt.type = di.Oppty_Type__c;
if(di.Oppty_Type__c != null && (!di.Oppty_Type__c.containsIgnoreCase('CARYSTA') && !di.Oppty_Type__c.containsIgnoreCase('Diagnostics Equipment Lead')) ){
opt.Service_Contract__c = di.Disc_Item__c;                                
}

break;
}
}
} 
System.debug('...Opty type..' + opt.type);
opt.CloseDate = System.today()+90;
opt.Amount = 0.00;
opt.ownerId = disc.ZTS_EU_Call_Owner__c;  

if(disc.ZTS_EU_Call_Owner__r.ManagerId != null){
opt.ABM__c = disc.ZTS_EU_Call_Owner__r.ManagerId;                    
}
if(disc.Opportunity_Type__c != null && (disc.Opportunity_Type__c.containsIgnoreCase('CARYSTA') 
|| disc.Opportunity_Type__c.containsIgnoreCase('Diagnostics Equipment Lead')) ){
opt.StageName = 'New Lead Received (Petcare/Conference/Other)';

}else if(isPFPStype){
opt.StageName = 'Field Force Identified a Customer need';                    
}else{
opt.StageName = 'Opportunity Identified';                    
}
opt.ZTS_US_Call__c = disc.id;
opt.ZTS_US_Territory__c= disc.ZTS_US_Call_Territory__c; 
oppts.add(opt);
}
*/
        //List<Database.SaveResult> results = null;        
    }
    
    /***********
* Method name  : createCallCredits
* Description  : create a call credit to account team members who participated in calls.
* Return Type  : Pagereference.
* Parameters   : None.
***********/
    public static void createCallCredits(List<Call__c> calls){
        Set<Id> accIdSet=new Set<Id>();
        Set<Id> callCreatorSet=new Set<Id>();
        Set<Id> submittedCallIds=new Set<Id>();
        List<ZTS_US_Call_Credit__c> ccrToInsert=new List<ZTS_US_Call_Credit__c>();
        //fetch call collegues info
        Map<Id,Call__c> callWithColleaguesMap=new Map<Id,Call__c>([SELECT Id, ZTS_EU_Account__c, (SELECT ZTS_EU_Call__c,Name,ZTS_EU_User__c,Id FROM Colleagues__r WHERE ZTS_EU_User__c!=NULL) FROM Call__c WHERE Id IN:calls AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']);
        for(Call__c call:calls){
            if(call.ZTS_EU_Status__c==ZTS_EU_GlobalConstants.CALL_STATUS_COMPLETED){
                submittedCallIds.add(call.Id);
                accIdSet.add(call.ZTS_EU_Account__c);
            }
        }
        Map<String,List<ZTS_EU_Account_Position__c>> acc_team_usr_map=new Map<String,List<ZTS_EU_Account_Position__c>>();
        //get  Accteams associated with Account Calls
        List<ZTS_EU_Account_Position__c> accTeams=[SELECT Id,Name,ZTS_Employee_ID__c,ZTS_EU_Account__c FROM ZTS_EU_Account_Position__c WHERE
                                                   ZTS_EU_Account__c =:accIdSet AND ZTS_Employee_ID__c!=null AND ZTS_EU_Market__c = 'United States'];                         
        List<Id> accTeamsIds=new List<Id>();
        
        /** CREATE ACCUSER KEY MAP WITH ACCTEAM VALUES **/
        for(ZTS_EU_Account_Position__c accTeam:accTeams){
            if(!String.isBlank(accTeam.ZTS_Employee_ID__c)){
                accTeamsIds.add(accTeam.id);
                //CREATE ACCOUNT:USER KEY
                String ACC_USR_KEY=accTeam.ZTS_EU_Account__c+':'+accTeam.ZTS_Employee_ID__c;
                if(!acc_team_usr_map.containsKey(ACC_USR_KEY)){
                    acc_team_usr_map.put(ACC_USR_KEY,new List<ZTS_EU_Account_Position__c>());
                }
                acc_team_usr_map.get(ACC_USR_KEY).add(accTeam);
            }
        }
        system.debug('acc_team_usr_map-->'+acc_team_usr_map);//added by Namrata
        
        List<ZTS_US_Call_Credit__c> existing_ccr_List=[SELECT Id, ZTS_US_Call__c, ZTS_EU_Account_Position__c FROM ZTS_US_Call_Credit__c WHERE  
                                                       ZTS_EU_Account_Position__c IN :accTeamsIds AND ZTS_US_Call__c IN :submittedCallIds];  
        
        System.debug('Existing call list '+ existing_ccr_List );
        
        /** CREATE EXISTING CALLCREDIT KEY SET FOR ACC TEAMS **/                           
        Set<String> ccrKeySet=new Set<String>();
        for(ZTS_US_Call_Credit__c ccr:existing_ccr_List){
            if(ccr.ZTS_US_Call__c!=null && ccr.ZTS_EU_Account_Position__c!=null){
                ccrKeySet.add(ccr.ZTS_US_Call__c+':'+ccr.ZTS_EU_Account_Position__c);
            }
            
        }
        
        
        for(Call__c call:calls){
            system.debug('map value callWithColleaguesMap ===> '+ callWithColleaguesMap);
            if(call.ZTS_EU_Status__c==ZTS_EU_GlobalConstants.CALL_STATUS_COMPLETED){
                /** EXCLUDE CREATING DUPLICATE CALL CREDIT RECORDS **/
                for(ZTS_EU_Colleague__c col:callWithColleaguesMap.get(call.id).Colleagues__r){
                    String ACC_USR_KEY=call.ZTS_EU_Account__c+':'+col.ZTS_EU_User__c;
                    
                    System.debug('ACC_USR_KEY' + ACC_USR_KEY);
                    
                    if(acc_team_usr_map.containsKey(ACC_USR_KEY)){
                        ZTS_EU_Account_Position__c acctm=acc_team_usr_map.get(ACC_USR_KEY)[0];
                        String crrKey=call.id+':'+acctm.id;
                        if(!ccrKeySet.contains(crrKey)){
                            //set CallEnd Datetime to Calculate Last Call Date Rollup in Account Teams
                            DateTime callSubmitDt=call.ZTS_EU_Submitted_Date__c;
                            DateTime callActivityDt=call.ZTS_EU_Start_Date_Time__c;
                            ccrToInsert.add(new ZTS_US_Call_Credit__c(ZTS_US_Call__c=call.id,
                                                                      ZTS_EU_Account_Position__c=acctm.id,
                                                                      Call_Submitted_Date__c=callSubmitDt,
                                                                      ZTS_Call_Activity_Date__c=callActivityDt)
                                            
                                           );
                        }
                    }    
                }
            }
            
        }
        
        List<Database.SaveResult> results=Database.insert(ccrToInsert,false);
    }
    /***********
* Method name  : setCallTerritory
* Description  : populate Call Territory Name from Call Owner assigned User territory.
* Return Type  : void.
* Parameters   : Inserted/Updated Calls.
***********/
    public static void setCallTerritory(List<Call__c> calls){
        Set<Id> callOwnerIds=new Set<Id>();
        Set<Id> accIds=new Set<Id>();
        //Calls without territory to update
        List<Call__c> updateCallList=new List<Call__c>();
        
        List<string> callowneridlist = new list<string>();
        List<string> accountidlist =  new list<string>();
        for(Call__c call:calls) {
            if(call.ZTS_US_Call_Territory__c==null){
                String callOwnerId=call.ZTS_EU_Call_Owner__c!=null?call.ZTS_EU_Call_Owner__c:call.CreatedById;
                callowneridlist.add(callOwnerId);
                System.debug('*********callowneridlist ********'+callowneridlist);
                String accId =  call.ZTS_EU_Account__c;
                accountidlist.add(accId);    
                
            }}
        
        
        //SC-010018/TPDEV -332 - Update the logic around Call Territory ID 
        map<String,string> utmap = new map<string,string>();
        Set<ID>callOwnerNoAp = new set<ID>();
        Set<Id>userIds = new Set<Id>();
        
        //First check at the rescpective Account Positions
        List<ZTS_EU_Account_Position__c> accPosList = [SELECT Id,ZTS_EU_Account__c, ZTS_Employee_ID__c, Name, ZTS_EU_Territory__c  
                                                       FROM ZTS_EU_Account_Position__c 
                                                       WHERE ZTS_EU_Account__c IN :accountidlist AND ZTS_Employee_ID__c IN : callowneridlist and ZTS_EU_Position__r.ZTS_PrimaryUser__c = true ];
        for(ZTS_EU_Account_Position__c ut1 : accPosList){
            if(!utmap.containsKey(ut1.ZTS_Employee_ID__c)){
                utmap.put(ut1.ZTS_Employee_ID__c,ut1.ZTS_EU_Territory__c);
               
            }
        }
        
        
        
        //If call owner dont have APs, look at the Primary Positions
        for(String callOwner: callowneridlist){
            if(!utmap.containsKey(callOwner))
                callOwnerNoAp.add(callOwner);
        }
        if(callOwnerNoAp.size()>0){
            String str1 =  'SELECT id,ZTS_EU_Territory__r.Name,ZTS_EU_Territory__c,ZTS_PrimaryUser__c, ZTS_EU_Employee__c from ZTS_EU_Position__c where ZTS_EU_Employee__c IN : callOwnerNoAp and ZTS_PrimaryUser__c=true'; 
            List<ZTS_EU_Position__c> userPos = Database.query(str1);
            for(ZTS_EU_Position__c pos: userPos){
                if(!utmap.containsKey(pos.ZTS_EU_Employee__c)){
                    utmap.put(pos.ZTS_EU_Employee__c,pos.ZTS_EU_Territory__r.Name);
                 
                }
            }
            
            
            
            //If call owner dont have APs and Primary Positions
            for(String callOwner: callowneridlist){
                if(!utmap.containsKey(callOwner))
                    userIds.add(callOwner);
            }
            if(userIds.size()>0){
                String str2 = 'SELECT id,name,territory__c from user where id IN: userIds AND isActive = true AND territory__c <> NULL';
                List<User> userTerr = Database.query(str2);
                for(User ut :userTerr){
                    if(!utmap.containsKey(ut.id))
                        utmap.put(ut.id,ut.Territory__c);
                }
            }
        }
        
        
        for(Call__c call:calls) {
            if(call.ZTS_US_Call_Territory__c==null){
                String callOwnerId=call.ZTS_EU_Call_Owner__c!=null?call.ZTS_EU_Call_Owner__c:call.CreatedById;
                if(utmap.containskey(callOwnerId)) // TPDEV-332: if it either has an AP/P/Users
                    updateCallList.add(new Call__c(Id=call.id,ZTS_US_Call_Territory__c= utmap.get(callOwnerId)));
                else // TPDEV-332: When it's still not present at the User records, stamp Null
                    updateCallList.add(new Call__c(Id=call.id,ZTS_US_Call_Territory__c=null));
            }
        }
        
        if(!updateCallList.isEmpty())  {
            List<Database.Saveresult> results=Database.update(updateCallList,true);
            ZTS_EU_Logger.error(results, 'CallUtils-setCallTerritory');
        }                  
    }
}