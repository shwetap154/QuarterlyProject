/**
 * @description       : Main Query Class for ProfilesSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
public class ProfilesSelector extends fflib_SObjectSelector implements IProfilesSelector {
    public static IProfilesSelector newInstance() {
      return (IProfilesSelector) Application.Selector.newInstance(
        Profile.SObjectType
      );
    }
  
    /**
    * @description Default Field List to return with all Queries
    * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
      return new List<Schema.SObjectField>{
        Profile.Name,
        Profile.Id,
        Profile.UserType,
        Profile.UserLicenseId
      };
    }
  
  
    /**
    * @description Gets the SObject Type from Salesforce
    * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
      return Profile.SObjectType;
    }
  
    /**
    * @description Selects records by Id
    * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
    * @param Set<Id> idSet 
    * @return List<SAPCustomerMaterialPrice__c> 
    **/
    public List<Profile> selectById(Set<Id> idSet) {
      return (List<Profile>) selectSObjectsById(idSet);
    }
  
    /**
    * @description Selects All Profiles
    * @author Morgan Marchese @ Zoetis Inc | 07-19-2021 
    * @return List<Profile> 
    **/
    public List<Profile> selectAll() {
      fflib_QueryFactory recordQueryFactory = newQueryFactory();
      return (List<Profile>) Database.query(
        recordQueryFactory.toSOQL()
      );
    }
  }