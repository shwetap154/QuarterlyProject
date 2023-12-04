/*********************************************************************************************************************
 * Class Name   : ZTS_EU_AccSegThresholdListCont
 * Description  : Controller class for Account_Segmentation_threshold__c buttons with StandardController  
 * Created By   : Slalom/Art Smorodin
 * Created Date : 9 June 2020
 *
 * Modification Log:
 * -------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * -------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     06/09/2020          Created.
 *********************************************************************************************************************/
public with sharing class ZTS_EU_AccSegThresholdListCont {

    private ApexPages.StandardSetController standardController;
    public List<Account_Segmentation_threshold__c> selContractList;
    public String retURL;
    // public String listId;
    // public String formatedURL;


    public ZTS_EU_AccSegThresholdListCont(ApexPages.StandardSetController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        selContractList = standardController.getSelected();
        retURL  = ApexPages.CurrentPage().getparameters().get('vfRetURLInSFX');
        // System.debug(retURL);
        // listId = retURL.substring(retURL.indexOf('=')+1, retURL.length());
        // String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        // Integer endUrlInd = baseUrl.indexOf('--c');
        // formatedURL = baseUrl.substring(0, endUrlInd);

    }

    public PageReference doRecalculate()
    {   
        
        PageReference redirectedPage = new PageReference(retURL);
        redirectedPage.setRedirect(true);

        try {
            ZTS_EU_AccountSegBatchUpdateWebservice.UpdateBatch();
            return redirectedPage;
        } catch (Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return redirectedPage;
        }

    }
}