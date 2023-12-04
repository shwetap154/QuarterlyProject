/****************************************************************************************************************************************** 
 * Trigger Name : ACP_StatusUpdateAndNotify
 * Description  : This Class contains the method which will be invoked when "Submit" button on ACP Form is clicked.
 * Created By   : Aritra (Cognizant)
 * Created Date : 5th Nov, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra Chakraborty      11/05/2021          Created 
******************************************************************************************************************************************/
public with sharing class ACP_StatusUpdateAndNotify {
    
    static final String acp_RecType = System.label.ACPRecordType;
    static final String acp_Saved = System.label.ACP_Saved;
    static final String acp_New = System.label.ACP_New;
    static final String acp_pendingRepsComments = System.label.ACP_Pending_Reps_Comment;
    static final String acp_completed = System.label.ACP_Completed;
    static final String acp_RepEmailTemplate = System.label.ACP_Rep_Email_Template;
    static final String acp_MgrEmailTemplate = System.label.ACP_Manager_Email_Template;
    
    //Below method will be called when "Submit" button is clicked on ACP form
	//When Manager Clicks it, status will be updated to Pending Reps Comments and email will be sent to Rep
	//When Rep clicks it, Status will be updated to Completed and Email will be sent to Manager
    @AuraEnabled
    public static void  acpUpdStatusAndNotify(Id strRecId)
    {
        Id acpRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get(acp_RecType).getRecordTypeId();
        //update the status 
        Form__c f = [Select Id,Status__c,IDSR__c,IDSM__c,Rep_Comments__c,RecordTypeId,Accreditation_Status__c from Form__c where Id =: strRecId limit 1][0];
        List<String> emailAddresses = new List<String>();
        String templateName;
        Id targetObjId;
        if(f.recordtypeID == acpRecordTypeId){
            if((userInfo.getUserId() == f.IDSR__c) && (f.Status__c == acp_pendingRepsComments))
            {
                if(String.isBLANK(f.Rep_Comments__c))
                {
                    throw new AuraHandledException('Rep needs to enter Comments in Rep\'s comments field to submit the form');
                }
                else
                {
                    f.Status__c = acp_completed;
                    //Send Email to IDSM
                    String idsmEmail = [Select Email from User where Id =: f.IDSM__c][0].Email;
                    targetObjId = f.IDSM__c;
                    emailAddresses.add(idsmEmail);
                    templateName = acp_MgrEmailTemplate;
                }
                
            }
            if((userInfo.getUserId() == f.IDSM__c) && ((f.Status__c == acp_Saved)||(f.Status__c == acp_New)) && (f.Accreditation_Status__c != ''))
            {
                f.Status__c = acp_pendingRepsComments;
                //Send Email to IDSR
                String idsrEmail = [Select Email from User where Id =: f.IDSR__c][0].Email;
                targetObjId = f.IDSR__c;
                emailAddresses.add(idsrEmail);
				templateName = acp_RepEmailTemplate;               
            }
            
            try{
                update f;
            }        
            catch(Exception e)
            {
                system.debug('Error Occurred while changing Form Status:'+ e.getMessage());
            }
            sendEmail(f,templateName,emailAddresses,targetObjId);
        }
    }
    
    @AuraEnabled
    public static void sendEmail(Form__c f, String tempName, List<String> emailAddresses,Id targetObjId)
    {
        system.debug('tempName-->'+tempName);
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = :tempName];
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, targetObjId, f.Id);
        
        String emailSubject = email.getSubject();
        String emailTextBody = email.getPlainTextBody();
        
        email.setTargetObjectId(targetObjId);
        email.setSubject(emailSubject);
        email.setPlainTextBody(emailTextBody);
        email.saveAsActivity = false;
        if(!Test.isRunningTest()) {
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                system.debug('Email Sent>>>>>>>>>>>>>>>>>');
            }catch(exception e){
                system.debug(e.getMessage());
            }
        }
    }
    
   

}