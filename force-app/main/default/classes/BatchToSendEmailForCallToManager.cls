/**
 * @description       : Batch Class to email managers when their subordinates Calls are submitted.
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 08-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-22-2022   Unknown                     Initial Version with single tests
 * 1.1   08-08-2022   Ethan Hirsch @ Zoetis Inc   Add abilitiy to overwrite the Start Query with User Ids in a Unit Test
**/
global class BatchToSendEmailForCallToManager implements database.Batchable<sObject>, Database.Stateful{
global BusinessHours bh;
global List<OrgWideEmailAddress> owea;
global EmailTemplate managerEmailTemp;
@testVisible private static List<User> testUsers;

//start method
global Database.QueryLocator start(Database.BatchableContext BC){
    bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true LIMIT 1];
    owea = [select Id from OrgWideEmailAddress where Address = 'noreply@zoetis.com' LIMIT 1];
    managerEmailTemp = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Notification_to_manager_regarding_rep_s_call'];
    Set<String> territoryNameSet = new Set<String>();
    territoryNameSet.addAll(BuildQueryString.getTerritoryNameSet());
    String queryString = '';
    queryString += 'SELECT Id FROM User WHERE Territory__c IN : territoryNameSet AND IsActive = true';
    queryString += ' AND Manager_Call_Reminder_Scheduled_Date__c = TODAY';
    
    if (Test.isRunningTest() && testUsers != null) {
        queryString += ' AND Id in: testUsers';
    }

    return Database.getQueryLocator(queryString);
}

//execute method
global void execute(Database.BatchableContext BC, List<User> userList){
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    Map<Id, User> userMap = new Map<Id, User>();
    List<String> userEmailList;
    List<user> updateuserlist = new List<user>();
    
    for(User usr : [SELECT Id, Name, Manager.FirstName, Manager.Email,
                    (SELECT ZTS_EU_Submitted_Date__c FROM Calls__r
                     WHERE ZTS_EU_Submitted_Date__c !=null AND ZTS_EU_Call_Owner__c != null
                     ORDER BY ZTS_EU_Submitted_Date__c desc LIMIT 1) FROM User
                   WHERE Id IN : userList AND Id IN (SELECT ZTS_EU_Call_Owner__c FROM Call__c)])
    {
        if(usr.calls__r.size() > 0){
            Long submittedDateDiff=BusinessHours.diff(bh.id, usr.Calls__r[0].ZTS_EU_Submitted_Date__c, DateTime.now())/(1000*60*60*9);
            
            if(submittedDateDiff > 5 ){
                userMap.put(usr.Id, usr);
            } else{
                user udetails=new user();
                udetails.Id=usr.Id;
                udetails.Manager_Call_Reminder_Scheduled_Date__c=null;
                updateuserlist.add(udetails);
            }
        }
        
    }
      
    for(Id notifyUserId : userMap.keySet()){  
    Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
     String plainBody = managerEmailTemp.Body;
   try{
       
        plainBody = plainBody.replace('{!User.Manager}', userMap.get(notifyUserId).Manager.FirstName);
        plainBody = plainBody.replace('{!User.Name}', userMap.get(notifyUserId).Name);  
      }Catch(System.NullPointerException e){}
        //Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        userEmailList = new List<string>{userMap.get(notifyUserId).Manager.Email};
        emailMsg.setToAddresses(userEmailList);
        emailMsg.setOrgWideEmailAddressId(owea.get(0).Id);
        emailMsg.setSaveAsActivity(false);
        emailMsg.setTargetObjectId(userMap.get(notifyUserId).Manager.id);
        emailMsg.setPlainTextBody(plainBody);

   
        emailMsg.setTemplateID(managerEmailTemp.Id);

        if (owea != null) {
            emailMsg.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        emailList.add(emailMsg);
                       
      
}
    
    //send email to the list of users reminding to submit calls
    if(!emailList.isEmpty()) {
        try{
        System.debug('emails sent'+emailList);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            
            //update the reminder sent and manager reminder schedule dates once the email has been sent successfully
            if(results[0].success){
                for(Id userId : userMap.keySet()) {
                    User usr = new User();
                    usr.Id = userId;
                    usr.Manager_Call_Reminder_Sent_Date__c= Date.today();
                    updateuserlist.add(usr);
                }
                
            }
        }
        catch (Exception ex) {
            system.debug('Unable to send email : '+ ex.getStackTraceString());
        }
    }
    if(!updateuserlist.isEmpty()){
        update updateuserlist;
    }
    
}

//finish method    
global void finish(Database.BatchableContext BC){
    //finish logic
}
}