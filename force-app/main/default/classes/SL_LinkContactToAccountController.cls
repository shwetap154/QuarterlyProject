/**
* @ClassName    : SL_LinkContactToAccountController 
* @JIRATicket   : LIGHTNI-1641
* @CreatedOn    : 25th September, 2019
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Handler for the vf page SL_LinkContactToAccount.
*/
public with sharing class SL_LinkContactToAccountController {

    public static final String parentId = ApexPages.currentPage().getParameters().get('id');
    public String ContactName {get; set;}

    public SL_LinkContactToAccountController(ApexPages.StandardSetController controller) { 
        ContactName = [SELECT Name FROM Contact WHERE Id =:parentId AND ZTS_EU_Market__c != 'United States'].Name;
    }

    /***********
      * Method name  : backToView
      * Description  : This method will exit from the record creation wizard.
      * Return Type  : PageReference
      * Parameters   : NA.
    ***********/
    public PageReference backToView() {
        PageReference pageRef = !Test.isRunningTest() ? ( String.isNotBlank(parentId) ? new PageReference('/'+parentId): new ApexPages.Action('{!List}').invoke() ) 
            										  : ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }
}