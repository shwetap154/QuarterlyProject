({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var totId = myPageRef.state.c__recordId;
        component.set("v.recordId",totId);
        var eventId = myPageRef.state.c__event;
        component.set("v.eventId",eventId);

        helper.doCreateCalEvt(component, event, helper);
    }
})