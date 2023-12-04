/**
Class Name	    : iDevelopConfigurationsTriggerHandler
Description	    : Trigger_Handler Class as part of TPDEV-167 for the iDevelop_Configurations object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 02-10-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao	 02-10-2023   Added Methods to call Service class upon beforeInsert & beforeUpdate
*/
public With Sharing class iDevelopConfigurationsTriggerHandler extends TriggerHandler {
    
    /**     * @Description This methode will call service class upon Insertion of a record      
			* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 02-10-2023 
			* @param       iDevelopConfiguration record
    */
    public override void beforeInsert() {
        iDevelopConfigurationsService.iDevelopConfigValidations(trigger.new, null);        
    }
    
    /**     * @Description This methode will call service class upon Updation of a record      
			* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 02-10-2023 
			* @param       iDevelopConfiguration record
    */
    public override void beforeUpdate() {
        iDevelopConfigurationsService.iDevelopConfigValidations(trigger.new, (map<Id,iDevelop_Configuration__c>)trigger.oldMap);        

    }
    
}