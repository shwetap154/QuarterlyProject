/****************************************************************************************************************************************** 
* Class Name   : BatchToNotifyTaskDueDateBreachToDirector
* Description  : This batch job is used to send emails after 7 days of task Due date to the respective Directors if a Rep has breached due date of task. Created for US market.
               : To be run once in a week.
* Created By   : Aritra(Cognizant)
* Created Date : 21-Mar-2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      21-Mar-2022      Created this class (SC-009405)
*****************************************************************************************************************************************/
global class BatchToNotifyTaskDueDateBreachToDirector implements Database.Batchable <sObject> {
    global List<OrgWideEmailAddress> owea;
    global EmailTemplate directorEmailTemp;
    final String MARKET_CHECK  = 'United States';
    //Date startDateForChecking = date.today();
    Date startDateForChecking = date.today().addDays(-7);


    //startDateForChecking = date.today().addDays(-7);
        
   /* public String getResourceURL(String resourceName) {
        
        List<Document> resourceList = [
            SELECT Id,SystemModstamp from Document where DeveloperName =:resourceName
        ];
        
        if (resourceList.size() == 1) {
           return URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+resourceList[0].Id+'&oid='+UserInfo.getOrganizationId()+'&lastMod='+resourceList[0].SystemModstamp.getTime(); 
        } else return '';
        
    }*/
    
        
    global Database.QueryLocator start (Database.BatchableContext BC) 
    {
        
        System.debug('Inside Start method');
        Set<Id> directorIdList = new Set<Id>();
        
        List<Task> breachedTaskList = [Select DirectorUserId__c from Task where ActivityDate < :startDateForChecking and 
                                         Status !='Completed' and DueDateBreachNotifiedtoDirector__c = false 
                                         and ZTS_EU_Market__c = :MARKET_CHECK];
        System.debug('breachedTaskList -->'+ breachedTaskList);
        
        for(Task t: breachedTaskList)
        {
            directorIdList.add(t.DirectorUserId__c);
        }
        System.debug('directorIdList -->'+ directorIdList);
        return Database.getQueryLocator([Select Id,Email,Name from User where ZTS_EU_Market__c = :MARKET_CHECK and isActive = true 
                                         and Id in : directorIdList]);
    }
    
    global void execute(Database.BatchableContext BC,List<User> scope){
        List<Task> allBreachedTask = [Select Id,OwnerId,ZTS_US_SER_Owner_Name__c,ZTS_US_SER_Manager_Name__c,DirectorEmail__c,DirectorUserId__c
                                         from Task where ActivityDate < :startDateForChecking and 
                                         Status !='Completed' and DueDateBreachNotifiedtoDirector__c = false 
                                         and ZTS_EU_Market__c = :MARKET_CHECK ];
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
        owea = [select Id from OrgWideEmailAddress where Address = 'noreply@zoetis.com' LIMIT 1];
        //directorEmailTemp = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Task_Past_Due_Weekly_Notification_to_Task_Owner_Director_per_manager'];
        //system.debug('directorEmailTemp-->'+directorEmailTemp.Id);
       
        for(User dir: scope)
        {
            Map<String,Set<String>> breachMgrToRepMap = new Map<String,Set<String>>();
            Messaging.SingleEmailMessage emailMsg;
            for(Task t: allBreachedTask)
            {
                if(t.DirectorUserId__c == dir.Id)
                {
                    if(breachMgrToRepMap.containsKey(t.ZTS_US_SER_Manager_Name__c))
                    {
                        breachMgrToRepMap.get(t.ZTS_US_SER_Manager_Name__c).add(t.ZTS_US_SER_Owner_Name__c);
                    }
                    else
                    {
                        breachMgrToRepMap.put(t.ZTS_US_SER_Manager_Name__c,new Set<String>());
                    }
                }
            }
            
            if(breachMgrToRepMap.size()>0)
            {
                emailMsg = new Messaging.SingleEmailMessage();
                //String plainBody = directorEmailTemp.Body ;
                String subject = 'Your Sales Team Members have Overdue Zoetis Leads/Tasks to be completed';
                String plainBody;
                //String logoName = 'ZoetisLogo';
                //String resourceURL = getResourceURL(logoName) ;
                //system.debug('resourceURL ->>'+ resourceURL);
                //plainBody = '<img src ="' +  resourceURL + '" alt="Sample Image" height="100" width ="180"/>';
                //plainBody = plainBody+ '<p>Hello '+ dir.Name + ',</p>';
                plainBody = '<p>Hello <b>'+ dir.Name + '</b>,</p>';
                plainBody = plainBody + '<p> The Below Sales Team Members under your area managers, have overdue Leads or Tasks that <span style="color: red"><b> have not been completed</b>.</span> </p>';
               
                
                for(String mgrName: breachMgrToRepMap.KeySet())
                {
                    plainBody = plainBody + '<u>' + mgrName + '</u>';
                    plainBody = plainBody + '<ul>';
                    for(String repName: breachMgrToRepMap.get(mgrName))
                    {
                        plainBody = plainBody + '<li> ' + repName + '</li>';
                    }
                    plainBody = plainBody + '</ul>';
                    plainBody = plainBody+ '<br/>';
                }
                String report_link = System.label.ACE_Lead_Report_URL;   
                plainBody = plainBody + 'Please use this '+ '<a href = "'+ report_link +'">link</a> to access the Lead/Task Status Dashboard for your Team. <br/>';
                plainBody = plainBody + '<p>Thank You.</p>';
                
                
                
                emailMsg.setToAddresses(new List<String>{dir.Email});
                if (owea != null) {
                    emailMsg.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                emailMsg.setSubject(subject);
                emailMsg.setSaveAsActivity(false);
                emailMsg.setTargetObjectId(dir.Id);
                emailMsg.setHtmlBody(plainBody);
                emailMsg.setPlainTextBody(plainBody);
                emailMsg.setEmailPriority('Highest');
                //system.debug('directorEmailTemp.Id -->'+directorEmailTemp.Id);
                //emailMsg.setTemplateId(directorEmailTemp.Id);
                lstEmail.add(emailMsg);
            }
            
        }
        
        if(!lstEmail.isEmpty()) {
            try{
                System.debug('emails sent'+lstEmail);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmail);
            }
            catch (exception e) {
                System.debug(e.getMessage());
            }
        }
       
        
        
    }
    global void finish(database.BatchableContext BC){
        List<Task> updTaskList = new List<Task>();
        List<Task> allBreachedTask = [Select Id,DueDateBreachNotifiedtoDirector__c
                                         from Task where ActivityDate < :startDateForChecking and 
                                         Status !='Completed' and DueDateBreachNotifiedtoDirector__c = false 
                                         and ZTS_EU_Market__c = :MARKET_CHECK ];
        for (Task t: allBreachedTask)
        {
            t.DueDateBreachNotifiedtoDirector__c = true;
            updTaskList.add(t);
        }
        if(!updTaskList.isEmpty())
        {
            try{
                update updTaskList;
            } 
            catch(exception e)
            {
                System.debug(e.getMessage());
            }
        }
    }

}