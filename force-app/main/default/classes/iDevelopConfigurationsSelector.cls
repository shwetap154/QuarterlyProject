/**
Class Name	    : iDevelopConfigurationsSelector
Description	    : Selector Class created as part of TPDEV-167 for the iDevelop_Configurations object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 02-10-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	02-10-2023   Added Methods to Retrive list of Configuration records having Market same as setMarket value
*/
public With Sharing class iDevelopConfigurationsSelector{

    /**     * @Description To Retrive list of Configuration records having Market same as setMarket value      
			* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 02-10-2023 
			* @param       Set of Markets
    */
    public static List<iDevelop_Configuration__c> selectIDevConfigByMarket(set<String> setMarket) {
        
        List<iDevelop_Configuration__c> lstIDevConfig =[SELECT Id,Market__c,Role__c 
                                                         FROM iDevelop_Configuration__c 
                                                         WHERE Market__c IN : setMarket];
        return lstIDevConfig;
        
        
    }
    
    /**     * @Description :To Retrive list of Idevelop Configuration records.
			* @Author      :Raut, Pranav Krushnarao @ Zoetis Inc | 04-06-2023 
			* @param       :
    */
    public static List<iDevelop_Configuration__c> selectAll() {     
    List<iDevelop_Configuration__c> lstIdevelopConfig = [SELECT Id,Market__c,Role__c,Days_to_Complete__c,Due_Date_Day__c,Due_Date_Month__c FROM iDevelop_Configuration__c];    
	return lstIdevelopConfig;
        
    }
}