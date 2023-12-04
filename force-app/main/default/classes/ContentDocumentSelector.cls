/**
Class Name	    : ContentDocumentSelector
Description	    : Selector Class created as part of TPDEV-428 for the ContentDocument. 
Created By		: Sibin Kuriakose
Created Date	: 04-04-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer			Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Sibin Kuriakose	04-04-2023   Added Methods to Retrive list of ContentDocument records having Id same as RecordId
*/

public With Sharing class ContentDocumentSelector {

    /**     * @Description To Retrive list of Knowledge records having Id same as RecordId     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
			* @param       List of Id
    */
    public static List<ContentDocument> selectContentById(List<Id> tempRecordId) {
        
        List<ContentDocument> lstContdetail = [SELECT Id,Description, ContentAssetId,Title FROM ContentDocument where Id = :tempRecordId];
        return lstContdetail;
    }
}