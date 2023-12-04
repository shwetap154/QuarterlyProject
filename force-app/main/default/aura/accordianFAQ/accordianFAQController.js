({
    doInit: function (cmp, event) {

        //var url = $A.get('$Resource.Zoetis_Static_Resources');
        //component.set('v.backgroundImageURL', url);
        //console.log(backgroundImageURL,'===================');

        //alert(10);
        var urlString = window.location.href;
 		var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        cmp.set('v.baseURL', baseURL);
        var action = cmp.get("c.getMarketBasedOnUser");
         action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const result = response.getReturnValue();
                
                 // Acronyms & Abbreviations and Frequently Asked Questions appearing as per result is equal to Costa Rica, Panama and null.
                if(result === 'Costa Rica' || result ==='Panama' || result === null) {
                    cmp.set("v.FAQLabel", ""); 
                    cmp.set("v.marketvalue", result);
                     var cmpTarget = cmp.find('customer_faq_container slds-m-top_large ');
                     $A.util.removeClass(cmpTarget, 'customer_faq_container slds-m-top_large');
                     var cmpTarget1 = cmp.find('slds-text-heading_medium slds-p-bottom_small');
                     $A.util.removeClass(cmpTarget1, 'slds-text-heading_medium slds-p-bottom_small');
                    cmp.set("v.showAcronymsAbbreviationsButton", false);
                     }
                  // Acronyms & Abbreviations and Frequently Asked Questions appearing as per result is not equal Costa Rica, Panama and null.
                else {
                    cmp.set("v.marketvalue", result);  
                    cmp.set("v.FAQLabel", "Frequently Asked Questions"); 
                    var cmpTarget = cmp.find('customer_faq_container slds-m-top_large');
                    $A.util.addClass(cmpTarget, 'customer_faq_container slds-m-top_large');
                    var cmpTarget1 = cmp.find('slds-text-heading_medium slds-p-bottom_small');
                    $A.util.addClass(cmpTarget1, 'slds-text-heading_medium slds-p-bottom_small');
                    cmp.set("v.showAcronymsAbbreviationsButton", true);
                     }
                
            }
        });
        $A.enqueueAction(action);
    },
    
     handleSectionToggle: function (cmp, event) {
         var openSections = event.getParam('openSections');
         if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
     },
            
     handleClick : function (cmp, event ) {
            cmp.set("v.openModal", true);
         
             },
     handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.openModal", false);
         },
})