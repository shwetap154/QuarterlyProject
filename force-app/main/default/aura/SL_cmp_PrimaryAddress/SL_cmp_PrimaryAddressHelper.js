({
	showMessage : function(title, type, mode, message) 
    {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "mode": mode,
            "message": message
        });
        toastEvent.fire();
    }
})