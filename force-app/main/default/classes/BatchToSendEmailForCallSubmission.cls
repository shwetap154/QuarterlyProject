/**
 * @description       : Send email to Call Users reminding them to Submit their Calls
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 07-27-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-22-2021   Unknown                      Initial Version
 * 1.1   07-27-2022   Ethan Hirsch @ Zoetis Inc    Make testUserId a private static testvisible variable
**/
global class BatchToSendEmailForCallSubmission implements database.Batchable<sObject>, Database.Stateful{
    global BusinessHours defaultBusinessHours;
    global OrgWideEmailAddress orgWideEmail;
    global EmailTemplate emailTemp;
    @testVisible private static Id testUserId;
    // start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault=true LIMIT 1];
        orgWideEmail = [select Id from OrgWideEmailAddress where Address = 'noreply@zoetis.com' LIMIT 1];
        emailTemp = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Notification_to_submit_call'];
        Set<String> territoryNameSet = new Set<String>();
        territoryNameSet.addAll(BuildQueryString.getTerritoryNameSet());
        String queryString = 'SELECT Id,Territory__c FROM User WHERE Territory__c IN : territoryNameSet AND IsActive = true';
        if (Test.isRunningTest()) {
            queryString += ' AND Id = \''+ testUserId + '\'';
        }
        system.debug('queryString = '+queryString);
        return Database.getQueryLocator(queryString);
    }
    
    // execute method
    global void execute(Database.BatchableContext BC, List<User> userList){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id, User> userMap = new Map<Id, User>();
        List<String> userEmailList;
        
        for(User usr : [SELECT Id, Name, Email, Call_Reminder_Sent_Date__c,
                        (SELECT Id, Name, ZTS_EU_Submitted_Date__c FROM Calls__r
                         WHERE ZTS_EU_Submitted_Date__c !=null AND ZTS_EU_Call_Owner__c != null
                         ORDER BY ZTS_EU_Submitted_Date__c desc LIMIT 1) FROM User
                        WHERE Id IN : userList AND Id IN (SELECT ZTS_EU_Call_Owner__c FROM Call__c)
                       ])
        {
            if(usr.Calls__r.size() > 0){
                Long reminderDateDiff, submittedDateDiff;
                submittedDateDiff=BusinessHours.diff(defaultBusinessHours.id, usr.calls__r[0].ZTS_EU_Submitted_Date__c, DateTime.now());
                submittedDateDiff=submittedDateDiff/(1000*60*60*9);
                
                if(usr.Call_Reminder_Sent_Date__c != null){
                    reminderDateDiff=BusinessHours.diff(defaultBusinessHours.id, usr.Call_Reminder_Sent_Date__c, DateTime.now());
                    reminderDateDiff=reminderDateDiff/(1000*60*60*9);
                }
                
                if(submittedDateDiff > 5 && (usr.Call_Reminder_Sent_Date__c == null || reminderDateDiff > 15)){
                    userMap.put(usr.Id, usr);
                }
            }
        }
        
        //Query for ToT records and exclude the user from the emailList if he/she has ToT in last 5 business days
        for(Time_Out_of_Territory__c tot : [SELECT Id, ZTS_EU_Start_Date__c, ZTS_EU_End_Date__c, OwnerId
                                            FROM Time_Out_of_Territory__c
                                            WHERE OwnerId IN : userMap.keySet() AND
                                            ZTS_EU_Start_Date__c != null AND
                                            ZTS_EU_End_Date__c != null AND
                                            (
                                                ZTS_EU_Start_Date__c = LAST_N_Days:7
                                                OR
                                                ZTS_EU_End_Date__c = LAST_N_Days:7
                                            )
                                           ])
        {
            Long startSubmittedDateDiff, todayEndDateDiff, businessDaysCount;
            startSubmittedDateDiff = BusinessHours.diff(defaultBusinessHours.id, userMap.get(tot.OwnerId).Calls__r[0].ZTS_EU_Submitted_Date__c, tot.ZTS_EU_Start_Date__c)/(1000*60*60*9);
            todayEndDateDiff = BusinessHours.diff(defaultBusinessHours.id, tot.ZTS_EU_End_Date__c, Date.today())/(1000*60*60*9);
            businessDaysCount = startSubmittedDateDiff + todayEndDateDiff;
            if(businessDaysCount < 7){
               userMap.remove(tot.OwnerId);
            }
        }
        
        for(Id notifyUserId : userMap.keySet()){
            //Draft email message if the user doesn't have ToT in last 5 business days
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            String plainBody = emailTemp.Body;
            plainBody = plainBody.replace('{!User.Name}', userMap.get(notifyUserId).Name);
            userEmailList = new List<string>{userMap.get(notifyUserId).Email};
            emailMsg.setToAddresses(userEmailList);
            emailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);
            emailMsg.setSaveAsActivity(false);
            emailMsg.setTargetObjectId(notifyUserId);
            emailMsg.setTemplateID(emailTemp.Id);
            emailMsg.setPlainTextBody(plainBody);
            if (orgWideEmail != null) {
                emailMsg.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            emailList.add(emailMsg);
        }
        
        //send email to the list of users reminding to submit calls
        if(!emailList.isEmpty()) {
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                
                //update the reminder sent and manager reminder schedule dates once the email has been sent successfully
                if(results[0].success){
                    system.debug('email sent to'+emailList);
                    List<User> updateUsersList = new List<User>();
                    for(String userId : userMap.keySet()) {
                        User usr = new User();
                        usr.Id = userId;
                        usr.Call_Reminder_Sent_Date__c = Date.today();
                        usr.Manager_Call_Reminder_Scheduled_Date__c = Date.today().addDays(7);
                        updateUsersList.add(usr);
                        }
                    
                    if(!updateUsersList.isEmpty()){
                        Database.update(updateUsersList,false);
                    }
                }
            }
            catch (Exception ex) {
                system.debug('Unable to send email : '+ ex.getStackTraceString()+'message '+ex.getMessage()+'cause '+ex.getCause());
            }
        }
    }
    
    //finish method    
    global void finish(Database.BatchableContext BC){
        //finish logic
    }
}