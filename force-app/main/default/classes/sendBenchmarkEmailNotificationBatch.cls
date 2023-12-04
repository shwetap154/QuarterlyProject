/*
Class Name	    : sendBenchmarkEmailNotificationBatch
Description	    : Batch class to send Benchmark Email Notifications. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 03-27-2023

Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	03-27-2023   Initial version of batch class to send Benchmark Email Notifications.
02   Raut, Pranav Krushnarao	06-05-2023   TPDEV-798 - Added the code in order to sends out all emails if the date to send them has past, but the manager has not received the email
03   Padma, Nerella             10-10-2023   TPDEV-2082 - Added userIdsSet to minimize the users to run the test class and to handle null pointer exception on line 72.
*/
global class sendBenchmarkEmailNotificationBatch implements database.Batchable<sObject>, Database.Stateful {
    
    
    Set<String> setMarket = new Set<String>();
    Map<String,iDevelop_Configuration__c> mapMarktRoleIdevConfig = new Map<String,iDevelop_Configuration__c>();        
    Map<String,Date> mapIdevMarketRoleBenchDueDate = new Map<String,Date>();
    Map<String, iDevelop_Configuration__c> mapIdevConfigWithNoRole = new Map<String, iDevelop_Configuration__c>();        
    Map<String,Date> mapIdevWithNoRoleBenchDueDate = new Map<String,Date>();
    String strCoacheePemisnSet = 'iDevelop_Coachee'; 
    String newBechmarkTemplateName = System.Label.TemplateName_New_iDevelop_Benchmark_Coach_Notification;
    String newTenDaysPriorDueDateTemplateName = System.Label.TemplateName_Ten_Days_Prior_to_Due_Date_No_Benchmark;
    String newOneDayBeforeDueDateTemplateName = System.Label.TemplateName_One_Day_before_Benchmark_Due_Date_No_Benchmark;
    String newOneWeekAfterDueDateTemplateName = System.Label.TemplateName_One_Week_After_Benchmark_Due_Date_No_Benchmark;
    Id orgWideId = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Zoetis'].Id;
    @testVisible private static Set<Id>testUserIdsSet = new Set<Id>();
    
    //Constructor
    public sendBenchmarkEmailNotificationBatch(Set<String> setMarket, Map<String,iDevelop_Configuration__c> mapMarktRoleIdevConfig, Map<String,Date> mapIdevMarketRoleBenchDueDate, Map<String, iDevelop_Configuration__c> mapIdevConfigWithNoRole, Map<String,Date> mapIdevWithNoRoleBenchDueDate){
        this.setMarket = setMarket;
        this.mapMarktRoleIdevConfig = mapMarktRoleIdevConfig;
        this.mapIdevMarketRoleBenchDueDate = mapIdevMarketRoleBenchDueDate;
        this.mapIdevConfigWithNoRole = mapIdevConfigWithNoRole;
        this.mapIdevWithNoRoleBenchDueDate=mapIdevWithNoRoleBenchDueDate;   
    }
    
    // start method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string queryString = 'SELECT Id,Name,Last_Coach_Benchmark_Started_Date__c,ZTS_EU_Market__c,PIT_Coaching_Group__c,Next_Coach_Benchmark_Due_Date__c,ManagerId,Manager.Email,Manager.Manager.Email,LanguageLocaleKey,Last_Sent_New_Benchmark_Notification__c,Last_Sent_10_Days_Prior_Benchmark_Date__c,Last_Sent_1_Day_Before_Benchmark_DueDate__c,Last_Sent_1_Week_After_Benchmark_DueDate__c FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =: strCoacheePemisnSet ) AND IsActive=true AND ZTS_EU_Market__c IN : setMarket ';
        if (Test.isRunningTest()) {
            if(testUserIdsSet != null && testUserIdsSet.isEmpty() == false){
               queryString += ' AND ID IN:testUserIdsSet ';
            }
        }

        return Database.getQueryLocator(queryString); 
    }
    
    //execute method
    global void execute(Database.BatchableContext BC, List<User> lstUsers ){
        List<SendBetterEmailRequest> lstSendBetterEmailRequest = new List<SendBetterEmailRequest>();
        List<User> lstUserToUpdate = new List<User>();
        for(User objUser : lstUsers){   
            Boolean sendEmail = False;
            String userMarketRole = objUser.ZTS_EU_Market__c + objUser.PIT_Coaching_Group__c;  
            if(mapMarktRoleIdevConfig.containsKey(userMarketRole)){                  
                if(objUser.Last_Coach_Benchmark_Started_Date__c == null || !(objUser.Last_Coach_Benchmark_Started_Date__c >= (mapIdevMarketRoleBenchDueDate.get(userMarketRole).addYears(-1)).addMonths(8))){ 
                    //Set Next Benchmark Due Date on User
                    if(objUser.Next_Coach_Benchmark_Due_Date__c == null || (objUser.Next_Coach_Benchmark_Due_Date__c != mapIdevMarketRoleBenchDueDate.get(userMarketRole))){                        
                        objUser.Next_Coach_Benchmark_Due_Date__c = mapIdevMarketRoleBenchDueDate.get(userMarketRole); 
                        sendEmail = true;
                    }                                         
                }                   
            }
            if(!mapMarktRoleIdevConfig.containsKey(userMarketRole) && mapIdevConfigWithNoRole.containsKey(objUser.ZTS_EU_Market__c) && mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c) != null && mapMarktRoleIdevConfig.get(userMarketRole) == null){                       
                if(objUser.Last_Coach_Benchmark_Started_Date__c == null || !(objUser.Last_Coach_Benchmark_Started_Date__c >= (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c).addYears(-1)).addMonths(8))){                                                     
                    //Set Next Benchmark Due Date on User
                    if(objUser.Next_Coach_Benchmark_Due_Date__c == null || (objUser.Next_Coach_Benchmark_Due_Date__c != mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c))){                           
                        objUser.Next_Coach_Benchmark_Due_Date__c = mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c);
                        sendEmail = true;
                    }                                         
                }
            }
            if(sendEmail && objUser.ManagerId != null){
                //Send 1 Week After due date email to manager
                if((mapIdevMarketRoleBenchDueDate.get(userMarketRole) != null && System.today() >= (mapIdevMarketRoleBenchDueDate.get(userMarketRole)+7) && (objUser.Last_Sent_1_Week_After_Benchmark_DueDate__c == null || objUser.Last_Sent_1_Week_After_Benchmark_DueDate__c < (mapIdevMarketRoleBenchDueDate.get(userMarketRole)+7))) ||
                   (mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c) != null && System.today() >= (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c)+7) && (objUser.Last_Sent_1_Week_After_Benchmark_DueDate__c == null || objUser.Last_Sent_1_Week_After_Benchmark_DueDate__c < (mapIdevWithNoRoleBenchDueDate.get(userMarketRole)+7)))
                  ){
                      SendBetterEmailRequest objSendBetterEmailRequest = new SendBetterEmailRequest();        
                      objSendBetterEmailRequest.orgWideEmailAddressId = orgWideId;
                      objSendBetterEmailRequest.templateName = newOneWeekAfterDueDateTemplateName;
                      objSendBetterEmailRequest.templateLanguage = objUser.LanguageLocaleKey;
                      objSendBetterEmailRequest.templateTargetObjectId = objUser.Id; 
                      objSendBetterEmailRequest.recordId = string.valueOf(objUser.Id);
                      objSendBetterEmailRequest.SendTOthisOneEmailAddress = string.valueOf(objUser.Manager.Email);
                      objSendBetterEmailRequest.SendCCthisOneEmailAddress = string.valueOf(objUser.Manager.Manager.Email);
                      objSendBetterEmailRequest.setTreatTargetObjectAsRecipient = false;
                      lstSendBetterEmailRequest.add(objSendBetterEmailRequest);
					  
                      //Set User's Last_Sent_1_Week_After_Benchmark_DueDate__c to Today.
                      objUser.Last_Sent_1_Week_After_Benchmark_DueDate__c = System.today();
                  }
                
                //Send 1 day before due date email to manager
                else if((mapIdevMarketRoleBenchDueDate.get(userMarketRole) != null && System.today() >= (mapIdevMarketRoleBenchDueDate.get(userMarketRole)-1) && (objUser.Last_Sent_1_Day_Before_Benchmark_DueDate__c == null || objUser.Last_Sent_1_Day_Before_Benchmark_DueDate__c < (mapIdevMarketRoleBenchDueDate.get(userMarketRole)-1))) ||
                   (mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c) != null && System.today() >= (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c)-1) && (objUser.Last_Sent_1_Day_Before_Benchmark_DueDate__c == null || objUser.Last_Sent_1_Day_Before_Benchmark_DueDate__c < (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c)-1)))
                  ){
                      SendBetterEmailRequest objSendBetterEmailRequest = new SendBetterEmailRequest();        
                      objSendBetterEmailRequest.orgWideEmailAddressId = orgWideId;
                      objSendBetterEmailRequest.templateName = newOneDayBeforeDueDateTemplateName;
                      objSendBetterEmailRequest.templateLanguage = objUser.LanguageLocaleKey;
                      objSendBetterEmailRequest.templateTargetObjectId = objUser.Id; 
                      objSendBetterEmailRequest.recordId = string.valueOf(objUser.Id);
                      objSendBetterEmailRequest.SendTOthisOneEmailAddress = string.valueOf(objUser.Manager.Email);
                      objSendBetterEmailRequest.setTreatTargetObjectAsRecipient = false;
                      lstSendBetterEmailRequest.add(objSendBetterEmailRequest);
                      
                      //Set User's Last_Sent_1_Day_Before_Benchmark_DueDate__c to Today.
                      objUser.Last_Sent_1_Day_Before_Benchmark_DueDate__c = System.today();
                  }
                
                //Send 10 days prior to due date email to manager  
                else if((mapIdevMarketRoleBenchDueDate.get(userMarketRole) != null && System.today() >= (mapIdevMarketRoleBenchDueDate.get(userMarketRole)-10) && (objUser.Last_Sent_10_Days_Prior_Benchmark_Date__c == null || objUser.Last_Sent_10_Days_Prior_Benchmark_Date__c < (mapIdevMarketRoleBenchDueDate.get(userMarketRole)-10))) ||
                   (mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c) != null && System.today() >= (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c)-10) && (objUser.Last_Sent_10_Days_Prior_Benchmark_Date__c == null || objUser.Last_Sent_10_Days_Prior_Benchmark_Date__c < (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c)-10)))
                  ){    
                      SendBetterEmailRequest objSendBetterEmailRequest = new SendBetterEmailRequest();        
                      objSendBetterEmailRequest.orgWideEmailAddressId = orgWideId;
                      objSendBetterEmailRequest.templateName = newTenDaysPriorDueDateTemplateName;
                      objSendBetterEmailRequest.templateLanguage = objUser.LanguageLocaleKey;
                      objSendBetterEmailRequest.templateTargetObjectId = objUser.Id; 
                      objSendBetterEmailRequest.recordId = string.valueOf(objUser.Id);
                      objSendBetterEmailRequest.SendTOthisOneEmailAddress = string.valueOf(objUser.Manager.Email);
                      objSendBetterEmailRequest.setTreatTargetObjectAsRecipient = false;                      
                      lstSendBetterEmailRequest.add(objSendBetterEmailRequest);
                      
                      //Set User's Last_Sent_10_Days_Prior_Benchmark_Date__c to Today.
                      objUser.Last_Sent_10_Days_Prior_Benchmark_Date__c = System.today();
                  }
                
               //Send New Benchmark Notification
               else if( (mapIdevMarketRoleBenchDueDate.get(userMarketRole) != null && System.today() >= (mapIdevMarketRoleBenchDueDate.get(userMarketRole) - Integer.valueOf(mapMarktRoleIdevConfig.get(userMarketRole).Days_to_Complete__c)) && (objUser.Last_Sent_New_Benchmark_Notification__c == null || objUser.Last_Sent_New_Benchmark_Notification__c < (mapIdevMarketRoleBenchDueDate.get(userMarketRole) - Integer.valueOf(mapMarktRoleIdevConfig.get(userMarketRole).Days_to_Complete__c)) ) ) ||
                   (mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c) != null && System.today() >= (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c) - Integer.valueOf(mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c).Days_to_Complete__c)) && (objUser.Last_Sent_New_Benchmark_Notification__c == null || objUser.Last_Sent_New_Benchmark_Notification__c < (mapIdevWithNoRoleBenchDueDate.get(objUser.ZTS_EU_Market__c) - Integer.valueOf(mapIdevConfigWithNoRole.get(objUser.ZTS_EU_Market__c).Days_to_Complete__c)) ) )
                  ){
                      SendBetterEmailRequest objSendBetterEmailRequest = new SendBetterEmailRequest();        
                      objSendBetterEmailRequest.orgWideEmailAddressId = orgWideId;
                      objSendBetterEmailRequest.templateName = newBechmarkTemplateName;
                      objSendBetterEmailRequest.templateLanguage = objUser.LanguageLocaleKey;
                      objSendBetterEmailRequest.templateTargetObjectId = objUser.Id; 
                      objSendBetterEmailRequest.recordId = string.valueOf(objUser.Id);
                      objSendBetterEmailRequest.SendTOthisOneEmailAddress = string.valueOf(objUser.Manager.Email);
                      objSendBetterEmailRequest.setTreatTargetObjectAsRecipient = false;
                      lstSendBetterEmailRequest.add(objSendBetterEmailRequest);
                      
                      //Set User's Last_Sent_New_Benchmark_Notification__c to Today.
                      objUser.Last_Sent_New_Benchmark_Notification__c = System.today();
                  }   
                else{
                    //No email reminders needs to be sent 
                }
            }
            
            //Add user to User Update List
            lstUserToUpdate.add(objUser);
        }
        if(!lstUserToUpdate.isEmpty()){
            Database.update(lstUserToUpdate,false);
        }          
        if(!lstSendBetterEmailRequest.isEmpty()){
            SendBetterEmail.SendEmail(lstSendBetterEmailRequest);  
        }            
    }
    
    //finish method    
    global void finish(Database.BatchableContext BC){
        //finish logic
    }
}