({
    showToast: function (component, event, error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: error,
            key: 'info_alt',
            type: 'error',
        });
        toastEvent.fire();
    },
    doRedirect: function (component, event, helper) {

        var errorMsg = component.get("v.errorMsg");
        var error = (errorMsg)? 'You cannot create a Speaker Fee record on a Contact which does not have the Speaker Flag checked.':'Error Ocurred';
        // var urlEvent = $A.get("e.force:navigateToURL");
        // var contId = component.get("v.contId");
        // urlEvent.setParams({
        //   "url": 'https://touchpointeca--slalomdev1.lightning.force.com/lightning/r/'+contId+'/view'
        // });
        // urlEvent.fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        var contId = component.get("v.contId");
        navEvt.setParams({
            "recordId": contId
        });
        navEvt.fire();
        helper.showToast(component, event, error);
    },

    doRecCreate: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var contId = component.get("v.contId");
        var LOOKUP = 'LOOKUP'; 
        createRecordEvent.setParams({
        "entityApiName": "ZTS_US_Speaker_Fee__c", 
        "defaultFieldValues": { 
            "ZTS_US_Contact__c": contId
        },
        "navigationLocation":LOOKUP,
        "panelOnDestroyCallback": function() {
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: contId
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