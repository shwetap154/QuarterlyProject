/**
 * @description       : Service Class for all future Account Position utilities/services
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 09-19-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   11-09-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   04-08-2022   Ethan Hirsch @ Zoetis Inc      Update queries to use ColleaguesSelector and AccountPositionSelector
 * 1.1   04-13-2022   Ethan Hirsch @ Zoetis Inc      Add setLeProgramOwnerToPrimaryForContractOwner method
 * 1.2   05-25-2022   Ethan Hirsch @ Zoetis Inc      Add mergeRelatedAccountPositionsByAccountAndPosition method, primarily for handling INTL Account merges
 * 1.3   06-02-2022   Ethan Hirsch @ Zoetis Inc      Update mergeRelatedAccountPositionsByAccountAndPosition method to use helper method for generating unique keys to reduce duplicated patterns
 * 1.4   07-11-2022   Ethan Hirsch @ Zoetis Inc      Update merge logic to pass along additional details for a Child Relationship
 * 1.5   09-08-2022   Ethan Hirsch @ Zoetis Inc      Change the logic of mergeRelatedAccountPositionsByAccountAndPosition to keep active Account Positions over inactive per business request.
 * 1.6   09-12-2022   Ethan Hirsch @ Zoetis Inc      Change the logic of mergeRelatedAccountPositionsByAccountAndPosition to treat Call Targets of 0 as blank.
 * 1.7   09-19-2022   Ethan Hirsch @ Zoetis Inc      Change the logic of mergeRelatedAccountPositionsByAccountAndPosition to change how relationships are processed
 **/
public class AccountPositionsService {
  /**
   * @description to calculate the 'Day Since Last Called' field on Account Position
   * Migrated from ZTS_EU_AccountPositionUtility on 11-09-2021
   * @author Shreyas @ CloudSense | 03-13-2015
   * @param List<Call__c> callList
   * @param boolean callDelete
   **/
  public static void updateLastCallDateFromCalls(
    List<Call__c> callList,
    boolean isDelete
  ) {
    Set<Id> callIdSet = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    List<ZTS_EU_Colleague__c> colleagueList = new List<ZTS_EU_Colleague__c>();
    List<Call__c> callList_Fetched = new List<Call__c>();
    List<ZTS_EU_Account_Position__c> apList = new List<ZTS_EU_Account_Position__c>();
    Map<string, datetime> collegueMap = new Map<string, datetime>();

    for (Call__c c : callList) {
      callIdSet.add(c.Id);
      accountIdSet.add(c.ZTS_EU_Account__c);
    }

    IColleaguesSelector colleaguesSelector = ColleaguesSelector.newInstance();
    if (!isDelete) {
      colleagueList = colleaguesSelector.selectByCallAccountId(accountIdSet);
    } else {
      colleagueList = colleaguesSelector.selectByCallAccountIdExcludeCallIds(accountIdSet, callIdSet);
    }

    collegueMap = ColleaguesService.getCollegueKeyToCallDateMap(colleagueList);

    apList = AccountPositionsSelector.newInstance().selectByAccountIds(accountIdSet);

    AccountPositionsService.updateDaysSinceLastCalled(apList, collegueMap);
  }

