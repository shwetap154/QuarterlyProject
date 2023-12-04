/**
* @ClassName    : SL_NewServiceRequestController 
* @JIRATicket   : LIGHTNI-1557
* @CreatedOn    : 30th August 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Controller to fetch the default data for the service request creation.
*/
public with sharing class SL_NewServiceRequestController {

    public String parentId = ApexPages.currentPage().getParameters().get('id');
    public String recordtypeId = ApexPages.currentPage().getParameters().get('RecordType');
    public String defaultValues {get; set;}
    public String caseRecordTypeId {get; set;}
    public String retURL = ApexPages.currentPage().getParameters().get('retURL');
    public Id pId = null;

    public SL_NewServiceRequestController(ApexPages.StandardSetController controller) {
        getDefaultData();
    }
    
    public SL_NewServiceRequestController(ApexPages.StandardController controller) {
        
        if(ApexPages.currentPage().getParameters().containskey('def_account_id'))
        	parentId = ApexPages.currentPage().getParameters().get('def_account_id');
        if(ApexPages.currentPage().getParameters().containskey('def_contact_id'))
        	parentId = ApexPages.currentPage().getParameters().get('def_contact_id');
        
        if(ApexPages.currentPage().getParameters().containskey('RecordType'))
            recordtypeId = ApexPages.currentPage().getParameters().get('RecordType');
        if(ApexPages.currentPage().getParameters().containskey('retURL'))
        	retURL = ApexPages.currentPage().getParameters().get('retURL');

        getDefaultData();
    }

    /***********
      * Method name  : redirectToURL
      * Description  : This method create the URL for setting the default value in classic view. 
      * Return Type  : PageReference
      * Parameters   : NA.
    ***********/
    public PageReference redirectToURL() {
        String userDefaultMar = [select id, ZTS_EU_Market__c from user where id = : UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Market__c;

        String URL = '/500/e?&nooverride=1';
        if(String.isNotBlank(parentId))
        	pId = (Id)parentId;
        
        URL += '&retURL=' + retURL;
        if(String.isNotBlank(userDefaultMar))
            URL += '&00NF000000CM832=' + userDefaultMar;

        // updated for multiple recordtype selection
        if(String.isNotBlank(recordtypeId))
            URL += '&RecordType=' + recordtypeId;

        if(pId != null && pId.getSobjectType() == Schema.Account.SObjectType) {
            Account objAcc = [SELECT Id, Name, ZTS_EU_Primary_Contact__c, ZTS_EU_Primary_Contact__r.Name FROM Account Where Id =:parentId AND ZTS_EU_Market__c != 'United States'];

            URL += '&cas4_lkid=' + parentId;
            URL += '&cas4=' + objAcc.Name;
            if(String.isNotBlank(objAcc.ZTS_EU_Primary_Contact__c)) {
                URL += '&cas3=' + objAcc.ZTS_EU_Primary_Contact__r.Name;
                URL += '&cas3_lkid=' + objAcc.ZTS_EU_Primary_Contact__c;
            }

        } else if(pId != null && pId.getSobjectType() == Schema.Contact.SObjectType) {
            Contact objCon = [SELECT Id, Name, AccountId, Account.Name FROM Contact Where Id =:parentId AND ZTS_EU_Market__c != 'United States'];
            
            URL += '&cas3_lkid=' + parentId;
            URL += '&cas3=' + objCon.Name;
            URL += '&cas4=' + objCon.Account.Name;
            URL += '&cas4_lkid=' + objCon.AccountId;
        }
        PageReference redirectedPage = new PageReference(URL); 
        redirectedPage.setRedirect(true);        
        return redirectedPage;
    }

    /***********
      * Method name  : backToView
      * Description  : This method will exit from the record creation wizard.
      * Return Type  : PageReference
      * Parameters   : NA.
    ***********/
    public PageReference backToView() {
        PageReference pageRef = !Test.isRunningTest() ? ( String.isNotBlank(parentId) ? new PageReference('/'+parentId): new ApexPages.Action('{!List}').invoke() ) 
            										  : ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }

    /***********
      * Method name  : getDefaultData
      * Description  : This method create the default value JSOn for the lightning experience. 
      * Return Type  : NA
      * Parameters   : NA.
    ***********/
    private void getDefaultData() {
        Map<String, Object> mapDefaultValues = new Map<String, Object>();
        caseRecordTypeId = String.isNotBlank(recordtypeId) ? '\'' +recordtypeId +'\'': 'null';
        if(String.isNotBlank(parentId))
        	pId = (Id)parentId;
        
        String userDefaultMar = [select id, ZTS_EU_Market__c from user where id = : UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'].ZTS_EU_Market__c;
        
        if(pId != null && pId.getSobjectType() == Schema.Account.SObjectType) {
            Account objAcc = [SELECT Id, ZTS_EU_Primary_Contact__c FROM Account Where Id =:parentId AND ZTS_EU_Market__c != 'United States'];
            mapDefaultValues.put('AccountId', objAcc.Id);
            if(String.isNotBlank(objAcc.ZTS_EU_Primary_Contact__c))
                mapDefaultValues.put('ContactId', objAcc.ZTS_EU_Primary_Contact__c) ;
            
        } else if(pId != null && pId.getSobjectType() == Schema.Contact.SObjectType) {
            Contact objCon = [SELECT Id, AccountId FROM Contact Where Id =:parentId AND ZTS_EU_Market__c != 'United States'];
            mapDefaultValues.put('AccountId', objCon.AccountId);
            mapDefaultValues.put('ContactId', objCon.Id) ;
        }
        
        // updated for multiple recordtype selection
        if(String.isNotBlank(recordtypeId))
            mapDefaultValues.put('RecordTypeId', recordtypeId);
        // setting default market
        if(String.isNotBlank(userDefaultMar))
                mapDefaultValues.put('ZTS_EU_Market__c', userDefaultMar);

        defaultValues = JSON.serialize(mapDefaultValues);
    }
}