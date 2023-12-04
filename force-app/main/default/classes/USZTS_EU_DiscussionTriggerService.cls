/****************************************************************************************************************************************** 
 * Trigger Name : USZTS_EU_DiscussionTriggerService
 * Description  : Service class to handle ZTS_EU_Discussion__c trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/11/2020		Consolidated trigger logic in service class
 * Added below triggers:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Trigger Name   : DiscussionCheck
*****************************************************************************************************************************************/
public class USZTS_EU_DiscussionTriggerService 
{
    
    public static void afterInsert(List<ZTS_EU_Discussion__c> triggerNew, Map<Id, ZTS_EU_Discussion__c> triggerNewMap)
    {
        // String[] filters = new String[]{'Leadership Certificate Program (LCP) - Opportunity','KL Automation - Basic Plan Opportunity','KL Automation - Premium Plan Opportunity'};
        List<DiscussionMapping__c> ditems = DiscussionMapping__c.getall().values();
        List<String> dits = new List<String>();
        for(DiscussionMapping__c di: ditems){
            dits.add(di.Disc_Item__c);
        }
        
        List<ZTS_EU_Discussion__c> lst = new List<ZTS_EU_Discussion__c>([select ZTS_EU_Call_Attendee__r.ZTS_EU_call__c,name from ZTS_EU_Discussion__c 
                                                                         where id IN:triggerNew and Name like:dits AND ZTS_EU_Market__c = 'United States']);
        if(lst.size()>0){
            Set<Id> parentIds = new Set<Id>();
            for(ZTS_EU_Discussion__c child : lst){
                parentIds.add(child.ZTS_EU_Call_Attendee__c);
            }
            Map<Id,Attendee__c> parentRecords = new Map<Id,Attendee__c>([Select ZTS_EU_call__c from Attendee__c where id in :parentIds AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']);
            Set<Id> grandParentIds = new Set<Id>();
            for(Attendee__c parentRecord : parentRecords.values()){
                grandParentIds.add(parentRecord.ZTS_EU_call__c);
            }
            Map<Id,Call__c> grandParentRecords = new Map<Id,Call__c>([Select id,Opportunity_Type__c from Call__c where id in : grandParentIds AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']);
            for(ZTS_EU_Discussion__c child : lst){
                if(parentRecords.containsKey(child.ZTS_EU_Call_Attendee__c) && grandParentRecords.containsKey(parentRecords.get(child.ZTS_EU_Call_Attendee__c).ZTS_EU_call__c)){
                    grandParentRecords.get(parentRecords.get(child.ZTS_EU_Call_Attendee__c).ZTS_EU_call__c).Opportunity_Type__c = child.name;
                }
            }
            update grandParentRecords.values();
        }
    }
}