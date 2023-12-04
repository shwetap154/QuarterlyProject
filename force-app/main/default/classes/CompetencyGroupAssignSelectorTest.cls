/**
* @description       : 
* @author            : Kalyan Nayak @ Zoetis Inc
* @group             : 
* @last modified on  : 02-10-2023
* @last modified by  : Kalyan Nayak @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   2-13-2-23    Kalyan Nayak @ Zoetis Inc   Added setupData and selectByCompeGroupMarketRoleTest methods to get 
												 Competecny Group Assignment list
**/
@isTest
private class CompetencyGroupAssignSelectorTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        //Competency model records
        List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
        Competency_Model__c objCompetencymodel = new Competency_Model__c();
        objCompetencymodel.Name = 'competencymodeltest';
        objCompetencymodel.Status__c ='Active';        
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
        
        Competency_Model__c objCompetencymodel4 = new Competency_Model__c();
        objCompetencymodel4.Name = 'competencymodeltest';
        objCompetencymodel4.Status__c = 'Draft';        
        competencyModelList.add(objCompetencymodel4);
    
       Competency_Model__c objCompetencymodel5 = new Competency_Model__c();
       objCompetencymodel5.Name = 'competencymodeltest';
       objCompetencymodel5.Status__c = 'Inactive';        
       competencyModelList.add(objCompetencymodel5);
        
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

        for (Competency_Model__c competencyModel : competencyModelList) {
            Competency_Group_Assignment__c objComGroupAssign = new Competency_Group_Assignment__c();
            objComGroupAssign.Competency_Group__c = competencyGroupList[0].Id;
            objComGroupAssign.Competency_Model__c = competencyModel.Id;
            comGroupAssignList.add(objComGroupAssign);
        }
        
        insert comGroupAssignList;        
    }
    //------------setupData End-------------------
    
    @isTest static void selectByCompeGroupMarketRoleTest(){
        Test.startTest(); 
        	List<Competency_Group_Assignment__c> objComGrpAss = CompetencyGroupAssignSelector.selectByCompeGroupMarketRole('Albania','SAM');
        Test.stopTest();
        System.assertEquals(5, objComGrpAss.size());
    }
    @isTest static void selectByCompeGroupSetOfMarketTest(){
        Set<String> setMarket = new Set<String>(new List<String>{'Albania'});
        Test.startTest(); 
        List<Competency_Group_Assignment__c> lstComGrpAssignment = CompetencyGroupAssignSelector.selectByCompeGroupSetOfMarket(setMarket);
        Test.stopTest();
        System.assertEquals(5, lstComGrpAssignment.size());
    }

    /**     * @Description This method will test selectByCompeGroupCompModel method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
    */
    @isTest static void selectByCompeGroupCompModelTest(){
        List <Competency_Group__c> lstfnlCompGroup = [SELECT Id,Market__c,Role__c FROM Competency_Group__c];
        List<Competency_Group_Assignment__c> tempCGA = [SELECT Competency_Model__c FROM Competency_Group_Assignment__c];
        List<Id> compmodel = new List<Id>();
        for(Competency_Group_Assignment__c temp : tempCGA){
            compmodel.add(temp.Competency_Model__c);
        }
        Test.startTest(); 
        List<Competency_Group_Assignment__c> lstComGrpAssignment = CompetencyGroupAssignSelector.selectByCompeGroupCompModel(lstfnlCompGroup,compmodel);
        Test.stopTest();
        System.assertEquals(5, lstComGrpAssignment.size());
    }
    
    /**     * @Description This method will test selectByCompeGroupByMarket method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
    */
    @isTest static void selectByCompeGroupByMarketTest(){
        String strtemp = 'Albania';
        list<string> strtempmarket = new List<string>();
        strtempmarket.add(strtemp);
        String comGrpMarket = '(\'' + String.join(strtempmarket, '\',\'') + '\')';
        Test.startTest(); 
        List <Competency_Group_Assignment__c> lsttempCompGroup = CompetencyGroupAssignSelector.selectByBenchmarkMarket(comGrpMarket);
        Test.stopTest();
        System.assertEquals(1, lsttempCompGroup.size());
    }
}