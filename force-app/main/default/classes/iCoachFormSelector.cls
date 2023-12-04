public class iCoachFormSelector {
    
    public static List<iCoach_Form__c> getiCoachFormListId(string iCoachFormId )
    {
      List<iCoach_Form__c> getiCoachFormList =[select id, Name,Coachee__c,Coachee__r.LanguageLocaleKey, Market__c,Role__c, Previous_iCoach_Form__c,Previous_Benchmark__c from iCoach_Form__c  where Id =:iCoachFormId];
       
        return getiCoachFormList;
    }
}