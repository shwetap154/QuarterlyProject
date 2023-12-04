({
    doRecCreate: function (component, event, helper) {
        var recAccount = component.get("v.account");
        console.log(' recAccount  :::: '+recAccount);
        console.log(' recAccount  :::: '+recAccount.Id);
        var createRecordEvent = $A.get("e.force:createRecord");
        // var contId = component.get("v.contId");
        var LOOKUP = 'LOOKUP'; 
        createRecordEvent.setParams({
        "entityApiName": "Contract", 
        "defaultFieldValues": { 
            "Name": '-AutoPopulates on Save-',
            "AccountId": recAccount.Id
        },
        "navigationLocation":LOOKUP,
        "panelOnDestroyCallback": function() {
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: recAccount.Id
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