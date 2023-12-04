/**
 * @description       : Aura Controller for working with Contacts
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 03-08-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   03-04-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   06-09-2021   Aritra @ Cognizant             Added 'getUserFields' method to pull user's market if contact is not created from Account screen (SC-008687)
 **/
public with sharing class ContactAuraCtrl {
  @AuraEnabled
  public static String getPrepopulatedFields(Id accountId) {
    Account acct = new Account();
    String returnString = '';
    List<String> fieldPairSet = new List<String>();

    if (accountId != null) {
      acct = [
        SELECT
          ZTS_EU_Address_Line_1__c,
          ZTS_EU_Preferred_Language__c,
          ZTS_EU_Address_Line_2__c,
          ZTS_EU_Address_Line_3__c,
          ZTS_EU_District__c,
          ZTS_EU_State_County__c,
          ZTS_EU_City__c,
          ZTS_EU_Market__c,
          ZTS_EU_Country__c,
          ZTS_EU_Zip_Postal_Code__c,
          ZTS_EU_City_Country__c,
          ZTS_EU_Main_Phone__c,
          ZTS_EU_Commune_Lookup__c
        FROM Account
        WHERE Id = :accountId
        LIMIT 1
      ];

      String countryName = acct.ZTS_EU_Country__c;
      String addressLine1 = acct.ZTS_EU_Address_Line_1__c;
      String addressLine2 = acct.ZTS_EU_Address_Line_2__c;
      String addressLine3 = acct.ZTS_EU_Address_Line_3__c;
      String cityName = acct.ZTS_EU_City__c;
      String cityLookup = acct.ZTS_EU_City_Country__c;
      String countyId = acct.ZTS_EU_State_County__c;
      String postalCode = acct.ZTS_EU_Zip_Postal_Code__c;
      String preferredLanguage = acct.ZTS_EU_Preferred_Language__c;
      String market = acct.ZTS_EU_Market__c;
      String phone = acct.ZTS_EU_Main_Phone__c;
      String district = acct.ZTS_EU_District__c;
      String communeLookup = acct.ZTS_EU_Commune_Lookup__c;

      fieldPairSet.add('AccountId=' + accountId);
      if (!String.isBlank(addressLine1))
        fieldPairSet.add('ZTS_EU_Address_Line_1__c=' + addressLine1);
      if (!String.isBlank(addressLine2))
        fieldPairSet.add('ZTS_EU_Address_Line_2__c=' + addressLine2);
      if (!String.isBlank(addressLine3))
        fieldPairSet.add('ZTS_EU_Address_Line_3__c=' + addressLine3);
      if (!String.isBlank(cityName))
        fieldPairSet.add('ZTS_EU_City__c=' + cityName);
      if (!String.isBlank(cityLookup))
        fieldPairSet.add('ZTS_EU_City_Country__c=' + cityLookup);
      if (!String.isBlank(countyId))
        fieldPairSet.add('ZTS_EU_State_County__c=' + countyId);
      if (!String.isBlank(countryName))
        fieldPairSet.add('ZTS_EU_Country__c=' + countryName);
      if (!String.isBlank(postalCode))
        fieldPairSet.add('ZTS_EU_Zip_Postal_Code__c=' + postalCode);
      if (!String.isBlank(communeLookup))
        fieldPairSet.add('ZTS_EU_Commune_Lookup__c=' + communeLookup);
      if (!String.isBlank(preferredLanguage))
        fieldPairSet.add('ZTS_EU_Preferred_Language__c=' + preferredLanguage);
      if (!String.isBlank(market))
        fieldPairSet.add('ZTS_EU_Market__c=' + market);
      if (!String.isBlank(phone))
        fieldPairSet.add('Phone=' + phone);
      if (!String.isBlank(district))
        fieldPairSet.add('ZTS_EU_District__c=' + district);

      returnString = String.join(fieldPairSet, ',');
    }
    return returnString;
  }
  //Aritra Added below method for SC-008687 to return user's market to populate in contact market field
  @AuraEnabled
  public static String getUserFields() {
      Id userId = UserInfo.getUserId();
      String returnString;
      String userMarket = [Select ZTS_EU_Market__c from User where Id = :userId][0].ZTS_EU_Market__c;
      if(userMarket != '')
      {
          returnString = 'ZTS_EU_Market__c=' + userMarket;
      }
      else{
          returnString = '';
      }
          return returnString;
  }

  @AuraEnabled
  public static Account getAccountInfo(Id accountId) {
    Account acct = new Account();
    if (accountId != null) {
      acct = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
    }
    return acct;
  }
}