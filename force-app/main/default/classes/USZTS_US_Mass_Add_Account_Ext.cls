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
 * Sameep Agrawal           05/06/2014          Created 
*****************************************************************************************************************************************/
public with sharing class USZTS_US_Mass_Add_Account_Ext 
{
    public ZTS_Events__c currentEventsRecord    {get;set;}
    public String eventId                       {get;set;}
    public String accountPrefix                 {get;set;}
    public Id AccountId;
    public List<Account> showAccounts{get;set;}
    public USZTS_US_Mass_Add_Account_Ext(ApexPages.StandardController controller)
    {
        accountPrefix = '';
        currentEventsRecord = (ZTS_Events__c)controller.getRecord();
        System.debug(' ::: US ');
        if(ApexPages.currentPage().getParameters().containsKey('eventId')){
            eventId = ApexPages.currentPage().getParameters().get('eventId');
            currentEventsRecord = [select ZTS_EU_Market__c, Name, ZTS_US_Name__c from ZTS_Events__c where Id=: eventId];
        }
        if(ApexPages.currentPage().getParameters().containsKey('isError')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The selected Account(s) have already been added to the Event'));
            accountPrefix = Account.sObjectType.getDescribe().getKeyPrefix() + '';
        }
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            eventId = ApexPages.currentPage().getParameters().get('Id');
            currentEventsRecord = [select ZTS_EU_Market__c, Name, ZTS_US_Name__c from ZTS_Events__c where Id=: eventId];
        }

       
    }
    
    /***********
    * Method name  : redirect
    * Description  : This method is used to redirect to the INTL version of ZTS_US_Mass_Add_Account
    * Return Type  : PageReference.
    * Parameters   : None
    ***********/
    public PageReference redirect()
    {
       //US Call not returned in query above
       System.debug('currentEventsRecord ::: US '+currentEventsRecord);
       if( currentEventsRecord != null && currentEventsRecord.ZTS_EU_Market__c != 'United States')
       {
           PageReference pageRef = new PageReference('/apex/ZTS_US_Mass_Add_Account?Id=' + eventId);
           Map<String, String> passedParams = System.currentPageReference().getParameters(); //grab the parameters for the current page
           pageRef.getParameters().putAll(passedParams);
           pageRef.setRedirect(true);
           return pageRef;
       }
       else
       {
           return null;
       }
    }
}