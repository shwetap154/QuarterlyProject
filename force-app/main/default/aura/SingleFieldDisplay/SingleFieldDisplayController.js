({
	toggleView : function(component,event,helper){
		
		//get current form visibility and source of event
		var viewFormClass = component.get("v.viewFormVisible");
		var editFormClass = component.get("v.editFormVisible");
		var buttonId = event.getSource().getLocalId();

		//toggle view form visibility variable
		if(viewFormClass == "slds-show"){
			component.set("v.viewFormVisible", "slds-hide");
		}
		else{
			component.set("v.viewFormVisible", "slds-show");
		}

		//toggle edit form visibility variable
		if(editFormClass == "slds-show"){
			component.set("v.editFormVisible", "slds-hide");
		}
		else{
			component.set("v.editFormVisible", "slds-show");
		}

		//reset input field on cancel to field value
		if (buttonId == 'cancel'){
			component.find('inputField').reset();
		}

    },
})