({
    getInfo : function(cmp, event) {
		
		let additionalParams = cmp.get('v.pageReference').state.additionalParams;
		let accid = $A.util.isEmpty(additionalParams) ? '' : additionalParams.substring(additionalParams.indexOf('=')+1, additionalParams.indexOf('&'));
		cmp.set('v.accountId', accid);

        var action = cmp.get('c.getDefaultUserData');
        action.setParams({
			'sObjectName' : cmp.get('v.sObjectName'),
			'accountId' : accid
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state == 'SUCCESS') {
				let res = response.getReturnValue();
                cmp.set('v.listViewDetails', res.listViweDetails);
                if(res.isCreateableAccount) {
                    // user have create permission
                    this.openRecordEditForm(cmp, event, res);
                } else {
                    // if user doesn't have create permission
                    this.showToast('Error!', 'error', 'You do not have the appropriate permissions to create an Account. Please contact your Administrator.');
                    this.redirectTolistView(cmp.get('v.sObjectName'), res.listViweDetails, cmp.get('v.accountId'));
                }
            }else {
                // unexpected error occur
                this.showToast('Error!', 'error', 'Something went wrong. Please contact to Administrator.');
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    openRecordEditForm : function(component, event, resData) {
        try {
            var rtId = component.get('v.pageReference').state.recordTypeId;
            var sobj = component.get('v.sObjectName');
                    
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": sobj,
                "recordTypeId" : rtId,
				"defaultFieldValues": resData.defaultfields,
            });
            createRecordEvent.fire();
        } catch(e) {
            component.set('v.errorMessage','If you are not redirected in a few seconds please try again.');
        }
    },

    showToast : function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },

    redirectTolistView : function(sobjectName, listviewDetails, accid) {
		if($A.util.isEmpty(accid)) {
			var navEvent = $A.get("e.force:navigateToList");
			navEvent.setParams({
				"listViewId": listviewDetails.Id,
				"listViewName": listviewDetails.Name,
				"scope": sobjectName
			});
			navEvent.fire();
		}else{
			var navEvt = $A.get("e.force:navigateToSObject");
			navEvt.setParams({
			  "recordId": accid,
			  "slideDevName": "related"
			});
			navEvt.fire();
		}
        
    },
})