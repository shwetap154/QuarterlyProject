({
    onInit: function(component, event, helper){
        var action = component.get("c.getContractInfo");
            action.setParams({ contractId : component.get("v.contrId") });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue()){
                        component.set("v.contract", response.getReturnValue());
                        var contract = response.getReturnValue();
                        var positiveIntSalesOppty = (contract.Incremental_Sales_Opportunity__c > 1) ? true : false;
                        var posIncSalesOppty = (contract.Incremental_Sales_Opportunity__c >= 1) ? true : false;
                        var negIncSalesOppty = (contract.Incremental_Sales_Opportunity__c < 1) ? true : false;
                        var count = contract.ZTS_US_Count_Attachments__c;
                        var comments = contract.ZTS_US_Submitter_Comments__c;
                        var recordtype = contract.Record_Type_Name__c;
                        var internalSalesOppty = contract.Incremental_Sales_Opportunity__c;
                        var netBiosDisc = contract.Net_Bios_Sales_Last_12_Mos__c;
                        var netBiosAfterDisc = contract.Net_Bios_Sales_Next_12_Mos__c;
                        var netParasDisc = contract.Net_Paras_Sales_Last_12_Mos__c;
                        var netParasAfterDisc = contract.Net_Paras_Sales_Next_12_Mos__c;

                        if(recordtype === 'MZR BIOS Proposal' && 
                                            (netBiosDisc === null || typeof(netBiosDisc) == 'undefined' || 
                                             netBiosAfterDisc === null || typeof(netBiosAfterDisc) == 'undefined' || 
                                             internalSalesOppty === null || typeof(internalSalesOppty) == 'undefined' ) )
                        {
                            component.set("v.isValid", false);
                            var error = 'Please enter values for Net Bios Sales - Last 12 Mos, Net Bios Sales - Next 12 Mos and Incremental Sales Opportunity before submitting the proposal';
                            helper.doRedirect(component, event, helper, false, error);
                            return;
                        }

                        if(recordtype === 'MZR PARAS Proposal' && 
                                                (netParasDisc === null || typeof(netParasDisc) == 'undefined' ||
                                                netParasAfterDisc === null || typeof(netParasAfterDisc) == 'undefined' || 
                                                internalSalesOppty === null || typeof(internalSalesOppty) == 'undefined' ))
                        {
                            component.set("v.isValid", false);
                            var error = 'Please enter values for Net Paras Sales - Last 12 Mos, Net Paras Sales - Next 12 Mos and Incremental Sales Opportunity before submitting the proposal';
                            helper.doRedirect(component, event, helper, false, error);
                            return;
                        }

                        if((count === 0|| typeof(count) == 'undefined' || comments === '' || typeof(comments) == 'undefined') && 
                            (recordtype === 'MZR BIOS Proposal' || recordtype === 'MZR PARAS Proposal') )
                        {
                            component.set("v.isValid", false);
                            var msg = (recordtype === 'MZR BIOS Proposal') ? 'BIOS' : 'PARAs';
                            var error = 'In order to submit a new MZR '+msg+' Proposal, you must attach your MZR '+msg+' Calculator as well as enter Submitter Comments';
                            helper.doRedirect(component, event, helper, false, error);
                            return;
                        }

                        if((recordtype === 'MZR BIOS Proposal' || recordtype === 'MZR PARAS Proposal') 
                            && positiveIntSalesOppty == true )
                        {
                            var msg = (recordtype=='MZR BIOS Proposal') ? 'BIOS' : 'PARAs';
                            var res = 'Please review and confirm: The MZR '+msg+' Calculator is attached, the value of row 8 [Net '+msg+' purchases after discounts – Next 12 months] is greater than or equal to the commitment level on row 6, and the incremental sales opportunity on row 9 is equal to or greater than '+ internalSalesOppty +' in your calculator. Do not click OK unless the entire statement is correct.';
                            
                            if (component.get("v.showCalcCard")){
                                helper.insertModalComponent(component, event, helper, res);
                                return;
                            }

                        }

                        if(comments === '' || typeof(comments) === 'undefined'
                            && (recordtype=='MZR BIOS Renewal' || recordtype=='MZR PARAS Proposal') )
                        {
                            component.set("v.isValid", false);
                            var error = 'Submitter Comments are required for submission';
                            helper.doRedirect(component, event, helper, false, error);
                            return;
                        }

                        if((component.get("v.isValid")) && (recordtype === 'MZR BIOS Proposal' || recordtype === 'MZR PARAS Proposal') 
                            && negIncSalesOppty == true )
                        {
                            var res = 'This agreement has \$0 or a negative Incremental Sales Opportunity. If this is correct, please be sure to include thorough notes in the Submitter Comments field about why an exception should be made.\nClick CANCEL to review or revise. Click OK to submit to your ABM anyway.';
                            if (component.get("v.showCalcCard")){
                                helper.insertModalComponent(component, event, helper, res);
                                return;
                            }
                        }

                        if((component.get("v.isValid"))){
                            var res = 'Once you submit this for approval, you might not be able to edit it or recall it from the approval process depending on your settings. Continue?'
                            if((recordtype === 'MZR BIOS Proposal' || recordtype === 'MZR PARAS Proposal') && posIncSalesOppty == true )
                            {
                                var action = component.get("c.updateContract");
                                action.setParams({ 
                                    contractId : component.get("v.contrId") 
                                });
                                action.setCallback(this, function(response){
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        $A.get('e.force:refreshView').fire();
                                        var msg = 'Your proposal submission has been accepted. Please resync Pitcher to ensure this information updates, so you can have the customer accept Terms & Conditions in your MZR eDetailer to enroll this customer.';
                                        helper.showWarning(component, event, helper, msg);
                                        helper.doRedirect(component, event, helper, true, '');
                                    }
                                    else if (state === "INCOMPLETE") {
                                        // do something
                                    }
                                    else if (state === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                console.log("Error message: " +
                                                            errors[0].message);
                                            }
                                        } else {
                                            console.log("Unknown error");
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                            }
                            else if (confirm(res)){
                                var action = component.get("c.submitApproval");
                                action.setParams({ 
                                    contractId : component.get("v.contrId") 
                                });
                                action.setCallback(this, function(response){
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var result = response.getReturnValue();
                                        if(result != undefined && result != null && result != '') helper.showWarning(component, event, helper, result);
                                        helper.doRedirect(component, event, helper, true, '');
                                    }
                                    else if (state === "INCOMPLETE") {
                                        // do something
                                    }
                                    else if (state === "ERROR") {
                                        var errors = response.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                console.log("Error message: " +
                                                            errors[0].message);
                                            }
                                        } else {
                                            console.log("Unknown error");
                                        }
                                    }
                                    
                                });
                                $A.enqueueAction(action);
                            }
                            else {
                                helper.doRedirect(component, event, helper, true, '');
                            }
                        }
                        
                    }
                    else{
                        var error = 'ERROR with SOQL query, please see APEX logs for details';
                        helper.doRedirect(component, event, helper, false, error);
                    }

                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
        $A.enqueueAction(action);
        
    },
    
    doRedirect: function (component, event, helper, pass, error) {
        //Redirecting back to View page for Contract record
        var contractId = component.get("v.contrId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": contractId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        //if there was an error registered fire of error toast
        if (!pass){
            helper.showToast(component, event, error);
        }
    },

    showToast: function (component, event, error) {
        //create error toast: type sticky and pre defined error text
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: error,
            key: 'info_alt',
            type: 'error',
        });
        toastEvent.fire();
    },

    showWarning: function (component, event, helper, msg) {
        //create error toast: type Info
        //to notify that save was successful and record was updated
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: msg,
            duration:' 10000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        //before showing  toast go back to the record page view and refresh it
        // helper.doRedirect(component, event, helper, true, '');
        //fire of toast
        toastEvent.fire();
        
    },
    insertModalComponent: function (component, event, error, res) {
        $A.createComponent(
            "c:contractConfirmCard",
            {
                "component":component.get("v.contrId"),
                "message": res,
            },
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    component.set("v.currentContent", newCmp);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                }
            }
        );
    }

})