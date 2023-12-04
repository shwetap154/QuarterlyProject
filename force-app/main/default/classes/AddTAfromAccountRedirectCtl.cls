/****************************************************************************************************************************************** 
 * Class Name       : AddTAfromAccountRedirectCtl
 * Description      : controller for "AddTAfromAccountRedirect.vfp" (SC-008159)                                 
 * Created By   : Cognizant
 * Created Date : March 5th, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        03/05/2021          Created 
*****************************************************************************************************************************************/

public class AddTAfromAccountRedirectCtl {
    private ApexPages.StandardController standardController;
    public Id recordId;
      public AddTAfromAccountRedirectCtl(ApexPages.StandardController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        recordId = standardController.getRecord().Id;
        
    }
    
    public AddTAfromAccountRedirectCtl(ApexPages.StandardSetController standardSetController)
    {
        //Getting list of ids from records selected in the list view 
        recordId = ApexPages.CurrentPage().GetParameters().get('id');     
    }
    
    public PageReference doredirect()
    {
        PageReference pg = new PageReference('/apex/ZTS_EU_TargetedAccountfromAccount?accId=' + recordId);
        return pg.setRedirect(true);
    }
   

}