({
        redirect : function(component, event, helper) {
                component.set('v.isLoading', true);
                helper.getInfo(component, event);
        },
        
        exit : function(component, event, helper) {
                helper.redirectTolistView(component.get('v.sObjectName'), component.get('v.listViewDetails'));
        },
})