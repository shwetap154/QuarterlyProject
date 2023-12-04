/****************************************************************************************************************************************** 
* Class Name : ZTS_createAccountTeams
* Description  :Reffer Trigger on Account.
*                Create an Account Team Records on Prospect Account Creation with Available Offline
*                  
* Created By   : Sohil Shah(CloudSense)
* Created Date : Feb 09, 2015
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
***************************************************************************************************************************
*/
public with sharing class  ZTS_createAccountTeams
{
    
    // public static List<ZTS_EU_Account_Position__c> accountTeamList = new List<ZTS_EU_Account_Position__c>();
    // public static ZTS_EU_Account_Position__c accontPositionObject ;
    // public static List<Id> ownerIds = new List<Id>();
    public static boolean dataAdminFlag = false;
    
    public static void AccountTeamCreation(List<Account> originalAccountList)
    {
        List<ZTS_EU_Account_Position__c> accountTeamList = new List<ZTS_EU_Account_Position__c>();
        ZTS_EU_Account_Position__c accontPositionObject ;
         List<Id> ownerIds = new List<Id>();
        for(Account acc: originalAccountList)
            ownerIds.add(acc.OwnerID);          
        
        List<User> userName = new LIst<User>();
        userName = [Select Id, Name from User where ID IN: ownerIds];
        
        for(User user : userName)
        {
            if(user.Name == 'Data Admin')
                dataAdminFlag = true;
        }
        if(!dataAdminFlag)
        {
            List<ZTS_EU_Position__c> userTerritoryList = new List<ZTS_EU_Position__c>();
            userTerritoryList = [Select Id, Name,OwnerId,ZTS_EU_Employee__c,ZTS_EU_Territory__c from ZTS_EU_Position__c where ZTS_EU_Employee__c IN : ownerIds];

            if(!userTerritoryList.isEmpty())
            {       
                for(Account acc: originalAccountList)
                {
                    if(acc.ZTS_EU_Account_Status__c == 'Pending')
                    {
                        accontPositionObject = new ZTS_EU_Account_Position__c();
                        accontPositionObject.ZTS_EU_Account__c = acc.id;
                        accontPositionObject.ZTS_EU_Bring_offline__c = true;
                        accontPositionObject.ZTS_EU_Position__c = userTerritoryList[0].id; 
                        accountTeamList.add(accontPositionObject);
                    }
                }
                insert accountTeamList;
            }
        }   
    }
}