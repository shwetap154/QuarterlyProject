({
    getInfo: function(cmp, event, helper) {
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getRecordTypes");
        action.setParams({
            objectName: "Case"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordTypes = response.getReturnValue();
                var options = [];
                for (var i = 0; i < recordTypes.length; i++) {
                    options.push({ label: recordTypes[i].label, value: recordTypes[i].Id, Desc: recordTypes[i].RTDesc  });
                }
                cmp.set("v.recordTypeOptions", options);
            } else {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    cmp.set("v.error", errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
        
        cmp.set("v.isLoading", true);
        window.setTimeout(
            $A.getCallback(function() {
                cmp.set("v.isLoading",false);
            }), 3000
        );
    },
    
    handleRecordTypeSelection: function(cmp, event, helper) {
        cmp.set("v.selectedRecordType", event.getSource().get("v.value"));
    },
    
    handleClick: function(component, event, helper) {
        component.set("v.isLoading", true);
        $A.get('e.force:refreshView').fire();
        $A.get('e.force:closeQuickAction').fire();
        var defaultValues = "MasterRecordId=null";
        
        if(component.get("v.accountId")){
            defaultValues = defaultValues + ",AccountId="+component.get("v.accountId");
        }if(component.get("v.contactId")){
            defaultValues = defaultValues + ",ContactId="+component.get("v.contactId");
        }
        
        defaultValues = defaultValues + ",Customer_Address_Lookup__c="+component.get("v.addressId");
        defaultValues = defaultValues + ",Address__c="+component.get("v.addressId");
        var cityvalue= component.get("v.record.ZTS_EU_City__c");
        defaultValues = defaultValues + ",City__c="+cityvalue;
        var marketvalue=component.get("v.record.ZTS_EU_Market_from_Parent__c");
        defaultValues = defaultValues + ",ZTS_EU_Market__c="+marketvalue;
        var zipvalue = component.get("v.record.Zip_Postal_Code__c");
        defaultValues = defaultValues + ",Zip__c="+zipvalue;
        
        component.find("navService").navigate({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Case",
                actionName: "new"
            },
            state: {
                defaultFieldValues: defaultValues,
                nooverride: "1",
                recordTypeId: component.get("v.selectedRecordType"),
                Address__c: component.get("v.addressId")
            }
        }, true);
        
    }
    
    
})