Global with sharing class ZTS_EU_createAccountPosition {
    public static void createAccountPosition(List <ZTS_EU_Position__c> PosList, List < ZTS_AccountTerritory__c > accTerrList) {
        
        Map < Id, List < ZTS_AccountTerritory__c >> terrAccMap = new Map < Id, List < ZTS_AccountTerritory__c >> ();
        
        for (ZTS_AccountTerritory__c accTerr: accTerrList){
            	if (accTerr.ZTS_EU_Territory__c != null){
                        if (!terrAccMap.containsKey(accTerr.ZTS_EU_Territory__c)) 
                            terrAccMap.put(accTerr.ZTS_EU_Territory__c, new List < ZTS_AccountTerritory__c > ());
                        terrAccMap.get(accTerr.ZTS_EU_Territory__c).add(accTerr);
                    }            
        	}
        
        Set < ZTS_EU_Account_Position__c > acc_pos_set = new Set < ZTS_EU_Account_Position__c > ();
        List<ZTS_EU_Position__c> updPosProcessFlagList=new List<ZTS_EU_Position__c>();

        for (ZTS_EU_Position__c postn : PosList) 
        {
            if (postn.ZTS_EU_Territory__c != null && terrAccMap.containsKey(postn.ZTS_EU_Territory__c)) 
            {   
                for (ZTS_AccountTerritory__c accTerr: terrAccMap.get(postn.ZTS_EU_Territory__c)) 
                {
                    if (accTerr.ZTS_EU_Account__c != null) 
                    {
                        String acc_position_key = accTerr.ZTS_EU_Account__c + ':'+postn.id;
                        ZTS_EU_Account_Position__c acc_pos = new ZTS_EU_Account_Position__c(
                            									ZTS_EU_Account__c = accTerr.ZTS_EU_Account__c, 
                            									ZTS_EU_Position__c = postn.id,
                                                        		ZTS_AccountUserTerrUniqueKey__c = acc_position_key, 
                            									ZTS_AccountTerritory__c = accTerr.id);
                        
                        acc_pos_set.add(acc_pos);
                    }
                }

            }
            if(!postn.ZTS_Processed__c)
              updPosProcessFlagList.add(new ZTS_EU_Position__c(id=postn.id,ZTS_Processed__c=true));
            
            
        }
        
        //Ap to be upserted
        for ( ZTS_EU_Account_Position__c ap1: acc_pos_set ){
            system.debug('Ap to be upserted'+ap1);
        }
        
        //position to be updated
        for ( ZTS_EU_Position__c p1: updPosProcessFlagList ){
            system.debug('position to be updated'+p1);
        }
        
        
            List < Database.Upsertresult > results = Database.upsert(new List<ZTS_EU_Account_Position__c> (acc_pos_set), Schema.ZTS_EU_Account_Position__c.ZTS_AccountUserTerrUniqueKey__c, false);
            List<Database.Saveresult> updResults=Database.update(updPosProcessFlagList,false);
            //ZTS_US_Logger.error(results, 'ZTS_TerritoryManager-createAccountTeams-UserTerr');
            //ZTS_US_Logger.error(updResults,'ZTS_TerritoryManager-createAccountTeams-UserTerr-ProcessFlagUpdate');
        
        
        
    }

}