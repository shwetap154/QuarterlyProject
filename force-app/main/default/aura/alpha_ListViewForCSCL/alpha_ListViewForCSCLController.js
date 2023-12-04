({
    
    fetchOrders : function(component, event, helper) {
        
        helper.getMonthPicklist(component, event,helper);
        helper.getYearPicklist(component, event,helper);
        helper.getIndustryPicklist(component, event);
        
        
        helper.geturl(component);
        
        /*var action = component.get("c.fetchOrds");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                
                component.set("v.ordtList", records);
            }
        });
        $A.enqueueAction(action);*/
    },
     handleCompanyOnChangeYear : function(component, event, helper) {
        var indutry = component.get("v.yearstr");
            
         component.set("v.yearstrSave", indutry);  
            
    } ,
            handleCompanyOnChangeMonth : function(component, event, helper) {
        var indutry = component.get("v.monthStr");
            component.set("v.monthStrSave", indutry);  
            
    } ,
            //Handle Lead Save
    handleSearch : function(component, event, helper) {
        var allValid = component.get("v.monthStrSave");
        var allValid1 = component.get("v.yearstrSave");
       
        if (typeof allValid == 'undefined' || typeof allValid1 == 'undefined') {
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'Please provide Month and Year to search',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
            
        }else{
        var mnth = component.get("v.monthStrSave");
        var yr = component.get("v.yearstrSave");
            var action = component.get("c.filterOrds");
        //alert(component.get("v.pickliststring"));
        action.setParams({
            "mnth" : mnth,
            "yr": yr,
            "selectRecordId" : component.get("v.selectRecordId"),
            "picklst":component.get("v.pickliststring")
        });
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state === "SUCCESS"){
                var records =a.getReturnValue();
                //alert(JSON.stringify(records));
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.ordtList", records);
            }
        });       
        $A.enqueueAction(action);
        component.set("v.ispreview", true);
        }
      },
    
    
    searchField : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        component.set("v.LoadingText", true);
        if(currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "value" : currentText
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
                if(component.get("v.searchRecords").length == 0) {
                    console.log('000000');
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
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);
    },
    
    setSelectedRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        //alert(currentText);
        //alert(event.currentTarget.dataset.name);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        component.find('userinput').set("v.readonly", true);
    }, 
    
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.find('userinput').set("v.readonly", false);
    },
    //handle Industry Picklist Selection
    handleCompanyOnChange : function(component, event, helper) {
        var indutry = component.get("v.pickliststring");
        //alert(indutry);
    }

})