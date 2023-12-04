/*************************************************************************************
* Name          :    PrimatyAddressUpdate.
* Description   :    Class for 'ZTS_EU_Account_Trigger' to update all related contact's primary address  
* Author        :    Sohil Shah(CloudSense)
 
Modification Log
----------------
Date             Developer                                    Comments
---------------------------------------------------------------------------------------
06/17/2015       Sohil Shah(CloudSense)                        Created(DEF-000417)


*/

public class PrimatyAddressUpdate
{
    public static void ContactsUpdateOnPrimaryAddressUpdate(List<Account> TriggerNew)
    {
        List<Account> updatedAccountList = new List<Account>();
        Set<Id> contactsID = new Set<Id>();
        List<Contact> contactToUpdateList = new List<Contact>();
        List<Contact> contactsList = new List<Contact>();
        // System.debug('TriggerNew---'+TriggerNew);
        updatedAccountList = [Select Id, ZTS_EU_Primary_Address__c,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_Address_Line_4__c,ZTS_EU_Country__c,ZTS_EU_State_County__c,ZTS_EU_City_Country__c,ZTS_EU_City__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Main_Phone__c,ZTS_EU_District__c, 
        (Select Id, Name,ZTS_EU_Contact__c, ZTS_EU_Contact__r.ZTS_EU_Primary_Address__c,ZTS_EU_Contact__r.ZTS_EU_Address_Line_1__c,ZTS_EU_Contact__r.ZTS_EU_Address_Line_2__c,
        ZTS_EU_Contact__r.ZTS_EU_Address_Line_3__c,ZTS_EU_Contact__r.ZTS_EU_City__c,ZTS_EU_Contact__r.ZTS_EU_City_Country__c,ZTS_EU_Contact__r.ZTS_EU_District__c,
        ZTS_EU_Contact__r.ZTS_EU_State_County__c,ZTS_EU_Contact__r.ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Contact__r.Local_Address__c,
        ZTS_EU_Contact__r.Inherited_Address__c,ZTS_EU_Account__c from Accounts_and_Contacts__r),
        (Select Id, Name,ZTS_EU_Primary_Address__c,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,
        ZTS_EU_Address_Line_3__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,ZTS_EU_District__c,
        ZTS_EU_State_County__c,ZTS_EU_Zip_Postal_Code__c,Local_Address__c,
        Inherited_Address__c,AccountId from Contacts) from Account where id IN: TriggerNew AND ZTS_EU_Market__c != 'United States'];
        // System.debug('updatedAccountList---'+updatedAccountList);
        // System.debug('updatedAccountList--Size-'+updatedAccountList.Size());
        for(Account acc : updatedAccountList)
        {
            for(ZTS_EU_Affiliations__c con: acc.Accounts_and_Contacts__r)
            {               
                if(con.ZTS_EU_Contact__r.ZTS_EU_Primary_Address__c == acc.ZTS_EU_Primary_Address__c)
                {
                    contactsID.add(con.ZTS_EU_Contact__c);
                }
                
            }
        }
        // System.debug('contactsID---'+contactsID);
        // System.debug('contactsID--Size-'+contactsID.Size());
        contactsList = [Select Id, Name,ZTS_EU_Primary_Address__c,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,
        ZTS_EU_Address_Line_3__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,ZTS_EU_District__c,
        ZTS_EU_State_County__c,ZTS_EU_Zip_Postal_Code__c,Local_Address__c,Inherited_Address__c,AccountID from Contact where id IN:contactsID AND ZTS_EU_Market__c != 'United States'];

        Map<Id,List<Contact>> accountIdVsContactMap = new Map<Id,List<Contact>>();
        for(Contact con: contactsList)
        {
            List<Contact> tempList = accountIdVsContactMap.get(con.AccountID);
            if(tempList == null)
            {
                tempList = new List<Contact>();
                accountIdVsContactMap.put(con.AccountId,new List<contact>{con});
            }
            else
            {
                tempList.add(con);
            }
        }
       
        // System.debug('accountIdVsContactMap--------'+accountIdVsContactMap);
        // System.debug('accountIdVsContactMap-Size-------'+accountIdVsContactMap.size());
        
        for(Account acc : updatedAccountList)
        {
            // System.debug('acc --------'+acc.id);
            if(accountIdVsContactMap.containskey(acc.id))
            {
               for(Contact con: accountIdVsContactMap.get(acc.id))
                {                
                    con.ZTS_EU_Primary_Address__c = acc.ZTS_EU_Primary_Address__c;
                    con.ZTS_EU_Address_Line_1__c = acc.ZTS_EU_Address_Line_1__c;
                    con.ZTS_EU_Address_Line_2__c = acc.ZTS_EU_Address_Line_2__c;
                    con.ZTS_EU_Address_Line_3__c = acc.ZTS_EU_Address_Line_3__c;
                    con.ZTS_EU_Country__c = acc.ZTS_EU_Country__c;
                    con.ZTS_EU_State_County__c = acc.ZTS_EU_State_County__c;
                    con.ZTS_EU_City_Country__c = acc.ZTS_EU_City_Country__c;
                    con.ZTS_EU_City__c = acc.ZTS_EU_City__c;
                    con.ZTS_EU_Zip_Postal_Code__c= acc.ZTS_EU_Zip_Postal_Code__c;
                    con.ZTS_EU_District__c= acc.ZTS_EU_District__c;
                    con.Local_Address__c = false;
                    con.Inherited_Address__c = true;
                     
                   contactToUpdateList.add(con);    
                } 
            }            
        }
system.debug('$$$ contactToUpdateList: '+contactToUpdateList);
        Database.update(contactToUpdateList,false);
    }
}