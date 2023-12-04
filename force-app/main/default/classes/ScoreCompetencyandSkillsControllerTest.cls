/**
Class Name	    : ScoreCompetencyandSkillsControllerTest
Description	    : Test Class created as part of TPDEV-59 for the ScoreCompetencyandSkillsController Class. 
Created By		: Sibin Kuriakose
Created Date	: 03-13-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-13-2023	 Created methods to Test Methods on ScoreCompetencyandSkillsController
*/
@isTest
public class ScoreCompetencyandSkillsControllerTest {
 /**     * @Description This method will setup the Test data      
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-14-2023 
 */
    @testSetup static void setupData() {
        //Competency model records

         //First Record
         List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         objCompetencymodel.Status__c='Active';
         competencyModelList.add(objCompetencymodel);
         
         insert competencyModelList;
        
        //Creating Competencies
        
        //First Record
        Competency__c tempComps = new Competency__c();
        tempComps.Name = 'Test Comp';
        tempComps.Learning_Description__c = 'Test Comp Learning_Description__c';
        tempComps.Applying_Description__c = 'Test Comp Applying_Description__c';
        tempComps.Mastery_Description__c = 'Test Comp Mastery_Description__c';
        tempComps.Competency_Model__c = competencyModelList[0].id;
        tempComps.Order__c = 1;
        tempComps.Status__c='Active';
        insert tempComps;
        
        //Second Record
        Competency__c tempComps1 = new Competency__c();
        tempComps1.Name = 'Test Comp1';
        tempComps1.Learning_Description__c = 'Test Comp1 Learning_Description__c';
        tempComps1.Applying_Description__c = 'Test Comp1 Applying_Description__c';
        tempComps1.Mastery_Description__c = 'Test Comp1 Mastery_Description__c';
        tempComps1.Competency_Model__c = competencyModelList[0].id;
        tempComps1.Order__c = 2;
        tempCOmps1.Status__c='Active';
        insert tempComps1;
        
        //Third Record
        Competency__c tempComps2 = new Competency__c();
        tempComps2.Name = 'Test Comp2';
        tempComps2.Learning_Description__c = 'Test Comp2 Learning_Description__c';
        tempComps2.Applying_Description__c = 'Test Comp2 Applying_Description__c';
        tempComps2.Mastery_Description__c = 'Test Comp2 Mastery_Description__c';
        tempComps2.Competency_Model__c = competencyModelList[0].id;
        tempComps2.Order__c = 3;
        tempComps2.Status__c='Active';
        insert tempComps2;
        
        //Fourth Record
        Competency__c tempComps3 = new Competency__c();
        tempComps3.Name = 'Test Comp3';
        tempComps3.Learning_Description__c = 'Test Comp3 Learning_Description__c';
        tempComps3.Applying_Description__c = 'Test Comp3 Applying_Description__c';
        tempComps3.Mastery_Description__c = 'Test Comp3 Mastery_Description__c';
        tempComps3.Competency_Model__c = competencyModelList[0].id;
        tempComps3.Order__c = 4;
        tempComps3.Status__c='Active';
        insert tempComps3;
        
        //Creating Skills
        
        //First Record
        Skill__c tempSkills = new Skill__c();
        tempSkills.Name__c = 'Test Skill';
        tempSkills.Learning_Description__c = 'Test Skill Learning_Description__c';
        tempSkills.Applying_Description__c = 'Test Skill Applying_Description__c';
        tempSkills.Mastery_Description__c = 'Test Skill Mastery_Description__c';
        tempSkills.Competency__c = tempComps.Id;
        tempSkills.Order__c = 1;
        tempSkills.Status__c='Active';
        insert tempSkills;

        
        //Second Record
        Skill__c tempSkills1 = new Skill__c();
        tempSkills1.Name__c = 'Test Skill1';
        tempSkills1.Learning_Description__c = 'Test Skill1 Learning_Description__c';
        tempSkills1.Applying_Description__c = 'Test Skill1 Applying_Description__c';
        tempSkills1.Mastery_Description__c = 'Test Skill1 Mastery_Description__c';
        tempSkills1.Competency__c = tempComps.Id;
        tempSkills1.Order__c = 2;
        tempSkills1.Status__c='Active';
        insert tempSkills1;
        
        //Third Record
        Skill__c tempSkills2 = new Skill__c();
        tempSkills2.Name__c = 'Test Skill2';
        tempSkills2.Learning_Description__c = 'Test Skill2 Learning_Description__c';
        tempSkills2.Applying_Description__c = 'Test Skill2 Applying_Description__c';
        tempSkills2.Mastery_Description__c = 'Test Skill2 Mastery_Description__c';
        tempSkills2.Competency__c = tempComps3.Id;
        tempSkills2.Order__c = 2;
        tempSkills2.Status__c='Active';
        insert tempSkills2;
        
        //Creating Translations
        List<Data_Translation__c> lstTrans = new List<Data_Translation__c>();
        
        //First Record
        Data_Translation__c tempTrans = new Data_Translation__c();
        tempTrans.Name__c = 'Test Comp1 Translation';
        tempTrans.Learning_Description__c = 'Test Comp1 Learning_Description__c Translation';
        tempTrans.Applying_Description__c = 'Test Comp1 Applying_Description__c Translation';
        tempTrans.Mastery_Description__c = 'Test Comp1 Mastery_Description__c Translations';
        tempTrans.Competency__c = tempComps1.Id;
        tempTrans.Language__c = 'en_US';
        lstTrans.add(tempTrans);
        
        //Second Record
        Data_Translation__c tempTrans1 = new Data_Translation__c();
        tempTrans1.Name__c = 'Test Skill1 Translation';
        tempTrans1.Learning_Description__c = 'Test Skill1 Learning_Description__c Translation';
        tempTrans1.Applying_Description__c = 'Test Skill1 Applying_Description__c Translation';
        tempTrans1.Mastery_Description__c = 'Test Skill1 Mastery_Description__c Translations';
        tempTrans1.Skill__c = tempSkills1.Id;
        tempTrans1.Language__c = 'en_US';
        lstTrans.add(tempTrans1);
        
        //Third Record
        Data_Translation__c tempTrans2 = new Data_Translation__c();
        tempTrans2.Name__c = 'Test Comp Translation';
        tempTrans2.Learning_Description__c = 'Test Comp Learning_Description__c Translation';
        tempTrans2.Applying_Description__c = 'Test Comp Applying_Description__c Translation';
        tempTrans2.Mastery_Description__c = 'Test Comp Mastery_Description__c Translation';
        tempTrans2.Competency__c = tempComps.Id;
        tempTrans2.Language__c = 'en_US';
        lstTrans.add(tempTrans2);
        
		insert lstTrans;        
    }
    
