/**
Class Name	    : CompetencyGroupSelectorTest
Description	    : Test Class created as part of TPDEV-533 for the CompetencyGroupSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 04-06-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer					    Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Sibin Kuriakose       	    04-06-2023   Added Methods to call Test Methods in CompetencyGroupSelector
02    Raut, Pranav Krushnarao		04-11-2023	 Added method to test selectByCompeGroupByMarketSet method 
*/

@isTest
private class CompetencyGroupSelectorTest {
    
    //----------setupData start----------------
    @testSetup static void setupData() {
        
        //Competency group records
        List<Competency_Group__c> competencyGroupList = new List<Competency_Group__c>();
        Competency_Group__c objCompetencyGroup = new Competency_Group__c();
        objCompetencyGroup.Market__c = 'Albania';
        objCompetencyGroup.Role__c = 'SAM';
        competencyGroupList.add(objCompetencyGroup);
        
        //Competency group records
        Competency_Group__c objCompetencyGroup2 = new Competency_Group__c();
        objCompetencyGroup2.Market__c = 'Ukraine';
        objCompetencyGroup2.Role__c = 'SAM';
        competencyGroupList.add(objCompetencyGroup2);
        
        insert competencyGroupList;
                       
    }
    //------------setupData End-------------------
    
    /**     * @Description This method will test selectByCompeGroupById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 04-06-2023 
    */
    @isTest static void selectByCompeGroupByIdTest(){
        
        List<Id> compgroup = new List<Id>();
        List <Competency_Group__c> lsttempCG = [SELECT Id,Market__c,Role__c FROM Competency_Group__c];
        for(Competency_Group__c  tempCG : lsttempCG) {
            compgroup.add(tempCG.Id);
        }
        Test.startTest(); 
        List <Competency_Group__c> lstCompGroup = CompetencyGroupSelector.selectByCompeGroupById(compgroup);
        Test.stopTest();
        System.assertEquals(2, lstCompGroup.size());

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
        List <Competency_Group__c> lsttempCompGroup = CompetencyGroupSelector.selectByCompeGroupByMarket(comGrpMarket);
        Test.stopTest();
        System.assertEquals(1, lsttempCompGroup.size());
    }

    /**     * @Description This method will test selectByCompeGroupByMarketSet method     
            * @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 04-11-2023 
    */
    @isTest static void selectByCompeGroupByMarketSetTest(){
        Set<String> setMarket = new Set<String>();
        setMarket.add('Albania');
        Test.startTest(); 
        List <Competency_Group__c> lsttempCompGroup = CompetencyGroupSelector.selectByCompeGroupByMarketSet(setMarket);
        Test.stopTest();
        System.assertEquals(1, lsttempCompGroup.size());
    }
}