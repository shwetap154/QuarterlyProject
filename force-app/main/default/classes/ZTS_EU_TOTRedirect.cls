/*************************************************************************************
* Name          :    ZTS_EU_TOTRedirect.
* Description   :    Override the new button.
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/20/2014         Chandra                   Created

**************************************************************************************/
public with sharing class ZTS_EU_TOTRedirect{
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultMar{get;set;}
    public List<String> availableRecIds=new List<String>();
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public String retURL = '';    

    
    /***********
        * Method name  : ZTS_EU_TOTRedirect
        * Description  : Get the market details of logged-in user.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_TOTRedirect(ApexPages.StandardController controller) {         
        

        userDefaultMar = [select id,ZTS_EU_Market__c from user where id = : UserInfo.getUserID()].ZTS_EU_Market__c;
        
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }

    }

    /***********
        * Method name  : totRedirect
        * Description  : Redirect to Time Off Territory edit page with user's market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference totRedirect()
    {
        String marketId = '';        
        ZTS_EU_Field_ID__c fieldId1 = ZTS_EU_Field_ID__c.getValues('ZTS_EU_TOT_Market_Field_Id');
         
         if(fieldId1 != null){
            marketId = fieldId1.ZTS_EU_ID__c;
        }
        Schema.DescribeSObjectResult r = Time_Out_of_Territory__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/'+keyPrefix+'/e';         
        url = url + '?'+marketId+'='+userDefaultMar;       
        System.debug('url ::::: '+url);
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