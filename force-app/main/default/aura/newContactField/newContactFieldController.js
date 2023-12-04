({
    doInit : function(cmp, event, helper) {
        let objCase = cmp.get('v.objCase');
        let apiName = cmp.get('v.apiName');
        if(apiName === 'AccountId')
            cmp.find('field').set('v.value', objCase['AccountId']);
    }
})