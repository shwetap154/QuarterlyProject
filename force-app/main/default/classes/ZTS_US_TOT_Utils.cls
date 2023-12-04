/*
* @Name: ZTS_US_TOT_Utils
* @Desciption: Utils Class for the trigger on TOT.
*              1.Avoids creation and updation of TOT for the User whenever there is a conflict with DateTime of a call associated with that User.(not in use)'Factored out by US Region'
*              2.Prevents Deletion of records where the Start Date has past.'Factored in by US Region'
*              3.Creates Calender Event for the TOT Owner.'Factored in by US Region'
*              4.Updates Calender Event.'Factored in by US Region'
*              5.Stamps Start/End DateTime fields of TOT for the Calender Event Start/End DateTime mapping.'Factored in by US Region'
*              6.Prevents conflicting TOTs for the same User.'Factored in by US Region'
* @date Created:Feb 21, 2014
* @author Ketan Prakash Singh
*/
public class ZTS_US_TOT_Utils{
/*
    public static void validateTOTDateOnInsertAndUpdate(List<Time_Out_of_Territory__c> lstTOT){
        List<Attendee__c> lstAttendee = new List<Attendee__c>();
        List<Call__c> lstCall = new List<Call__c>();
        Set<Id> setCallId = new Set<Id>();
        
        lstAttendee = [Select a.call__c, a.Name, a.Id, a.Employee__c, a.Contact__c From Attendee__c a where a.Employee__c = :UserInfo.getUserId()];
        system.debug('@@@@@@@@@@@@@lstAttendee is: '+lstAttendee );
        if(lstAttendee != null && lstAttendee.size() > 0){
            for(Attendee__c att: lstAttendee){
                setCallId.add(att.call__c);
            }
        }
        lstCall = [Select c.Start_Date_Time__c, c.Id, c.End_Date_Time__c, c.Account__c, c.CreatedById From Call__c c 
                    where (c.Id in :setCallId or c.CreatedById = :UserInfo.getUserId()) AND c.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
        system.debug('@@@@@@@@@@@@@lstCall is: '+lstCall);
        if(lstCall != null && lstCall.size() > 0){
            for(Call__c c: lstCall){
               if(c.Start_Date_Time__c != null){
                   system.debug('@@@@@@@@@@@@@c.Start_Date_Time__c in datetime format is: '+c.Start_Date_Time__c);
                   system.debug('@@@@@@@@@@@@@c.Start_Date_Time__c in date format is: '+c.Start_Date_Time__c.date()); 
                  for(Time_Out_of_Territory__c tot: lstTOT){
                       if(tot.ZTS_EU_Start_Date__c != null && tot.ZTS_EU_Start_Date__c == c.Start_Date_Time__c.date()){
                           tot.addError('You cannot proceed with this time off request because of meeting conflict');
                       } 
                   }
               }
            }
        }
    }  
    */
    
    // Stamps Start/End DateTime fields of TOT for the Calender Event Start/End DateTime mapping.'Factored in by US Region'
    
