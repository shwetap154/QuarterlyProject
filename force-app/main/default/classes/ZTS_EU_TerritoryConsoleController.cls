/*************************************************************************************
* Name          :    ZTS_EU_TerritoryConsoleController.
* Description   :    Controller for the Territory2 Management.
* Author        :    Deloitte/Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
05/06/2014      Sunil             Created
06/08/2014      Pankaj            Modified
24th-Mar-15     Shreyas           Added the method 'updateAssignmentRules'
15th-Mar-15     Shreyas           Added the method 'getExcludedAssignmentRuleIdList'
**************************************************************************************/
public with sharing class ZTS_EU_TerritoryConsoleController {

    public ZTS_EU_TerritoryConsoleController ()
    {
        
    }
    /****************Added by Pankaj*****************/
   /* public integer totalTerr {get;set;}
    public integer syncedTerr {get;set;}
    public integer unSyncedTerr {get;set;}
    public boolean showMsg {get;set;}
    public boolean RemoveUsershowMsg{get;set;}
    public string marketType{get;set;}
    
    public integer failedAccountCount {get;set;}
    public integer successAccountCount{get;set;}
    */
    
    //Build a picklist of for market
    /* public List<selectOption> MarketList{
        get{
            if(MarketList == null){
    
                MarketList= new  List<SelectOption>();
               // MarketList.add(new SelectOption('All','All')); //Shefali 11/21/2014 for changes same for both the batches(Full Alignment.ZipAlignment)
                List<Schema.PicklistEntry> ple = Account.fields.ZTS_EU_Market__c.getDescribe().getpicklistvalues();
                for(Schema.PicklistEntry p : ple){
                    MarketList.add(new SelectOption(p.getValue(), p.getLabel()));  
                }
        }  
        return MarketList; 
        } set;     
    }*/
    
    /***********  
            * Method name  : terrCount
            * Description  : This method display the total count od synced and un-synced Territory2.
            * Return Type  : None.
            * Parameters   : None.
     ***********/
   /* public void terrCount(){
        syncedTerr     = [select count() from ZTS_EU_Territory__c where ZTS_EU_Territory_synced__c = true AND ZTS_EU_Market__c != 'United States' ];
        unSyncedTerr   = [select count() from ZTS_EU_Territory__c where ZTS_EU_Territory_synced__c = false AND ZTS_EU_Market__c != 'United States'];   
        totalTerr      = [select count() from ZTS_EU_Territory__c AND ZTS_EU_Market__c != 'United States'];
        showMsg = false;
        RemoveUsershowMsg = false;
    }*/
    
     /***********  
            * Method name  : createTerr
            * Description  : This method create a standrad Territory2.
            * Return Type  : PageReference.
            * Parameters   : None.
     ***********/
    
   /* public PageReference createTerr(){ 
        List<Territory2> finalUpdateStdTerrlist = new List<Territory2>(); 
        list<ZTS_EU_Territory__c> custTerrList = new list<ZTS_EU_Territory__c>();
        Map<string,string> custTerrMap = new Map<string,string>();
        
        map<string,string> stdTerrMap = new map<string,string>();
        map<string,string> stdTerrMapID = new map<string,string>();
        list<string> custTerrName = new list<string>();
        list<Territory2> stdTerrList = new list<Territory2>();        
        list<ZTS_EU_Territory__c> finalUpdateCustTerrlist = new list<ZTS_EU_Territory__c>();
        
       //Map of Standard Territory2
       stdTerrlist = [select id,name, Zoetis_Territory_ID_Map__c from Territory2 limit 50000];
       for(Territory2 t : stdTerrlist){
         stdTerrMap.put(t.name, t.Zoetis_Territory_ID_Map__c);
         stdTerrMapID.put(t.name, t.id);
       }      
       //Map,List of Custom Territory2
       custTerrList = [select id,name,ZTS_EU_Parent_Territory__r.name,ZTS_EU_Terr_SFID__c from ZTS_EU_Territory__c where ZTS_EU_Need_syncing__c = true AND ZTS_EU_Market__c != 'United States'];
       system.debug('custTerrList********'+custTerrList);
       for(ZTS_EU_Territory__c t : custTerrList){
         custTerrName.add(t.name);
         custTerrMap.put(t.name,t.id);
       }
       
       //Creation of Standard Territory2 based on Custom Territory2  
        for(ZTS_EU_Territory__c s : custTerrList){      
         
         if(custTerrMap!= null && stdTerrMap != null && custTerrMap.containskey(s.name) && custTerrMap.get(s.name) != stdTerrMap.get(s.name)){
           Territory2 newTerr = new Territory2();
           newTerr.Name = s.name;
            
           if(s.ZTS_EU_Parent_Territory__c != null){
             newTerr.ParentTerritoryid = stdTerrMapID.get(s.ZTS_EU_Parent_Territory__r.name);
           }
           if(custTerrMap != null){
             newTerr.Zoetis_Territory_ID_Map__c = custTerrMap.get(s.name);
           } 
           finalUpdateStdTerrlist.add(newTerr);
         }
         
        }
        if(!finalUpdateStdTerrlist.isempty()){
            try{ // Modified by Sunil
                insert finalUpdateStdTerrlist;                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Territories are successfully synced')); 
               
            }
            catch(Exception e){               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Process not completed'+e)); 
            } // End of modification
        }
         system.debug('finalUpdateStdTerrlist************'+finalUpdateStdTerrlist);
         return null;       
    } */
      
     /***********  
            * Method name  : updateStdTerr
            * Description  : This method update a custom Territory2 and custom setting field value.
            * Return Type  : PageReference.
            * Parameters   : None.
     ***********/ 
     
    /* public PageReference  updateStdTerr(){
       
       map<string,string> stdTerrMapID = new map<string,string>();
       list<ZTS_EU_Territory__c> custTerrList = new list<ZTS_EU_Territory__c>();
       list<Territory2> stdTerrList = new list<Territory2>();
       list<ZTS_EU_Territory__c> finalUpdateCustTerrlist = new list<ZTS_EU_Territory__c>();
       stdTerrlist = [select id,name, Zoetis_Territory_ID_Map__c from Territory2 limit 50000];
        for(Territory2 t : stdTerrlist){         
            stdTerrMapID.put(t.name, t.id);
        }
        custTerrList = [select id,name,ZTS_EU_Parent_Territory__r.name,ZTS_EU_Terr_SFID__c from ZTS_EU_Territory__c where ZTS_EU_Need_syncing__c = true AND ZTS_EU_Market__c != 'United States' limit 50000];       
       
         //Update Custom Territory2 with Standard Territory2 ID
          TerrSyncLogic__c tr = [Select Need_syncing__c from TerrSyncLogic__c where name='From VF page'];
          tr.Need_syncing__c = true;
          try{
              update tr;
              for(ZTS_EU_Territory__c ct : custTerrList){
                  if(stdTerrMapID != null){           
                    ct.ZTS_EU_Terr_SFID__c = stdTerrMapID.get(ct.name);
                    ct.ZTS_EU_Need_syncing__c = false;
                    ct.ZTS_EU_Is_Active__c = true;
                    ct.ZTS_EU_Territory_synced__c = true;  
                    finalUpdateCustTerrlist.add(ct);
                  } 
                }
                if(!finalUpdateCustTerrlist.isempty()){         
                    update finalUpdateCustTerrlist;
                    tr.Need_syncing__c = false;
                   update tr;               
                }
           }catch(DMLException e){
                ZTS_EU_Logger.error('DMLException***'+e.getMessage(), null, 'ZTS_EU_TerritoryConsoleController.updateStdTerr');
           
           }
        return null;
     }*/
     
     /***************Added by Pankaj ends here***********************/
    
    

    /*public String INSTANCE_SERVER_URL{get{return URL.getSalesforceBaseUrl().toExternalForm();}}*/
    /** total user Territory2 count **/
    /*public Integer totalUsrTerrCount{get{
         if(totalUsrTerrCount==null){
            totalUsrTerrCount=[SELECT COUNT() FROM ZTS_EU_Position__c WHERE ZTS_EU_Employee__c!= null and ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c != ''];
         }
         return totalUsrTerrCount;
        } private set;
    
    }*/
    /** total unassigned user Territory2 count **/
    /*public Integer totalUnassignedUsrTerrCount{get{
        if(totalUnassignedUsrTerrCount==null){
            totalUnassignedUsrTerrCount= getUnAssignedUserTerritoryResults().size();
         }
         return totalUnassignedUsrTerrCount;
        } private set;
    
    }*/
    
    /** total account count which are going to be process during re-allignment ****/
    /*public Integer totalUnprocessedAccountCount{get{
        if(totalUnprocessedAccountCount==null){
            totalUnprocessedAccountCount= [SELECT COUNT() FROM account WHERE ZTS_EU_Account_Status__c = 'Active' and IsExcludedFromRealign = false and ZTS_EU_Zip_Postal_Code__c != '' AND ZTS_EU_Market__c != 'United States'];
         }
         return totalUnprocessedAccountCount;
        } private set;
    
    }*/
    /***********  
    * Method name  : getUnAssignedUserTerritoryResults
    * Description  : This method returns details of to unassigned UserTerritory custom object records in comparison to Std. UserTerritory.
    * Return Type  : Unassigned UserTerr list.
    * Parameters   : None.
    ***********/
    /*public static List<ZTS_EU_Position__c> getUnAssignedUserTerritoryResults(){
        List<ZTS_EU_Position__c> unAssignedUserTerrList=new List<ZTS_EU_Position__c>();
        //******* FILTER BY SYNCED TERRITORIES *********
        List<ZTS_EU_Position__c> custUsrTerrList=[SELECT Id, ZTS_EU_Employee__c, ZTS_EU_Territory__c,ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c FROM ZTS_EU_Position__c WHERE ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c!='' and ZTS_EU_Employee__c!= null];
        List<Id> stdTerrIds=new List<Id>();
        Set<Id> custUsrTerrIds=new Set<Id>();
        
        for(ZTS_EU_Position__c custUsrTerr:custUsrTerrList){
            custUsrTerrIds.add(custUsrTerr.ZTS_EU_Territory__c);
            stdTerrIds.add(custUsrTerr.ZTS_EU_Territory__r.ZTS_EU_Terr_SFID__c);
        }
        Map<Id,Territory2> stdTerrMap=new Map<Id,Territory2>([SELECT Id , Zoetis_Territory_ID_Map__c FROM Territory2 WHERE Id IN :stdTerrIds]);
        //CHECK FOR ROWS FETCHED
        List<UserTerritory> stdUsrTerrList=[SELECT UserId, TerritoryId FROM UserTerritory WHERE TerritoryId IN :stdTerrIds];
        Set<String> stdUsrTerrUniqKeySet=new Set<String>();
        for(UserTerritory usrTerr:stdUsrTerrList){
            stdUsrTerrUniqKeySet.add(usrTerr.UserId+':'+stdTerrMap.get(usrTerr.TerritoryId).Zoetis_Territory_ID_Map__c);
                
        }
        for(ZTS_EU_Position__c custUsrTerr:custUsrTerrList){
            String usrTerrUniqKey=custUsrTerr.ZTS_EU_Employee__c+':'+custUsrTerr.ZTS_EU_Territory__c;
            System.debug('usrTerrUniqKey : '+usrTerrUniqKey+'\n');
            if(!stdUsrTerrUniqKeySet.contains(usrTerrUniqKey)){
                unAssignedUserTerrList.add(custUsrTerr);
            }
        }
        return unAssignedUserTerrList;
        
    }*/
    /***********  
    * Method name  : addUserToTerritory
    * Description  : This remote action method creates standard UserTerritory records from custom object.
    * Return Type  : Batch Info list.
    * Parameters   : None.
    ***********/
   /* @RemoteAction
    public static List<JobUtilities.BatchInfo> addUserToTerritory(){
      //send unassigned userterritory to Territory2 managed to add them to userterritory 
      JobUtilities job_util =ZTS_EU_TerritoryManager.insertUserTerritoryBatch(getUnAssignedUserTerritoryResults());
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
      }
      return batch;
    }*/
    /***********  
    * Method name  : StandaradTerritory
    * Description  : This method fetch standard Territory2 records.
    * Return Type  : List.
    * Parameters   : None.
    ***********/
    
   /* public static List<Territory2> getStandaradTerritory(){       
        List<ZTS_EU_Territory__c> custTerrList = new List<ZTS_EU_Territory__c>();
        List<Territory2> territoryList = new List<Territory2>(); 
        Set<ID> stdTerrID = new Set<Id>();
        custTerrList = [select id,ZTS_EU_Terr_SFID__c,ZTS_EU_Territory_synced__c,ZTS_EU_Is_Assigned__c,ZTS_EU_Need_syncing__c from ZTS_EU_Territory__c where ZTS_EU_Is_Assigned__c = false AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Need_syncing__c =  false and ZTS_EU_Territory_synced__c = true];
        for(ZTS_EU_Territory__c custTerr : custTerrList){
            stdTerrID.add(custTerr.ZTS_EU_Terr_SFID__c);
        }
        
        territoryList = [select id,name from Territory2 where id in : stdTerrID];       
        return territoryList;
    }*/
    
    /***********  
    * Method name  : addAssignmentRules
    * Description  : This remote action method creates standard Assignment Rules records.
    * Return Type  : Batch Info list.
    * Parameters   : None.
    ***********/
   /* @RemoteAction
    public static List<JobUtilities.BatchInfo> addAssignmentRules(){
      JobUtilities job_util =ZTS_EU_TerritoryManager.insertAssignmentRuleBatch(getStandaradTerritory());
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
      }
      
      return batch;
    }*/
   /***********  
    * Method name  : AssignmentRule
    * Description  : This method fetch assignmentrules records.
    * Return Type  : List.
    * Parameters   : None.
    ***********/
  /*  public static List<AccountTerritoryAssignmentRule> getAssignmentRule(){
        List<AccountTerritoryAssignmentRule> terrAssignRuleList = new List<AccountTerritoryAssignmentRule>();
        Set<ID> stdTerrID = new Set<Id>();
        List<ZTS_EU_Territory__c> custTerrList = new List<ZTS_EU_Territory__c>();
        custTerrList = [select id,ZTS_EU_Terr_SFID__c,ZTS_EU_Territory_synced__c,ZTS_EU_Is_Assigned__c,ZTS_EU_Need_syncing__c from ZTS_EU_Territory__c where ZTS_EU_Is_Assigned__c = false AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Need_syncing__c =  false and ZTS_EU_Territory_synced__c = true];
        for(ZTS_EU_Territory__c custTerr : custTerrList){
            stdTerrID.add(custTerr.ZTS_EU_Terr_SFID__c);
        }
        terrAssignRuleList = [select id,TerritoryId from AccountTerritoryAssignmentRule where TerritoryId In : stdTerrID];
        //return terrAssignRuleList; // commented by Shreyas
        
        // below code added by Shreyas
        Set<string> ruleListToBeExcluded = new Set<string>();
        ruleListToBeExcluded = getExcludedAssignmentRuleIdList(terrAssignRuleList);
        
        List<AccountTerritoryAssignmentRule> terrAssignRuleList_Refined = new List<AccountTerritoryAssignmentRule>();
        terrAssignRuleList_Refined = [select id,TerritoryId from AccountTerritoryAssignmentRule where TerritoryId In : stdTerrID AND Id Not IN : ruleListToBeExcluded];
        
        return terrAssignRuleList_Refined;
        
    }*/
    
    /***********  
    * Method name  : AssignmentRule
    * Description  : This method fetch assignmentrules records.
    * Return Type  : List.
    * Parameters   : None.
    ***********/
    /*public static List<AccountTerritoryAssignmentRule> getAssignmentRule2(){
        List<AccountTerritoryAssignmentRule> terrAssignRuleList = new List<AccountTerritoryAssignmentRule>();
        Set<ID> stdTerrID = new Set<Id>();
        List<ZTS_EU_Territory__c> custTerrList = new List<ZTS_EU_Territory__c>();
        custTerrList = [select id,ZTS_EU_Terr_SFID__c,ZTS_EU_Territory_synced__c,ZTS_EU_Is_Assigned__c,ZTS_EU_Need_syncing__c from ZTS_EU_Territory__c where ZTS_EU_Is_Assigned__c = false AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Need_syncing__c =  false and ZTS_EU_Territory_synced__c = true];
        for(ZTS_EU_Territory__c custTerr : custTerrList){
            stdTerrID.add(custTerr.ZTS_EU_Terr_SFID__c);
        }
        terrAssignRuleList = [select id,TerritoryId, BooleanFilter from AccountTerritoryAssignmentRule where TerritoryId In : stdTerrID];
        //return terrAssignRuleList; // commented by Shreyas
        
        // below code added by Shreyas
        Set<string> ruleListToBeExcluded = new Set<string>();
        ruleListToBeExcluded = getExcludedAssignmentRuleIdList(terrAssignRuleList);
        
        List<AccountTerritoryAssignmentRule> terrAssignRuleList_Refined = new List<AccountTerritoryAssignmentRule>();
        terrAssignRuleList_Refined = [select id,TerritoryId, BooleanFilter from AccountTerritoryAssignmentRule where TerritoryId In : stdTerrID AND Id NOT in: ruleListToBeExcluded];
        
        return terrAssignRuleList_Refined;
        
    }
    */
    /***********  
    * Method name  : getRefinedAssignmentRule
    * Description  : This method will excllude all those assignment rules that doesnt contain 'TSF PBC' fields in the criteria. 
    * Return Type  : List<string>
    * Parameters   : List<AccountTerritoryAssignmentRule>
    ***********/
    /*public static Set<string> getExcludedAssignmentRuleIdList(List<AccountTerritoryAssignmentRule> ruleList){
    
        List<string> ruleIdList = new List<string>();       
        for(AccountTerritoryAssignmentRule r: ruleList){
            ruleIdList.add(r.Id);
        }       
                
        List<AccountTerritoryAssignmentRuleItem> ruleItemList = new List<AccountTerritoryAssignmentRuleItem>();
        ruleItemList = [Select Id, Field, RuleID from AccountTerritoryAssignmentRuleItem where RuleID IN: ruleIdList];
        
        Map<string, List<string>> ruleMap = new Map<string, List<string>>();
        for(AccountTerritoryAssignmentRuleItem ri: ruleItemList){
            if(ruleMap.containsKey(ri.RuleID)){
                ruleMap.get(ri.RuleID).add(ri.Field);
            }
            else{
                ruleMap.put(ri.RuleID, new List<String>{ri.Field});
            }
        }
        
        Set<string> ruleListToBeExcluded = new Set<string>();

        for(string key: ruleMap.keyset()){
            List<string> fieldsList = new List<string>();
            fieldsList = ruleMap.get(key);
            integer i = fieldsList.size();
            if(i == 3){
                for(string s: fieldsList){
                    if(!s.contains('_TSF_PBC_')){
                        ruleListToBeExcluded.add(key);
                    }
                }
            }
            else{
                ruleListToBeExcluded.add(key);
            }
        }
        
        return ruleListToBeExcluded;
        
    }*/
    
    /***********  
    * Method name  : AssignmentTerrRule
    * Description  : This method stores terretory based on assignmentrule Territory2 id.
    * Return Type  : Map.
    * Parameters   : None.
    ***********/
    /*public static Map<Id,Territory2>  getAssignmentTerrRule(){
        List<AccountTerritoryAssignmentRule> terrAssignRuleList = new List<AccountTerritoryAssignmentRule>();
        Map<Id,Territory2> terrMap = new Map<Id,Territory2>();
        Set<ID> stdTerrID = new Set<Id>();
        List<ZTS_EU_Territory__c> custTerrList = new List<ZTS_EU_Territory__c>();
        custTerrList = [select id,ZTS_EU_Terr_SFID__c,ZTS_EU_Territory_synced__c,ZTS_EU_Is_Assigned__c,ZTS_EU_Need_syncing__c from ZTS_EU_Territory__c where ZTS_EU_Is_Assigned__c = false AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Need_syncing__c =  false and ZTS_EU_Territory_synced__c = true];
        for(ZTS_EU_Territory__c custTerr : custTerrList){
            stdTerrID.add(custTerr.ZTS_EU_Terr_SFID__c);
        }
        Map<Id,Territory2> terrMapID = new Map<Id,Territory2>([select id,name from Territory2 where id in : stdTerrID]);
        
        terrAssignRuleList = [select id,TerritoryId from AccountTerritoryAssignmentRule where TerritoryId in : stdTerrID];
        
        for(AccountTerritoryAssignmentRule assignRule : terrAssignRuleList){
            terrMap.put(assignRule.TerritoryId,terrMapID.get(assignRule.TerritoryId));
        
        }
        return terrMap;
    }*/
    /***********  
    * Method name  : addAssignmentRuleItems
    * Description  : This remote action method creates standard Assignment Rule Items records.
    * Return Type  : Batch Info list.
    * Parameters   : None.
    ***********/
    /*@RemoteAction
    public static List<JobUtilities.BatchInfo> addAssignmentRuleItems(){
    
      List<AccountTerritoryAssignmentRule> terrAssignRulefetch = new List<AccountTerritoryAssignmentRule>();
      terrAssignRulefetch = getAssignmentRule();
      
      JobUtilities job_util =ZTS_EU_TerritoryManager.insertAssignmentRuleItemBatch(terrAssignRulefetch,getAssignmentTerrRule());
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
      }
      
      
      return batch;
    }*/
    
    /***********  
    * Method name  : updateAssignmentRules
    * Description  : This remote action method updates standard Assignment Rule filter conditions to '1 OR 2 OR 3'.
    * Return Type  : Batch Info list.
    * Parameters   : None.
    ***********/
   /* @RemoteAction
    public static List<JobUtilities.BatchInfo> updateAssignmentRules(){
    
      List<AccountTerritoryAssignmentRule> terrAssignRulefetch = new List<AccountTerritoryAssignmentRule>();
      terrAssignRulefetch = getAssignmentRule2();
      
      JobUtilities job_util =ZTS_EU_TerritoryManager.updateAssignmentRuleBatch(terrAssignRulefetch);
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
      }
      
      return batch;
    }*/
    
    /***********  
    * Method name  : checkStatus
    * Description  : This remote action method checks the batch status.
    * Return Type  : BatchInfo details.
    * Parameters   : String batchId.
    ***********/
   /* @RemoteAction
    public static JobUtilities.BatchInfo checkStatus(String jobId,String batchId){
      //send unassigned userterritory to Territory2 managed to add them to userterritory 
      JobUtilities job_util=new JobUtilities();
      job_util.job=new JobUtilities.JobInfo(jobId);
      job_util.sessionId=Userinfo.getSessionId();
      return job_util.checkBatchStatus(batchId, new JobUtilities.BulkConnection());
    }*/
    
    
    /***********  
    * Method name  : closeJob
    * Description  : This remote action method close Job status.
    * Return Type  : BatchInfo details.
    * Parameters   : String batchId.
    ***********/
   /* @RemoteAction
    public static JobUtilities.JobInfo closeJob(String jobId){
      //send unassigned userterritory to Territory2 managed to add them to userterritory 
      JobUtilities job_util=new JobUtilities();
      job_util.job=new JobUtilities.JobInfo(jobId);
      job_util.sessionId=Userinfo.getSessionId();
      //job_util.checkBatchStatus(batchId, new JobUtilities.BulkConnection());
      job_util.closeJob(jobId, new JobUtilities.BulkConnection());
      return job_util.job;
    }*/
    
    /***********  
    * Method name  : finish
    * Description  : This method update Is Assigned checkbox.
    * Return Type  : PageReference.
    * Parameters   : None.
    ***********/
    /*public PageReference finish(){
        List<ZTS_EU_Territory__c> custTerrList = new List<ZTS_EU_Territory__c>();
        List<ZTS_EU_Territory__c> finalCustTerrList = new List<ZTS_EU_Territory__c>();
        custTerrList = [select id,ZTS_EU_Terr_SFID__c,ZTS_EU_Territory_synced__c,ZTS_EU_Is_Assigned__c,ZTS_EU_Need_syncing__c from ZTS_EU_Territory__c where ZTS_EU_Is_Assigned__c = false AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Need_syncing__c =  false and ZTS_EU_Territory_synced__c = true];
        for(ZTS_EU_Territory__c custTerr : custTerrList){
            custTerr.ZTS_EU_Is_Assigned__c = true;
            finalCustTerrList.add(custTerr);      
            
        }
        try{
             update finalCustTerrList;
        }catch(DMLException e){
               ZTS_EU_Logger.error('DML Exception******'+e.getMessage(), null, 'JobUtilities.JobInfo-closeJob');
        }
        return null;
    }*/
     /***********  
    * Method name  : fullReAlignment
    * Description  : exceute batch class.
    * Parameters   : None.
    ***********/
   /* public void fullReAlignment(){
        
        ZTS_EU_TerritroyAssignAccountBatch batch = new ZTS_EU_TerritroyAssignAccountBatch();
        batch.market =  marketType;
        
        database.executebatch(batch,20); 
       
        showMsg = true;    
    
    }*/
    /***********  
    * Method name  : zipAlignment
    * Description  : exceute batch class.
    * Parameters   : None.
    ***********/
   /* public void zipAlignment(){
        
        ZTS_EU_ZipAllignBatch b = new ZTS_EU_ZipAllignBatch();  
        b.market =  marketType;
        database.executebatch(b,20);
         
        showMsg = true;   
    
    }*/
    /***********  
    * Method name  : updateUserTerritory
    * Description  : exceute batch class.
    * Parameters   : None.
    ***********/
    /*public void updateUserTerritory(){
        
      Date toDt=Date.today();
      Date fromDt=toDt.addDays(-1);
      ZTS_EU_UserTerritoryRemoveScheduleBatch utr_sb=new ZTS_EU_UserTerritoryRemoveScheduleBatch(UserInfo.getSessionId(),fromDt,toDt);
      database.executebatch(utr_sb,20); 
      RemoveUsershowMsg = true;
    
    }*/
}