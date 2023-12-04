({
	doInit : function(component, event, helper) {
        component.set('v.loading', true);
        helper.getSegmentationData(component);
    },
})