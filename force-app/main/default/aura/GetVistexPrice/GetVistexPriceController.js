({
	doInit : function(component, event, helper) {
        var callingFromQLE = component.get('v.callingFromQLE');
		var action = component.get('c.getVistexPriceFromLightning');

        action.setParams({
            'quoteId': component.get('v.recordId')
        });

        action.setCallback(this, function(results) {
            
            console.log('getVistexPriceFromLightning', 'Doing callback');
            
            if (results.getState() === 'SUCCESS') {
                
                console.log('getVistexPriceFromLightning', 'Callback Success');

                var statusMessage = results.getReturnValue();
                
                // SUCCESS - Calling from Quote Record page
                if (statusMessage == '' && !callingFromQLE) {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                // SUCCESS - Calling from QLE
                else if (statusMessage == '' && callingFromQLE) {
                    component.set('v.loading', false);
                    component.set('v.statusMessage', statusMessage);
                }
                // INFO 
                else {
                    console.log('getVistexPriceFromLightning STATUS', statusMessage);
                    
                    component.set('v.loading', false);
                    component.set('v.statusMessage', statusMessage);
                }

            } else {
                console.log('getVistexPriceFromLightning ERROR', results.getError());

                $A.log('Errors', results.getError());

                let errors = results.getError();
                console.log(errors);
                
                let message = errors[0].message;
                
                component.set('v.loading', false);
                component.set('v.errorMessage', message + '\n\r' +
                    'There was an error on the Vistex call. Please contact a Zoetis Administrator.' );
            }
        });

        $A.enqueueAction(action);
	}
})