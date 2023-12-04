({
    showToast: function (component, event, error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: error,
            key: 'info_alt',
            type: 'error',
        });
        toastEvent.fire();
    },
    doRedirect: function (component, event, helper) {

        //Find the text value of the component with aura:id set to "address"
        var targeting = component.get("v.targeting");
        console.log('gettargeting  ::: '+targeting);
        var error = (targeting === 'Open')? 'Please select at least one record':'You cannot add or remove Targeted Accounts if Campaign Field Targeting is Closed';
        var urlEvent = $A.get("e.force:navigateToURL");
        var campaignId = component.get("v.campaignId");
        urlEvent.setParams({
          "url": 'https://touchpointeca--slalomdev1.lightning.force.com/lightning/r/'+campaignId+'/related/Targeted_Accounts__r/view'
        });
        urlEvent.fire();
        helper.showToast(component, event, error);
    }
})