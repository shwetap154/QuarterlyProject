({
    getRecordId : function(component) {
        var recId = component.get("v.recordId");
        return recId;
    },
    getSObjectName : function(component) {
        var sObjectName = component.get("v.sObjectName");
		if (!sObjectName) {
            sObjectName = component.get("v.ObjectName");
        }
        return sObjectName;
    },
    resetData : function(component) {
        component.set("v.sObj", null);
        var sObjCloned = JSON.parse(JSON.stringify(component.get("v.sObjCloned")))
        component.set("v.sObj", sObjCloned);
        component.set("v.isEdit", false);
    },
    // getRecords : function(component, event, helper, recId) {
    //     var sObjectName = component.get('v.sObjectName');
    //     var fieldAPI = component.get('v.fieldAPI');
    //     var parentAPIname = component.get("v.parentobjFieldAPIName");
    //     var isfilterParentId = component.get("v.filterParentFieldName");
    
    //     action = component.get("c.getCurrentRecord");      
    //     action.setParams({
    //         sObj : sObjectName,
    //         fieldNames : fieldAPI.join(),
    //         recordId : recId,
    //         parentAPIname : parentAPIname,
    //         isfilterParentId : isfilterParentId
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var sObj = response.getReturnValue();
    //             component.set("v.sObj", sObj);
    //             var gettingParentId = sObj.Id;
    //             component.set("v.StoringParentId",gettingParentId);
    //             component.set("v.sObjCloned", JSON.parse(JSON.stringify(sObj)));
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    getParentObj : function(component) {
        
        var act = component.get("c.getSobjName");
        act.setParams({
            "currentObjType" : component.get('v.sObjectName'),
            "parentAPIname" : component.get('v.parentobjFieldAPIName'),
            "isfilterParentId" : true
        });
        act.setCallback(this,function(response){
            if( response.getState() == "SUCCESS" ){
                component.set('v.ObjectName',response.getReturnValue());
            }
        });
        $A.enqueueAction(act);
    },
    standardFormat : function(cmp, ev) {
        let dateLocale = $A.get("$Locale.dateFormat");
        dateLocale=dateLocale.replace(/ /g, '-');
        dateLocale=dateLocale.replace(/,/g, '');
        dateLocale = dateLocale.replace(/-/g, '/');
        dateLocale = dateLocale.replace(/MM/g, 'M');
        dateLocale = dateLocale.replace(/MM/g, 'M');
        cmp.set('v.stdDateFormat',dateLocale);
        let timeFormat = $A.get("$Locale.timeFormat");
        timeFormat = timeFormat.replace(/:ss/g, '');
        let dateTimeLocale = dateLocale+' '+timeFormat;
        cmp.set('v.stdDateTimeFormat',dateTimeLocale);
    },

    getDisplayDensity : function(component) {
        var action = component.get("c.getDisplayDensity");
        // action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('LINE 24 STATE: '+state);
            if (state === "SUCCESS") {
                component.set("v.displayDensity",response.getReturnValue());
                 //console.log('RESPONSE>>>>>'+component.get("v.displayDensity"));
            }else{
                component.set("v.displayDensity","ViewOne");
            }
        });
        $A.enqueueAction(action);
    },
    describeFieldSetAndGetCurrentRecordActions : function (component){

        var recId = this.getRecordId(component);
        var fieldset = component.get("v.fieldsetToUse");
        var parentAPIname = component.get("v.parentobjFieldAPIName");
        var isfilterParentId = component.get("v.filterParentFieldName");
        var sObjectName = this.getSObjectName(component);

        if(isfilterParentId){
            this.getParentObj(component);
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

            if (state === "SUCCESS") {

                returnObj = JSON.parse(response.getReturnValue());
                component.set('v.decimalFldLngth' , returnObj.mpfldDecimal);

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

                        if (state === "SUCCESS") {
                            //Get display density of the current session
                            this.getDisplayDensity(component);

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

                        }
                        else if(state === "ERROR") {
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