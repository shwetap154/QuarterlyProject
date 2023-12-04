/*************************************************************************************
* Name          :    ZFS_DeleteOpenLeads
* Description   :    Batch class to delete Leads which are in Open OR Pre-Qualification Not Eligible status. 
* Author        :    Tanmoy Bardhan(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
Jan 02, 2017       Tanmoy Bardhan(Cognizant)         Created

**************************************************************************************/

public class ZFS_DeleteOpenLeads implements Database.Batchable<sObject> {
    public ID recID;
    //Start Method which retrieves Open Lead records
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select ID,Name,createddate, LastModifiedDate,RecordTypeId FROM Lead where (Status = 'Open' OR Status = 'Pre-Qualification Not Eligible') AND Market__c = 'United States']);
    }
    
    //Execute method
    public void execute (Database.BatchableContext BC, List<Lead> open_Leads){
        recID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Shelters').getRecordTypeId();
        List<Lead> leads_to_del = new List<Lead>();
        for (Lead l : open_Leads){
            if(recID == l.RecordTypeId && l.LastModifiedDate.Date().daysBetween(system.now().Date()) > 90){
                leads_to_del.add(l);
                //system.debug('Leads to delete ==>'+ l.Name +''+ l.LastModifiedDate);                
            }
        }
        //delete(leads_to_del);
    }
    
    //Finish Method
    public void finish(Database.BatchableContext BC){
        
    }
    
   /* public void execute(SchedulableContext sc){
        String batchID = Database.executeBatch(new ZFS_DeleteOpenLeads());
    }
    
    //Call the schedulable class and schedule it at 12AM every night
    public static String schedule(){
        String CRON_EXP = '0 0 0 * * ? *'; //this schedules the class 12AM every night
        ZFS_DeleteOpenLeads dol = new ZFS_DeleteOpenLeads();
        return system.schedule('Delete Open Shelter Leads', CRON_EXP, dol);
    }*/
}