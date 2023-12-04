/**
* @description       : 
* @author            : Sweta Kumari @ Zoetis Inc
* @group             : 
* @last modified on  : 11-11-2023
* @last modified by  : Sweta Kumari @ Zoetis Inc
* Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Sweta Kumari		11-09-2023	Created methods to createEditiCoachFormObjective and return the values to JS in LWC
----------------------------------------------------------------------------
**/

public with sharing class createEditiCoachFormObjectiveController {
    
    @AuraEnabled(cacheable=true)
    public static List<iCoach_Form_Objective__c> getiCoachObjectiveReleatediCoachForm(String ObjectiveId) {
        List<iCoach_Form_Objective__c> objectiveList =iCoachFormObjectiveSelector.getiCoachFormObjective(ObjectiveId);
        if(objectiveList.isEmpty()) {
            throw new AuraHandledException('Record Not Found');
        }
        return objectiveList;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPreviousScore(String recordId, String competencyModalId, String competencyId, String skillId){
        Map<String, String> output = new Map<String, String>();
        if(recordId != null){
            iCoach_Form__c rec = [SELECT Id, Previous_iCoach_Form__c, Previous_Benchmark__c 
                                  FROM iCoach_Form__c
                                  Where Id = :recordId];
            if(rec.Previous_Benchmark__c != null){
                for(Observed_Competency__c ocRec :[SELECT Id, Observation__c, Competency__c, Skill__c, Score__c 
                                                FROM Observed_Competency__c
                                                Where Observation__r.Benchmark__c = :rec.Previous_Benchmark__c
                                                AND Competency__c = : competencyId
                                                AND Skill__c = :skillId]){
                                                    output.put('previousBenchMarkRating', ocRec.Score__c);
                                                }
            }
            if(rec.Previous_iCoach_Form__c != null){
                for(iCoach_Form_Objective__c iCoachFormObjectiveRec :[SELECT Id, iCoach_Form__c, Competency_Model__c, Competency__c, Skill__c, Rating__c 
                                                                      FROM iCoach_Form_Objective__c
                                                                      Where iCoach_Form__c = :rec.Previous_iCoach_Form__c
                                                                      AND Competency_Model__c = :competencyModalId
                                                                      AND Competency__c = : competencyId
                                                                      AND Skill__c = :skillId]){
                                                                          output.put('previousiCoachFormRating', iCoachFormObjectiveRec.Rating__c);
                                                                      }
            }
        }
        return output;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<compentencyModelWithCompetenciesAndSkills> getCompetencyModels(string iCoachFormId) {
        String iCoachFormMarket;
        Map<Id,string> mapCompeGroupAssignmentWithCompModelId = new Map<Id,string>();
        Map<string,Id> mapCompModelIdWithICoachFormId = new Map<string,Id>(); 
        Map<Id,Data_Translation__c> mapCompIdDataTrans = new Map<Id,Data_Translation__c>();
        map<Id,compentencyModelWithCompetenciesAndSkills> modelWrapper  =  new map<Id,compentencyModelWithCompetenciesAndSkills>();
        set<Id> competencyModelIds = new set<Id>();
        Map<Id,String> mapCompetency = new Map<Id,String>();
        Map<Id,Competency__c> mapCompetencyWithSkill = new Map<Id,Competency__c>();
        List<skillsWrapper> listSkills = new List<skillsWrapper>();
        Map<Id,CompeteciesWrapper> listComWithSkills = new Map<Id,CompeteciesWrapper>();
        List<iCoach_Form__c> getiCoachFormList = iCoachFormSelector.getiCoachFormListId(iCoachFormId);
        
        //get all the Competency Group Assignments for benchmark Markets 
        for(Competency_Group_Assignment__c objCGA : CompetencyGroupAssignSelector.selectByCompeGroupMarketRole(getiCoachFormList[0].Market__c,getiCoachFormList[0].Role__c)){
            mapCompeGroupAssignmentWithCompModelId.put(objCGA.Competency_Model__c,objCGA.Competency_Model__r.Name);
            compentencyModelWithCompetenciesAndSkills cmw = new compentencyModelWithCompetenciesAndSkills();
            cmw.Id = objCGA.Competency_Model__c;
            cmw.competencyModelName = objCGA.Competency_Model__r.Name; 
            modelWrapper.put(objCGA.Competency_Model__c ,cmw);           
        }
        
        for(Data_Translation__c dataTranslation :DataTranslationsSelector.selectDataTransByCompetencyModelIdsAndLocales(mapCompeGroupAssignmentWithCompModelId.keySet(),new Set<String> {getiCoachFormList[0].Coachee__r.LanguageLocaleKey}) )
        {
            if(modelWrapper.containsKey(dataTranslation.Competency_Model__c))
            {
                modelWrapper.get(dataTranslation.Competency_Model__c).competencyModelName = dataTranslation.Name__c ;
            }    
        }
        
        //Get all the Competency with Skills related to Competency Model
        for(Competency__c objCom : CompetenciesSelector.selectByCompetencyModelSet(mapCompeGroupAssignmentWithCompModelId.keySet())){
            mapCompetency.put(objCom.Id,objCom.Name);
            mapCompetencyWithSkill.put(objCom.Id,objCom);
            CompeteciesWrapper com = new CompeteciesWrapper();
            com.Id = objCom.Id;
            com.competencyName = objCom.Name;
            for(Skill__c objSkill : objCom.Skills__r){
                skillsWrapper skill = new skillsWrapper();
                skill.Id = objSkill.Id;
                skill.skillsName = objSkill.Name__c;
                listSkills.add(skill);
            }
            com.skillsList = listSkills;
            listComWithSkills.put(objCom.Id,com);
            
            if(modelWrapper.containsKey(objCom.Competency_Model__c))
            {
                modelWrapper.get(objCom.Competency_Model__c).competencyList = listComWithSkills.values();
            }
        }
        
        for(Skill__c objSkill : SkillsSelector.selectSkillsByCompetencyWithCurrentUserTranslations(mapCompetency.keySet(), getiCoachFormList[0].Coachee__r.LanguageLocaleKey)){
            
        }
        for(compentencyModelWithCompetenciesAndSkills obj : modelWrapper.values()){
            System.debug('Check Name::'+ obj.competencyModelName);
            System.debug('Check Competency'+ obj.competencyList);
            for(CompeteciesWrapper objCom : obj.competencyList){
                System.debug('Check Skills'+ objCom.skillsList); 
            }  
        }
        system.debug('model'+modelWrapper.values());
        return modelWrapper.values();            
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Competency__c> getCompetencies(String competencyModelId) {
        
        // List<Competency__c> competencyList=CompetenciesSelector.selectedCompetencyiCoachFormObjective(mapCompeGroupAssignmentWithCompModelId.keySet());        
        //  List<Data_Translation__c> CompetencyDataTranslationList = DataTranslationsSelector.selectDataTransByCompetencyList(user, competencyList);
        List<Competency__c> competencyList = [SELECT Id, Name FROM Competency__c WHERE Competency_Model__c = :competencyModelId];
        
        
        return competencyList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Skill__c> getSkills(String competencyId) {
        List<Skill__c> getSkillList = [SELECT Id,Name, Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Competency__c
                                       FROM Skill__c where Competency__c =:competencyId];
        //SkillsSelector.selectSkillsByCometencyWithCurrentUserTranslationsObjective(competencyId);
        return getSkillList;
    }
    @AuraEnabled
    public static string CreateiCoachFormObjectiveRecord(String payloadForm){
        try{
            system.debug('payloadForm>>' + payloadForm);
            FormObjectiverWrapper formObjective = (FormObjectiverWrapper) JSON.deserialize(
                payloadForm,
                FormObjectiverWrapper.class
            );
            
            iCoach_Form_Objective__c ObjectiveList = new iCoach_Form_Objective__c();
            ObjectiveList.iCoach_Form__c = formObjective.iCoachFormId;
            ObjectiveList.Competency_Model__c = formObjective.CompetencyModel;
            ObjectiveList.Competency__c = formObjective.Competency;
            ObjectiveList.Skill__c = formObjective.skills;
            ObjectiveList.Rating__c = formObjective.Ratingscore;
            ObjectiveList.Comments__c = formObjective.iCoachComments;
            insert ObjectiveList ; 
            system.debug('ObjectiveList'+ObjectiveList);
            
            return ObjectiveList.Id ;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
        
    }  
    
    
    @AuraEnabled
    public static void saveiCoachFormObjectiveRecord(String upsertPayload, String deletePayload){
        if(upsertPayload != null){
            List<iCoach_Form_Objective__c> upsertList = (List<iCoach_Form_Objective__c>) JSON.deserialize(upsertPayload, List<iCoach_Form_Objective__c>.class);
            Upsert upsertList;
        }
        if(deletePayload != null){
            List<iCoach_Form_Objective__c> deleteList = (List<iCoach_Form_Objective__c>) JSON.deserialize(deletePayload, List<iCoach_Form_Objective__c>.class);
            Delete deleteList;
        }
    }
    
    @AuraEnabled
    public static string UpdateiCoachFormObjectiveRecord(String payloadForm){
        try{
            system.debug('payloadForm>>' + payloadForm);
            UpdateFormObjectiverWrapper updateformObjective = (UpdateFormObjectiverWrapper) JSON.deserialize(
                payloadForm,
                UpdateFormObjectiverWrapper.class
            );
            iCoach_Form_Objective__c updateObjectiveList = new iCoach_Form_Objective__c();
            updateObjectiveList.Id = updateformObjective.Id;
            updateObjectiveList.Competency_Model__c = updateformObjective.CompetencyModel;
            updateObjectiveList.Competency__c = updateformObjective.Competency;
            updateObjectiveList.Skill__c = updateformObjective.skills;
            updateObjectiveList.Rating__c = updateformObjective.Ratingscore;
            updateObjectiveList.Comments__c = updateformObjective.iCoachComments;
            Update updateObjectiveList ; 
            system.debug('ObjectiveList'+updateObjectiveList);
            
            return updateObjectiveList.Id ;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
        
    }  
    
    
    @AuraEnabled(cacheable =true)
    public static List<iCoach_Form_Objective__c> getRelatedObjectives(String recorId) 
        
    {
        System.debug('recorId: ' + recorId);
        try{
            List<iCoach_Form_Objective__c> iCoachFormObjectiveList = [select Id,iCoach_Form__c,Competency_Model__c,Competency__c,
                                                                      Skill__c,Comments__c,Rating__c 
                                                                      from iCoach_Form_Objective__c where iCoach_Form__c =:recorId];
            system.debug('iCoachFormObjectiveList'+iCoachFormObjectiveList);
            return iCoachFormObjectiveList;
        }
        catch(Exception e)
        {
            throw new AuraHandledException(e.getMessage());
        }
        
        
        /*   @AuraEnabled(cacheable=true)
public static List<iCoach_Form__c> getAllStatusIcoachForm(Id recordId ) {

List<iCoach_Form__c> getformList =[select id,Previous_iCoach_Form__c,Previous_Benchmark__c from iCoach_Form__c where Id=:recordId ];

List<iCoach_Form_Objective__c>  getobjectiveList = [select Id,iCoach_Form__c,Competency_Model__c,Competency__c,Skill__c,Comments__c,Rating__c from iCoach_Form_Objective__c where iCoach_Form__c=:getformList[0].Previous_iCoach_Form__c and Competency__c= ];
List<Observed_Competency__c> getObservedCompetencyList = [select id,Observation__c,Competency__c,Skill__c,Score__c where Observation__r.Benchmark__c = :getformList[0].Previous_Benchmark__c and Competency__c ]
} */
        
        
        
        
    }
    
    
    
    
    
    
    /*   @AuraEnabled(cacheable=true)
public static List<iCoach_Form__c> getAllStatusIcoachForm(Id recordId ) {
List<iCoach_Form__c> getAllStatusList = [SELECT Id,Name,Status__c FROM iCoach_Form__c where Id=:recordId ];
system.debug('objectiveList'+getAllStatusList);
return getAllStatusList;
}


}

@AuraEnabled(cacheable =true)
public static Boolean getFormList(String recordId) 
{

iCoach_Form__c getForm= [SELECT Id,Name,Status__c FROM iCoach_Form__c WHERE Id = :recordId Limit 1];
if (getForm.Status__c =='Submitted' ||getForm.Status__c =='Completed') {
return true ;  
}
return true ;
}    


@AuraEnabled(cacheable=true) 
public static List<String> getCompetencyModelss(String iCoachFormId) {
List<String> competencyModels = new List<String>();

// Fetch iCoach Form details including Market and Role
iCoach_Form__c form = [SELECT Market__c, Role__c FROM iCoach_Form__c WHERE Id = :iCoachFormId LIMIT 1];
String market = form.Market__c;
String role = form.Role__c;
List<Competency_Group_Assignment__c> assignments = [SELECT Competency_Model__c, Competency_Model__r.Name FROM Competency_Group_Assignment__c
WHERE Competency_Group__r.Market__c INCLUDES (:market) 
AND Competency_Group__r.Role__c INCLUDES (:role) ];
map<id,Competency_Model__c> mapCompentecy = new map<id,Competency_Model__c>();

// Extract unique Competency Models from the assignments
for (Competency_Group_Assignment__c assignment : assignments) {
competencyModels.put(assignment.Competency_Model__c,assignment.Competency_Model__r.Name);
}

return competencyModels;

} 


@AuraEnabled(cacheable=true)
public static List<CompetencyWrapper> getCompetencies(string competencyModelId ) {
String userLang = UserInfo.getLanguage();


List<Competency__c> lstCompetency = [
SELECT Id, Name, Learning_Description__c, Applying_Description__c, Mastery_Description__c
FROM Competency__c where Competency_Model__c = :competencyModelId];

Set<Id> competencyIds = new Set<Id>();
for (Competency__c competency : lstCompetency) {
competencyIds.add(competency.Id);
}



Map<Id, Data_Translation__c> dataTranslationMap = new Map<Id, Data_Translation__c>();
for (Data_Translation__c translation : [
SELECT Id, Name,Competency__c, Learning_Description__c, Applying_Description__c, Mastery_Description__c, Competency__c
FROM Data_Translation__c
WHERE Language__c = :userLang AND Competency__c IN :competencyIds])
{
dataTranslationMap.put(translation.Competency__c, translation);
}

List<CompetencyWrapper> competencyWrappers = new List<CompetencyWrapper>();
for (Competency__c competency : lstCompetency) {
Data_Translation__c translation = dataTranslationMap.get(competency.Id);
competencyWrappers.add(new CompetencyWrapper(competency, translation));
}
system.debug('competencyWrappers'+competencyWrappers);
return competencyWrappers;
}



public class CompetencyWrapper {
public Competency__c competency { get; private set; }
public Data_Translation__c translation { get; private set; }

public CompetencyWrapper(Competency__c competency, Data_Translation__c translation) {
this.competency = competency;
this.translation = translation;
}
}
*/
    
    
    
    
    
    
    
    
    
    
    
    
    public class FormObjectiverWrapper{
        
        @AuraEnabled
        public string iCoachFormId;
        @AuraEnabled
        public string CompetencyModel;
        @AuraEnabled
        public string Competency;
        @AuraEnabled
        public string skills;
        @AuraEnabled
        public string Ratingscore;
        @AuraEnabled
        public string iCoachComments;
        
    }
    
    public class UpdateFormObjectiverWrapper{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string CompetencyModel;
        @AuraEnabled
        public string Competency;
        @AuraEnabled
        public string skills;
        @AuraEnabled
        public string Ratingscore;
        @AuraEnabled
        public string iCoachComments;
        
    }
    
    
    
    public class compentencyModelWithCompetenciesAndSkills{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string competencyModelName;
        public List<CompeteciesWrapper> competencyList; 
    }   
    public class CompeteciesWrapper{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string competencyName;
        public List<skillsWrapper> skillsList;  
        
    } 
    
    public class skillsWrapper{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string skillsName;
        
    } 
    
    
}