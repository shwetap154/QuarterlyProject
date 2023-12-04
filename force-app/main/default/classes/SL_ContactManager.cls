/**
* @ClassName    : SL_NewButtonOverride 
* @JIRATicket   : LIGTHTNI-1576
* @CreatedOn    : 13 September, 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : This manager class fetch the default value for contact from Account Object.
*/
public inherited sharing class SL_ContactManager {
    
    /***********
      * Method name  : getContactDefaultValues
      * Description  : This method return's the default value for contact from Account Object.
      * Return Type  : Map<String, Object>
      * Parameters   : String parentId.
    ***********/
    public static Map<String, Object> getContactDefaultValues( String parentId ) {
        Map<String, Object> mapDefaultvalues = new Map<String, Object>();
        
        if(String.isNotBlank(parentId)) {
            
            List<Account> accountAddressFields = [  SELECT ZTS_EU_Address_Line_1__c,ZTS_EU_Preferred_Language__c, ZTS_EU_Address_Line_2__c, ZTS_EU_Address_Line_3__c, 
                                                    ZTS_EU_District__c, ZTS_EU_State_County__r.Id, ZTS_EU_State_County__r.Name, ZTS_EU_City__c, ZTS_EU_Market__c, 
                                                    ZTS_EU_Country__c, ZTS_EU_Zip_Postal_Code__c, ZTS_EU_City_Country__r.Id, ZTS_EU_City_Country__r.Name, ZTS_EU_State_County__c, 
                                                    ZTS_EU_Main_Phone__c, ZTS_EU_Commune_Lookup__c, ZTS_EU_Commune_Lookup__r.Id, ZTS_EU_Commune_Lookup__r.Name  
                                                    FROM Account where Id =: parentId AND ZTS_EU_Market__c != 'United States' LIMIT 1];
            if(accountAddressFields.size() > 0) {
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_Preferred_Language__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Preferred_Language__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Preferred_Language__c', (accountAddressFields[0].ZTS_EU_Preferred_Language__c!= null ? accountAddressFields[0].ZTS_EU_Preferred_Language__c : ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_Market__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Market__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Market__c', (accountAddressFields[0].ZTS_EU_Market__c!= null ? accountAddressFields[0].ZTS_EU_Market__c : ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_Address_Line_1__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Address_Line_1__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Address_Line_1__c', (accountAddressFields[0].ZTS_EU_Address_Line_1__c!= null ? accountAddressFields[0].ZTS_EU_Address_Line_1__c : ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_Address_Line_2__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Address_Line_2__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Address_Line_2__c', (accountAddressFields[0].ZTS_EU_Address_Line_2__c!= null ? accountAddressFields[0].ZTS_EU_Address_Line_2__c : ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_Address_Line_3__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Address_Line_3__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Address_Line_3__c', (accountAddressFields[0].ZTS_EU_Address_Line_3__c!= null ? accountAddressFields[0].ZTS_EU_Address_Line_3__c : ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_City__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_City__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_City__c', (accountAddressFields[0].ZTS_EU_City__c!= null ? accountAddressFields[0].ZTS_EU_City__c : ''));
                
                if((Schema.sObjectType.Contact.fields.ZTS_EU_State_County__c.isCreateable()  && Schema.sObjectType.Contact.fields.ZTS_EU_State_County__c.isUpdateable() ) && accountAddressFields[0].ZTS_EU_State_County__r.Id != null)
                    mapDefaultvalues.put('ZTS_EU_State_County__c', accountAddressFields[0].ZTS_EU_State_County__r.Id);

                if(Schema.sObjectType.Contact.fields.ZTS_EU_Country__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Country__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Country__c', (accountAddressFields[0].ZTS_EU_Country__c!= null ? accountAddressFields[0].ZTS_EU_Country__c : ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_Zip_Postal_Code__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Zip_Postal_Code__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_Zip_Postal_Code__c', (accountAddressFields[0].ZTS_EU_Zip_Postal_Code__c!= null ? accountAddressFields[0].ZTS_EU_Zip_Postal_Code__c: ''));
                
                if(Schema.sObjectType.Contact.fields.Phone.isCreateable() && Schema.sObjectType.Contact.fields.Phone.isUpdateable() )
                    mapDefaultvalues.put('Phone', (accountAddressFields[0].ZTS_EU_Main_Phone__c!= null ? accountAddressFields[0].ZTS_EU_Main_Phone__c: ''));
                
                if(Schema.sObjectType.Contact.fields.ZTS_EU_District__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_District__c.isUpdateable() )
                    mapDefaultvalues.put('ZTS_EU_District__c', (accountAddressFields[0].ZTS_EU_District__c!= null ? accountAddressFields[0].ZTS_EU_District__c: ''));
        
                if((Schema.sObjectType.Contact.fields.ZTS_EU_City_Country__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_City_Country__c.isUpdateable() ) && accountAddressFields[0].ZTS_EU_City_Country__c != null)
                    mapDefaultvalues.put('ZTS_EU_City_Country__c', accountAddressFields[0].ZTS_EU_City_Country__r.Id);
                
                if((Schema.sObjectType.Contact.fields.ZTS_EU_Commune_Lookup__c.isCreateable() && Schema.sObjectType.Contact.fields.ZTS_EU_Commune_Lookup__c.isUpdateable() ) && accountAddressFields[0].ZTS_EU_Commune_Lookup__c != null)
                    mapDefaultvalues.put('ZTS_EU_Commune_Lookup__c', accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Id);

            }
            mapDefaultvalues.put('AccountId', parentId);
        }
        return mapDefaultvalues;
    }
}