/**
* @ClassName    : SL_AffiliateNewContactController 
* @JIRATicket   : LIGHTNI-1550
* @CreatedOn    : 28th August 2019.
* @CreatedBy    : Akshay
* @ModifiedBy   : 
* @Description  : Controller to fetch the default data on click ligthning list button.
*/
public class SL_AffiliateNewContactController {
	
    public String defaultValues {get; set;}
    public static final String parentId = ApexPages.currentPage().getParameters().get('id');
    
    public SL_AffiliateNewContactController(ApexPages.StandardSetController controller) { 
    }
    
    /***********
      * Method name  : fetchRecordURL
      * Description  : This method will fetch the default data to populate on the Contact edit record.
      * Return Type  : NA
      * Parameters   : NA.
    ***********/
    public void fetchRecordURL() {
        //added logic to populate the default value for lightning view
        defaultValues = JSON.serialize( SL_ContactManager.getContactDefaultValues( parentId ) );
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