({

    getRelatedSAPIds : function(component) {

        let objCase = component.get('v.objCase');
        let isSAPNumber = objCase.hasOwnProperty('isSAPNumber') ? !objCase.isSAPNumber : false;
        if( ($A.util.isEmpty(objCase.AccountId) && $A.util.isEmpty(objCase.ContactId)) || (!$A.util.isEmpty(objCase.Address__c)|| isSAPNumber )) {
            return;
        }
        let recId = (objCase.AccountId ? objCase.AccountId : objCase.ContactId);
        component.set('v.displayCaseComponent', false);
        var action = component.get( "c.fetchSAPNumbers" );
        action.setParams({
            accountId : recId
        });
        action.setCallback( this, function( response ) {
            let state = response.getState();
            if(state == 'SUCCESS') {
                let data = response.getReturnValue(),
                    records = data.rowdata,
                    columns = data.columns.filter(val => {return val.fieldName !='Name'}),

                    node = {    'label': 'Address Line 1',
                                'fieldName': 'AddressName',
                                'type': 'url',
                                'typeAttributes' :  {   'label' :   {   'fieldName' : 'Name'    }, 
                                                        ' target' : '_blank'    
                                                    }
                            };

                columns.splice(0, 0, node);
                component.set( 'v.cols', columns );
                
                if(records && records.length > 0) {
                    records.forEach(function(record) { record.AddressName = '/'+record.Id; });
                    component.set( 'v.rows', records );
                    component.set( 'v.showCMP', true );

                    if(records.length == 1) {
                        objCase.Address__c = records[0].Id ;
                        let sourceAccNum = records[0].ZTS_US_Source_Account_Number__c ?' ( '+records[0].ZTS_US_Source_Account_Number__c+' )' : '';
                        objCase.SAPName = records[0].Name + sourceAccNum;
                        objCase.AccountNumber = records[0].ZTS_US_Source_Account_Number__c;
                        component.set('v.objCase', objCase);
                        component.find('sapList').set('v.selectedRows', [records[0].Id]);
                        component.set('v.displayCaseComponent', true);
                        if(objCase.objectApiName != 'Contact') {
                            this.contactList(component, objCase.AccountId);
                            component.set('v.activeSectionName', 'ContactSearch');
                        } else {
                            component.set('v.activeSectionName', 'CaseDetails');
                        }
                    }

                } else {
                    if(objCase.objectApiName == 'Account')
                        this.contactList(component, recId);
                    if(objCase.objectApiName == 'Contact')
                        component.set('v.activeSectionName', 'CaseDetails');

                    objCase.isSAPNumber = false;
                    component.set('v.objCase', objCase);
                    component.set( 'v.rows', [] );
                    component.set('v.displayCaseComponent', true); 
                }
            }
        });
        $A.enqueueAction( action );
    },

    contactList : function(component, recordId) {
        var action = component.get( "c.searchContacts" );
        action.setParams({
            lstAccountId : recordId
        });
        
        action.setCallback( this, function( response ) {
            var event = $A.get( "e.c:contactsLoaded" );
            var state = response.getState();

            if(state === "SUCCESS") {
                event.setParams({
                    "contacts": response.getReturnValue(),
                });
                event.fire();
                component.set('v.activeSectionName', 'ContactSearch');
            }
        });
        $A.enqueueAction( action );
    }
})