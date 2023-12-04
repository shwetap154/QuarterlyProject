({
    doInit : function(component, event, helper) {

        var sObjectName = helper.getSObjectName(component);
        var userEnteredFieldSet = component.get('v.fieldset');
        var returnFieldSetName;
        var enqueueFieldSetAction = false;

        component.set('v.ObjectName',sObjectName);

        if(component.get('v.fieldSetSelection') === 'Field Set from Component Config'){
            component.set('v.fieldsetToUse', userEnteredFieldSet);
        }
        else{
            enqueueFieldSetAction = true;
        }

        var that = this;

        helper.standardFormat(component,event);

        var cmpProp = component.get("v.ComponentExpandCollapse");
        var isExpanded = (cmpProp === 'Don\'t allow-always expanded') ? false : true;

        if(isExpanded){
            component.set("v.isShowChevronIcon",isExpanded);
            component.set("v.IsMainExpEnabled", cmpProp === 'Allow-default expanded' ? true : false);
        }

        if(cmpProp === 'Allow-default collapsed' && component.get("v.isLoaded") == false){
            component.set("v.isLoaded", true);
            return;
        }
        else{
            component.set('v.IsMainExpEnabled', true);
            component.set("v.isLoaded", false);
        }

        if(enqueueFieldSetAction){

            var actionFS = component.get("c.fieldSetUserAssignment");

            actionFS.setParams({
                sobjectName : sObjectName,
            });

            actionFS.setCallback(this, function(response){

                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnFieldSetName = response.getReturnValue();

                    if (returnFieldSetName === null){
                        component.set('v.fieldsetToUse', userEnteredFieldSet);
                    }
                    else if (returnFieldSetName === 'Multiple assigned field sets found'){
                        alert('The Field Set component could not load properly. '+
                                'Your user has multiple field sets assigned for this object. '+
                                'Please contact your administrator with this information.');
                        component.set('v.isNoError', false);
                    }
                    else if (returnFieldSetName === 'No Custom Setting'){
                        alert('The Field Set component could not load properly. '+
                                'There is no org default custom setting to indicate field set. '+
                                'Please contact your administrator with this information.');
                        component.set('v.isNoError', false);
                    }
                    else{
                        component.set('v.fieldsetToUse', returnFieldSetName);
                    }
                    helper.describeFieldSetAndGetCurrentRecordActions(component);
                }

                else if (state === 'ERROR'){
                    var errors = response.getError();
                    if(errors) {
                        if(errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    }
                }
            });

            $A.enqueueAction(actionFS);
        }

        else{
            helper.describeFieldSetAndGetCurrentRecordActions(component);
        }

    },
    editFieldHandle : function(component, event, helper) {
        var isFieldEdited = event.getParam("isFieldEdited");
        if(isFieldEdited) {
            component.set("v.isEdit", true);
        }
    },
    handleCancel : function(component, event, helper) {
        helper.resetData(component);
    },
    handleSave : function(component, event, helper) {
        var sObjectName;
        if(component.get('v.filterParentFieldName')){
            sObjectName = component.get('v.ObjectName');
        }else{
            sObjectName = helper.getSObjectName(component);
        }
        var recordToUpdate = [component.get("v.sObj")];
        var action = component.get("c.updateRecord");
        action.setParams({
            sObj : sObjectName,
            jsonObjArr : JSON.stringify(recordToUpdate)
        });
        action.setCallback(this, function(response) {
            var resultsToast = $A.get("e.force:showToast");
            if (response.getState() === "SUCCESS") {
                var res = response.getReturnValue();
                var objToast = {
                    "message" : "Record updated successfully",
                    "type" : "success"
                };
                if(res === 'success'){
                    component.set("v.isEdit", false);
                    var sObjCloned = JSON.parse(JSON.stringify(recordToUpdate[0]))
                    component.set("v.sObjCloned", sObjCloned);
                }else{
                    objToast['message'] = JSON.parse(res)[0].message;
                    objToast["type"] = "error";
                    objToast["mode"] = "sticky";
                    //helper.resetData(component);
                }
                resultsToast.setParams(objToast);
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();
                
            }else{
                helper.resetData(component);
                resultsToast.setParams({
                    "message" : "Something went wrong please try again.",
                    "type"    : "error"
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
    UpdateLookupValue : function(component, event, helper){
        var Id = event.getParam("Id");
        var fieldApi  = event.getParam("fieldApi");
        var ObjLabel  = event.getParam("ObjLabel");
        
        var record = component.get('v.sObj');
        record[fieldApi] = Id;
        // if(fieldApi.endsWith('__c')){
        //     var lookupfield = fieldApi.replace('__c','__r');
        //     myMap = new Map();
        //     myMap.set('Id', Id);
        //     myMap.set(, 'value associated with keyObj');
        //     myMap.set(keyFunc, 'value associated with keyFunc');
        //     var obj = {Id}
        // }
        component.set('v.sObj',record);
        
    },
    refresh :function(component, event, helper){
        var type = event.getParam('type');
        if(type == 'success'){
            //component.set('v.sObj',null);
            $A.get('e.force:refreshView').fire();
        }
    },
    updateMultiselect : function(component, event, helper){
        var fieldApi  = event.getParam("fieldApi");
        var values  = event.getParam("Values");
        var record = component.get('v.sObj');
        record[fieldApi] = values;
        component.set('v.sObj',record);
        
        
    },
    ToggleBody : function(component, event, helper){
        var toggle = component.get('v.IsMainExpEnabled');
        component.set('v.IsMainExpEnabled', toggle ? false : true );
        if(component.get('v.IsMainExpEnabled')){
            console.log('TOGGLED>>>>>');
            component.executeToggle();
        }
    },
    dontInit : function(component, event, helper) {

            var sObjectName = helper.getSObjectName(component);
            component.set('v.ObjectName',sObjectName);
            var userEnteredFieldSet = component.get('v.fieldset');
            //var returnFieldSetName;
            //var enqueueFieldSetAction = false;

            console.log('the field selection: '+ component.get('v.fieldSetSelection'));
            if(component.get('v.fieldSetSelection') === 'Field Set from Component Config'){
                component.set('v.fieldsetToUse', userEnteredFieldSet);
            }
            else{
                helper.getFieldSetfromUser(component);
            }

            console.log('this is the outer level, did the field set get set?: ', component.get("v.fieldsetToUse"));

            //start originally
            var that = this;
            helper.standardFormat(component,event);
            var cmpProp = component.get("v.ComponentExpandCollapse");
            var isExpanded = (cmpProp === 'Don\'t allow-always expanded') ? false : true;
            if(isExpanded){
                component.set("v.isShowChevronIcon",isExpanded);
                component.set("v.IsMainExpEnabled", cmpProp === 'Allow-default expanded' ? true : false);
            }

            if(cmpProp === 'Allow-default collapsed' && component.get("v.isLoaded") == false){
                component.set("v.isLoaded", true);
                return;
            }
            else{
                component.set('v.IsMainExpEnabled', true);
                component.set("v.isLoaded", false);
            }

            var recId = helper.getRecordId(component);
            var fieldset = component.get("v.fieldsetToUse");
            var parentAPIname = component.get("v.parentobjFieldAPIName");
            var isfilterParentId = component.get("v.filterParentFieldName");
            if(isfilterParentId){
                helper.getParentObj(component);
            }
            console.log('=====fieldset====>',fieldset);
            var action = component.get("c.describeFieldSet");
            action.setParams({
                objType : sObjectName,
                fieldSetName : fieldset,
                parentAPIname : parentAPIname,
                isfilterParentId : isfilterParentId
            });

            action.setCallback(this, function(response) {
                var returnObj;
                var fieldAPI = [];
                var state = response.getState();
                console.log('response state: ', state);
                if (state === "SUCCESS") {
                    console.log('second to lowest level');
                    returnObj = JSON.parse(response.getReturnValue());
                    component.set('v.decimalFldLngth' , returnObj.mpfldDecimal);
                    console.log('returnObj'+returnObj);
                    console.log('returnObj.fieldApiNames'+returnObj.fieldApiNames);
                    console.log('returnObj.mapOfFieldApiToFieldsInfo'+returnObj.mapOfFieldApiToFieldsInfo);
                    if(returnObj != null && returnObj.fieldApiNames != null && returnObj.mapOfFieldApiToFieldsInfo != null) {
                        fieldAPI = returnObj.fieldApiNames;
                        component.set("v.fieldInfo", returnObj.mapOfFieldApiToFieldsInfo);
                        component.set("v.fieldAPI", fieldAPI);
                        component.set('v.mpFieldDependence',returnObj.mapFieldDependence);
                        //console.log('all Fields',returnObj.mapOfFieldApiToFieldsInfo);
                        //helper.getRecords(component, event, helper, recId);
                        action = component.get("c.getCurrentRecord");

                        action.setParams({
                            sObj : sObjectName,
                            fieldNames : fieldAPI.join(),
                            recordId : recId,
                            parentAPIname : parentAPIname,
                            isfilterParentId : isfilterParentId
                        });
                        action.setCallback(this, function(response) {
                            var state = response.getState();
                            console.log('inner level');
                            if (state === "SUCCESS") {
                                //Get display density of the current session
                                helper.getDisplayDensity(component, event, helper);

                                var ret = JSON.parse(response.getReturnValue());
                                console.log('responseval---> ',ret);
                                var recLvlAccess = ret.recordLvlAccess;

                                if(!recLvlAccess.HasEditAccess){
                                    component.set('v.isReadOnly',true);
                                }
                                if(ret.hasOwnProperty('recordData')){
                                    var sObj = ret.recordData;
                                    component.set("v.sObj", null);
                                    component.set("v.sObj",sObj);
                                    // console.log('record-->',sObj);
                                    var gettingParentId = sObj.Id;
                                    component.set("v.StoringParentId",gettingParentId);
                                    component.set("v.sObjCloned", JSON.parse(JSON.stringify(sObj)));
                                }

                            } else if(state === "ERROR") {
                            var errors = response.getError();
                            if(errors) {
                            if(errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);

                            }
                        }
                        else {
                            console.log("Unknown error");
                        }
                    }
                    component.set("v.isLoaded", true);
                    });
                    $A.enqueueAction(action);
                    }
                }


            });
            $A.enqueueAction(action);
        },
})