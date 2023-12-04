/**
* @ClassName    : SL_ContactNewButtonOverride 
* @JIRATicket   : LIGTHTNI-1111
* @CreatedOn    : 31 July, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Controller for the SL_ContactNewButtonOverride component.
*/
public class SL_ContactNewButtonOverride {

    /***********
      * Method name  : getDefaultUserData
      * Description  : This method return's the default value for the contact page.
      * Return Type  : Map<String, Object>
      * Parameters   : String sObjectName, String accountId.
    ***********/
    @AuraEnabled
    public static Map<String, Object> getDefaultUserData(String sObjectName, String accountId) {

        Boolean isCreateableAccount = Schema.getGlobalDescribe().get(sObjectName).getDescribe().isCreateable();

        // fetching the recently view loanListViewId
        ListView ListViewDetails = [SELECT Id, Name 
                                    FROM ListView WHERE SobjectType = :sObjectName
                                    ORDER BY LastReferencedDate DESC NULLS LAST LIMIT 1];
        return new Map<String, Object> {
            'isCreateableAccount' => isCreateableAccount,
            'listViweDetails' => ListViewDetails,
            'defaultfields' => getAccountDetails( accountId )
        };
    }

    /***********
      * Method name  : getAccountDetails
      * Description  : This method return contact fields default values with account.
      * Return Type  : Map<String, Object>
      * Parameters   : String accid.
    ***********/
    private static Map<String, Object> getAccountDetails(String accid) {
        Map<String, Object> mapDefaultvalues = new Map<String, Object>();
        
        if(String.isNotBlank(accid)) {
            
            List<Account> accountAddressFields = [  SELECT ZTS_EU_Address_Line_1__c,ZTS_EU_Preferred_Language__c, ZTS_EU_Address_Line_2__c, ZTS_EU_Address_Line_3__c, 
                                                    ZTS_EU_District__c, ZTS_EU_State_County__r.Id, ZTS_EU_State_County__r.Name, ZTS_EU_City__c, ZTS_EU_Market__c, 
                                                    ZTS_EU_Country__c, ZTS_EU_Zip_Postal_Code__c, ZTS_EU_City_Country__r.Id, ZTS_EU_City_Country__r.Name, ZTS_EU_State_County__c, 
                                                    ZTS_EU_Main_Phone__c, ZTS_EU_Commune_Lookup__c, ZTS_EU_Commune_Lookup__r.Id, ZTS_EU_Commune_Lookup__r.Name  
                                                    FROM Account where Id =: accid AND ZTS_EU_Market__c != 'United States' LIMIT 1];
            if(accountAddressFields.size() > 0) {
                mapDefaultvalues.put('ZTS_EU_Preferred_Language__c', (accountAddressFields[0].ZTS_EU_Preferred_Language__c!= null ?accountAddressFields[0].ZTS_EU_Preferred_Language__c : ''));
                mapDefaultvalues.put('ZTS_EU_Market__c', (accountAddressFields[0].ZTS_EU_Market__c!= null ?accountAddressFields[0].ZTS_EU_Market__c : ''));
                mapDefaultvalues.put('ZTS_EU_Address_Line_1__c', (accountAddressFields[0].ZTS_EU_Address_Line_1__c!= null ?accountAddressFields[0].ZTS_EU_Address_Line_1__c : ''));
                mapDefaultvalues.put('ZTS_EU_Address_Line_2__c', (accountAddressFields[0].ZTS_EU_Address_Line_2__c!= null ?accountAddressFields[0].ZTS_EU_Address_Line_2__c : ''));
                mapDefaultvalues.put('ZTS_EU_Address_Line_3__c', (accountAddressFields[0].ZTS_EU_Address_Line_3__c!= null ?accountAddressFields[0].ZTS_EU_Address_Line_3__c : ''));
                mapDefaultvalues.put('ZTS_EU_City__c', (accountAddressFields[0].ZTS_EU_City__c!= null ?accountAddressFields[0].ZTS_EU_City__c : ''));
                if(accountAddressFields[0].ZTS_EU_State_County__r.Id != null) {
                    mapDefaultvalues.put('ZTS_EU_State_County__c', accountAddressFields[0].ZTS_EU_State_County__r.Id);
                    //url = url + '&'+countyName+'='+(accountAddressFields[0].ZTS_EU_State_County__r.Name!= null ?accountAddressFields[0].ZTS_EU_State_County__r.Name: '');
                }
                mapDefaultvalues.put('ZTS_EU_Country__c', (accountAddressFields[0].ZTS_EU_Country__c!= null ?accountAddressFields[0].ZTS_EU_Country__c : ''));
                mapDefaultvalues.put('ZTS_EU_Zip_Postal_Code__c', (accountAddressFields[0].ZTS_EU_Zip_Postal_Code__c!= null ?accountAddressFields[0].ZTS_EU_Zip_Postal_Code__c: ''));
                mapDefaultvalues.put('Phone', (accountAddressFields[0].ZTS_EU_Main_Phone__c!= null ?accountAddressFields[0].ZTS_EU_Main_Phone__c: ''));
                mapDefaultvalues.put('ZTS_EU_District__c', (accountAddressFields[0].ZTS_EU_District__c!= null ?accountAddressFields[0].ZTS_EU_District__c: ''));
            
            
                if(accountAddressFields[0].ZTS_EU_City_Country__c != null) {
                    mapDefaultvalues.put('ZTS_EU_City_Country__c', accountAddressFields[0].ZTS_EU_City_Country__r.Id);
                    //mapDefaultvalues.put(url = url + '&'+citylookupName+'='+(accountAddressFields[0].ZTS_EU_City_Country__r.Name!= null ?accountAddressFields[0].ZTS_EU_City_Country__r.Name: ''));
                }
                
                if(accountAddressFields[0].ZTS_EU_Commune_Lookup__c != null) {
                    mapDefaultvalues.put('ZTS_EU_Commune_Lookup__c', accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Id);
                    //mapDefaultvalues.put(url = url + '&'+CommunelookupName+'='+(accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Name!= null ?accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Name: ''));
                }
            }
            mapDefaultvalues.put('AccountId', accid);
        }
        return mapDefaultvalues;
    }
}