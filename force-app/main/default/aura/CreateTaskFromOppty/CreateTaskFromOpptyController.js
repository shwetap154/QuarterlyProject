/* <!--
 -Created by Aritra Chakraborty on 29-Jul-2021 for SC-008128.
 -->*/

({  
    
    doInit: function(component, event, helper) {
        
            var createEvent = $A.get("e.force:createRecord");
            createEvent.setParams({
                "entityApiName": "Task",
                "defaultFieldValues": {
                    "WhatId": component.get("v.recordId")
                }
            });
            createEvent.fire();
        }
       
})