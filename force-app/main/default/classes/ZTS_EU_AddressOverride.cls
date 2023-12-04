/*************************************************************************************
* Name          :    ZTS_EU_AddressOverride .
* Description   :    Override the new button.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/7/2014       Sunil            Created

**************************************************************************************/

public class ZTS_EU_AddressOverride {
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultCon;
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public String accID= '';
    public String accountName;
    public String recordType='';
    public String retURL = '';
    public ZTS_EU_AddressOverride(ApexPages.StandardController controller) {
    
        userDefaultCon = [select id,Default_Country__c from user where id = : UserInfo.getUserID()].Default_Country__c;        
        if(ApexPages.currentPage().getParameters().containskey('accId')){
          accID = ApexPages.currentPage().getParameters().get('accId');          
        }
        
        if(ApexPages.currentPage().getParameters().containskey('RecordType')){
          recordType = ApexPages.currentPage().getParameters().get('RecordType');          
        }
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        } 
    }
    
    public pagereference addRedirect(){
    	
    	String countryId = '';
    	String accName = '';
    	String acclkID ='';
        ZTS_EU_Field_ID__c cfieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Address_Country__c');
        if(cfieldId != null)
        	countryId = cfieldId.ZTS_EU_ID__c;
        
        ZTS_EU_Field_ID__c accfieldName = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Add_AccountName');
        if(accfieldName != null)
        	accName = accfieldName.ZTS_EU_ID__c;
        
        ZTS_EU_Field_ID__c accfieldID = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Add_AccountID');
        if(accfieldID != null)
        	acclkID = accfieldId.ZTS_EU_ID__c;
        Schema.DescribeSObjectResult result = Address__c.SObjectType.getDescribe();
        PageReference redirectedPage   = null;
        String url ='';         
        url =  '/' + result.getKeyPrefix() + '/e'; 
        url = url + '?'+countryId+'='+userDefaultCon;
        if(accID != ''){
            accountName = [select id,name from account where id = :accID].name;
            String encodedName = EncodingUtil.urlEncode(accountName, 'UTF-8');
            url = url + '&'+accName+'='+encodedName;
            url = url + '&'+acclkID+'='+accID;
        }
        if(recordType != ''){       
            url = url + '&RecordType='+recordType;
        }
        if(retURL != ''){       
            url = url + '&retURL='+retURL;
        }
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        redirectedPage = new PageReference(url);        
       redirectedPage.setRedirect(true);         
       return redirectedPage;
    } 
       
}