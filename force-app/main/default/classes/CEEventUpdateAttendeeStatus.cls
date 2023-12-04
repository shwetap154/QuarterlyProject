public class CEEventUpdateAttendeeStatus {
    
    public List<conWrapper> wrpConList{get;set;} 
    public ZTS_Events__c eventRec{get;set;}
    public boolean selectAllVar {get;set;}
    public String newStatus {get;set;}
    
    
    public CEEventUpdateAttendeeStatus(ApexPages.StandardController controller) {
        wrpConList = new List<conWrapper>();
        eventRec = (ZTS_Events__c)controller.getRecord();
        //evntId = [select id, Name from ZTS_Events__c where id=: eventRec.id AND ZTS_EU_Market__c = 'United States'];
        //String eventId = ApexPages.currentPage().getParameters().get('eventId');
        for(ZTS_US_Event_Invitee__c e : [SELECT Id, ZTS_US_Invitation_Status__c,ZTS_US_Contact__c,ZTS_US_Event_Invitee_Email__c, ZTS_US_Event_Invitee_Mailing_State__c, ZTS_US_Event_Invitee_Mailing_Zip_Postal__c, ZTS_US_Event_Invitee_Mailing__c, ZTS_US_Event_Invitee_Last_Name__c, ZTS_US_Event_Invitee_First_Name__c FROM ZTS_US_Event_Invitee__c
                   WHERE ZTS_US_Event__c = :eventRec.id
                     AND ZTS_EU_Market__c = 'United States']){
            wrpConList.add(new conWrapper(e));    
        } 
        
    }
    
    
    public class conWrapper{
        public ZTS_US_Event_Invitee__c evtInv{get;set;}
        public boolean isSelected{get;set;}
        
        public conWrapper(ZTS_US_Event_Invitee__c e){
            evtInv = e;
            isSelected = false;
        }
    }
   
    public PageReference selectAll(){
        System.debug('...shiva..' + selectAllVar);
        for(conWrapper w : wrpConList){
            w.isSelected = selectAllVar; 
        }
        Integer x = 0;
        for(conWrapper w : wrpConList){
            
            System.debug(x + '...shiva..' + w.isSelected);
            ++x;
        }
       return null;
    }
    
    public pageReference updateStatus(){
        if(wrpConList == null || wrpConList.size() <= 0){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No records to update'));
            return null;
        }
        List<ZTS_US_Event_Invitee__c> listToUpdate = new List<ZTS_US_Event_Invitee__c>();
        boolean flag = false;
        for(conWrapper w : wrpConList){
            if(w.isSelected){
                System.debug('....shivak ...' + newStatus   ); 
                w.evtInv.ZTS_US_Invitation_Status__c = newStatus;
                listToUpdate.add(w.evtInv);
                flag = true;
            }   
        }
        if(flag){
            update listToUpdate;
        }else{
            flag = false;
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No rows selected'));
        }
        return null;
    }
    public pageReference cancelAction(){
        return new pageReference('/'+eventRec.Id);    
    }
    
 
}