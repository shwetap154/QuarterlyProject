/*************************************************************************************
* Name          :    TaskContoller.
* Description   :    Controller for adding TAsk from call page.
* Author        :    Teresa Sebastian
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
01/27/2014       Teresa Sebastian            Created

**************************************************************************************/
public with sharing class ZTS_EU_Task_Controller{
    public String callId{get; set;}
    public String userId{get; set;}
    public Task task{get; set;} 
    
    public ZTS_EU_Task_Controller(ApexPages.StandardController controller) {
         PageReference pageRef = ApexPages.currentPage();
         task = new Task();
         task.whatId = pageRef.getParameters().get('callId');
         task.ownerId = pageRef.getParameters().get('userId');
    }

     public PageReference cancel() {
        return null;       
    }
    
    public PageReference save() {
        upsert task;
        return null;      
    }
}