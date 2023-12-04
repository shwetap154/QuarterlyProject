public with sharing class QuestionTriggerService {
    
    @testVisible static Boolean forceFailure = false; 
    
    public static void afterUpdate(List<Question> triggerOld, Map<Id, Question> triggerOldMap, List<Question> triggerNew, Map<Id, Question> triggerNewMap) 
    {
        if(triggerNew != null && !triggerNew.isEmpty()){
            List<Question> questionsList = [SELECT Id, Title, Body, Priority, CommunityId, createdById, createdBy.AccountId, createdBy.ContactId 
                                                FROM Question WHERE 
                                                Id IN :triggerNew];
            
            List<Case> newCaseList = new List<Case>();
    
            for (Question q : questionsList) {
    
                if (q.Priority == 'high' && (q.Cases == null || q.Cases.size() == 0) && triggerOldMap.get(q.id).Priority != 'high') {
                    Case newCase = new Case(Origin='Chatter Answers', OwnerId=q.CreatedById, QuestionId=q.Id, CommunityId=q.CommunityId, Subject=q.Title, Description=q.Body, AccountId=q.CreatedBy.AccountId, ContactId=q.CreatedBy.ContactId);
                    newCaseList.add(newCase);
                }
            } 
            
            try{
                if(newCaseList.size()>0)
                    insert newCaseList;
                
                if(Test.isRunningTest() && forceFailure) {
                    String subjectTooLong = 'pibQWiIRKUS2S90HMDV2jxDsUr3mwi4wbcG9HTPCuVlX8kM37NisqFDYVn3gOlRmPqJCdWu7bJm0LnScvEwjeeGeV3tLg8749o0LpLo3ENHiiSfF2kgXHcPTNNOZKfTe7M5d2Y7YS2hH5YSYmS5VdMDqFkK9JCDJ5wmiwBiQQCdLy0i6A039Dpwf5BypKaq8d7iPxPUnG4DyllrNMaZthuyGSTUycdP24KOnJnJnzmokEwsBbFo7UBmo9ynGPDen';
                    newCaseList[0].Subject = subjectTooLong;
                    update newCaseList;
                }
    
            } catch (Exception e) {
                String subjectText = 'Case Escalation exception in site ' + Site.getName();
                String bodyText = 'Case Escalation on Question has failed with the following message: ' + e.getMessage() +
                    '\n\nStacktrace: ' + e.getStacktraceString();
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> toAddresses = new List<String>();
                if(Site.getAdminEmail() != null) {
	                toAddresses.add(Site.getAdminEmail());    
                }            
                if(Test.isRunningTest() && forceFailure) {
                    toAddresses.add('test@test.com');
                }             
    
                mail.setReplyTo('no-reply@salesforce.com');
                mail.setSenderDisplayName('Salesforce Chatter Answers User');
    
                // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
                // the portal user profile, and set the ID in the following line.
                // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                mail.setToAddresses(toAddresses);
                mail.setSubject(subjectText);
                mail.setPlainTextBody(bodyText);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}