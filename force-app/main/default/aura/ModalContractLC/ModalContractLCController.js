({
    handleConfirmDialogYes : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        //helper.doRedirect(component, event, helper, true);
    }
})