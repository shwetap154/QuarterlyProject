/******************************************************************************************************************************************
 * Class Name   : CustomEventLWCController
 * Description  : Controller class for Request Payment Action 
 * Created By   : Slalom/Art Smorodin
 * Created Date : 26 April 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     04/26/2020          Created.
 *****************************************************************************************************************************************/

public with sharing class CustomEventLWCController {
    @AuraEnabled(cacheable=true)
    public static ZTS_Events__c getSingleRecord(String recordId) {
    return [
        SELECT Id, Payment_Requested__c, ZTS_US_Status__c,Specific_Payment_Information__c,ZTS_US_Number_of_Event_Account_Records__c,ZTS_US_Number_of_Event_Product_Records__c,
                ZTS_US_Total_Event_Invitees__c,No_of_speakers__c,ZTS_US_Event_Category__c
        FROM ZTS_Events__c
        WHERE Id =: recordId
        LIMIT 1
    ];
}
}