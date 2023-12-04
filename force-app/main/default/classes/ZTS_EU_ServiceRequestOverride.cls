/*************************************************************************************
* Name          :    ZTS_EU_ServiceRequestOverride .
* Description   :    Override the Close Service Request.
* Author        :    Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
4/16/2014       Teresa S                    Created
5/25/2014        Sunil K                Added pre-populate of Market logic
**************************************************************************************/

public with sharing class ZTS_EU_ServiceRequestOverride {
     public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
     public String retURL = '';
     public string recordTypeId = '';
     public String userDefaultMarket = '';
     public ZTS_EU_ServiceRequestOverride(ApexPages.StandardController controller) {
    
        userDefaultMarket = [select id,ZTS_EU_Market__c from user where id = : UserInfo.getUserID() AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Market__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        } 
        if(ApexPages.currentPage().getParameters().containskey('RecordType')){
            recordTypeID  =  ApexPages.currentPage().getParameters().get('RecordType');
        }  
    }
    
    public pagereference redirect(){
      
        Schema.DescribeSObjectResult result = Case.SObjectType.getDescribe();
        PageReference redirectedPage   = null;
        String url ='';         
        url =   retURL + '/s'; 
        url = url + '?cas7=Closed';
        
        if(retURL != ''){       
            url = url + '&retURL='+retURL;
        }
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        redirectedPage = new PageReference(url);        
       redirectedPage.setRedirect(true);         
       return redirectedPage;
    } 
    
      /***********
        * Method name  : serviceRedirect
        * Description  : Redirect to standard case edit page with user's market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference serviceRedirect(){
        String marketId = '';
        ZTS_EU_Field_ID__c fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_ServiceReq_MarketID');
        if(fieldId != null){
            marketId = fieldId.ZTS_EU_ID__c;
        }
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/500/e';         
        url = url + '?'+marketId+'='+userDefaultMarket; 
        if(recordTypeID  != ''){
             url = url + '&RecordType='+recordTypeID;
        }
        url = url + '&retURL='+retURL;
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        redirectedPage = new PageReference(url);        
        redirectedPage.setRedirect(true);         
        return redirectedPage; 
    }   
       
}