({
    doCreateCalEvt : function(component, event, helper) {
        var event = component.get("v.eventId");
        var pass =  false;
        if (event != 'null' && event != ''){
            helper.fileDownload(component, event, helper);
            pass =  true;
        }
        
        helper.doRedirect(component, event, helper, pass);

    },

    fileDownload: function (component, event, helper) {
        var urlString = window.location.href;
        var event = component.get("v.eventId");
        var baseURL = urlString.substring(0, urlString.indexOf('force.com/')+10);
        window.open( 
            baseURL+'/servlet/servlet.OutlookEvent?rnd=1234567890123&id='+event,'DETAIL','vcal'
        );

    },

    doRedirect: function (component, event, helper, pass) {
        //Redirecting back to View page for Contract record
        var recordId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
        if (!pass){
            var error = 'No Calendar Event ID found on this Time Off Territory record.';
            helper.showToast(component, event, error);
        }
    },

    showToast: function (component, event, error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: error,
            key: 'info_alt',
            type: 'error',
        });
        toastEvent.fire();
    },
})