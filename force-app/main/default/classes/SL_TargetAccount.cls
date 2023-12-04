/**
* @ClassName    : SL_TargetAccount
* @JIRATicket   : LIGHTNI-39
* @CreatedOn    : 1st April 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to fetch create the target account for the Campaign.
*/
public with sharing class SL_TargetAccount 
{
    public String strCampId                                             {   get; set;   }
    public String strStatus                                             {   get; set;   }
    public String campName                                              {   get; set;   }
    
    /***********
      * Method name  : SL_TargetAccount
      * Description  : This method will redirect the vf page so as to add the target accounts to the selected
      * Return Type  : NA.
      * Parameters   : ApexPages.StandardSetController standardController
    ***********/ 
    public SL_TargetAccount(ApexPages.StandardSetController stdSetContrl)
    {
        strCampId = ApexPages.currentPage().getParameters().get('id'); 
        
        Campaign objCamp = [Select Id, ZTS_EU_Field_Targeting__c,Name From Campaign Where Id =: StrCampId AND ZTS_EU_Market__c != 'United States'];
        
        strStatus = objCamp.ZTS_EU_Field_Targeting__c;
        campName = objCamp.Name;
    }
}