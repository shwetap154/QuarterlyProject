/*************************************************************************************
* Name          :    ZTS_EU_TerritoryRedirect
* Description   :    Override the new button.
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/20/2014       Chandra           Created

**************************************************************************************/
public with sharing class ZTS_EU_TerritoryRedirect{
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultCon{get;set;}
    public String userDefaultMar{get;set;}
    public List<String> availableRecIds=new List<String>();
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public String retURL = '';    
    
    /***********
        * Method name  : ZTS_EU_TerritoryRedirect
        * Description  : Get the Market details of logged-in user
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_TerritoryRedirect(ApexPages.StandardController controller) {         
        userDefaultMar = [select id,ZTS_EU_Market__c from user where id = : UserInfo.getUserID()].ZTS_EU_Market__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }
    }

    /***********
        * Method name  : trrRedirect
        * Description  : Redirect to Territory edit page with user's Market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference trrRedirect(){
        String marketId = '';        
        ZTS_EU_Field_ID__c fieldId1 = ZTS_EU_Field_ID__c.getValues('ZTS_EU_TRR_Market_Field_Id');
        if(fieldId1 != null){
            marketId = fieldId1.ZTS_EU_ID__c;
            system.debug('marketId*******>'+marketId);
        }
        Schema.DescribeSObjectResult r = ZTS_EU_Territory__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/'+keyPrefix+'/e';         
        url = url + '?'+marketId+'='+userDefaultMar;       
        url = url + '&retURL='+retURL;
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        redirectedPage = new PageReference(url);        
        redirectedPage.setRedirect(true);         
        return redirectedPage;
    } 

    /***********
        * Method name  : backToView
        * Description  : Redirect to Time Off Territory listview page.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public Pagereference backToView() {
        PageReference listViewUrl = Test.isRunningTest() ? ApexPages.currentPage() : new ApexPages.Action('{!List}').invoke();
        listViewUrl.setRedirect(true);
        return listViewUrl;
    }
   
}