/**
* @description       : This is the service class for CompetenciesService
* @author            : Kalyan Nayak @ Zoetis Inc
* @group             : 
* @last modified on  : 02-08-2023
* @last modified by  : Kalyan Nayak @ Zoetis Inc
* Ver   Date         Author                      Modification
* 1.0   02-10-2023   Kalyan Nayak @ Zoetis Inc   TPdev-58 Core Competency Skills
* 2.0	07-13-2023	 Kalyan Nayak @ Zoetis Inc	 TPDEV-1176 - To return a map of Benchmark with all the related competencies available
**/
public With Sharing class CompetenciesService {
    
    /**
     * @description this methode will get a list of competencies for a Benchmark 
     * @author Kalyan Nayak @ Zoetis Inc | 02-08-2023 
     * @param BenchmarkList
     */
    public static Map<Id, List<Competency__c>> getCompetenceList(List<Benchmark__c> BenchmarkList)
    {
        String benchmarkMarket;
        Map<String,Id> mapCompeGrpAssignWithCompModelId = new Map<String,Id>();
        Set<String> setMarket = new Set<String>();
        Set<Id> setCompModelId = new Set<Id>();
		Map<String,set<Id>> mapMarketRoleCompModelIds = new Map<String,set<Id>>();
        Map<string,Id> mapCompModelIdWithBenchmarkId = new Map<string,Id>();
        Map<Id, Competency__c> mapCompetency = new Map<Id, Competency__c>();      
        Map<Id,List<Competency__c>> mapCMWithCompetency = new Map<Id,List<Competency__c>>();
        Map<Id,Benchmark__c> mapBenchmarkToCompare = new Map<Id,Benchmark__c>();
        Map<Id, List<String>> mapCompIdSkillDTNames = new Map<Id, List<String>>();
        Map<Id,Data_Translation__c> mapCompIdDataTrans = new Map<Id,Data_Translation__c>();
        Map<Id,List<Competency__c>> mapBenchmarkWithCompetency = new Map<Id,List<Competency__c>>();
        
        for(Benchmark__c objBenchmark : BenchmarkList){
            {
                mapBenchmarkToCompare.put(objBenchmark.Id, objBenchmark);
                setMarket.add(objBenchmark.Market__c);                             
            }                
        }
        
        //get all the Competency Group Assignments for benchmark Markets
        benchmarkMarket = '(\'' + String.join(new List<String>(setMarket), '\',\'') + '\')';
        for(Competency_Group_Assignment__c objCGA : CompetencyGroupAssignSelector.selectByBenchmarkMarket(benchmarkMarket)){
            mapCompeGrpAssignWithCompModelId.put(objCGA.Id + objCGA.Competency_Group__r.Market__c + objCGA.Competency_Group__r.Role__c,objCGA.Competency_Model__c);
        }
        
        for(Benchmark__c objBench : mapBenchmarkToCompare.values()){
		Map<string,Id> tempMap = new Map<String,Id>(); 
            tempMap = mapKeysContain(mapCompeGrpAssignWithCompModelId, objBench.Market__c, objBench.Role__c, objBench.Id);
            mapCompModelIdWithBenchmarkId.putAll(tempMap);
        }
        
        //get All Comopetencies for each Competency Model
        List<Competency__c> lstCompetency = CompetenciesSelector.selectByCompetencyModelSet(new Set<Id>(mapCompModelIdWithBenchmarkId.values()));
        mapCompetency = new Map<Id, Competency__c>(lstCompetency);
        
        
        //get Translated Skill Names for the competency
        String UserLanguage = UserInfo.getLanguage();
        if(!mapCompetency.isEmpty()){
            String allSkillsDTNames = '';        
            Integer i;
            for(Skill__c objSkill : SkillsSelector.selectSkillsByCompetencyWithCurrentUserTranslations(mapCompetency.keySet(), UserLanguage)){
                if(!mapCompIdSkillDTNames.containsKey(objSkill.Competency__c)){
                    i = 1;
                }
                else{
                    i++;
                }
                if(objSkill.Data_Translations__r != null && !(objSkill.Data_Translations__r).isEmpty()){
                    for(Data_Translation__c objDTSkill : objSkill.Data_Translations__r){
                        allSkillsDTNames = allSkillsDTNames + i+'. '+objDTSkill.Name__c +  '\n'; 
                        
                    }                
                    if(!mapCompIdSkillDTNames.containsKey(objSkill.Competency__c)){
                        mapCompIdSkillDTNames.put(objSkill.Competency__c, new List<String>{allSkillsDTNames});
                        allSkillsDTNames = '';                
                    }
                    else{
                        mapCompIdSkillDTNames.get(objSkill.Competency__c).add(allSkillsDTNames);
                        allSkillsDTNames = '';
                    }   
                }
                else{               
                    if(!mapCompIdSkillDTNames.containsKey(objSkill.Competency__c)){
                        allSkillsDTNames = allSkillsDTNames + i+'. '+objSkill.Name__c +  '\n';                    
                        mapCompIdSkillDTNames.put(objSkill.Competency__c, new List<String>{allSkillsDTNames});
                        allSkillsDTNames = '';
                    }
                    else{
                        allSkillsDTNames = allSkillsDTNames + i+'. '+objSkill.Name__c +  '\n';
                        mapCompIdSkillDTNames.get(objSkill.Competency__c).add(allSkillsDTNames);
                        allSkillsDTNames = '';
                    }
                }            
            }
        }
              
        //Updating the Competency name with Data translation if translations are available
        for(Data_Translation__c objCompDT : DataTranslationsSelector.selectDataTransbyCompetency(mapCompetency.keySet())){
            mapCompIdDataTrans.put(objCompDT.Competency__c,objCompDT);
        }
        
        if(!mapCompetency.isEmpty()){
            for(Competency__c objComp : mapCompetency.values()){
                Competency__c obj = new Competency__c();
                List<Competency__c> listCompetency = new List<Competency__c>();
                obj = objComp;
                if(mapCompIdDataTrans.containsKey(objComp.Id)){
                    obj.Name = mapCompIdDataTrans.get(objComp.Id).Name__c;   
                }
                if(mapCompIdSkillDTNames.containsKey(objComp.Id)){
                    obj.Skill_Names__c = (String.join(mapCompIdSkillDTNames.get(objComp.Id), ',')).remove(',');      
                }
                mapCompetency.put(objComp.Id,obj); 
                
                if(!mapCMWithCompetency.containsKey(objComp.Competency_Model__c)){
                    listCompetency.add(obj);
                    mapCMWithCompetency.put(objComp.Competency_Model__c, listCompetency);
                }
                else{
                    mapCMWithCompetency.get(objComp.Competency_Model__c).add(obj);
                } 
            } 
        }
        
        //Retrun a map for benchmark with all the competencies
        for(Benchmark__c obj : mapBenchmarkToCompare.values()){
            for(string strKey : mapCompModelIdWithBenchmarkId.keySet()){
                if(strKey.contains(obj.Id)){
                    Id cmId = mapCompModelIdWithBenchmarkId.get(strKey);
                    if(!mapBenchmarkWithCompetency.containsKey(obj.Id)){
                        List<Competency__c> listComs = new List<Competency__c>();
                        if(mapCMWithCompetency.containsKey(cmId)){
                            listComs.addall(mapCMWithCompetency.get(cmId));
                            mapBenchmarkWithCompetency.put(obj.Id,listComs);  
                        }
                    }
                    else{
                        mapBenchmarkWithCompetency.get(obj.Id).addAll(mapCMWithCompetency.get(cmId));
                    }
                }
            }
        }
        return mapBenchmarkWithCompetency;
    }
    
    /**
     * @description this methode will return map Competency Model and benchmark for each benchmark
     * @author Kalyan Nayak @ Zoetis Inc | 07-13-2023 
     * @param mapsObject,Market,Role,BenchmarkId
     */
    //Compare Benchmark Market and role with Competency Group Assignment's Competency Group Market and role
    private static Map<String,Id> mapKeysContain(Map<String,Id> mapsObject, String Market, String Role, Id BenchmarkId){
        Set<string> mapKeys = mapsObject.keySet();
        Map<String,Id> mapBenchmarkIdCompModelId = new Map<String,Id>();
        
        for(string obj : mapKeys)
        {
            if(Market != null && Role != null && obj.contains(Market) && obj.contains(Role)){
               String strIds = String.valueOf(mapsObject.get(obj))+String.valueOf(BenchmarkId);
               mapBenchmarkIdCompModelId.put(strIds, mapsObject.get(obj));
            }
        }
        return mapBenchmarkIdCompModelId;
    }
}