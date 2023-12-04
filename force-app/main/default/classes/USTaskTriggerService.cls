/********************************************************
@class      USTaskTriggerService
@brief      Service class for Task Trigger functionality 

@revision   02-05-2020  Mohamed Seliman
Created.

@copyright  (c)2020, Zoetis
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     02-05-2020   Mohamed Seliman      Revised the class.
* 1.1     06-09-2022   Aritra Chakraborty   updated "afterInsert" method email send action, won't send email for Small Animal Profile Users (SC-009405)
**********************************************************/

public without sharing class USTaskTriggerService 
{  
    
    @testVisible static final String AFTER_UPDATE_ORIGIN_TYPE = 'USTaskTriggerService - afterUpdate: updating related cases';
    public static void beforeUpdate(List<Task> triggerOld, Map<Id, Task> triggerOldMap, List<Task> triggerNew, Map<Id, Task> triggerNewMap)
    {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true limit 1];
        
        for(TASK Tasktracking : triggerNew){
            Double milliseconds = BusinessHours.diff(bh.Id, Tasktracking.CreatedDate, Tasktracking.lastmodifieddate);   
            Tasktracking.ZTS_US_SER_Business_Hour_Duration__c = (Decimal.valueOf(milliseconds)).Divide((60*60*1000), 2);
        }
        
        
        for (Task mywaitingtask : triggerNew){
            Task oldTask = triggerOldMap.get(mywaitingtask.id);  
            boolean oldstatus = oldTask.status.equals('Waiting on customer');   
            if (mywaitingtask.status !='Waiting on customer' && oldstatus ){
                
                mywaitingtask.dummy__c =0; mywaitingtask.ZTS_US_TASK_Waiting_Hour_Duration__c =0;
                
                if (mywaitingtask.ZTS_US_TASK_Waiting_Start_Time__c <> null && mywaitingtask.ZTS_US_TASK_Waiting_End_Time__c <> null){
                    Double milliseconds = BusinessHours.diff(bh.Id, mywaitingtask.ZTS_US_TASK_Waiting_Start_Time__c,mywaitingtask.ZTS_US_TASK_Waiting_End_Time__c);
                    //mywaitingtask.dummy__c = mywaitingtask.ZTS_US_TASK_Waiting_Hour_Duration__c;
                    mywaitingtask.ZTS_US_TASK_Waiting_Hour_Duration__c =  (Decimal.valueOf(milliseconds)).Divide((60*60*1000), 2);
                    //mywaitingtask.dummy__c = mywaitingtask.ZTS_US_TASK_Waiting_Hour_Duration__c;
                    if (mywaitingtask.total__c == null) mywaitingtask.total__c =0;
                    mywaitingtask.dummy__c = triggerOldMap.get(mywaitingtask.id).total__c;
                    //mywaitingtask.dummy__c = mywaitingtask.ZTS_US_TASK_Waiting_Hour_Duration__c + mywaitingtask.dummy__c;
                    if (mywaitingtask.dummy__c == null) mywaitingtask.dummy__c =0;
                    
                    mywaitingtask.total__c = mywaitingtask.ZTS_US_TASK_Waiting_Hour_Duration__c + mywaitingtask.dummy__c;
                    
                }
            }
        }
    }
    
    public static void afterInsert(List<Task> triggerNew, Map<Id, Task> triggerNewMap)
    {
        String call_prefix = Schema.SObjectType.Call__c.getKeyPrefix();
        String case_prefix = Schema.SObjectType.Case.getKeyPrefix(); 
        List<Task> tasks = [select id,owner.email,owner.name,OwnerId,Owner.Profile.Name, Account.Name,whatId,ActivityDate,Priority,Subject,ZTS_US_SER_AutoCreated__c,ZTS_US_SER_Manager_Email__c from Task where id In:triggerNew ];//SC-009405 - Added Task Owner Profile Name field in Query
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Id> whatIds = new List<Id>();
        
        for(Task t0 : tasks){
            
            if(t0.whatid==null){
                return;
            }
            if(((String)t0.WhatId).startsWith(call_prefix)&&UserInfo.getUserId()!=t0.OwnerId && !(t0.Owner.Profile.Name.contains('Small Animal'))){ //SC-009405 - Added Task Owner Profile Name filter
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); // new mail object
                
                mail.setSaveAsActivity(false);
                mail.setWhatId(t0.WhatId);
                mail.setSubject('Action Required: Account Call Follow Up Has Been Assigned to You');
                List<String> sendTo = new List<String>();           
                sendTo.add(t0.owner.email); 
                String email = t0.owner.email;
                mail.setToAddresses(sendTo);
                String displayDate;
                if(t0.ActivityDate!=null){
                    displayDate = t0.ActivityDate.format();
                }
                mail.setHtmlBody('<b>'+t0.owner.name+'</b>'+
                '</br></br>'+Userinfo.getName()+' has created a follow up action for you after their interaction with '+ t0.account.name+':</br></br>'+
                t0.subject+'</br></br>Priority:'+t0.Priority+'</br>Due Date:'+displayDate+'</br></br> Please click on the link below to see this follow up in TouchPoint and be sure to mark this as Complete once you have finished the task.</br></br>'+
                '<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+t0.id+'">'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+t0.id+'</a>');
                
                emails.add(mail);
            }
            
            // update "Task Created" in Case
            if(t0.ZTS_US_SER_AutoCreated__c && ((String)t0.WhatId).startsWith(case_prefix)){
                whatIds.add(t0.WhatId);
            }
            if(!t0.ZTS_US_SER_AutoCreated__c && ((String)t0.WhatId).startsWith(case_prefix)){
                whatIds.add(t0.WhatId);
            }
        }
        Messaging.sendEmail(emails);  //send emails
            
        //update "Task Created" in Case
        if(!whatIds.isEmpty()){
            List<case> cases = [Select ZTS_US_SER_Task_Created__c  from Case where  id IN :whatIds]; //status !='Closed' and
              
            if(!cases.isEmpty()){
                for(Case c:cases){
                    c.ZTS_US_SER_Task_Created__c = true;
                    c.ZTS_US_SER_Open_Tasks__c = true;
                }
                //try{
                	//update cases;
                    List<Database.Saveresult> results=Database.Update(Cases,false);
       			    ZTS_EU_Logger.error(results, 'USTaskTriggerService-afterInsert');
               //}
               // catch(DMLException e){
                 //   ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'USTaskTriggerService-afterInsert');
                    //System.debug('Exception occurred' +e.getMessage());
               // } 
            }
        }
    }
        
        public static void afterUpdate(List<Task> triggerOld, Map<Id, Task> triggerOldMap, List<Task> triggerNew, Map<Id, Task> triggerNewMap)
        {
            Set <ID> caseIDs = new Set <ID> ();
            List<Id> caseList = new List<Id>();
            Map<Id,String> caseManagerMap = new Map<Id,String>();
            String case_prefix = Schema.SObjectType.Case.getKeyPrefix(); 
            
            for (Task t: triggerNew){
                IF (T.WHATID !=NULL){ //KAUSHIK ADDED TO CHECK IF WHATID IS NOT NULL 10.05.2017;
                    if(((String)t.WhatId).startsWith(case_prefix)){
                        string whatid = t.WhatId;
                        if (t.status=='Completed' || t.status =='Acknowledged, No Action')
                        caseIDs.add(t.WhatId);
                    }
                } //END..KAUSHIK ADDED TO CHECK IF WHATID IS NOT NULL  10.05.2017;
            }
            
            List<Case> cases = [select recordtypeid from case where id in :caseIDs];
            for(Case c:cases){
                if(ZTS_US_SER_AutoCaseClosureOnTaskClosure__c.getAll().KeySet().contains(Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getname())){
                    caseList.add(c.Id);
                }
            }
            
            List <Task> AllTaskList = [select ID,Status,whatid from Task where whatid in :caseList];
            Map <id,List <task>> CaseTaskIdsMap = new Map <id,List <task>>();
            list <task> TList;
            Case CaseObj; Case mycase;
            List <Case> CaseToUpdate = new List<case>();
            boolean AllCompleted;
            //To create map with key as case id and value as related tasks
            for (Task t:AllTaskList){
                if(CaseTaskIdsMap.containsKey(t.WhatId)){
                    TList = new list<task>();
                    TList = CaseTaskIdsMap.get(t.WhatId);
                    Tlist.add(t);
                    CaseTaskIdsMap.put(t.WhatId, Tlist);
                }else{
                    TList = new list<task>();
                    Tlist.add(t);
                    CaseTaskIdsMap.put(t.WhatId, Tlist);
                }
            }
            //loop case to get the related task
            for(id c :caseList){
                //loop task to check the status
                AllCompleted = false;
                for(task t1 :CaseTaskIdsMap.get(c)){
                    if(t1.status =='Acknowledged, No Action' || t1.status =='Completed')
                    AllCompleted = true;
                }
                //if we get all task as completed then update the case status
                
                //if (!AllCompleted){
                    // mycase = new Case();
                    // mycase.ZTS_US_SER_Open_Tasks__c = True;
                    // CaseToUpdate.add(mycase); 
                    // } 
                    
                    
                    if(AllCompleted){
                        CaseObj = new case();
                        CaseObj.Id = c;
                        CaseObj.Status='Closed';
                        CaseObj.ZTS_US_Customer_Reaction_on_Case_Closure__c='Neutral';
                        CaseObj.ZTS_US_SER_Open_Tasks__c = False;
                        CaseToUpdate.add(CaseObj);
                    }
                }
                
                try{
                    if(CaseToUpdate.size()>0)
                    update CaseToUpdate;
                }
                catch(DmlException dex){
                    String errorMessages = '';
                    for (Integer i = 0; i < dex.getNumDml(); i++) {
                        System.debug(AFTER_UPDATE_ORIGIN_TYPE);
                        System.debug('DML Message: ' + dex.getDmlMessage(i));
                        errorMessages += dex.getDmlMessage(i) + '\n';
                    }
                    errorMessages.removeEnd('\n');
                    ZTS_EU_Logger.notify = true;
                    ZTS_EU_Logger.error(errorMessages,null, AFTER_UPDATE_ORIGIN_TYPE);
                }		
                
            }
        }