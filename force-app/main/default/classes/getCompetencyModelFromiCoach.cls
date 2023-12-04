public class getCompetencyModelFromiCoach{  


    public static set<String> testABC(List<iCoach_Form__c> lstiCoachForm){

String iCoachFormMarket;
        Map<String,Id> mapCompeGrpAssignWithCompModelId = new Map<String,Id>();
        Set<String> setMarket = new Set<String>();
        //Set<Id> setCompModelId = new Set<Id>();
        //Map<String,set<Id>> mapMarketRoleCompModelIds = new Map<String,set<Id>>();
        Map<string,Id> mapCompModelIdWithiCoachFormId = new Map<string,Id>();
        //Map<Id, Competency__c> mapCompetency = new Map<Id, Competency__c>();      
        //Map<Id,List<Competency__c>> mapCMWithCompetency = new Map<Id,List<Competency__c>>();
        Map<Id,iCoach_Form__c> mapiCoachFormToCompare = new Map<Id,iCoach_Form__c>();
        //Map<Id, List<String>> mapCompIdSkillDTNames = new Map<Id, List<String>>();
        //Map<Id,Data_Translation__c> mapCompIdDataTrans = new Map<Id,Data_Translation__c>();
        //Map<Id,List<Competency__c>> mapBenchmarkWithCompetency = new Map<Id,List<Competency__c>>();
        
        for(iCoach_Form__c objiCF : lstiCoachForm){
            {
                mapiCoachFormToCompare.put(objiCF.Id, objiCF);
                setMarket.add(objiCF.Market__c);                             
            }                
        }
        
        //get all the Competency Group Assignments for benchmark Markets
        iCoachFormMarket = '(\'' + String.join(new List<String>(setMarket), '\',\'') + '\')';
        for(Competency_Group_Assignment__c objCGA : CompetencyGroupAssignSelector.selectByBenchmarkMarket(iCoachFormMarket)){
            mapCompeGrpAssignWithCompModelId.put(objCGA.Id + objCGA.Competency_Group__r.Market__c + objCGA.Competency_Group__r.Role__c,objCGA.Competency_Model__c);
        }
        
        for(iCoach_Form__c objiCoachForm : mapiCoachFormToCompare.values()){
        Map<string,Id> tempMap = new Map<String,Id>(); 
            tempMap = mapKeysContain(mapCompeGrpAssignWithCompModelId, objiCoachForm.Market__c, objiCoachForm.Role__c, objiCoachForm.Id);
            mapCompModelIdWithiCoachFormId.putAll(tempMap);
        }

        System.debug('Comp Model == '+mapCompModelIdWithiCoachFormId.keySet());
        return mapCompModelIdWithiCoachFormId.keySet();
    }


    
    /**
     * @description this methode will return map Competency Model and benchmark for each benchmark
     * @author Kalyan Nayak @ Zoetis Inc | 07-13-2023 
     * @param mapsObject,Market,Role,BenchmarkId
     */
    //Compare Benchmark Market and role with Competency Group Assignment's Competency Group Market and role
    public static Map<String,Id> mapKeysContain(Map<String,Id> mapsObject, String Market, String Role, Id iCoachFormId){
        Set<string> mapKeys = mapsObject.keySet();
        Map<String,Id> mapiCoachFormIdCompModelId = new Map<String,Id>();
        
        for(string obj : mapKeys)
        {
            if(Market != null && Role != null && obj.contains(Market) && obj.contains(Role)){
               String strIds = String.valueOf(mapsObject.get(obj));
               mapiCoachFormIdCompModelId.put(strIds, mapsObject.get(obj));
            }
        }
        return mapiCoachFormIdCompModelId;
    }
}