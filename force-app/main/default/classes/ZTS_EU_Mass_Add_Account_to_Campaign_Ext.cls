/****************************************************************************************************************************************** 
 * Class Name     : ZTS_EU_Mass_Add_Account_to_Campaign
 * Description      : The class acts as an extension for the mass add account page to Campaign
                   
 * Created By   : Deloitte Consulting
 * Created Date : May 14th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Benjamin Prozinski       05/06/2014          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_Mass_Add_Account_to_Campaign_Ext    
{
  public Campaign currentCampaignRecord {get;set;}
  public String campaignId  {get;set;}
  public String campName {get;set;}
  public Id AccountId;
  public List<Account> showAccounts{get;set;}
  public ZTS_EU_Mass_Add_Account_to_Campaign_Ext(ApexPages.StandardController controller)
  {
    currentCampaignRecord = (Campaign)controller.getRecord();
    /*if(ApexPages.currentPage().getParameters().containsKey('isError')){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Account(s) has already been added to the Campaign'));
    }*/
    if(ApexPages.currentPage().getParameters().containsKey('Id')){
      campaignId = ApexPages.currentPage().getParameters().get('Id');
      for(Campaign oCamp : [Select Id, Name from Campaign where Id =: campaignId]){
          campName = oCamp.Name;
      }
    }
  }
  
  public void getAccounts()
  {
    
  }
}