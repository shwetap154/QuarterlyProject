/*************************************************************************************************************************
  Class Name     : USupdate_Opt_Out_Account
  Description    : Class to Update an Account's Email, Email_Opt_Out and Invalid Email when Contact of Record Type "Account Contact" updated.
  Created By     : Sohil Shah(CloudSense)
  Created On     : 04/22/2015
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  CloudSense/Sohil Shah               04/22/2015              Created DEF-001643
***************************************************************************************************************************/
public class USupdate_Opt_Out_Account
{
    
    public static boolean myFlag = false;
    public static void Opt_Out_AccountUpdate(List<Contact> newlyUpdateContactList)
    {
        if(myFlag == false)
        {
            List<Account> accountList = new List<Account>();
            List<Account> accountListToUpdate = new List<Account>();
            List<ID> accountIds = new List<ID>();
            Map<Id,Id> ContactVsAccountIdMap = new Map<Id,Id>();
            Map<Id,Account> accountIdVsAccountMap = new Map<Id,Account>(); 
            for(Contact con : newlyUpdateContactList)
            {
                accountIds.add(con.AccountID);
                ContactVsAccountIdMap.put(con.id,con.AccountID);
            }
            accountList = [Select Id, Name, Email__c,ZTS_US_Email_Opt_Out__c,ZTS_Invalid_Email__c from Account where Id IN: accountIds AND ZTS_EU_Market__c = 'United States'];
            if(accountList.size() > 0 && (!accountList.isEmpty()) && accountList !=null)
            {
                for(Account acc : accountList)
                {
                    accountIdVsAccountMap.put(acc.id,acc);
                }
                for(Contact con: newlyUpdateContactList)
                {
                    accountIdVsAccountMap.get(ContactVsAccountIdMap.get(con.id)).Email__c = con.Interface_Email__c;
                    accountIdVsAccountMap.get(ContactVsAccountIdMap.get(con.id)).ZTS_US_Email_Opt_Out__c = con.Interface_Email_Opt_Out__c;
                    accountIdVsAccountMap.get(ContactVsAccountIdMap.get(con.id)).ZTS_Invalid_Email__c = con.ZTS_Invalid_Email__c;
                    accountListToUpdate.add(accountIdVsAccountMap.get(ContactVsAccountIdMap.get(con.id)));
                }
                myFlag = true;
                update accountListToUpdate;
            }
        }
    }
}