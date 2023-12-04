({
	doInit : function(cmp, event, helper) 
    {
        var action = cmp.get('c.getUrl'); 
		
        action.setParams(
                        {
                            "recordId" : cmp.get('v.recordId') 
                        }
        				);
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') 
            {
               var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": a.getReturnValue()
                });
                urlEvent.fire();

            }
        });
        $A.enqueueAction(action);
        
        
	},
    
    showSpinner: function(cmp, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        cmp.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(cmp,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        cmp.set("v.spinner", false);
    }
})