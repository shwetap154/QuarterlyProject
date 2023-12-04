/*************************************************************************************
* Name          :    ZTS_EU_DescItemRedirect
* Description   :    Override the new button.
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/20/2014         Chandra                   Created

**************************************************************************************/
public with sharing class ZTS_EU_DescItemRedirect{
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultCon{get;set;}
    public String userDefaultMar{get;set;}

    public List<String> availableRecIds=new List<String>();
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public String retURL = '';    

    
    /***********
        * Method name  : ZTS_EU_DescItemRedirect
        * Description  : Get the market details of logged-in user.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_DescItemRedirect(ApexPages.StandardController controller) {         
        
        userDefaultMar = [SELECT Id,ZTS_EU_Market__c 
                            FROM User 
                            WHERE Id = : UserInfo.getUserID()].ZTS_EU_Market__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }
    }

    /***********
        * Method name  : descitemRedirect
        * Description  : Redirect to Brick To Territory edit page with user's market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference descitemRedirect(){

        String marketId = '';        

        ZTS_EU_Field_ID__c fieldId1 = ZTS_EU_Field_ID__c.getValues('ZTS_EU_DiscItem_Market_Field_Id');
         

        if(fieldId1 != null){
            marketId = fieldId1.ZTS_EU_ID__c;
            system.debug('marketId*******>'+marketId);
        }
        Schema.DescribeSObjectResult r = ZTS_EU_Discussion_Item__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/'+keyPrefix+'/e';         
        url = url + '?'+marketId+'='+userDefaultMar;       

        url = url + '&retURL='+retURL;
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        System.debug('##### url string '+url);
        redirectedPage = new PageReference(url);        
        redirectedPage.setRedirect(true);         
        return redirectedPage;
    } 

    public Pagereference backToView() {
        PageReference listViewUrl = Test.isRunningTest() ? ApexPages.currentPage() : new ApexPages.Action('{!List}').invoke();
        listViewUrl.setRedirect(true);
        return listViewUrl;
    }
   
}