  /**
   * @description to calculate the 'Day Since Last Called' field on Account Position.
   * Migrated from ZTS_EU_AccountPositionUtility on 11-09-2021.
   * @author Shreyas @ CloudSense | 03-13-2015
   * @param List<ZTS_EU_Colleague__c> collegueList
   * @param boolean isDelete
   **/
  public static void updateLastCallDateFromColleagues(
    List<ZTS_EU_Colleague__c> collegueList,
    boolean isDelete
  ) {
    Set<Id> collegueIdSet = new Set<Id>();
    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> employeeIdSet = new Set<Id>();
    List<ZTS_EU_Colleague__c> colleagueList = new List<ZTS_EU_Colleague__c>();
    List<ZTS_EU_Colleague__c> collegueListOtherCalls = new List<ZTS_EU_Colleague__c>();
    Map<string, datetime> collegueMap = new Map<string, datetime>();

    for (ZTS_EU_Colleague__c c : collegueList) {
      collegueIdSet.add(c.Id);
    }

    IColleaguesSelector colleaguesSelector = ColleaguesSelector.newInstance();
    colleagueList = colleaguesSelector.selectById(collegueIdSet);

    for (ZTS_EU_Colleague__c c : colleagueList) {
      accountIdSet.add(c.ZTS_EU_Call__r.ZTS_EU_Account__c);
      employeeIdSet.add(c.ZTS_EU_User__c);
    }

    if (!isDelete) {
      collegueListOtherCalls = ColleaguesSelector.selectByCallAccountIdAndUserId(accountIdSet, employeeIdSet);
    } else {
      collegueListOtherCalls = ColleaguesSelector.selectByCallAccountIdAndUserIdAndExcludeColleagueIds(accountIdSet,
        employeeIdSet, collegueIdSet);
    }

    collegueMap = ColleaguesService.getCollegueKeyToCallDateMap(
      collegueListOtherCalls
    );

    List<ZTS_EU_Account_Position__c> apList = AccountPositionsSelector.newInstance().selectByAccountIdsAndEmployeeIds(
      accountIdSet, employeeIdSet);

    AccountPositionsService.updateDaysSinceLastCalled(apList, collegueMap);
  }

  /**
   * @description Updates Days Since Last Called field on Account Positions by
   * matching Account Position Employee Ids with Colleague + Account Map Data.
   * Migrated from ZTS_EU_AccountPositionUtility on 11/09/2021
   * @author Shreyas @ Zoetis Inc | 03-13-2015
   * @param List<ZTS_EU_Account_Position__c> apList
   * @param Map<String DateTime> collegueMap
   **/
  public static void updateDaysSinceLastCalled(
    List<ZTS_EU_Account_Position__c> apList,
    Map<String, DateTime> collegueMap
  ) {
    List<ZTS_EU_Account_Position__c> listAccountPositions = new List<ZTS_EU_Account_Position__c>();
    for (ZTS_EU_Account_Position__c ap : apList) {
      if (ap.ZTS_EU_Employee_Id__c != null) {
        string key = ap.ZTS_EU_Employee_Id__c + ap.ZTS_EU_Account__c;
        if (collegueMap.get(key) != null) {
          datetime tempDateTime = collegueMap.get(key);
          date tempdate = date.newinstance(
            tempDateTime.year(),
            tempDateTime.month(),
            tempDateTime.day()
          );
          date todayDate = system.today();
          integer diff = tempDate.daysBetween(todayDate);

          if (diff >= 0) {
            ap.ZTS_EU_Days_Since_Last_Call_New__c = diff;
          } else {
            ap.ZTS_EU_Days_Since_Last_Call_New__c = null;
          }
        } else {
          ap.ZTS_EU_Days_Since_Last_Call_New__c = null;
        }
      } else {
        ap.ZTS_EU_Days_Since_Last_Call_New__c = null;
      }

      listAccountPositions.add(ap);
    }

    if (!listAccountPositions.isEmpty()) {
      new WithoutSharing().updateAccountPositionObj(listAccountPositions);
    }
  }

  /**
  * @description Takes in a list of Account Position, sets 
  * active to false, returns the list
  * @author Morgan Marchese @ Zoetis Inc | 11-10-2021 
  * @param List<ZTS_EU_Account_Position__c> records 
  * @return List<ZTS_EU_Account_Position__c> 
  **/
  public static List<ZTS_EU_Account_Position__c> setRecordsInactive(List<ZTS_EU_Account_Position__c> records) {
    for (ZTS_EU_Account_Position__c record : records) {
      record.ZTS_EU_Active__c = false;
    }
    return records;
  }

