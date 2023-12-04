/****************************************************************************************************************************************** 
* Class Name   : SchedulerToSendTaskReportCheckReminder
* Description  : This batch job will send a notification to US Inside Sales and Small Animal Managers to check Task Breach Report for his Team
               : To be run once in a month.
* Created By   : Aritra(Cognizant)
* Created Date : 1-Apr-2022
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra (Cognizant)      1-Apr-2022      Created this class (SC-009405)
*****************************************************************************************************************************************/

global class SchedulerToSendTaskReportCheckReminder implements Schedulable {
    global void execute(SchedulableContext SC) {
		sendEmail();
   }
    
    global void sendEmail(){
        String userProfiles = System.label.ACE_Task_Breach_Report_Enabled_Profiles;
        String report_link = System.label.ACE_Lead_Report_URL; 
        List<String> profileList = userProfiles.split(';');
        List<User> usrList = [Select Email from User where IsActive = TRUE and Profile.Name IN: profileList];
        List<String> toEmailAddress = new List<String>();
        if(usrList.size()>0)
        {
            for(User u: usrList)
            {
            	toEmailAddress.add(u.email);
            }
        }
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'noreply@zoetis.com' LIMIT 1];
        if(toEmailAddress != null && owea != null)
        {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String subject = 'Monthly Zoetis Leads and Tasks Report for your team';
        String plainBody;
        plainBody = '<p>Hello, </p>';
        plainBody = plainBody + '<p>Please use this '+'<a href = "'+ report_link +'">link</a> to access the ACE Lead Status Dashboard for your team.<br/>';
        plainBody = plainBody + 'This report allows you to view open Tasks and Leads for your team that are past due and in various stages.</p>';
        plainBody = plainBody + '<p>Thank You.</p>';
        mail.setSubject(subject);
        mail.setBccAddresses(toEmailAddress);
        mail.setOrgWideEmailAddressId(owea.Id);
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(plainBody);
        mail.setPlainTextBody(plainBody);
        mail.setEmailPriority('Highest');
        
         try{
                System.debug('emails sent -->'+mail);
             List<Messaging.SendEmailResult> result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            catch (exception e) {
                System.debug(e.getMessage());
            }
        }
    }
    

}