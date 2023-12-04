({
    /*******************************************************
    @function    doInit
    @brief       To prepopulate the seleted value pill if value attribute is filled

    *******************************************************/
    
    doInit : function( component, event, helper ) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        if( !$A.util.isEmpty(component.get('v.value')) ) {
            helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        }
    },
    
    
    /*******************************************************
    @function    searchRecords
    @brief       Invoked when a keyword is entered in search box

    *******************************************************/
    
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    /*******************************************************
    @function    searchRecords
    @brief       When an item is selected. Fires selectedsObjectRecordEvent

    *******************************************************/
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            var objName = component.get("v.objectAPIName");
            console.log('bjName : '+objName);
            // call the event   
            var compEvent = component.getEvent("SelectedRecordEvent");
            // set the Selected sObject Record to the event attribute.  
            compEvent.setParams({"recordId" : selectedRecord.value,
                                 "objectName": objName
                                });  
            // fire the event  
            compEvent.fire();
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    /*******************************************************
    @function    showRecords
    @brief       displays retrieved records.

    *******************************************************/
    
    showRecords : function( component, event, helper ) {
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    /*******************************************************
    @function    removeItem
    @brief       invoked when a seleted record is removed. fires selectedsObjectRecordEvent with empty record ids.

    *******************************************************/
    removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        var objName = component.get("v.objectAPIName");
        // call the event   
        var compEvent = component.getEvent("SelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"recordId" : '',
                             "objectName": objName
                            });  
        // fire the event  
        compEvent.fire();
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
    
    /*******************************************************
    @function    removeItem
    @brief       To close the dropdown if clicked outside the dropdown.

    *******************************************************/    
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
   
})