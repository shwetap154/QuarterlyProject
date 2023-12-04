({
    onPageReferenceChange: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var invts = myPageRef.state.c__listofInvitees;
        cmp.set("v.listofInvitees",invts);

        var pName = myPageRef.state.c__pageName;
        cmp.set("v.pageName",pName);

        var eveId = myPageRef.state.c__eventId;
        console.log('eveId ::: '+eveId);
        cmp.set("v.eventId",eveId);
    },

    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})