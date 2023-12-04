/**
 * @description       : Main Query class for User
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-29-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-30-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectUsersByIdNotExcludedFromIntegrations
 * 2.0   05-05-2023   Sibin Kuriakose             Added Method to Retrieve user Language by Id
 * 3.0   05-29-2023   Sibin Kuriakose             Added Methods to Retrieve user Market by Id and by Name
 * 4.0   06-08-2023   Padma Nerella @ Zoetis Inc  Add selectByName method to retieve Users by name TPDEV-1070
 * 5.0   07-01-2023   Sibin Kuriakose             Added Method to Retrieve user Market and Language by Id
**/
public inherited sharing class UsersSelector extends fflib_SObjectSelector implements IUserSelector {
    public static IUserSelector newInstance() {
        return (IUserSelector)Application.Selector.newInstance(
            User.SObjectType
        );
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            User.Id,
            User.Name,
            User.Email,
            User.Username
        };
    }

    public Schema.SObjectType getSObjectType() {
        return User.sObjectType;
    }

    public List<User> selectUsersByIdNotExcludedFromIntegrations(Set<Id> userIds, Set<String> excludeIntegrations) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectField(User.Exclude_From_Integrations__c);
        // Dynamically build the excludes filters using the passed in excludeIntegrations property.
        // excludes can only be bound to String variables and not Lists or Sets
        queryFactory.setCondition(String.format(
            'Id in: userIds AND Exclude_From_Integrations__c excludes (\'\'{0}\'\')',
            new List<String>{String.join(new List<String>(excludeIntegrations), '\', \'')}));

        return Database.query(queryFactory.toSOQL());
    }

    public static List<User> selectUserMarketsLangById(List<Id> userId) {
        List<User> markets = [SELECT Id,LanguageLocaleKey,ZTS_EU_Market__c,Additional_Markets__c FROM User WHERE Id = :userId];

        return markets;
    }

    public static List<User> selectUserDetailByName(String str, Set<String> setPermission, Integer intlimit) {
        List<User> results = [SELECT Id, Email, Title, ZTS_EU_Market__c,Additional_Markets__c, Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment 
		WHERE PermissionSet.Name = :setPermission) AND (FirstName LIKE :str OR LastName LIKE :str OR Name LIKE :str) ORDER BY Name LIMIT :intlimit];

        return results;
    }

    public static List<User> selectByName(Set<String> userNames){
        return [SELECT Id
        FROM User
        WHERE
        Name =: userNames
        AND echosign_dev1__EchoSign_Allow_Delegated_Sending__c =true];

    }
}