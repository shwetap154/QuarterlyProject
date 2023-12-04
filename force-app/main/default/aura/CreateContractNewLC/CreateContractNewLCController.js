({
    doInit : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        // var contId = component.get("v.contId");
        var LOOKUP = 'LOOKUP'; 
        createRecordEvent.setParams({
        "entityApiName": "Contract", 
        "defaultFieldValues": { 
            "Name": '-AutoPopulates on Save-'
        },
        "navigationLocation":LOOKUP,
        "panelOnDestroyCallback": function() {
            var pageReference = {
                "type": "standard__objectPage",
                "attributes": {
                    "objectApiName": "Contract",
                    "actionName": "home"
                }
            };
            var navService = component.find("navService");
            // Uses the pageReference definition in the init handler
            //event.preventDefault();
            navService.navigate(pageReference);
        }
        });
        createRecordEvent.fire();
    }
})