({
    doInit : function(component, event, helper) {
        let action = component.get("c.isInternationalUser");
        action.setCallback(this, function(response) {
            let isInternationalUser = response.getReturnValue();
            if (isInternationalUser === true) {
                let urlEvent = $A.get("e.force:navigateToURL");

                const searchString = window.location.search;
                let accountFieldValue;
                if(searchString) {

                    const base64EncodedString = searchString.split('?')[1].split('=')[1].substring(2).split('&')[0];

                    const decodedString = decodeURIComponent(base64EncodedString);
                    
                    const accObj = JSON.parse(atob(decodedString));

                    accountFieldValue = accObj.attributes.recordId; 
                }
                urlEvent.setParams({
                    "url": "/apex/SalesCallDetails?accountId="+accountFieldValue,
                    "isredirect": "true"
                });
                urlEvent.fire();
            }
        });
        $A.enqueueAction(action);

    },

    closeChildLWC : function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
})