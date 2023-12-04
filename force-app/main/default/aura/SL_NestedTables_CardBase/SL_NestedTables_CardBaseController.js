/**
 * Created by jerridkimball on 2018-05-31.
 */
({
    doInit : function(cmp, ev, help){
        
        help.getProfileAccessForMainObject(cmp, ev, help);
        
        var action = cmp.get("c.getName");
        action.setParams({
            "selectedObject": cmp.get('v.mainObjectName')
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                cmp.set("v.objectName", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
        
        var browserName = navigator.userAgent;

        var pos = browserName.indexOf("Trident");
        if (pos >= 0) {
            cmp.set('v.isIEbrowser',true);
        }
    },
    // From https://developer.salesforce.com/docs/atlas.en-us.212.0.lightning.meta/lightning/ref_force_createRecord.htm 
    createRecord: function (cmp, evt, hlpr) {
        var action = cmp.get("c.getRecordType");
        var objName = cmp.get('v.mainObjectName');
        action.setParams({
            "strObjectName": objName
        }); 
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() && response.getReturnValue().length > 0){
                    cmp.set("v.lstOfRecordType",response.getReturnValue());
                    cmp.set("v.isOpen", true);
                }
                else{
                    var createRecordEvent = $A.get("e.force:createRecord");
    				var fieldAPIName = cmp.get('v.mainLookupFieldName');
                    var recordId = cmp.get('v.recordId');
                    var objectFieldValues={};
                    objectFieldValues[fieldAPIName] = recordId;
			        createRecordEvent.setParams({
			            "entityApiName": objName,
                        "defaultFieldValues" : objectFieldValues			       
                    });
			        createRecordEvent.fire();                    
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    closeModal :function(component, event, helper){
        component.set("v.isOpen",false);
    },
    
    stdCreateRecord : function (component, event, helper){
        component.set("v.isOpen",false);

    	var recordTypeLabel = component.find("selectid").get("v.value");
    	var fieldAPIName = component.get('v.mainLookupFieldName');
    	var createRecordEvent = $A.get("e.force:createRecord");
        var recordId = component.get('v.recordId');
        var defaultObj = {};
        defaultObj[fieldAPIName] = recordId;

        createRecordEvent.setParams({
            "entityApiName": component.get('v.mainObjectName'),
            "recordTypeId": recordTypeLabel,
             "defaultFieldValues" :  defaultObj
        });
        createRecordEvent.fire();
    }
    
    
})