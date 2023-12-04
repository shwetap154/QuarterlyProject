({
    doInit : function(component, event, helper) {
        
        component.set("v.loaded", true);
        helper.buildDeal(component, event,helper);       	
    },
    closeModal: function(c, e) {
    $A.get("e.force:closeQuickAction").fire();
  }
 
})