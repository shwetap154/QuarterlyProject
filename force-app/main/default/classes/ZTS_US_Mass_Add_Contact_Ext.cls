/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_Mass_Add_Account_Ext
 * Description      : The class acts as an extension for the mass add account page
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 5th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Vidya Das               05/21/2014          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_US_Mass_Add_Contact_Ext 
{
    public ZTS_Events__c currentEventsRecord {get;set;}
    public String eventId   {get;set;}
    public Id ContactId;
    public List<Account> showAccounts{get;set;}
    public ZTS_US_Mass_Add_Contact_Ext(ApexPages.StandardController controller)
    {
        currentEventsRecord = (ZTS_Events__c)controller.getRecord();
        /*if(ApexPages.currentPage().getParameters().containsKey('isError')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Account(s) has already been added to the Event'));
        }*/
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            eventId = ApexPages.currentPage().getParameters().get('Id');
           currentEventsRecord = [select Name, ZTS_US_Name__c from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c != 'United States'];
        }
    }
    
}