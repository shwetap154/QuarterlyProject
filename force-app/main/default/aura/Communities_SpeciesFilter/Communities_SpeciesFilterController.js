({
  mouseClick: function(component, event, helper) {
    console.log('In the communities species filter');

    component
      .getEvent('Communities_SpeciesFilter_EV')
      .setParams({
        label: component.get('v.label'),
        active: !component.get('v.active')
      })
      .fire();
  }
});