/**
Class Name	    : KnowledgeSelector
Description	    : Selector Class created as part of TPDEV-431 for the Knowledge Object. 
Created By		: Sibin Kuriakose
Created Date	: 03-30-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer			Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose	03-30-2023   Added Methods to Retrive list of Knowledge records having Id same as RecordId
02   Sibin Kuriakose	04-04-2023   Modified selectKnowledgeById() to include Description and Content
*/

public With Sharing class KnowledgeSelector {

    /**     * @Description To Retrive list of Knowledge records having Id same as RecordId     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
			* @param       List of Id
    */
    public static List<FAQ__kav> selectKnowledgeById(List<Id> recordId) {
        
        List<FAQ__kav> lstKnowdetail = [SELECT Id,Title,Description__c,Answer__c,Data_Category__c  from FAQ__kav WHERE Id = :recordId];
        return lstKnowdetail;
    }
}