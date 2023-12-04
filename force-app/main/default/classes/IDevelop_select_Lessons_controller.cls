/**
Class Name	    : IDevelop_select_Lessons_controller
Description	    : Controller Class created as part of TPDEV-64 for the IDevelop_select_Lessons Flow. 
Created By		: Sibin Kuriakose
Created Date	: 05-05-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				05-05-2023	 Created methods to Select applicable Lessons and return the values to JS in LWC
*/

public With Sharing class  IDevelop_select_Lessons_controller {

    
    // Child Wrapper Class
    public class WrapLesson {
        @AuraEnabled
        public Id recordId {get; set;}
        @AuraEnabled
        public Boolean checked {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String url {get; set;}
        @AuraEnabled
        public String ObsCompId {get; set;}

        public WrapLesson(Id recID, String strname, String strdesc, String strurl, Boolean check, Id ObsComp) {
            recordId = recID;
            checked = check;
            name = strname;
            description = strdesc;
            url = strurl;
            ObsCompId = ObsComp;
        }
    }

    // Parent Wrapper Class
    public class WrapFnlCompLesson {
        @AuraEnabled
        public String strcompskill {get; set;}
        @AuraEnabled
        public List<WrapLesson> lstcompLesson {get; set;}
        
        public WrapFnlCompLesson(String strtempcompskill, List<WrapLesson> lstlesson) {
            lstcompLesson = lstlesson;
            strcompskill = strtempcompskill;
        }
    }

    public List<WrapFnlCompLesson> wrapLessonList {get; set;}
    public List<WrapLesson> WrapLesson {get; set;}

    /**     * @Description As part of TPDEV-64 this method will get the list of Lessons along with translations       
			* @Author      Sibin Kuriakose @ Zoetis Inc | 05-05-2023
    */
    @AuraEnabled(cacheable=true)
    public static List<WrapFnlCompLesson> getRecommendedLessons(List<Observed_Competency__c> lstObscomprecords, List<Benchmark__c> lstBenchmark, List<User> lstUser) {

        //Initializing Main variables
        List<WrapFnlCompLesson> wrpFnlLesson = new List<WrapFnlCompLesson>();
        Boolean check = false;
        List<Lesson__c> lstLessonbench = new List<Lesson__c>();
        Id temprecId;
        String name;
        String description;
        String url;
        Id ObsCompId;
        
        if(lstBenchmark.size() > 0){
            List<Observed_Competency__c> lstobscomp = ObservedCompetenciesSelector.selectByListBenchmarks(lstBenchmark);
            lstLessonbench = LessonsSelector.selectByListObservedCompetency(lstobscomp);
            Map<Id,String> mapcompskillname = getCompSkillName(lstobscomp);
        
            for(Observed_Competency__c temoobscomp : lstobscomp){
                List<WrapLesson> wrpLesson = new List<WrapLesson>();
                for (Lesson__c templesson : lstLessonbench){
                    if(temoobscomp.Competency__c == templesson.Observed_Competency__r.Competency__r.Id && temoobscomp.Skill__c == templesson.Observed_Competency__r.Skill__r.Id && temoobscomp.Id == templesson.Observed_Competency__c){
                        temprecId = templesson.Id;
                        name = templesson.Name;
                        description = templesson.Description__c;
                        url = templesson.URL__c;
                        check = true;
                        ObsCompId = temoobscomp.Id;
                        wrpLesson.add(new WrapLesson(temprecId,name,description,url,check,ObsCompId));  
                    }
                } 
                if(wrpLesson.size() > 0){
                    String strfnlname = mapcompskillname.get(temoobscomp.Id);
                    wrpFnlLesson.add(new WrapFnlCompLesson(strfnlname,wrpLesson));
                }
            }
            
        }
        else {
            //Selecting Coachee Language
            List<Id> lstUserId = new List<Id>();
            for(User tempusr : lstUser){
                lstUserId.add(tempusr.Id);
            }
            List<User> userdetail = UsersSelector.selectUserMarketsLangById(lstUserId);
            String coacheeLang = userdetail[0].LanguageLocaleKey;
            List<Id> lstcomps = new List<Id>();
            List<Id> lstskill = new List<Id>();
            for(Observed_Competency__c tempobscomp : lstObscomprecords){
                if(String.isBlank(tempobscomp.Skill__c)){
                    lstcomps.add(tempobscomp.Competency__c);
                }
                else {
                    lstskill.add(tempobscomp.Skill__c);
                }
            }

            //Getting Competency and Skill Details
            List<Observed_Competency__c> lstobscomp = ObservedCompetenciesSelector.selectByListObservedCompetecy(lstObscomprecords);

            Id benchmark = lstobscomp[0].Observation__r.Benchmark__c;
            List<Id> lstBenchmarkId = new List<ID>();
            lstBenchmarkId.add(benchmark);

            Map<Id,String> mapcompskillname = getCompSkillName(lstobscomp);
            String strlang = 'en_US';

            //Selecting available Lesson tempalates related to Competencies and Skills
            List<Lesson_Template__c> lstavailLessonEng = LessonTemplateSelector.selectByCompSkillIdLang(lstcomps,lstskill,strlang);
            
            //Setting up Map to store Lesson Templates
            Map<Id,Lesson_Template__c> mapavailconfig = new Map<Id,Lesson_Template__c>();

            for(Lesson_Template__c temp : lstavailLessonEng){
                String strtemp1 = temp.Competency__c;
                String strtemp2 = temp.Skill__c;
                if(strtemp1 != null){
                    if(!mapavailconfig.containsKey(temp.Competency__c)){
                        mapavailconfig.put(temp.Competency__c, temp);
                    }
                }
                if(strtemp2 != null){
                    if(!mapavailconfig.containsKey(temp.Skill__c)){
                        mapavailconfig.put(temp.Skill__c, temp);
                    }
                }
            }

            //Selecting available Lesson tempalates related to Competencies and Skills in Coachee's Language
            List<Lesson_Template__c> lstavailLessonCoacheLAng = LessonTemplateSelector.selectByCompSkillIdLang(lstcomps,lstskill,coacheeLang); 
            //Removing Entries of Competencies and Skills from English Language whose Local Language Templates are available
            for(Lesson_Template__c temp : lstavailLessonCoacheLAng){
                String strtemp1 = temp.Competency__c;
                String strtemp2 = temp.Skill__c;
                if(strtemp1 != null){
                    if(mapavailconfig.containsKey(temp.Competency__c)){
                        mapavailconfig.remove(temp.Competency__c);
                    }
                }
                if(strtemp2 != null){
                    if(mapavailconfig.containsKey(temp.Skill__c)){
                        mapavailconfig.remove(temp.Skill__c);
                    }
                }
            }

            List<Lesson_Template__c> lsttemplessonLang = new List<Lesson_Template__c>();
            lsttemplessonLang.addAll(mapavailconfig.values());            
            lsttemplessonLang.addAll(lstavailLessonCoacheLAng);            
            //Selecting Lessons related to the Competencies and Skills previosly created as part of this Benchmark
            lstLessonbench = LessonsSelector.selectByLessonTemplateBench(lsttemplessonLang, lstBenchmarkId); 
            Map<Id,Lesson_Template__c> mapLessontemp = new Map<Id,Lesson_Template__c>(lsttemplessonLang);

            //Removing entries of Lesson Templates for which Lessons are already added 
            for(Lesson__c temp : lstLessonbench){ 
                String strtemp1 = temp.Lesson_Template__c;
                if(strtemp1 != null){
                    if(mapLessontemp.containsKey(strtemp1)){
                        mapLessontemp.remove(strtemp1);
                    }
                }
            }
            List<Lesson_Template__c> lstfnlavailLessonCoacheLAng = new List<Lesson_Template__c>();
            lstfnlavailLessonCoacheLAng.addAll(mapLessontemp.values());
            Map<Id,String> CheckerMap = new Map<Id,String>();
            
            //Inserting Data to Wrapper Class 
            for(Observed_Competency__c temoobscomp : lstObscomprecords){ 
                List<WrapLesson> wrpLesson = new List<WrapLesson>();
                //Inserting Already Existing Lessons
                for (Lesson__c templesson : lstLessonbench){
                    if(temoobscomp.Competency__c == templesson.Observed_Competency__r.Competency__r.Id && temoobscomp.Skill__c == templesson.Observed_Competency__r.Skill__r.Id){  
                        temprecId = templesson.Id;
                        name = templesson.Name;
                        description = templesson.Description__c;
                        url = templesson.URL__c;
                        check = true;
                        ObsCompId = temoobscomp.Id;
                        wrpLesson.add(new WrapLesson(temprecId,name,description,url,check,ObsCompId)); 
                    }
                } 
                //Inserting Lesson Tempaltes related to Selected Competencies and Skills
                for(Lesson_Template__c templessontemplate : lstfnlavailLessonCoacheLAng){
                    if(templessontemplate.Threshold_Rating__c >= Integer.valueOf(temoobscomp.Score__c)){
                        if(templessontemplate.Competency__c == temoobscomp.Competency__c){
                            temprecId = templessontemplate.Id;
                            name = templessontemplate.Name;
                            description = templessontemplate.Description__c;
                            url = templessontemplate.URL__c;
                            check = false;
                            ObsCompId = temoobscomp.Id;
                            wrpLesson.add(new WrapLesson(temprecId,name,description,url,check,ObsCompId));  
                        }
                        if(templessontemplate.Skill__c == temoobscomp.Skill__c && temoobscomp.Skill__c != null){
                            temprecId = templessontemplate.Id;
                            name = templessontemplate.Name;
                            description = templessontemplate.Description__c;
                            url = templessontemplate.URL__c;
                            check = false;
                            ObsCompId = temoobscomp.Id;
                            wrpLesson.add(new WrapLesson(temprecId,name,description,url,check,ObsCompId));   
                        }
                    }
                }
                if(wrpLesson.size() > 0){
                    String strfnlname = mapcompskillname.get(temoobscomp.Id);
                    wrpFnlLesson.add(new WrapFnlCompLesson(strfnlname,wrpLesson));
                }
            }
        }
        return wrpFnlLesson;
    }
    
    /**     * @Description As part of TPDEV-64 this method will get the Competency and Skill names with Translation      
			* @Author      Sibin Kuriakose @ Zoetis Inc | 07-03-2023
    */
    private static Map<Id,String> getCompSkillName(List<Observed_Competency__c> lstObscomprecords) {
        Map<Id,String> mapcompskillname = new Map<Id,String>();

        for(Observed_Competency__c tempobscomp : lstObscomprecords){
            String comptrans = tempobscomp.Competency_Translation__r.Name__c;
            String comp = tempobscomp.Competency__r.Name;
            String skilltrans = tempobscomp.Skill_Translation__r.Name__c;
            String skill = tempobscomp.Skill__r.Name__c;
            String strfnl = '';
            if(comptrans != null){
                strfnl = comptrans;
            }
            else if(comp != null){
                strfnl = comp;
            }
            if(skilltrans != null){
                strfnl = strfnl+ ' : ' +skilltrans;
            }
            else if(skill != null){
                strfnl = strfnl+ ' : ' +skill;
            }
            mapcompskillname.put(tempobscomp.Id,strfnl);
        }

        return mapcompskillname;
    }
}