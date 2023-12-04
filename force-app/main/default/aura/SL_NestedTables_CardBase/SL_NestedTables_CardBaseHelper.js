({
	getProfileAccessForMainObject : function (cmp, evt, hlpr) {
        
    	var objName = cmp.get('v.mainObjectName');
    	
        var action = cmp.get("c.getProfileAccessForMainObj");
        action.setParams({
            "selectedObject": cmp.get('v.mainObjectName')
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.profileAccessForObject", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
	}   
})