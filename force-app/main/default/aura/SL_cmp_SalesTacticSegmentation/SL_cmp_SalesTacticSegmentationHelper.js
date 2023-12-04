({
	getSegmentationData : function(component) {
        
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var action = component.get('c.fetchSegmentationData');
        var recordId = component.get('v.recordId');
        action.setParams({
            AccountId : recordId
        });
        
        action.setCallback(this, function(res) {
            
            $A.util.toggleClass(spinner, "slds-hide");
            let SegmentationData = res.getReturnValue();
            component.set('v.lstSegmentaionData', SegmentationData);
            
        });
        $A.enqueueAction(action);
    },
})