  /**
  * @description Sets LE Program Owner to Primary on the Account Positions related to a Contract's Account and Owner.
  * @author Ethan Hirsch @ Zoetis Inc | 04-13-2022 
  * @param contracts
  **/
  public static void setLeProgramOwnerToPrimaryForContractOwner(List<Contract> contracts) {
    Set<Id> accountIds = new Set<Id>();
    Set<ID> ownerIds = new Set<Id>();
    Set<String> accountOwnerCombos = new Set<String>();
    for (Contract contract : contracts) {
      accountIds.add(contract.AccountId);
      ownerIds.add(contract.OwnerId);
      accountOwnerCombos.add(string.format('{0}{1}', new List<Object> {contract.AccountId, contract.OwnerId}));
    }

    if (accountOwnerCombos.size() > 0) {
      List<ZTS_EU_Account_Position__c> accountPositionsToUpdate = new List<ZTS_EU_Account_Position__c>();
      for (ZTS_EU_Account_Position__c accountPosition : AccountPositionsSelector.newInstance().selectByAccountIdsAndEmployeeIdsAndMarket(accountIds, ownerIds, true)) {
        string accountUserCombo = string.format('{0}{1}', new List<Object> {accountPosition.ZTS_EU_Account__c, 
          accountPosition.ZTS_Employee_ID__c});

        if (accountOwnerCombos.contains(accountUserCombo) && accountPosition.LE_Program_Owner__c != 'Primary') {
          accountPosition.LE_Program_Owner__c = 'Primary'; 
          accountPositionsToUpdate.add(accountPosition);  
        }
      }

      if (accountPositionsToUpdate.size() > 0 ) {
        new WithoutSharing().updateAccountPositionObj(accountPositionsToUpdate);
      }
    }
  }

