@isTest
public class ContactEditlwcEditSaveRowCtrl_Test { 
    
    @TestSetup
    static void setup(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        system.runAs(usr){
            List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
            Territory2Model terrModel = new Territory2Model();
            terrModel.Name = 'Name'; 
            terrModel.DeveloperName = 'Sample_territory_1'; 
            insert terrModel ;
            
            Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
            insert objTerr;
            
            List<Account> testAccounts = new List<Account>();
            testAccounts.addAll(ZTS_DataUtilityTest.createAccountRecord(4));
            for(Integer i=0; i<4; i++) {
                testAccounts[i].ZTS_EU_Market__c = 'United States';
            }
            insert testAccounts;
            
            List<Contact> testContacts = new List<Contact>();
            testContacts.addAll(ZTS_DataUtilityTest.createContactRecord(4));
            for(Integer i=0; i<4; i++) {
                testContacts[i].AccountId = testAccounts[i].Id;
                testContacts[i].ZTS_EU_Market__c = 'United States';
                testContacts[i].ZTS_US_Profession__c = 'Account Contact';
                testContacts[i].ZTS_US_Job_Function__c = 'Account Contact';
            }
            insert testContacts;
            List<ObjectTerritory2Association> ot2aList = new List<ObjectTerritory2Association>();
            ot2aList.add(new ObjectTerritory2Association(Territory2Id= objTerr.Id , ObjectId = testAccounts[0].Id, AssociationCause='Territory2Manual'));
            ot2aList.add(new ObjectTerritory2Association(Territory2Id= objTerr.Id , ObjectId = testAccounts[1].Id, AssociationCause='Territory2Manual'));
            ot2aList.add(new ObjectTerritory2Association(Territory2Id= objTerr.Id , ObjectId = testAccounts[2].Id, AssociationCause='Territory2Manual'));
            ot2aList.add(new ObjectTerritory2Association(Territory2Id= objTerr.Id , ObjectId = testAccounts[3].Id, AssociationCause='Territory2Manual'));
            insert  ot2aList;
            UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= usr.Id, RoleInTerritory2='Sales / Marketing Manager');
            insert objUserTerritory2Association;
        }
    }
            
    static testmethod void adminUser_getContactsTest(){
        User usr = [Select Id From User where FirstName = 'davidsUser' limit 1];
        System.runAs(usr){
            List<Contact> testContacts = [Select Id,AccountId,ZTS_US_Profession__c,ZTS_US_Job_Function__c,ZTS_US_LE_Contact__c,ZTS_US_Account_influence__c From Contact];
            ZTS_US_ContactAffiliation_Update.createAccountContactAffiliationRecord(testContacts);
            List<Contact> lstCon = ContactEditlwcEditSaveRowCtrl.getContacts('[]','CreatedDate','ASC');
            system.assertNotEquals(0, lstCon.size());
            
            List<ZTS_EU_Affiliations__c> affdata = ContactEditlwcEditSaveRowCtrl.getAffiliationRecords(String.valueOf(testContacts[0].Id));
            system.assertNotEquals(0, affdata.size());
            
            List<ZTS_EU_Affiliations__c> affList = [Select Id from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c =: testContacts[0].Id];
            List<Id> affIds = new List<Id>();
            for(ZTS_EU_Affiliations__c a: affList) 
            {
                affIds.add(a.Id);
            }
            ContactEditlwcEditSaveRowCtrl.deactivateAffilifiations(JSON.serialize(affIds));
            system.assertEquals(0, [Select Id from ZTS_EU_Affiliations__c where ZTS_EU_Affiliation_Status__c = 'Active' and ID in :affIds].size());
            
            testContacts[1].FirstName = 'New FN';
            Object obj = New List<Contact>{testContacts[1]};
            ContactEditlwcEditSaveRowCtrl.saveDraftValues(obj);
            system.assertEquals('New FN', [Select FirstName from Contact where ID =: testContacts[1].Id].FirstName);
        }
        
    }
    
    static testmethod void territoryUser_getContactsTest(){
        User usr = [Select Id From User where FirstName = 'davidsUser' limit 1];
        
        System.runAs(usr){
            
            List<Contact> testContacts = [Select Id,AccountId,ZTS_US_Profession__c,ZTS_US_Job_Function__c,ZTS_US_LE_Contact__c,ZTS_US_Account_influence__c From Contact];
            ZTS_US_ContactAffiliation_Update.createAccountContactAffiliationRecord(testContacts);
            
            List<Contact> lstCon = ContactEditlwcEditSaveRowCtrl.getContacts('[{"fieldName":"Account Name","searchKey":"test","fieldAPI":"Account_Name__c","index":0}]','CreatedDate','ASC');
            system.assertNotEquals(0, lstCon.size());
            
        }
    }

}