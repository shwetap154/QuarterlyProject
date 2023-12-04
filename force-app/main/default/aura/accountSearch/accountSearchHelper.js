({
    // code in the helper is reusable by both
    // the controller.js and helper.js files
    handleSearch: function( component, searchTerm ) {
       
        if($A.util.isEmpty(searchTerm) || searchTerm.length <=2) {
            var event = $A.get( "e.c:NewCaseReset" );
            
            event.setParams({
                "isSearchErased": true
            });
            event.fire();
        }

        var action = component.get( "c.searchAccounts" );
        action.setParams({
            searchTerm: searchTerm
        });
        action.setCallback( this, function( response ) {

            let res = JSON.parse(JSON.stringify(response.getReturnValue()))
            
            if( !$A.util.isEmpty(searchTerm) && res && res.rowdata.length == 0) {
                $A.util.removeClass(component.find('msg'), 'slds-hide');
            } else {
                $A.util.addClass(component.find('msg'), 'slds-hide');
            }

            var event = $A.get( "e.c:acctsLoaded" );
            
            event.setParams({
                "accountsToSAPWrapp": response.getReturnValue()
            });
            event.fire();
        });
        $A.enqueueAction( action );
    }
})