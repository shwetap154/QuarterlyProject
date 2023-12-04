public with sharing class NewAttendeeController {
    /****************************************
    VARIABLES
    *****************************************/
    String accID = ApexPages.currentpage().getparameters().get('ID');
    Public List<Contact> relatedContact{get;set;}
    
    public NewAttendeeController(ApexPages.StandardController controller) {
        relatedContact = [Select id,lastname,firstname,accountID from contact where accountId = :accID AND ZTS_EU_Market__c = 'United States']; 
    }

}