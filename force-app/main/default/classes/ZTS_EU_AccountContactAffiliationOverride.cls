/*************************************************************************************
* Name          :    ZTS_EU_AccountContactAffiliationOverride .
* Description   :    Override the new button.
* Author        :    Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/19/2014       Teresa            Created

**************************************************************************************/

public with sharing class ZTS_EU_AccountContactAffiliationOverride {
    /*****************************************
    VARIABLES
    ******************************************/
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    
    public String retURL      = '';
    public String accId       = '';
    public String accName     = '';
    public String conId       = '';
    public String conName     = '';
    public String accountId   = '';
    public String accountName = '';
    public String contactId   = '';
    public String contactName = '';
    
    public ZTS_EU_AccountContactAffiliationOverride(ApexPages.StandardController controller) {
        ZTS_EU_Field_ID__c fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_Name_Field');
        contactName = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_Id_Field');
        contactId   = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Account_Name_Field');
        accountName = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Account_Id_Field');
        accountId   = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        if(ApexPages.currentPage().getParameters().containskey(accountId)){
          accID = ApexPages.currentPage().getParameters().get(accountId);
          accName = ApexPages.currentPage().getParameters().get(accountName);         
        }
         
        if(ApexPages.currentPage().getParameters().containskey(contactId)){
          conId = ApexPages.currentPage().getParameters().get(contactId);
          conName = ApexPages.currentPage().getParameters().get(contactName);         
        }
        
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        } 
        
    }
     /***********
            * Method name  : addRedirect
            * Description  : This will redirect the page with overriden parameters.
            * Return Type  : None.
            * Parameters   : none.
      ***********/
    
    public pagereference addRedirect(){
       Schema.DescribeSObjectResult result = ZTS_EU_Affiliations__c.SObjectType.getDescribe();
        PageReference redirectedPage   = null;
        String url ='';         
        url =  '/' + result.getKeyPrefix() + '/e'; 
        url = url + '?Name=-Autopopulates on Save-';
        
        if(retURL != ''){       
            url = url + '&retURL='+retURL;
        }
        if(accID != ''){
            url = url + '&'+accountName+'='+accName;
            url = url + '&'+accountId+'='+accID;
        }
        
        if(conId != ''){
            url = url + '&'+contactName+'='+conName;
            url = url + '&'+contactId+'='+conId;
        }
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        redirectedPage = new PageReference(url);        
       redirectedPage.setRedirect(true);         
       return redirectedPage;
    } 
       
}