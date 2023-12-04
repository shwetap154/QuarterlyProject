/****************************************************************************************************************************************** 
 * Class Name   : eventUpdate
 * Description  : This is class for Event Trigger to translate Sub type values to French DEF-001251.     
 * Created By   : CloudSense(Sohil Shah) 
 * Created Date : 4th June, 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sohil Shah           06/04/2015          Created 
*****************************************************************************************************************************************/
public class eventUpdate
{
    public static void updatEventOnInsert(List<Event> eventList)
    {
        boolean flag = false;
        if(flag == false)
        {
        
            List<Event> allEventList = new List<Event>();
            List<Event> allEventListToUpdate = new List<Event>();
            System.debug('allEventList-----'+allEventList);
            allEventList =[Select Id,Sub_Type__c from Event where id IN: eventList AND ZTS_EU_Market__c != 'United States'];
            for(Event eve : allEventList)
            {
                System.debug('System.Label.Account_Call-----'+System.Label.Account_Call);
                System.debug('eve.Sub_Type__c----'+eve.Sub_Type__c);
                if(eve.Sub_Type__c == System.Label.Account_Call)
                    {
                        eve.Sub_Type__c = 'Visite client'; 
                    }
                    if(eve.Sub_Type__c == System.Label.Account_Call_with_Speaker)
                    {
                        eve.Sub_Type__c = 'Visite avec KOL'; 
                    }
                    if(eve.Sub_Type__c == System.Label.Advisory_Diagnostic_visit)
                    {
                        eve.Sub_Type__c = 'Visite Diagnostic'; 
                    }
                    if(eve.Sub_Type__c == System.Label.Clinical_Seedings_initial)
                    {
                        eve.Sub_Type__c = 'Visite élevage'; 
                    }
                    if(eve.Sub_Type__c == System.Label.Demonstration_PPE)
                    {
                        eve.Sub_Type__c = 'Démonstration'; 
                    }
                    if(eve.Sub_Type__c == System.Label.ICP_DMA_visit)
                    {
                        system.debug('eve.Sub_Type__c--------'+eve.Sub_Type__c);
                        eve.Sub_Type__c = 'Rev Intra-Cabinet'; 
                    }
                    if(eve.Sub_Type__c == System.Label.Loyalty_VAS_visit)
                    {
                        eve.Sub_Type__c = 'Visite PBC - Offre payante'; 
                    }
                    if(eve.Sub_Type__c == System.Label.PBC_Call)
                    {
                        eve.Sub_Type__c = 'Visite PBC - Offre non payante'; 
                    }
                    if(eve.Sub_Type__c == System.Label.Practice_Discussion_Group)
                    {
                        eve.Sub_Type__c = 'Groupe de discussion'; 
                    }
                    
                    allEventListToUpdate.add(eve);
               }
                System.debug('allEventListToUpdate-----'+allEventListToUpdate);
                flag = true;
            update allEventListToUpdate;
        }        
    }
            
}