/*************************************************************************************
* Name          :    VmipsCaseTriggerHandler.
* Description   :    Class to assign task and send email to an user for Vmips Cases.
* Author        :    Laxmikanth(CloudSense)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
4/9/2015       Laxmikanth(CloudSense)            Created
08/28/2017     Abir Bhattacharya(Cognizant)      Commented code for generating Tasks(SC-002360)

**************************************************************************************/

public class VmipsCaseTriggerHandler{

  public static void sendEmail(List<ZTS_US_VMIPS_Case__c> vmips,Map<Id,ZTS_US_VMIPS_Case__c> vmipsold){
    Set<Id> accIds=new Set<Id>();
    for(ZTS_US_VMIPS_Case__c vmpscase:vmips){
          accIds.add(vmpscase.ZTS_US_Vmips_Account__c);
     }  
 Id userids;
 List<User> users = new List<User>();
 //Commented to restrict tasks getting created(SC-002360)
 //List<Task> newTaskList=new List<Task>();
   
 List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();  
 Set<String> acc_position_uniq_key=new Set<String>();
// Map<Id,Account> acc_map=new Map<Id,Account>([SELECT Id,Name,(SELECT ZTS_US_Account__c,ZTS_US_Species__c,ZTS_US_SIB_Flag__c,ZTS_US_Employee_ID__c,ZTS_US_NotificationUser__c,ZTS_US_UserTerritory__r.ZTS_US_Employee__r.PIT_Coaching_Group__c,ZTS_US_UserTerritory__r.ZTS_US_Employee__r.isActive,ZTS_US_NotificationUser__r.PIT_Coaching_Group__c,ZTS_US_NotificationUser__r.IsActive FROM Account_Positions__r) FROM Account WHERE Id IN :accIds]);
  Map<Id,Account> acc_map=new Map<Id,Account>([SELECT Id,Name,(SELECT ZTS_EU_Account__c , ZTS_Species__c, ZTS_SIB_Flag__c,ZTS_EU_Employee_Id__c  ,ZTS_NotificationUser__c ,ZTS_NotificationUser__r.PIT_Coaching_Group__c,ZTS_NotificationUser__r.IsActive FROM Account_Positions__r) FROM Account WHERE Id IN :accIds]);      
      OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'VMIPS Case Alert'];   
        //get all the associated account position for account
        for(ZTS_US_VMIPS_Case__c advEvnt:vmips){
           if(advEvnt.ZTS_US_Vmips_Account__c!=vmipsold.get(advEvnt.id).ZTS_US_Vmips_Account__c&&advEvnt.ZTS_US_Vmips_Account__c!=null&&advEvnt.ZTS_US_Case_Type__c == 'Animal Complaint'){
                 for(ZTS_EU_Account_Position__c  acc_pos:acc_map.get(advEvnt.ZTS_US_Vmips_Account__c).Account_Positions__r){
                       
             
                       if((acc_pos.ZTS_Species__c  == advEvnt.ZTS_US_Species_Group__c)&&(acc_pos.ZTS_SIB_Flag__c )== TRUE){
                           
                           String cgrp = acc_pos.ZTS_NotificationUser__r.PIT_Coaching_Group__c;
                           Boolean activeuser = acc_pos.ZTS_NotificationUser__r.IsActive;
                             System.debug('***cgrp***'+cgrp);
                             
                           If((acc_pos.ZTS_EU_Employee_ID__c!=null)&&(cgrp=='TBM'||cgrp=='SAM')&&activeuser==true){ 
                                //Commented to restrict tasks getting created(SC-002360)
                                /*Task tsk=new Task(Subject =ZTS_US_GlobalConstants.VMIPS_CASE_TASK_SUBJ_PRETEXT+acc_map.get(advEvnt.ZTS_US_Vmips_Account__c).name , OwnerId=acc_pos.ZTS_US_Employee_ID__c ,                                  Priority=ZTS_US_GlobalConstants.VMIPS_CASE_TASK_PRIORITY,                                  Description=advEvnt.ZTS_US_Description__c,WhatId=advEvnt.id,ActivityDate=Date.today(),                                  ZTS_US_Type__c=ZTS_US_GlobalConstants.VMIPS_CASE_TASK_TYPE);
                              
                                  newTaskList.add(tsk);*/       
                                  
                                    
                                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); // new mail object
                                  List<String> CcTo = new List<String>();
                                  //CCto.add('daniel.shaheen@zoetis.com');
                                  //CCto.add('dshaheen@salesforce.com');
                                  //mail.setSenderDisplayName('Zoetis Admin');
                                  mail.setSaveAsActivity(false);
                                  //mail.setCcAddresses(CcTo);
                                  if ( owea.size() > 0 ) {
                                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                                    }    
                                  //mail.setWhatId(vmipscase.id);
                                  mail.setSubject('VMIPS Case Notification for '+advEvnt.ZTS_US_Account_Name__c);
                                  mail.setTargetObjectId(acc_pos.ZTS_NotificationUser__c); //target to receipient
                                  //String messagebody= '<HTML><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+advEvnt.id+'">'+advEvnt.Name+'</a></HTML>';
                                  String Link='VMIPS CASE';
                                  mail.setHtmlBody('Zoetis has been contacted by one of your customers '+
                                                    'who reported a suspected adverse event to a Zoetis product.'+  
                                                    'The details of the report are listed below.'+'</br></br>Case Number:<b>'+advEvnt.Name+
                                                    '</b></br></br>Date Received:<b>' +advEvnt.ZTS_US_Date_First_Received__c+
                                                    '</b></br></br>Case Owner:<b>' +advEvnt.ZTS_US_Case_Owner__c+
                                                    '</b></br></br>Account:<b>' +advEvnt.ZTS_US_Account_Name__c+
                                                    '</b></br></br>Species:<b>'+advEvnt.ZTS_US_Species_Group__c+
                                                    '</b></br></br>History:<b>' +advEvnt.ZTS_US_Response_Summary__c+
                                                    '</b></br></br>Comments:<b>' +advEvnt.ZTS_US_Comments__c+
                                                    '</b></br></br>Click on the link below to view more details about this case.</br>'+'</b></br>A task for this case will also appear on your TouchPoint Homepage as a reminder. You can click on the “x” to Complete the task once you’ve reviewed the case to remove it from the list.</br>'
                                                    +'<a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+advEvnt.id+'">'+Link+'</a>'
                                                    +'</br></br>'+'CONFIDENTIALITY NOTICE - This message may contain privileged and confidential information. Emails regarding VMIPS cases are for INTERNAL use only ' 
                                                    +'and should only be forwarded to Zoetis colleagues on a need to know basis as a means of communication on the case.'
                                                    +' Emails should not be forwarded to producers or veterinarians.');
                                   //mail.setTemplateId(et.id);           // pull the email template through id
                                   emails.add(mail);
                                     
                                     
                                  }
                                }
                             }  
                         
                        }
                      
                   }
        //System.debug('no.of tasks'+newTaskList.size());           
       System.debug('no.of emails'+emails.size());
    Messaging.sendEmail(emails);  //send single email
    //Commented to restrict tasks getting created(SC-002360)
    /*if(!newTaskList.isEmpty()){
            try{
                List<Database.Saveresult> results=Database.insert(newTaskList);
                //ZTS_US_Logger.error(results, 'VMIPSCaseTriggerHandler');
            }catch(Exception ex){
               //ZTS_US_Logger.notify=false;
               ZTS_US_Logger.error('VMIPSCaseTriggerHandler.sendEmail '+ex.getMessage(), null, 'Apex');
          
            }
    }*/    
  }
}