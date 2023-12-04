/*
Class Name        : DataTranslationsSelectorTest
Description       : Test Class created as part of TPDEV-168 for Code Coverage of DataTranslationsSelector. 
Created By        : Suprabha Acharya
Created Date      : 02-15-2023
Modification Log:
----------------------------------------------------------------------------
Var  Developer               Date            Description
----------------------------------------------------------------------------
01   Kalyan Nayak         02-16-2023   Added methods to cover selectDataTransByCompetencyTest method 
02   Sibin Kuriakose      02-17-2023   Added methods to cover selectDataTransBySkillTest method
03   Ethan Hirsch         04-10-2023   Added a method to cover selectDataTransByCompetencyModelIdsAndLocales method
*/

@isTest
public class DataTranslationsSelectorTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        //Competency model records
        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        Competency_Model__c objCompetencymodel = new Competency_Model__c();
        objCompetencymodel.Name = 'competencymodeltest';
        competencyModelList.add(objCompetencymodel);
        insert competencyModelList;
        
        //Competency records
        List<Competency__c> competencyList = new List<Competency__c>();
        Competency__c objCompetency = new Competency__c();
        objCompetency.Competency_Model__c = competencyModelList[0].id;
        objCompetency.Name = 'Competencytest1';
        objCompetency.Order__c =1;
        competencyList.add(objCompetency);
        
        insert competencyList;
        
        //Data Translation records with competency
        List<Data_Translation__c> dataTranslationList = new List<Data_Translation__c>();
        Data_Translation__c objDataTranslation = new Data_Translation__c();
        objDataTranslation.Name__c = 'DataTranslationTest';
        objDataTranslation.Language__c = 'en_US';
        objDataTranslation.Competency__c = competencyList[0].Id;
        dataTranslationList.add(objDataTranslation);
        insert dataTranslationList;
        
        //Skill Record
        List<Skill__c> lstSkill = new List<Skill__c>();
        Skill__c objSkill = new Skill__c();
        objSkill.Name__c = 'SkillTest';
        objSkill.Order__c =1;
        objSkill.Competency__c = competencyList[0].Id;
        lstSkill.add(objSkill);
        insert lstSkill;
        
        //Data Translation records with Skill
        List<Data_Translation__c> dataTranslationList2 = new List<Data_Translation__c>();
        Data_Translation__c objDataTranslation2 = new Data_Translation__c();
        objDataTranslation2.Name__c = 'DataTranslationTest2';
        objDataTranslation2.Language__c = 'en_US';
        objDataTranslation2.Skill__c = lstSkill[0].Id;
        dataTranslationList2.add(objDataTranslation2);
        insert dataTranslationList2;

        //Data Translation record with Competency Model
        List<Data_Translation__c> dataTranslationList3 = new List<Data_Translation__c>();
        Data_Translation__c objDataTranslation3 = TestDataFactory.createDataTranslation(null, null,
            competencyModelList[0].Id, 'Test Translation', 'en_US');
        dataTranslationList3.add(objDataTranslation3);
        insert dataTranslationList3;
        
    }
    //------------setupData end--------------------
    
    /**     * @Description This method will test selectDataTransBySkill method     
            * @Author      Sibin Kuriakose @ Zoetis Inc | 02-17-2023 
    */
    @isTest static void selectDataTransBySkillTest(){
        
        List<Data_Translation__c> DataTranslationlist = new List<Data_Translation__c>();
        Data_Translation__c Dtlist=new Data_Translation__c();
        Dtlist.Name__c = 'competencymodeltest';
        Dtlist.Language__c='en_US';
        DataTranslationlist.add(Dtlist);
        
        insert DataTranslationlist;
        
        List<Data_Translation__c> lstDataTrans =  [Select Language__c,Competency__c,Skill__c from Data_Translation__c Where Competency__c!= null OR Skill__c != null];
        set<string> setTrans = new set<string>();
        setTrans.add(lstDataTrans[0].Language__c);
        set<Id> lstDataTransComp = new Map<Id, Competency__c>([Select Id from Competency__c]).keySet();
        set<Id> Skillset = new Map<Id, Skill__c>([Select Id from Skill__c]).keySet();
        
        
        Test.startTest();
         List<Data_Translation__c> dataTranslationList1 = DataTranslationsSelector.selectDataTransBySkill(lstDataTransComp,Skillset);
        Test.stopTest();
        System.assertEquals(2,dataTranslationList1.size());
        
    }
      
    /**     * @Description This method will test selectDataTransByCompetency method     
            * @Author      Kalyan Nayak @ Zoetis Inc | 02-16-2023 
    */
    @isTest static void selectDataTransByCompetencyTest(){
        
        Set<Id> setCompetencyId = new Map<Id, Competency__c>( [Select Id from Competency__c]).keySet();        
        Test.startTest();
           List<Data_Translation__c> dataTranslationList2 = DataTranslationsSelector.selectDataTransByCompetency(setCompetencyId);
        Test.stopTest();
        System.assertEquals(1,dataTranslationList2.size());
    }
    
    /**     * @Description This method will test selectDataTransByCompetency method     
            * @Author      Sibin Kuriaksoe @ Zoetis Inc | 03-14-2023 
    */
    @isTest static void selectDataTransByCompetencyListTest(){
        
        String userlang = 'en_US';
        
        List<Competency__c> lstCompetency = [
            SELECT Name, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Skill_Count__c
            FROM Competency__c];
        
        Test.startTest();
           List<Data_Translation__c> dataTranslationList3 = DataTranslationsSelector.selectDataTransByCompetencyList(userlang, lstCompetency);
        Test.stopTest();
        System.assertEquals(1,dataTranslationList3.size());
    }
    
    /**     * @Description This method will test selectDataTransBySkill method     
            * @Author      Sibin Kuriaksoe @ Zoetis Inc | 03-14-2023 
    */
    @isTest static void selectDataTransBySkillListTest(){
        
        String userlang = 'en_US';
        
        List<Skill__c> lstSkill = [
            SELECT Name__c, Learning_Description__c, Applying_Description__c,Mastery_Description__c,Competency__c
            FROM Skill__c];
        
        Test.startTest();
           List<Data_Translation__c> dataTranslationList4 = DataTranslationsSelector.selectDataTransBySkillList(userlang, lstSkill);
        Test.stopTest();
        System.assertEquals(1,dataTranslationList4.size());
    }
    
    /**     * @Description This method will test the selectDataTransByCompetencyModelIdsAndLocales method     
            * @Author      Ethan Hirsch @ Zoetis Inc | 04-10-2023 
    */
    @isTest static void selectDataTransByCompetencyModelIdsAndLocalesTest() {
        String userLang = 'en_US';

        Set<Id> setCompetencyModelId = new Map<Id, Competency_Model__c>([
            SELECT Id
            FROM Competency_Model__c
        ]).keySet();

        Test.startTest();
            List<Data_Translation__c> dataTranslationList5 = DataTranslationsSelector.selectDataTransByCompetencyModelIdsAndLocales(
                setCompetencyModelId, new Set<String> {userLang});
        Test.stopTest();

        System.assertEquals(1, dataTranslationList5.size(), 'More/Less Translations were retrieved than expected.');
    }
}