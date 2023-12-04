({
	callApex: function (component, methodName, params) {
		return new Promise($A.getCallback(function (resolve, reject) {
			
			var action = component.get(methodName);

			console.log('Before set params they are ' + params);
			
			if (params) {
				
				action.setParams({"myParams" : params});
				console.log('After Set Params');
			}

			console.log(action.getParams());
			
			action.setCallback(this, function (results) {
				if (results.getState() === 'SUCCESS') {
					resolve(results.getReturnValue());
				} else if (results.getState() === 'ERROR') {
					$A.log('Errors', results.getError());
					reject(results.getError());
				}
			});

			
			$A.enqueueAction(action);

		})); 
	}
})