({
    doInit : function(component, event, helper) 
    {
        let requestId = component.get("v.recordId");
        let action = component.get("c.updatePrimaryaddress");

        action.setParams({
            "addressId" : requestId
        });
        
        action.setCallback(this, function(response) {
            
            let cssClass = 'slds-notify slds-notify_toast slds-theme_'
            let state = response.getState();
            if (state === "SUCCESS") 
            {   
                cssClass += 'success';

                component.set('v.showMessage', true);
                component.set('v.messageClass', cssClass);
                component.set('v.assistiveText', 'Success');
                component.set('v.message', 'Address is made Primary.');
                window.setTimeout(
                    $A.getCallback(function() {
                        window.location.reload();
                    }), 1500
                );
                
            }
            else if (state === "ERROR") 
            {

                let errors = response.getError();
                cssClass += 'error';
                component.set('v.showMessage', true);
                component.set('v.messageClass', cssClass);
                component.set('v.assistiveText', 'Error');
                component.set('v.message', errors[0].message);

            }
        });
        
        $A.enqueueAction(action);
    }
    
})