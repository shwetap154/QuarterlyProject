({
	helperMethod : function(component, event, helper) 
	{
	     var action = component.get("c.updateCoaching");
        
         action.setParams({
            "strRecordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            
            if(state == 'SUCCESS')
                component.set("v.isSuccess", true);
            window.location.reload();
        });

        $A.enqueueAction(action);
	}
})