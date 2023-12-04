({
	getPrepareDocumentURL : function(component) {
		var action = component.get("c.fetchPrepareDocumentURL");
        var recordId = component.get('v.recordId');
        
        action.setParams({
            "strRecordId" : recordId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null){
                	component.find("navigationService").navigate({ 
                        type: "standard__webPage", 
                        attributes: { 
                            url: result
                        } 
                    });
                }
                else
                    component.set("v.isError", true);
            }
            else if (state === "ERROR") {
                $A.get("e.force:closeQuickAction").fire();
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