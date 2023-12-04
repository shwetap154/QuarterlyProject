/**
 * @description       : Main Query Class for Address__c
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 07-17-2023
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   03-24-2022   Ethan Hirsch @ Zoetis Inc      Add selectDirectActiveShipToAddressesByAccountId method
 * 1.2   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add selectByAccountIdWithRelatedData method
 * 1.3   06-28-2022   Ethan Hirsch @ Zoetis Inc      Change query for Source_Account_Number__c to ZTS_EU_Address_ID__c in selectByAccountIdWithRelatedData
 *                                                   Also change this query to use Name instead of ZTS_Address_Line_1__c as that is the field used by INTL Addresses
 * 1.4   07-11-2022   Ethan Hirsch @ Zoetis Inc      Add back ZTS_US_Source_Account_Number__c in selectByAccountIdWithRelatedData for duplicate checks
 *                                                   Change input type of childRelationships in selectByAccountIdWithRelatedData
 * 1.5   09-09-2022   Ethan Hirsch @ Zoetis Inc      Add ZTS_EU_Phone__c to selectByAccountIdWithRelatedData.
 * 1.6   09-19-2022   Ethan Hirsch @ Zoetis Inc      Update selectByAccountIdWithRelatedData to handle more than 20 child relationships
 *                                                   and use a helper class to perform its query for reusability.
 * 1.7   07-17-2023   Padma Nerella @ Zoetis Inc     Add selectByLeadId method to retrieve addresses by leadIdSet TPDev-1079
 * 1.8   07-17-2023   Ethan Hirsch @ Zoetis Inc      Add Order by Id to selectByLeadId method so addresses are retrieved in a consistent order
 **/
public class AddressesSelector extends fflib_SObjectSelector implements IAddressesSelector {
  public static IAddressesSelector newInstance() {
    return (IAddressesSelector) Application.Selector.newInstance(
      Address__c.SObjectType
    );
  }

  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      Address__c.Name,
      Address__c.Id,
      Address__c.ZTS_EU_Account__c,
      Address__c.CurrencyIsoCode,
      Address__c.ZTS_EU_Address_Type__c,
      Address__c.ZTS_US_Source_Account_Number__c,
      Address__c.Full_Address__c,
      Address__c.OwnerId,
      Address__c.Account_Ultimate_Parent_Name__c,
      Address__c.ZTS_EU_Primary_Address__c
    };
  }

  public Schema.SObjectType getSObjectType() {
    return Address__c.SObjectType;
  }

  public List<Address__c> selectById(Set<Id> idSet) {
    return (List<Address__c>) selectSObjectsById(idSet);
  }

  public List<Address__c> selectByType(Set<String> typeSet) {
    fflib_QueryFactory addressesQueryFactory = newQueryFactory();
    addressesQueryFactory.setCondition('ZTS_EU_Address_Type__c IN :typeSet');
    return (List<Address__c>) Database.query(addressesQueryFactory.toSOQL());
  }

  public List<Address__c> selectByAccountId(Set<Id> accountIdSet) {
    fflib_QueryFactory addressesQueryFactory = newQueryFactory();
    Set<String> queryFields = new Set<String>{
      'ZTS_EU_Account__r.Name',
      'ZTS_EU_Account__r.Payment_Term__c',
      'ZTS_EU_Account__r.Incoterms__c'
    };
    addressesQueryFactory.selectFields(queryFields);
    addressesQueryFactory.setCondition('ZTS_EU_Account__c IN :accountIdSet');
    return (List<Address__c>) Database.query(addressesQueryFactory.toSOQL());
  }

  public List<Address__c> selectBySourceAccountNumber(
    Set<String> sourceAccountNumbers
  ) {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.setCondition(
      'ZTS_US_Source_Account_Number__c =: sourceAccountNumbers'
    );
    return (List<Address__c>) Database.query(recordQueryFactory.toSOQL());
  }

  public List<Address__c> selectBySourceAccountNumberAndType(
    Set<String> sourceAccountNumbers,
    Set<String> types
  ) {
    fflib_QueryFactory recordQueryFactory = newQueryFactory();
    recordQueryFactory.setCondition(
      'ZTS_US_Source_Account_Number__c =: sourceAccountNumbers AND ZTS_EU_Address_Type__c =: types'
    );
    return (List<Address__c>) Database.query(recordQueryFactory.toSOQL());
  }

  public List<Address__c> selectDirectActiveShipToAddressesByAccountId(Set<Id> accountIdSet) {
    fflib_QueryFactory addressesQueryFactory = newQueryFactory();
    addressesQueryFactory.selectField(Address__c.Reference_Labs_Ship_to__c);

    addressesQueryFactory.setCondition(String.join(new List<String> {
      'ZTS_EU_Account__c IN :accountIdSet',
      'AND  ZTS_EU_Address_Type__c IN (\'Ship To\', \'Shipping\', \'Ship Address\', \'Bill/Ship Address\')',
      'AND Is_Active__c = true',
      'AND Ship_Indirect__c != \'Y\''
    }, ' '));

    return (List<Address__c>) Database.query(addressesQueryFactory.toSOQL());
  }

  public Map<Id, MergeService.RecordAndRelationships> selectByAccountIdWithRelatedData(Set<Id> accountIdSet, List<MergeService.MergeChildRelationship> childRelationships) {
    // Due to needing to use dynamic relationships, this query does not use fflib
    // A List that is joined together with String.join is used instead of String Concatenation for better performance
    List<String> queryBase = new List<String>();
    queryBase.add('SELECT Id, Name, ZTS_EU_Address_Line_2__c, ZTS_EU_Address_Line_3__c, ');
    queryBase.add('Address_Line_4__c, ZTS_EU_Country__c, ZTS_EU_State_County__c, ZTS_EU_Commune_Lookup__c, ');
    queryBase.add('ZTS_EU_District__c, ZTS_EU_City__c, ZTS_EU_City_Country__c, Zip_Postal_Code__c, CreatedDate, ');
    queryBase.add('ZTS_EU_Address_Type__c, ZTS_EU_Address_ID__c, ZTS_US_Source_Account_Number__c, ');
    queryBase.add('ZTS_GL_Unique_Primary_Address_Key__c, ZTS_EU_Account__c, ZTS_EU_Phone__c');

    List<String> querySuffix = new List<String>();
    querySuffix.add(' FROM Address__c');
    // Due to the use of a helper method, bind parameters are not used
    querySuffix.add(String.format(' WHERE ZTS_EU_Account__c In (\'\'{0}\'\')',
      new List<String>{String.join(new List<Id>(accountIdSet), '\',\'')}));


    return MergeService.queryRelatedData(String.join(queryBase, ''), String.join(querySuffix, ''), childRelationships);
  }
    
    public static List<Address__c> selectByLeadId(Set<Id> leadIdSet){
        List<Address__c> addressList = [Select Id,Lead__c,ZTS_EU_Phone__c,ZTS_EU_Email__c,Zip_Postal_Code__c,State_Code__c,
                                       State_Province__c,ZTS_EU_City__c,ZTS_Address_Line_1__c,Source_Address_Name__c,
                                        Facility_State_Veterinary_License__c,Facility_DEA_License__c from Address__c
                                       where Lead__c=:leadIdSet
                                       ORDER BY Id];
        return addressList;
    }
    
    
    
}