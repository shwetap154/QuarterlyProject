/**
* @ClassName    : SL_AddToCampaignOREvent
* @JIRATicket   : LIGHTNI-24
* @CreatedOn    : 22nd March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to fetch the selected Account records from the list view button.
*/
public with sharing class SL_AddToCampaignOREvent
{
    public List<Account> lstAccount             {   get; set;   }
    private ApexPages.StandardSetController standardController;
    private Set<Id> setAccountId = new Set<Id>();
    
    /***********
      * Method name  : SL_AddToCampaignOREvent
      * Description  : This method will get the selected Accounts.
      * Return Type  : NA.
      * Parameters   : ApexPages.StandardSetController standardController
    ***********/ 
    public SL_AddToCampaignOREvent(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        
        lstAccount = new List<Account>();
        
        for (Account objAccount : (List<Account>)standardController.getSelected())
        { 
            setAccountId.add(objAccount.Id);
        }
        lstAccount = [SELECT Name FROM Account WHERE ID IN: setAccountId AND ZTS_EU_Market__c != 'United States'];
    }
}