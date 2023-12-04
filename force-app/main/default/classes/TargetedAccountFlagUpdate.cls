/*************************************************************************************
* Name          :    TargetedAccountFlagUpdate
* Description   :    Batch class to update the flag on Targeted Accounts.
* Author        :    Laxmikanth(CloudSense)
 
****************************/

global class TargetedAccountFlagUpdate implements Database.Batchable<sObject>{
    List<ZTS_EU_Campaign_Account__c> toUpdate = new List<ZTS_EU_Campaign_Account__c>(); 
    List<Campaign> MainCampaigns = new List<Campaign>();
    global TargetedAccountFlagUpdate(List<Campaign> CampaignIds)
    {
        
        MainCampaigns = CampaignIds;
    }

       
      global Database.QueryLocator start(Database.BatchableContext BC){   
      return Database.getQueryLocator([Select Id, ZTS_EU_Campaign__c,ZTS_US_Active__c,ZTS_EU_Campaign__r.isActive,ZTS_EU_Campaign__r.Description,ZTS_EU_Campaign__r.Key_Initiative__c,Key_Initiative__c from ZTS_EU_Campaign_Account__c where ZTS_EU_Campaign__c IN: MainCampaigns AND ZTS_EU_Market_From_Parent__c = 'United States']);
   }
    global void execute(Database.BatchableContext BC,List<ZTS_EU_Campaign_Account__c> TargetAccounts){    
       
                for(ZTS_EU_Campaign_Account__c acct : TargetAccounts){
                    if(acct.ZTS_EU_Campaign__r.Key_Initiative__c==true&&acct.ZTS_EU_Campaign__r.isActive==true){
                            acct.Key_Initiative__c=true;
                            acct.ZTS_US_Active__c=true; 
                            acct.ZTS_US_Description__c = acct.ZTS_EU_Campaign__r.Description;
                            toUpdate.add(acct);
                            system.debug('11 loop entered');
                    }
                    
                    else if(acct.ZTS_EU_Campaign__r.Key_Initiative__c==true&&acct.ZTS_EU_Campaign__r.isActive==false){
                           acct.Key_Initiative__c=true; 
                            acct.ZTS_US_Active__c=false; 
                            acct.ZTS_US_Description__c = acct.ZTS_EU_Campaign__r.Description;
                           toUpdate.add(acct);
                           system.debug('10 loop entered');
                     }
                     else if(acct.ZTS_EU_Campaign__r.Key_Initiative__c==false&&acct.ZTS_EU_Campaign__r.isActive==true){
                           acct.Key_Initiative__c=false;
                           acct.ZTS_US_Active__c=true; 
                           acct.ZTS_US_Description__c = acct.ZTS_EU_Campaign__r.Description;
                           toUpdate.add(acct);
                           system.debug('01 loop entered');
                       }
                     else if(acct.ZTS_EU_Campaign__r.Key_Initiative__c==false&&acct.ZTS_EU_Campaign__r.isActive==false){
                           acct.Key_Initiative__c=false;
                           acct.ZTS_US_Active__c=false; 
                           acct.ZTS_US_Description__c = acct.ZTS_EU_Campaign__r.Description;
                           toUpdate.add(acct);
                           system.debug('00 loop entered');
                        }   
                  }
      
    if(toUpdate.size()>0){ 
        system.debug('no.of accts to update'+toUpdate.size());                        
        Update toUpdate ; 
       }
    }
      
    global void finish(Database.BatchableContext BC){
     }
}