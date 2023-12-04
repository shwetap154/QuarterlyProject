/**
Class Name	    : KnowledgeServiceTest
Description	    : Test Class created as part of TPDEV-431 for the KnowledgeService Class. 
Created By		: Sibin Kuriakose
Created Date	: 03-30-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-30-2023	 Created methods to Test Methods on KnowledgeService
*/

@isTest
public class KnowledgeServiceTest {
    /**     * @Description This method will setup the Test data      
                * @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
    @testSetup static void setupData() {
        //Creating Knowledge

        //First Record
        FAQ__kav tempKnow = new FAQ__kav();
        tempKnow.Title = 'Test Know';
        tempKnow.URLName = 'Test-Know';
        tempKnow.Review_Article_In__c = '3 Months';
        tempKnow.Data_Category__c = 'Customer_Operations,All';
        insert tempKnow;

        //Creating Data Category
        List<FAQ__DataCategorySelection> lstdatacat = new List<FAQ__DataCategorySelection>();
        //First Record
        FAQ__DataCategorySelection tempDataCat = new FAQ__DataCategorySelection();
        tempDataCat.DataCategoryGroupName = 'Article_Topic';
        tempDataCat.DataCategoryName = 'All ';
        tempDataCat.ParentId = tempKnow.Id;
        lstdatacat.add(tempDataCat);

        //Second Record
        FAQ__DataCategorySelection tempDataCat2 = new FAQ__DataCategorySelection();
        tempDataCat2.DataCategoryGroupName = 'Business_Unit';
        tempDataCat2.DataCategoryName = ' Customer_Operations';
        tempDataCat2.ParentId = tempKnow.Id;
        lstdatacat.add(tempDataCat2);

        insert lstdatacat;
    }
    
    /**     * @Description This method will test getCompetencySkills method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
	 @isTest 
     public static void  checkDataCategoryTest(){
         List<FAQ__kav> lstKnow = [SELECT Id FROM FAQ__kav];
         Set<Id> tempKnowId = (new Map<Id,SObject>(lstKnow)).keySet();

         List<Id> lstKnowId = new List<Id>();

         for(Id tempknow : tempKnowId){
            lstKnowId.add(tempknow);
         }

         Test.startTest();
         Map<Id, List<String>> mapKnowDataCat = KnowledgeService.getDataCategory(lstKnowId);
         System.assertEquals(1,mapKnowDataCat.size());
         Map<Id, Boolean> mapKnowDataCatBool = KnowledgeService.compDataCategory(lstKnowId,mapKnowDataCat);
         List<FAQ__kav> lstKnowdetail = KnowledgeSelector.selectKnowledgeById(lstKnowId);
         List<FAQ__kav> lstKnowdetailfnl = new List<FAQ__kav>();
         for(FAQ__kav temp: lstKnowdetail){
             temp.Data_Category__c.remove('US Customer Care');
             temp.Data_Category__c = 'Customer_Operations,Contacts';
             lstKnowdetailfnl.add(temp);
         }
         update lstKnowdetailfnl;
         mapKnowDataCatBool = KnowledgeService.compDataCategory(lstKnowId,mapKnowDataCat);
         System.assertEquals(1,mapKnowDataCatBool.size());
         Test.stopTest();
     }
}