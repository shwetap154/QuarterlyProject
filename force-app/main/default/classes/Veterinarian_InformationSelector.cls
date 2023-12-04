/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-08-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
**/
public inherited sharing class Veterinarian_InformationSelector {
    /**
     * Retrieve Veterinarian_Information by the related leadIds
     * @param leadIdSet 
     * @return  `List<Veterinarian_Information__c>`
     */
    public static List<Veterinarian_Information__c> selectVetInforListByLeadId(Set<Id> leadIdSet){
        return [SELECT ID, Lead__c, Veterinarian_Email__c
        FROM Veterinarian_Information__c
        WHERE Lead__c =:leadIdSet];
    }
}