/**
 * Selector class for Lessons
 * @author Ethan Hirsch @ Zoetis Inc
 * @since 03-03-2023
 * Modifications Log
 * Ver   Date         Author                                 Modification
 * 1.0   03-03-2023   Ethan Hirsch @ Zoetis Inc              Initial Version with selectByObservedCompetencyCompetency
 * 2.0   04-26-2023   Raut, Pranav Krushnarao @ Zoetis Inc   Added method selectByLessonId to retrive lesson by ID.
 * 3.0   05-05-2023   Sibin Kuriakose                        Added method selectByListObservedCompetency, selectByLessonTemplate & selectByListLessonId
 * 4.0   05-30-2023   Padma Nerella @ Zoetis Inc             Add Set of benchmarkId as a parameter selectByObservedCompetencyCompetencyAndBenchmark method 
 *                                                           to avoid duplicate lessonsTPDEV-1172                                                           
 */
public inherited sharing class LessonsSelector {
    /**
     * Retrieve Lessons by the Observed Competency's related Competency Id and set of benchmarkId
     * @param competencyIds 
     * @return  `List<Lesson__c>`
     */
    public static List<Lesson__c> selectByObservedCompetencyCompetencyAndBenchmark(Set<Id> competencyIds, Set<Id> benchmarkIds) {
        return  [
            SELECT Id, Lesson_Template__r.Name, Lesson_Template__r.Description__c, Observed_Competency__r.Competency__c, URL__c,Observed_Competency__r.Observation__r.Benchmark__c
            FROM Lesson__c
            WHERE Observed_Competency__r.Competency__c in: competencyIds and Observed_Competency__r.Observation__r.Benchmark__c=:benchmarkIds];
    }
    
      /*
     * @Description :Retrieve Lessons by the Lesson's Id
     * @param  		: Id lessonId 
     * @return      :`List<Lesson__c>`
     */
    public static List<Lesson__c> selectByLessonId(Id lessonId) {
        return  [
            SELECT Id,Status__c,Lesson_Template__c,Lesson_Template__r.URL__c
            FROM Lesson__c
            WHERE Id =: lessonId];
    }

    /**
     * Retrieve Lessons by the Observed Competency's Id
     * @param competencyIds 
     * @return  `List<Lesson__c>`
     */
    public static List<Lesson__c> selectByListObservedCompetency(List<Observed_Competency__c> lstobscomp) {
        List<Lesson__c> lstLessonbench =  [SELECT Id,Name,Description__c,URL__c,Lesson_Template__c,Observed_Competency__c,
                                          Observed_Competency__r.Id,Observed_Competency__r.Skill__r.Id,Observed_Competency__r.Skill__r.Name,
                                          Observed_Competency__r.Competency__r.Id,Observed_Competency__r.Competency__r.Name FROM Lesson__c WHERE 
                                          Observed_Competency__c = :lstobscomp];

        return lstLessonbench;

    }

    /**
     * Retrieve Lessons by the Observed Competency's Id
     * @param competencyIds 
     * @return  `List<Lesson__c>`
     */
    public static List<Lesson__c> selectByLessonTemplateBench(List<Lesson_Template__c> lsttemplessonLang, List<Id> benchmark) {
        List<Lesson__c> lstLessonbench = [SELECT Id,Name,Description__c,URL__c,Lesson_Template__c,Observed_Competency__c,Observed_Competency__r.Id,Observed_Competency__r.Skill__r.Id,
                         Observed_Competency__r.Skill__r.Name,Observed_Competency__r.Competency__r.Id,Observed_Competency__r.Competency__r.Name FROM Lesson__c WHERE 
                         Lesson_Template__c = :lsttemplessonLang AND Observed_Competency__r.Observation__r.Benchmark__c = :benchmark];

        return lstLessonbench;

    }

    
    /*
     * @Description :Retrieve Lessons by List of Lesson's Id
     * @param  		: List<Id> delrecId
     * @return      :`List<Lesson__c>`
     */
    public static List<Lesson__c> selectByListLessonId(List<Id> delrecId) {
        List<Lesson__c> lstfnltempdelLessons = [SELECT Id FROM Lesson__c WHERE Id = :delrecId];
        return lstfnltempdelLessons;
    }
}