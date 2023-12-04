/*************************************************************************************
* Name          :    ZTS_US_NewContractOverride .
* Description   :    Override the new button.
* Author        :    Ketan Prakash Singh
 
Modification Log
----------------

Date             Developer                Comments
---------------------------------------------------------------------------------------
08/14/2014       Ketan            Created

**************************************************************************************/

public with sharing class ZTS_US_NewContractOverride {
    /*****************************************
    VARIABLES
    ******************************************/
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public static final string accountId   = 'ctrc7_lkid';
    public static final string accountName = 'ctrc7';
    
    public String retURL      = '';
    public String accId       = '';
    public String accName     = '';
    

    public ZTS_US_NewContractOverride(ApexPages.StandardController controller) {
        
        if(ApexPages.currentPage().getParameters().containskey(accountId)){
          accID = ApexPages.currentPage().getParameters().get(accountId);
          accName = ApexPages.currentPage().getParameters().get(accountName);         
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
       Schema.DescribeSObjectResult result = Contract.SObjectType.getDescribe();
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
        
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        redirectedPage = new PageReference(url);        
       redirectedPage.setRedirect(true);         
       return redirectedPage;
    } 
       
}