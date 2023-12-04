/*************************************************************************************************************************
  Class Name     : updateOpt_Out_Contact
  Description    : Class to Update an Contact's Interface_Email, Email_Opt_Out and Invalid Email of Record Type "Account Contact" when it's related Account update.
  Created By     : Sohil Shah(CloudSense)
  Created On     : 04/22/2015
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  CloudSense/Sohil Shah               04/22/2015              Created DEF-001643
  Slalom/Taylor Poppell	              01/08/2020              Updated ContactList query to use getRecordTypeInfosByDeveloperName()
                                                              rather than hardcoded RecordTypeId
  Slalom/Mohamed Seliman			  02/10/2020			  Merged code from US
  Cognizant/Aritra                    04/21/2022              Added new method "resetBypassDupeRuleFlagUSContact" for (SC-008149)
  Zoetis/Padma Nerella                01/26.2023              Moved opt_Out_ContactUpdate method to ContactsService class and contact query to contactsSelector class TPDev-103
***************************************************************************************************************************/
public class updateOpt_Out_Contact
{
    
    public static boolean myFlag = false;
    public static List<Contact> ContactList = new List<Contact>();
    
    public static void copyAccountEmailOnContactInsert(List<Contact> TriggerNew)
    {
        List<Contact> insertedContactList = new List<Contact>();
        insertedContactList = [Select ID, Name,Interface_Email__c,Contact.Accounts_ZTS_US_Email__c from Contact where id IN : TriggerNew];
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact con: insertedContactList)
        {
            con.Interface_Email__c = con.Accounts_ZTS_US_Email__c ;
            contactsToUpdate.add(con);
        }
        update contactsToUpdate;
    }
    
    // Below method is added to reset the Bypass Duplicate Rule flag on US Contact to FALSE if it's previous value is TRUE (SC-008149)
    // Usually Pitcher will send contacts with Bypass Duplicate Rule flag as TRUE
    @future  
    public static void resetBypassDupeRuleFlagUSContact(list<Id> contactIDList){
		
        List<Contact> lstContact = [Select DuplicateBypassed__c, Id from Contact where Id in :contactIDList ];
        List<Contact> lstContactToUpdate = new List<Contact>();
        for(Contact c: lstContact)
        {
            if(c.DuplicateBypassed__c == TRUE)
            {
                c.DuplicateBypassed__c = FALSE;
                lstContactToUpdate.add(c);
            }
        }
        if(lstContactToUpdate.size()>0)
        {
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 			Database.DMLOptions dml = new Database.DMLOptions(); 
 			dml.DuplicateRuleHeader.allowSave = true;
 			dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = false;
            try{
 			List<Database.SaveResult> sr = Database.update(lstContactToUpdate,dml);
            }
            catch(Exception e)
            {
                system.debug('Exception occurred while resetting Duplicate Bypassed flag --'+ e.getMessage());
            }
        }
        
    }
}