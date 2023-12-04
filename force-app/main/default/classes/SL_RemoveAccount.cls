/**
* @ClassName    : SL_RemoveAccount
* @JIRATicket   : LIGHTNI-38
* @CreatedOn    : 29th March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to fetch the selected Account records from the list view button.
*/
public with sharing class SL_RemoveAccount 
{
    public List<ZTS_EU_Campaign_Account__c> lstCampAccount              {   get; set;   }
    public String strStatus                                             {   get; set;   }
    public String strCampId                                             {   get; set;   }
    private ApexPages.StandardSetController stdSetContrl;
    private Set<Id> setCampAccountId = new Set<Id>();
    
    /***********
      * Method name  : SL_RemoveAccount
      * Description  : This method will redirect the vf page so as to remove the target accounts.
      * Return Type  : NA.
      * Parameters   : ApexPages.StandardSetController standardController
    ***********/ 
    public SL_RemoveAccount(ApexPages.StandardSetController stdSetContrl)
    {
        this.stdSetContrl = stdSetContrl;
        strStatus = strCampId = '';
        lstCampAccount = new List<ZTS_EU_Campaign_Account__c>();
        
        strCampId = ApexPages.currentPage().getParameters().get('id');
        
        for (ZTS_EU_Campaign_Account__c objCampAccount : (List<ZTS_EU_Campaign_Account__c>)stdSetContrl.getSelected())
        { 
            setCampAccountId.add(objCampAccount.Id);
        }
        lstCampAccount = [SELECT Name FROM ZTS_EU_Campaign_Account__c WHERE ID IN: setCampAccountId AND ZTS_EU_Market_From_Parent__c != 'United States'];
        
        
        
        Campaign objCamp = [Select Id, ZTS_EU_Field_Targeting__c From Campaign Where Id =: StrCampId AND ZTS_EU_Market__c != 'United States'];
        
        strStatus = objCamp.ZTS_EU_Field_Targeting__c;
    }
}