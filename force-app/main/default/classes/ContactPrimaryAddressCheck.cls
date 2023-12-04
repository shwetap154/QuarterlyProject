/*************************************************************************************
* Name          :    ContactPrimaryAddressCheck.
* Description   :    Class for 'ZTS_EU_Contact_Trigger' to check that the primary address is local or inhertited
                :   
* Author        :    Sohil Shah(CloudSense)
 
Modification Log
----------------
Date             Developer                                    Comments
---------------------------------------------------------------------------------------
06/17/2015       Sohil Shah(CloudSense)                        Created(DEF-000417)


*/
public class ContactPrimaryAddressCheck
{
    public static void localInhetitedPrimaryAddressUpdate(List<Contact> TriggerNew)
    {
        boolean flag = false;
        if(flag == false)
        {
            List<Contact> newlyUpdatedcontactList = new List<Contact>();
            List<Contact> contactToUpdateList = new List<Contact>();
            newlyUpdatedcontactList = [Select Id, Name,ZTS_EU_Primary_Address__c,Local_Address__c,Inherited_Address__c,Account.ZTS_EU_Primary_Address__c from Contact where id IN:TriggerNew AND ZTS_EU_Market__c != 'United States'];
            for(Contact con : newlyUpdatedcontactList)
            {
                System.debug('con.ZTS_EU_Primary_Address__c-----'+con.ZTS_EU_Primary_Address__c);
                System.debug('con.ZTS_EU_Primary_Address__c-----'+con.ZTS_EU_Primary_Address__c);
                if(con.ZTS_EU_Primary_Address__c != con.Account.ZTS_EU_Primary_Address__c && con.ZTS_EU_Primary_Address__c != null)
                {
                   System.debug('if----');
                    con.Local_Address__c = true;
                    con.Inherited_Address__c = false;
                }
                 
                else 
                {
                    if(con.ZTS_EU_Primary_Address__c == con.Account.ZTS_EU_Primary_Address__c && con.ZTS_EU_Primary_Address__c != null)
                    {
                         System.debug('else-if---');
                        con.Local_Address__c = false;
                        con.Inherited_Address__c = true;
                    }
                    else
                    {
                        System.debug('else---');
                        con.Local_Address__c = false;
                        con.Inherited_Address__c = false;
                    }
                }    
                contactToUpdateList.add(con);
                                
            }
            flag = true;
            Database.update(contactToUpdateList,false);
        }       
    }
    
}