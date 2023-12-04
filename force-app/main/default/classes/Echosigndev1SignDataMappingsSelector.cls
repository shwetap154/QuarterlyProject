/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-09-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   6-22-2023    Padma Nerella @ Zoetis Inc  Add selectByName
**/
public inherited sharing class Echosigndev1SignDataMappingsSelector {

    /**
     * Retrieve echosign_dev1__SIGN_Data_Mapping__c with the Name
     * @param List<String> echoSignDev1Names
     * @return  `List<echosign_dev1__SIGN_Data_Mapping__c>`
     */
    public static List<echosign_dev1__SIGN_Data_Mapping__c> selectByName(Set<String> echoSignDev1Name){
        return [SELECT Id, Name
        FROM echosign_dev1__SIGN_Data_Mapping__c
        WHERE Name =:echoSignDev1Name];
    }
}