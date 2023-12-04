/****************************************************************************************************************************************** 
Class Name   : USContentDocumentTriggerService
Description  : Logic for all US Attachment triggers housed here.
Created By   : Slalom/David Stern 
Created Date : 17 February 2020

Modification Log:  
---------------------------------------------------------------------------------------------------------------------------------------
    Developer                Date               Description 
---------------------------------------------------------------------------------------------------------------------------------------
@revision
    David Stern(Slalom)     02/17/2020          Created, Logic from US Attach trigger moved to this class.
@revision
    Aritra (Cognizant)      07/12/2021          Added logic to populate RSA Active flag on Account for US(SC-005631)
@revision
    Ahmed Elawad (Slalom)   05/05/2022          Added insertCDLForCaseOwner to share file on email attachment with case owner. CSEPVW-120
@revision
    Ethan Hirsch (Zoetis)   01/05/2023          Bypass the Account Trigger when updating Accounts in beforeDelete, afterInsert, afterUpdate, and 
                                                afterUndelete to improve performance (TPDEV-81)
*****************************************************************************************************************************************/

public class USContentDocumentTriggerService 
{
    @testVisible static final String TEST_CONST = 'USContentDocumentTriggerService - {METHOD}: super brief summation of what caused error';
    @testVisible public static Boolean forceFailure = false;
    @testVisible static final String EMAIL_RECORD_PREFIX = '02s';

