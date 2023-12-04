/**
* @ClassName    : SL_CopyAddress 
* @JIRATicket   : LIGHTNI-35
* @CreatedOn    : 27th March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Controller to copy address to the contact record from account.
*/
public with sharing class SL_CopyAddress 
{
    public SL_CopyAddress(ApexPages.StandardController controller)
    {
    }
    
    /***********
      * Method name  : updateContactAddress
      * Description  : This method will copy the address from Affiliated's account to the contact record.
      * Return Type  : NA
      * Parameters   : String affiliationRecordId.
    ***********/ 
    
    @auraEnabled
    public static void updateContactAddress(String affiliationRecordId)
    {
        
        ZTS_EU_Affiliations__c objAffiliation = [Select Id, ZTS_EU_Contact__c, ZTS_EU_Account__c 
                                                   From ZTS_EU_Affiliations__c 
                                                   Where Id =: affiliationRecordId AND ZTS_EU_Market_from_Parent__c != 'United States'];
        
        Contact objContact = new Contact(Id = objAffiliation.ZTS_EU_Contact__c);
        String strAccountId = objAffiliation.ZTS_EU_Account__c;
        
        List<Account> lstAccount = [SELECT ZTS_EU_Address_Line_1__c, ZTS_EU_Address_Line_2__c, ZTS_EU_Address_Line_3__c, ZTS_EU_City__c,
                                           ZTS_EU_Country__c, ZTS_EU_Zip_Postal_Code__c, ZTS_EU_State_County__c 
                                    FROM Account 
                                    WHERE Id =: strAccountId
                                      AND ZTS_EU_Market__c != 'United States'
                                    LIMIT 1];
        
        objContact.ZTS_EU_Address_Line_1__c = lstAccount[0].ZTS_EU_Address_Line_1__c;
        objContact.ZTS_EU_Address_Line_2__c= lstAccount[0].ZTS_EU_Address_Line_2__c;
        objContact.ZTS_EU_Address_Line_3__c= lstAccount[0].ZTS_EU_Address_Line_3__c;
        objContact.ZTS_EU_City__c = lstAccount[0].ZTS_EU_City__c;
        objContact.ZTS_EU_Country__c= lstAccount[0].ZTS_EU_Country__c;
        objContact.ZTS_EU_State_County__c= lstAccount[0].ZTS_EU_State_County__c;
        objContact.ZTS_EU_Zip_Postal_Code__c= lstAccount[0].ZTS_EU_Zip_Postal_Code__c;
        
        update objContact;
    }
}