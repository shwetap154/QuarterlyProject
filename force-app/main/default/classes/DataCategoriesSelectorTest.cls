/**
Class Name	    : DataCategoriesSelectorTest
Description	    : Test Class created as part of TPDEV-431 for the DataCategoriesSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 03-30-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-30-2023	 Created methods to Test Methods on DataCategoriesSelector
*/
@isTest
public class DataCategoriesSelectorTest {
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
        tempKnow.Data_Category__c = 'All';
        insert tempKnow;

        //Creating Data Category

        //First Record
        FAQ__DataCategorySelection tempDataCat = new FAQ__DataCategorySelection();
        tempDataCat.DataCategoryGroupName = 'Article_Topic';
        tempDataCat.DataCategoryName = 'All';
        tempDataCat.ParentId = tempKnow.Id;
        insert tempDataCat;

        //Second Record
        FAQ__DataCategorySelection tempDataCat2 = new FAQ__DataCategorySelection();
        tempDataCat2.DataCategoryGroupName = 'Business_Unit';
        tempDataCat2.DataCategoryName = 'Reference_Labs';
        tempDataCat2.ParentId = tempKnow.Id;
        insert tempDataCat2;
    }
    
    /**     * @Description This method will test selectAllDataCategoriesByParentId method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
	 @isTest 
     public static void  selectAllDataCategoriesByParentIdTest(){
         List<FAQ__kav> lstKnow = [SELECT Id FROM FAQ__kav];
         Set<Id> tempKnowId = (new Map<Id,SObject>(lstKnow)).keySet();

         List<Id> lstKnowId = new List<Id>();

         for(Id tempknow : tempKnowId){
            lstKnowId.add(tempknow);
         }

         Test.startTest();
         List<FAQ__DataCategorySelection> lstdataCatdetail = DataCategoriesSelector.selectAllDataCategoriesByParentId(lstKnowId);
         Test.stopTest();
         System.assertEquals(2,lstdataCatdetail.size());
     }
}