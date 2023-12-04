({
    validateDeal: function(component, event, helper) {      
        this.callApex(component, "c.processDeal", {
            dealId: component.get("v.recordId")
        }).then(function(response) {
            component.set("v.loaded", false);
            var toastEvent = $A.get("e.force:showToast");
            let params = { message: response.Message };
            if (response.Status === "OK") {
                $A.get("e.force:refreshView").fire();
                params.title = "Success!";
                params.type = "success";
            } else {
                params.title = "Error!";
                params.type = "error";
            }
                    
            toastEvent.setParams(params);
            toastEvent.fire();
            closeModal.fire();
            $A.get('e.force:refreshView').fire();
        });
    }, 
    buildDeal: function(component, event, helper) {      
        const closeModal = $A.get("e.force:closeQuickAction");   
        this.callApex(component, "c.processDeal", {
            dealId: component.get("v.recordId")
        }).then(function(response) {
            component.set("v.loaded", false);
            var toastEvent = $A.get("e.force:showToast");
            let params = { message: response.Message };
            if (response.Status === "OK") {
                $A.get("e.force:refreshView").fire();
                params.title = "Success!";
                params.type = "success";
            } else {
                params.title = "Error!";
                params.type = "error";
                params.mode = "sticky";
            }
                    
            toastEvent.setParams(params);
            toastEvent.fire();
            closeModal.fire();
            $A.get('e.force:refreshView').fire();
        });
    }, 
    
    callApex: function(component, methodName, params) {
    component.set("v.loaded", true);
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
          } else if (results.getState() === "ERROR") {
            console.log("callApex() ERROR", results.getError());
            $A.log("Errors", results.getError());
            reject(results.getError());
          }
          component.set("v.loaded", false);
        });

        $A.enqueueAction(action);
      })
    );
  }
      
})