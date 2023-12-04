({
    doInit : function(component, event, helper) {

        var myPageRef = component.get("v.pageReference");
        var strTerrIds = myPageRef.state.c__strTerrIds;
        component.set("v.strTerrIds",strTerrIds);

        var retURL = myPageRef.state.c__retURL;
        component.set("v.retUrlString",retURL);

        helper.removeTerritories(component, event, helper);
    }
})