    public static void dateTimeFill(List < Time_Out_of_Territory__c > lstTOT) {

//List<Time_Out_of_Territory__c> lstToT1 = new List<Time_Out_of_Territory__c>([Select Id,ZTS_EU_Duration__c,ZTS_EU_Start_Date__c,ZTS_EU_End_Date_Time__c from Time_Out_of_Territory__c where id In : lstTOT AND ZTS_Market__c = 'United States']);
    List<Time_Out_of_Territory__c> lstToTupdate = new List<Time_Out_of_Territory__c>();    
    for(Time_Out_of_Territory__c tot : lstToT){
        if(tot.ZTS_EU_Duration__c == 'Full Day = 9 AM - 5 PM'){
            tot.ZTS_EU_Start_Date_Time__c = datetime.newInstance(tot.ZTS_EU_Start_Date__c.year(),tot.ZTS_EU_Start_Date__c.month(),tot.ZTS_EU_Start_Date__c.day(),09,00,00);
            tot.ZTS_EU_End_Date_Time__c = datetime.newInstance(tot.ZTS_EU_End_Date__c.year(),tot.ZTS_EU_End_Date__c.month(),tot.ZTS_EU_End_Date__c.day(),17,00,00);

            //lstToTupdate.add(tot);
        }

        if(tot.ZTS_EU_Duration__c == 'AM = 9 AM to 1 PM'){
            tot.ZTS_EU_Start_Date_Time__c = datetime.newInstance(tot.ZTS_EU_Start_Date__c.year(),tot.ZTS_EU_Start_Date__c.month(),tot.ZTS_EU_Start_Date__c.day(),09,00,00);
            tot.ZTS_EU_End_Date_Time__c = datetime.newInstance(tot.ZTS_EU_End_Date__c.year(),tot.ZTS_EU_End_Date__c.month(),tot.ZTS_EU_End_Date__c.day(),13,00,00);

            //lstToTupdate.add(tot);
        }

        if(tot.ZTS_EU_Duration__c == 'PM = 1 PM to 5 PM'){
            tot.ZTS_EU_Start_Date_Time__c = datetime.newInstance(tot.ZTS_EU_Start_Date__c.year(),tot.ZTS_EU_Start_Date__c.month(),tot.ZTS_EU_Start_Date__c.day(),13,00,00);
            tot.ZTS_EU_End_Date_Time__c = datetime.newInstance(tot.ZTS_EU_End_Date__c.year(),tot.ZTS_EU_End_Date__c.month(),tot.ZTS_EU_End_Date__c.day(),17,00,00);
            
            //lstToTupdate.add(tot);
        }

     }
   }
    
    
     // Prevents conflicting TOTs for the same User.'Factored in by US Region'
     
     public static void preventTOTConflict(List < Time_Out_of_Territory__c > lstTOT) {
         Set<Id> setTOTOwnerId = new Set<Id>();
         List<Time_Out_of_Territory__c> lstTOTWithSameOwner = new List<Time_Out_of_Territory__c>();
         
         for(Time_Out_of_Territory__c tot: lstTOT){
             setTOTOwnerId.add(tot.ownerId);
         }
         
         lstTOTWithSameOwner = [Select z.ZTS_EU_Start_Date__c, z.ZTS_EU_Start_Date_Time__c, z.ZTS_EU_End_Date__c, z.ZTS_EU_End_Date_Time__c, 
                                 z.ZTS_EU_Duration__c, z.OwnerId, z.Id From Time_Out_of_Territory__c z 
                                 where z.OwnerId in :setTOTOwnerId  AND ZTS_Market__c = 'United States'];
                                 
         for(Time_Out_of_Territory__c tot: lstTOT){
             for(Time_Out_of_Territory__c totSameOwnr: lstTOTWithSameOwner){
                 if(totSameOwnr.OwnerId == tot.OwnerId && totSameOwnr.Id != tot.Id){
                     if(totSameOwnr.ZTS_EU_Start_Date__c == tot.ZTS_EU_Start_Date__c && 
                         totSameOwnr.ZTS_EU_End_Date__c == tot.ZTS_EU_End_Date__c && 
                         totSameOwnr.ZTS_EU_Duration__c == tot.ZTS_EU_Duration__c){
                             tot.addError(System.Label.ZTS_US_TOT_ERROR_MSG_SAME);
                     }
                     if(totSameOwnr.ZTS_EU_Start_Date__c == tot.ZTS_EU_Start_Date__c){
                         if(totSameOwnr.ZTS_EU_Duration__c == 'Full Day = 9 AM - 5 PM' && 
                             (tot.ZTS_EU_Duration__c == 'AM = 9 AM to 1 PM' || tot.ZTS_EU_Duration__c == 'PM = 1 PM to 5 PM' || tot.ZTS_EU_Duration__c == 'Full Day = 9 AM - 5 PM')){
                                 tot.addError(System.Label.ZTS_US_TOT_ERROR_MSG_FULL_DAY);
                         }
                         if(totSameOwnr.ZTS_EU_Duration__c == 'AM = 9 AM to 1 PM' && 
                             (tot.ZTS_EU_Duration__c == 'AM = 9 AM to 1 PM' || tot.ZTS_EU_Duration__c == 'Full Day = 9 AM - 5 PM')){
                                 tot.addError(System.Label.ZTS_US_TOT_ERROR_MSG_AM);
                         }
                         if(totSameOwnr.ZTS_EU_Duration__c == 'PM = 1 PM to 5 PM' && 
                             (tot.ZTS_EU_Duration__c == 'PM = 1 PM to 5 PM' || tot.ZTS_EU_Duration__c == 'Full Day = 9 AM - 5 PM')){
                                 tot.addError(System.Label.ZTS_US_TOT_ERROR_MSG_PM);
                         }
                     }
                     
                     if(totSameOwnr.ZTS_EU_Start_Date__c < tot.ZTS_EU_Start_Date__c && tot.ZTS_EU_Start_Date__c <= totSameOwnr.ZTS_EU_End_Date__c){
                         tot.addError(System.Label.ZTS_US_TOT_ERROR_MSG_EXTENDED_FULL_DAY);
                     }
                     if(totSameOwnr.ZTS_EU_Start_Date__c > tot.ZTS_EU_Start_Date__c && 
                     (tot.ZTS_EU_End_Date__c >= totSameOwnr.ZTS_EU_End_Date__c || tot.ZTS_EU_End_Date__c >= totSameOwnr.ZTS_EU_Start_Date__c)){
                         tot.addError(System.Label.ZTS_US_TOT_ERROR_MSG_CONFLICT);
                     }
                 }
             }
         }                        
     }
    
