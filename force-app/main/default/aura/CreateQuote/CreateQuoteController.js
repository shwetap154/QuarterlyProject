({
  doInit: function(component, event, helper) {
    
      var pickvar = component.get("c.getPickListValuesIntoList");
      pickvar.setCallback(this, function(response) {
          var state = response.getState();
          if(state === 'SUCCESS'){
              var list = response.getReturnValue();
              component.set("v.languagevalue", list);
          }
          else if(state === 'ERROR'){
              alert('ERROR OCCURED.');
          }
      })
      $A.enqueueAction(pickvar);
      
      helper.setInitValues(component);
  },
  closeModal: function(c, e) {
    $A.get("e.force:closeQuickAction").fire();
  },
  handleSubmit: function(component, event, helper) {
    const errors = helper.validateInputs(component, event);

    component.set("v.errors", errors);

    if (errors.length) {
      component.set("v.displayErrors", true);
    } else {
      component.set("v.displayErrors", false);
      helper.createQuote(component);
    }
  }
});