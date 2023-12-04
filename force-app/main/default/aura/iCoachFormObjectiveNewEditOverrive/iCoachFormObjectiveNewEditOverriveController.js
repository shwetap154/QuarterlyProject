({
    handleInit : function(component, event, helper) 
    {
        console.log('handleInit');
        debugger
        var recordId = component.get("v.recordId");
        
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        
        // For some reason, the string starts with "1.", if somebody knows why,
        // this solution could be better generalized.
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        if(addressableContext != null 
           && addressableContext.attributes != null
           && addressableContext.attributes.recordId != null){
            component.set("v.recordId", addressableContext.attributes.recordId); 
            component.find("iCoachFormRecordId").reloadRecord();
        }
        
        
        
        
          
      var iCoachFormObjectiveget = component.get("c.getiCoachObjectiveReleatediCoachForm");
        console.log('iCoachFormObjectiveget',iCoachFormObjectiveget);
        iCoachFormObjectiveget.setParams({ ObjectiveId :component.get("v.formObjectiveId") });
         iCoachFormObjectiveget.setCallback(this, function(response) {
              var state = response.getState();
            if (state === "SUCCESS") {
                 var iCoachFormObjectiveList = response.getReturnValue();
                console.log('iCoachFormObjectiveList',iCoachFormObjectiveList);
                var status= iCoachFormObjectiveList[0].iCoach_Form__r.Status__c;
                console.log('status',status);
                if(status == 'Submitted' || status == 'Completed')
                {
					component.set('v.CompletedSubmitted', true);         
                }
                else
                {
                    component.set('v.CompletedSubmitted', false);   
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(iCoachFormObjectiveget);
        
    },
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        console.log('eventParams :: ', eventParams);
        if(eventParams.changeType === "LOADED") {
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
		
	
})