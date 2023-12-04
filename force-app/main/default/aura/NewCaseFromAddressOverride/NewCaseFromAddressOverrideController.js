({
    redirect: function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.getInfo(component, event,helper);
    },
    
    exit: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    callgetinfo: function(component, event, helper) {
        helper.getInfo(component, event);
        
    },
    callrecordtypeselection: function(component, event, helper) {
        helper.handleRecordTypeSelection(component, event);
    },
    callhandleclick: function(component, event, helper) {
        helper.handleClick(component, event, helper);
    },
    recordUpdate: function(component, event, helper) {
        if (component.get("v.record").ZTS_EU_Contact__c){ //check if the Address has Contact
            component.set("v.contactId", component.get("v.record").ZTS_EU_Contact__c);
        }
        
        
        if (component.get("v.record").ZTS_EU_Account__c){ //check if the Address has Account
            component.set("v.accountId", component.get("v.record").ZTS_EU_Account__c);
        }else{ //Address doesn't have an Account
            //attempt to get the Account from Address's Contact
            if (component.get("v.record").ZTS_EU_Contact__c){
                var getContactAction = component.get("c.getAccountIdFromContact");
                getContactAction.setParams({ contactId: component.get("v.record").ZTS_EU_Contact__c });
                getContactAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if(response.getReturnValue().length > 0){
                            component.set("v.accountId", response.getReturnValue());
                        }
                    }
                });
                $A.enqueueAction(getContactAction);
            }
        }
        
        component.set("v.addressId", component.get("v.recordId"));
    },
    closeModel: function(){
        $A.get("e.force:closeQuickAction").fire();
    }
});