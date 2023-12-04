@isTest
private class ContactUtilityTest {

    @TestSetup
    static void testDataSetup(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Italy';
        insert usr;

        /*Primary_Contact_Inactive_Profile_List__c obj = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names',Profile__c = 'System Administrator');
        Primary_Contact_Inactive_Profile_List__c obj1 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 1',Profile__c = 'ZTS PL Business Administrator');
        Primary_Contact_Inactive_Profile_List__c obj2 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 2',Profile__c = 'ZTS PL Business Administrator');
        insert new List<Primary_Contact_Inactive_Profile_List__c>{obj,obj1,obj2};*/

        List<Contact> contactList = ZTS_EU_DataUtilityTest.createContactRecord(1);
        for(Contact con : contactList){
            con.ZTS_EU_Country__c = 'Italy';
            con.ZTS_EU_Market__c = 'Italy';
        }

        System.runAs(usr){
			Primary_Contact_Inactive_Profile_List__c obj = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names',Profile__c = 'System Administrator');
            Primary_Contact_Inactive_Profile_List__c obj1 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 1',Profile__c = 'ZTS PL Business Administrator');
            Primary_Contact_Inactive_Profile_List__c obj2 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 2',Profile__c = 'ZTS PL Business Administrator');
            insert new List<Primary_Contact_Inactive_Profile_List__c>{obj,obj1,obj2};

            insert contactList;
        }
    }    
    
    @isTest
    static void setMKTOPermissionsTestEnabled() {

        User usr = [SELECT Id FROM User WHERE FirstName = 'davidsUser' AND ZTS_EU_Market__c = 'Italy'];
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        List<Contact> contacts = [SELECT Id,Privacy_Authorisation__c,Authorization_Letter_Signed__c,ZTS_EU_Country__c,ZTS_EU_Market__c FROM Contact];

        for(Contact c : contacts){   
                
            c.Privacy_Authorisation__c = 'Si';
            c.Authorization_Letter_Signed__c = 'Yes';
            contactsToUpdate.add(c);
        }
       

        System.runAs(usr){
            update contactsToUpdate;
        }
        
        List<Contact> contacts2 = [SELECT Id, Mkto_Sync_Permission__c FROM Contact WHERE Id IN:contactsToUpdate];
        System.debug('$$$ contacts2'+contacts2);
        System.assertEquals(null, contacts2[0].Mkto_Sync_Permission__c, 'The expected value of Mkto_Sync_Permission__c is blank');
        
    }
    
    @isTest
    static void setMKTOPermissionsTestDisabled() {
        
        User usr = [SELECT Id FROM User WHERE FirstName = 'davidsUser' AND ZTS_EU_Market__c = 'Italy'];

        List<Contact> contactsToUpdate = new List<Contact>();
        List<Contact> contacts = [SELECT Id,Privacy_Authorisation__c,Authorization_Letter_Signed__c,Mkto_Sync_Permission__c,ZTS_EU_Country__c,ZTS_EU_Market__c FROM Contact];

        for(Contact c : contacts){
            c.Privacy_Authorisation__c = '';
            c.Authorization_Letter_Signed__c = '';
            contactsToUpdate.add(c);

        }

        System.runAs(usr){
            update contactsToUpdate;
        }
        
        List<Contact> contacts2 = [SELECT Id,Mkto_Sync_Permission__c FROM Contact WHERE Id IN:contactsToUpdate];
        System.debug('$$$ contacts2'+contacts2);
        
		System.assertEquals('disabled', contacts2[0].Mkto_Sync_Permission__c, 'The expected value of Mkto_Sync_Permission__c is disabled');
        
        
    }
    
}