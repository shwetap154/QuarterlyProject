/*
Class Name		: ContentDocumentLinkTriggerHandler
Description	    : Trigger_Handler Class as part of TPDEV-554 for the ContentDocumentLink object. 
Created By		: Nayak, Kalyan
Created Date	: 06-22-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
1.0   Nayak, Kalyan			 06-22-2023   	Added Methods to call Service class upon beforeInsert

*/
public With Sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {

    /*
	* @Description : This methode will call service class upon Updation of a record      
	* @Author      : Nayak, Kalyan @ Zoetis Inc | 06-22-2023 
	* @param       : ContentDocumentLink records
	*/
    public override void afterInsert() {
        ContentDocumentLinkService.updateContentDocumentShareType((Map<Id,ContentDocumentLink>)trigger.newMap);
    }
    
    /*
	* @Description : This methode will call service class upon insertion of a record      
	* @Author      : Kumari, Sweta @ Zoetis Inc | 09-26-2023 
	* @param       : ContentDocumentLink records
	*/
   public override void beforeInsert() {
     ContentDocumentLinkService.setVisibleToAllUsersForOrders((List<ContentDocumentLink>)Trigger.New);
   }
    

    
}