/**
 * @description       : Unit Tests for PIT_UpdatedObjectService class.
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2014   Unknown                     Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Fix failing Unit Tests and made minor updates.
**/
@isTest
public class PIT_TestUpdatedObjectService {

    static Set<String> availableQueryTypes = new Set<String>{'deleted','updated','created','all'};

    @isTest
    public static void testIncorrectObjectName() {
        String objectName = 'incorrectObjectName';
        DateTime since = Date.Today();
        String queryType = 'created';
        String[] relatedObjects = new List<String>();
        Boolean includeMainObjectIds = false;
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        System.assertEquals(responseMap.get('Error'), 'Incorrect objectName');
    }
    
    @isTest
    public static void testIncorrectQueryType() {
        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'incorrectQueryType';
        String[] relatedObjects = new List<String>();
        Boolean includeMainObjectIds = false;
                
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        System.assertEquals(responseMap.get('Error'), 'Incorrect queryType ' + queryType + '. Possible values: ' + availableQueryTypes);
    }
    
    @isTest
    public static void testIncorrectRelatedObjectName() {
        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'created';
        String relatedObject = 'incorrectRelatedObjectName';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = false;
                
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        System.assertEquals(responseMap.get('Error'), 'Incorrect relatedObject name ' + relatedObject);
    }
    
    @isTest
    public static void testMissingIncludeMainObjectIds() {
        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'created';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = null;
                
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        System.assertEquals(responseMap.get('Error'), 'Please provide includeMainObjectIds value: true or false');
    }
    
    @isTest
    public static void testCreatedAccount() {
        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'created';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = true;
        
        Account acc = new Account();
        acc.Name = 'testAccName';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingCity = 'Boca Raton';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert acc;
        }       
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        
        System.assertEquals(responseMap.get('updatedRecordsIds'), JSON.serialize(new Set<String>{acc.id}));
    }
    
   
    @isTest
    public static void testAllQueryType() {
        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'all';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = true;
        
        Account acc = new Account();
        acc.Name = 'testAccName';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingCity = 'Boca Raton';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert acc;
        }        
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        
        System.assertEquals(responseMap.get('updatedRecordsIds'), JSON.serialize(new Set<String>{acc.id}));
    }
    
    @isTest
    public static void testExternalId() {
        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'created';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = true;
        String externalId = 'BillingCity';
        
        Account acc = new Account();
        acc.Name = 'testAccName';
        acc.BillingCity = 'Warsaw';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert acc;
        }        
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', externalId);
        
        System.assertEquals(responseMap.get('updatedRecordsIds'), JSON.serialize(new Set<String>{acc.BillingCity}));
    }
    
    @isTest
    public static void testUpdatedContact() {
        String market = 'United Kingdom';

        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'updated';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = true;
        
        Account acc = new Account();
        acc.Name = 'testAccName';
        acc.ZTS_EU_Market__c = market;
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingCity = 'Boca Raton';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = market;
        insert usr;

        System.runAs(usr){
            insert acc;

            Contact ctc = new Contact();
            ctc.FirstName = 'testFirstName';
            ctc.LastName = 'testLastName';
            ctc.AccountId = acc.id;
            insert ctc;
            ctc.FirstName = 'update';
            update ctc;
        }
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, 'ZTS_EU_Market__c != \'United States\'', null);
        
        //No way to check assert - it would require to modify createdDate        
    }
    
    @isTest
    public static void testCreatedContactWhereClause() {
        String market = 'United Kingdom';

        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'created';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = false;
        
        Account acc = new Account();
        acc.Name = 'testAccName';
        acc.ZTS_EU_Market__c = market;
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingCity = 'Boca Raton';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = market;
        insert usr;

        System.runAs(usr){
            insert acc;

            Contact ctc = new Contact();
            ctc.FirstName = 'testFirstName';
            ctc.LastName = 'testLastName';
            ctc.AccountId = acc.id;
            insert ctc;
        }
        
        
        String whereClause = string.format('Name = \'\'testAccName\'\' AND ZTS_EU_Market__c = \'\'{0}\'\'', new List<String> {market});
        
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, whereClause, null);
        
        System.assertEquals(responseMap.get('updatedRecordsIds'), JSON.serialize(new Set<String>{acc.id}));         
    }
    
    @isTest
    public static void testDeletedContact() {
        String market = 'United Kingdom';

        String objectName = 'Account';
        DateTime since = Date.Today();
        String queryType = 'deleted';
        String relatedObject = 'Contacts';
        String[] relatedObjects = new List<String>{relatedObject};
        Boolean includeMainObjectIds = true;
        
        Account acc = new Account();
        acc.Name = 'testAccName';
        acc.ZTS_EU_Market__c = market;
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        acc.BillingPostalCode = '12345';
        acc.BillingCity = 'Boca Raton';
        acc.BillingState = 'Florida';
        acc.BillingStreet = 'Elm Lane';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = market;
        insert usr;

        System.runAs(usr){
            insert acc;
            
            Contact ctc = new Contact();
            ctc.FirstName = 'testFirstName';
            ctc.LastName = 'testLastName';
            ctc.AccountId = acc.id;
            insert ctc;
            delete ctc;
        }      

        string whereClause = string.format('ZTS_EU_Market__c = \'\'{0}\'\'', new List<String> {market});
        Map<String, String> responseMap = PIT_UpdatedObjectService.getUpdatedRecords(objectName, since, queryType, relatedObjects, includeMainObjectIds, 0, whereClause, null);
        
        System.assertEquals(responseMap.get('updatedRecordsIds'), JSON.serialize(new Set<String>{acc.id}));        
    }

}