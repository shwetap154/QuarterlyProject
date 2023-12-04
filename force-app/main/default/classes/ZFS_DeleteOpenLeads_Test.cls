/*************************************************************************************
* Name          :    ZFS_DeleteOpenLeads_Test
* Description   :    Test class to test ZFS_DeleteOpenLeads 
* Author        :    Tanmoy Bardhan(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
Jan 02, 2017       Tanmoy Bardhan(Cognizant)         Created

**************************************************************************************/


@isTest(SeeAllData=False)
public class ZFS_DeleteOpenLeads_Test {
    static testMethod void ZFS_DeleteOpenLeads(){
        ID LeadRecTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Shelters').getRecordTypeId();
        List<Lead> leadList = new List<Lead>();
        for (Integer i=1 ; i<=200 ; i++){
            Lead l = new Lead(LastName = 'Test'+i , Company = 'Test'+i , RecordTypeId = LeadRecTypeID);
            leadList.add(l);
        }
        Insert leadList;
        
        List<Lead> openLeadsList = [Select ID,Name,createddate, LastModifiedDate,RecordTypeId FROM Lead where Status = 'Open' AND Market__c = 'United States'];
        
        Test.startTest();
        ZFS_DeleteOpenLeads zfs = new ZFS_DeleteOpenLeads();
        zfs.start(NULL);
        zfs.execute(null, openLeadsList);
        zfs.finish(null);
        Test.stopTest();
    }
    
    /*static testMethod void testSchedule(){
        Test.startTest();
        ZFS_DeleteOpenLeads.schedule();
        Test.stopTest();
    }*/
}