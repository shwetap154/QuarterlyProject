/****************************************************************************************************************************************** 
 * Trigger Name   : ZTS_US_TerritoryConsoleController
 * Description  : This class contain operations for TerritoryManagement automation activites.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 23 April 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   04/23/2014           Created
*****************************************************************************************************************************************/
public with sharing class ZTS_US_TerritoryConsoleController {
        
        public String INSTANCE_SERVER_URL{get{return URL.getSalesforceBaseUrl().toExternalForm();}}
        /** total user territory count **/
        public Integer totalUsrTerrCount{get{
         if(totalUsrTerrCount==null){
                totalUsrTerrCount=[SELECT COUNT() FROM ZTS_EU_Position__c WHERE ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c!='' AND ZTS_EU_Employee__c!='' AND Market__c = 'United States'];
         }
         return totalUsrTerrCount;
        } private set;
        
        }
        
        /** total unassigned user territory count **/
        public Integer totalUnassignedUsrTerrCount{get{
         if(totalUnassignedUsrTerrCount==null){
                totalUnassignedUsrTerrCount= getUnAssignedUserTerritoryResults().size();
         }
         return totalUnassignedUsrTerrCount;
        } private set;
        
        }
        
        
        /** total Territory2 count **/
        public Integer totalTerrCount{get{
         if(totalTerrCount==null){
                totalTerrCount= [SELECT COUNT() FROM ZTS_EU_Territory__c WHERE ZTS_EU_Market__c = 'United States'];
          }
          return totalTerrCount;
         }private set;
        }
        
        /** Unassigned/unsynched territory count **/
        public Integer unAssignedTerrCount{get{
         if(this.unAssignedTerrCount==null){
		 	//unAssignedTerrCount=[SELECT COUNT() FROM ZTS_EU_Territory__c WHERE ZTS_EU_Terr_SFID__c='' AND ZTS_EU_Territory_synced__c=false AND ZTS_EU_Market__c = 'United States'];
		    unAssignedTerrCount=[SELECT COUNT() FROM ZTS_EU_Territory__c WHERE   ZTS_EU_Territory_synced__c=false AND ZTS_EU_Market__c = 'United States'];
          }
          return unAssignedTerrCount;
         }private set;
        }
        

        /***********  
        * Method name  : getUnAssignedUserTerritoryResults
        * Description  : This method returns details of to unassigned UserTerritory custom object records in comparison to Std. UserTerritory.
        * Return Type  : Unassigned UserTerr list.
        * Parameters   : None.
    ***********/
        public static List<ZTS_EU_Position__c> getUnAssignedUserTerritoryResults(){
          List<ZTS_EU_Position__c> unAssignedUserTerrList=new List<ZTS_EU_Position__c>();
          //******* FILTER BY SYNCED TERRITORIES *********
          List<ZTS_EU_Position__c>custUsrTerrList=[SELECT Id, ZTS_EU_Employee__c, ZTS_EU_Territory__c,ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c FROM ZTS_EU_Position__c WHERE ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c!='' AND ZTS_EU_Employee__c!='' AND Market__c = 'United States'];
          
          List<Id> stdTerrIds=new List<Id>();
          Set<Id> custUsrTerrIds=new Set<Id>();
          
          
          for(ZTS_EU_Position__c custUsrTerr:custUsrTerrList){
                  custUsrTerrIds.add(custUsrTerr.ZTS_EU_Territory__c);
                  stdTerrIds.add(custUsrTerr.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c);
          }
          
          Map<Id,Territory2> stdTerrMap=new Map<Id,Territory2>([SELECT Id , ZTS_Terr_SFID__c FROM Territory2 WHERE Id IN :stdTerrIds]);
          //CHECK FOR ROWS FETCHED
          List<UserTerritory2Association> stdUsrTerrList=[SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN :stdTerrIds];
          Set<String> stdUsrTerrUniqKeySet=new Set<String>();
          for(UserTerritory2Association usrTerr:stdUsrTerrList){
                  stdUsrTerrUniqKeySet.add(usrTerr.UserId+':'+stdTerrMap.get(usrTerr.Territory2Id).ZTS_Terr_SFID__c);
                  
          }
          
          
          for(ZTS_EU_Position__c custUsrTerr:custUsrTerrList){
                  String usrTerrUniqKey=custUsrTerr.ZTS_EU_Employee__c+':'+custUsrTerr.ZTS_EU_Territory__c;
                  System.debug('usrTerrUniqKey : '+usrTerrUniqKey+'\n');
                  if(!stdUsrTerrUniqKeySet.contains(usrTerrUniqKey)){
                          unAssignedUserTerrList.add(custUsrTerr);
                  }
          }
          return unAssignedUserTerrList;
                        
        }
        
    /***********  
        * Method name  : refresh
        * Description  : This  method clears territory and user territory count varaibles.
        * Return Type  : None.
        * Parameters   : None.
    ***********/
        public void refresh(){
                totalTerrCount=null;
                unAssignedTerrCount=null;
                totalUnassignedUsrTerrCount=null;
                totalUsrTerrCount=null;
        }
        
        /***********  
        * Method name  : addUserToTerritory
        * Description  : This remote action method creates standard UserTerritory records from custom object.
        * Return Type  : Batch Info list.
        * Parameters   : None.
    ***********/
    @RemoteAction
        public static List<JobUtilities.BatchInfo> addUserToTerritory(){
          //send unassigned userterritory to territory managed to add them to userterritory 
          JobUtilities job_util=USZTS_TerritoryManager.insertUserTerritoryBatch(getUnAssignedUserTerritoryResults());
          List<JobUtilities.BatchInfo> batch;
          //no payload
          if(job_util.job==null){
                JobUtilities.BatchInfo binfo=new JobUtilities.BatchInfo();
                binfo.jobId='';
                binfo.batchInfoMap.put('jobId','');
                batch = new  List<JobUtilities.BatchInfo>{};
                batch.add(binfo);
          }
          else{
          batch=job_util.batchInfos;
          for(JobUtilities.BatchInfo binfo:batch){
          JobUtilities.createBatchInfoEntry(binfo.jobId,binfo.id);
                }
          }
          return batch;
        }
        
        
        /***********  
        * Method name  : checkStatus
        * Description  : This remote action method checks the batch status.
        * Return Type  : BatchInfo details.
        * Parameters   : String batchId.
    ***********/
    @RemoteAction
        public static JobUtilities.BatchInfo checkStatus(String jobId,String batchId){
          //send unassigned userterritory to territory managed to add them to userterritory 
          JobUtilities job_util=new JobUtilities();
          job_util.job=new JobUtilities.JobInfo(jobId);
          job_util.sessionId=Userinfo.getSessionId();
          return job_util.checkBatchStatus(batchId, new JobUtilities.BulkConnection());
        }
        
        
        /***********  
        * Method name  : closeJob
        * Description  : This remote action method close Job status.
        * Return Type  : BatchInfo details.
        * Parameters   : String batchId.
    ***********/
    @RemoteAction
        public static JobUtilities.JobInfo closeJob(String jobId){
          //send unassigned userterritory to territory managed to add them to userterritory 
          JobUtilities job_util=new JobUtilities();
          job_util.job=new JobUtilities.JobInfo(jobId);
          job_util.sessionId=Userinfo.getSessionId();
          //job_util.checkBatchStatus(batchId, new JobUtilities.BulkConnection());
          job_util.closeJob(jobId, new JobUtilities.BulkConnection());
          return job_util.job;
        }
        
   /***********  
        * Method name  : createStdTerrFromCustomTerritory
        * Description  : This method creates standard territory from custom territory.
        * Return Type  : None.
        * Parameters   : None.
    ***********/
     public PageReference createStdTerrFromCustomTerritory(){
      // List<ZTS_EU_Territory__c> unassignedTerrList=[SELECT Id, Name FROM ZTS_EU_Territory__c WHERE ZTS_EU_Terr_SFID__c='' AND ZTS_EU_Territory_synced__c=false AND ZTS_EU_Market__c = 'United States'];
         List<ZTS_EU_Territory__c> unassignedTerrList=[SELECT Id, Name FROM ZTS_EU_Territory__c WHERE  ZTS_EU_Territory_synced__c=false AND ZTS_EU_Market__c = 'United States'];
	      if(!unassignedTerrList.isEmpty()){
	        List<Id> unassignedTerrIds=new List<Id>();
	        for(ZTS_EU_Territory__c terr:unassignedTerrList){
	                unassignedTerrIds.add(terr.id);
	        }
	        USZTS_TerritoryManager.SFA terrSFA=new USZTS_TerritoryManager.SFA ();
	        try{
	        List<Territory2> stdTerrrList= terrSFA.upsertZoetisTerritory(unassignedTerrIds);
	        List<Id> custTerrIdsToUpdate=new List<Id>();


	        if(stdTerrrList!=null && !stdTerrrList.isEmpty())
          {
              for(Territory2 terr:stdTerrrList)
              {
                  if(terr.id!=null && terr.ZTS_Terr_SFID__c!=null){
                          custTerrIdsToUpdate.add(terr.ZTS_Terr_SFID__c);
                  }
              }
	        }
	        
            if(!custTerrIdsToUpdate.isempty()){
           //TODO use custom labels for error msg.
             ZTS_EU_Logger.addPageMessage(ApexPages.Severity.INFO, 'Territory Record Synced successfully  : '+custTerrIdsToUpdate.size());
             }
             else{
                     ZTS_EU_Logger.addPageMessage(ApexPages.Severity.WARNING, 'No Territory records Synced , check error logs for more details.');
             }
	        }
	        catch(DMLException ex){
	                String msg='';
	                 for (Integer i = 0; i < ex.getNumDml(); i++) {
	                        // Process exception here
	                        msg=ex.getDmlMessage(i); 
	                 }
	                 ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, msg);
	        }
	      }
	      return null;
   }
   
    /***********  
        * Method name  : updateCustomTerrAssignedStatus
        * Description  : This method updates CustomTerritory Assigned Status Flag after Std Territory is created.
        * Return Type  : None.
        * Parameters   : None.
    ***********/
     public PageReference updateCustomTerrAssignedStatus(){
                
                try{
                        List<ZTS_EU_Territory__c> cterrList=USZTS_TerritoryManager.updateCustomTerrAssignedFlag();
                //update cterrToUpdate;
                 refresh();
                 //TODO use custom labels for error msg.
                 String pg_msg=cterrList.isEmpty()?'No CustomTerritory Records updated.':'Total CustomTerritory Record successfully updated '+cterrList.size();
                 ZTS_EU_Logger.addPageMessage(ApexPages.Severity.INFO, pg_msg);
        
                }
                
                catch(DMLException ex){
                String msg='';
                 for (Integer i = 0; i < ex.getNumDml(); i++) {
                        // Process exception here
                        msg=ex.getDmlMessage(i); 
                 }
                 ZTS_EU_Logger.addPageMessage(ApexPages.Severity.ERROR, msg);
          }
        
      
      return null;
   }
        
}