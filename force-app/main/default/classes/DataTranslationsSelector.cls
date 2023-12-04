/**
@description    : Selector Class for DataTranslations 
Created By      : Suprabha Acharya @ Zoetis Inc
Created Date    : 02-13-2023
Modification Log:
----------------------------------------------------------------------------
Developer            Date        Description
Suprabha Acharya    02-13-2023    Added selectDataTransBySkill method to get data translation by Skills
Kalyan Nayak        02-13-2023    Added selectDataTransByCompetency method to get data translation
Ethan Hirsch        04-10-2023    Added selectDataTransByCompetencyModelIdsAndLocales method
----------------------------------------------------------------------------
*/

public With Sharing class DataTranslationsSelector {
    
    /**
     * @description this methode will select data traslation by Skill 
     * @author Suprabha Acharya @ Zoetis Inc | 02-13-2023 
     * @param BenchmarkList
    */
    /*public static List<Data_Translation__c> selectDataTransBySkill(set<String> Languageset,set<Id> Competencyset,set<Id> Skillset){
        List<Data_Translation__c>Dtlist=[select ID,Skill__c,Competency__c,Language__c FROM Data_Translation__c WHERE  (Skill__c IN:skillset OR Competency__c IN:Competencyset) AND Language__c IN:Languageset ] ;
        return Dtlist;

    }*/
        public static List<Data_Translation__c> selectDataTransBySkill(set<Id> Competencyset,set<Id> Skillset){
        List<Data_Translation__c>Dtlist=[select ID,Skill__c,Competency__c,Language__c FROM Data_Translation__c WHERE  (Skill__c IN:skillset OR Competency__c IN:Competencyset)] ;
        return Dtlist;

    }
    
    /**
     * @description this methode will select data traslation for all the competencies for the current logged in user 
     * @author Kalyan Nayak @ Zoetis Inc | 02-13-2023 
     * @param BenchmarkList
    */
    public static List<Data_Translation__c> selectDataTransByCompetency(Set<Id> comIds){
        List<Data_Translation__c> Dtlist = [select ID,Name,Name__c, Skill__c,Competency__c,Language__c FROM Data_Translation__c WHERE Competency__c IN: comIds AND Language__c =: UserInfo.getLanguage()] ;
        return Dtlist;
    }

    /**
     * @description this methode will select data traslation for all the Competencies in the list 
     * @author Sibin kuriaksoe @ Zoetis Inc | 03-14-2023 
     * @param lstComp
    */
    public static List<Data_Translation__c> selectDataTransByCompetencyList(String userLang, List<Competency__c> lstComp){
        List<Data_Translation__c> lstCompTrans = [
                SELECT Id,Name,Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Competency__c
                FROM Data_Translation__c WHERE Language__c = :userLang AND Competency__c = :lstComp];
        
        return lstCompTrans;
    }

    /**
     * @description this methode will select data traslation for all the Skills in the list 
     * @author Sibin kuriaksoe @ Zoetis Inc | 03-14-2023 
     * @param lstSkill
    */
    public static List<Data_Translation__c> selectDataTransBySkillList(String userLang, List<Skill__c> lstSkill){
        List<Data_Translation__c> lstSkillTrans = [
                SELECT Id,Name,Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Skill__c
                FROM Data_Translation__c WHERE Language__c = :userLang AND Skill__c = :lstSkill];
        
        return lstSkillTrans;
    }

    /**
     * @description This method retrieves Data Translations by Competency Model Id and Language Locale Key
     * @author Ethan Hirsch @ Zoetis Inc | 04-10-2023 
     * @param competencyModelIds
    */
    public static List<Data_Translation__c> selectDataTransByCompetencyModelIdsAndLocales(Set<Id> competencyModelIds, Set<String> languageLocaleKeys) {
        return [
            SELECT Id, Name,Name__c, Competency_Model__c, Language__c
            FROM Data_Translation__c
            WHERE Language__c in: languageLocaleKeys
            AND Competency_Model__c in: competencyModelIds];
    }
}