({
    doInit : function(cmp, event, helper) 
    {   
        // fectch the data
        var action = cmp.get('c.isPetOwnerAvailable');
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                console.log('isPetOwnerAvailable::'+ result);
                if(result === true){
                    cmp.set("v.showPetOwner", true);
                } else {
                    cmp.set("v.showPetOwner", false);
                }
            }
            console.log('isPetOwnerAvailable::'+ cmp.get("v.showPetOwner"));
        });
        $A.enqueueAction(action);
    },
    
    onContactsLoaded: function( component, event, helper ) {
        /* var cols = [
            {
                'label': 'Name',
                'fieldName': 'contactId',
                'type': 'url',
                'typeAttributes' :  {
                    'label' :       {   'fieldName' : 'Name'    }, 
                                        ' target' : '_blank'    }
            },
            {
                'label': 'Contact Type',
                'fieldName': 'ZTS_EU_Contact_type__c',
                'type': 'text'
            }
        ];
        component.set( 'v.cols', cols ); */
        
        let objCase = component.get('v.objCase'),
            data = event.getParam( 'contacts' ),
            records = data.rowdata,
            cols = data.columns.filter(val => {return val.fieldName !='Name'}),
            node = {    'label': 'Name',
                        'fieldName': 'contactId',
                        'type': 'url',
                        'typeAttributes' :  {   'label' : {   'fieldName' : 'Name'    }, 
                                                ' target' : '_blank'    
                                            }
                    };
            cols.splice(0, 0, node);
            component.set( 'v.cols', cols );
        console.log('onContactsLoaded'+records)
        if(records.length > 0)
        {
            records.forEach(function(record)
            {   
                record.contactId = '/'+record.Id;     
                record.Name = record.Name;     
            });
            component.set( 'v.rows', records );
            component.set( 'v.showCMP', true );
            if(!$A.util.isEmpty(objCase.ContactId)) {
                component.find('contactList').set('v.selectedRows', [objCase.ContactId]);
                component.set( 'v.displayCaseComponent', true );
                component.set('v.activeSectionName', 'CaseDetails');
            }
        } else {
            component.set( 'v.rows', [] );
            component.set( 'v.showCMP', false );
            component.set( 'v.displayCaseComponent', true );
            component.set('v.activeSectionName', 'CaseDetails');
        }
    },

    selectedContacts: function( component, event, helper ) 
    {
     //   component.set( 'v.displayComponent', false );
        component.set( 'v.displayCaseComponent', true );

        var selectedRows = event.getParam('selectedRows');
        let objCase = component.get('v.objCase');
        if(!$A.util.isEmpty(selectedRows))
        {
            objCase.ContactId = selectedRows[0].Id;
            objCase.ContactName = selectedRows[0].Name;
            component.set('v.objCase', objCase);
            component.set('v.activeSectionName', 'CaseDetails');
            component.set('v.displayCaseComponent', true);
        }
    },

    noContactSelected: function(component, event, helper) {
        component.set( 'v.showCMP', false );
        let objCase = component.get('v.objCase');
        objCase.ContactName = 'No Contact';
        objCase.ContactId = null;
        component.set('v.objCase', objCase);
        component.set( 'v.rows', JSON.parse(JSON.stringify(component.get('v.rows'))));
        component.set('v.activeSectionName', 'CaseDetails');
        component.set( 'v.displayCaseComponent', true );
        component.set( 'v.showCMP', true );
    },

    onNewCaseReset : function(cmp, event, helper) {
        let isSearchErased = event.getParam('isSearchErased');
        if(isSearchErased) {
            cmp.set('v.rows', []);
            cmp.set('v.cols', []);
            cmp.set('v.showCMP', false);
            cmp.set('v.displayCaseComponent', false);
        }
    },
    
})