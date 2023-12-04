/*************************************************************************************************************************
  Class Name     : ZTS_EU_KOL_UpdateContact
  Description    : This is an utility class to provide common services.
  Created By     : Sunil Kumar
  Created On     : 03/13/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Sunil Kumar    03/13/2014              Created

***************************************************************************************************************************/
public class ZTS_EU_KOL_UpdateContact{
      /*****************************************
    VARIABLES
    ******************************************/
    public Set<ID> conKOLId = new Set<ID>();
    public Set<ID> conKOLSpeakerId = new Set<ID>();
    public List<Contact> kolConList = new List<Contact>();
    Set<Id> KOL_NonSpeaker =new Set<Id>();
    Set<Id> KOL_Speaker =new Set<Id>();
    public List<ZTS_EU_KOL__c> kolSpealList = new List<ZTS_EU_KOL__c>();
    
   /***********
        * Method name  : UpdateKOLandSpeakerFlag
        * Description  : Update KOL and Speaker flag on contact whenever a kol is created.
        * Return Type  : None.
        * Parameters   : List.
    ***********/
        
    public void UpdateKOLandSpeakerFlag(List<ZTS_EU_KOL__c> kolList){
    
        for(ZTS_EU_KOL__c kol : kolList){     
             
            conKOLId.add(kol.ZTS_EU_Contact__c);
            if(kol.ZTS_EU_Speaker__c == false){          
               KOL_NonSpeaker.add(kol.ZTS_EU_Contact__c);
           }
            if (kol.ZTS_EU_Speaker__c == true){
               KOL_Speaker.add(kol.ZTS_EU_Contact__c);
           }
          
        }
         Map < Id, Contact > contactMap = new Map < Id, Contact > ();
         
       for(Contact con : [Select id,ZTS_EU_KOL_Flag__c,ZTS_EU_Speaker_Flag__c from contact where id in : conKOLId AND ZTS_EU_Market__c != 'United States']){
            if(!con.ZTS_EU_KOL_Flag__c && KOL_NonSpeaker.contains(con.id)){
                con.ZTS_EU_KOL_Flag__c = true;          
                 contactMap.put(con.id, con);
            }
            if(!con.ZTS_EU_Speaker_Flag__c && KOL_Speaker.contains(con.id)){
                con.ZTS_EU_Speaker_Flag__c = true;
                con.ZTS_EU_KOL_Flag__c = true; 
                contactMap.put(con.id, con);
            }
       }
       try{
           kolConList.addall(contactMap.values());
           Database.update(kolConList, false);
       }catch(Exception e){
            system.debug('Exception'+e);
       }
    }
     /***********
        * Method name  : UpdateSpeakerFlag
        * Description  : Update Speaker flag on contact whenever a kol is updated.
        * Return Type  : None.
        * Parameters   : List.
    ***********/
    
    public void UpdateSpeakerFlag(List<ZTS_EU_KOL__c> kolList){
        
        Map<Id,List<ZTS_EU_KOL__c>> mapIdKol = new Map<Id,List<ZTS_EU_KOL__c>>();
        
        for(ZTS_EU_KOL__c kol : kolList){
            conKOLSpeakerId.add(kol.ZTS_EU_Contact__c);
        }
        
        kolSpealList = [select id,ZTS_EU_Speaker__c,ZTS_EU_Contact__c from ZTS_EU_KOL__c where ZTS_EU_Contact__c In : conKOLSpeakerId and ZTS_EU_Speaker__c = true AND ZTS_EU_Market__c != 'United States'];
        for(ZTS_EU_KOL__c kol : kolSpealList){
            if(mapIdKol.containskey(kol.ZTS_EU_Contact__c)){
                mapIdKol.get(kol.ZTS_EU_Contact__c).add(kol);
            }
            else{
                List<ZTS_EU_KOL__c> kolInternalList = new List<ZTS_EU_KOL__c>();
                kolInternalList.add(kol);
                mapIdKol.put(kol.ZTS_EU_Contact__c,kolInternalList);
            }
        }         
        
        for(Contact con : [Select id,ZTS_EU_KOL_Flag__c,ZTS_EU_Speaker_Flag__c from contact where id in : conKOLSpeakerId AND ZTS_EU_Market__c != 'United States']){
            if(mapIdKol.containskey(con.id)){
                con.ZTS_EU_Speaker_Flag__c = true;
                kolConList.add(con);
            }
            else{
                con.ZTS_EU_Speaker_Flag__c = false;
                kolConList.add(con);
            }
        }
        try{
            Database.update(kolConList);
        }catch(Exception e){
             system.debug('Exception'+e);
        }       
        
    }
     /***********
        * Method name  : checkKOLRecordsOnContact
        * Description  : Check if a contact has KOL records or not.
        * Return Type  : None.
        * Parameters   : List.
    ***********/
    public void checkKOLRecordsOnContact(List<ZTS_EU_KOL__c> kolListDetail){
        Set<ID> conId = new Set<ID>();
        Set<ID> conListDel = new Set<Id>();
        Map<Id,List<ZTS_EU_KOL__c>> mapIdKol = new Map<Id,List<ZTS_EU_KOL__c>>();
        List<Contact> conListUpdate = new List<Contact>();
        Map < Id, Contact> conMap = new Map < Id, Contact> ();
        if(kolListDetail != null && kolListDetail.size() > 0){
          for(ZTS_EU_KOL__c kol : kolListDetail){
            conId.add(kol.ZTS_EU_Contact__c);
         }
      }
      List <ZTS_EU_KOL__c> kolList = [select id,ZTS_EU_Speaker__c,ZTS_EU_Contact__c from ZTS_EU_KOL__c where ZTS_EU_Contact__c In : conId AND ZTS_EU_Market__c != 'United States' ];
      for(ZTS_EU_KOL__c kol : kolList){
         if(mapIdKol.containskey(kol.ZTS_EU_Contact__c)){
           mapIdKol.get(kol.ZTS_EU_Contact__c).add(kol);
        }
        else{
            List<ZTS_EU_KOL__c> kolInternalList = new List<ZTS_EU_KOL__c>();
            kolInternalList.add(kol);
            mapIdKol.put(kol.ZTS_EU_Contact__c,kolInternalList);
        }
      }
      
      for( Contact co:[Select id,ZTS_EU_KOL_Flag__c,ZTS_EU_Speaker_Flag__c from contact where id in : conId AND ZTS_EU_Market__c != 'United States']){
        boolean isSpeakerRole = false;      
        if(mapIdKol.containskey(co.id)){           
            for (ZTS_EU_KOL__c kol: mapIdKol.get(co.id)) {
                if(kol.ZTS_EU_Speaker__c == true){
                    isSpeakerRole = true;
                }
            }
            if(isSpeakerRole ==  false && co.ZTS_EU_Speaker_Flag__c == true){
                co.ZTS_EU_Speaker_Flag__c = false;
                conMap.put(co.id,co);
            }            
        }
        else{
            co.ZTS_EU_KOL_Flag__c = false;
            co.ZTS_EU_Speaker_Flag__c = false;
            conMap.put(co.id,co);
        }
      }
       try{
            conListUpdate.addall(conMap.values());
            Database.update(conListUpdate, false);
       }catch(Exception e){
             system.debug('Exception'+e);
       }
    }
    
}