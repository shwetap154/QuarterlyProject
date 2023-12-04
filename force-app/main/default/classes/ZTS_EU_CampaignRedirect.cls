/*************************************************************************************
* Name          :    ZTS_EU_CampaignRedirect .
* Description   :    Override the new button.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/7/2014       Sunil                       Created
5/20/2014       Chandra                    Added Market pre-populate

**************************************************************************************/
public with sharing class ZTS_EU_CampaignRedirect {
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultCon{get;set;}
    public String userDefaultMar{get;set;}
    public Static final string RECORDTYPE_STR = 'RecordType';   
    public List<String> availableRecIds=new List<String>();
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public String retURL = '';    
    public string recordTypeId = '';
    
    /***********
        * Method name  : ZTS_EU_CampaignRedirect
        * Description  : Get the country, market details of logged-in user and recordtype id.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_CampaignRedirect(ApexPages.StandardController controller) {         
        
         userDefaultMar = [select id,ZTS_EU_Market__c from user where id = : UserInfo.getUserID()].ZTS_EU_Market__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }
        if(ApexPages.currentPage().getParameters().containskey('RecordType')){
            recordTypeID  =  ApexPages.currentPage().getParameters().get('RecordType');
        }  
    }

    /***********
        * Method name  : campRedirect
        * Description  : Redirect to standard account edit page with user's country & Market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference campRedirect(){
        String marketId = '';        
        ZTS_EU_Field_ID__c fieldId1 = ZTS_EU_Field_ID__c.getValues('ZTS_EU_CAMP_Market_Field_Id');
         
        if(fieldId1 != null){
            marketId = fieldId1.ZTS_EU_ID__c;
        }
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/701/e';         
        url = url + '?'+marketId+'='+userDefaultMar;       
       
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