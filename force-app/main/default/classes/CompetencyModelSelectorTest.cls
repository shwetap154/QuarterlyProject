/**
Class Name	    : CompetencyGroupSelectorTest
Description	    : Test Class created as part of TPDEV-533 for the CompetencyGroupSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 04-06-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					 Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Sibin Kuriakose       	 04-06-2023   Added Methods to call Test Methods in CompetencyGroupSelector
*/
@isTest
private class CompetencyModelSelectorTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        
         //Competency model records

         //First Record
         List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         competencyModelList.add(objCompetencymodel);
        
        //Second Record
         Competency_Model__c objCompetencymodel2 = new Competency_Model__c();
         objCompetencymodel2.Name = 'competencymodeltest';
         competencyModelList.add(objCompetencymodel2);
        insert competencyModelList;
        
                       
    }
    //------------setupData End-------------------

    /**     * @Description This method will test selectNameByCompeModelById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
    */
    @isTest static void selectNameByCompeModelByIdTest(){
        List<Id> compmodel = new List<Id>();
        List <Competency_Model__c> lsttempCM = [SELECT Id, Status__c FROM Competency_Model__c];
        for(Competency_Model__c  tempCM : lsttempCM) {
            compmodel.add(tempCM.Id);
        }
        Test.startTest(); 
        List<Competency_Model__c> lstCompModel = CompetencyModelSelector.selectNameByCompeModelById(compmodel);
        Test.stopTest();
        System.assertEquals(2, lstCompModel.size());
    }
}