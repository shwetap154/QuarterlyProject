/****************************************************************************************************************************************** 
     * Trigger Name : ZTS_EU_TerritoryManager
     * Description  : This class contain operations for Account Territory Management .
     *                
     *      
     * Created By   : Deloitte Consulting/ Sunil
     * Created Date : 17 April 20114.
     *
     * Modification Log:  
     * ---------------------------------------------------------------------------------------------------------------------------------------
     * Developer                Date               Description 
     * ---------------------------------------------------------------------------------------------------------------------------------------
     * Sunil                   04/17/2014           Created 
     * Shreyas                 24th-Mar-15          Added the method 'updateAssignmentRuleBatch'    
    *****************************************************************************************************************************************/
    global with sharing class ZTS_EU_TerritoryManager {
         /***********  
            * Method name  : insertUserTerritoryBatch
            * Description  : This method add UserTerritories records for Batch insert.
            * Return Type  : None.
            * Parameters   : UserTerritory custom object list.
            ***********/
            /*
            public static JobUtilities insertUserTerritoryBatch(List<ZTS_EU_Position__c> userTerrList){
                JobUtilities.JobInfo job=new JobUtilities.JobInfo('UserTerritory',JobUtilities.OPERATION.insert_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
                JobUtilities job_utl=new JobUtilities();
                job_utl.sessionId=UserInfo.getSessionId();
                String payload=getUserTerritoryCSV_ToInsert(userTerrList);
                System.debug('Payload : '+payload);
                    if(String.isBlank(payload)){
                        return job_utl;
                    }
                
                    String jobId=job_utl.createJob(job,new JobUtilities.BulkConnection());
                    if(String.isBlank(jobId)){
                        throw new ZTS_EU_ZoetisException('Job creation failed (Terriotry Manager - insertUserTerritoryBatch) , see error log for more information');
                    }
                    
                    String batchId=job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);
                    
                    return job_utl;
                }*/
                 /***********  
            * Method name  : getUserTerritoryCSV_ToInsert
            * Description  : This method prepares  UserTerritory  CSV data for insertion.
            * Return Type  : String - CSV Std.UserTerritory DATA.
            * Parameters   : Custom UserTerritory  - list.
            ***********/
          /*public static String getUserTerritoryCSV_ToInsert(List<ZTS_EU_Position__c> userTerrList){
            //prepare UserTerritory rules data
            String HEADER='"TerritoryId","UserId"\n';
            String ROWS='';
            for(ZTS_EU_Position__c userTerr:userTerrList){
                if(!String.isBlank(userTerr.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c)){
                String LINE=userTerr.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c+','+userTerr.ZTS_EU_Employee__c+'\n';
                    ROWS+=line;
                }
            }
            
           
            return String.isBlank(ROWS)==false?HEADER+ROWS:'';
         }
         */
         /***********  
        * Method name  : getAccountAssignmentRuleCSV_ToInsert
        * Description  : This method prepares AccountTerritoryAssignment Rules CSV data for insertion.
        * Return Type  : String -AccountTerritoryAssignment Rules CSV DATA.
        * Parameters   : Std Territory ID - list.
        ***********/
       /*public static String getAccountAssignmentRuleCSV_ToInsert(List<Territory> terrList){
        
            //create accountassignment rules data
            String HEADER='"Name","IsInherited","IsActive","TerritoryId"\n';
            String ROWS='';
            for(Territory terr:terrList){
                String LINE=terr.name+',FALSE,TRUE,'+terr.Id+'\n';
                    ROWS+=LINE;
                    
            }
            
            return HEADER+ROWS;
       }
       */
        /*********** // added by Shreyas on 24th March. 
        * Method name  : getAccountAssignmentRuleCSV_ToUpdate
        * Description  : This method prepares AccountTerritoryAssignment Rules CSV data for update.
        * Return Type  : String -AccountTerritoryAssignment Rules CSV DATA.
        * Parameters   : Std Territory ID - list.
        ***********/
       /*public static String getAccountAssignmentRuleCSV_ToUpdate(List<AccountTerritoryAssignmentRule> terrRuleList){
        
            //update accountassignment rules data
            String HEADER='"Id","BooleanFilter"\n';
            String ROWS='';
            for(AccountTerritoryAssignmentRule rule: terrRuleList){
                String LINE=rule.Id + ',1 OR 2 OR 3' +'\n';
                    ROWS+=LINE;
            }
            
            return HEADER+ROWS;
       }
        */
        /***********  
        * Method name  : getSFID_ToDelete
        * Description  : This method prepares  SObject ID  CSV data for deletion.
        * Return Type  : String - CSV Std.UserTerritory DATA.
        * Parameters   : SObjects list.
        ***********/
      /*public static String getSFID_ToDelete(List<SObject> SObjectList){
        String HEADER='"Id"\n';
        String ROWS='';
            for(Sobject sobj:SObjectList){
                String LINE=sobj.get('Id')+'\n';
                    ROWS+=line;
            }
        
       
        return String.isBlank(ROWS)==false?HEADER+ROWS:'';
     }
       */ 
       /***********  
        * Method name  : getAccountAssignmentRuleItemsCSV_ToInsert
        * Description  : This method  prepares AccountTerritoryAssignment RuleItems CSV data for insertion.
        * Return Type  : String - CSV AccountTerritoryAssignment RuleItems DATA.
        * Parameters   : AccountTerritoryAssignmentRules list & Std. Territory Map.
        ***********/       
        /*public static String getAccountAssignmentRuleItemsCSV_ToInsert(List<AccountTerritoryAssignmentRule> rules,Map<Id,Territory> terrMap){
            //create accountassignment rules data - default sort order - 0
            String HEADER='"RuleId","Field","Operation","Value","SortOrder"\n';
            String ROWS='';
            for(AccountTerritoryAssignmentRule rule:rules){
                String LINE=rule.Id+',Account.ZTS_EU_TSF_PBC_1__c,contains,'+terrMap.get(rule.TerritoryId).Name+',0\n';
                LINE=LINE+rule.Id+',Account.ZTS_EU_TSF_PBC_2__c,contains,'+terrMap.get(rule.TerritoryId).Name+',1\n';
                LINE=LINE+rule.Id+',Account.ZTS_EU_TSF_PBC_3__c,contains,'+terrMap.get(rule.TerritoryId).Name+',2\n';
                    ROWS+=LINE;
            }
            system.debug('Headers********'+ HEADER+ROWS);
            return HEADER+ROWS;
        }
        public static JobUtilities insertAssignmentRuleBatch(List<Territory> terrList){
            JobUtilities.JobInfo job=new JobUtilities.JobInfo('AccountTerritoryAssignmentRule',JobUtilities.OPERATION.insert_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
            JobUtilities job_utl=new JobUtilities();
            job_utl.sessionId=UserInfo.getSessionId();
            String payload=getAccountAssignmentRuleCSV_ToInsert(terrList);
            String jobId=job_utl.createJob(job,new JobUtilities.BulkConnection());
            if(String.isBlank(jobId)){
                throw new ZTS_EU_ZoetisException('Job creation failed (Terriotry Manager - insertUserTerritoryBatch) , see error log for more information');
            }
            String batchId=job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);    
            return job_utl;
        }
        
        // added by Shreyas on 24th March. 
        public static JobUtilities updateAssignmentRuleBatch(List<AccountTerritoryAssignmentRule> terrRuleList){
            JobUtilities.JobInfo job=new JobUtilities.JobInfo('AccountTerritoryAssignmentRule',JobUtilities.OPERATION.update_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
            JobUtilities job_utl=new JobUtilities();
            job_utl.sessionId=UserInfo.getSessionId();
            String payload=getAccountAssignmentRuleCSV_ToUpdate(terrRuleList);
            String jobId=job_utl.createJob(job,new JobUtilities.BulkConnection());
            if(String.isBlank(jobId)){
                throw new ZTS_EU_ZoetisException('Job creation failed (Terriotry Manager - updateUserTerritoryBatch) , see error log for more information');
            }
            String batchId=job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);    
            return job_utl;
        }
        
        public static JobUtilities insertAssignmentRuleItemBatch(List<AccountTerritoryAssignmentRule> rulesList ,Map<Id,Territory> terrMap){
            JobUtilities.JobInfo job=new JobUtilities.JobInfo('AccountTerritoryAssignmentRuleItem',JobUtilities.OPERATION.insert_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
            JobUtilities job_utl=new JobUtilities();
            job_utl.sessionId=UserInfo.getSessionId();
            String payload=getAccountAssignmentRuleItemsCSV_ToInsert(rulesList,terrMap);
            String jobId=job_utl.createJob(job,new JobUtilities.BulkConnection());
            if(String.isBlank(jobId)){
                throw new ZTS_EU_ZoetisException('Job creation failed (Terriotry Manager - insertUserTerritoryBatch) , see error log for more information');
            }
            String batchId=job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);    
            return job_utl;
        }
        */
              
    /***********  
        * Method name  : updatedUserTerrHistoryRecords
        * Description  : This method retrieves updated updated Custom object UserTerritory history records to be removes from changes made to User lookup field in custom UserTerritory records for specified date range.
        * Return Type  : Custom UserTerritory History records.
        * Parameters   : Date - toDate & fromDt.
        ***********/
    
         /*public static List<ZTS_EU_Position__History> updatedUserTerrHistoryRecords(Date fromDate,Date toDate){
            if(fromDate > toDate){
                //TODO use custom labels
                throw new ZTS_EU_ZoetisException('Invalid arguments fromDate cannot be greater than toDate : '+fromDate + ' > '+toDate);
            }
        
            Integer DAYS_DIFF=fromDate.daysBetween(toDate);
            String usr_lookup_field=GlobalVariablesService.USER_LOOKUP_FIELD;
            String qry='SELECT ParentId, OldValue, NewValue, Field, CreatedDate, IsDeleted FROM ZTS_EU_Position__History WHERE '+
                                                                     ' CreatedDate=LAST_N_DAYS:'+DAYS_DIFF +'AND Field=:usr_lookup_field';
            return Database.query(qry);
        
         }
   */
       /***********  
        * Method name  : updatedUserTerrUserRecordsToRemove
        * Description  : This method retrieves updated UserTerritory to be removes from changes made to User lookup field in custom UserTerritory records for specified date range.
        * Return Type  : None.
        * Parameters   : Updated Custom UserTerritory history records received from updatedUserTerrHistoryRecords method date range.
        ***********/
       /*public static List<UserTerritory> updatedUserTerrUserRecordsToRemove(List<ZTS_EU_Position__History> ut_histList){
             // updatedUserTerrHistoryRecords
             Set<Id> custUsrTerrIds=new Set<Id>();
             Set<Id> custTerrIds=new Set<Id>();
             Set<String> existingUsrTerrKeys=new Set<String>();
             List<ZTS_EU_Position__History> ut_updatedUsr_histList=new List<ZTS_EU_Position__History>();

             //filter results
             for(ZTS_EU_Position__History uth:ut_histList){
                if(uth.OldValue!=null && uth.OldValue!='' && uth.OldValue!=uth.NewValue && String.valueOf(uth.OldValue).startsWith(GlobalVariablesService.USER_KEYCODE) && String.valueOf(uth.OldValue).length()==18 ){
                        custUsrTerrIds.add(uth.parentId);
                        ut_updatedUsr_histList.add(uth);
                    
                }
             }
            //get Territory information from updated user territories
            Map<Id,ZTS_EU_Position__c> custUsrTerrMap=new Map<Id,ZTS_EU_Position__c>([SELECT Id,ZTS_EU_Employee__c,ZTS_EU_Territory__c FROM ZTS_EU_Position__c WHERE Id IN :custUsrTerrIds ]);
            for(ZTS_EU_Position__c custUsrTerr:custUsrTerrMap.values()){
                if(custUsrTerr.ZTS_EU_Employee__c!=null){
                    existingUsrTerrKeys.add(custUsrTerr.ZTS_EU_Territory__c+':'+custUsrTerr.ZTS_EU_Employee__c);
                }
                custTerrIds.add(custUsrTerr.ZTS_EU_Territory__c);
            }
            //get territory info from history parent ids
            Map<Id,ZTS_EU_Territory__c> custTerrMap=new Map<Id,ZTS_EU_Territory__c>([SELECT Id,Name,ZTS_EU_Terr_SFID__c, ZTS_EU_Territory_synced__c FROM ZTS_EU_Territory__c WHERE Id IN :custTerrIds AND ZTS_EU_Terr_SFID__c!='' AND ZTS_EU_Territory_synced__c=TRUE AND ZTS_EU_Market__c != 'United States']);
             List<String> terrIdList=new List<Id>();
             List<String> usrIdList=new List<Id>();
            //check if they have associated std. territory id
           //combo key Territory and UserId to be deleted
            Set<String> stdUserTerrCombKeyToDel=new Set<String>();
                for(ZTS_EU_Position__History uth:ut_updatedUsr_histList){
                     if(custUsrTerrMap.containsKey(uth.parentId)){
                        String stdTerrId=custTerrMap.get(custUsrTerrMap.get(uth.parentId).ZTS_EU_Territory__c).ZTS_EU_Terr_SFID__c;
                        String usrId=String.valueOf(uth.OldValue);
                        String usrTerrKey=custUsrTerrMap.get(uth.parentId).ZTS_EU_Territory__c+':'+uth.OldValue;
                        //Exclude any rolled backed changes
                        if(!existingUsrTerrKeys.contains(usrTerrKey) && !(stdUserTerrCombKeyToDel.contains(stdTerrId+':'+usrId))){
                            terrIdList.add(stdTerrId);
                            usrIdList.add(usrId);
                            stdUserTerrCombKeyToDel.add(stdTerrId+':'+usrId);
                        }
                  }
        
                }
            //get Std.Userterritory list of records
            List<UserTerritory> userTerrList=[SELECT Id,TerritoryId, UserId FROM UserTerritory WHERE TerritoryId IN :terrIdList];
            List<UserTerritory> userTerrToDelete=new List<UserTerritory>();
            for(UserTerritory usrTerr:userTerrList){
                String usrTerrKey=usrTerr.TerritoryId+':'+usrTerr.UserId;
             //check to exclude same user changed in other territory 
                if(stdUserTerrCombKeyToDel.contains(usrTerrKey)){
                    userTerrToDelete.add(usrTerr);
                }
            }
             return userTerrToDelete;            
      }
    
    
    */
    
       /***********  
        * Method name  : removeUserTerritory
        * Description  : This method removes standard UserTerritory records.
        * Return Type  : None.
        * Parameters   : custom UserTerritory list.
        ***********/
      /* public static JobUtilities  removeUserTerritory(List<UserTerritory> userTerrList,String sessionId){
        
        JobUtilities.JobInfo job=new JobUtilities.JobInfo('UserTerritory',JobUtilities.OPERATION.delete_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
            JobUtilities job_utl=new JobUtilities();
            job_utl.sessionId=sessionId;
            String payload=getSFID_ToDelete(userTerrList);
            System.debug('Payload : '+payload);
                if(String.isBlank(payload)){
                    return job_utl;
                }
            
                String jobId=job_utl.createJob(job,new JobUtilities.BulkConnection());
                if(String.isBlank(jobId)){
                    throw new ZTS_EU_ZoetisException('Job creation failed (Territory Manager - removeUserTerritory) , see error log for more information');
                }
                
                String batchId=job_utl.createBatch(job_utl.job, new JobUtilities.BulkConnection(), payload);
               // set details in BatchInfo CS
               //JobUtilities.createBatchInfoEntry(jobId,batchId);
                
                return job_utl;
         }
   */
      /***********  
        * Method name  : removeUserTerritoryAsync
        * Description  : This future method removes standard UserTerritory records.
        * Return Type  : None.
        * Parameters   : custom UserTerritory list.
        ***********/
      /*@future(callout=true)
       public static void  removeUserTerritoryAsync(List<String> stduserTerrIds,String sessionId){
        List<UserTerritory> utlist=new List<UserTerritory>();
        for(String utId:stduserTerrIds){
            utlist.add(new UserTerritory(Id=utId));
        }
        removeUserTerritory(utlist,sessionId);
        
       }
    */
     }