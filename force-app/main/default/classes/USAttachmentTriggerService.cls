/****************************************************************************************************************************************** 
* Class Name   : USAttachmentTriggerService
* Description  : Logic for all US Attachment triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 17 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/17/2020          Created, Logic from all triggers moved to this class.
* Aritra (Cognizant)      07/12/2021          Added logic to populate RSA Active flag on Account for US(SC-005631)
* Ethan Hirsch (Zoetis)   01/05/2023          Bypass the Account Trigger when updating Accounts in beforeDelete to improve performance (TPDEV-81)
*****************************************************************************************************************************************/
public class USAttachmentTriggerService 
{
    public static void beforeDelete(List<Attachment> triggerOld, Map<Id, Attachment> triggerOldMap)
    {
        Integer i;
        String Title1;
        Id pId1;
        
        List<Case> c1= New List<Case>();
        for(Attachment att1: triggerOld)
        {
            Title1=att1.Name;
            pId1=att1.ParentId;
        }   
        List<AggregateResult> atmt = [SELECT count(id) FROM Attachment WHERE ParentId =: pId1];
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
        
        Map<Id,List<Attachment>> parent = new Map<Id,List<Attachment>>();
        set<id> attids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        
        if(triggerOld != null)
        {
            for(Attachment c : triggerOld)
            {
                if(c.ParentId <> null)      
                    attids.add(triggerOldMap.get(c.id).parentid);
            }
        }
        if(attids.size()>0)
        {
            try
            {
                List<Attachment> a = new List<Attachment>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c 
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, parentid 
                    FROM Attachment 
                    WHERE parentid IN :attids
                ];
                
                for(Attachment at : a)
                {
                    List<Attachment> llist = new List<Attachment>();
                    if(parent.get(at.parentid) == null)
                    {
                        llist = new List<Attachment>();
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                    else if(parent.get(at.parentid) != null)
                    {
                        llist = new List<Attachment>();
                        llist = parent.get(at.parentid);
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                }
                
                for(Id id : attids)
                {
                    if(testmap.get(id) != null && parent.get(id) != null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c = parent.get(id).size(); 
                    }
                    else if(testmap.get(id) != null && parent.get(id) == null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c = 0; 
                    }
                }
                
                update testmap.values();
            }
            catch(Exception e){}
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
        
        List <sobject> recordsToUpdate = new List <sobject> ();            
        
        List<Id> accIds = new List<Id>();
        for(Attachment att : triggerOld)
        {
            accIds.add(att.parentId);
        }
        Map<Id, Account> accById = new Map<Id, Account>(
            [ 
                SELECT Id, Name, MZR_Doc_Id__c,DX_Install_Doc_ID__c, Bios_MVP_Doc_ID__c, VGP_Enrollment_Doc_ID__c, MZR_PARAs_Doc_Id__c,RSA_Flag_Id__c,RSA_Active__c 
                FROM Account 
                WHERE Id in :accIds
                AND ZTS_EU_Market__c = 'United States'
            ]
        );
        if(accById.size()>0)
        {
            for(Attachment atc : triggerOld)
            {
                Account acc = accById.get(atc.parentId);
                if(acc.MZR_Doc_Id__c == atc.id && (acc.MZR_Doc_Id__c != '' || acc.MZR_Doc_Id__c != null))
                {
                    acc.MZR_Doc_Id__c = '';
                    accById.put(atc.parentId, acc);
                }
                else if(acc.Bios_MVP_Doc_ID__c == atc.id && (acc.Bios_MVP_Doc_ID__c != '' || acc.Bios_MVP_Doc_ID__c != null))
                {
                    acc.Bios_MVP_Doc_ID__c = '';
                    accById.put(atc.parentId, acc); 
                }
                else if(acc.MZR_PARAs_Doc_Id__c == atc.id && (acc.MZR_PARAs_Doc_Id__c != '' || acc.MZR_PARAs_Doc_Id__c != null))
                {
                    acc.MZR_PARAs_Doc_Id__c = '';
                    accById.put(atc.parentId, acc); 
                }
                else if(acc.VGP_Enrollment_Doc_ID__c == atc.id && (acc.VGP_Enrollment_Doc_ID__c != '' ||  acc.VGP_Enrollment_Doc_ID__c != null))
                {
                    acc.VGP_Enrollment_Doc_ID__c = '';
                    accById.put(atc.parentId, acc); 
                }
                else if(acc.DX_Install_Doc_ID__c == atc.id && (acc.DX_Install_Doc_ID__c != '' || acc.DX_Install_Doc_ID__c != null))
                {
                    acc.DX_Install_Doc_ID__c = '';
                    accById.put(atc.parentId, acc); 
                }
                //Added the below part to uncheck RSA Active flag on Account when the last attachment with '_RSA_' removed from the account(SC-005631)
                else if(acc.RSA_Flag_Id__c == atc.id && (acc.RSA_Flag_Id__c != '' ||  acc.RSA_Flag_Id__c != null))
                {
                    acc.RSA_Flag_Id__c = '';
                    acc.RSA_Active__c  = FALSE;
                    accById.put(atc.parentId, acc); 
                }
                //EOC - Added the below part to uncheck RSA Active flag on Account when the last attachment with '_RSA_' removed from the account(SC-005631)
            }
            // Bypass the Account Trigger as the update made will not require any Account logic to run
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update accById.values();
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    
    public static void afterInsert(List<Attachment> triggerNew, Map<Id, Attachment> triggerNewMap) 
    {
        String Title;
        Id pId;
        List<Case> c = New List<Case>();
        for(Attachment att: triggerNew)
        {
            Title=att.Name;
            pId=att.ParentId;
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
        
        Map<Id,List<Attachment>> parent = new Map<Id,List<Attachment>>();
        set<id> attids = new set<id>();
        if(triggerNew <> null)
        {
            for(Attachment a : triggerNew)
            {
                if(a.ParentId != null)
                    attids.add(a.parentid);
            }
            
        }
        if(attids.size()>0)
        {
            try
            {
                List<Attachment> a = new List<Attachment>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c 
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, parentid 
                    FROM Attachment 
                    WHERE parentid IN :attids
                ];
                
                for(Attachment at : a)
                {
                    List<Attachment> llist = new List<Attachment>();
                    if(parent.get(at.parentid) == null)
                    {
                        llist = new List<Attachment>();
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                    else if(parent.get(at.parentid) != null)
                    {
                        llist = new List<Attachment>();
                        llist = parent.get(at.parentid);
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                }
                
                for(Id id: attids)
                {
                    if(testmap.get(id) != null && parent.get(id) != null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c = parent.get(id).size(); 
                    }
                    else if(testmap.get(id) != null && parent.get(id) == null)
                    {
                        testmap.get(id).ZTS_US_Count_Attachments__c = 0; 
                    }
                }
                
                update testmap.values();
            }
            catch(Exception e){}
        }
        
        AttachmentService.setAttachmentIdFieldsOnAccount(triggerNew, new List<Id>(attids));
    }  
    
    public static void afterUpdate(List<Attachment> triggerOld, Map<Id, Attachment> triggerOldMap, List<Attachment> triggerNew, Map<Id, Attachment> triggerNewMap) 
    {
        Map<Id,List<Attachment>> parent = new Map<Id,List<Attachment>>();
        set<id> attids = new set<id>();
        if(triggerNew <> null)
        {
            for(Attachment c : triggerNew)
            {
                if(c.ParentId != null)
                    attids.add(c.parentid);
            }
            
        }
        else if(triggerOld != null)
        {
            for(Attachment c : triggerOld)
            {
                if(c.ParentId <> null)      
                    attids.add(triggerOldMap.get(c.id).parentid);
            }
        }
        if(attids.size()>0)
        {
            try
            {
                List<Attachment> a = new List<Attachment>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c 
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, parentid 
                    FROM Attachment 
                    WHERE parentid IN :attids
                ];
                
                for(Attachment at : a)
                {
                    List<Attachment> llist = new List<Attachment>();
                    if(parent.get(at.parentid) == null)
                    {
                        llist = new List<Attachment>();
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                    else if(parent.get(at.parentid) != null)
                    {
                        llist = new List<Attachment>();
                        llist = parent.get(at.parentid);
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                }
                
                for(Id i: attids)
                {
                    if(testmap.get(i) != null && parent.get(i) != null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c = parent.get(i).size(); 
                    }
                    else if(testmap.get(i) != null && parent.get(i) == null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c = 0; 
                    }
                }
                
                update testmap.values();
            }
            catch(Exception e){}
        }
        
        // This logic will be run regardless of what was updated on the Attachment to stay consistent.
        // with what it looked like pre-refactor for SC-008670
        AttachmentService.setAttachmentIdFieldsOnAccount(triggerNew, new List<Id>(attids));
    }    
    
    public static void afterDelete(List<Attachment> triggerOld, Map<Id, Attachment> triggerOldMap) 
    {
        Integer num;
        String Title1;
        Id pId1;
        
        List<Case> c1= New List<Case>();
        for(Attachment att1: triggerOld)
        {
            Title1=att1.Name;
            pId1=att1.ParentId;
        }   
        List<AggregateResult> atmt = [SELECT count(id) FROM Attachment WHERE ParentId =: pId1];
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
        
        Map<Id,List<Attachment>> parent = new Map<Id,List<Attachment>>();
        set<id> attids = new set<id>();
        Set<ID> AttachIds = new Set<ID>();  
        if(triggerOld != null)
        {
            for(Attachment c : triggerOld)
            {
                if(c.ParentId <> null)      
                    attids.add(triggerOldMap.get(c.id).parentid);
            }
        }
        if(attids.size() > 0)
        {
            try
            {
                List<Attachment> a = new List<Attachment>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c 
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, parentid 
                    FROM Attachment 
                    WHERE parentid IN :attids
                ];
                
                for(Attachment at : a)
                {
                    List<Attachment> llist = new List<Attachment>();
                    if(parent.get(at.parentid) == null)
                    {
                        llist = new List<Attachment>();
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                    else if(parent.get(at.parentid) != null)
                    {
                        llist = new List<Attachment>();
                        llist = parent.get(at.parentid);
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                }
                
                for(Id i: attids)
                {
                    if(testmap.get(i) != null && parent.get(i) != null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c = parent.get(i).size(); 
                    }
                    else if(testmap.get(i) != null && parent.get(i) == null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c = 0; 
                    }
                }
                
                update testmap.values();
            }
            catch(Exception e){}
        }
        
        Map <Id, Account> matchingInvoicesMap = new Map <Id, Account> ();
        for (Account invoice : [Select Id, Name From Account Where Id IN :AttachIds AND ZTS_EU_Market__c = 'United States'])
        {
            matchingInvoicesMap.put(invoice.Id, invoice);
        }
    }
    
    public static void afterUndelete(List<Attachment> triggerNew, Map<Id, Attachment> triggerNewMap) 
    {
        Map<Id,List<Attachment>> parent = new Map<Id,List<Attachment>>();
        set<id> attids = new set<id>();
        if(triggerNew <> null)
        {
            for(Attachment c : triggerNew)
            {
                if(c.ParentId != null)
                    attids.add(c.parentid);
            }
            
        }
        
        if(attids.size()>0)
        {
            try
            {
                List<Attachment> a = new List<Attachment>();
                Map<id,Contract> testmap = new Map<id,Contract>(
                    [
                        SELECT id,ZTS_US_Count_Attachments__c 
                        FROM Contract 
                        WHERE id IN: attids
                        AND ZTS_EU_Market__c = 'United States'
                    ]
                );
                a = [
                    SELECT Id, parentid 
                    FROM Attachment 
                    WHERE parentid IN :attids
                ];
                
                for(Attachment at : a)
                {
                    List<Attachment> llist = new List<Attachment>();
                    if(parent.get(at.parentid) == null)
                    {
                        llist = new List<Attachment>();
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                    else if(parent.get(at.parentid) != null)
                    {
                        llist = new List<Attachment>();
                        llist = parent.get(at.parentid);
                        llist.add(at);
                        parent.put(at.parentid,llist);
                    }
                }
                
                for(Id i: attids)
                {
                    if(testmap.get(i) != null && parent.get(i) != null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c = parent.get(i).size(); 
                    }
                    else if(testmap.get(i) != null && parent.get(i) == null)
                    {
                        testmap.get(i).ZTS_US_Count_Attachments__c = 0; 
                    }
                }
                
                update testmap.values();
            }
            catch(Exception e){}
        }
        
        AttachmentService.setAttachmentIdFieldsOnAccount(triggerNew, new List<Id>(attids));
    }
    
}