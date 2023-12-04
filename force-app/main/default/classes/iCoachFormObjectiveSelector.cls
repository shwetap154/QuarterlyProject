/**
* @description       : 
* @author            : Sweta Kumari @ Zoetis Inc
* @group             : 
* @last modified on  : 11-09-2023
* @last modified by  : Sweta Kumari @ Zoetis Inc
* Modification Log:
----------------------------------------------------------------------------
Developer			Date		Description
Sweta Kumari		11-09-2023	Retrieve iCoach Form Objective records by Id
----------------------------------------------------------------------------
**/

public class iCoachFormObjectiveSelector {
    
    public static List<iCoach_Form_Objective__c> getiCoachFormObjective(String ObjectiveId) {
         iCoach_Form_Objective__c objectiveList =[SELECT Id, iCoach_Form__c FROM iCoach_Form_Objective__c where Id =:ObjectiveId LIMIT 1];
        List<iCoach_Form_Objective__c> iCoachFormObjectiveList = [select Id,Name,iCoach_Form__c,iCoach_Form__r.Status__c,Competency_Model__c,Competency__c,Skill__c,Comments__c,Rating__c from iCoach_Form_Objective__c where iCoach_Form__c =:objectiveList.iCoach_Form__c order by Name ASC];
        system.debug(iCoachFormObjectiveList);
         return iCoachFormObjectiveList;
  
}
    public static iCoach_Form_Objective__c getiCoachFormObjectiveIdInEdit(String ObjectiveId) {
         iCoach_Form_Objective__c getObjectiveList =[SELECT Id,Competency_Model__c, iCoach_Form__c,Competency__c,Skill__c,Comments__c,Rating__c FROM iCoach_Form_Objective__c where Id =:ObjectiveId]; 
        system.debug('getObjectiveList' +getObjectiveList);
        return getObjectiveList ;
    }
        
    
    
    

}