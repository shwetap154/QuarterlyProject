({
	doInit: function(component, event, helper) {		
		helper.callApex(component, 'c.getLeanandGrowUrl')
		.then(function(siteURL){
			console.log('This is the Site URL: ' + siteURL);
			component.set('v.siteURL', siteURL);		
		}) 
		.catch(function(err){
			//component.set('v.errorMessage', 'There is an error getting the domain url. Error: ' + err);
		})
	}
})