/*************************************************************************************
* Name          :    ZTS_EU_AccountRedirect .
* Description   :    Override the new button.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/7/2014       Sunil                       Created
5/20/2014       Chandra                    Added Market pre-populate

**************************************************************************************/
public with sharing class ZTS_EU_AccountRedirect {
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
        * Method name  : ZTS_EU_AccountRedirect
        * Description  : Get the country, market details of logged-in user and recordtype id.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_AccountRedirect(ApexPages.StandardController controller) {         
        User user = [select id,Default_Country__c, ZTS_EU_Market__c from user where id = : UserInfo.getUserID()];
        userDefaultCon = user.Default_Country__c;
        userDefaultMar = user.ZTS_EU_Market__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }
        if(ApexPages.currentPage().getParameters().containskey('RecordType')){
            recordTypeID  =  ApexPages.currentPage().getParameters().get('RecordType');
        }  
    }

    /***********
        * Method name  : accRedirect
        * Description  : Redirect to standard account edit page with user's country & Market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference accRedirect(){
        String countryId = '';
        String marketId = '';        
        ZTS_EU_Field_ID__c fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Country__c');
        ZTS_EU_Field_ID__c fieldId1 = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Account_Market_Field_Id');
         
        if(fieldId != null){
            countryId = fieldId.ZTS_EU_ID__c;
        }
        if(fieldId1 != null){
            marketId = fieldId1.ZTS_EU_ID__c;
        }
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/001/e';         
        url = url + '?'+countryId+'='+userDefaultCon;       
        url = url +'&'+marketId+'='+userDefaultMar;
       
        if(recordTypeID  != ''){
             url = url + '&RecordType='+recordTypeID;
        }
        url = url + '&retURL='+retURL;
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        
        if(url.startsWith('/'))
            url = url.replaceFirst('/+',''); 
        
        redirectedPage = new PageReference('/'+url);
        redirectedPage.setRedirect(true);         
        return redirectedPage;
    } 
   
}