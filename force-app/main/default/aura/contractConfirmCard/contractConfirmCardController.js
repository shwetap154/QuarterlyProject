({
    handleConfirmDialogYes : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        var compEvent = component.getEvent("cmpEvent");
        // Optional: set some data for the event (also known as event shape)
        // A parameter’s name must match the name attribute
        // of one of the event’s <aura:attribute> tags
        compEvent.setParams({"evtConfirmed" : true });
        compEvent.fire();
    },
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        var compEvent = component.getEvent("cmpEvent");
        compEvent.setParams({"evtConfirmed" : false });
        compEvent.fire();
    },
    doInit : function(component, event, helper) {
        var test = component.get('v.message');
        console.log('test >>> '+ test);
        
    }
})