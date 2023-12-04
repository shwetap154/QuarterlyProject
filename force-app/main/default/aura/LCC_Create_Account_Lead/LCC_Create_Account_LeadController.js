({
	execute : function(component, event, helper) {
		// TODO: Review the migrated code
		if (''+component.get('v.sObjectInfo.Status')+'' != 'Complete') 
  {
  helper.showTextAlert(component, 'Lead must be in Complete status before creating an Account');
}
else 
  {
helper.gotoURL(component, '/apex/NOA_CreateAccount?id='+component.get('v.sObjectInfo.Id')+'');
}


	},

	accept : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})