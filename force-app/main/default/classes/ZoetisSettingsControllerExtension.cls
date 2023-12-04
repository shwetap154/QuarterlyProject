/****************************************************************************************************************************************** 
 * Class Name   : ZoetisSettingsControllerExtension
 * Description  : This class contain operations used to update Zoetis App Custom Settings.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 12 May 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   05/12/2014           Created
 */
public with sharing class ZoetisSettingsControllerExtension
{
    public String strPositionMessage    {   get; set;   }
    public String strPositionMsgType    {   get; set;   }
    
    // public List<TriggerActivation__c> triggerActivationList{get{if(triggerActivationList==null)
    //                                  {triggerActivationList=[SELECT Name, isActive__c, Id FROM TriggerActivation__c ORDER BY Name];}
    //                                                 return  triggerActivationList;                  
  //  }set;}
    /*public ZoetisSettingsControllerExtension(ApexPages.StandardController controller){
        
    }*/
    
    /** Default constructor **/
    public ZoetisSettingsControllerExtension(){}
    
    /** Param  constructor used with TerritoryConsoleController as parameter **/    
      public ZoetisSettingsControllerExtension(ZTS_TerritoryConsoleController controller) {
            tconsoleCtrl=controller;
    }
      public ZoetisSettingsControllerExtension(ZTS_US_TerritoryConsoleController controller) {	
            tconsoleCtrlUS=controller;	
    }
    
    
    /** Org Default custom Setting */
    public ZTS_Settings__c zoetisSettings{get{
        if(zoetisSettings==null)
        {
            zoetisSettings=Test.isRunningTest()?ZTS_Settings__c.getInstance(UserInfo.getUserId()):ZTS_Settings__c.getOrgDefaults();
            }
        return zoetisSettings;
        }
        set;
       }
    
    /***********
    * Method name  : updateSettings
    * Description  : This method updates custom settings values.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void updateSettings()
    {
        strPositionMessage = strPositionMsgType = '';
        try
        {
            if(zoetisSettings.Id == null)
            {
                strPositionMessage = 'No Custom Setting record was found.'; 
                strPositionMsgType = 'Error';
            }
            else 
            {
                update zoetisSettings;
                
                // if(!triggerActivationList.isEmpty())
                //     update triggerActivationList;
                //ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'Changes Updated Successfully.');
                strPositionMessage = 'Changes Updated Successfully.'; 
                strPositionMsgType = 'INFO';
            }
        }
        catch(Exception ex)
        {
            //ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Changes cannot be saved due to '+ex.getMessage());
            strPositionMessage = 'Changes cannot be saved due to '+ex.getMessage(); 
            strPositionMsgType = 'Error';
        }
        
    }

    /** TerritoryConsoleController **/ 
    public ZTS_TerritoryConsoleController tconsoleCtrl{get;set;}
    public ZTS_US_TerritoryConsoleController tconsoleCtrlUS{get;set;}

    public String status{get;set;}
    public String console{get;set;}
    public String log{get;set;}
    public String comment{get;set;}
    public String exceptionStr{get;set;}
    public String log2{get;set;}
    public String comment2{get;set;}
    public String exceptionStr2{get;set;}
    
    
     /***********
    * Method name  : executeCurrentFYCallCreditUpdateBatch
    * Description  : This method executes CurrentFYCallCredit Update Batch.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void executeCurrentFYCallCreditUpdateBatch(){
        try{
        String batchId=ZTS_CurrentFY_CallCreditUpdateBatch.executeBatch();
        ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'Batch initiated successfully , check Apex Job Id : '+batchId +' in Setup -> Monitor -> Jobs -> Apex Jobs for more details.');
        }
        catch(Exception ex){
            ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute CurrentFY CallCredit Update Batch due to error msg : '+ex.getMessage());
        }
        
    }
    
    
     /***********
    * Method name  : executeExceptionAlignFlagUpdateBatch
    * Description  : This method executes associates AccountTerritory to AccountTeams to display exception alignment flag
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void executeExceptionAlignFlagUpdateBatch(){
        try{
        String batchId=ZTS_ExcepAlignFlagUpdateScheduleBatch.executeBatch(2000);

        ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'Batch initiated successfully , check Apex Job Id : '+batchId +' in Setup -> Monitor -> Jobs -> Apex Jobs for more details.');
        }
        catch(Exception ex){
            ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute ExceptionAlignment Update Batch due to error msg : '+ex.getMessage());
        }
        
    }
    
    
   /***********
    * Method name  : executeExceptionAlignFlagUpdateScheduler
    * Description  : This method schedules updates ExceptionAlignFlag in Account teams.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void executeExceptionAlignFlagUpdateScheduler(){
        try{
        String jobid=ZTS_ExcepAlignFlagUpdateScheduleBatch.start();
        ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'ExceptionAlignFlagUpdate scheduled successfully , check Apex Job Id : '+jobid +' in Setup -> Monitor -> Jobs -> Scheduled Jobs for more details.');
        }
        catch(Exception ex){
            ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute ExceptionAlignFlagUpdate Scheduler due to error msg : '+ex.getMessage());
        }
        
    }
    
   /***********
    * Method name  : executeRemoveUserTerrScheduler
    * Description  : This method executes RemoveUserTerritory Update Scheduler.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void executeRemoveUserTerrScheduler(){
        try{
        String jobid=ZTS_UserTerritoryRemoveScheduleBatch.start();
        ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,' Remove UserTerritory scheduled successfully , check Apex Job Id : '+jobid +' in Setup -> Monitor -> Jobs -> Scheduled Jobs for more details.');
        }
        catch(Exception ex){
            ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute Remove User Territory Scheduler due to error msg : '+ex.getMessage());
        }
        
    }
    
   /***********
    * Method name  : closeJobScheduler
    * Description  : This method closes completed bulk jobs.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void closeJobScheduler()
    {
        try
        {
            String jobid=ZTS_JobCloseSchedule.start();
            //ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'CloseJob scheduled successfully , check Apex Job Id : '+jobid +' in Setup -> Monitor -> Jobs -> Scheduled Jobs for more details.');
            strPositionMessage = 'CloseJob scheduled successfully , check Apex Job Id : '+jobid +' in Setup -> Monitor -> Jobs -> Scheduled Jobs for more details.';
            strPositionMsgType = 'INFO';
            
            system.debug('=========strPositionMessage======'+strPositionMessage);
        }
        catch(Exception ex)
        {
            //ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute Clear Closed Jobs Scheduler due to error msg : '+ex.getMessage());
            strPositionMessage = 'Failed to execute Clear Closed Jobs Scheduler due to error msg : '+ex.getMessage();
            strPositionMsgType = 'Error';
        }
        
    }
    
     /***********
    * Method name  : closeJobs
    * Description  : This method closes completed bulk jobs.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void closeJobs()
    {
        strPositionMessage = strPositionMsgType = '';
        try
        {
            ZTS_JobCloseSchedule jcb=new ZTS_JobCloseSchedule(UserInfo.getSessionId());
            jcb.execute(null);
        }
        catch(Exception ex)
        {
            ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute closeJobs due to error msg : '+ex.getMessage());
        }
        
    }
    
    
   /***********
    * Method name  : executeRemoveUserTerrBatch
    * Description  : This method executes RemoveUserTerritory Update Batch.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void executeRemoveUserTerrBatch(){
        try{
        String batchId=ZTS_UserTerritoryRemoveScheduleBatch.run();
        ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'Remove User Territory Batch initiated successfully , check Apex Job Id : '+batchId +' in Setup -> Monitor -> Jobs -> Apex Jobs for more details.');
        }
        catch(Exception ex){
            ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute Remove User Territory Batch due to error msg : '+ex.getMessage());
        }
        
    }
    
    /***********
    * Method name  : userTerrRemoval
    * Description  : This method executes ZTS_RemoveUserTerrBatch  Batch.
    * Return Type  : None.
    * Parameters   : None .
    ***********/
    public void userTerrRemoval()
    {
        try{
            String batchId=Database.executeBatch(new ZTS_RemoveUserTerrBatch(UserInfo.getSessionId()));
            //ZTS_Logger.addPageMessage(ApexPages.Severity.INFO,'Remove User Territory Batch initiated successfully , check Apex Job Id : '+batchId +' in Setup -> Monitor -> Jobs -> Apex Jobs for more details.');
            strPositionMessage = 'Remove User Territory Batch initiated successfully , check Apex Job Id : '+batchId +' in Setup -> Monitor -> Jobs -> Apex Jobs for more details.';
            strPositionMsgType = 'INFO';
        }
        catch(Exception ex)
        {
            //ZTS_Logger.addPageMessage(ApexPages.Severity.Error,'Failed to execute Remove User Territory Batch due to error msg : '+ex.getMessage());
            strPositionMessage = 'Failed to execute Remove User Territory Batch due to error msg : '+ex.getMessage();
            strPositionMsgType = 'Error';
        }
        
    }
        
}