/**
Class Name	    : KnowledgeSelector
Description	    : Selector Class created as part of TPDEV-64 for the Knowledge Object. 
Created By		: Sibin Kuriakose
Created Date	: 05-05-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer			Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose	05-05-2023   Added selectByCompSkillIdLang & selectById to Retrive list of Knowledge records
*/
public class LessonTemplateSelector {

    /**     * @Description To Retrive list of Lesson Template records     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
			* @param       List of Competency Id, List of Skill Id, String Containing Language
    */
    public static List<Lesson_Template__c> selectByCompSkillIdLang(List<Id> lstcomps, List<Id> lstskill, String Lang) {
        
        List<Lesson_Template__c> lstavailLessonlang = [SELECT Id,Name,Description__c,URL__c,Language__c,Competency__c,Skill__c,Threshold_Rating__c FROM 
                                                     Lesson_Template__c WHERE ((Competency__c = :lstcomps OR Skill__c = :lstskill) AND Language__c = :Lang)];

        return lstavailLessonlang;
    }

    /**     * @Description To Retrive list of Knowledge records having Id same as RecordId     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023 
			* @param       List of Id
    */
    public static List<Lesson_Template__c> selectById(List<Id> recId) {
        
        List<Lesson_Template__c> lstlesstemplate = [SELECT Id,Name,Description__c,URL__c,Competency__c,Skill__c FROM Lesson_Template__c WHERE Id = :recId];

        return lstlesstemplate;
    }
}