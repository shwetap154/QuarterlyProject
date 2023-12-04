({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
    },
    
    submit : function(component, event, helper) {
        let record = component.get("v.timeOffTerritoryRecord");
        if( record.ZTS_EU_Status__c != 'Submitted') {
            record.ZTS_EU_Status__c = 'Submitted';
            component.set("v.timeOffTerritoryRecord", record);
            return;
        }
        component.find("TOTRec").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                helper.showToast('success', 'Success!', 'Submitted Successfully.');
            } else if (saveResult.state === "INCOMPLETE") {
                helper.showToast('error', 'INCOMPLETE!', "User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") { 
                var errMsg = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                helper.showToast('error', 'ERROR!', errMsg);
            } else {
                helper.showToast('error', 'ERROR!', 'Unknown problem, state: ' + saveResult.state + ', error: ' + 
                              JSON.stringify(saveResult.error));
            }
            component.set('v.isLoading', false);
        }));
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();  
    },
})