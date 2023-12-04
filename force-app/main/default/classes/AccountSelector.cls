/**
 * @description       : Main Query class for Account
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-16-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
 * 1.1   03-17-2022   Ethan Hirsch @ Zoetis Inc   Add newInstance method
 * 1.1   04-08-2022   Ethan Hirsch @ Zoetis Inc   Add Name and ZTS_EU_Market__c to returned fields.
 * 1.2   04-13-2022   Ethan Hirsch @ Zoetis Inc   Add Program Owner fields to be returned from the selectByIdAndMarket method.
 * 1.3   05-03-2022   Ethan Hirsch @ Zoetis Inc   Add selectAccountWithReferenceLabFields method
 * 1.4   03-28-2023   Pamda Nerella @ Zoetis Inc  Add selectInternationalAccountByIdWithContacts method to get accounts to update certification status TPDEV-89
 * 1.5   05-09-2023   Padma Nerella @ Zoetis Inc  Add selectInternationalParentAccountsById method TPDEV-109
 * 1.6   05-10-2023   Padma Nerella @ Zoetis Inc  Add buildInternationalParentAccountsByIdQuery method TPDEV-109
 * 1.7   05-10-2023   Padma Nerella @ Zoetis Inc  Add retrieveInternationalParentAccountsByIdQuery method TPDEV-109
 * 1.8   05-15-2023   Padma Nerella @ Zoetis Inc  Add selectAccountsWithDiagnosticAPs method TPDEV-519
 * 1.9   05-18-2023   Padma Nerella @ Zoetis Inc  Add SelectINTLParentAccs method TPDEV-109
 * 2.0   07-10-2023   Padma Nerella @ Zoetis Inc  Add static boolean enforceSecurity variable TPDev-1070
**/
public inherited sharing class AccountSelector extends fflib_SObjectSelector implements IAccountSelector {
    public static boolean enforceSecurity = true;
    public static IAccountSelector newInstance() {
        return (IAccountSelector)Application.Selector.newInstance(
          Account.SObjectType
        );
      }


    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name,
            Account.ZTS_EU_Market__c
        };
    }
    

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public List<Account> selectByIdAndMarket(List<Id> ids, boolean isUnitedStates) {
        string marketCondition = 
            isUnitedStates
            ? ' ZTS_EU_Market__c = \'United States\''
            : ' ZTS_EU_Market__c != \'United States\'';

        return (List<Account>)Database.query(
            newQueryFactory(enforceSecurity, enforceSecurity, true).
            selectFields(new List<String> {
                    'MZR_Program_Owner__c',
                    'VGP_Program_Owner__c',
                    'LE_Program_Owner__c'
                }
            ).
            setCondition(string.format('Id in: ids AND {0}', 
                new List<string> {marketCondition} )).
            toSOQL()
        );
    }

    public List<Account> selectAccountWithReferenceLabFields(Set<Id> ids) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(new List<Schema.SObjectField> {
            Account.Courier_Request_Type__c,
            Account.Primary_Lab_Location__c,
            Account.Pick_ups_Per_Day__c,
            Account.Courier_Service_Provider__c,
            Account.Preferred_Pickup_Time__c,
            Account.Dropbox_Needed_if_Courier__c,
            Account.Send_In_Courier__c,
            Account.Days_of_Pickup__c,
            Account.Start_Date__c,
            Account.UPS_PPP_Customer__c,
            Account.UPS_PPP_Pickup_Location__c,
            Account.Will_Call_Time__c
        });

        queryFactory.setCondition('Id in: ids');

        return Database.query(queryFactory.toSOQL());
    }

    public List<Account> selectInternationalAccountByIdWithContacts(Set<Id> accIds){
        
        List<Account> getAccounts = [Select Id,Certification_Status__c, (Select Id,Certification_Status__c from Contacts) 
                                     from Account where Id IN :accIds AND ZTS_EU_Market__c != 'United States'];
        
        return getAccounts;
        
    }

    private fflib_QueryFactory buildInternationalParentAccountsByIdQuery(Set<Id> parentAccIds){
        return newQueryFactory().
            selectFields(new List<String> {
                'ZTS_EU_Corporate_Flag__c',
                'ZTS_EU_Parent_Id__c'
                }
            ).
            setCondition('(id in: parentAccIds or ZTS_EU_Parent_Id__c in:parentAccIds) AND ZTS_EU_Market__c != \'United States\'');
    }
    
    public List<Account> selectInternationalParentAccountsById(Set<Id> parentAccIds, Integer queryLimit){
        fflib_QueryFactory queryFactory= buildInternationalParentAccountsByIdQuery( parentAccIds);
        queryFactory.setLimit(queryLimit);
        return Database.query(queryFactory.toSOQL());
    }
    
    public String retrieveInternationalParentAccountsByIdQuery(Set<Id> parentAccIds){
        fflib_QueryFactory queryFactory= buildInternationalParentAccountsByIdQuery( parentAccIds);
        return queryFactory.toSOQL();
    }

    public static List<Account> selectAccountsWithDiagnosticAPs(Set<Id> accountIds){
        List<Account> accountList = 
        [
            SELECT 
                Id, 
                Name, 
                (SELECT 
                    Id, 
                    Name,  
                    ZTS_EU_Account__c, 
                    Account_Market__c, 
                    ZTS_NotificationUser__c, 
                    ZTS_AccountTerritory__c, 
                    Account_Type__c, 
                    ZTS_EU_Active__c, 
                    ZTS_City__c, 
                    ZTS_EU_Employee__c, 
                    ZTS_EU_Employee_Id__c,
                    ZTS_Employee_ID__c, 
                    ZTS_Field_Force_Name__c, 
                    ZTS_EU_Employee_Role__c, 
                    ZTS_EU_Is_Active__c, 
                    ZTS_EU_Market__c,
                    ZTS_EU_Position__c,
                    ZTS_SIB_Flag__c, 
                    Standard_Territory_ID__c, 
                    ZTS_EU_Territory__c,
                    ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c
                    FROM Account_Positions__r 
                    WHERE 
                        ZTS_EU_Employee__c != :DiagnosticCaseService.VACANT_EMPLOYEE 
                        AND ZTS_EU_Employee__c != ' ' 
                        AND ZTS_SIB_Flag__c = true 
                        AND EmployeeIsActive__c = true 
                        AND (
                            ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS 
                            OR ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_INSIDE_SALES_DIAGNOSTICS 
                            OR ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_TECH 
                            OR ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS_REGIONAL_TECH
                        )
                    AND ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c = :DiagnosticCaseService.TERRITORY_TYPE_TERRITORY  
                ) 
            FROM Account  
            WHERE Id IN :accountIds
        ]; 

        return accountList;
    }
    
    public static List<Account> SelectINTLParentAccs(Set<Id> parentAccIds){
        List<Account> parentAccList = [Select Id,ZTS_EU_Corporate_Flag__c,ZTS_EU_Parent_Id__c,ZTS_EU_Market__c From Account where Id IN:parentAccIds];
        return parentAccList;
    }
}