({
	helperMethod : function(component, event, helper) 
	{
	    var recordIdVar = component.get("v.recordId");
	    
        var action = component.get("c.updateAccount");
        
        action.setParams({
            "strRecordId" : recordIdVar
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") 
                window.location.reload();
            else if (state === "ERROR") 
            {
                var errors = response.getError();
                if (errors) 
                {
                    var message = 'Unknown error: ';
                    if (errors && Array.isArray(errors) && errors.length > 0) 
                    {
                        message = errors[0].message;
                        component.set('v.strMessage', message);
                        component.set("v.isError", true);
                    }
                }
                else 
                {
                    component.set("v.isError", true);
                    component.set('v.strMessage', 'Unknown error');
                }
                    
            }
        });

        $A.enqueueAction(action);
	}
})