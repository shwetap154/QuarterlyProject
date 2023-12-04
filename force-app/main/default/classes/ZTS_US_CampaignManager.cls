/****************************************************************************************************************************************** 
 * Trigger Name   : ZTS_US_CampaignManager
 * Description  : This class contain operation used to for Campaign Management.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 17 April 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   04/17/2014           Created
*****************************************************************************************************************************************/
public  class ZTS_US_CampaignManager {

   /***********
    * Method name  : getCampaignsWithMembers
    * Description  : This method returns the associated CampaignMembers associated to Campaign.
    * Return Type  : Campaign list with Members.
    * Parameters   : Campaign Id list.
    ***********/
 public static List<Campaign> getCampaignsWithMembers(List<Id> campaignIds){
	 return [SELECT Id, IsActive, ZTS_EU_External_ID__c, Name, ZTS_EU_Field_Targeting__c,Type, 
													  (SELECT CampaignId,ContactId FROM CampaignMembers) FROM Campaign WHERE ID IN :campaignIds AND ZTS_EU_Market__c = 'United States'];
													  
   }
   
   /***********
    * Method name  : getCampaignsWithMembersForTargetAccounts
    * Description  : This method returns the associated CampaignMembers associated to Campaign.
    * Return Type  : Campaign list with Members.
    * Parameters   : CampaignAccounts List and AccontContactIdMap.
    ***********/
 public static List<Campaign> getCampaignsWithMembersForTargetAccounts(List<ZTS_EU_Campaign_Account__c > targetAccList,Map<Id,Set<Id>> accContactIdMap){
	 	Set<Id> campaignIds=new Set<Id>();
	 	Set<Id> conIds=new Set<Id>();
	 	 for(ZTS_EU_Campaign_Account__c ta:targetAccList){
	 	 	campaignIds.add(ta.ZTS_EU_Campaign__c);
	 	 }
	 	 
	 	for(Set<Id> conIdSet:accContactIdMap.values()){
	 		for(Id conId:conIdSet){
	 		conIds.add(conId);
	 		}
	 	}
	 	 
	 return [SELECT Id, IsActive, ZTS_EU_External_ID__c, Name, ZTS_EU_Field_Targeting__c,Type, 
													  (SELECT CampaignId,ContactId FROM CampaignMembers WHERE ContactId IN :conIds) FROM Campaign WHERE ID IN :campaignIds AND ZTS_EU_Market__c = 'United States'];
													  
   }
   
     /***********
    * Method name  : getAccountWithContacts
    * Description  : This method returns the contacts associated with Accounts.
    * Return Type  : Account list with Contacts.
    * Parameters   : Account Id list.
    ***********/
   public static List<Account> getAccountWithContacts(List<Id> accIds){
   	return [SELECT Id, Name, (SELECT AccountId,Id,Name,HasOptedOutOfEmail,HasOptedOutOfFax,DoNotCall,ZTS_US_Phone_Opt_out__c,
	 											 ZTS_EU_Contact_Status__c,ZTS_US_NARC_ID__c,Email FROM Contacts ) 
	 											 FROM Account WHERE ID IN :accIds AND ZTS_EU_Market__c = 'United States'];
   }
}