    /**     * @Description This method will test getCompetencySkills method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-13-2023 
    */
	 @isTest 
     public static void  getCompetencySkillsTest1(){
          //Competency model records

         //First Record
         List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         objCompetencymodel.Status__c='Active';
         competencyModelList.add(objCompetencymodel);
         
         insert competencyModelList;
         //Competency records
        //first record
        List<Competency__c> competencyList = new List<Competency__c>();
        Competency__c objCompetency = new Competency__c();
        objCompetency.Name = 'Competencytest1';
        objCompetency.Competency_Model__c = competencyModelList[0].id;
        objCompetency.Order__c = 1;
        objCompetency.Status__c='Active';
        competencyList.add(objCompetency);
       
        //Second Record
        Competency__c objCompetency1 = new Competency__c();
        objCompetency1.Name = 'Competencytest1';
        objCompetency1.Competency_Model__c = competencyModelList[0].id;
        objCompetency1.Order__c =1;
        objCompetency1.Status__c='Draft';
        competencyList.add(objCompetency1);
        
        //Third Record
        Competency__c objCompetency2 = new Competency__c();
        objCompetency2.Name = 'Competencytest1';
        objCompetency2.Competency_Model__c = competencyModelList[0].id;
        objCompetency2.Order__c =1;
        objCompetency2.Status__c='Inactive';
        competencyList.add(objCompetency2);
        
        insert competencyList;
                 //Skill records
        //First Record
        List<Skill__c> skillList = new List<Skill__c>();
        Skill__c objSkill = new Skill__c();
        objSkill.Name__c = 'SkillTest';
        objSkill.Competency__c = competencyList[0].Id;
        objSkill.Learning_Description__c = 'Skill Learning Description';
        objSkill.Applying_Description__c = 'Skill Applying Description';
        objSkill.Mastery_Description__c = 'Skill Mastery Description';
        objSkill.Order__c = 1;
        objSkill.Status__c='Active';
        skillList.add(objSkill);
        
        
        //Second Record
        Skill__c objSkill1 = new Skill__c();
        objSkill1.Name__c = 'SkillTest';
        objSkill1.Competency__c = competencyList[0].Id;
        objSkill1.Learning_Description__c = 'Skill Learning Description';
        objSkill1.Applying_Description__c = 'Skill Applying Description';
        objSkill1.Mastery_Description__c = 'Skill Mastery Description';
        objSkill1.Order__c = 1;
        objSkill1.Status__c='Draft';
        skillList.add(objSkill1);
        
        //Third Record
        Skill__c objSkill2 = new Skill__c();
        objSkill2.Name__c = 'SkillTest';
        objSkill2.Competency__c = competencyList[0].Id;
        objSkill2.Learning_Description__c = 'Skill Learning Description';
        objSkill2.Applying_Description__c = 'Skill Applying Description';
        objSkill2.Mastery_Description__c = 'Skill Mastery Description';
        objSkill2.Order__c = 1;
        objSkill2.Status__c='Inactive';
        skillList.add(objSkill2);
        
        insert skillList;
         
         Test.startTest();
         List<Data_Translation__c> dataTranslationList = ScoreCompetencyandSkillsController.getCompetencySkills(competencyList);
         Test.stopTest();
         System.assertEquals(3,dataTranslationList.size());
     }
    
    /**     * @Description This method will test getCompetencySkills method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-13-2023 
    */
	 @isTest 
     public static void  getCompetencySkillsTest2(){
         List<Competency__c> lstComp2 = [SELECT Id FROM Competency__c WHERE Name = 'Test Comp2' OR Name = 'Test Comp3'];
         
         Test.startTest();
         List<Data_Translation__c> dataTranslationList2 = ScoreCompetencyandSkillsController.getCompetencySkills(lstComp2);
         Test.stopTest();
         System.assertEquals(2,dataTranslationList2.size());
     }
    
    /**     * @Description This method will test getObservedRecords method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-13-2023 
    */
	 @isTest 
     public static void  getObservedRecordsTest(){
         List<Competency__c> lstComp = [SELECT Id FROM Competency__c];
         List<Data_Translation__c> lstTran = [SELECT Id,Name,Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Competency__c,Skill__c FROM Data_Translation__c];
           
         Test.startTest();
         List<Observed_Competency__c> observeredRecords = ScoreCompetencyandSkillsController.getObservedRecords(lstTran,lstComp);
         Test.stopTest();
         System.assertEquals(3,observeredRecords.size());
     }
}