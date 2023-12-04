/****************************************************************************************************************************************** 
 * Class Name       : USZTS_US_Class_Expense_Trigger_Helper
 * Description      : The class is used by the trigger to perform the following actions 
                            1. Check if more than one speaker for same date is associated for an event and throw error  
 * Created By   : Deloitte Consulting
 * Created Date : July 9th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Deloitte                 07/09/2014          Created 
 * Saibal Mondal            10/24/2016          Ref US SC-002011 : Added method UpdateSpeakerContactIDsOnEvent() for stamping Speaker Contact IDs on Event. 
 * *****************************************************************************************************************************************/
public class USZTS_US_Class_Speaker_Check_Helper 
{
    public static void checkSpeakerRecord(List <ZTS_US_Speaker__c> listSpeaker, Map<ID, ZTS_US_Speaker__c> mapSpeakerID)
    {    
        set<id> setEventIds=new set<id>();
        for(ZTS_US_Speaker__c oSpeaker:listSpeaker){
            setEventIds.add(oSpeaker.ZTS_US_Event__c);
        }
        if(setEventIds.size()>0){
            map<id,ZTS_Events__c> mapEvents=new map<id,ZTS_Events__c>([select id,ZTS_US_Name__c,(select ZTS_US_Speaking_Date__c,ZTS_US_Contact__c from speakers__r)
                                                                       from ZTS_Events__c where id in :setEventIds AND ZTS_EU_Market__c = 'United States']);
            for(ZTS_US_Speaker__c oSpeaker:listSpeaker){
                
                for(ZTS_US_Speaker__c oSpeakerCheck:mapEvents.get(oSpeaker.ZTS_US_Event__c).speakers__r){
                    if(oSpeaker.id==null||oSpeaker.id<>oSpeakerCheck.id){
                        if(oSpeaker.ZTS_US_Contact__c==oSpeakerCheck.ZTS_US_Contact__c&&oSpeaker.ZTS_US_Speaking_Date__c==oSpeakerCheck.ZTS_US_Speaking_Date__c)
                            oSpeaker.addError('A speaker with same contact and speaking date already exists for the event '+
                                                        mapEvents.get(oSpeaker.ZTS_US_Event__c).ZTS_US_Name__c+'. Please select a different contact or speaking date.');
                        else
                            mapEvents.get(oSpeaker.ZTS_US_Event__c).speakers__r.add(oSpeaker);                   
                    }
                    
                }
                
            }
        }
    }

    public static void UpdateSpeakerContactIDsOnEvent(List <ZTS_US_Speaker__c> listSpeaker)
    {
        
        set<id> setEventIds=new set<id>();
        for(ZTS_US_Speaker__c oSpeaker:listSpeaker){
            setEventIds.add(oSpeaker.ZTS_US_Event__c);
        }
        if(setEventIds.size()>0){
            List<ZTS_Events__c> eventList = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id in :setEventIds AND ZTS_EU_Market__c = 'United States']);
            
            Map<Id,List<Id>> evntSpeakerIDMap = new Map<Id, List<Id>>();
            
            List<ZTS_US_Speaker__c> eventSpeakerList = new List<ZTS_US_Speaker__c>([SELECT Id,ZTS_US_Contact__c,ZTS_US_Event__c FROM ZTS_US_Speaker__c WHERE ZTS_US_Event__c in :setEventIds AND ZTS_EU_Market_from_Parent__c = 'United States' Order By ZTS_US_Event__c, CreatedDate]);
            
            List<Id> tmpList = new List<Id>();
            
            for(ZTS_US_Speaker__c speaker : eventSpeakerList)
            {
                if(evntSpeakerIDMap.containsKey(speaker.ZTS_US_Event__c))
                {
                    tmpList = evntSpeakerIDMap.get(speaker.ZTS_US_Event__c);
                    tmpList.add(speaker.ZTS_US_Contact__c);
                    evntSpeakerIDMap.put(speaker.ZTS_US_Event__c, tmpList);
                }
                else
                {
                    evntSpeakerIDMap.put(speaker.ZTS_US_Event__c, new List<Id> { speaker.ZTS_US_Contact__c } );
                }
            }
            
            for(ZTS_Events__c event : eventList)
            {
                tmpList = evntSpeakerIDMap.get(event.Id);
                
                if( tmpList == null || tmpList.size() == 0)
                {
                    event.Speaker_ID_1__c = null;
                    event.Speaker_ID_2__c = null;
                    event.Speaker_ID_3__c = null;
                }
                else if(tmpList.size() == 1)
                {
                    event.Speaker_ID_1__c = tmpList[0];
                    event.Speaker_ID_2__c = null;
                    event.Speaker_ID_3__c = null;
                }
                else if (tmpList.size() == 2)
                {
                    event.Speaker_ID_1__c = tmpList[0];
                    event.Speaker_ID_2__c = tmpList[1];
                    event.Speaker_ID_3__c = null;
                }
                else if (tmpList.size() >= 3)
                {
                    event.Speaker_ID_1__c = tmpList[0];
                    event.Speaker_ID_2__c = tmpList[1];
                    event.Speaker_ID_3__c = tmpList[2];
                }  
            }           
            
            Database.update(eventList);            
            
        }
    }
   
}