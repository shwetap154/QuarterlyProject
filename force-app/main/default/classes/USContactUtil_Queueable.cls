/*************************************************************************************************************************
  Class Name     : USContactUtil_Queueable
  Description    : This Queueable class is used to call the future method "resetBypassDupeRuleFlagUSContact" in Class "updateOpt_Out_Contact" from Contact Trigger. (SC-008149)
  Created By     : Aritra
  Created On     : 21/4/2022
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Aritra (Cognizant)                    21/4/2022                 Created

***************************************************************************************************************************/
public class USContactUtil_Queueable implements Queueable {
    
    Public final List<Id> newContactList;
    
    Public USContactUtil_Queueable(List<Id> newContactList){
        this.newContactList = newContactList;
    }
   
    Public void execute(QueueableContext context){
        if(newContactList.size() > 0){
       		updateOpt_Out_Contact.resetBypassDupeRuleFlagUSContact(newContactList);
        }
    }

}