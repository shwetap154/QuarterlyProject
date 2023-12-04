/**
* @ClassName    : SL_SubmitCoaching 
* @JIRATicket   : LIGTHTNI-43
* @CreatedOn    : 2nd April, 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to update the ZTS_EU_Coaching__c object rocrd field on click of ligthning action.
*/
public with sharing class SL_SubmitCoaching 
{   
    /***********
      * Method name  : updateCoaching
      * Description  : This method will update the Coaching record.
      * Return Type  : NA
      * Parameters   : String strRecordId.
    ***********/ 
    @AuraEnabled
    public static void updateCoaching(String strRecordId)
    {
        ZTS_EU_Coaching__c objCoaching = new ZTS_EU_Coaching__c(Id = strRecordId, ZTS_EU_Status__c= 'Pending Colleague');
        update objCoaching;
    }
}