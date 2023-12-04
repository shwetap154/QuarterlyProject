trigger SL_AssetTrigger on Asset (before insert, before update,before delete,after insert,after update,after delete) {
    
    // Added for LIGHTNI-1707
    // Updates the Asset AccountId based on Asset.Address_Lookup__c
    
    SL_AssetTriggerHandler handler = new SL_AssetTriggerHandler();
     if(Trigger.isBefore)
    {
    if(Trigger.isInsert || Trigger.isUpdate ){
    
    SL_AssetTriggerHandler.getAssetorAddresssAccount(Trigger.new);
    
    }else if(Trigger.isUpdate || Trigger.isDelete){
        handler.checkEditDeletePermission(Trigger.old);
    }
    
    }
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
            new SL_AssetTriggerHandler().onBeforeInsert(Trigger.new);
        if(Trigger.isUpdate)
            new SL_AssetTriggerHandler().onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    
    //Added by sreekanth SC-009545
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert){
            handler.updateZoetisFlagonInsert(Trigger.new,null);
        }
        if(Trigger.isUpdate){
            handler.updateZoetisFlagonInsert(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isDelete){
            handler.updateZoetisFlagonDelete(Trigger.old);
        }

    }

}