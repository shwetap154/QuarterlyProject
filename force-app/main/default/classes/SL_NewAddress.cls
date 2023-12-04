/**
* @ClassName    : SL_NewAddress 
* @JIRATicket   : LIGHTNI-32
* @CreatedOn    : 26th March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : Akshay Agrawal for(LIGHTIN-1170)
* @Description  : Controller to fetch the URL for the New Address on click ligthning list button.
*/

public with sharing class SL_NewAddress {
    public String strRecordTypeId           {   get; set;   }
    public String strFieldAPIName           {   get; set;   }
    public String strFieldValue             {   get; set;   }
    public String strcountryValue           {   get; set;   }
    
    public SL_NewAddress(ApexPages.StandardSetController controller) {
        strRecordTypeId = strFieldAPIName = strFieldValue = strcountryValue ='';
    }
    
    /***********
      * Method name  : fetchRecordURL
      * Description  : This method will fetch the url string for the New ligthning button to redirect. Only available for Account/Contact
      * Return Type  : NA
      * Parameters   : NA.
    ***********/
    public void fetchRecordURL() {
        Id parentObjectId = apexpages.currentpage().getparameters().get('id');

        String strName = parentObjectId.getSObjectType().getDescribe().getName() == 'Account' ? 'ZTS_EU_Account_Address' : 
                    	(parentObjectId.getSObjectType().getDescribe().getName() == 'Contact' ? 'ZTS_EU_Contact_Address' : null);
                            
        strRecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get(strName).getRecordTypeId();
        
        strcountryValue = [SELECT ZTS_EU_Country__c FROM User WHERE Id =:UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Country__c;
        
        if(strName == 'ZTS_EU_Account_Address' && parentObjectId != null) 
        {
            Account objAccount = [Select Id,Name From Account Where Id =: parentObjectId AND ZTS_EU_Market__c != 'United States'];
            String strEncodeURL = EncodingUtil.urlEncode(objAccount.Name,'UTF-8');
            strFieldAPIName = 'ZTS_EU_Account__c';
            strFieldValue = objAccount.Id;
            
        }
        else if(strName == 'ZTS_EU_Contact_Address') {
            Contact objContact = [Select Id, Name From Contact Where Id =: parentObjectId AND ZTS_EU_Market__c != 'United States'];
            String strEncodeURL = EncodingUtil.urlEncode(objContact.Name,'UTF-8');
            strFieldAPIName = 'ZTS_EU_Contact__c';
            strFieldValue = objContact.Id;
        }
    }
}