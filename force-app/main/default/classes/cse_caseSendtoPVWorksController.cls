/*
* Name: cse_CaseSendtoPvWorks
* Desciption: Contoller for cse_CaseSendtoPvWorks.Fetch the Email from Case Contact's Primary Reporter
* date Created:August 7, 2023
*/
public class cse_caseSendtoPVWorksController {

    @AuraEnabled(cacheable=true)
    public static string getPrimaryReporterEmail(string caseId) {
      try {
        Case_Contact__c caseContact = [
          SELECT
            Id,
            ZTS_US_Primary_Reporter__c,
            Email__c
          FROM Case_Contact__c
          WHERE Case__c = :caseID and ZTS_US_Primary_Reporter__c = true
        ];
          if(caseContact.Email__c == null){
              return null;
          }
          return caseContact.Email__c;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
       
      }
    }


}