@isTest
public class ZTS_EU_BatchAccountUpdateTest
{
    static testMethod void TestZTS_EU_BatchAccountUpdate()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        Account acc = new Account(Name = 'Test Account', Type = 'Farm',
            ZTS_EU_Market__c='United Kingdom',
            Practice_Management_Software__c = 'Other',
            Other_Practice_Management_Software__c = 'Sample Practice Management Software',
            ZTS_EU_Address_Line_1__c = 'city',
            ZTS_EU_Zip_Postal_Code__c='12345'
            );
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            insert acc;
            Contact con = new Contact(LastName = 'contact', FirstName = 'Test',ZTS_EU_Market__c = 'Italy',
            ZTS_EU_Contact_type__c = 'Veterinarian',ZTS_EU_Species_Specialty__c = 'Beef', Is_Government_Official__c='No',ZTS_EU_District__c = 'XXX', AccountId = acc.id);
            insert con;
            /*ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(Name = 'Test', ZTS_EU_Account__c = acc.id,ZTS_EU_Contact__c = con.id);
            insert aff;*/
            test.startTest();
                ZTS_EU_BatchAccountUpdate ap = new  ZTS_EU_BatchAccountUpdate();
            database.executebatch(ap);
            test.stoptest();
        } 
    }
}