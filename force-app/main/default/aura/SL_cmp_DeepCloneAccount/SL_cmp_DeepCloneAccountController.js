({
	doInit : function(component, event, helper) {
        
        let result = confirm("Are you sure you want to Deep Clone this Account?");
        if (result == true) {
            helper.deepCloneAccount(component);
        } else {
            window.setTimeout(
                $A.getCallback(function() {
                    $A.get("e.force:closeQuickAction").fire();
                }), 1
            );
        }
	}
})