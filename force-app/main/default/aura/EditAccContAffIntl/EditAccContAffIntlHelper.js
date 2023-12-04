/*({
    doEditAffiliationEvt : function(component, event, helper) {
        alert('hi edit')
        var recordId = component.get("v.recordId");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": recordId,
                "actionName": "view",
                "objectApiName": "ZTS_EU_Affiliations__c"
            },
            "state":{
                "nooverride":"1"
            }
        };

        var navService = component.find("navService");
        //navService.navigate(pageReference);
        pageReference.attributes.actionName = "edit";
        navService.navigate(pageReference);
    }
})*/
//Aritra commented the handler class code as the is now being done from controller itself (SC-008143)
({
    doEditAffiliationEvt : function(component, event, helper) {
    }
    
})