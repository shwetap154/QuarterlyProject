/*
  * Controller : changeRequestEditSubmitController (Page - ChangeRequestEditSubmitPage)
  * Description : Custom Edit Page for Save and submit button (DEF-00723)
  * Author : Sohil Shah(CloudSense)
  * Created Date : 8th Aug,2015
*/
public with sharing class changeRequestEditSubmitController
{
    public ZTS_EU_Request__c cr{get;set;}
    public Id crId;
    public boolean newCr{get;set;}
    public boolean edit{get;set;}
    public string OwnerName{get;set;}
    public string AccId;
    public string ContactID;
    public changeRequestEditSubmitController(ApexPages.StandardController controller) {
        cr = new ZTS_EU_Request__c();
        newCr = false;
        edit = false;   
        crId = ApexPages.currentPage().getParameters().get('id');
        AccId = ApexPages.currentPage().getParameters().get('CF00Ni000000EHlmz_lkid');
        ContactID = ApexPages.currentPage().getParameters().get('CF00Ni000000EHln0_lkid'); 
        //AccIdOrContactID = AccIdOrContactID.substring(1);
        if(crId != null)
        {
            edit = true;
            cr = [Select Id, Name, OwnerId,ZTS_EU_Status__c,CreatedByID,ZTS_EU_Requestor__c,ZTS_EU_Object_Type__c,ZTS_EU_Account_To_Be_Changed__c,ZTS_EU_Contact__c,ZTS_EU_Reviewer_Comments__c from ZTS_EU_Request__c where id=:crId];           
        }
        System.debug('crid------'+crId);
        if(crId == null && AccId!=null)
        {
            newCr = true;            
            User us = [select Id,Name from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            OwnerName = us.Name;     
            cr.OwnerId = us.Id;
            cr.ZTS_EU_Account_To_Be_Changed__c = AccId;
            cr.ZTS_EU_Object_Type__c = 'Account';
            cr.ZTS_EU_Requestor__c = us.id;                             
        }
        if(crId == null && ContactID!=null)
        {
            newCr = true;            
            User us = [select Id,Name from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            OwnerName = us.Name;            
            cr.OwnerId = us.Id;
            cr.ZTS_EU_Contact__c= ContactID;
            cr.ZTS_EU_Object_Type__c = 'Contact';                             
            cr.ZTS_EU_Requestor__c = us.id;                             
        }
        if(crId == null && AccId == null && ContactID == null )
        {
            newCr = true;            
            User us = [select Id,Name from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            OwnerName = us.Name;            
            cr.OwnerId = us.Id;
            cr.ZTS_EU_Requestor__c = us.id;
        }
        
        
    }
    
    public PageReference insertCR()
    {
       System.debug('cr   :::: '+cr);
       cr.ZTS_EU_Object_Type__c = 'Empty';
        insert cr;
        cr = new ZTS_EU_Request__c();
        if(AccId!=null)
        {
            newCr = true;            
            User us = [select Id,Name from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            OwnerName = us.Name;     
            cr.OwnerId = us.Id;
            cr.ZTS_EU_Account_To_Be_Changed__c = AccId;
            cr.ZTS_EU_Object_Type__c = 'Account';
            cr.ZTS_EU_Requestor__c = us.id;                             
        }
        if(ContactID!=null)
        {
            newCr = true;            
            User us = [select Id,Name from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            OwnerName = us.Name;            
            cr.OwnerId = us.Id;
            cr.ZTS_EU_Contact__c= ContactID;
            cr.ZTS_EU_Object_Type__c = 'Contact';                             
            cr.ZTS_EU_Requestor__c = us.id;                             
        }
        if(AccId == null && ContactID == null )
        {
            newCr = true;            
            User us = [select Id,Name from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'];
            OwnerName = us.Name;            
            cr.OwnerId = us.Id;
            cr.ZTS_EU_Requestor__c = us.id;
        }
        return new PageReference('/apex/ChangeRequestEditSubmitPage');
    }

    public PageReference UpdateCR()
    {
        if(edit)
        {
            update cr;
        }
        if(newCr)
        {
            cr.ZTS_EU_Object_Type__c = 'Empty';
            insert cr;
        }
        
        return new PageReference('/'+cr.id);
    }
    public PageReference updateandSumbit()
    {
         if(edit)
        {
            update cr;
        }
        if(newCr)
        {
            insert cr;
        }
        ZTS_EU_submit_CR_record.submitRecord(cr.id);
        return new PageReference('/'+cr.id);
    }
    public PageReference cancelCR()
    {
        if(edit)
        {
            return new PageReference('/'+cr.id);    
        }
        if(newCr)
        {
            if(AccId == null && ContactID == null)
            {
                return new PageReference('/a1e/o'); 
            }
            if(AccId !=null && ContactID == null)
            {
                return new PageReference('/'+AccId);    
            }
            if(AccId ==null && ContactID != null)
            {
                return new PageReference('/'+ContactID);    
            }
            
        }
        return null;
    }
}