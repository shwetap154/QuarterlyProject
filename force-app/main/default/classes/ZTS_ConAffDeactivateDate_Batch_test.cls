/****************************************************************************************************************************************** 
 * Class Name       : ZTS_ConAffDeactivateDate_Batch_test
 * Description      : Test Class for ZTS_DeactiveContOnAffltnDeactivation.cls (SC-008471)                               
 * Created By       : Cognizant
 * Created Date     : 5-April, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)       05-April-2021       Created  (SC-008471)
*****************************************************************************************************************************************/
@istest
public class ZTS_ConAffDeactivateDate_Batch_test {
    
     @testSetup
    public static void setup() { 
        
        
        //Create US records
        List<Account> testUSaccountList;
        testUSaccountList = ZTS_DataUtilityTest.createAccountRecord(1);
        testUSaccountList[0].ZTS_EU_Market__c ='United States';
        insert testUSaccountList;
        
        List<Contact> testUScontactList;
        testUScontactList = ZTS_DataUtilityTest.createContactRecord(1);
        testUScontactList[0].ZTS_EU_Market__c = 'United States';
        
        insert testUScontactList;
        
        List<ZTS_EU_Affiliations__c> lstUSAff = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        lstUSAff[0].ZTS_EU_Account__c = testUSaccountList[0].Id;
        lstUSAff[0].ZTS_EU_Contact__c = testUScontactList[0].Id;
        lstUSAff[0].ZTS_EU_Affiliation_Status__c = 'Active';
        
        insert lstUSAff;
       
        //Create INTL records
        Primary_Contact_Inactive_Profile_List__c newCustomSetting11 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting11.Name = 'Profile Names';
        newCustomSetting11.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
        insert newCustomSetting11;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting22 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting22.Name = 'Profile Names 1';
        newCustomSetting22.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
        insert newCustomSetting22;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting33 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting33.Name = 'Profile Names 2';
        newCustomSetting33.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
        insert newCustomSetting33;
        
        List<Account> testINTLaccountList;
        testINTLaccountList = ZTS_DataUtilityTest.createAccountRecord(1);
        testINTLaccountList[0].ZTS_EU_Market__c ='United Kingdom';
        insert testINTLaccountList;
        
        List<Contact> testINTLcontactList;
        testINTLcontactList = ZTS_DataUtilityTest.createContactRecord(1);
        testINTLcontactList[0].ZTS_EU_Market__c = 'United States';
        testINTLcontactList[0].ZTS_EU_Contact_Status__c = 'Active';
        insert testINTLcontactList;
        
        testINTLaccountList[0].ZTS_EU_Primary_Contact__c = testINTLcontactList[0].Id;
        update testINTLaccountList;
        
        List<ZTS_EU_Affiliations__c> lstINTLAff = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        lstINTLAff[0].ZTS_EU_Account__c = testINTLaccountList[0].Id;
        lstINTLAff[0].ZTS_EU_Contact__c = testINTLcontactList[0].Id;
        lstINTLAff[0].ZTS_EU_Affiliation_Status__c = 'Active';
        
        insert lstINTLAff;
    }
    
