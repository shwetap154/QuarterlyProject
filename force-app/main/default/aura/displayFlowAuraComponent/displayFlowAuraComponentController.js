({
	doInit : function(component, event, helper) {
        var type = component.get("v.pageReference").state.c__type;
        var flow = component.find("flowData");
        var inputVariables = [
        {
            name : 'recordId',
            type : 'String',
            value : component.get("v.pageReference").state.c__inputVariable
        }
        ];
        flow.startFlow(type,inputVariables);
	},
    onPageReferenceChanged : function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})