    // Prevents Deletion of records where the Start Date has past.'Factored in by US Region'
    
    public static void preventDeletion(List<Time_Out_of_Territory__c> lstTOT){
        for(Time_Out_of_Territory__c tot: lstTOT){
            if((tot.ZTS_EU_Start_Date__c != null && tot.ZTS_EU_Start_Date__c < System.today()) || tot.ZTS_EU_Status__c == 'Submitted'){
                tot.addError('You cannot delete this time off request because the Start Date has past or it is Submitted');
            }
        }
    }
    
    // Creates Calender Event for the TOT Owner.'Factored in by US Region'
    
    public static void calenderEventCreation(List<Time_Out_of_Territory__c> lstTOT){
        List<Event> lstEvent = new List<Event>();
        String eventRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'General_Event'].Id;
        
        for(Time_Out_of_Territory__c tot: lstTOT){
            Event eventObj = new Event();
            eventObj.OwnerId = tot.ownerId;       
            eventObj.Subject = tot.ZTS_EU_Reason__c;        
            eventObj.WhatId = tot.Id; 
            /*
            eventObj.StartDateTime = tot.ZTS_EU_Start_Date__c;
            eventObj.EndDateTime = tot.ZTS_EU_End_Date__c;       
            eventObj.ActivityDate = tot.ZTS_EU_Start_Date__c;  
            */ 
            eventObj.StartDateTime = tot.ZTS_EU_Start_Date_Time__c;
            eventObj.EndDateTime = tot.ZTS_EU_End_Date_Time__c;       
            eventObj.ActivityDateTime = tot.ZTS_EU_Start_Date_Time__c;
                     
            eventObj.RecordTypeId = eventRecordTypeId;
            eventObj.Description = tot.ZTS_EU_Description__c;
            //eventObj.Type = 'ABC';
            
            lstEvent.add(eventObj);
            System.debug('@@@TOT Start Date is: '+tot.ZTS_EU_Start_Date__c);
            System.debug('@@@TOT End Date is: '+tot.ZTS_EU_End_Date__c);
            System.debug('@@@lstEvent is: '+lstEvent[0].id);
            System.debug('@@@lstEvent StartDateTime is: '+lstEvent[0].StartDateTime);
            System.debug('@@@lstEvent EndDateTime is: '+lstEvent[0].EndDateTime);
            System.debug('@@@lstEvent ActivityDate is: '+lstEvent[0].ActivityDate);
            System.debug('@@@lstEvent is: '+lstEvent);
        }
        try{
            Database.insert(lstEvent);
        }
        catch(Exception e){
            system.debug('Exception while creating an OOTB event'+ e);
        }
    }
    
    // Updates Calender Event.'Factored in by US Region'
    
    public static void updateCalenderEvent(List<Time_Out_of_Territory__c> lstTOT,Map<ID,Time_Out_of_Territory__c> totOldMap){
        Map<Id,Event> mapTOTIdAndEvent = new Map<Id,Event>();
        List<Event> lstEvent = new List<Event>();
        List<Event> lstEventToUpdate = new List<Event>();
        Set<Id> setTOTId = new Set<Id>();
        
        for(Time_Out_of_Territory__c objTOT: lstTOT){
            setTOTId.add(objTOT.Id);
        }
        
        lstEvent = [Select e.WhatId, e.ActivityDateTime, e.type, e.Subject, e.StartDateTime, e.OwnerId, e.Id, e.EndDateTime, e.Description, e.ActivityDate 
                    From Event e where e.WhatId in :setTOTId AND ZTS_EU_Market__c = 'United States' ];
                    
        for(Event objEvent: lstEvent){
            mapTOTIdAndEvent.put(objEvent.WhatId,objEvent);
        }
        
        for(Time_Out_of_Territory__c objTOT: lstTOT){
            Time_Out_of_Territory__c oldObjTOT = totOldMap.get(objTOT.id);
            if(oldObjTOT.OwnerId != objTOT.OwnerId || 
               oldObjTOT.ZTS_EU_Start_Date__c != objTOT.ZTS_EU_Start_Date__c || oldObjTOT.ZTS_EU_End_Date__c != objTOT.ZTS_EU_End_Date__c || 
               oldObjTOT.ZTS_EU_Reason__c != objTOT.ZTS_EU_Reason__c || oldObjTOT.ZTS_EU_Description__c != objTOT.ZTS_EU_Description__c || 
               oldObjTOT.ZTS_EU_Start_Date_Time__c != objTOT.ZTS_EU_Start_Date_Time__c || 
               oldObjTOT.ZTS_EU_End_Date_Time__c != objTOT.ZTS_EU_End_Date_Time__c ){
                if(mapTOTIdAndEvent.get(objTOT.Id) != null){   
                    mapTOTIdAndEvent.get(objTOT.Id).OwnerId = objTOT.OwnerId;
                    mapTOTIdAndEvent.get(objTOT.Id).Subject = objTOT.ZTS_EU_Reason__c;
                    /*
                    mapTOTIdAndEvent.get(objTOT.Id).StartDateTime = objTOT.ZTS_EU_Start_Date__c;
                    mapTOTIdAndEvent.get(objTOT.Id).EndDateTime = objTOT.ZTS_EU_End_Date__c;
                    mapTOTIdAndEvent.get(objTOT.Id).ActivityDate = objTOT.ZTS_EU_Start_Date__c;
                    */
                    mapTOTIdAndEvent.get(objTOT.Id).StartDateTime = objTOT.ZTS_EU_Start_Date_Time__c;
                    mapTOTIdAndEvent.get(objTOT.Id).EndDateTime = objTOT.ZTS_EU_End_Date_Time__c;
                    mapTOTIdAndEvent.get(objTOT.Id).ActivityDateTime = objTOT.ZTS_EU_Start_Date_Time__c;
                    
                    mapTOTIdAndEvent.get(objTOT.Id).Description = objTOT.ZTS_EU_Description__c;
                    
                    lstEventToUpdate.add(mapTOTIdAndEvent.get(objTOT.Id));
                }
            }
        }
        try{
            if(lstEventToUpdate != null && lstEventToUpdate.size() > 0){
                Database.update(lstEventToUpdate);
            }
        }
        catch(Exception e){
            system.debug('Exception while updating an OOTB event'+ e);
        }
    }
}