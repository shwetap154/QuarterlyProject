({
    notifyUser : function(title, message, variant) {
         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": variant
        });
        toastEvent.fire();
    },

    callApex: function(component, methodName, params) {
		return new Promise(
			$A.getCallback(function(resolve, reject) {
				var action = component.get(methodName);
				
				if (params) {
					action.setParams(params);
				}

				action.setCallback(this, function(results) {
					console.log(methodName + " results", results);
					
					if (results.getState() === "SUCCESS") {
						console.log("results:", results.getReturnValue());
						resolve(results.getReturnValue());
					}
					else if (results.getState() === "ERROR") {
						console.log("callApex() ERROR", results.getError());
						$A.log("Errors", results.getError());
						reject(results.getError());
					}
				});

				$A.enqueueAction(action);
			})
		);
    },

    closeModal: function() {
        $A.get("e.force:closeQuickAction").fire();
    }
})