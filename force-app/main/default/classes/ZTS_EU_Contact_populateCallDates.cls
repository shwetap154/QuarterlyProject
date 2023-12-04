/*************************************************************************************
* Name          :    ZTS_EU_Contact_populateCallDates .
* Description   :    Controller for Dispalying last call date on Contact Layout.
* Author        :    Ninad

Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
02/20/2014       Ninad           Created
09/08/2021       Sree Harsha     Modifed the getLastCAllDate method for SC-008874
10/22/2021       Chelsea Paice   Fixing permissions errors for SC-009076
11/18/2021       Chanbasha NBSK  Updated SOQL  query to filter only Submitted & Completed calls[SC-008964]
**********************************************************************************************************/
public without sharing class ZTS_EU_Contact_populateCallDates
{
    
    Map <id, date> mapConIdDate = new Map<id, Date>();
    Map <ID, List<Attendee__C>> mapCallAttendees = new Map<ID, List<Attendee__C>>();
    Map <id, id> mapAttcon = new Map<id, id>();
    List<Contact> listCon = new List<Contact>();
    LIst <Attendee__C> listAttendee = new List<Attendee__C>();
    List <Attendee__C> listAllAttendee = new List<Attendee__C>();
    
    public void getLastCallDate(List<Call__C> triggerNew){
        
        
        for(CAll__C oCall: [SELECT id FROM CAll__C WHERE ID IN :TriggerNew])
        {
            mapCallAttendees.put(oCall.id,null);
        }
        for(Attendee__C oAtt : [SELECT ZTS_EU_call__C, id ,ZTS_EU_Contact__C FROM Attendee__C WHERE ZTS_EU_call__c in :TriggerNew])
        {
            listAttendee.add(oAtt);
            System.debug('OATT:;;;;'+oAtt);
            List <Attendee__c> newList = mapCallAttendees.get(oAtt.ZTS_EU_call__c);
            if(newList == null)newList = new List<Attendee__C>();
            newList.add(oAtt);
            mapCallAttendees.put(oAtt.ZTS_EU_call__C, newList);
            mapAttCon.put(oAtt.id, oAtt.ZTS_EU_Contact__C );
        }
        System.debug('listAttendee:;;;;'+listAttendee);
        if(listAttendee.size() >0){
            
            system.debug('mapCallAttendees ::::'+ mapCallAttendees.size());
            listAttendee = [SELECT ZTS_EU_Contact__c FROM Attendee__C WHERE ZTS_EU_Call__c IN :mapCallAttendees.keyset()];
            LIst <id> listConID = new List<id>();
            for(Attendee__c oAtt: listAttendee)
            {
                listConID.add(OAtt.ZTS_EU_Contact__c);
            }
            listAllAttendee = [SELECT id,ZTS_EU_Contact__c from Attendee__C where ZTS_EU_Contact__c IN : listConID];
            List<id> listAttID =  new List<id>();
            for(Attendee__C oAtt1: listAllAttendee)
            {
                listAttID.add(oAtt1.id);
                mapAttCon.put(oAtt1.id, oAtt1.ZTS_EU_Contact__C );
            }
            //Updated SOQL Query to filter only Submitted & Completed Calls - NoorbashaSheik Chanbasha - 11/18/2021 - [SC-008964]
            List <AggregateResult> results = [SELECT ZTS_EU_Contact__c con,Max(ZTS_EU_call__r.ZTS_EU_Start_Date_Time__c) date from Attendee__c WHERE ID IN: listAttID AND (ZTS_EU_call__r.ZTS_EU_Status__c= 'Submitted' OR ZTS_EU_call__r.ZTS_EU_Status__c='Completed') Group BY ZTS_EU_Contact__c];
            for(AggregateResult ar: results)
            {
                mapConIdDate.put(String.valueOf(ar.get('con')), Date.valueOF(ar.get('date')));                    
            }                
            for(Call__c oCall: triggerNew)
            {
                for(Attendee__c oAtt : mapCallAttendees.get(oCall.id))
                {
                    Contact oCon = new Contact();
                    oCon.id = mapAttcon.get(oAtt.id);                       
                    if(oCall.ZTS_EU_Start_Date_Time__c > mapConIdDate.get(oCon.id))
                    {                           
                        mapConIdDate.put(oCon.ID, Date.valueOf(oCall.ZTS_EU_Start_Date_Time__c));                            
                    }
                    
                }
            }
            
            for(ID conId : mapConIdDate.keyset()){
                Contact oCon = new Contact(id = conId );
                oCon.ZTS_EU_Last_call_Date__c = mapConIDDate.get(conId );
                listCon.add(oCon);
            } 
            
            try {
                 update(listCon);
            } catch(DmlException dex) {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, 'ZTS_EU_Contact_populateCallDates.getLastCallDate Contact DML error');
            }  
        }
    } 
}