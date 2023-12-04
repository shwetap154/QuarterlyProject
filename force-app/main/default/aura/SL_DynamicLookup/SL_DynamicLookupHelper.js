({
    displayFieldData : function(cmp) {
        cmp.set("v.lstSelectedUsers", []);
        var name = cmp.get("v.selRecName");
       
        if(name != null && name != undefined && name != '') {
            var newSelectedUserObject = {
                id : cmp.get("v.selRecId"),
                Name : cmp.get("v.selRecName")
            }
            // Update the Searchstring with blank
            cmp.set("v.searchString", '');
            var listOfselectedUsers = cmp.get("v.lstSelectedUsers");
            listOfselectedUsers.push(newSelectedUserObject);
            cmp.set("v.lstSelectedUsers", listOfselectedUsers);            
            
    	}
    },
    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch : function(cmp) {
        
       
        // Get the search string, input element and the selection container
        var searchString = cmp.get("v.searchString");
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find("lookuplist");
        var lookupListItems = cmp.find("lookuplist-items");
        var lookupDiv = cmp.find("lookup-div");
 
        // Clear any errors and destroy the old lookup items container
        inputElement.set('v.errors', null);
        lookupListItems.set('v.body', new Array());
        
        // We need at least 2 characters for an effective search
        if (typeof searchString === 'undefined' || searchString.length < 2) {
            // Hide the lookuplist
            $A.util.addClass(lookupList, 'slds-hide');
            $A.util.removeClass(lookupDiv, 'slds-is-open');
            return;
        }
 
        // Show the lookuplist
        $A.util.removeClass(lookupList, 'slds-hide');
        $A.util.addClass(lookupDiv, 'slds-is-open');
 
        // Get the API Name
        var sObjectAPIName = cmp.get('v.sObjectAPIName');
        // Create an Apex action
        var action = cmp.get("c.lookup");
 
        // Mark the action as abortable, this is to prevent multiple events from the keyup executing
        action.setAbortable();
 		
        action.setParams({ "searchString" : searchString,
         					"sObjectAPIName" : sObjectAPIName, 
         					"isLOFilter" : cmp.get("v.isFilter")
         				});
                           
        // Define the callback
        action.setCallback(this, function(response) {
            var state = response.getState();
            // Callback succeeded
            if (cmp.isValid() && state === "SUCCESS") {
                // Get the search matches
                var matches = response.getReturnValue();
                // If we have no matches, return
                if (matches.length == 0) {
                    return;
                }
               
                // Render the results
                this.renderLookupComponents(cmp, lookupListItems, matches);
            }
            else if (state === "ERROR") { // Handle any error by reporting it
                var errors = response.getError();
                 
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayToast('Error', errors[0].message);
                    }
                }
                else {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });
         
        // Enqueue the action                  
        $A.enqueueAction(action);                
    },
    /**
     * Render the Lookup List Components
     */   
    renderLookupComponents : function(cmp, lookupListItems, matches) {
        // list Icon SVG Path and Class
        var listIconSVGPath = cmp.get('v.listIconSVGPath');
        var listIconClass = cmp.get('v.listIconClass');
 
        // Array of components to create
        var newComponents = new Array();
        
        // Add a set of components for each match found
        for (var i=0; i<matches.length; i++) {

            var listOfselectedUsers = cmp.get("v.lstSelectedUsers");
            var liStyling = '';
			
            if(listOfselectedUsers && matches[i].SObjectId) {
                for( var j in listOfselectedUsers) {
                    if(listOfselectedUsers[j].id && listOfselectedUsers[j].id == matches[i].SObjectId) {
                        liStyling = ' disabledLi';
                    }
                }
            }
            // li element
            newComponents.push(["aura:html", {
                "tag" : "li",
                "HTMLAttributes" : {
                    "class" : "slds-lookup__item" + liStyling
                }
            }]);
 
            // a element
            newComponents.push(["aura:html", {
                "tag" : "a",
                "HTMLAttributes" : { 
                    "id" : cmp.getGlobalId() + '_id_' + matches[i].SObjectId, 
                    "role" : "option", 
                    "onclick" : cmp.getReference("c.select"),
                    "data-textValue" : matches[i].SObjectLabel
                }
            }]);

            newComponents.push(["lightning:icon", {
                "iconName" : (cmp.get("v.sObjectAPIName") == 'User'?'standard:user':'custom:custom24'), //listIconSVGPath,
                "size" : "small",
                "class" : "slds-input__icon liContactImage"
            }]);
 
            // output text component
            // For some reason adding an aura:id to this component failed to record the id for subsequent cmp.find requests
            newComponents.push(["ui:outputText", {
                "value" : matches[i].SObjectLabel
            }]);
        }
 
        // Create the components
        $A.createComponents(newComponents, function(components, status) {
            // Creation succeeded
            if (status === "SUCCESS") {
                // Get the List Component Body
                var lookupListItemsBody = lookupListItems.get('v.body');
                lookupListItemsBody = [];
 
                // Iterate the created components in groups of 4, correctly parent them and add them to the list body
                for (var i=0; i<components.length - 2; i+=4) {
                    // Identify the releated components
                    var li = components[i];
                    var a = components[i+1];
                    var svg = components[i+2];
                    var outputText = components[i+3];
 
                    // Add the <a> to the <li>
                    var liBody = li.get('v.body');
                    liBody.push(a);
                    li.set('v.body', liBody);
 
                    // Add the <svg> and <outputText> to the <a>
                    var aBody = a.get('v.body');
                    aBody.push(svg);
                    aBody.push(outputText);
                    a.set('v.body', aBody);
 
                    // Add the <li> to the container
                    lookupListItemsBody.push(li);
                }
                var li = components[components.length - 1];
                var addButton = components[components.length];

                var liBody = li.get('v.body');
                liBody.push(addButton);
                li.set('v.body', liBody);
                lookupListItemsBody.push(li);
 
                // Update the list body
                lookupListItems.set('v.body', lookupListItemsBody);
           }
           else { // Report any error
                this.displayToast('Error', 'Failed to create list components.');
           }
        });
 
    },
 
    /**
     * Handle the Selection of an Item
     */
    handleSelection : function(cmp, event) {
		// Resolve the Object Id from the events Element Id (this will be the <a> tag)
        var objectId = this.resolveId(event.currentTarget.id);
        
        // The Object label from data attribute
        var objectLabel = event.currentTarget.getAttribute('data-textValue');
		
        var newSelectedUserObject = { 
            id : objectId,
            Name : objectLabel
        }
        // Update the Searchstring with blank
        cmp.set("v.searchString", '');
		
        var listOfselectedUsers = cmp.get("v.lstSelectedUsers");
        listOfselectedUsers.push(newSelectedUserObject);
        cmp.set("v.lstSelectedUsers", listOfselectedUsers);
        // Event to notify the parent component for the list of values selected.
        var updateLookupEvt = cmp.getEvent("SL_evt_LookupValue");
        updateLookupEvt.setParams({
            "Id" : objectId,
            "fieldApi" : cmp.get('v.FieldApiName'),
            "ObjLabel" : objectLabel
        });
        updateLookupEvt.fire();
        
        // Hide the Lookup List
        var lookupDiv = cmp.find("lookup-div");
        $A.util.removeClass(lookupDiv, 'slds-is-open');
 
        // Show the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.removeClass(lookupPill, 'slds-hide');
 
    },
    
    /**
     * Clear the Selection
     */
    clearSelection : function(cmp, event) {

        // The ObjectId from data attribute
        var objectId = event.currentTarget.getAttribute('data-UserId');
        var objectLabel = event.currentTarget.getAttribute('data-textValue');
        var listOfselectedUsers = cmp.get("v.lstSelectedUsers");
		var finalListOfUsers = [];
        
        //Removing the closed pill
        if(listOfselectedUsers && objectId) {
            for(var i in listOfselectedUsers) {
                if(listOfselectedUsers[i].id && listOfselectedUsers[i].id != objectId) {
                    finalListOfUsers.push(listOfselectedUsers[i]);
                }
            }
        }
        cmp.set("v.lstSelectedUsers", finalListOfUsers);
        
        // Event to notify the parent component for the list of values selected.
        var updateLookupEvt = cmp.getEvent("SL_evt_LookupValue");
        updateLookupEvt.setParams({
            "Id" : '',
            "fieldApi" : cmp.get('v.FieldApiName'),
            "ObjLabel" : ''
        });
        updateLookupEvt.fire();
    },
 
    /**
     * Resolve the Object Id from the Element Id by splitting the id at the _
     */
    resolveId : function(elmId) {
        var i = elmId.lastIndexOf('_');
        return elmId.substr(i+1);
    },
 
    /**
     * Display a message
     */
    displayToast : function (title, message) {
        var toast = $A.get("e.force:showToast");
 
        // For lightning1 show the toast
        if (toast) {
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": title,
                "message": message
            });
 
            toast.fire();
        }
        else { // otherwise throw an alert
            alert(title + ': ' + message);
        }
    }
    
})