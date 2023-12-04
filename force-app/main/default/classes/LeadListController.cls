/****************************************************************************************************************************************** 
 * CLass Name : LeadListController
 * Description  : Controller for new buttons (that used to be JS) on Lead object
 * Created By   : Slalom(David Stern) 
 * Created Date : 4th June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern            06/04/2020          Created 
*****************************************************************************************************************************************/
public class LeadListController 
{
    private ApexPages.StandardController standardController;
    public Id recordId;
    public String returnValue {get; set;}

    public LeadListController(ApexPages.StandardController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        recordId = standardController.getRecord().Id;
    }
    
    public void switchRecordTypes()
    {
        // No idea why this happens, but assigning it directly to returnValue does not work, but
        // assigning it to temp and then to return Value does. ¯\_(ツ)_/¯
        String temp = NOA_SwitchApplications.convertVetToRepro(recordId);
        returnValue = temp;        
    }
    
    public PageReference goBackToLead()
    {
        PageReference pg = new PageReference('/' + recordId);
        return pg.setRedirect(true); 
    }
}