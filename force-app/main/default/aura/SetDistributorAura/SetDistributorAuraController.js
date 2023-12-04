({
    init : function (component) {
        
        console.log('PageReference Attrib: ' + component.get('v.pageReference').state.c__quoteId);        

        var inputVariables = [
            { name : "recordId", type : "String", value: component.get('v.pageReference').state.c__quoteId }]

        
        //var recordId = component.get('v.pageReference').state.c__quoteId;

        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");

        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Set_Distributor_Quote",inputVariables);
    },
    
    handleStatusChange : function (component, event) {

        console.log('entering handleStatusChange');
        
        if(event.getParam("status") === "FINISHED") {
            
            var quoteId = component.get('v.pageReference').state.c__quoteId;            
            console.log('flow has finisehd, quoteID: ', quoteId);
            
            let link = '/apex/sbqq__sb?scontrolCaching=1&id=' + quoteId 
            + '#quote/le?qId=' + quoteId;
            var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": link
            });
        
            urlEvent.fire();
        }
     }
})