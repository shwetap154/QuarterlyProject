/****************************************************************************************************************************************** 
 * CLass Name : CattleEquineSurveyButtonController
 * Description  : Controller for new buttons (that used to be JS) on Cattle_Equine_Survey__c object
 * Created By   : Slalom(David Stern) 
 * Created Date : 8th June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern            06/08/2020          Created 
*****************************************************************************************************************************************/
public class CattleEquineSurveyButtonController 
{
    private ApexPages.StandardController StandardController;
    public String reasonForFailure {get; set;}
    public Id recordId;
    public String market;
    public String redirectURL;
    public Boolean failTest = false;

    public CattleEquineSurveyButtonController(ApexPages.StandardController StandardController)
    {
        this.StandardController = StandardController;
        recordId = standardController.getRecord().Id;
    }
    
    public void doUpdateCES()
    {
        Cattle_Equine_Survey__c CES = [
            SELECT Id, Status__c
            FROM Cattle_Equine_Survey__c
            WHERE Id = :recordId
        ];
        
        try
        {
            if (Test.isRunningTest() && failTest)
            {
                insert new Account();
            }
            CES.Status__c = 'Completed';
            update CES;
        }
        catch (DMLException e)
        {
            reasonForFailure = 'Exception: ' + e.getMessage();
        }  
    }       
        
    public PageReference goBackToRecord()
    { 
        PageReference pg = new PageReference('/' + recordId);
        return pg.setRedirect(true);
    }
}