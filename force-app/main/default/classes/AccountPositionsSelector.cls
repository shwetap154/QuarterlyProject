/**
 * @description       : Selector Class for all future queries related 
 * to the Account Position Object
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-10-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   04-07-2022   Ethan Hirsch @ Zoetis Inc      Change class to use FFLib library and add selectByAccounts and selectByAccountIdsAndEmployeeIds.
 * 1.2   04-13-2022   Ethan Hirsch @ Zoetis Inc      Add selectByAccountIdsAndEmployeeIdsAndMarket
 * 1.3   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add selectByAccountIdWithRelatedData method
 * 1.4   07-11-2022   Ethan Hirsch @ Zoetis Inc      Change input type of childRelationships in selectByAccountIdWithRelatedData
 * 1.5   09-08-2022   Ethan Hirsch @ Zoetis Inc      Add ZTS_EU_Active__c to selectByAccountIdWithRelatedData
 * 1.6   09-19-2022   Ethan Hirsch @ Zoetis Inc      Update selectByAccountIdWithRelatedData to handle more than 20 child relationships
 *                                                   and use a helper class to perform its query for reusability.
**/
public inherited sharing class AccountPositionsSelector extends fflib_SObjectSelector implements IAccountPositionsSelector {
  public static IAccountPositionsSelector newInstance() {
    return (IAccountPositionsSelector) Application.Selector.newInstance(
      ZTS_EU_Account_Position__c.SObjectType
    );
  }

  public List<Schema.SObjectField> getSObjectFieldList() {
    return new List<Schema.SObjectField>{
      ZTS_EU_Account_Position__c.Name,
      ZTS_EU_Account_Position__c.Id,
      ZTS_EU_Account_Position__c.ZTS_EU_Position__c,
      ZTS_EU_Account_Position__c.ZTS_EU_Account__c
    };
  }

  public Schema.SObjectType getSObjectType() {
    return ZTS_EU_Account_Position__c.SObjectType;
  }
  
  /**
   * @description : returns a list of Account Position Records
   * based on their parent AccountId relationship
   * @author Morgan Marchese @ Zoetis Inc | 01-20-2021
   * @param accountIds
   * @return List<ZTS_EU_Account_Position__c>
   **/
  public List<ZTS_EU_Account_Position__c> selectByAcctTerritoryId(
    Set<Id> accountTerritoryIds,
    Boolean international
  ) {
    fflib_QueryFactory accountPositionQueryFactory = newQueryFactory();

    Set<String> queryFields = new Set<String>{
        'ZTS_EU_Territory__c',
        'ZTS_EU_Call_Target__c',
        'ZTS_EU_Position__r.ZTS_EU_Territory__c',
        'ZTS_EU_Active__c',
        'ZTS_EU_Market__c',
        'ZTS_AccountTerritory__c'
    };

    accountPositionQueryFactory.selectFields(queryFields);

    string marketFilter = international
                          ? 'ZTS_EU_Market__c != \'United States\''
                          :'ZTS_EU_Market__c = \'United States\'';

    accountPositionQueryFactory.setCondition(string.format(
      'ZTS_AccountTerritory__c IN: accountTerritoryIds AND {0}',
      new List<String> {marketFilter}));
      
    return (List<ZTS_EU_Account_Position__c>) Database.query(accountPositionQueryFactory.toSOQL()); 
  }
  
  public List<ZTS_EU_Account_Position__c> selectByAccountIds(Set<Id> accountIds) {
    fflib_QueryFactory accountPositionQueryFactory = newQueryFactory();
    Set<String> queryFields = new Set<String>{
        'ZTS_EU_Days_Since_Last_Call_New__c',
        'ZTS_EU_Employee_Id__c',
        'ZTS_AccountUserTerrUniqueKey__c',
        'Uniqueness_Key__c'
    };

    accountPositionQueryFactory.selectFields(queryFields);
    accountPositionQueryFactory.setCondition('ZTS_EU_Account__c IN :accountIds');

    return (List<ZTS_EU_Account_Position__c>) Database.query(accountPositionQueryFactory.toSOQL()); 
  }

  public List<ZTS_EU_Account_Position__c> selectByAccountIdsAndEmployeeIds(Set<Id> accountIds, set<Id> employeeIds) {
    fflib_QueryFactory accountPositionQueryFactory = newQueryFactory();
    Set<String> queryFields = new Set<String>{
        'ZTS_EU_Days_Since_Last_Call_New__c',
        'ZTS_EU_Employee_Id__c',
        'ZTS_AccountUserTerrUniqueKey__c',
        'Uniqueness_Key__c'
    };

    accountPositionQueryFactory.selectFields(queryFields);
    accountPositionQueryFactory.setCondition('ZTS_EU_Account__c IN :accountIds AND ZTS_EU_Employee_Id__c IN :employeeIds');

    return (List<ZTS_EU_Account_Position__c>) Database.query(accountPositionQueryFactory.toSOQL()); 
  }

  public List<ZTS_EU_Account_Position__c> selectByAccountIdsAndEmployeeIdsAndMarket(Set<Id> accountIds, set<Id> employeeIds, Boolean isUnitedStates) {
    fflib_QueryFactory accountPositionQueryFactory = newQueryFactory();
    Set<String> queryFields = new Set<String>{
        'LE_Program_Owner__c',
        'ZTS_Employee_ID__c'
    };

    accountPositionQueryFactory.selectFields(queryFields);

    string marketFilter = isUnitedStates
                          ? 'ZTS_EU_Market__c = \'United States\''
                          : 'ZTS_EU_Market__c != \'United States\'';

    accountPositionQueryFactory.setCondition(
      String.format('ZTS_EU_Account__c IN :accountIds AND ZTS_Employee_ID__c IN :employeeIds AND {0}', 
      new List<String> {marketFilter}));

    return (List<ZTS_EU_Account_Position__c>) Database.query(accountPositionQueryFactory.toSOQL()); 
  }

  public Map<Id, MergeService.RecordAndRelationships> selectByAccountIdWithRelatedData(Set<Id> accountIdSet,
    List<MergeService.MergeChildRelationship> childRelationships) {
    // Due to needing to use dynamic relationships, this query does not use fflib
    // A List that is joined together with String.join is used instead of String Concatenation for better performance
    List<String> queryBase = new List<String>();
    queryBase.add('SELECT Id, ZTS_EU_Account__c, ZTS_EU_Position__c, ZTS_AccountUserTerrUniqueKey__c, ');
    queryBase.add('Uniqueness_Key__c, CreatedDate, ZTS_EU_Call_Target__c, ZTS_EU_Active__c');

    List<String> querySuffix = new List<String>();
    querySuffix.add(' FROM ZTS_EU_Account_Position__c');
    // Due to the use of a helper method, bind parameters are not used
    querySuffix.add(String.format(' WHERE ZTS_EU_Account__c In (\'\'{0}\'\')',
      new List<String>{String.join(new List<Id>(accountIdSet), '\',\'')}));

    return MergeService.queryRelatedData(String.join(queryBase, ''), String.join(querySuffix, ''), childRelationships);
  }
}