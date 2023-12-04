trigger PropelSAPIntegrationAttachErrorFilesTrigger on ContentVersion (after insert) {
    if(PDLM__Configuration__c.getInstance('AttachSapErrorFileToChange') == null ||
       PDLM__Configuration__c.getInstance('AttachSapErrorFileToChange').PDLM__Value__c != 'true'){return;}

    List<String> changeNames = new List<String>();
    List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
    Map<String, Id> changeNameCdIdMap = new Map<String, Id>();
    Map<Id, Id> changeIdChangeAnalystIdMap = new Map<Id, Id>();

    if (Trigger.isAfter && Trigger.isInsert){
        for (ContentVersion cv : Trigger.new){
            //Check the File Description
            if (cv.Description != null && cv.Description.indexOf('PLM-SAP Interface Error Log') != -1){
                String tempChangeName = cv.Title.split('_')[0]; //Parse Change Number here
                changeNames.add(tempChangeName);
                changeNameCdIdMap.put(tempChangeName, cv.ContentDocumentId);
            }
        }
    }

    System.debug('changeNames: ' + changeNames);
    if (changeNames.size() == 0){return; }

    for (PDLM__Change__c chg : [SELECT Id, Name, Change_Analyst__c FROM PDLM__Change__c WHERE Name in :changeNames]){
        if (chg.Change_Analyst__c != null){
            changeIdChangeAnalystIdMap.put(chg.Id, chg.Change_Analyst__c);
        }
        
        //Prepare the list of ContentDocumentLink records
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = chg.Id;
        cdl.ContentDocumentId = changeNameCdIdMap.get(chg.Name);
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        cdls.add(cdl);
    }

    System.debug('ContentDocumentLink list: ' + cdls);

    //Insert Error Files to Changes
    if (cdls.size() > 0){
        insert cdls;
    }

    System.debug('changeIdChangeAnalystIdMap: ' + changeIdChangeAnalystIdMap);
    if (changeIdChangeAnalystIdMap.size() == 0 ){return; }
    
    //Email Change Analyst when there is an error file
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Propel_SAP_Error_Notification'].Id;

    if (emailTemplateId == null){return; }

    //Create the list of mails to be sent
    for (Id rec: changeIdChangeAnalystIdMap.keySet()){
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemplateId, null, rec); //Set recipents in the next line
        mail.setToAddresses(new Id[] {changeIdChangeAnalystIdMap.get(rec)}); 
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false); //Must be set to false, otherwise gives error when trying to sendEmail()
        mails.add(mail);
    }

    //Send Email(s) now
    try {
        Messaging.reserveSingleEmailCapacity(mails.size());
        Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
        System.debug('Number of emails sent: ' + mails.size());
        System.debug('Email Results: ' + result);
        return;
    } catch (Exception e) {
        System.debug(e.getMessage());
    }
}