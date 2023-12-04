({
  callApex: function (component, methodName, params) {
    return new Promise(
      $A.getCallback(function (resolve, reject) {
        var action = component.get(methodName);

        if (params) {
          action.setParams(params);
        }

        action.setCallback(this, function (results) {
          console.log(methodName + ' results', results);

          if (results.getState() === 'SUCCESS') {
            console.log('results:', results.getReturnValue());
            resolve(results.getReturnValue());
          } else if (results.getState() === 'ERROR') {
            console.log('callApex() ERROR', results.getError());
            $A.log('Errors', results.getError());
            reject(results.getError());
          }
        });

        $A.enqueueAction(action);
      })
    );
  },
  redirectToQLE: function (quoteId) {
    var urlEvent = $A.get('e.force:navigateToURL');
    if (urlEvent) {
      urlEvent.setParams({
        url: '/apex/sbqq__sb?id=' + quoteId,
        isredirect: 'true'
      });

      urlEvent.fire();
    } else {
      window.location.replace('/apex/sbqq__sb?id=' + quoteId);
    }
  },
  showErrorMessage: function (component, severity, errorMessage, additionalErrorMessage) {
    console.log(severity.toUpperCase() + ' on getting Vistex Response: ' + errorMessage);

    component.set('v.loading', false);
    component.set('v.errorSeverity', severity);
    component.set('v.errorMessage', errorMessage);

    if (additionalErrorMessage) {
      component.set('v.additionalErrorDetails', additionalErrorMessage.replace(/(?:\r\n|\r|\n)/g, '<br>'));
    }

    let pricingCallResult = component.get('v.pricingCallResult');
    if (pricingCallResult) {
      pricingCallResult.Status = 'ERROR';
      component.set('v.pricingCallResult', pricingCallResult);
    }
  },
  showLoadingMessage: function (component, message) {
    component.set('v.loading', true);
    component.set('v.loadingMessage', message);
  },
  showToast: function (title, message, type) {
    var toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
      title: title,
      message: message,
      type: type
    });
    toastEvent.fire();
  }
});