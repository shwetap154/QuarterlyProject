/**
Class Name	    : iDevelopNavigateToLessonController
Description	    : Controller Class created as part of TPDEV-95 for the iDevelopNavigateToLesson page. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 04-25-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer			        Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	04-25-2023   Added Methods to Navigate user to URL of Lesson's Lesson Template Record 
*/

public Without Sharing class iDevelopNavigateToLessonController {
    //public Id lessonId {get; set;}
    
	//Constructor   
    public iDevelopNavigateToLessonController(){
        
    }
    
/*
* @Description : Method to Navigate the user to URL of Lesson's Lesson Template Record
* @Author      : Raut, Pranav Krushnarao @ Zoetis Inc | 04-26-2023  
* @return  `   : PageReference`
*/    
    public PageReference iDevelopNavigateToLesson(){
        Id lessonId = Id.valueOf(ApexPages.CurrentPage().getparameters().get('lessonId'));
        String lessonTemplateURL = lessonsService.updateLessonStatusToReviewed(lessonId);
        if(String.isNotEmpty(lessonTemplateURL)){
            PageReference page = new PageReference(lessonTemplateURL);
            page.setRedirect(true);
            return page;
        }  
        else{
            return null;
        }
    }    
}