  /**
  * @description This method processes Account Positions related to an Account after a merge to delete any duplicates.
  *              A duplicate Account Position is determined by looking for Account Positions with the same Account and Position.
  *              Any child records of a deleted Account Position are transfered to the matching record to avoid them being lost.
  *              The child records are determined using the childObjectsToMerge Collection.
  *              This method also updated the unique keys of an Account Position, Uniqueness_Key__c and ZTS_AccountUserTerrUniqueKey__c.
  *              These fields are normally updated in triggers, but those triggers do not run on merge.
  *              They are updated here to prevent duplicates or other issues in the future
  * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
  * @param accountIds 
  * @param childObjectsToMergeMap 
  * @param updateRelatedRecordsMap 
  * @return Map<Id, ZTS_EU_Account_Position__c> 
  **/
  public static Map<Id, ZTS_EU_Account_Position__c> mergeRelatedAccountPositionsByAccountAndPosition(Set<Id> accountIds,
    Map<String, MergeRelatedRecordLookupsSelector.ChildObject> childObjectsToMergeMap,
    MergeService.UpdateRelatedRecordsMap updateRelatedRecordsMap) {
    Map<String, List<ZTS_EU_Account_Position__c>> accountPositionsByUniqueKey = 
      new Map<String, List<ZTS_EU_Account_Position__c>>();

    Map<String, ZTS_EU_Account_Position__c> keepAccountPositionsByUniqueKey = 
      new Map<String, ZTS_EU_Account_Position__c>();

    List<ZTS_EU_Account_Position__c> deleteAccountPositions = new List<ZTS_EU_Account_Position__c>();

    List<MergeService.MergeChildRelationship> childRelationships = MergeService.getChildRelationshipsForObjects(
      childObjectsToMergeMap, ZTS_EU_Account_Position__c.getSObjectType());

    Map<Id, MergeService.RecordAndRelationships> recordsAndRelationshipsMap = 
      AccountPositionsSelector.newInstance().selectByAccountIdWithRelatedData(accountIds, childRelationships);

    for (Id accountPositionId : recordsAndRelationshipsMap.keySet()) {
      ZTS_EU_Account_Position__c accountPosition = (ZTS_EU_Account_Position__c)recordsAndRelationshipsMap.get(accountPositionId).record;

      string uniqueKey = string.format('{0}{1}', new List<Object> {accountPosition.ZTS_EU_Account__c,
          accountPosition.ZTS_EU_Position__c});
        
      if (!accountPositionsByUniqueKey.containsKey(uniqueKey)) {
        accountPositionsByUniqueKey.put(uniqueKey, new List<ZTS_EU_Account_Position__c>());
      }

      accountPositionsByUniqueKey.get(uniqueKey).add(accountPosition);

      if (!keepAccountPositionsByUniqueKey.containsKey(uniqueKey)) {
        keepAccountPositionsByUniqueKey.put(uniqueKey, accountPosition);
        continue;
      }

      ZTS_EU_Account_Position__c matchingAccountPosition = keepAccountPositionsByUniqueKey.get(uniqueKey);
    
      // Deduplication logic
      // First, keep the active Account Position if only one is active. This was identified by business as being first priority.
      // Next, keep the Account Position with a Call Target populated. This was identified by business as being second priority.
      // Next, keep the Account Position with an AccountUserTerrUniqueKey that contains the Account Id.
      //    This Account Position originated from the original Account and will be prioritized
      // Finally, if an Account cannot be prioritized using the above logic, keep the oldest Account Position.
      Id accountId = accountPosition.ZTS_EU_Account__c;
      
      Boolean bothAccountPositionsActiveOrNotActive = 
        (accountPosition.ZTS_EU_Active__c && matchingAccountPosition.ZTS_EU_Active__c) ||
        (!accountPosition.ZTS_EU_Active__c && !matchingAccountPosition.ZTS_EU_Active__c);

      Boolean bothAccountPositionsHaveOrDontHaveCallTarget = 
        (!callTargetNullOrZero(accountPosition) && 
        !callTargetNullOrZero(matchingAccountPosition)) ||
        (callTargetNullOrZero(accountPosition) && 
        callTargetNullOrZero(matchingAccountPosition));

      if (accountPosition.ZTS_EU_Active__c && !matchingAccountPosition.ZTS_EU_Active__c) {
        keepAccountPositionsByUniqueKey.put(uniqueKey, accountPosition);
      }
      // Both Account Positions must be Active or not Active to move to the next prioritzation logic
      else if (bothAccountPositionsActiveOrNotActive &&
        !callTargetNullOrZero(accountPosition) && 
        callTargetNullOrZero(matchingAccountPosition)) {
          keepAccountPositionsByUniqueKey.put(uniqueKey, accountPosition);
      }
      // Both Account Positions must have a Call Target specified or not specified to move to the next prioritization logic.
      // This avoids deleting an Account Position with a Call Target incorrectly.
      else if (bothAccountPositionsActiveOrNotActive && bothAccountPositionsHaveOrDontHaveCallTarget &&
      accountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(accountId) == true &&
        matchingAccountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(accountId) != true) {
        keepAccountPositionsByUniqueKey.put(uniqueKey, accountPosition);
      }
      // Both Account Positions must have Call Target specified or no Call Target
      // and correct Unique Keys or incorrect Unique Keys to move to the next prioritization logic.
      // This avoids deleting an Account Position with a Call Target or correct Unique Key incorrectly.
      else if (bothAccountPositionsActiveOrNotActive && bothAccountPositionsHaveOrDontHaveCallTarget &&
        ((accountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(accountId) == true &&
        matchingAccountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(accountId) == true) ||
        (accountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(accountId) != true &&
        matchingAccountPosition.ZTS_AccountUserTerrUniqueKey__c?.contains(accountId) != true)) &&
        accountPosition.CreatedDate < matchingAccountPosition.CreatedDate) {
        keepAccountPositionsByUniqueKey.put(uniqueKey, accountPosition);
      }
    }

    // Pull the field names from schema to create a reference to the field in code
    String accountUserTerrUniqueKeyFieldName = ZTS_EU_Account_Position__c.ZTS_AccountUserTerrUniqueKey__c.getDescribe().getName();
    String uniquenessKeyFieldName = ZTS_EU_Account_Position__c.Uniqueness_Key__c.getDescribe().getName();

      // Process duplicate Account Positions to transfer related records to the matching record and update unique keys.
    for (String uniqueKey : accountPositionsByUniqueKey.keySet()) {
      MergeService.DeleteRecordsAndKeepRecord deleteRecordsAndKeepRecord = MergeService.setLookupFieldsAndDeleteRecords(
        uniqueKey, keepAccountPositionsByUniqueKey, accountPositionsByUniqueKey, childRelationships,
        recordsAndRelationshipsMap, updateRelatedRecordsMap);

      ZTS_EU_Account_Position__c keepAccountPosition = (ZTS_EU_Account_Position__c)deleteRecordsAndKeepRecord.keepRecord;
      deleteAccountPositions.addAll((List<ZTS_EU_Account_Position__c>)deleteRecordsAndKeepRecord.deleteRecords);

      Id accountId = keepAccountPosition.ZTS_EU_Account__c;
      // Update ZTS_AccountUserTerrUniqueKey__c if it's inaccurate.
      // This is set in multiple pieces of code.
      MergeService.setUniqueKeyField(keepAccountPosition, accountUserTerrUniqueKeyFieldName,
        generateAccountUserTerrUniqueKey(keepAccountPosition), accountId,
        updateRelatedRecordsMap);

      // Update Uniqueness_Key__c if it's inaccurate.
      // This is set in multiple pieces of code.
      MergeService.setUniqueKeyField(keepAccountPosition, uniquenessKeyFieldName,
        generateUniquenessKey(keepAccountPosition), accountId,
        updateRelatedRecordsMap);
    }

    return new Map<Id, ZTS_EU_Account_Position__c>(deleteAccountPositions);
  }

