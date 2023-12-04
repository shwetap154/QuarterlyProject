({  
    init : function(cmp, event, helper) 
    {   
        var pageRef = cmp.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        
        // For some reason, the string starts with "1.", if somebody knows why,
        // this solution could be better generalized.
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        let recordId = addressableContext.attributes.recordId,
            objectApiName = addressableContext.attributes.objectApiName,
            objCase = {};
            objCase.objectApiName = objectApiName;
            objCase.filterName = addressableContext.state.hasOwnProperty('filterName') ? addressableContext.state.filterName : '';
          
        
        // fectch the data
        var action = cmp.get('c.fetchInitData');
        action.setParams({recordId : recordId});
        action.setCallback(this, function(res) {
            var state = res.getState();

            if (state === "SUCCESS") {
                var details = res.getReturnValue();

                objCase.userMarket = '';
                objCase.createContactFS  = details.newContactFieldSet;
                objCase.createPetOwnerContactFS  = details.newPetOwnerContactFieldSet;
                if(objectApiName == 'Contact') {
                    cmp.set('v.displayCaseComponent', true);
                    objCase.ContactId = recordId;
                    objCase.AccountId = details.recordInfo.AccountId;
                    objCase.ContactName = details.recordInfo.Name;
                    objCase.AccountName = details.recordInfo.Account.Name;
                    objCase.userMarket = details.recordInfo.Account.ZTS_EU_Market__c;
                }

                if(objectApiName == 'Account') {
                    objCase.AccountId = recordId;
                    objCase.AccountName = details.recordInfo.Name;
                    objCase.userMarket = details.recordInfo.ZTS_EU_Market__c;
                    cmp.set('v.activeSectionName', 'SAPSearch');

                }
            }
            
            cmp.set('v.objCase', objCase);
        });
        $A.enqueueAction(action);

        cmp.set("v.objCase", objCase);
    },

    onNewCaseReset : function(cmp, event, helper) {
        let isSearchErased = event.getParam('isSearchErased');
        if(isSearchErased) {
            let objCase = cmp.get('v.objCase');
            let cpCase = {};
            cpCase.objectApiName = objCase.objectApiName;
            cpCase.filterName =objCase.filterName;
            cpCase.createContactFS  = objCase.createContactFS;
            cpCase.createPetOwnerContactFS  = objCase.createPetOwnerContactFS;
            cmp.set('v.objCase', cpCase);
            cmp.set('v.activeSectionName', 'AccountSearch');
            cmp.set('v.displayAccComponent', true);
            cmp.set('v.displayContactComponent', false);
            cmp.set('v.displayCaseComponent', false);

        }
    },
    //Added to force reset for non console bug discovered after Org Con go-live Aug 2020
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})