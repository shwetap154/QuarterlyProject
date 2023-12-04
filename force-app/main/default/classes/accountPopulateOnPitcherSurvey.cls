/*************************************************************************************
* Name          :    accountPopulateOnPitcherSurvey.
* Description   :    class to Populate the Account(From Call's Account) on On Pitcher Survey Record.
* Author        :    Sohil Shah(CloudSense)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
1/13/2015       Sohil Shah(CloudSense)            Created

**************************************************************************************/

public with sharing class accountPopulateOnPitcherSurvey
{
    public static List<Pitcher_Activity__c>  pitcherActivityListToUpdate = new List<Pitcher_Activity__c>();
    public static List<Pitcher_Activity__c>  pitcherActivityList = new List<Pitcher_Activity__c>();
    public static boolean flag = false;
    
    public  void populateAccount( List<Pitcher_Activity__c> pictherActivityLst)
    {       
        if(!flag)
        {
            pitcherActivityList = [Select Id, Name, Account__c,Call__r.ZTS_EU_Account__c from Pitcher_Activity__c where id IN: pictherActivityLst AND ZTS_EU_Market__c = 'United States'];           
            for(Pitcher_Activity__c pitcher : pitcherActivityList)
            {
                pitcher.Account__c = pitcher.Call__r.ZTS_EU_Account__c;
                pitcherActivityListToUpdate.add(pitcher);            
            }           
             flag = true;
             update pitcherActivityListToUpdate;
                     
          }
    }
}