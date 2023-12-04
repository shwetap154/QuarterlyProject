({
	deepCloneAccount : function(component) {
		var action = component.get("c.deepCloneAccountAndRelatedRecords");
        var recordId = component.get('v.recordId');
        action.setParams({
            "accountId" : recordId
        });
        
        action.setCallback(this, function(response) {
            
            let state = response.getState();
            if (state === "SUCCESS") {
                let returnValue = response.getReturnValue();
                console.log('New Record:',returnValue);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "New Account record created successfully."
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": returnValue
                });
                navEvt.fire();
            }
            else if (state === "ERROR") {
                
                let errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    $A.get("e.force:closeQuickAction").fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Something went wrong!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                }
            }
        });

        $A.enqueueAction(action);
	}
})