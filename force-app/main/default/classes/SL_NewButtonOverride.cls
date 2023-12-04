/**
* @ClassName    : SL_NewButtonOverride 
* @JIRATicket   : LIGTHTNI-1111
* @CreatedOn    : 06 August, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Controller for the SL_cmp_NewButtonOverride component.
*/
public with sharing class SL_NewButtonOverride {

    /***********
      * Method name  : getRecordDetails
      * Description  : This method return's the default value for the passed sObjectType back to component.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName, String parentId.
    ***********/
    @AuraEnabled
    public static Map<String, Object> getRecordDetails(String sObjectName, String parentId) {
		System.debug('this is test');
        // checking for accessibility
        Boolean isCreateableAccount = Schema.getGlobalDescribe().get(sObjectName).getDescribe().isCreateable();
        // fetching the recently view loanListViewId
        List<ListView> lstListViewDetails = [SELECT Id, Name 
                                             FROM ListView WHERE SobjectType = :sObjectName
                                             ORDER BY LastReferencedDate DESC NULLS LAST LIMIT 1];
        return new Map<String, Object>{
            'isCreateableAccount' => isCreateableAccount,
            'listViewDetails' => lstListViewDetails.isEmpty() ? new ListView() : lstListViewDetails[0] ,
            'defaultFieldValues' => getDefaultFieldValues( sObjectName, parentId)
        };
    }

    /***********
      * Method name  : getDefaultFieldValues
      * Description  : This method return's the default value for the passed sObjectType.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName, String parentId.
    ***********/
    private static Map<String, Object> getDefaultFieldValues(String sObjectName, String parentId) {
        Map<String, Object> mapDefaultFieldValues = new Map<String, Object>();
        
        switch on sObjectName {
            when 'Account' {
                mapDefaultFieldValues = getAccountDefaultValues( sObjectName );
            }	
            when 'Contact' {
                mapDefaultFieldValues = SL_ContactManager.getContactDefaultValues( parentId );
            }
            when 'Address__c' {	
                mapDefaultFieldValues = getAddressDefaultValues(sObjectName);
            }
            when 'ZTS_EU_Affiliations__c' {	
                mapDefaultFieldValues.put('Name', '-Auto populate on save-');
            }
            when 'ZTS_Events__c' {	
                mapDefaultFieldValues = getEventDefaultValues(sObjectName);
            }

            when else {	// future case	
            }
        }
        return mapDefaultFieldValues;
    }

    /***********
      * Method name  : getAccountDefaultValues
      * Description  : This method return's the default value for the account sObject.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName.
    ***********/
    private static Map<String, Object> getAccountDefaultValues(String sObjectName) {
        User usr = [SELECT ZTS_EU_Market__c, Default_Country__c 
                    FROM User 
                    WHERE Id =:UserInfo.getUserId()];
        return new Map<String, Object> {
            'ZTS_EU_Country__c' => usr.Default_Country__c,
            'ZTS_EU_Market__c' => usr.ZTS_EU_Market__c
        };
    }

    /***********
      * Method name  : getEventDefaultValues
      * Description  : This method return's the default value for the ZTS_Events__c sObject.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName.
    ***********/
    private static Map<String, Object> getEventDefaultValues(String sObjectName) {
        User usr = [SELECT ZTS_EU_Market__c 
                    FROM User 
                    WHERE Id =:UserInfo.getUserId()];
        return new Map<String, Object> {
            'ZTS_EU_Market__c' => usr.ZTS_EU_Market__c
        };
    }

    /***********
      * Method name  : getAddressDefaultValues
      * Description  : This method return's the default value for the Address__c sObject.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName.
    ***********/
    private static Map<String, Object> getAddressDefaultValues(String sObjectName) {

        User usr = [SELECT ZTS_EU_Country__c  FROM User 
                    WHERE Id =:UserInfo.getUserId()];

        return new Map<String, Object>{'ZTS_EU_Country__c' => usr.ZTS_EU_Country__c};
    }
}