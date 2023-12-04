({
    doInit : function(component, event, helper) {
        var action = component.get("c.updateAbstractSummary");
        action.setParams({
            "eventNarrativeRecordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                //alert("Narrative Template Updated");
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        //helper.closePage(component, event, helper);
        //setTimeout(function(){ alert("Hello");
         //                    helper.closePage(component, event, helper);}, 3000);
        
    }
     
    
    
})