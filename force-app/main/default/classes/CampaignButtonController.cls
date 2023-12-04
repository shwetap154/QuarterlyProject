/****************************************************************************************************************************************** 
 * CLass Name : CampaignButtonController
 * Description  : Controller for new buttons (that used to be JS) on Campaign object
 * Created By   : Slalom(David Stern) 
 * Created Date : 8th June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern            06/08/2020          Created 
*****************************************************************************************************************************************/
public class CampaignButtonController 
{
    private ApexPages.StandardSetController standardSetController;
    public Id recordId;
    public String market;
    public String redirectURL;
    public Boolean failTest = false;

    public CampaignButtonController(ApexPages.StandardSetController standardSetController)
    {
        this.standardSetController = standardSetController;
        recordId = ApexPages.CurrentPage().GetParameters().get('id');     
        
        market = [
            SELECT ZTS_EU_Market__c
            FROM Contact
            WHERE Id = :recordId
            LIMIT 1
        ].ZTS_EU_Market__c;
                
        if (market == 'United States') redirectURL = '/apex/ZTS_US_AddtoCampaignFromCon?conCampId='+recordId;
        else redirectURL = '/apex/ZTS_EU_AddtoCampaignFromCon?conCampId='+recordId;
    }
    
    public PageReference doRedirectToAddCampaignFromContact()
    {
        PageReference pg = new PageReference(redirectURL);
        return pg.setRedirect(true);
    }

}