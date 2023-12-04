({
    launchCaseScreen : function(cmp, event, helper) {
        let objCase = cmp.get('v.objCase');
        let defaultFieldValues = {};
        defaultFieldValues.RecordTypeId = objCase.RecordTypeId;
        //  only populate non-null fields to minimize need for FLS access to fields
        if ( objCase.userMarket ) defaultFieldValues.ZTS_EU_Market__c = objCase.userMarket;
        if ( objCase.AccountId ) defaultFieldValues.AccountId = objCase.AccountId;
        if ( objCase.ContactId ) defaultFieldValues.ContactId = objCase.ContactId;
        if ( objCase.Address__c ) defaultFieldValues.Address__c = objCase.Address__c;
        if ( objCase.AccountNumber ) defaultFieldValues.ZTS_US_Customer_Acc_Number_PayerBillTo__c = objCase.AccountNumber;
        if ( objCase.Type ) defaultFieldValues.Type = objCase.Type;
        if ( objCase.Sub_Type_2__c ) defaultFieldValues.Sub_Type_2__c = objCase.Sub_Type_2__c;
        if ( objCase.AssetId ) defaultFieldValues.AssetId = objCase.AssetId;
        if ( objCase.Primary_Consumable__c ) defaultFieldValues.Primary_Consumable__c = objCase.Primary_Consumable__c;
        if ( objCase.Primary_Error_Code__c ) defaultFieldValues.Primary_Error_Code__c = objCase.Primary_Error_Code__c;
        var createCase = $A.get("e.force:createRecord");
        createCase.setParams({
            "entityApiName": "Case",
            "defaultFieldValues": defaultFieldValues,
            "recordTypeId" : objCase.RecordTypeId,
        });
        createCase.fire();
    },
})