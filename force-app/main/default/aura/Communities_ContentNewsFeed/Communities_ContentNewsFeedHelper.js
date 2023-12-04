({
  callApex: function(component, methodName, params) {
    return new Promise(
      $A.getCallback(function(resolve, reject) {
        var action = component.get(methodName);

        if (params) {
          action.setParams({ componentName: params['componentName'] });
        }

        action.setCallback(this, function(results) {
          if (results.getState() === 'SUCCESS') {
            resolve(results.getReturnValue());
          } else if (results.getState() === 'ERROR') {
            $A.log('Errors', results.getError());
            reject(results.getError());
          }
        });

        $A.enqueueAction(action);
      })
    );
  }
});