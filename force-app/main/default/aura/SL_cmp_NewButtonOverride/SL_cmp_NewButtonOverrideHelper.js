({	
	getInfo : function(cmp, event) {
		let parentId = this.getParentId(cmp);
		cmp.set('v.parentId', parentId);

        var action = cmp.get('c.getRecordDetails');
        action.setParams({
			'sObjectName' : cmp.get('v.sObjectName'),
			'parentId' : parentId
        });
        action.setCallback(this, function(response) {
			let state = response.getState();
            if(state == 'SUCCESS') {
				let res = response.getReturnValue();
				cmp.set('v.listViewDetails', res.listViewDetails);
                if(res.isCreateableAccount) {
                    // user have create permission
                    this.openRecordEditForm(cmp, res.defaultFieldValues);
                } else {
                    // if user doesn't have create permission
                    this.showToast('Error!', 'error', 'You do not have the appropriate permissions to create an Account. Please contact your Administrator.');
                    this.redirectTolistView(cmp.get('v.sObjectName'), res.listViweDetails, cmp.get('v.parentId'));
                }
            }else {
                // unexpected error occur
                this.showToast('Error!', 'error', 'Something went wrong. Please contact to Administrator.');
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
	},
	
	getParentId : function(component) {
		let sObject = component.get('v.sObjectName');
		let parentId = '';
		switch(sObject) {
			case 'Contact': 
				{	// getting the related accountid while new button is clicked from the Account related list
					let additionalParams = component.get('v.pageReference').state.additionalParams;
					parentId = $A.util.isEmpty(additionalParams) ? '' : additionalParams.substring(additionalParams.indexOf('=')+1, additionalParams.indexOf('&'));
				}; 
				break;
		}
		return parentId;
	},

	getLabel : function(component) {
		let sObject = component.get('v.sObjectName');
		let label = '';
		switch(sObject) {
			case 'Account': {label = 'Account'}; break;
			case 'Contact': {label = 'Contact'}; break;
			case 'Address__c': {label = 'Address'}; break;
			case 'ZTS_EU_Affiliations__c': {label = 'Account Contact Affiliation'}; break;
			case 'ZTS_Events__c': {label = 'Event'}; break;
			default: {label = 'Record'}; break;
		}
		component.set('v.label', label);
	},

	openRecordEditForm : function(component, defaultFieldValues) {
        try {
            var rtId = component.get('v.pageReference').state.recordTypeId;
            var sobj = component.get('v.sObjectName');
                    
            var createRecordEvent = $A.get("e.force:createRecord");
            createRecordEvent.setParams({
                "entityApiName": sobj,
                "recordTypeId" : rtId,
				"defaultFieldValues": defaultFieldValues,
            });
            createRecordEvent.fire();
        } catch(e) {
            // console.log('>>e>>>>',e);
            component.set('v.errorMessage','If you are not redirected in a few seconds please try again.');
        }
    },

	redirectTolistView : function(sobjectName, listviewDetails, parentId) {
		if($A.util.isEmpty(parentId)) {
			if($A.util.isEmpty(listviewDetails)) {
				window.location.href = '/lightning/o/'+ sobjectName +'/list'
			}else {
				var navEvent = $A.get("e.force:navigateToList");
				navEvent.setParams({
					"listViewId": listviewDetails.Id,
					"listViewName": listviewDetails.Name,
					"scope": sobjectName
				});
				navEvent.fire();
			}
		}else {
			var navEvt = $A.get("e.force:navigateToSObject");
			navEvt.setParams({
			  "recordId": parentId,
			  "slideDevName": "related"
			});
			navEvt.fire();
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
})