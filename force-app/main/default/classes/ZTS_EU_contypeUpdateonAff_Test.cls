@isTest (SeeAlldata = False)
public with sharing class ZTS_EU_contypeUpdateonAff_Test 
{

    static final String CONTACT_UPDATE_ERROR_ORIGIN = 'ZTS_EU_contypeUpdateonAff_Test - ZTS_EU_contypeUpdateonAff(): Insert Contact ';

    static testMethod void ZTS_EU_contypeUpdateonAff() 
    {
        List < ZTS_EU_Affiliations__c > newaff = new List < ZTS_EU_Affiliations__c > ();
        
        Primary_Contact_Inactive_Profile_List__c obj = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names',Profile__c = 'ZTS PL Business Administrator');
        insert obj;
        
        Primary_Contact_Inactive_Profile_List__c obj1 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 1',Profile__c = 'ZTS PL Business Administrator');
        insert obj1;
        
        Primary_Contact_Inactive_Profile_List__c obj2 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 2',Profile__c = 'ZTS PL Business Administrator');
        insert obj2;
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List < Account > accRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            insert accRecord;
            List < Contact > conRecord = ZTS_EU_DataUtilityTest.createContactRecord(1);
            List < Contact > conrec = new List < Contact > ();
            for (Contact con: conRecord) {
                con.ZTS_EU_Species_Specialty__c = 'Equine';
                con.ZTS_EU_Contact_type__c = 'Sales Manager';
                conrec.add(con);
            }
            insert conrec;
            Map < Id, Contact > mapcon = new Map < Id, Contact > ();
            for (Contact con: conrec) {
                mapcon.put(Con.id, Con);
            }
            System.debug('<<mapcon>>>'+mapcon);
            System.debug('<<conrec>>>'+conrec);        
            List<ZTS_EU_Affiliations__c> accConAffList = new List<ZTS_EU_Affiliations__c>();
                ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c = accRecord[0].id,ZTS_EU_Contact__c = conrec[0].id , ZTS_EU_Contact_type__c = '' );

            Insert accConAff;
            Test.startTest();
            List<Contact> updcon = new List<Contact>();
            try {
                for (Contact con: conrec) {
                    con.ZTS_EU_Contact_type__c = 'Academic';
                    updcon.add(con);
                }
                Update updcon;    
            }
            catch(DmlException dex)
            {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(CONTACT_UPDATE_ERROR_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, CONTACT_UPDATE_ERROR_ORIGIN);
            } 

            Test.stopTest();
        }
    }
}