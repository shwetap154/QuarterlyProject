/**
* @ClassName    : SL_RecalculateRatings 
* @JIRATicket   : LIGTHTNI-48
* @CreatedOn    : 3rd April, 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : Akshay Agrawal (for LIGHTNI-1628)
* @Description  : Controller to execute the batch on click of Recalculate ratings button on the list view of the Account_Segmentation_threshold__c object.
*/
public  with sharing class SL_RecalculateRatings {   
    /***********
      * Method name  : SL_RecalculateRatings
      * Description  : constuctor of the class, which get called on page init.
      * Parameters   : ApexPages.StandardSetController controller
    ***********/ 
    public SL_RecalculateRatings(ApexPages.StandardSetController controller) {
        
    }

    /***********
      * Method name  : onAction
      * Description  : This method will call the controller which executes the batch from the constructor.
      * Return Type  : NA
      * Parameters   : NA
    ***********/ 
    public void onAction() {
      ZTS_EU_AccountSegBatchUpdateWebservice.UpdateBatch();
    }

    /***********
      * Method name  : listView
      * Description  : This method fetch the recently viewed list view Id and redirect the user to that list view.
      * Return Type  : PageReference
      * Parameters   : NA
    ***********/ 
    public PageReference listView() {
        PageReference listViewUrl = Test.isRunningTest() ? ApexPages.currentPage() : new ApexPages.Action('{!List}').invoke();
        listViewUrl.setRedirect(true);
        return listViewUrl;
    }
}