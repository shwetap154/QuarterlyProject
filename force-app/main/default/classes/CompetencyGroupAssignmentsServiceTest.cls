/**
Class Name	    : CompetencyGroupAssignmentsServiceTest
Description	    : Test Class created as part of TPDEV-533 for CompetencyGroupAssignmentsService Class. 
Created By		: Sibin Kuriakose
Created Date	: 04-06-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Sibin Kuriakose       	 04-06-2023   Added Methods to call Test Methods in CompetencyGroupAssignmentsService
*/
@isTest
private class CompetencyGroupAssignmentsServiceTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        //Competency model records

         //First Record
         List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         objCompetencymodel.Status__c='Active';
         competencyModelList.add(objCompetencymodel);
         
         //Second Record
         Competency_Model__c objCompetencymodel2 = new Competency_Model__c();
         objCompetencymodel2.Name = 'competencymodeltest';
         objCompetencymodel2.Status__c='Draft';
         competencyModelList.add(objCompetencymodel2);
        //Third Record
        Competency_Model__c objCompetencymodel3 = new Competency_Model__c();
        objCompetencymodel3.Name = 'competencymodeltest';
        objCompetencymodel3.Status__c='Inactive';
        competencyModelList.add(objCompetencymodel3);

         insert competencyModelList;
        
        //Competency group records
        List<Competency_Group__c> competencyGroupList = new List<Competency_Group__c>();
        Competency_Group__c objCompetencyGroup = new Competency_Group__c();
        objCompetencyGroup.Market__c = 'Albania';
        objCompetencyGroup.Role__c = 'SAM';
        competencyGroupList.add(objCompetencyGroup);
        
        insert competencyGroupList;
        
        //Competency Group Assignment records
        List<Competency_Group_Assignment__c> comGroupAssignList = new List<Competency_Group_Assignment__c>();
        Competency_Group_Assignment__c objComGroupAssign = new Competency_Group_Assignment__c();
        objComGroupAssign.Competency_Group__c = objCompetencyGroup.Id;
        objComGroupAssign.Competency_Model__c = objCompetencymodel.id;
        comGroupAssignList.add(objComGroupAssign);
        
        insert comGroupAssignList;        
    }
    //------------setupData End-------------------


    /**     * @Description This method will test competencyGroupValidations method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
    */
    @isTest static void competencyGroupValidationsTest(){
        List<Competency_Group_Assignment__c> tempCGA = [SELECT Id,Competency_Group__c,Competency_Model__c FROM Competency_Group_Assignment__c];
        Test.startTest(); 
        try{
        CompetencyGroupAssignmentsService.competencyGroupValidations(tempCGA);
        }
        catch(Exception e){
        Test.stopTest();
        string str1='{compmodel}';
        string str2='{market}';
        string str3='{roles} ';
        string strname = 'competencymodeltest';
        string strmarket = 'Albania';
        string strrole = 'SAM';
        String errorMessage = System.Label.CompetencyGroupAssignmentsError.replace(str1,strname).replace(str2,strmarket).replace(str3,strrole);
        String message = e.getMessage();
        system.assert(message.contains(errorMessage), 'message=' + message);
        }
  
    }
}