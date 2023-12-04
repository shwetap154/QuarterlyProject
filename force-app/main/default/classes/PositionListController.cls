/****************************************************************************************************************************************** 
 * CLass Name : PositionListController
 * Description  : Controller for new buttons (that used to be JS) on ZTS_EU_Position object
 * Created By   : Slalom(David Stern) 
 * Created Date : 4th June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern            06/04/2020          Created 
*****************************************************************************************************************************************/
public class PositionListController 
{
    private ApexPages.StandardController standardController;
    public Id recordId;

    public PositionListController(ApexPages.StandardController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        recordId = standardController.getRecord().Id;
    }
}