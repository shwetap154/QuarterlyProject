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
        //Aritra added the below code in the method for SC-008149
        var message = '';
        var errors = event.getParams();
        console.log(errors);
        var errormessages = errors.output;
        
        if ($A.util.isEmpty(errormessages.errors) === false) {
            if (errormessages.errors.length > 0) {
                for (var j = 0; errormessages.errors.length > j; j++) {
                    var fielderror = errormessages.errors[j];
                    let confMessage = 'Below Potential Duplicate(s) have been detected. You can select from the below matching entries, or create new duplicate contact.';
                    if (fielderror.errorCode === 'DUPLICATES_DETECTED') {
                        cmp.set('v.showModal', false);
                        cmp.set('v.showDupContactModal', true);
                        cmp.set('v.duplicateContactMessage', confMessage);
                        var matchedIds = [];
                        for (var k = 0; k < fielderror.duplicateRecordError.matchResults[0].matchRecordIds.length ; k++) {
                            matchedIds.push(fielderror.duplicateRecordError.matchResults[0].matchRecordIds[k]);
                        }
                        //alert('matchedIds '+matchedIds);
                        var matchedIDJSON = JSON.stringify(matchedIds);
                        //alert('json-> '+ matchedIDJSON);
                        cmp.set('v.conColumns',  [
                            {label: 'Contact Name', fieldName : 'Full_Contact_Name__c', type: 'text'},
                            {label: 'Account Name', fieldName : 'Account_Name__c', type: 'text'},
                            {label: 'Status', fieldName : 'ZTS_EU_Contact_Status__c', type: 'text'},
                            {label: 'Email', fieldName : 'Interface_Email__c', type: 'Email'},
                            {label: 'Phone', fieldName : 'Phone',type: 'Phone'},
                            {label: 'Profession', fieldName : 'ZTS_US_Profession__c',type: 'text'},
                            {label: 'Job Function', fieldName : 'ZTS_US_Job_Function__c',type: 'text'}
                            
                        ]); 
                        var action = cmp.get( "c.getMatchingContactDetails" );
                        action.setParams({
                            selectedIdsJson : matchedIDJSON
                        });
                        action.setCallback(this, function(response){
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                cmp.set("v.conRecords", response.getReturnValue());
                            }
                        });
                        $A.enqueueAction(action);
                    }
                    else{
                        message = fielderror.errorCode + ' (' + fielderror.field + ') : ' + fielderror.message;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error on Save!",
                            "message": message
                        });
                        toastEvent.fire();
                    }
                }
            }
        }
    },

    saveContact :function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        cmp.find('createContactForm').submit();
    },

    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        //Below code of this method Added by Aritra for (SC-008149)
        let objCase = cmp.get('v.objCase');
        cmp.set('v.accountID', objCase['AccountId']);
        
        let objCon = cmp.get('v.newContact');
        objCon.AccountId = objCase['AccountId'];
        cmp.set('v.newContact', objCon);
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
    //Created by Aritra for (SC-008149)
    saveDuplicateContact :function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        //alert('contact details -->'+ JSON.stringify(cmp.get('v.newContact')));
        let objCon = cmp.get('v.newContact');
        var action = cmp.get( "c.createDuplicateRecord" );
        action.setParams({
            sObjectRecord : JSON.stringify(objCon),
            objectName : 'Contact'
        });       
        action.setCallback( this, function( response ) 
                           {
                               var state = response.getState();
                               //If Duplicate contact creation is successful
                               if(state === "SUCCESS") {
                                   alert("contact creation successful");
                                   let retVal;
                                   let conId;
                                   let conName;
                                   if(response.getReturnValue() !== "ERROR")
                                   {
                                       retVal = response.getReturnValue();
                                       const myArray = retVal.split('||');
                                       conId = myArray[0];
                                       conName = myArray[1];
                                       
                                   }
                                   let objCase = cmp.get('v.objCase');
                                   objCase.ContactId = conId;
                                   objCase.ContactName = conName;
                                   cmp.set('v.objCase', objCase);
                                   var action = cmp.get( "c.searchContacts" );
                                   action.setParams({
                                       lstAccountId : objCase.AccountId
                                   });       
                                   
                                   event.setParams({
                                       "contacts": response.getReturnValue(),
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
                                                              cmp.set('v.showSpinner', false);
                                                              cmp.set('v.showDupContactModal', false);
                                                          }else {
                                                              cmp.set('v.showSpinner', false);
                                                              cmp.set('v.showDupContactModal', false);
                                                              errorMsg = response.getError()[0];
                                                              let toastParams = {
                                                                  title: "Error",
                                                                  message: errorMsg, 
                                                                  type: "error"
                                                              };
                                                              let toastEvent = $A.get("e.force:showToast");
                                                              toastEvent.setParams(toastParams);
                                                              toastEvent.fire();
                                                          }
                                                      });
                                   $A.enqueueAction( action );
                               }
                               else if(state = "ERROR"){
                                   cmp.set('v.showSpinner', false);
                                   errorMsg = response.getError()[0];
                                   let toastParams = {
                                       title: "Error",
                                       message: errorMsg, 
                                       type: "error"
                                   };
                                   let toastEvent = $A.get("e.force:showToast");
                                   toastEvent.setParams(toastParams);
                                   toastEvent.fire();
                               }
                               
                           });
        $A.enqueueAction( action );
    },
    //Created by Aritra for (SC-008149)
    cancelDuplicateContact :function(cmp, event, helper){
        cmp.set('v.showDupContactModal', false);
    },
    //Created by Aritra for (SC-008149)
    addContactToCase :function(cmp, event, helper){
        cmp.set('v.showSpinner', true);
        let objCase = cmp.get('v.objCase');
        objCase.ContactId = cmp.get('v.selectedConRecordId');
        objCase.ContactName = cmp.get('v.selectedContactName');
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
                                   cmp.set('v.showSpinner', false);
                                   cmp.set('v.showDupContactModal', false);
                               }else {
                                   console.log('>>errorrr>>>');
                               }
                           });
        $A.enqueueAction( action );
    },
    //Created by Aritra for (SC-008149)
    handleRowSelection : function(cmp, event, helper){
        var selectedRows=cmp.find('contactDataTable').getSelectedRows();
        cmp.set('v.selectedConRecordId',selectedRows[0].Id);
        cmp.set('v.selectedContactName',selectedRows[0].Full_Contact_Name__c);
    },
    //Created by Aritra for (SC-008149)
    handleValueChange : function(cmp, event, helper) {
        let fieldName = event.getSource().get("v.fieldName") ; 
        let newValue =  event.getSource().get("v.value") ; 
        //alert('fieldName-->'+ fieldName+ '; newValue-->'+newValue);
        /*let contact = {
            AccountId:"",
            FirstName : "",
            ZTS_EU_Contact_type__c : "",
            LastName : "",
            ZTS_EU_Species_Specialty__c : "",
            Interface_Email__c : "",
            Phone : "",
            AccountId : "",
            ZTS_EU_Address_Line_1__c :"",
            ZTS_EU_Country__c :"",
            ZTS_EU_State_County__c :"",
            ZTS_EU_Commune_Lookup__c :"",
            ZTS_EU_District__c :"",
            ZTS_EU_Zip_Postal_Code__c :""
        }*/
        let contactObj = cmp.get('v.newContact');
        switch(fieldName){
            case 'AccountId':
                contactObj.AccountId = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'FirstName':
                contactObj.FirstName = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'ZTS_EU_Contact_type__c':
                contactObj.ZTS_EU_Contact_type__c = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'LastName':
                contactObj.LastName = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'ZTS_EU_Species_Specialty__c':
                contactObj.ZTS_EU_Species_Specialty__c = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'Interface_Email__c':
                contactObj.Interface_Email__c = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'ZTS_US_Job_Function__c':
                contactObj.ZTS_US_Job_Function__c = newValue;
                cmp.set('v.newContact', contactObj);
                break; 
            case 'Phone':
                contactObj.Phone = newValue;
                cmp.set('v.newContact', contactObj);
                break; 
            case 'ZTS_EU_Address_Line_1__c':
                contactObj.ZTS_EU_Address_Line_1__c = newValue;
                cmp.set('v.newContact', contactObj);
                break; 
            case 'ZTS_EU_Country__c':
                contactObj.ZTS_EU_Country__c = newValue;
                cmp.set('v.newContact', contactObj);
                break; 
            case 'ZTS_EU_State_County__c':
                contactObj.ZTS_EU_State_County__c = newValue;
                cmp.set('v.newContact', contactObj);
                break; 
            case 'ZTS_EU_Commune_Lookup__c':
                contactObj.ZTS_EU_Commune_Lookup__c = newValue;
                cmp.set('v.newContact', contactObj);
                break; 
            case 'ZTS_EU_District__c':
                contactObj.ZTS_EU_District__c = newValue;
                cmp.set('v.newContact', contactObj);
                break;
            case 'ZTS_EU_Zip_Postal_Code__c':
                contactObj.ZTS_EU_Zip_Postal_Code__c = newValue;
                cmp.set('v.newContact', contactObj);
                break;
        }
    }

})