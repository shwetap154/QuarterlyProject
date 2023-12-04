/****************************************************************************************************************************************** 
* CLass Name : PITStompButtonController
* Description  : Controller for new buttons (that used to be JS) on PIT_STOMP__c object
* Created By   : Slalom(David Stern) 
* Created Date : 5th June, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern            06/05/2020          Created 
*****************************************************************************************************************************************/
public class PITStompButtonController 
{
    private ApexPages.StandardController standardController;
    public Id recordId;
    public PIT_Stomp__c record;
    public String response {get; set;}
    public Boolean failTest = false;
    
    public PITStompButtonController(ApexPages.StandardController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        recordId = standardController.getRecord().Id;
        record = [
            SELECT Id, Follow_Up_Notes__c, Date_Follow_Up_Completed__c, Outcome__c,
                   PIT_Status__c
            FROM PIT_Stomp__c
            WHERE Id = :recordId
        ];
    }
    
    public void doCompleteFollowUp()
    {
        try
        {
            if (Test.isRunningTest() && failTest)
            {
                throw new TestPITStompButtonController.MyException();
            }
            
            String followUpNotes = record.Follow_Up_Notes__c;
            Date dateCompleted = record.Date_Follow_Up_Completed__c;
            String outcome = record.Outcome__c;
            String status = record.PIT_Status__c;
            response = '';

            if(status == 'Approved')
            {
                if((followUpNotes == null) || (dateCompleted == null) || (outcome == null))
                {
                    if (followUpNotes == null) response += 'Please enter Follow Up Notes.\\n';
                    if (dateCompleted == null) response += 'Please select a value for Date Follow Up Completed.\\n';
                    if (outcome == null) response += 'Please select an Outcome.\\n';   
                }
                else
                {                  
                    record.PIT_Status__c = 'Follow Up Completed';
                    update record;
                    response += 'STOMP successfully updated.';
                }
            }
            else
            {
                if(status == 'Follow Up Completed')
                {
                    response += 'STOMP is already in Follow Up Completed state. Thank You!';
                }
                else
                {
                    response += 'STOMP Status is: ' + status + '.  STOMP must have Approved status to be updated to Follow Up Completed. Thank You!';
                }
            }
        }
        catch(Exception e)
        {
            response += 'An Error has Occurred. Error: ' + e.getMessage();
        }
    }
     
    public PageReference goBackToPITStomp()
    {
        PageReference pg = new PageReference('/' + recordId);
        return pg.setRedirect(true); 
    }
}