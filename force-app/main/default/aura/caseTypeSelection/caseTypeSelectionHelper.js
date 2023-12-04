({
    /*******************************************************
    @function    checkAssetAndConsumable
    @brief       checks if case object has Primary_Consumable and AssetId set. If not, hides Primary Error Code lookup

    @param       component
    @param       objCase : case record details from wizard.

    *******************************************************/
    checkAssetAndConsumable : function(cmp,objCase){
        if((objCase.Primary_Consumable__c == undefined || objCase.Primary_Consumable__c =='') && (objCase.AssetId ==undefined || objCase.AssetId =='')){
            cmp.set("v.hasAssetOrConsumable",false)
            objCase.Primary_Error_Code__c = ''
            cmp.set('v.objCase', objCase);
        }
    },
})