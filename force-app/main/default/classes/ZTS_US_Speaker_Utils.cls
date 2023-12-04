/*************************************************************************************************************************
  Class Name     : ZTS_US_Speaker_Utils
  Description    : Utils Class for the trigger on TOT.
                    1.Avoids creation and updation of Speaker with the same Speaking Date for the same Event.
  Created By     : Ketan Prakash Singh
  Created On     : Feb 21, 2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Ketan Prakash Singh                 Feb 21, 2014              Created

***************************************************************************************************************************/
public class ZTS_US_Speaker_Utils{
    
    /***********       
    * Method name  : validateOnInsertAndUpdate
    * Description  : This show error on speaker object record.
    * Return Type  : None.
    * Parameters   : List<ZTS_US_Speaker__c>.
    ***********/
    public static void validateOnInsertAndUpdate(List<ZTS_US_Speaker__c> lstSpaeker){
        List<ZTS_Events__c> lstEvents = new List<ZTS_Events__c>();
        Set<Id> setEventId = new Set<Id>();
        
        for(ZTS_US_Speaker__c speakerObj: lstSpaeker){
            setEventId.add(speakerObj.ZTS_US_Event__c);
        }        
           lstEvents = [Select z.Name, z.Id, (Select Name, ZTS_US_Event__c, ZTS_US_Speaking_Date__c, ZTS_US_Contact__c From Speakers__r) From ZTS_Events__c z 
                  where z.Id in :setEventId AND z.ZTS_EU_Market__c = 'United States'];        
        if(lstEvents != null && lstEvents.size() > 0 && lstEvents[0].Speakers__r != null && lstEvents[0].Speakers__r.size() > 0){
            for(ZTS_US_Speaker__c eveSpeakerObj: lstEvents[0].Speakers__r){
                for(ZTS_US_Speaker__c speakerObj: lstSpaeker){
                   if(speakerObj.ZTS_US_Event__c == eveSpeakerObj.ZTS_US_Event__c && speakerObj.ZTS_US_Contact__c == eveSpeakerObj.ZTS_US_Contact__c && speakerObj.ZTS_US_Speaking_Date__c == eveSpeakerObj.ZTS_US_Speaking_Date__c){
                       speakerObj.addError('You cannot add same speaker on with the same speaking date on the same event');
                   }
                }
            }
        }
    }    
}