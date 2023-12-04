/**
* @ClassName    : SL_MilestoneHandler
* @JIRATicket   : LIGHTNI-1726
* @CreatedOn    : 11th Nov 2019
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : Poonam Dalvi
* @Description  : Handler Class for SL_diagnosticsMilestoneTimeCalculator calls for SLA calculation on Case record.
*/
public class SL_MilestoneHandler 
{
    /***********
    * Method name  : calculateDiagnosticsSLA
    * Description  : This method call from SL_diagnosticsMilestoneTimeCalculator to calculate the SLA datetime on Case record.
    * Return Type  : NA
    * Parameters   : Case Id, Milestone Id, Time Calculation from SL_diagnosticsMilestoneTimeCalculator.
    ***********/
    public static void calculateDiagnosticsSLA(String caseId, String milestoneTypeId, Integer timeRemaining )
    {
        MilestoneType mt = [SELECT Id, Name FROM MilestoneType WHERE Id=:milestoneTypeId];
        
        DateTime dtValue = DateTime.Now().addMinutes(timeRemaining);
        Case objCase = new Case();
        
        if(mt != null)
        {
            if(mt.Name == 'Diagnostics L1')
                objCase = new Case(Id = caseId, L1_SLA_Target__c = dtValue, Automation_Last_Executed_On__c = dtValue);
            else if(mt.Name == 'Diagnostics L2')
                objCase = new Case(Id = caseId, L2_SLA_Target__c = dtValue, Automation_Last_Executed_On__c = dtValue);
            else if(mt.Name == 'Diagnostics L3')
                objCase = new Case(Id = caseId, L3_SLA_Target__c = dtValue, Automation_Last_Executed_On__c = dtValue);
            else if(mt.Name == 'Diagnostics Case')
                objCase = new Case(Id = caseId, Overall_SLA_Target__c = dtValue, Automation_Last_Executed_On__c = dtValue);
            
            update objCase;
        }
    }
    
}