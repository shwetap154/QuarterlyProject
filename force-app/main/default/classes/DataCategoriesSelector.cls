/**
Class Name	    : DataCategoriesSelector
Description	    : Selector Class created as part of TPDEV-431 for the DataCategories. 
Created By		: Sibin Kuriakose
Created Date	: 03-30-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose	03-30-2023   Added Methods to Retrive list of DataCategories records having ParentId same as RecordId
02   Morgan @ Zoetis    08-09-2023   Changed the selectDataCategoryByParentId to selectAllDataCategoriesByParentId
*                                    and updated the query logic to bypass sharing.
*/

public With Sharing class DataCategoriesSelector {

    /**     * @Description Returns a List of all Data Categories for a given List of Knowledge Ids, 
            * even if the user doesn't have access to some Data Categories.     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
			* @param       List of Id
    */
    public static List<FAQ__DataCategorySelection> selectAllDataCategoriesByParentId(List<Id> recordId) {
        
        // We retrieve the full Data Category Selection list regardless of sharing so that proper comparisons can be done.
        List<FAQ__DataCategorySelection> lstdataCatdetail = new WithoutSharing().selectDataCategoriesByParentId(recordId);
        return lstdataCatdetail;
    }

    private without sharing class WithoutSharing {
        public List<FAQ__DataCategorySelection> selectDataCategoriesByParentId(List<Id> recordIds){
            List<FAQ__DataCategorySelection> lstdataCatdetail = [SELECT Id,DataCategoryGroupName,DataCategoryName,ParentId FROM 
                                                            FAQ__DataCategorySelection WHERE ParentId = :recordIds];
            return lstdataCatdetail;
        }
    }
}