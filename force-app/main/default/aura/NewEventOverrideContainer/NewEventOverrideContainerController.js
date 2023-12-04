/* <!--
 -Created by Aritra Chakraborty on 18-June-2021 for SC-004726.
 -->*/

({  
    
    doInit: function(component, event, helper) {
        var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  
        var salesCallRTId = $A.get("$Label.c.SalesCallEventRecordTypeID");
        //alert('recordTypeId==>' +salesCallRTId);
        
        if(recordTypeId !== salesCallRTId)
        {
            var createEvent = $A.get("e.force:createRecord");
            createEvent.setParams({
                "entityApiName": "Event",
                "recordTypeId":  recordTypeId
            });
            createEvent.fire();
        }
        else{
            var createCall = $A.get("e.force:navigateToComponent");
            createCall.setParams({
                         componentDef : "c:PageOverrideContainer",
                         componentAttributes: {}
           });
           createCall.fire();
        }
        
    } 
})