({
    passParamToCreateSamples : function(component) {
        
        var recordId = component.get('v.recordId');
        var action = component.get("c.createSamples");
        action.setParams({
            "recordId" : recordId
        });
        
        action.setCallback(this, function(response) {
			
            $A.get("e.force:closeQuickAction").fire();
            var state = response.getState();
            console.log('state!!',state);
            if (state === "SUCCESS") {
                this.showToast('Success!', 'success', 'dismissible', 
                               'Samples are being created for this record. Please allow up to 15 minutes before refreshing.');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                this.showToast('Error!', 'error', 'sticky', errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title, type, mode, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "mode": mode,
            "message": message
        });
        toastEvent.fire();
    }
})