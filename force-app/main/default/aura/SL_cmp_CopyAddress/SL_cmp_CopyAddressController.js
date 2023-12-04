({
	doInit : function(component, event, helper) 
	{
        var action = component.get("c.updateContactAddress");
        
         action.setParams({
            "affiliationRecordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            
            window.location.reload();
        });

        $A.enqueueAction(action);
	}
})