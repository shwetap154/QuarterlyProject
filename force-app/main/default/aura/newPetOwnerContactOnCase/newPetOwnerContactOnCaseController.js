({
    openModal : function(cmp, event, helper) {
        cmp.set('v.showModal', true);
        cmp.set('v.showSpinner', true);

    },

    closeModal : function(cmp, event, helper) {
        cmp.set('v.showModal', false);
    },

    handleError : function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
    },

    saveContact :function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        cmp.find('createPetOwnerContactForm').submit();
        
    },
    
    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        var action = cmp.get("c.getPetOwnerRecTypeId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Recordtype from controller'+JSON.stringify(result));
                cmp.set("v.recordType", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSuccess : function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        cmp.set('v.showModal', false);
        let objCase = cmp.get('v.objCase');
        objCase.ContactId = event.getParam('response').id;
        objCase.ContactName = event.getParam('response').fields.FirstName.value + ' '+ event.getParam('response').fields.LastName.value;
        cmp.set('v.objCase', objCase);
        var action = cmp.get( "c.searchContacts" );
            action.setParams({
                lstAccountId : objCase.AccountId
            });
            
            action.setCallback( this, function( response ) 
            {
                var event = $A.get( "e.c:contactsLoaded" );
                
                var state = response.getState();
    
                if(state === "SUCCESS") {
                    event.setParams({
                        "contacts": response.getReturnValue(),
                    });
                    event.fire();
                }else {
                    console.log('>>errorrr>>>');
                }
            });
            $A.enqueueAction( action );
    },

})