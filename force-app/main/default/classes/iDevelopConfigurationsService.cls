/**
Class Name	    : iDevelopConfigurationsService
Description	    : Service Class created as part of TPDEV-167 for the iDevelop_Configurations object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 02-10-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	02-10-2023   Added Methods to Check for Existing combinations of Market&Role or Market with Configurations
02	 Nayak, Kalyan				03-02-2023	 Updated the method to accept oldMap to compare the update records.
*/
public WIth Sharing class iDevelopConfigurationsService{
    
    /**     * @Description Method to Check for Existing combinations of Market&Role or Market with Configurations      
			* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 02-10-2023 
			* @param       List of iDevelopCongigurations
    */
    public static void iDevelopConfigValidations(List <iDevelop_Configuration__c> lstIDevConfig, map<Id, iDevelop_Configuration__c> mapOldiDevConfig) {
        
        Set<String> setMarket = new Set<String>();
        if(!lstIDevConfig.isEmpty()){
            for(iDevelop_Configuration__c objIDevCon: lstIDevConfig){
                if((String.isNotBlank(objIDevCon.Market__c))                   
                  ){
                      setMarket.add(objIDevCon.Market__c); 
                  }
            }        
        Map<String ,iDevelop_Configuration__c> mapExistingIDevCon = new Map<String,iDevelop_Configuration__c>();
        List<iDevelop_Configuration__c> lstOldIDevCon = iDevelopConfigurationsSelector.selectIDevConfigByMarket(setMarket);  
        if(!lstOldIDevCon.isEmpty()){
            for(iDevelop_Configuration__c objOldIDC : lstOldIDevCon){
                String sOldIDCMarketRole = string.valueOf(objOldIDC.Market__c) + string.valueOf(objOldIDC.Role__c) ;
                mapExistingIDevCon.put(sOldIDCMarketRole, objOldIDC);
            }            
        }        
        for(iDevelop_Configuration__c objNewIDevCon: lstIDevConfig){            
            String strNewIDCMarketRole = string.valueOf(objNewIDevCon.Market__c) + string.valueOf(objNewIDevCon.Role__c) ;
            if(mapOldiDevConfig == null && mapExistingIDevCon.containsKey(strNewIDCMarketRole)){
                objNewIDevCon.addError(System.Label.iDevelopConfigExistingConfig + mapExistingIDevCon.get(strNewIDCMarketRole).Id);
            } 
            if(mapOldiDevConfig != null && (mapOldiDevConfig.get(objNewIDevCon.Id).Market__c != objNewIDevCon.Market__c || mapOldiDevConfig.get(objNewIDevCon.Id).Role__c != objNewIDevCon.Role__c) && mapExistingIDevCon.containsKey(strNewIDCMarketRole)){
                objNewIDevCon.addError(System.Label.iDevelopConfigExistingConfig + mapExistingIDevCon.get(strNewIDCMarketRole).Id);
            } 
        }
    } 
  }
}