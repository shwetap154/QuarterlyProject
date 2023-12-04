/**
* @ClassName    : SL_PrimaryContactOfAccount 
* @JIRATicket   : LIGTHTNI-37
* @CreatedOn    : 28th March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to update the Primary contact on the account record.
*/
public with sharing class SL_PrimaryContactOfAccount 
{
    /***********
      * Method name  : updateAccount
      * Description  : This method will update the primary address field on the Account record.
      * Return Type  : NA
      * Parameters   : String strRecordId.
    ***********/ 
    @AuraEnabled
    public static void updateAccount(String strRecordId)
    {
         ZTS_EU_Affiliations__c objAffiliation = [Select Id, ZTS_EU_Contact__c, ZTS_EU_Account__c 
                                                   From ZTS_EU_Affiliations__c 
                                                   Where Id =: strRecordId AND ZTS_EU_Market_from_Parent__c != 'United States'];
        
        //Bypass the Account Trigger when updating Accounts (TPDEV-80) 
        DispatchTriggerHandler.bypass('AccountTriggerHandler');                                           
        Account objAccount = new Account(Id = objAffiliation.ZTS_EU_Account__c, ZTS_EU_Primary_Contact__c=objAffiliation.ZTS_EU_Contact__c );
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        update objAccount;
    }
}