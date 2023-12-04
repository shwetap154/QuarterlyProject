({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var targeting = myPageRef.state.c__campTargeting;
        console.log('targeting   :::: '+targeting);
        if (typeof targeting === 'undefined') component.set("v.targeting",'');
        else component.set("v.targeting",targeting);

        var myPageRef = component.get("v.pageReference");
        var campaignId = myPageRef.state.c__campId;
        component.set("v.campaignId",campaignId);

        helper.doRedirect(component, event, helper);
    }
})