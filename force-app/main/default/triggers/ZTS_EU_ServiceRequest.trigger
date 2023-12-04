/*************************************************************************************
* Name          :    ZTS_EU_ServiceRequest .
* Description   :    Trigger used to throw Error Message in case there are open
*                    tasks when Service Request is being closed.
* Author        :    Teresa
 
Modification Log4/16/2014        Teresa                    Created
5/4/2015         Priya Krishnamurthy       Modified
10/21/2022       Ethan Hirsch @ Zoetis Inc Remove logic for automatically setting Market from User. This will now be set through a Flow CASS-881
**************************************************************************************/
trigger ZTS_EU_ServiceRequest on Case (before insert,after insert,before update,after update) {
    // Get custom setting value to check if this trigger is for bypassing
    if(!CustomSettingService.checkIfTriggerIsForBypass('ZTS_EU_ServiceRequest') ) return;
    if(DispatchTriggerHandler.checkCustomSettingBypass(Automation_Bypass__c.Case_Bypass__c)) return;
    
    // Srinivas K Part of SC-002115 assiging user market to case market 
    if(trigger.isBefore && trigger.isInsert) {
        // Added as part of LIGHTNI-1662
        new SL_CaseTriggerHandler().onBeforeInsert(Trigger.new);
        // See the After Update method for details on the Trigger Handler
        // This runs after SL_CaseTriggerHandler.onBeforeInsert as the method transfered to DiagnosticCaseTriggerHandler, beforeInsertUpdateOnBoardingCaseStatus,
        // ran after another method beforeInsertUpdatePrimaryLabLocation. Changing the order would impact the behavior of this method.
        new DiagnosticCaseTriggerHandler().onBeforeInsert(Trigger.new); 
    }

    // to insert an Calendar event with the 'needed by' date field 
    if(trigger.isAfter && trigger.isInsert)
    {
       
        new SL_CaseTriggerHandler().onAfterInsert(Trigger.new);

        List<Event> lstNewEvents = new List<Event>();
        for ( Case eve : Trigger.new )
        {
            if ( eve.ZTS_EU_Needed_By__c == null ) continue;
            lstNewEvents.add
            (   new Event
                (   StartDateTime = eve.ZTS_EU_Needed_By__c
                ,   EndDateTime = eve.ZTS_EU_Needed_By__c.addseconds(1800)
                ,   Subject = 'Service Request: ' + eve.CaseNumber
                )
            );
        }
        insert lstNewEvents;   
    }

    if(trigger.isBefore && trigger.isUpdate) {
        // Added as part of LIGHTNI-1662 
        new SL_CaseTriggerHandler().onBeforeUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
        
        ZTS_EU_CloseServiceRequest.checkTasksForServiceRequest(Trigger.New,Trigger.oldMap);  
    }
    // After Update Trigger
    // Added by Apurva Verma @ Slalom for CSE-333
    // To send email alerts to Account Positions (team members) with SIB Flag as true

    if(trigger.isAfter && trigger.isUpdate) {
        // Added a Separate Trigger Handler for Diagnostic Specific Case Logic.
        // Since Cases are going through a large expansion during Customer Service Expansion,
        // Case logic should be split between separate type-specific handlers to remove dependencies 
        // and better address potential merge conflicts
        new DiagnosticCaseTriggerHandler().onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        
        new SL_CaseTriggerHandler().onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        new SL_CaseTriggerHandler().sendEmail(Trigger.new, Trigger.oldMap );
    }
}