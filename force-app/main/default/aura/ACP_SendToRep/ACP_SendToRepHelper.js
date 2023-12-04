({
    sendToRep : function(component) {
        var action = component.get("c.acpUpdStatusAndNotify");
        var recordId = component.get('v.recordId');
        
        action.setParams({
            "strRecId" : recordId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var warningMessage = "Record Updated and Email Sent."
                this.setToastMessages(component,warningMessage,'success');
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }), 2000);
            }
            else if (state === "ERROR") {
                var errors = response.getError();            
                var warningMessage = "Error While Updating the Record and Sending Email: " + errors[0].message;
                this.setToastMessages(component,warningMessage,'error');
            }
        });
        
        $A.enqueueAction(action);
        
        
    },
    
    setToastMessages : function(component, message, toastType){
        var iconType = 'utility:warning';
        var slds = 'slds-notify slds-notify_toast slds-theme_warning';
        if(toastType==='error'){
            iconType = 'utility:error';
            slds = 'slds-notify slds-notify_toast slds-theme_error';
        }
        if(toastType === 'success'){
            iconType = 'utility:success';
            slds = 'slds-notify slds-notify_toast slds-theme_success';
        }
        
        component.set("v.showWarningToast", true);
        component.set("v.toastHeadMsg",message);
        component.set("v.toastType", toastType);
        component.set("v.utilityIconType", iconType);
        component.set("v.divForToast", slds);
    }
})