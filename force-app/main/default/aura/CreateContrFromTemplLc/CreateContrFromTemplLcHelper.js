({
    doCreateContractEvt : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var createRecordEvent = $A.get("e.force:createRecord");
        var LOOKUP = 'LOOKUP'; 
        createRecordEvent.setParams({
        "entityApiName": "Contract", 
        "defaultFieldValues": { 
            "ZTS_EU_Discount__c": component.get("v.discVal"),
            "ZTS_EU_Related_Contract_Template__c": recordId
        },
        "navigationLocation":LOOKUP,
        "panelOnDestroyCallback": function() {
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: recordId
                }
            };
            var navService = component.find("navService");
            // Uses the pageReference definition in the init handler
            //event.preventDefault();
            navService.navigate(pageReference);
        }
        });
        createRecordEvent.fire();
    },

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
        var urlEvent = $A.get("e.force:navigateToURL");
        var contId = component.get("v.recordId");
        urlEvent.setParams({
          "url": 'https://touchpointeca--slalomdev1.lightning.force.com/lightning/r/'+contId+'/view'
        });
        urlEvent.fire();
        helper.showToast(component, event, error);
    },
})