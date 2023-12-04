({
    doInit : function(component, event, helper) {
        var action = component.get("c.getCaseRecordType");
        component.set('v.openForm', false);

        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.picklistValues", list);
        })

        $A.enqueueAction(action);
    },

    onChangeRecordType: function(component, event, helper) {
        component.set('v.openForm', false);
        let picklistValues = component.get('v.picklistValues');
        let objCase = component.get('v.objCase');
        if(component.get('v.selectedRecordType') === 'NONE') {
            objCase.RecordTypeId = '';
            objCase.RecordTypeName = '';
            objCase.RecordTypeDescription = '';
            objCase.Type = '';
            objCase.Sub_Type_2__c = '';
            component.set('v.objCase', objCase);
        } else {
            let recordType = picklistValues.filter(val => { return val.Id == component.get('v.selectedRecordType')});
            objCase.RecordTypeId = recordType[0].Id;
            objCase.RecordTypeName = recordType[0].label;
            objCase.RecordTypeDescription = recordType[0].Description;
            objCase.Type = '';
            objCase.Sub_Type_2__c = '';
            component.set('v.openForm', true);
        }
        component.set('v.objCase', objCase);
    },

    /*******************************************************
    @function    onChangeType
    @brief       invoked when Type is selected on wizard.
                 for Diagnostics case, if Complaint is selected, Asset and Consumable fields are shown.

    *******************************************************/

    onChangeType: function(cmp, event, helper) {
        let value = event.getParam('value');
        let objCase = cmp.get('v.objCase');
        objCase.Type = value;
        objCase.Sub_Type_2__c = '';
        cmp.set('v.objCase', objCase);
        (value==='Complaint') ? cmp.set("v.showAssetAndConsumable",true) : cmp.set("v.showAssetAndConsumable",false);
    },


    /*******************************************************
    @function    onConsumbaleChange
    @brief       invoked when primary consumable is selected on wizard. Sets Primary_Consumable__c value with seleted record id.
                 checks for asset and consumable and shows/hides Primary Error Code field

    *******************************************************/
    onConsumbaleChange: function(cmp, event, helper) {
        let value = event.getParam('value');
        let objCase = cmp.get('v.objCase');
        objCase.Primary_Consumable__c = value[0];
        cmp.set('v.objCase', objCase);
        (value != '') ? cmp.set("v.hasAssetOrConsumable",true) : helper.checkAssetAndConsumable(cmp,objCase);
    },

    /*******************************************************
    @function    handleComponentEvent
    @brief       invoked when Asset or Primary Error Code is selected.
                 handles selectedsObjectRecordEvent triggered by customLookup component.

    *******************************************************/
    handleComponentEvent : function(cmp, event,helper) {
        // set the handler attributes based on event data
        let objCase = cmp.get('v.objCase');
        var recordId = event.getParam("recordId");
        var objectName = event.getParam("objectName");
        if(objectName==='Asset'){
            cmp.set("v.selectedAsset",recordId)
            objCase.AssetId = recordId;
            (recordId !='') ? cmp.set("v.hasAssetOrConsumable",true) : helper.checkAssetAndConsumable(cmp,objCase);
        }else{
            cmp.set("v.selectedErrorCode",recordId);
            objCase.Primary_Error_Code__c = recordId;
        }
        cmp.set('v.objCase', objCase);
    },
})