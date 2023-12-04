/****************************************************************************************************************************************** 
 * Class Name   : ZTS_US_ContactAddinsertfromAccount
 * Description  : This class contain operations to populate Contact address from Account Address details.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 * Created Date : 11 Mar 2014.
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Raghu                   03/11/2014           Created
*****************************************************************************************************************************************/
public with sharing class ZTS_US_ContactAddinsertfromAccount {
	
   /***********
    * Method name  : ContactAddinsertfromAccount
    * Description  : This method updates primary contact address information with Account Address details.
    * Return Type  : None.
    * Parameters   : AccId set and Contact List.
    ***********/
	public static void ContactAddinsertfromAccount(Set<Id> setAcc,List<Contact> lstcon)
    {

        //List<Account> lstAcnt = [Select id,Account.ZTS_US_Address_Line_1__c,Account.ZTS_EU_Address_Line_2__c,Account.ZTS_US_City__c, Account.ZTS_US_State_County__c,Account.ZTS_US_Zip_Postal_Code__c,Account.ZTS_US_Country__c from Account where Id IN : setAcc AND ZTS_EU_Market__c = 'United States'];
            List<Account> lstAcnt = [Select id,BillingStreet,BillingCity/*,BillingPostalCode,BillingCountry,BillingState,BillingStateCode,BillingCountryCode*/  from Account where Id IN : setAcc AND ZTS_EU_Market__c = 'United States'];
    
        Map<Id, Account> mpAcnt = new Map<Id, Account>(lstAcnt);
        
        for(Contact cont: lstCon){
        
        If(Cont.AccountId != null){
        
        Account acc = mpAcnt.get(cont.Accountid);
        cont.MailingCity=acc.BillingCity;
        cont.MailingStreet=acc.BillingStreet;
        //cont.MailingPostalCode=acc.BillingPostalCode;
        //cont.MailingCountry=acc.BillingCountry;
        //cont.MailingStateCode=acc.BillingStateCode ;
        //cont.MailingCountryCode=acc.BillingCountryCode; 
           
        
    }
    
    }

}



}