  /**
  * @description Generates the key for ZTS_AccountUserTerrUniqueKey__c. 
  *              Usable in a Unit Test to keep key generation in one place.
  * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
  * @param accountPosition 
  * @return string 
  **/
  @TestVisible
  private static string generateAccountUserTerrUniqueKey(ZTS_EU_Account_Position__c accountPosition) {
    return string.format('{0}:{1}', new List<Object> {accountPosition.ZTS_EU_Account__c,
      accountPosition.ZTS_EU_Position__c});
  }

  /**
  * @description Generates the key for Uniqueness_Key__c.
  *               Usable in a Unit Test to keep key generation in one place.
  * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
  * @param accountPosition 
  * @return string 
  **/
  private static string generateUniquenessKey(ZTS_EU_Account_Position__c accountPosition) {
    return string.format('A:{0}_P:{1}', new List<Object> {accountPosition.ZTS_EU_Account__c,
      accountPosition.ZTS_EU_Position__c});
  }

  /**
  * @description Returns true if ZTS_EU_Call_Target__c is null or 0
  * @author Ethan Hirsch @ Zoetis Inc | 05-25-2022 
  * @param accountPosition 
  * @return Boolean 
  **/
  private static Boolean callTargetNullOrZero(ZTS_EU_Account_Position__c accountPosition) {
    return accountPosition.ZTS_EU_Call_Target__c == null || accountPosition.ZTS_EU_Call_Target__c == 0;
  }

  /**
   * @description private class implementing without sharing declaration
   * to allow system developers to leverage contextual sharing bypasses
   * as needed within this class.
   * @author Morgan Marchese @ Zoetis Inc | 11-01-2021
   * @param List<ZTS_EU_Account_Position__c> apList
   * @param Map<String DateTime> collegueMap
   **/
  private without sharing class WithoutSharing {
    /**
     * @description Updates a List of Account Positions irrespective
     * of the current users Sharing access to the record(s)
     * @author Morgan Marchese @ Zoetis Inc | 11-01-2021
     * @param List<ZTS_EU_Account_Position__c> lstAccPostToUpdate
     **/
    public void updateAccountPositionObj(
      List<ZTS_EU_Account_Position__c> lstAccPostToUpdate
    ) {
      update lstAccPostToUpdate;
    }
  }
}