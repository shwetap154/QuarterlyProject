global with sharing class PropelEmailWithFieldsValidation {
    global class GetRequestsfromPB{
        @InvocableVariable(label='Change ID' required=true) global Id changeId;
        @InvocableVariable(label='List of Change Fields (API Name and Separated by Semi-colon if Multiple)' required=true) global String changeFields;
        @InvocableVariable(label='List of Affected Item Fields (API Name and Separated by Semi-colon if Multiple)' required=true) global String aiFields;
        @InvocableVariable(label='List of User Ids' required=true) global List<Id> userIds;
    }

    @testVisible static Integer num_of_emails_sent = 0;
    @InvocableMethod

    global static void PropelEmailWithFieldsValidation(List<GetRequestsfromPB> pbs){
        Set<Id> changeIds = new Set<Id>();
        Set<Id> changeAnalystIds = new Set<Id>();
        Map<Id, String> changeAnalystIdNameMap = new Map<Id, String>();
        Map<Id, Id> changeAnalystIdIdMap = new Map<Id, Id>();
        List<Id> userIdsList = new List<Id>();
        Map<Id, List<Id>> changeUserIdsMap = new Map<Id, List<Id>>();
        List<PDLM__Change__c> changes = new List<PDLM__Change__c>();
        List<PDLM__Affected_Item__c> affectedItems = new List<PDLM__Affected_Item__c>();
        String changeFieldsParsed = '';
        String aiFieldsParsed = '';
        String[] changeFieldsList = new List<String>();
        String[] aiFieldsList = new List<String>();

        //Loop through records that trigger the Process Builder/Flow
        for (GetRequestsfromPB pb : pbs){
            changeIds.add(pb.changeId);
            changeUserIdsMap.put(pb.changeId, pb.userIds);
            changeFieldsList = pb.changeFields.split(';');
            aiFieldsList = pb.aiFields.split(';');
            changeFieldsParsed = String.join(pb.changeFields.split(';'), ',').trim();
            aiFieldsParsed = String.join(pb.aiFields.split(';'), ',').trim();
        }

        System.debug('changeFieldsList : ' + changeFieldsList);
        System.debug('aiFieldsList : ' + aiFieldsList);

        String changeQuery = String.format('SELECT {0}, Id, Name, Change_Analyst__c, OwnerId FROM PDLM__Change__c WHERE Id in :changeIds', new list<string>{changeFieldsParsed});
        String aiQuery = String.format('SELECT {0}, Id, Name, PDLM__Item_Revision__c, PDLM__Change_Order_lk__c FROM PDLM__Affected_Item__c WHERE PDLM__Change_Order_lk__c in :changeIds', new list<string>{aiFieldsParsed}); 
        changes.addAll((List<PDLM__Change__c>)(Database.query(changeQuery)));
        affectedItems.addAll((List<PDLM__Affected_Item__c>)(Database.query(aiQuery)));

        System.Debug('Change Records: ' + changes);
        System.Debug('Affected Item Records: ' + affectedItems);
        System.Debug('Change UserIds Map: ' + changeUserIdsMap);
        
        //Create Missing AIs Fields Map and Loop Through AIs
        String listOfMissingAiFields = '';
        String listOfMissingAiFieldsPlain = '';
        String listOfMissingChangeFields = '';
        String listOfMissingChangeFieldsPlain = '';
        List<Id> itemRevIdsList = new List<Id>();
        Map<Id, String> revIdNameMap = new Map<Id, String>();
        Map<Id, String> changeMissingFieldsMap = new Map<Id, String>();
        Map<Id, String> changeMissingFieldsPlainMap = new Map<Id, String>();
        Map<Id, String> aiMissingFieldsMap = new Map<Id, String>();
        Map<Id, String> aiMissingFieldsPlainMap = new Map<Id, String>();
        Map<Id, String> changeMissingFieldsMapConsol = new Map<Id, String>();
        Map<Id, String> changeMissingFieldsPlainMapConsol = new Map<Id, String>();
        Map<Id, String> changeIdNameMap = new Map<Id, String>();
        Map<String, Schema.SObjectField> changeMapFields = Schema.SObjectType.PDLM__Change__c.fields.getMap();
        Map<String, Schema.SObjectField> aiMapFields = Schema.SObjectType.PDLM__Affected_Item__c.fields.getMap();
        String tempAiFieldLabel = '';
        String tempChangeFieldLabel = '';

        if (affectedItems.size() != 0){
            for (PDLM__Affected_Item__c ai: affectedItems){
                itemRevIdsList.add(ai.PDLM__Item_Revision__c);
            }
        }

        System.debug('ItemRevisionMap: ' + itemRevIdsList);

        for(PDLM__Item_Revision__c rev: [SELECT Id, Name FROM PDLM__Item_Revision__c WHERE Id in :itemRevIdsList]){
            revIdNameMap.put(rev.Id, rev.Name);
        }

        if (affectedItems.size() != 0){
            for (PDLM__Affected_Item__c ai: affectedItems){
                Map<String, Object> aiMap = ai.getPopulatedFieldsAsMap();

                for (String field : aiFieldsList){
                    field = field.trim();

                    if (!aiMap.containsKey(field)) {

                        listOfMissingAiFields = '<li>' + revIdNameMap.get(ai.PDLM__Item_Revision__c) + ': ';
                        if(!aiMissingFieldsMap.containsKey(ai.PDLM__Change_Order_lk__c)){
                            aiMissingFieldsMap.put(ai.PDLM__Change_Order_lk__c, listOfMissingAiFields);
                        }
    
                        if (!aiMissingFieldsMap.get(ai.PDLM__Change_Order_lk__c).contains(listOfMissingAiFields)){
                            String tempStr1 = aiMissingFieldsMap.get(ai.PDLM__Change_Order_lk__c);
                            tempStr1 += listOfMissingAiFields;
                            aiMissingFieldsMap.put(ai.PDLM__Change_Order_lk__c, tempStr1);
                        }
    
                        listOfMissingAiFieldsPlain = revIdNameMap.get(ai.PDLM__Item_Revision__c) + ': ';
                        if(!aiMissingFieldsPlainMap.containsKey(ai.PDLM__Change_Order_lk__c)){
                            aiMissingFieldsPlainMap.put(ai.PDLM__Change_Order_lk__c, listOfMissingAiFieldsPlain);
                        }
    
                        if (!aiMissingFieldsPlainMap.get(ai.PDLM__Change_Order_lk__c).contains(listOfMissingAiFieldsPlain)){
                            String tempStr2 = aiMissingFieldsPlainMap.get(ai.PDLM__Change_Order_lk__c);
                            tempStr2 += listOfMissingAiFieldsPlain;
                            aiMissingFieldsPlainMap.put(ai.PDLM__Change_Order_lk__c, tempStr2);
                        }

                        Schema.SObjectField fieldDescribe = aiMapFields.get(field);
                        if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                            tempAiFieldLabel = aiMapFields.get(field).getDescribe().getLabel();
                        } else{
                            tempAiFieldLabel =  field;
                        }

                        //Grab missing fields from Affected Items
                        listOfMissingAiFields = aiMissingFieldsMap.get(ai.PDLM__Change_Order_lk__c);
                        listOfMissingAiFields += String.valueOf(tempAiFieldLabel) + '; ';
                        aiMissingFieldsMap.put(ai.PDLM__Change_Order_lk__c, listOfMissingAiFields);

                        //Grab missing plain fields from Affected Items
                        listOfMissingAiFieldsPlain = aiMissingFieldsPlainMap.get(ai.PDLM__Change_Order_lk__c);
                        listOfMissingAiFieldsPlain += String.valueOf(tempAiFieldLabel) + '; ';
                        aiMissingFieldsPlainMap.put(ai.PDLM__Change_Order_lk__c, listOfMissingAiFieldsPlain);
                    }
                }

                if (aiMissingFieldsMap.get(ai.PDLM__Change_Order_lk__c) != null){
                    listOfMissingAiFields = aiMissingFieldsMap.get(ai.PDLM__Change_Order_lk__c) + '</li>';
                    aiMissingFieldsMap.put(ai.PDLM__Change_Order_lk__c, listOfMissingAiFields);
                }
            }
        }

        System.debug('Missing Affected Item Fields: ' + listOfMissingAiFields);
        System.debug('Missing Affected Item Fields Plain: ' + listOfMissingAiFieldsPlain);
        System.debug('aiMissingFieldsMap: ' + aiMissingFieldsMap);
        System.debug('aiMissingFieldsPlainMap: ' + aiMissingFieldsPlainMap);

        //Check if a record has missing required fields
        for (PDLM__Change__c change: changes){
            changeIdNameMap.put(change.Id, change.Name);
            changeAnalystIds.add(change.Change_Analyst__c);
            changeAnalystIdIdMap.put(change.Id, change.Change_Analyst__c);

            Map<String, Object> changeMap = change.getPopulatedFieldsAsMap();

            for (String field: changeFieldsList) {
                field = field.trim();

                if (!changeMap.containsKey(field)) {
                    Schema.SObjectField fieldDescribe = changeMapFields.get(field);
                    if (fieldDescribe != null && fieldDescribe.getDescribe().getLabel() != null) {
                        tempChangeFieldLabel = changeMapFields.get(field).getDescribe().getLabel();
                    } else{
                        tempChangeFieldLabel =  field;
                    }
                    
                    if(!changeMissingFieldsMap.containsKey(change.Id)){
                        listOfMissingChangeFields = '';
                        changeMissingFieldsMap.put(change.Id, listOfMissingChangeFields);
                    }
                    //Grab missing fields from Changes
                    listOfMissingChangeFields = changeMissingFieldsMap.get(change.Id);
                    listOfMissingChangeFields += '<li>' + String.valueOf(tempChangeFieldLabel) + '</li>';
                    changeMissingFieldsMap.put(change.Id, listOfMissingChangeFields);
                    
                    if(!changeMissingFieldsPlainMap.containsKey(change.Id)){
                        listOfMissingChangeFieldsPlain = '';
                        changeMissingFieldsPlainMap.put(change.Id, listOfMissingChangeFieldsPlain);
                    }
                    listOfMissingChangeFieldsPlain = changeMissingFieldsPlainMap.get(change.Id);
                    listOfMissingChangeFieldsPlain += String.valueOf(tempChangeFieldLabel) + '; ';
                    changeMissingFieldsPlainMap.put(change.Id, listOfMissingChangeFieldsPlain);
                }
            }
        }

        System.debug('List of Missing Change Fields:' + changeMissingFieldsMap);
        System.debug('List of Missing Change Plain Fields:' + listOfMissingChangeFieldsPlain);

        //Concatenate the string of missing fields for emails and change history log
        for (Id change : changeIds){
            String tempMissingFields = '';
            if (!String.IsBlank(changeMissingFieldsMap.get(change))){tempMissingFields = changeMissingFieldsMap.get(change);}
            if (!String.IsBlank(aiMissingFieldsMap.get(change))){tempMissingFields += aiMissingFieldsMap.get(change);}

            String tempMissingFieldsPlain = '';
            if (!String.IsBlank(changeMissingFieldsPlainMap.get(change))){tempMissingFieldsPlain = changeMissingFieldsPlainMap.get(change);}
            if (!String.IsBlank(aiMissingFieldsPlainMap.get(change))){tempMissingFieldsPlain += aiMissingFieldsPlainMap.get(change);}

            changeMissingFieldsMapConsol.put(change, tempMissingFields);
            changeMissingFieldsPlainMapConsol.put(change, tempMissingFieldsPlain);
        }

        if (changeMissingFieldsMapConsol.isEmpty() && changeMissingFieldsPlainMapConsol.isEmpty()){return; }
        
        System.debug('changeMissingFieldsMapConsolidated Map: ' + changeMissingFieldsMapConsol);
        System.debug('changeMissingFieldsPlainMapConsolidated Map: ' + changeMissingFieldsPlainMapConsol);

        //Create Change Analyst Id Name Map
        for (User usr : [SELECT Id, Name FROM User WHERE Id in :changeAnalystIds]) {
            changeAnalystIdNameMap.put(usr.Id, usr.Name);
        }

        //Send Email
        //Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
        Messaging.SingleEmailMessage [] mails = new List<Messaging.SingleEmailMessage> {};

        for (Id change : changeMissingFieldsMapConsol.keySet()){
            //Query the OrgWide
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName like '%Propel%' limit 1];

            //Get User Ids List
            for (Id usrId : changeUserIdsMap.get(change)){
                userIdsList.add(usrId);
            }
            
            // mail.setToAddresses(changeUserIdsMap.get(change));
            mail.setToAddresses(userIdsList);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            //If statement here
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            else {
                mail.setSenderDisplayName(userInfo.getName());
            }
            mail.setSubject(changeIdNameMap.get(change) + ' Failed to Auto-promote');
            mail.setHtmlBody('Hello Propel User,'
                            + '<br><br>' + changeIdNameMap.get(change)+ ' has failed to Auto-promote out of the Assessment status.' 
                            + '<br>The following fields where incomplete:'
                            + '<br><ul>' + changeMissingFieldsMapConsol.get(change) + '</ul>'
                            + '<br>Notify ' + changeAnalystIdNameMap.get(changeAnalystIdIdMap.get(change)) + ' when above fields are completed.'
                            + '<br>' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + change
                            + '<br><br>Thanks!');

            mails.add(mail);
        }

        System.debug('Email Detail: ' + mails);
        
        //Send Email(s) now
        //Try...Catch...
        try {
            // Send email
            num_of_emails_sent = mails.size();
            Messaging.reserveSingleEmailCapacity(num_of_emails_sent);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            
            system.debug('Email(s) sent: ' + result.size());
            system.debug(LoggingLevel.warn, result);

            //Email the outstanding Approvers and Originator
            Messaging.sendEmail(mails);
            num_of_emails_sent = mails.size();
        } catch (Exception e) {
            // deal with failure to send
            System.debug(LoggingLevel.WARN, 'Exception: ' + e);
        }

        //Log to Change History Table
        List<PDLM__Change_History__c> changeHistoryRecords = new List<PDLM__Change_History__c>();

        for (Id change : changeMissingFieldsPlainMapConsol.keySet()){
            PDLM__Change_History__c changeAudit = new PDLM__Change_History__c();
            changeAudit.PDLM__Parent_Id__c = change;
            changeAudit.PDLM__Field__c = changeIdNameMap.get(change) + ' Failed to Auto-promote of the Assessment status';
            changeAudit.PDLM__NewValue__c = 'Missing fields: ' + changeMissingFieldsPlainMapConsol.get(change);
            changeAudit.PDLM__Object_Id__c = change;
            changeAudit.PDLM__Object_Name__c = changeIdNameMap.get(change);
            changeHistoryRecords.add(changeAudit);
        }

        insert changeHistoryRecords;
    }
}