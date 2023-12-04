/**
Class Name	    : CompetencyGroupServiceTest
Description	    : Test Class created as part of TPDEV-558 for CompetencyGroupService Class. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 04-11-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Raut, Pranav Krushnarao    04-11-2023   Added Methods to Test Methods in CompetencyGroupService
02	  Nayak, Kalyan				 05-07-2023   Added preventDuplicateCompetencyGroupTest2 Methods in part of TPDEV-1206
*/
@isTest
public class CompetencyGroupServiceTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        //Competency model records
        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        Competency_Model__c objCompetencymodel = new Competency_Model__c();
        objCompetencymodel.Name = 'competencymodeltest';
        competencyModelList.add(objCompetencymodel);
        
        insert competencyModelList;
        
        //Competency group records
        List<Competency_Group__c> competencyGroupList = new List<Competency_Group__c>();
        Competency_Group__c objCompetencyGroup = new Competency_Group__c();
        objCompetencyGroup.Market__c = 'Albania';
        objCompetencyGroup.Role__c = 'SAM';
        competencyGroupList.add(objCompetencyGroup);
        
        insert competencyGroupList;
        
        //Competency group records
        List<Competency_Group__c> competencyGroupList2 = new List<Competency_Group__c>();
        Competency_Group__c objCompetencyGroup2 = new Competency_Group__c();
        objCompetencyGroup2.Market__c = 'Albania;United Kingdom';
        objCompetencyGroup2.Role__c = 'SAM;TBM';
        competencyGroupList.add(objCompetencyGroup2);
        
        insert competencyGroupList2;
        
        //Competency Group Assignment records
        List<Competency_Group_Assignment__c> comGroupAssignList = new List<Competency_Group_Assignment__c>();
        Competency_Group_Assignment__c objComGroupAssign = new Competency_Group_Assignment__c();
        objComGroupAssign.Competency_Group__c = objCompetencyGroup.Id;
        objComGroupAssign.Competency_Model__c = objCompetencymodel.id;
        comGroupAssignList.add(objComGroupAssign);
        
        insert comGroupAssignList;        
    }
    //------------setupData End-------------------
    
    /**     
* @Description :This method will test preventDuplicateCompetencyGroup method in CompetencyGroupService class
* @Author      :Raut, Pranav Krushnarao @ Zoetis Inc | 04-11-2023 
*/
    @isTest static void preventDuplicateCompetencyGroupTest(){
        Test.startTest();
        try{
            //Competency record
            Competency_Group__c objCompGrp = new Competency_Group__c();
            objCompGrp.Market__c = 'Albania';
            objCompGrp.Role__c = 'SAM';       
            insert objCompGrp;
            
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Duplicate_Competency_Group_Error), 'message=' + message);
        }
        Test.StopTest(); 
    }
    
    /**     
* @Description :This method will test preventDuplicateCompetencyGroup method in CompetencyGroupService class
* @Author      :Raut, Pranav Krushnarao @ Zoetis Inc | 04-11-2023 
*/    
    @isTest static void preventDuplicateCompGrpUpdateTest(){
        Test.startTest();
        try{
            //Competency record
            Competency_Group__c objCompGrp = new Competency_Group__c();
            objCompGrp.Market__c = 'United States';
            objCompGrp.Role__c = 'TBM';       
            insert objCompGrp;

            Competency_Group__c objCompGrp2 = new Competency_Group__c();
            objCompGrp2.Market__c = 'Ukraine';
            objCompGrp2.Role__c = 'TBM';       
            insert objCompGrp2;   
            
            objCompGrp2.Market__c = 'United States';
            Update objCompGrp2;
            
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Duplicate_Competency_Group_Error), 'message=' + message);
        }        
        Test.StopTest();        
    }
    
        /**     
* @Description :This method will test preventDuplicateCompetencyGroup method in CompetencyGroupService class
* @Author      :Raut, Pranav Krushnarao @ Zoetis Inc | 04-11-2023 
*/    
    @isTest static void preventDuplicateCompGroupForCompModelTest(){
        Test.startTest();
        try{        
        //Competency record
        Competency_Group__c objCompGrp = new Competency_Group__c();
        objCompGrp.Market__c = 'United States';
        objCompGrp.Role__c = 'TBM';       
        insert objCompGrp;
        
        objCompGrp.Market__c = 'Albania';
        objCompGrp.Role__c = 'SAM';
        update objCompGrp;
            
        }catch(Exception e){
            string CompModelName='{CompetencyModelName}';
            string CompGrpMarket='{CompetencyGroupMarket}';
            string CompGrpRole='{CompetencyGroupRole}';
            String CompetencyModelName = 'competencymodeltest';
            String Market = 'Albania';
            String Role = 'SAM';
            String errorMessage = System.Label.Duplicate_CompetencyGroup_On_CompetencyModel_Error.replace(CompModelName,CompetencyModelName).replace(CompGrpMarket,Market).replace(CompGrpRole,Role);
            String message = e.getMessage();
            system.assert(message.contains(errorMessage), 'message=' + message);
        }        
        Test.StopTest();
    }
    
      /**     
* @Description :This method will test preventDuplicateCompetencyGroup method in CompetencyGroupService class
* @Author      :Nayak,Kalyan @ Zoetis Inc | 05-07-2023 
*/
    @isTest static void preventDuplicateCompetencyGroupTest2(){
        Test.startTest();
        try{
            //Competency record
            Competency_Group__c objCompGrp = new Competency_Group__c();
            objCompGrp.Market__c = 'Albania;United Kingdom';
            objCompGrp.Role__c = 'SAM;TBM';       
            insert objCompGrp;
            
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Duplicate_Competency_Group_Error), 'message=' + message);
        }
        Test.StopTest(); 
    }

    
}