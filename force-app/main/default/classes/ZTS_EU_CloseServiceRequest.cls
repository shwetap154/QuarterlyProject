/*************************************************************************************
* Name          :    ZTS_EU_CloseServiceRequest.
* Description   :    A service request can only be closed if there are no remaining open
                     tasks or events related to the service request .
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
04/15/2014       Deloitte Constulting/Sunil Kumar           Created
04/16/2014       Deloitte Constulting/Teresa S              Modified
08/06/2020       Salesforce Daniel Shaheen                  Modified (Added-8-6-2020)

**************************************************************************************/
public with sharing class ZTS_EU_CloseServiceRequest {
    
    /***********
            * Method name  : checkTasksForServiceRequest
            * Description  : This will check if there are tasks open against the Service Request and throw error.
            * Return Type  : none.
            * Parameters   : Trigger parameters.
 ***********/
     public static void checkTasksForServiceRequest(List<Case> triggerNew, Map<Id,Case> triggerOldMap){
        try{
            system.debug('**********triggerNew***********'+triggerNew);
            List<Task> relatedServiceRequestTask = [SELECT Status,whatId, Id from Task where whatId =: triggerNew and Status != 'Completed'];
            //Added-8-6-2020
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Open_Service_Request').getRecordTypeId();
            system.debug('####'+recordTypeId);
            Set<Id> serviceReqIds = new Set<Id>();
            for(Task task : relatedServiceRequestTask){
                serviceReqIds.add(task.whatId);
            }
            system.debug('************serviceReqIds**************'+serviceReqIds);
            system.debug('************relatedServiceRequestTask **************'+relatedServiceRequestTask );
            for(Case sr : triggerNew){
            system.debug('************sr**************'+sr.Status);
            system.debug('************triggerOldMap.get(sr.id).Status**************'+triggerOldMap.get(sr.id).Status +'##'+ sr.recordTypeId);
               //Modifed 8-6-2020
                if(sr.Status == 'Closed' && triggerOldMap.get(sr.id)!= null && triggerOldMap.get(sr.id).Status != 'Closed' && sr.recordTypeId == recordTypeId){
                    if(serviceReqIds != null && serviceReqIds.contains(sr.Id)){
                        sr.addError('This Service Request has Tasks Open. Please close them before closing the Service Request');
                    }
                }
            }
                
                
    //    }catch(DmlException e) {
    //            ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_CloseServiceRequest-checkTasksForServiceRequest');
        }catch(Exception ex) {
                ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_CloseServiceRequest-checkTasksForServiceRequest');
        }
     }
}