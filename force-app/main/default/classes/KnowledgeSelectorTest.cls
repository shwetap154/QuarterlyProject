/**
Class Name	    : KnowledgeSelectorTest
Description	    : Test Class created as part of TPDEV-431 for the KnowledgeSelector Class. 
Created By		: Sibin Kuriakose
Created Date	: 03-30-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-30-2023	 Created methods to Test Methods on KnowledgeSelector
02  Sibin Kuriakose	            04-04-2023   Modified selectKnowledgeById() to add Description and Content
*/
@isTest
public class KnowledgeSelectorTest {
    /**     * @Description This method will setup the Test data      
                * @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
    @testSetup static void setupData() {
        //Creating Knowledge

        //First Record
        FAQ__kav tempKnow = new FAQ__kav();
        tempKnow.Title = 'Test Know';
        tempKnow.URLName = 'Test-Know';
        tempKnow.Description__c = 'Test-Know Description';
        tempKnow.Answer__c = 'Test-Know Content';
        tempKnow.Review_Article_In__c = '3 Months';
        tempKnow.Data_Category__c = 'All';
        insert tempKnow;
    }
    
    /**     * @Description This method will test selectKnowledgeById method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
	 @isTest 
     public static void  selectKnowledgeByIdTest(){
         List<FAQ__kav> lstKnow = [SELECT Id FROM FAQ__kav];
         Set<Id> tempKnowId = (new Map<Id,SObject>(lstKnow)).keySet();

         List<Id> lstKnowId = new List<Id>();

         for(Id tempknow : tempKnowId){
            lstKnowId.add(tempknow);
         }

         Test.startTest();
         List<FAQ__kav> lstKnowdetail = KnowledgeSelector.selectKnowledgeById(lstKnowId);
         Test.stopTest();
         System.assertEquals(1,lstKnowdetail.size());
     }
}