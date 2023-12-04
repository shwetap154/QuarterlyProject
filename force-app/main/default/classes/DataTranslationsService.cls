/**
* @description       : This is service class for DataTranslations
* @author            : Suprabha Acharya @ Zoetis Inc
* @group             : 
* @last modified on	: 02-13-2023
* @last modified by  : Suprabha Acharya @ Zoetis Inc
Modification Log:
----------------------------------------------------------------------------
Developer	           Date		   Description
Acharya,Suprabha    02-13-2023    TPDEV-168:Block Creation of Duplicate Data Translations for the same Language/Comp/Skill Combo
----------------------------------------------------------------------------
*/

public With Sharing class DataTranslationsService {
    
    /**     
* @description: This Method to Check for Existing combinations of Language and Competency or Language and Skill     
* @author     : Acharya,Suprabha @ Zoetis Inc | 02-13-2023   
* @param      : lstDataTrans 
*/   
    public static void dataTransValidations(List<Data_Translation__c> lstDataTrans, Map<Id, Data_Translation__c> mapOldDataTrans) {
        Map<Id, String> mapSkillIdLanguage = new Map<Id, String>();
        Map<Id, String> mapCompIdLanguage = new Map<Id, String>();        
        for(Data_Translation__c objDataTranslation : lstDataTrans) {
            if(objDataTranslation.Language__c != null && objDataTranslation.Competency__c != null) {
                mapCompIdLanguage.put(objDataTranslation.Competency__c, objDataTranslation.Language__c); 
            }  
            if(objDataTranslation.Language__c != null && objDataTranslation.Skill__c != null) {
                mapSkillIdLanguage.put(objDataTranslation.Skill__c, objDataTranslation.Language__c);
            }
        }
        
        Map<String,Data_Translation__c> mapExistingDataTrans = new Map<String,Data_Translation__c>();
        for(Data_Translation__c objDataTrans : DataTranslationsSelector.selectDataTransBySkill(mapCompIdLanguage.keySet(), mapSkillIdLanguage.keySet())) {
            if(objDataTrans.Skill__c != null) {
                String strSkillIdLanguage = objDataTrans.Skill__c+objDataTrans.Language__c;
                mapExistingDataTrans.put(strSkillIdLanguage,objDataTrans);
            } else if(objDataTrans.Competency__c != null) {
                String strCompIdLanguage = objDataTrans.Competency__c+objDataTrans.Language__c;
                mapExistingDataTrans.put(strCompIdLanguage,objDataTrans);
            }
            else{
            }
        }

        for(Data_Translation__c objDT : lstDataTrans) {
            String strNewDTCompIdLang = objDT.Competency__c != null ? objDT.Competency__c + objDT.Language__c : null;
            String strNewDTSkillIdLang = objDT.Skill__c != null ? objDT.Skill__c + objDT.Language__c : null;
            
            if(mapOldDataTrans == null && 
               ((strNewDTCompIdLang != null && mapExistingDataTrans.containsKey(strNewDTCompIdLang) && mapExistingDataTrans.get(strNewDTCompIdLang).Language__c == objDT.Language__c) || 
                (strNewDTSkillIdLang != null && mapExistingDataTrans.containsKey(strNewDTSkillIdLang) && mapExistingDataTrans.get(strNewDTSkillIdLang).Language__c == objDT.Language__c))                                      
              ){
                  String Id = strNewDTCompIdLang != null ? mapExistingDataTrans.get(strNewDTCompIdLang).Id : mapExistingDataTrans.get(strNewDTSkillIdLang).Id;
                  objDT.addError(System.Label.DuplicateDataTransError + ' : ' +Id );
              }
            if(mapOldDataTrans != null && 
               (mapOldDataTrans.get(objDT.id).Competency__c != objDT.Competency__c || mapOldDataTrans.get(objDT.id).Skill__c != objDT.Skill__c || mapOldDataTrans.get(objDT.id).Language__c != objDT.Language__c) &&
               ((strNewDTCompIdLang != null && mapExistingDataTrans.containsKey(strNewDTCompIdLang) && mapExistingDataTrans.get(strNewDTCompIdLang).Language__c == objDT.Language__c) || 
                (strNewDTSkillIdLang != null && mapExistingDataTrans.containsKey(strNewDTSkillIdLang) && mapExistingDataTrans.get(strNewDTSkillIdLang).Language__c == objDT.Language__c))                                      
              ){
                  String Id = strNewDTCompIdLang != null ? mapExistingDataTrans.get(strNewDTCompIdLang).Id : mapExistingDataTrans.get(strNewDTSkillIdLang).Id;
                  objDT.addError(System.Label.DuplicateDataTransError + ' : ' +Id );
              }
        }             
    }
}