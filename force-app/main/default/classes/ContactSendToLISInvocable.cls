/**
 * @description       : Service class for "Sync with Labdaq" button on Contact
 * @author            : Yadagiri Avula @ Cognizant
 * @group             : 
* @last modified on  : 03-Aug-2023
 * @last modified by  : Yadagiri Avula @ Cognizant
 * Modifications Log
 * Ver   Date              Author                      Modification
 * 1.0   03-Aug-2023    Yadagiri Avula @ Cognizant   Added sendTOLIS method TPDev-366
\**/


public class ContactSendToLISInvocable {
    
    @InvocableMethod(label='Send TO LIS' description='Set the Send_To_LIS__c flag as true' )
    public static void sendTOLIS(List<Contact> conlist){
        try{
            
            ContactsService.updateSendTOLIS(conlist,null, true);
        }catch(Exception e){
            
            System.debug('The following exception has occurred: ' + e.getMessage());            
        }
        
    }
}