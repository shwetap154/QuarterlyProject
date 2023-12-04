({
	handleSearch: function( component, searchTerm ) {
        var action = component.get( "c.searchAccounts" );
        action.setParams({
            searchTerm: searchTerm
        });
        action.setCallback( this, function( response ) {
            var event = $A.get( "e.c:contactsLoaded" );
            event.setParams({
                "contacts": response.getReturnValue()
            });
            event.fire();
        });
        $A.enqueueAction( action );
    }
})