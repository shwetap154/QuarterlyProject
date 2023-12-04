/*({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var templateId = myPageRef.state.c__recordId;
        component.set("v.recordId",templateId);
        helper.doEditAffiliationEvt(component, event, helper);

    },
    
    handleSaveSuccess: function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var templateId = myPageRef.state.c__recordId;
        component.set("v.recordId",templateId);
        helper.doViewAffiliationEvt (component, event, helper);
    }
})*/

//Aritra commented out the old controller code and rewrote the controller for SC-008143

({
	handleSave: function(component, event, helper) {
		component.find("edit").get("e.recordSave").fire();
	},
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var templateId = myPageRef.state.c__recordId;
        component.set("v.recordId",templateId);

    },
    close : function(component, event, helper) { 
            //var url = window.location.href; 
            //var value = url.substr(0,url.lastIndexOf('/') + 1);
            window.history.back();
            return false;
        
    },
    onSaveSuccess: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
        var isConsole = response;
            if(!isConsole) {
                var navService = component.find("navService");
                var pageRef = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": component.get("v.recordId"),
                        "actionName": "view"
                        
                    }
                    
                };
                navService.navigate(pageRef);
                $A.get('e.force:refreshView').fire();
            }
        })
        .catch(function(error) {
            console.log(error); 
        });
        
    },
    
})