    static testmethod void testBatchJobContactUpdate(){
        
        User usr;
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'uk_User';
        usr.Email = 'temp@temp.com';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting.Name = 'Profile Names';
        newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
        insert newCustomSetting;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting2.Name = 'Profile Names 1';
        newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
        insert newCustomSetting2;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting3.Name = 'Profile Names 2';
        newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
        insert newCustomSetting3;
        
        
        
        List<Account> testaccountList;
        testaccountList = ZTS_DataUtilityTest.createAccountRecord(3);
        insert testaccountList;
        
        List<Contact> testcontactList;
        testcontactList = ZTS_DataUtilityTest.createContactRecord(3);
        
        for(Integer i=0;i<testcontactList.size();i++)
        {
            testcontactList[i].ZTS_EU_Market__c = 'United States';
            testcontactList[i].accountId = testaccountList[i].id;
            testcontactList[i].ZTS_EU_Contact_Status__c='Active';
            testcontactList[i].ZTS_EU_Rep_Contact_Status__c='Active';
            
        }
        insert testcontactList;
        
        List<ZTS_EU_Affiliations__c> lstAff = ZTS_DataUtilityTest.createAccConAffiliationRecord(3);
        //1st Aff
        lstAff[0].ZTS_EU_Account__c = testaccountList[1].Id;
        lstAff[0].ZTS_EU_Contact__c = testcontactList[0].Id;
        lstAff[0].ZTS_EU_Affiliation_Status__c = 'Inactive';
        lstAff[0].Contact_Affiliation_Deactivation_Date__c = system.now().addHours(-25);
        lstAff[0].Contact_Deactivation_Processed__c = FALSE;
        
        //2nd Aff
        lstAff[1].ZTS_EU_Account__c = testaccountList[2].Id;
        lstAff[1].ZTS_EU_Contact__c = testcontactList[0].Id;
        lstAff[1].ZTS_EU_Affiliation_Status__c = 'Inactive';
        lstAff[1].Contact_Affiliation_Deactivation_Date__c = system.now().addHours(-26);
        lstAff[1].Contact_Deactivation_Processed__c = FALSE;
        
        //3rd Aff
        lstAff[2].ZTS_EU_Account__c = testaccountList[0].Id;
        lstAff[2].ZTS_EU_Contact__c = testcontactList[1].Id;  
        lstAff[2].ZTS_EU_Affiliation_Status__c = 'Inactive';
        lstAff[2].Contact_Affiliation_Deactivation_Date__c = system.now().addHours(-27);
        lstAff[2].Contact_Deactivation_Processed__c = FALSE;
        
        insert lstAff;
        
		lstAff[1].ZTS_EU_Affiliation_Status__c = 'Active';       
        update lstAff[1];
        
        List<ZTS_EU_Affiliations__c> lstcon1Aff = [Select id from ZTS_EU_Affiliations__c where ZTS_EU_Affiliation_Status__c = 'Active' and ZTS_EU_Contact__c=: testcontactList[1].Id];
        for(ZTS_EU_Affiliations__c aff: lstcon1Aff )
        {
            aff.ZTS_EU_Affiliation_Status__c = 'Inactive';
        }
        update lstcon1Aff;
        
        
        test.startTest();
        ZTS_DeactiveContOnAffltnDeactivation batch= new ZTS_DeactiveContOnAffltnDeactivation();
        database.executeBatch(batch, 5);
        test.stopTest();
        
        
        
    }
    
    static testmethod void testUSAffUpdate()
    {
        
        
        List<ZTS_EU_Affiliations__c> lstAff = [Select Id,ZTS_EU_Account__c,ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c 
                                               where ZTS_EU_Affiliation_Status__c='Active' and ZTS_EU_Market_from_Parent__c='United States' limit 1];
        test.startTest();
        lstAff[0].ZTS_EU_Affiliation_Status__c = 'Inactive';
        update lstAff;
        test.stopTest();
 
    }
    
    static testmethod void testINTLAffUpdate()
    {
    
        
        List<ZTS_EU_Affiliations__c> lstAff = [Select Id,ZTS_EU_Account__c,ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c 
                                               where ZTS_EU_Affiliation_Status__c='Active' and ZTS_EU_Market_from_Parent__c='United Kingdom' limit 1];
        test.startTest();
        lstAff[0].ZTS_EU_Affiliation_Status__c = 'Inactive';
        update lstAff;
        test.stopTest();
     
    }
    
    static testmethod void testINTLAffDelete()
    {
    
        
        List<ZTS_EU_Affiliations__c> lstAff = [Select Id,ZTS_EU_Account__c,ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c 
                                               where ZTS_EU_Affiliation_Status__c='Active' and ZTS_EU_Market_from_Parent__c='United Kingdom' limit 1];
        try{
        delete lstAff;
        }
        catch(Exception e) {
            System.assert(e.getMessage().contains('The Affiliation for Active Primary Contact of the Account cannot be deleted. Please change the primary contact of the account before deleting this affiliation record.'));
        }
     
    }
    
}