    public static void beforeDelete(List<ContentDocumentLink> triggerOld, Map<Id, ContentDocumentLink> triggerOldMap)
    {
        Integer i;
        String Title1;
        Id pId1;
        
        List<Case> c1= New List<Case>();
        for(ContentDocumentLink att1: triggerOld)
        {
            Title1=att1.ContentDocumentId;
            pId1=att1.LinkedEntityId;
        }   
        List<AggregateResult> atmt = [SELECT count(id) FROM ContentDocumentLink WHERE LinkedEntityId =: pId1];
        if(atmt != null && atmt.size() >0)
        {
            i = Integer.valueOf(atmt[0].get('expr0'));
            RecordType rt1 = [select Id from RecordType where Name = 'Items Request' and SobjectType = 'Case' limit 1];
            c1 = [select Id, Status, RecordTypeId from Case where Id=:pId1];
            if(c1 != null && c1.size() >0 && rt1 != null)
            {
                if(((c1[0].Status == 'Open') || (c1[0].Status == 'Pending with C&C')) 
                   && (c1[0].RecordTypeId == rt1.Id) && (i == 1))
                {
                    //c1[0].ZTS_US_Purge_form__c=False;
                    //update c1[0];
                }
            }
        }
        
        Map<Id,List<ContentDocumentLink>> parent = new Map<Id,List<ContentDocumentLink>>();
        set<id> attids = new set<id>();
        set<id> contractids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        
        if(triggerOld != null)
        {
            for(ContentDocumentLink c : triggerOld)
            {
                if(c.LinkedEntityId <> null)   
                {   
                    contractids.add(triggerOldMap.get(c.id).LinkedEntityId);
                    attids.add(c.Id);
                }
            }
        }
      
        if(attids.size()>0)
        {
            try
            {
                List<ContentDocumentLink> a = new List<ContentDocumentLink>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c
                        FROM Contract 
                        WHERE id IN: contractids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, LinkedEntityId 
                    FROM ContentDocumentLink 
                    WHERE Id IN :attids
                ];
                
                for(ContentDocumentLink at : a)
                {
                    USContentDocumentTriggerService.addCDLToParentMap(parent, at);
                }
                
                for(Id id : contractids)
                {
                    if(testmap.get(id) != null && parent.get(id) != null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c -= parent.get(id).size(); 
                    }
                    else if(testmap.get(id) != null && parent.get(id) == null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c= 0; 
                    }
                }
                
                if(Test.isRunningTest() && forceFailure){
                    for(Contract contRec : testmap.values()){
                        contRec.accountId = null;
                    }
                }
                
                update testmap.values();
            }
            catch(DmlException dex){   
                USContentDocumentTriggerService.logError(dex, 'beforeDelete');
            }
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
        
        List <sobject> recordsToUpdate = new List <sobject> ();            
        
        List<Id> accIds = new List<Id>();
        for(ContentDocumentLink att : triggerOld)
        {
            accIds.add(att.LinkedEntityId);
        }
        Map<Id, Account> accById = new Map<Id, Account>(
            [ 
                SELECT Id, Name, MZR_Doc_Id__c, Bios_MVP_Doc_ID__c, VGP_Enrollment_Doc_ID__c, MZR_PARAs_Doc_Id__c,RSA_Flag_Id__c,RSA_Active__c 
                FROM Account 
                WHERE Id in :accIds
                AND ZTS_EU_Market__c = 'United States'
            ]
        );
        // Extracted the Content Document Title value from ContentDocumentLink -- Added by Aritra (SC-005631)
        List<Id> cdlIDs = new List<Id>();
        for(ContentDocumentLink cdl: triggerOld)
        {
            cdlIDs.add(cdl.Id);
        }
        List<ContentDocumentLink> listContentDocDetails = [select Id, ContentDocument.Title,ContentDocument.Id,LinkedEntityId
                                                           from ContentDocumentLink where id in :cdlIDs];
        // EOC - Extracted the Content Document Id, Title value from ContentDocumentLink -- Added by Aritra (SC-005631)
        if(accById.size()>0)
        {
            for(ContentDocumentLink atc : listContentDocDetails)
            {
                Account acc = accById.get(atc.LinkedEntityId);
                if(acc.MZR_Doc_Id__c == atc.ContentDocument.id && (acc.MZR_Doc_Id__c != '' || acc.MZR_Doc_Id__c != null))
                {
                    acc.MZR_Doc_Id__c = '';
                    accById.put(atc.LinkedEntityId, acc);
                }
                else if(acc.Bios_MVP_Doc_ID__c == atc.ContentDocument.id && (acc.Bios_MVP_Doc_ID__c != '' || acc.Bios_MVP_Doc_ID__c != null))
                {
                    acc.Bios_MVP_Doc_ID__c = '';
                    accById.put(atc.LinkedEntityId, acc); 
                }
                else if(acc.MZR_PARAs_Doc_Id__c == atc.ContentDocument.id && (acc.MZR_PARAs_Doc_Id__c != '' || acc.MZR_PARAs_Doc_Id__c != null))
                {
                    acc.MZR_PARAs_Doc_Id__c = '';
                    accById.put(atc.LinkedEntityId, acc); 
                }
                else if(acc.VGP_Enrollment_Doc_ID__c == atc.ContentDocument.id && (acc.VGP_Enrollment_Doc_ID__c != '' ||  acc.VGP_Enrollment_Doc_ID__c != null))
                {
                    acc.VGP_Enrollment_Doc_ID__c = '';
                    accById.put(atc.LinkedEntityId, acc); 
                }
                //Added the below part to uncheck RSA Active flag on Account when the last attachment with '_RSA_' removed from the account(SC-005631)
                else if(acc.RSA_Flag_Id__c == atc.ContentDocument.id && (acc.RSA_Flag_Id__c != '' ||  acc.RSA_Flag_Id__c != null))
                {
                    acc.RSA_Flag_Id__c = '';
                    acc.RSA_Active__c  = FALSE;
                    accById.put(atc.LinkedEntityId, acc); 
                }
                //EOC - Added the below part to uncheck RSA Active flag on Account when the last attachment with '_RSA_' removed from the account(SC-005631)
            }
            // Bypass the Account Trigger as the update made will not require any Account logic to run
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update accById.values();
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    
    public static void afterInsert(List<ContentDocumentLink> triggerNew, Map<Id, ContentDocumentLink> triggerNewMap) 
    {
        String Title;
        Id pId;
        List<Case> c = New List<Case>();
        for(ContentDocumentLink att: triggerNew)
        {
            Title=att.ContentDocumentId;
            pId=att.LinkedEntityId;
        }
        RecordType rt = [select Id from RecordType where Name = 'Items Request' and SobjectType = 'Case' limit 1];
        c = [select Id, Status,RecordTypeId from Case where Id=:pId];
        if(c != null && c.size() >0 && rt != null)
        {
            if(((c[0].Status == 'Open') || (c[0].Status == 'Pending with C&C')) 
               && (C[0].RecordTypeId == rt.Id) && (Title != NULL))
            {   
                //c[0].ZTS_US_Purge_form__c=True;
                //update c[0];
            }
        }
        
        Map<Id,List<ContentDocumentLink>> parent = new Map<Id,List<ContentDocumentLink>>();
        set<id> attids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        if(triggerNew <> null)
        {
            for(ContentDocumentLink a : triggerNew)
            {
                if(a.LinkedEntityId != null)
                    attids.add(a.LinkedEntityId);
                AttachIds.add(a.LinkedEntityId); 
            }
        }
        if(attids.size()>0)
        {
            try
            {
                List<ContentDocumentLink> a = new List<ContentDocumentLink>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, LinkedEntityId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :attids
                ];
                
                for(ContentDocumentLink at : a)
                {
                    USContentDocumentTriggerService.addCDLToParentMap(parent, at);
                }
                
                for(Id id: attids)
                {
                    if(testmap.get(id) != null && parent.get(id) != null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c= parent.get(id).size(); 
                    }
                    else if(testmap.get(id) != null && parent.get(id) == null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c= 0; 
                    }
                }
                
                if(Test.isRunningTest() && forceFailure){
                    for(Contract contRec : testmap.values()){
                        contRec.accountId = null;
                    }
                }
                update testmap.values();
            }
            catch(DmlException dex){   
                USContentDocumentTriggerService.logError(dex, 'afterInsert');
            }
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
        List <sobject> recordsToUpdate = new List <sobject> ();
        if(AttachIds.size() > 0)
        {
            for(ContentDocumentLink a: triggerNew)
            {
                List <ZTS_US_Contract_Doc_Id_search_string__c> cs = ZTS_US_Contract_Doc_Id_search_string__c.getall().values();
                if(matchingInvoicesMap.get(a.LinkedEntityId) != null && cs.size()>0) 
                {
                    for (ZTS_US_Contract_Doc_Id_search_string__c s : cs)
                    {
                        if(s.Contract_Attachment_Identifier__c.contains(';')) 
                        {
                            String[] idf = s.Contract_Attachment_Identifier__c.split(';'); 
                            for(integer i = 0; i < idf.size() - 1; i++)
                            {
                                if(((String)(a.ContentDocument.Title)).containsIgnoreCase(idf[i]))  {
                                    populateRSAFlag(a, s, recordsToUpdate);
                                    break;
                                }
                            }
                        }
                        else  
                        {
                            String idff= s.Contract_Attachment_Identifier__c;
                            if(((String)(a.ContentDocument.Title)).containsIgnoreCase(idff))
                            {
                                Id objId = a.LinkedEntityId;
                                SObject obj = objId.getSObjectType().newSObject(objId);
                                String fld= s.Contract_Field_Name__c;
                                obj.put(fld, a.ContentDocumentId);
                                //Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
                                if (((String)(a.ContentDocument.Title)).containsIgnoreCase('_RSA_'))
                                    {
                                        if(obj.getSObjectType() == Schema.Account.getSObjectType())
                                        {
                                             obj.put('RSA_Active__c', TRUE);
                                        }
                                    }
                                //EOC - Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
                                recordsToUpdate.add(obj);
                            }
                            
                        }
                    }
                }
            }     
            // Bypass the Account Trigger as the update made will not require any Account logic to run
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update recordsToUpdate;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }  
    
    public static void afterUpdate(List<ContentDocumentLink> triggerOld, Map<Id, ContentDocumentLink> triggerOldMap, List<ContentDocumentLink> triggerNew, Map<Id, ContentDocumentLink> triggerNewMap) 
    {
        Map<Id,List<ContentDocumentLink>> parent = new Map<Id,List<ContentDocumentLink>>();
        set<id> attids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        if(triggerNew <> null)
        {
            for(ContentDocumentLink c : triggerNew)
            {
                if(c.LinkedEntityId != null)
                attids.add(c.LinkedEntityId);
                AttachIds.add(c.LinkedEntityId); 
                
            }
            
        }
        else if(triggerOld != null)
        {
            for(ContentDocumentLink c : triggerOld)
            {
                if(c.LinkedEntityId <> null)      
                    attids.add(triggerOldMap.get(c.id).LinkedEntityId);
            }
        }
        
        if(attids.size()>0)
        {
            try
            {
                List<ContentDocumentLink> a = new List<ContentDocumentLink>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, LinkedEntityId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :attids
                ];
                
                for(ContentDocumentLink at : a)
                {
                    USContentDocumentTriggerService.addCDLToParentMap(parent, at);
                }
                
                for(Id i: attids)
                {
                    if(testmap.get(i) != null && parent.get(i) != null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c= parent.get(i).size(); 
                    }
                    else if(testmap.get(i) != null && parent.get(i) == null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c= 0; 
                    }
                }
                
                if(Test.isRunningTest() && forceFailure){
                    for(Contract contRec : testmap.values()){
                        contRec.accountId = null;
                    }
                }
                update testmap.values();
            }
            catch(DmlException dex){   
                USContentDocumentTriggerService.logError(dex, 'afterUpdate');
            }
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
        system.debug(LoggingLevel.ERROR,'matchingInvoicesMap-->'+matchingInvoicesMap);
        
        List <sobject> recordsToUpdate = new List <sobject> ();
        if(AttachIds.size() > 0)
        {
            for(ContentDocumentLink a: triggerNew)
            {
                // 
                List <ZTS_US_Contract_Doc_Id_search_string__c> cs = ZTS_US_Contract_Doc_Id_search_string__c.getall().values();
                if(matchingInvoicesMap.get(a.LinkedEntityId) != null && cs.size()>0) 
                {
                    for (ZTS_US_Contract_Doc_Id_search_string__c s : cs)
                    {
                        if(s.Contract_Attachment_Identifier__c.contains(';')) 
                        {
                            String[] idf = s.Contract_Attachment_Identifier__c.split(';'); 
                            for(integer i=0;i<idf.size()-1;i++)
                            {
                                if(((String)(a.ContentDocument.Title)).containsIgnoreCase(idf[i])) 
                                {   
                                    populateRSAFlag(a, s, recordsToUpdate);
                                    break;
                                }
                            }
                        }
                        else  
                        {
                            String idff= s.Contract_Attachment_Identifier__c;
                            if(((String)(a.ContentDocument.Title)).containsIgnoreCase(idff))
                            {
                                Id objId = a.LinkedEntityId;
                                SObject obj = objId.getSObjectType().newSObject(objId);
                                String fld= s.Contract_Field_Name__c;
                                obj.put(fld, a.ContentDocumentId);
                                //Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
                                if (((String)(a.ContentDocument.Title)).containsIgnoreCase('_RSA_'))
                                    {
                                        if(obj.getSObjectType() == Schema.Account.getSObjectType())
                                        {
                                             obj.put('RSA_Active__c', TRUE);
                                        }
                                    }
                                //EOC - Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
                                recordsToUpdate.add(obj);
                            }
                            
                        }
                    }
                }
            }     
            // Bypass the Account Trigger as the update made will not require any Account logic to run
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update recordsToUpdate;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }    
    
    public static void afterDelete(List<ContentDocumentLink> triggerOld, Map<Id, ContentDocumentLink> triggerOldMap) 
    {
        Integer num;
        String Title1;
        Id pId1;
        
        List<Case> c1= New List<Case>();
        for(ContentDocumentLink att1: triggerOld)
        {
            Title1=att1.ContentDocumentId;
            pId1=att1.LinkedEntityId;
        }   
        List<AggregateResult> atmt = [SELECT count(id) FROM ContentDocumentLink WHERE LinkedEntityId =: pId1];
        if(atmt != null && atmt.size() >0)
        {
            num = Integer.valueOf(atmt[0].get('expr0'));
            RecordType rt1 = [select Id from RecordType where Name = 'Items Request' and SobjectType = 'Case' limit 1];
            c1 = [select Id, Status, RecordTypeId from Case where Id=:pId1];
            if(c1 != null && c1.size() >0 && rt1 != null)
            {
                if(((c1[0].Status == 'Open') || (c1[0].Status == 'Pending with C&C')) 
                   && (c1[0].RecordTypeId == rt1.Id) && (num == 1))
                {
                    //c1[0].ZTS_US_Purge_form__c=False;
                    //update c1[0];
                }
            }
        }
        
        Map<Id,List<ContentDocumentLink>> parent = new Map<Id,List<ContentDocumentLink>>();
        set<id> attids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        if(triggerOld != null)
        {
            for(ContentDocumentLink c : triggerOld)
            {
                if(c.LinkedEntityId <> null)      
                    attids.add(triggerOldMap.get(c.id).LinkedEntityId);
            }
        }
        
        
        if(attids.size() > 0)
        {
            try
            {
                List<ContentDocumentLink> a = new List<ContentDocumentLink>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, LinkedEntityId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :attids
                ];
                
                for(ContentDocumentLink at : a)
                {
                    USContentDocumentTriggerService.addCDLToParentMap(parent, at);
                }
                
                for(Id i: attids)
                {
                    if(testmap.get(i) != null && parent.get(i) != null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c= parent.get(i).size(); 
                    }
                    else if(testmap.get(i) != null && parent.get(i) == null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c= 0; 
                    }
                }
                
                
                update testmap.values();
            }
            catch(DmlException dex){   
                USContentDocumentTriggerService.logError(dex, 'afterDelete');
            }
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
    }
    
    public static void afterUndelete(List<ContentDocumentLink> triggerNew, Map<Id, ContentDocumentLink> triggerNewMap) 
    {
        Map<Id,List<ContentDocumentLink>> parent = new Map<Id,List<ContentDocumentLink>>();
        set<id> attids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        if(triggerNew <> null)
        {
            for(ContentDocumentLink c : triggerNew)
            {
                if(c.LinkedEntityId != null)
                    attids.add(c.LinkedEntityId);
                AttachIds.add(c.LinkedEntityId); 
            }
            
        }
        
        if(attids.size()>0)
        {
            try
            {
                List<ContentDocumentLink> a = new List<ContentDocumentLink>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, LinkedEntityId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :attids
                ];
                
                for(ContentDocumentLink at : a)
                {
                    USContentDocumentTriggerService.addCDLToParentMap(parent, at);
                }
                
                for(Id i: attids)
                {
                    if(testmap.get(i) != null && parent.get(i) != null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c= parent.get(i).size(); 
                    }
                    else if(testmap.get(i) != null && parent.get(i) == null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c= 0; 
                    }
                }
                
                update testmap.values();
            }
            catch(DmlException dex){   
                USContentDocumentTriggerService.logError(dex,'afterUndelete');
            }
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
        
        List <sobject> recordsToUpdate = new List <sobject> ();
        if(AttachIds.size() > 0)
        {
            for(ContentDocumentLink a: triggerNew)
            {
                List <ZTS_US_Contract_Doc_Id_search_string__c> cs = ZTS_US_Contract_Doc_Id_search_string__c.getall().values();
                if(matchingInvoicesMap.get(a.LinkedEntityId) != null && cs.size()>0) 
                {
                    for (ZTS_US_Contract_Doc_Id_search_string__c s : cs)
                    {
                        if(s.Contract_Attachment_Identifier__c.contains(';')) 
                        {
                            String[] idf = s.Contract_Attachment_Identifier__c.split(';'); 
                            for(integer i=0;i<idf.size()-1;i++)
                            {
                                if(((String)(a.ContentDocument.Title)).containsIgnoreCase(idf[i]))  {   
                                    populateRSAFlag(a, s, recordsToUpdate);
                                    break;
                                }
                            }
                        }
                        else  
                        {
                            String idff= s.Contract_Attachment_Identifier__c;
                            if(((String)(a.ContentDocument.Title)).containsIgnoreCase(idff)) {
                                Id objId = a.LinkedEntityId;
                                SObject obj = objId.getSObjectType().newSObject(objId);
                                String fld= s.Contract_Field_Name__c;
                                obj.put(fld, a.ContentDocumentId);
                                //Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
                                if (((String)(a.ContentDocument.Title)).containsIgnoreCase('_RSA_')) {
                                        if(obj.getSObjectType() == Schema.Account.getSObjectType()) {
                                             obj.put('RSA_Active__c', TRUE);
                                        }
                                    }
                                //EOC - Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
                                recordsToUpdate.add(obj);
                            }
                            
                        }
                    }
                }
            }     
            // Bypass the Account Trigger as the update made will not require any Account logic to run
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update recordsToUpdate;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
   /* COMMENTING OUT METHOD DUE TO DEFECT INC2570483, ROLLING BACK
    public static void giveVmipsCaseOwnerAccessToEmailFile( List<ContentDocumentLink> linksForContentDocuments, Map<Id, ContentDocument> triggerNewReferenceMap)
    {
        Map<Id, Id> emailMessageToContentDocumentId = new Map<Id, Id>();
        List<ContentDocument> nonEmailDocs = new List<ContentDocument>(); 
        Map<Id, List<ContentDocument>> caseIdToNonEmailDocs = new Map<Id, List<ContentDocument>>();
        Set<Id> alreadyReferencedDocs = new Set<Id>();
        String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Animal_Support').getRecordTypeId(); 
        // iterate over the content document links
        for (ContentDocumentLink link : linksForContentDocuments) 
        {
            ContentDocument doc = triggerNewReferenceMap.get(link.contentDocumentId);
            List<ContentDocument> docListForCase = caseIdToNonEmailDocs.get(link.LinkedEntityId);
            if (docListForCase == null) docListForCase = new List<ContentDocument>();
            // get the linkedEntity id and determine if this shares the file with an email
            // if the link points to an email add map the document id to the email
            String linkedEntityId = ((String)link.LinkedEntityId);
            Boolean cdlReferencesEmail = linkedEntityId.startsWith(EMAIL_RECORD_PREFIX);
            if (cdlReferencesEmail && !alreadyReferencedDocs.contains(link.ContentDocumentId)) {
                emailMessageToContentDocumentId.put(linkedEntityId, link.ContentDocumentId);
                alreadyReferencedDocs.add(link.ContentDocumentId);
            } 
            
            Boolean cdlReferencesCase = linkedEntityId.startsWith('500');
            if (cdlReferencesCase && !alreadyReferencedDocs.contains(link.ContentDocumentId)) {
                docListForCase.add(doc);
                alreadyReferencedDocs.add(doc.id);
                caseIdToNonEmailDocs.put(link.LinkedEntityId, docListForCase);
            }
        }
        
        // get all the emails in the map values: parent, owner id
        List<EmailMessage> emails = 
            new List<EmailMessage>(
                [   SELECT Id, ParentId, Parent.OwnerId, Parent.RecordTypeId 
                    FROM EmailMessage 
                    WHERE Id IN :emailMessageToContentDocumentId.keySet()
                    AND Parent.RecordTypeId = : animalRecordtypeId]);
        
        for (EmailMessage email : emails) {
            Id contentDocumentId = emailMessageToContentDocumentId.get(email.Id);
            ContentDocument doc = triggerNewReferenceMap.get(contentDocumentId);
            if ( 
                doc.OwnerId != email.Parent.OwnerId 
                && email.Parent.OwnerId.getSObjectType() == User.SObjectType
            ) doc.ownerId =  email.parent.ownerId;
        }
        
        if (!caseIdToNonEmailDocs.isEmpty()) {
            // get all the cases for the documents being updated that are vmips record types
            Map<Id, Case> idToCasemap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case WHERE Id IN : caseIdToNonEmailDocs.keySet() 
                                                          AND recordTypeId=:animalRecordtypeId]);
            
            // for each case get the list of documents being updated.
            // If the case owner doesn't have ownership access rights provide that access
            for (Case parentCase : idToCasemap.values()) {
                List<ContentDocument> docsForCase = caseIdToNonEmailDocs.get(parentCase.Id);
                if ( docsForCase != null) {
                    for (ContentDocument doc : docsForCase) {
                        if ( 
                            doc.OwnerId != parentCase.OwnerId 
                            && parentCase.OwnerId.getSObjectType() == User.SObjectType
                        ) doc.ownerId =  parentCase.ownerId;
                    }
                }
            }
        }
    }
    */
    
    public static void logError(DmlException dex, String methodName) {
        String errorMessages = '';
        for (Integer n = 0; n < dex.getNumDml(); n++) {
            errorMessages += dex.getDmlMessage(n) + '\n';
        }
        errorMessages.removeEnd('\n');
        ZTS_EU_Logger.notify = true;
        ZTS_EU_Logger.error(errorMessages,null, TEST_CONST.replace('{METHOD}', methodName));
    }
    
    public static void addCDLToParentMap(Map<Id, List<ContentDocumentLink>> parent, ContentDocumentLink at) {
        // initialize the list by getting the existing list from the parent map
        // if the list is null initialize it as an empty one
        // add the cdl to the list
        // put the list on the map
        List<ContentDocumentLink> contentDocumentList = parent.get(at.linkedEntityId);
        if (contentDocumentList == null) contentDocumentList = new List<ContentDocumentLink>();
        contentDocumentList.add(at);
        parent.put(at.LinkedEntityId,contentDocumentList);
    }

    // CSEPVW-120 refactor
    public static void populateRSAFlag(ContentDocumentLink link, ZTS_US_Contract_Doc_Id_search_string__c contractString,  List<sObject> recordsToUpdate) 
    {
        Id objId = link.LinkedEntityId;
        SObject obj = objId.getSObjectType().newSObject(objId);
        String fld= contractString.Contract_Field_Name__c;
        obj.put(fld, link.ContentDocumentId);
        //Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
        if (((String)(link.ContentDocument.Title)).containsIgnoreCase('_RSA_')) {
            if(obj.getSObjectType() == Schema.Account.getSObjectType()) {
                obj.put('RSA_Active__c', TRUE);
            }
        }
        //EOC - Added this part to populate RSA Active flag on Account if File with title containing _RSA_ is added under the account(SC-005631)
        recordsToUpdate.add(obj);
    }
}