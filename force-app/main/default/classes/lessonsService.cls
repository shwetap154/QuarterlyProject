/**
Class Name	    : lessonsService
Description	    : Service Class created as part of TPDEV-95 for the Lesson__c object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 04-26-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					    Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao       	04-26-2023   Added Method to update Lessons Status to Reviewed.
*/
public Without Sharing class lessonsService {
    /*     
* @Description : Method to update Lessons Status to Reviewed.
* @Author      : Raut, Pranav Krushnarao @ Zoetis Inc | 04-26-2023
* @param       : Id lessonId
* @return  `   : String URL`
*/
    public static String updateLessonStatusToReviewed(Id lessonId){  
        List<Lesson__c> lstLessons = LessonsSelector.selectByLessonId(lessonId);
        if(lstLessons[0].Lesson_Template__c != null){
            lstLessons[0].Status__c = System.Label.Reviewed;
            update lstLessons;
            return lstLessons[0].Lesson_Template__r.URL__c;  
        }
        else{
            return null;
        } 
    }        
}