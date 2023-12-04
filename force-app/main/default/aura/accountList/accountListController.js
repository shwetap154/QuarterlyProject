({
    onAccountsLoaded: function( component, event, helper ) {
        // var cols = [
        //     {
        //         'label': 'Name',
        //         'fieldName': 'accountId',
        //         'type': 'url',
        //         'typeAttributes' :  {
        //             'label' :       {   'fieldName' : 'Name'    }, 
        //                                 ' target' : '_blank'    }
        //     }
        // ];
        //component.set( 'v.cols', cols );
        
        var records = event.getParam( 'accountsToSAPWrapp' );
        // if(records != null) console.log(JSON.stringify(records.lstAccountSAPWrapper));
        // if (records != null) console.log(JSON.stringify(records.rowdata));
        
        if(records){
            if (records.rowdata && records.rowdata.length > 0) {
                var wrapper = records.rowdata;
                wrapper.forEach(function (record) {
                    record.accountId = record.Id.includes('/') ? record.Id : '/' + record.Id;
                    if (records.isSapIds.includes(record.Id)){
                        record.isSAPNumber = true;
                    }else{
                        record.isSAPNumber = false;
                    }
                });
                component.set("v.rows", wrapper);


                let columns = records.columns.filter(val => { return val.fieldName != 'Name' }),
                    node = {
                        'label': 'Name',
                        'fieldName': 'accountId',
                        'type': 'url',
                        'typeAttributes': {
                            'label': { 'fieldName': 'Name' },
                            ' target': '_blank'
                        }
                    };

                columns.splice(0, 0, node);
                component.set('v.cols', columns);

                component.set('v.showCMP', true);
            }
            else
                component.set('v.showCMP', false); 
        }

    },

    selectedAccounts: function( component, event, helper ) {

        var selectedRows = event.getParam('selectedRows');
        let objCase = component.get('v.objCase');
        if($A.util.isEmpty(selectedRows)) {
            return;
        }
        objCase.AccountId = (selectedRows[0].Id);
        objCase.isSAPNumber = selectedRows[0].isSAPNumber;
        objCase.AccountName = selectedRows[0].Name;
        objCase.userMarket = selectedRows[0].ZTS_EU_Market__c;
        objCase.Address__c = '';
        objCase.SAPName = '';
        objCase.AccountNumber = '';
        objCase.ContactId = '';
        objCase.ContactName = '';
        component.set('v.objCase', objCase);
        
        if(!selectedRows[0].isSAPNumber) {

            var action = component.get( "c.searchContacts" );
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
                    component.set('v.activeSectionName', 'ContactSearch');
                    event.fire();
                }else {
                    console.log('>>errorrr>>>');
                }
            });
            $A.enqueueAction( action );
        } else {

            component.set('v.activeSectionName', 'SAPSearch');
        }
    },

    onNewCaseReset : function(cmp, event, helper) {
        let isSearchErased = event.getParam('isSearchErased');
        if(isSearchErased) {
            cmp.set('v.rows', []);
            cmp.set('v.cols', []);
            cmp.set('v.showCMP', false);
        }
    }
})