({
    fectchSAPIDs : function(component, event, helper) {
        if(component.get('v.objCase').hasOwnProperty('isSAPNumber') && !component.get('v.objCase').isSAPNumber) {
            component.set('v.rows', []);
            component.set('v.showCMP', false);
            return;
        }
        helper.getRelatedSAPIds(component);
    },

    selectSAPNumber : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        let objCase = component.get('v.objCase');
        if(!$A.util.isEmpty(selectedRows)) {
            objCase.Address__c = selectedRows[0].Id;
            let sourceAccNum = selectedRows[0].ZTS_US_Source_Account_Number__c ? ' ( '+selectedRows[0].ZTS_US_Source_Account_Number__c+' )' : '';
            objCase.AccountNumber = selectedRows[0].ZTS_US_Source_Account_Number__c;
            objCase.SAPName = selectedRows[0].Name + sourceAccNum;
            component.set('v.objCase', objCase);
            if(objCase.objectApiName != 'Contact')
                helper.contactList(component, objCase.AccountId);
            else {
                component.set('v.displayCaseComponent', true);
                component.set('v.activeSectionName', 'CaseDetails');
            }
        }
        
    },

    onNewCaseReset : function(cmp, event, helper) {
        let isSearchErased = event.getParam('isSearchErased');
        if(isSearchErased) {
            cmp.set('v.rows', []);
            cmp.set('v.cols', []);
            cmp.set('v.showCMP', false);
            cmp.set('v.displayCaseComponent', false);
        }
    }
})