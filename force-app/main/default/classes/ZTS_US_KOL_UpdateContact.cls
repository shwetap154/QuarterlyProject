/*************************************************************************************************************************
  Class Name     : ZTS_US_KOL_UpdateContact
  Description    : This is an utility class to provide common services for Contact Speaker/KOL Flag updates.
  	               Update Speaker Flag for Speaker Role and KOL Flag for Influencer Role only when end date is not specified.
  Created By     : Sunil Kumar
  Created On     : 02/26/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Sunil Kumar    02/26/2014              Created
  Deloitte Consulting/Raghu           07/11/2014              Modification on Speaker& KOL-Contact flag based KOL record Roles 
***************************************************************************************************************************/
public class ZTS_US_KOL_UpdateContact {
    /*****************************************
    VARIABLES
    ******************************************/
    public Set < ID > conKOLId = new Set < ID > ();
    public Set < ID > conKOLSpeakerId = new Set < ID > ();
    public List < Contact > kolConList = new List < Contact > ();
    public List < ZTS_EU_KOL__c > kolSpealList = new List < ZTS_EU_KOL__c > ();

    /***********
     * Method name  : UpdateKOLandSpeakerFlag
     * Description  : Update KOL and Speaker flag on contact whenever a kol is created.
     * Return Type  : None.
     * Parameters   : List.
     ***********/

    public void UpdateKOLandSpeakerFlag(List < ZTS_EU_KOL__c > kolList) {
            Set<Id> KOL_InfluencerRoles=new Set<Id>();
            Set<Id> KOL_SpeakerRole=new Set<Id>();
            for (ZTS_EU_KOL__c kol: kolList) {

                if (kol.ZTS_EU_Contact__c  != null) {
                	if (!String.isBlank(kol.ZTS_US_Role__c)){
                     conKOLId.add(kol.ZTS_EU_Contact__c );
                     
                         /** update only for Roles and when enddate not specified */  
	                     if(kol.ZTS_US_Role__c==ZTS_EU_GlobalConstants.KOL_INFLUENCER_ROLE && kol.ZTS_US_End_Date__c==null){
	                     	KOL_InfluencerRoles.add(kol.ZTS_EU_Contact__c );
	                     }
	                     
	                      if(kol.ZTS_US_Role__c==ZTS_EU_GlobalConstants.KOL_SPEAKER_ROLE && kol.ZTS_US_End_Date__c==null){
	                     	KOL_SpeakerRole.add(kol.ZTS_EU_Contact__c );
	                     }
                     
                	}
                }
            }
            
            Map < Id, Contact > contactMap = new Map < Id, Contact > ();
            for (Contact con: [Select id, ZTS_EU_KOL_Flag__c, ZTS_US_Speaker_Flag__c from contact where id in : conKOLId AND ZTS_EU_Market__c = 'United States']) {
            	 if(!con.ZTS_EU_KOL_Flag__c && KOL_InfluencerRoles.contains(con.id)){
                     con.ZTS_EU_KOL_Flag__c = true;
               		 contactMap.put(con.id, con);
            	 }
            	 
            	if(!con.ZTS_US_Speaker_Flag__c && KOL_SpeakerRole.contains(con.id)){
                     con.ZTS_US_Speaker_Flag__c = true;
               		 contactMap.put(con.id, con);
            	 }
            }
            try {
                kolConList.addall(contactMap.values());
				// Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 				Database.DMLOptions dml = new Database.DMLOptions(); 
 				dml.DuplicateRuleHeader.allowSave = true;
 				dml.DuplicateRuleHeader.runAsCurrentUser = true;
                dml.OptAllOrNone = false;
 				List < Database.Saveresult > results = Database.update(kolConList, dml);
                //List < Database.Saveresult > results = Database.update(kolConList, false);-- commented for SC-008149
                ZTS_EU_Logger.error(results, 'ZTS_US_KOL_UpdateContact-UpdateKOLandSpeakerFlag');
            } catch (Exception e) {
                ZTS_EU_Logger.error('Non-DML Exception'+e.getMessage(), null, 'ZTS_US_KOL_UpdateContact-UpdateKOLandSpeakerFlag');
            }
        }
        /***********
         * Method name : KOLUpdates
         * Description : Update KOL and Speaker flag when changes occur on KOL records
         * Return Type : None.
         * Parameters : List.
         ***********/

