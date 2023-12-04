/*
Trigger Name	: ContentDocumentLinkTrigger
Description	    : Trigger created as part of TPDEV-554 for the ContentDocumentLink object. 
Created By		: Nayak, Kalyan
Created Date	: 06-22-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
1.0   Nayak, Kalyan			 06-22-2023   	Added afterUpdate trigger operations to call TriggerHandler             
1.1   Sweta Kumari           09-26-2023     file Visibility to all attached documents related to object    

*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        new ContentDocumentLinkTriggerHandler().run();}
    
    
   if(Trigger.isInsert && Trigger.isBefore)
   {
       new ContentDocumentLinkTriggerHandler().run();
   }    
    
}