/****************************************************************************************************************************************** 
 * CLass Name : CallAssignExistingCallsController
 * Description  : Controller for new button (that used to be JS) on Call_c object
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 11th May, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           05/11/2020          Created 
*****************************************************************************************************************************************/
public with sharing class CallAssignExistingCallsController {

    private ApexPages.StandardSetController standardController;
    public String coachingGuidId;

    public CallAssignExistingCallsController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference doRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        coachingGuidId = theUrl.substring(n+3, n+21);

        try {
            pageReference pg = new pageReference('/apex/PIT_MassAssignCalls?id='+coachingGuidId);
            return pg.setRedirect(true);
        }

        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
}