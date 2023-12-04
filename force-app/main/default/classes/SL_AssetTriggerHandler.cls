/**
* @ClassName    : SL_AssetTriggerHandler
* @JIRATicket   : LIGHTNI-1707
* @CreatedOn    : 25th Oct 2019
* @CreatedBy    : Mike Agrapides
* @ModifiedBy   : Prasun Dubey
* @Description  : Handler class for the SL_AssetTrigger trigger.
@Modification Detail: 23th Jan, 2022 SC-009180, allow deletion of asset with competitor asset recordtType and only on accessable accounts
* @ModifiedBy   : Padmavathi Nerella 8/25/2022.Unlink Asset from Account when Ship To is Cleared By Interface User or a System Admin TPBUILD-84
*/

public without sharing class SL_AssetTriggerHandler 
{
    
   /***********
* Method name  : onBeforeInsert
* Description  : Method called on Asset before insert of Asset record.
* Return Type  : void
* Parameters   : assetList 
***********/
    public void onBeforeInsert(List<Asset> lstAssetNew)
    {
        updateAssetProduct(null, lstAssetNew);
        
    }
    
    /***********
* Method name  : onBeforeInsert
* Description  : Method called on Asset before insert of Asset record.
* Return Type  : void
* Parameters   : assetList 
***********/
    public void onBeforeUpdate(Map<Id, Asset> mapAssetOld, Map<Id, Asset> mapAssetNew)
    {
        updateAssetProduct(mapAssetOld, mapAssetNew.values());
    }
    
    
    /***********
* Method name  : updateAssetProduct
* Description  : Method called on insert and update to update the product field on Asset record based on criteria.
* Return Type  : void
* Parameters   : assetList 
***********/
    private void updateAssetProduct(Map<Id, Asset> mapAssetOld, List<Asset> lstAssetNew)
    {
        Set<String> setMaterialNumber = new Set<String>();
        Map<String, Product2> mapMaterialToProduct2 = new Map<String, Product2>();
        
        for(Asset objAsset : lstAssetNew)
        {
            if((mapAssetOld != null && mapAssetOld.get(objAsset.Id).Material_Number__c != objAsset.Material_Number__c && String.isNotBlank(objAsset.Material_Number__c)) 
               || String.isNotBlank(objAsset.Material_Number__c))
                setMaterialNumber.add(objAsset.Material_Number__c);
        }
        
        for(Product2 objProduct : [Select Id, SAP_Product_Number__c From Product2 Where SAP_Product_Number__c IN: setMaterialNumber])
            mapMaterialToProduct2.put(objProduct.SAP_Product_Number__c, objProduct);
        
        for(Asset objAsset : lstAssetNew)
        {
            if(mapMaterialToProduct2.containsKey(objAsset.Material_Number__c))
                objAsset.Product2Id = mapMaterialToProduct2.get(objAsset.Material_Number__c).Id;
        }
    }
    
    // Added Account to Assets based on Ship to Number by AJAYKRISHNA ISTARLA
    
    Public static void getAssetorAddresssAccount(List<Asset> lstAsset){
        //Based on SC-004942, we added Line No: 100 & 101 this trigger will work only for System Administrator & SAP Integration User profile users
        String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        if (profileName == 'System Administrator' || profileName =='SAP Integration User'){
            Set<String> setShip = new Set<String>();
            Map<String, Account> mapAssetAccount = new Map<String, Account>();
            Map<String, Address__c> mapAssetsAddress = new Map<String, Address__c>();
            
            for(Asset asse:lstAsset){
                if(asse.Ship_to_Number__c!=Null && asse.Ship_to_Number__c!=''){
                    setShip.add(asse.Ship_to_Number__c);
                }
                System.debug('Ship_to_Number__c:'+setShip);
            }
            List<Account> accList = new List<Account>();
            accList = [select id,name,ZTS_EU_SAP_Customer_ID__c from Account where ZTS_EU_SAP_Customer_ID__c IN: setShip];
            List<Address__c> addList = new List<Address__c>();
            addList = [select id,name,ZTS_US_Source_Account_Number__c,ZTS_EU_Account__c from Address__c where ZTS_US_Source_Account_Number__c IN: setShip];
            
            for (Account acc : accList )
            {
                mapAssetAccount.put (acc.ZTS_EU_SAP_Customer_ID__c, acc);
            }
            
            for (Address__c add : addList )
            {
                mapAssetsaddress.put (add.ZTS_US_Source_Account_Number__c, add);
            }
            
            
            for(Asset asset:lstAsset)
            { 
                if(mapAssetAccount.containskey(asset.Ship_to_Number__c)){
                    
                    asset.Accountid = mapAssetAccount.get(asset.Ship_to_Number__c).id;
                    
                }else if(mapAssetsAddress.containskey(asset.Ship_to_Number__c)){
                    
                    asset.Address_Lookup__c = mapAssetsAddress.get(asset.Ship_to_Number__c).id;
                    asset.Accountid = mapAssetsAddress.get(asset.Ship_to_Number__c).ZTS_EU_Account__c;
                    
                }else{
                    
                    asset.Accountid = NULL ;
                    asset.Address_Lookup__c= NULL;
                }
            }
        }
    }
    //Added Address record  to Assets based on Ship to Number and Source account number by AJAYKRISHNA ISTARLA
    
    // Added as a part of SC-009180, allow deletion of asset with competitor asset recordtType and only on accessable accounts
    public void checkEditDeletePermission(List<Asset> assetList){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> accountWithAccessIdSet = new Set<Id>();
        List<UserRecordAccess> recordWithAccessList = new List<UserRecordAccess>();
        List<String> exemptedProfileFromDeletionPrevention = new List<String>{'System Administrator','SAP Integration User','System Developer'};
            
            String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        if (!exemptedProfileFromDeletionPrevention.contains(profileName)){ 
            String competitorRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Competitor_Asset').getRecordTypeId();
            
            for(Asset asset: assetList){
                accountIdSet.add(asset.AccountId);
            }
            
            recordWithAccessList = [SELECT RecordId FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND HasReadAccess = true AND RecordId IN :accountIdSet];
            
            for(UserRecordAccess recordWithAccess: recordWithAccessList){
                accountWithAccessIdSet.add(recordWithAccess.RecordId);
            }
            
            for(Asset asset: assetList){
                if(asset.RecordTypeId != competitorRecordTypeId || (asset.AccountId != null && !accountWithAccessIdSet.contains(asset.AccountId)) || (asset.AccountId != null && asset.OwnerId != UserInfo.getUserId())){
                    asset.addError('You don\'t have permission to delete this asset');
                }
            }
        }
    }
    
    //Added by sreekanth SC-009545
    public void updateZoetisFlagonInsert(List<Asset> assets,Map<Id,Asset> oldAssets){
        List<Id> accids = new List<Id>();
        List<Id> oldAccids = new List<Id>();
        List<Account> accountUpd = new List<Account>();
        String competitorRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Competitor_Asset').getRecordTypeId();
        String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name; 
        
        for(Asset a: assets){
            if(a.recordTypeId != competitorRecordTypeId && profileName =='SAP Integration User'){
                if(a.AccountId != null ){
                    accids.add(a.AccountId);
                }
                if(oldAssets != null && oldAssets.get(a.id).AccountId != a.AccountId){
                    oldAccids.add(oldAssets.get(a.id).AccountId);
                }
            }
            
        }
      
       
        if(!accids.isEmpty()){
            for(Account acc : [Select id,Has_Zoetis_Asset__c from Account where id IN: accids and Has_Zoetis_Asset__c = false])
            {
                acc.Has_Zoetis_Asset__c = true;
                accountUpd.add(acc);
            } 
        }
        /*if(!oldAccids.isEmpty()){
            for(Account acc : [Select id,Has_Zoetis_Asset__c,(select id from Assets where recordtype.DeveloperName != 'Competitor_Asset' AND createdby.profile.name ='SAP Integration User') from Account 
                               where id IN: oldAccids])
            {
                if(acc.Has_Zoetis_Asset__c == true && acc.Assets.isEmpty()){
                    acc.Has_Zoetis_Asset__c = false;
                    accountUpd.add(acc);
                }
            } 
        }*/
        
        Map<Id, List<Asset>> mapofAccAsset = new Map<Id, List<Asset>>();
        if(!oldAccids.isEmpty()){
            for(Asset asss : [select id, AccountId,recordtype.DeveloperName,createdby.profile.name from Asset where AccountId in: oldAccids and Createdby.profile.name ='SAP Integration User' and Recordtype.DeveloperName != 'Competitor_Asset']){
                if(mapofAccAsset.ContainsKey(asss.AccountId)){
                    mapofAccAsset.get(asss.AccountId).add(asss); 
                } 
                else {
                    mapofAccAsset.put(asss.AccountId, new List<Asset>{asss});
                }		            
            }
        }
        
         for(Account acc : [Select id, Has_Zoetis_Asset__c from Account where id in: oldAccids]){
            if(mapofAccAsset.ContainsKey(acc.Id) == false && acc.Has_Zoetis_Asset__c == true){
                acc.Has_Zoetis_Asset__c = false;
                accountUpd.add(acc);
            }
        }
        
        
        if(!accountUpd.isEmpty()){
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            Update accountUpd;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        } 
    }
    //Added by sreekanth SC-009545
    public void updateZoetisFlagonDelete(List<Asset> assets){
        List<Id> accids = new List<Id>();
        List<Account> accountUpd = new List<Account>();
        String competitorRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Competitor_Asset').getRecordTypeId();
        
        for(Asset a: assets){
            if(a.AccountId != null && a.recordTypeId != competitorRecordTypeId){
                accids.add(a.AccountId);
            }
        }
        if(!accids.isEmpty()){
            List<Account> accLst = [Select id,Has_Zoetis_Asset__c,(select id from Assets
                                    where recordtype.DeveloperName != 'Competitor_Asset' AND createdby.profile.name = 'SAP Integration User') 
                                    from Account where Id In: accids];
            for(Account a : accLst)
            {
                if(a.Has_Zoetis_Asset__c == true && a.Assets.isEmpty()){
                    a.Has_Zoetis_Asset__c = false;
                    accountUpd.add(a);  
                }
                
            } 
        }
        if(!accountUpd.isEmpty()){
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            Update accountUpd;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    
}