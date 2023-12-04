/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   6-22-2023    Padma Nerella @ Zoetis Inc  Added Lead__r.Id in the query
 * 1.1   7-27-2023    Ethan Hirsch @ Zoetis Inc   Added Order by Id so that Vets are returned in the same order when
 *                                                generating an NOA PDF and when sending the PDF
 * 1.1   7-27-2023    Padma Nerella @ Zoetis Inc  Removed Lead__r.Id from the query in selectByLeadId method TPDEV-1546
**/
public with sharing class VeterinarianInformationSelector {
  public static List<Veterinarian_Information__c> selectByLeadId(
    Set<Id> recordIds
  ) {
    return [
      SELECT
        Id,
        Name,
        DEA__c,
        Veterinarian_Role__c,
        Lead__c,
        Delete_Record__c,
        Primary__c,
        State_License__c,
        Veterinarian_Email__c,
        Veterinarian_First_Name__c,
        Veterinarian_Last_Name__c,
        Veterinarian_Signature_Tag__c,
        OwnerId
      FROM Veterinarian_Information__c
      WHERE Lead__c = :recordIds
      Order by Id
    ];
  }
}