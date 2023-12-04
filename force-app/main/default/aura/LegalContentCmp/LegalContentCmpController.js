({
	doInit: function(component, event, helper) {
		helper.callApex(component, 'c.retrieveContentRecords')
		.then(function(contentVersions){
			component.set('v.contentVersions', contentVersions);
		}) 
		.catch(function(err){			
			//component.set('v.errorMessage', 'There is an error loading the content records. Error: ' + err);
		})
		helper.callApex(component, 'c.getBaseURL')
		.then(function(baseURL){
			console.log('This is the Base URL: ' + baseURL);
			component.set('v.baseURL', baseURL);		
		}) 
		.catch(function(err){
			//component.set('v.errorMessage', 'There is an error getting the domain url. Error: ' + err);
		})
	}
})