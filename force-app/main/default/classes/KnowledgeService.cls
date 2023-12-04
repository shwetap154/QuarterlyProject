/**
Class Name	    : KnowledgeService
Description	    : Service Class created as part of TPDEV-431 for Knowledge. 
Created By		: Sibin Kuriakose
Created Date	: 03-29-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-30-2023	 Created methods to get Data categories from Knowledge and verify they are populated correctly
*/

public With Sharing class KnowledgeService {

    /**     * @Description As part of TPDEV-431 this method will get Data categories that are related to a Knowledge Article 
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
    public static Map<Id, List<String>> getDataCategory(List<Id> recordId){
        List<FAQ__DataCategorySelection> lstdataCatdetail = DataCategoriesSelector.selectAllDataCategoriesByParentId(recordId);
        Map<Id, List<String>> mapKnowDataCat = new Map<Id, List<String>>();

        for(Id tempId : recordId){
            if(!mapKnowDataCat.containsKey(tempId)){
                mapKnowDataCat.put(tempId, new List<String>());
            }
        }
        for(FAQ__DataCategorySelection tempDataCatdetail : lstdataCatdetail){
            if(mapKnowDataCat.containsKey(tempDataCatdetail.ParentId)){
                mapKnowDataCat.get(tempDataCatdetail.ParentId).add(tempDataCatdetail.DataCategoryName);
            }
        }
        return mapKnowDataCat;
    }

    /**     * @Description As part of TPDEV-431 this method will Check if Data categories are Populated correctly and return a Map of Id,Boolean
			* @Author      Sibin Kuriakose @ Zoetis Inc | 03-30-2023 
    */
    public static Map<Id, Boolean> compDataCategory(List<Id> recordId, Map<Id,List<String>> mapKnowledgeID){
        Map<Id, Boolean> mapKnowDataCatBool = new Map<Id, Boolean>();
        Integer counter = 0;
        List<FAQ__kav> lstKnowdetail = KnowledgeSelector.selectKnowledgeById(recordId);

        for(FAQ__kav tempKnowdetail : lstKnowdetail){
            if(mapKnowledgeID.containsKey(tempKnowdetail.Id)){
                List<String> strTemp = mapKnowledgeID.get(tempKnowdetail.Id);
                counter = 0;
                list<String> lstKnowData = tempKnowdetail.Data_Category__c.split(',');
                list<String> lstKnowDataCount  = tempKnowdetail.Data_Category__c.split(',');
                integer index = 0;
                for(String templstKnowData : lstKnowData)
                { 
                    if(templstKnowData == 'US Customer Care' && lstKnowDataCount[index] == 'US Customer Care'){
                        lstKnowDataCount.remove(index);
                        index --;
                    }
                    index++;
                }

                for(String tempStr : strTemp)
                {  
                    lstKnowData = tempKnowdetail.Data_Category__c.split(',');
                    index = 0;
                    for(String  tempStrKnowData : lstKnowData){
                        if(tempStr.deleteWhitespace() == tempStrKnowData.deleteWhitespace()){
                            counter++;
                            if(tempStr == 'All'){
                                tempKnowdetail.Data_Category__c = tempKnowdetail.Data_Category__c.remove('All');
                            }
                        }
                    }                    
                }
                strTemp = mapKnowledgeID.get(tempKnowdetail.Id);
                if(strTemp.size() == counter && lstKnowDataCount.size() == counter){
                    mapKnowDataCatBool.put(tempKnowdetail.Id, false); 
                }
                else{
                    mapKnowDataCatBool.put(tempKnowdetail.Id, true); 
                }
            }
        }
        return mapKnowDataCatBool;
    }
}