    public void KOLUpdates(List < ZTS_EU_KOL__c > kolList) {

        Map < Id, List < ZTS_EU_KOL__c >> mapIdKol = new Map < Id, List < ZTS_EU_KOL__c >> ();
  		Map < Id, Contact> conMap = new Map < Id, Contact> ();
  		
        for (ZTS_EU_KOL__c kol: kolList) {
        	if(kol.ZTS_EU_Contact__c !=null){
             conKOLId.add(kol.ZTS_EU_Contact__c );
        	}
        }
        
         /** existing KOL records with no end-date specified **/
        List<ZTS_EU_KOL__c> existing_kolList = [select id, ZTS_US_Speaker_Class__c, ZTS_EU_Contact__c , ZTS_US_Role__c,ZTS_US_End_Date__c from ZTS_EU_KOL__c where ZTS_EU_Contact__c  IN: conKOLId AND ZTS_US_End_Date__c=NULL AND ZTS_EU_Market__c = 'United States'];
        for (ZTS_EU_KOL__c kol: existing_kolList) {
            if (mapIdKol.containskey(kol.ZTS_EU_Contact__c )) {
                mapIdKol.get(kol.ZTS_EU_Contact__c ).add(kol);
            } else {
                List < ZTS_EU_KOL__c > kolInternalList = new List < ZTS_EU_KOL__c > ();
                kolInternalList.add(kol);
                mapIdKol.put(kol.ZTS_EU_Contact__c , kolInternalList);
            }
        }

        for (Contact con: [Select id, ZTS_EU_KOL_Flag__c, ZTS_US_Speaker_Flag__c from contact WHERE ID IN : conKOLId  AND ZTS_EU_Market__c = 'United States']) {
            boolean isSpeakerRole = false;
            boolean isInfluencerRole = false;
            if (mapIdKol.containskey(con.id)) {
                for (ZTS_EU_KOL__c kol: mapIdKol.get(con.id)) {
                    if (kol.ZTS_US_Role__c == ZTS_EU_GlobalConstants.KOL_SPEAKER_ROLE && kol.ZTS_US_End_Date__c==null) {
                        isSpeakerRole = true;
                    }
                    
                    if (kol.ZTS_US_Role__c == ZTS_EU_GlobalConstants.KOL_INFLUENCER_ROLE && kol.ZTS_US_End_Date__c==null) {
                        isInfluencerRole = true;
                    }
                }
                
                /** Speaker Flag update on Contacts **/
                if (isSpeakerRole && !con.ZTS_US_Speaker_Flag__c) {
                    con.ZTS_US_Speaker_Flag__c = true;
                    conMap.put(con.id,con);

                } else if (!isSpeakerRole && con.ZTS_US_Speaker_Flag__c) {
                    con.ZTS_US_Speaker_Flag__c = false;
                    conMap.put(con.id,con);
                }
                
                
                 /** KOL Flag update on Contacts **/
                 if (isInfluencerRole && !con.ZTS_EU_KOL_Flag__c) {
                    con.ZTS_EU_KOL_Flag__c = true;
                    conMap.put(con.id,con);

                } else if (!isInfluencerRole && con.ZTS_EU_KOL_Flag__c) {
                    con.ZTS_EU_KOL_Flag__c = false;
                    conMap.put(con.id,con);
                }

            }
            //NO KOL records exists for contact with role and empty enddate
            else {
            	if(con.ZTS_EU_KOL_Flag__c || con.ZTS_US_Speaker_Flag__c){
            		//clear KOL and Speaker flags
            		con.ZTS_EU_KOL_Flag__c=false;
            		con.ZTS_US_Speaker_Flag__c=false;
            		conMap.put(con.id,con);
            		
            	}
            }
        }
        try {
        	 kolConList.addall(conMap.values());
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 				Database.DMLOptions dml = new Database.DMLOptions(); 
 				dml.DuplicateRuleHeader.allowSave = true;
 				dml.DuplicateRuleHeader.runAsCurrentUser = true;
                dml.OptAllOrNone = false;
 				List < Database.Saveresult > results = Database.update(kolConList, dml);
                //List < Database.Saveresult > results = Database.update(kolConList, false);-- commented for SC-008149
            ZTS_EU_Logger.error(results, 'ZTS_US_KOL_UpdateContact-UpdateSpeakerFlag');
        } catch (Exception e) {
             ZTS_EU_Logger.error('Non-DML Exception'+e.getMessage(), null, 'ZTS_US_KOL_UpdateContact-UpdateSpeakerFlag');
        }

    }

}