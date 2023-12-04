/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_UpdateEventSubjectOnIsertUdate 
 * Description :  Update the Event Subject after insert Ref: INC0385931
 * Created By   : Sohil Shah (CloudSense)
 * Created Date : 15/09/2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * 
*****************************************************************************************************************************************/

public class ZTS_EU_UpdateEventSubjectOnIsertUdate
{
    public static boolean flag = false;
    public static void updateEventSubject(List<Event> eventList)
    {
        if(flag == false)
        {
            List<Event> currentEventList = new List<Event>();
            List<Event> EventToUpdateList = new List<Event>();
            List<String>callId = new List<String>();
            currentEventList = [Select Id, Subject, CallRecordId__c from Event where id IN: eventList AND ZTS_EU_Market__c != 'United States'];
            for(Event eve: currentEventList)
            {
                callId.add(eve.CallRecordId__c); 
            }
            Map<Id, Call__C> callVsCallMap = new Map<Id,Call__C>([Select id, Name from Call__c where id IN: callId AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']);
            
            Map<Id,String> EventVsCallNameMap = new Map<Id,String>();
            
            for(Event eve: currentEventList)
            {
                //EventVsCallNameMap.put(eve.id,call.Name);
                if(callVsCallMap.get(eve.CallRecordId__c) != null)
                {
                    if (eve.subject == callVsCallMap.get(eve.CallRecordId__c).Name) continue;
                    eve.subject = callVsCallMap.get(eve.CallRecordId__c).Name;
                } 
                EventToUpdateList.add(eve);
            }
            flag = true;
            Database.update(EventToUpdateList, false);
        }
    }
}