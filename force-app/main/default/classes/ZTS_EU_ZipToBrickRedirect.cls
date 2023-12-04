/*************************************************************************************
* Name          :    ZTS_EU_ZipToBrickRedirect
* Description   :    Override the new button.
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/20/2014       Chandra            Created

**************************************************************************************/
public with sharing class ZTS_EU_ZipToBrickRedirect{
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultCon{get;set;}
    public String userDefaultMar{get;set;}
 //   public Static final string RECORDTYPE_STR = 'RecordType';   
    public List<String> availableRecIds=new List<String>();
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public String retURL = '';    
 //   public string recordTypeId = '';
    
    /***********
        * Method name  : ZTS_EU_ZipToBrickRedirect
        * Description  : Get the Market details of logged-in user
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_ZipToBrickRedirect(ApexPages.StandardController controller) {         
        
 //       userDefaultCon = [select id,Default_Country__c from user where id = : UserInfo.getUserID() AND ZTS_EU_Market__c != 'United States'].Default_Country__c;
        userDefaultMar = [select id,ZTS_EU_Market__c from user where id = : UserInfo.getUserID() AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Market__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }
//        if(ApexPages.currentPage().getParameters().containskey('RecordType')){
//            recordTypeID  =  ApexPages.currentPage().getParameters().get('RecordType');
//        }  
    }

    /***********
        * Method name  : ztbRedirect
        * Description  : Redirect to Zip to Brick edit page with user's Market information.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public pagereference ztbRedirect(){
   //     String countryId = '';
        String marketId = '';        
   //     ZTS_EU_Field_ID__c fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Country__c');
        ZTS_EU_Field_ID__c fieldId1 = ZTS_EU_Field_ID__c.getValues('ZTS_EU_ZTB_Market_Field_Id');
         
 //       if(fieldId != null){
 //           countryId = fieldId.ZTS_EU_ID__c;
 //           system.debug('countryId*******>'+countryId);
 //       }
        if(fieldId1 != null){
            marketId = fieldId1.ZTS_EU_ID__c;
            system.debug('marketId*******>'+marketId);
        }
        Schema.DescribeSObjectResult r = ZTS_GL_ZipToBrick__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/'+keyPrefix+'/e';         
        url = url + '?'+marketId+'='+userDefaultMar;       
   //     url = url +'&'+marketId+'='+userDefaultMar;
       
 //       if(recordTypeID  != ''){
 //            url = url + '&RecordType='+recordTypeID;
 //       }
        url = url + '&retURL='+retURL;
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        System.debug('##### url string '+url);
        redirectedPage = new PageReference(url);        
        redirectedPage.setRedirect(true);         
        return redirectedPage;
    } 
   
}