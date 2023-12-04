/**
* @ClassName    : SL_AccountNewButtonOverride 
* @JIRATicket   : LIGTHTNI-1084
* @CreatedOn    : 26 July, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : controller class 'SL_AccountNewButtonOverride' component.
*/
public with sharing class SL_AccountNewButtonOverride {
    
    /***********
      * Method name  : getDefaultUserData
      * Description  : This method return's the default value for the account page.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName
    ***********/
    @AuraEnabled
    public static Map<String, Object> getDefaultUserData(String sObjectName) {

        User usr = [SELECT ZTS_EU_Market__c, Default_Country__c 
                    FROM User 
                    WHERE Id =:UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];

        Boolean isCreateableAccount = Schema.getGlobalDescribe().get(sObjectName).getDescribe().isCreateable();

        // fetching the recently view loanListViewId
        ListView ListViewDetails = [SELECT Id, Name 
                                    FROM ListView WHERE SobjectType = :sObjectName
                                    ORDER BY LastReferencedDate DESC NULLS LAST LIMIT 1];
        return new Map<String, Object> {
            'user' => usr,
            'isCreateableAccount' => isCreateableAccount,
            'listViweDetails' => ListViewDetails
        };
    }
    
}