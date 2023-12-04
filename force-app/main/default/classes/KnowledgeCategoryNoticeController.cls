/**
Class Name	    : KnowledgeCategoryNoticeController
Description	    : Controller Class created as part of TPDEV-431 for KnowledgeCategoryNotice LWC. 
Created By		: Sibin Kuriakose
Created Date	: 03-29-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-30-2023	 Created methods to Check if Data categories are Populated correctly and return a Boolean to LWC
*/


public With Sharing class KnowledgeCategoryNoticeController {

    /**     * @Description As part of TPDEV-431 this method will Check if Data categories are Populated correctly and return a Boolean to LWC 
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */

    @AuraEnabled(cacheable=false)
    public static Boolean checkDataCategory(List<Id> recordId){
        Boolean verify;
        Map<Id, List<String>> mapKnowledgeID = new Map<Id, List<String>>();
        mapKnowledgeID = KnowledgeService.getDataCategory(recordId);
        Map<Id, Boolean> mapCheckData = new Map<Id, Boolean>();
        mapCheckData = KnowledgeService.compDataCategory(recordId,mapKnowledgeID);

        for(Id temprec : recordId){           
            if(mapCheckData.containsKey(temprec)){
                verify = mapCheckData.get(temprec);
            }
            if(verify == true){  
                return verify; 
            }
        }
        return verify;        
    }
}