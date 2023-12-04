/**
 * @description       : Test class for Adobe_Send_For_Signature.
 * @author            : Shiva Kudikilla @ Cognizant
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   10-10-2016   Shiva Kudikilla @ Cognizant Initial Version (Estimate based on class it's testing)
 * 1.1   03-22-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test failures due to validation errors
**/
@isTest
public class Adobe_Send_For_Signature_Test {
    
    @TestSetup
    static void createTestData(){

        User usrAdmin = new User();
        usrAdmin = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usrAdmin.FirstName = 'davidsUser';
        usrAdmin.zts_eu_market__c = 'United States';
        insert usrAdmin;

        System.runAs(usrAdmin){
            List<Account> accountList =  new List<Account>();
            Account Acc1 = new Account(Name ='Test Account1',  Email__c = 'testemail@abc.com', ZTS_US_NARC_ID__c='1234567', ZTS_EU_Market__c = 'United States',ZTS_EU_Zip_Postal_Code__c = '12345', BillingPostalCode = '12345', BillingCity = 'Boca Raton', BillingState = 'Florida', BillingStreet = 'Elm Lane');
            Account Acc2 = new Account(Name ='Test Account2',  Email__c = 'testemail1@abc.com', ZTS_EU_Market__c = 'United States', ZTS_EU_Zip_Postal_Code__c = '12345', BillingPostalCode = '12345', BillingCity = 'Boca Raton', BillingState = 'Florida', BillingStreet = 'Elm Lane');
            Account Acc3 = new Account(Name ='Test Account3',  Email__c = 'testemail2@abc.com', ZTS_EU_Market__c = 'United States', ZTS_EU_Zip_Postal_Code__c = '12345', BillingPostalCode = '12345', BillingCity = 'Boca Raton', BillingState = 'Florida', BillingStreet = 'Elm Lane');
            accountList.add(Acc1);
            accountList.add(Acc2);
            accountList.add(Acc3);
            insert accountList;

            State_Country__c sc = new State_Country__c();
            sc.Name = 'Sachsen';
            sc.ZTS_EU_Country__c = 'Country1';
            insert sc;

            State_Country__c sc2 = new State_Country__c();
            sc2.Name = 'Test sc';
            sc2.ZTS_EU_Country__c = 'Country2';
            insert sc2;
            
            List<Address__c> addList = new List<Address__c>();
            Address__c Add1 = new Address__c(ZTS_EU_Account__c=accountList[0].id,ZTS_Address_Line_1__c='PO Box 1',ZTS_EU_Address_Type__c='Primary',ZTS_EU_City__c='City1',ZTS_EU_Country__c='Country1',ZTS_US_State_Province__c='State1',Zip_Postal_Code__c='Zip1', ZTS_EU_State_County__c = sc.Id);
            Address__c Add2 = new Address__c(ZTS_EU_Account__c=accountList[1].id,ZTS_Address_Line_1__c='PO Box 2',ZTS_EU_Address_Type__c='Primary',ZTS_EU_City__c='City2',ZTS_EU_Country__c='Country2',ZTS_US_State_Province__c='State2',Zip_Postal_Code__c='Zip2', ZTS_EU_State_County__c = sc2.Id);
            addList.add(Add1);
            addList.add(Add2);
            insert addList;
            
            ZTS_EU_Account_Affiliations__c accAffi1 = new ZTS_EU_Account_Affiliations__c(ZTS_EU_Account__c=accountList[0].Id, ZTS_EU_Affiliated_Account__c=accountList[1].Id, ZTS_US_Role__c='Supplier');
            insert accAffi1;
            ZTS_EU_Account_Affiliations__c accAffi2 = new ZTS_EU_Account_Affiliations__c(ZTS_EU_Account__c=accountList[0].Id, ZTS_EU_Affiliated_Account__c=accountList[2].Id, ZTS_US_Role__c='Distributor');
            insert accAffi2;
            
            ZTS_EU_Account_Position__c accountPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c = accountList[0].Id);
            insert accountPos;
            
            Contact contact = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            contact.AccountId = Acc1.Id;
            contact.LastName = 'Test LName';
            contact.ZTS_EU_Profession__c='Consultant';
            contact.ZTS_Job_Function__c='Owner';
            insert contact;
            
            echosign_dev1__Agreement_Template__c agrTemp1 = new echosign_dev1__Agreement_Template__c(Name = 'Veterinarian and Animal Health Account _Manual_', echosign_dev1__Name__c = 'Veterinarian and Animal Health Account _Manual_');
            insert agrTemp1;
            echosign_dev1__Agreement_Template__c agrTemp2 = new echosign_dev1__Agreement_Template__c(Name = 'Producers_Manual_', echosign_dev1__Name__c = 'Producers_Manual_');
            insert agrTemp2;
            
            Contract contract1 = new Contract(Name ='Test', AccountId = accountList[0].Id, ZTS_US_Field_Proposed_Tier__c = 'Veterinarian', Status='Draft');
            insert contract1 ;
            contract1.Name = 'Test0';
            contract1.Status = 'Proposal Approved';
            update contract1;
            ContractContactRole ccRole = new ContractContactRole(ContractId = contract1.Id, ContactId = contact.Id, IsPrimary = True, Role = 'Business User');
            insert ccRole;        
            
            Contract contract2 = new Contract(Name ='Test1', AccountId = accountList[0].Id, ZTS_US_Field_Proposed_Tier__c = 'Prestige', Status='Draft');
            insert contract2;
            contract2.Name = 'Test10';
            contract2.Status = 'Proposal Approved';
            update contract2;
            ContractContactRole ccRole1 = new ContractContactRole(ContractId = contract2.Id, ContactId = contact.Id, IsPrimary = False, Role = 'Business User');
            insert ccRole1;
            
            Contract contract3 = new Contract(Name ='Test2', AccountId = accountList[0].Id, ZTS_US_Field_Proposed_Tier__c = 'Veterinarian', Status='Draft');
            insert contract3;
            contract3.Name = 'Test20';
            contract3.Contract_Recipient__c= contact.Id;
            update contract3;
            ContractContactRole ccRole2 = new ContractContactRole(ContractId = contract3.Id, ContactId = contact.Id, IsPrimary = False, Role = 'Business User');
            insert ccRole2;

        }
        
    }
    
    @isTest
    static void testcreateAddendum()
    {

        Test.startTest();
        List<Contract> contractList = [select id,name,ContractNumber,AccountId,Status,ZTS_US_NARC_ID__c from Contract where Name = 'Test0' AND ZTS_EU_Market__c = 'United States'];
            system.debug('**************** CONT1'+contractList[0].id);
            String attID1 = Adobe_Send_For_Signature.createAddendum(contractList[0].id);
        Test.stopTest();

        List<echosign_dev1__Agreement_Template__c> agTemplates = [SELECT Id FROM  echosign_dev1__Agreement_Template__c WHERE Name like '%Veterinarian and Animal Health Account _Manual_%'];        
        System.assertEquals(agTemplates[0].Id, attID1, 'The expected Agreement Template ID must match');

        List<Attachment> attachmentList = [SELECT Name, ParentId FROM Attachment WHERE ParentId =:contractList[0].id];
        System.assertNotEquals(0, attachmentList.size(), 'The expected value of number of Attachments must be at least 1');
       

        List<Contract> contractList1 = [select id,name,ContractNumber,AccountId,Status from Contract where ZTS_US_Field_Proposed_Tier__c = 'Prestige' AND ZTS_EU_Market__c = 'United States'];
        system.debug('**************** CONT2'+contractList1[0].id);
        String attID2 = Adobe_Send_For_Signature.createAddendum(contractList1[0].id);
        
        List<echosign_dev1__Agreement_Template__c> agTemplates1 = [SELECT Id FROM  echosign_dev1__Agreement_Template__c WHERE Name like '%Producers_Manual_%'];        
        System.assertEquals(agTemplates1[0].Id, attID2, 'The expected Agreement Template ID must match');
        List<Attachment> attachmentList1 = [SELECT Name, ParentId FROM Attachment WHERE ParentId =:contractList1[0].id];
        System.assertNotEquals(0, attachmentList1.size(), 'The expected value of number of Attachments must be at least 1');

        List<Contract> contractList2 = [select id,name,AccountId,Status,ZTS_US_Current_Tier__c,ContractNumber,Contract_Recipient__c,ZTS_US_Field_Proposed_Tier__c from Contract where Contract_Recipient__c!=null AND ZTS_EU_Market__c = 'United States'];
        system.debug('**************** CONT 3'+contractList2[0].id);
        String attID3 = Adobe_Send_For_Signature.createAddendum(contractList2[0].id);
        System.assertEquals(true, attID3.contains('Contract must be approved'), 'The expected value of attID3 is Following Errors must be corrected before submission: Contract must be approved Found since the Status of Contract is Draft');
    }

    @isTest
    static void testController()
    {
        Test.startTest();
        List<Contract> contractList = [select id,name,ContractNumber,AccountId,Status,ZTS_US_NARC_ID__c from Contract where Name = 'Test0' AND ZTS_EU_Market__c = 'United States'];
        PageReference pageRef = Page.CreateAddendum;
        test.SetCurrentPage(pageRef);
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(contractList[0]);
        Adobe_Send_For_Signature asfs = new Adobe_Send_For_Signature(stdCon);
        System.assertNotEquals(0,Adobe_Send_For_Signature.adobeTags.size() , 'The expected Value of Adobe_Send_For_Signature.adobeTags should not be blank');
        System.assert(pageRef.getUrl().substringAfterLast('/') == 'createaddendum');
        Test.stopTest();
    }
}