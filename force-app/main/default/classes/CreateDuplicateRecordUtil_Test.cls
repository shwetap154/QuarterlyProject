/*************************************************************************************
* Name          :    CreateDuplicateRecordUtil_Test.
* Description   :    Test Class for CreateDuplicateRecordUtil (SC-008149)
* Author        :    Aritra Chakraborty
 
Modification Log
----------------
Date             Developer              Comments
---------------------------------------------------------------------------------------
April,2022      Aritra Chakraborty      Created
**************************************************************************************/
@isTest
public class CreateDuplicateRecordUtil_Test {
    public static testMethod void testcreateDuplicateRecord(){
        Contact newContact = new Contact(LastName='Test Contact');
        newContact.Interface_Email__c = 'test@test.com';
        newContact.ZTS_US_Profession__c='Executive Leadership';
        newContact.ZTS_US_Job_Function__c='CEO/President';
        String serialLiseNewContact = Json.serialize(newContact);
        
        Call__c newCall = new Call__C(Name='Test Call');
        String serialLiseNewCall = Json.serialize(newCall);
        try{
            Test.startTest();
            String newContactId = CreateDuplicateRecordUtil.createDuplicateRecord(serialLiseNewContact, 'Contact');
            System.assert(!String.isEmpty(newContactId));
            String newCallId = CreateDuplicateRecordUtil.createDuplicateRecord(serialLiseNewCall, 'Call__c');
            System.assert(!String.isEmpty(newCallId));
            Test.stopTest();
        }
        catch(DMLException de)
        {
            system.assertEquals('DML Exception occcurred', de.getMessage());
        }
    }
    
    public static testMethod void testcheckDuplicate(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'Test';
        usr.LastName = 'User' ;
        usr.ZTS_EU_Market__c = 'United States';
        insert usr;
                
        System.runAs(usr)
        {
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            Account acc1 = new Account();
            acc1.Name = 'Test Account';
            insert acc1;
            Contact oldContact = new Contact(FirstName='Test',LastName='Contact',AccountId= acc.Id, Interface_Email__c = 'test1@test.com');
            oldContact.ZTS_US_Profession__c='Executive Leadership';
            oldContact.ZTS_US_Job_Function__c='CEO/President';
            insert oldContact;
            
            Contact newContact = new Contact(FirstName='Test',LastName='Contact',AccountId= acc.Id, Interface_Email__c = 'test1@test.com');
            newContact.ZTS_US_Profession__c='Executive Leadership';
            newContact.ZTS_US_Job_Function__c='CEO/President';
            
            try{
                Test.startTest();
                List<Contact> duplicateRecords = new List<Contact>();
                duplicateRecords = CreateDuplicateRecordUtil.checkDuplicateRecords(newContact);
                CreateDuplicateRecordUtil.createAffiliation(oldContact.Id,acc.Id);
                CreateDuplicateRecordUtil.createAffiliation(oldContact.Id,acc1.Id);
                System.assert(duplicateRecords.size() > 0);
                Test.stopTest();
            }
            catch(DMLException de)
            {
                system.assertEquals('DML Exception occcurred', de.getMessage());
            }
        }
    }
    
    
    public static testMethod void testgetDupContactDetails(){
        List<String> newContactIds = new List<String>();
        Contact newContact = new Contact(LastName='Test Contact');
        newContact.ZTS_US_Profession__c='Executive Leadership';
        newContact.ZTS_US_Job_Function__c='CEO/President';
        newContact.Interface_Email__c = 'test2@test.com';
        insert newContact;
        newContactIds.add(newContact.Id);
        
        Contact newContact1 = new Contact(LastName='Test Contact1');
        newContact1.ZTS_US_Profession__c='Executive Leadership';
        newContact1.ZTS_US_Job_Function__c='CEO/President';
        newContact1.Interface_Email__c = 'test2@test.com';
        insert newContact1;
        newContactIds.add(newContact1.Id);
        
        String serialLiseNewContact = Json.serialize(newContactIds);
        
        Test.startTest();
        List<Contact> dupContact = CreateDuplicateRecordUtil.getDupContactDetails(serialLiseNewContact);
        System.assert(!dupContact.isEmpty());
        Test.stopTest();
        
    }
}