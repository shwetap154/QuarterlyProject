public class BuildQueryString {
    public static Set<String> getTerritoryNameSet(){
        //get Territory names from metadata
        Map<String, Call_Reminder_Territories__mdt> userTerritoryMetaData = Call_Reminder_Territories__mdt.getAll();
        Set<String> territoryNameSet= new Set<String>();
               
        //collect all the territory names from custom metadata and store in territoryNameSet
        for(string territoryName : userTerritoryMetaData.keyset()){
            territoryNameSet.add(userTerritoryMetaData.get(territoryName).Label);
        }     
        system.debug('territory names are:' +territoryNameSet);
        
        return territoryNameSet;
    }
}