/**
 * @description       : Created new test class for ImprovacContactService
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-10-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Ver   Date         Author                      Modification
 * 1.0   04-05-2023   Padma nerella @ Zoetis Inc  Added test cases for account update certification status true or false from contact
**/
@isTest
private class ImprovacContactsServiceTest {
    @TestSetup
    private static void setup(){
        
        List<echosign_dev1__Agreement_Template__c> echoSignList = ZTS_DataUtilityTest.createEchoSignDev1AgreementTemplateRec(2);
        echoSignList[0].Name = 'Improvac Certificate for Vet';
        echoSignList[0].echosign_dev1__Name__c = 'Improvac Certificate for Vet';
        insert echoSignList;
        
        List<Account> insertTestaccList = new List<Account>();
        List<Account> testaccList = ZTS_DataUtilityTest.createAccountRecord(5);
        for(Integer i=0;i<5;i++){
            testaccList[i].ZTS_EU_Market__c = 'United Kingdom';
            testaccList[i].ZTS_EU_Account_Status__c='Active';
        }
        insertTestaccList.addall(testaccList);
        
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert insertTestaccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> insertConList = new List<Contact>();
        List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(6);
        conList[0].AccountId = insertTestaccList[0].Id;
        conList[0].ZTS_EU_Contact_type__c = 'Farmer';
        conList[0].ZTS_EU_Contact_Status__c ='Active';
        conList[0].Certification_Status__c = true;
        conList[0].Email = 'farmerCon@Zoetis.com';
        conList[1].AccountId = insertTestaccList[1].Id;
        conList[1].ZTS_EU_Contact_type__c = 'Veterinarian';
        conList[1].ZTS_EU_Contact_Status__c ='Active';
        conList[1].Email = 'test12@Zoetis.com';
        conList[1].Certification_Status__c = true;
        conList[2].AccountId = insertTestaccList[2].Id;
        conList[2].ZTS_EU_Contact_type__c = 'Academic';
        conList[2].ZTS_EU_Contact_Status__c ='Active';
        conList[2].Email = 'test12@Zoetis.com';
        conList[2].Certification_Status__c = true;
        conList[3].AccountId = insertTestaccList[0].Id;
        conList[3].ZTS_EU_Contact_type__c = 'Farmer';
        conList[3].ZTS_EU_Contact_Status__c ='Active';
        conList[3].Certification_Status__c = true;
        conList[3].Email = 'farmerCon@Zoetis.com';
        conList[4].AccountId = insertTestaccList[3].Id;
        conList[4].FirstName ='FarmerContact';
        conList[4].LastName ='LastName';
        conList[4].ZTS_EU_Contact_type__c = 'Farmer';
        conList[4].ZTS_EU_Contact_Status__c ='Active';
        conList[4].Certification_Status__c = false;
        conList[4].Email = 'test@Zoetis.com';
        conList[5].AccountId = insertTestaccList[4].Id;
        conList[5].ZTS_EU_Contact_type__c = 'Farmer';
        conList[5].ZTS_EU_Contact_Status__c ='Active';
        conList[5].Certification_Status__c = true;
        conList[5].Email = 'test@Zoetis.com';
        insert conList;
        
        
    }
    
    @isTest
    private static void insertLWConAndVWContactcertificationStatusTrue(){
    
        
        List<Account> testaccList = ZTS_DataUtilityTest.createAccountRecord(2);
        testaccList[0].ZTS_EU_Market__c = 'United Kingdom';
        testaccList[0].ZTS_EU_Account_Status__c='Active';
        testaccList[1].ZTS_EU_Market__c = 'United Kingdom';
        testaccList[1].ZTS_EU_Account_Status__c='Active';
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        Insert testaccList;
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        
        List<Contact> conList = ZTS_DataUtilityTest.createContactRecord(2);
        conList[0].AccountId = testaccList[0].Id;
        conList[0].ZTS_EU_Contact_type__c = 'Farmer';
        conList[0].ZTS_EU_Contact_Status__c ='Active';
        conList[0].Certification_Status__c = true;
        conList[0].Email = 'test@Zoetis.com';
        conList[1].AccountId = testaccList[1].Id;
        conList[1].ZTS_EU_Contact_type__c = 'Veterinarian';
        conList[1].ZTS_EU_Contact_Status__c ='Active';
        conList[1].Certification_Status__c = true;
        conList[1].Email = 'test@Zoetis.com';
        
        Test.startTest();
        Insert conList;
        Test.stopTest();
        List<Account> accList = [Select Id,Certification_Status__c from Account where Id=:testaccList];
        for(Account acc1:accList){
            if(acc1.id ==conList[0].AccountId){
                System.assertEquals(true, acc1.Certification_Status__c, 'Account certification status updated to true when contact inserted with contact type Framer or Veterinarian, certification true and createAgreements');
 
            }else if(acc1.id ==conList[1].AccountId){
                System.assertEquals(true, acc1.Certification_Status__c, 'Account certification status updated to true when contact inserted with contact type Framer or Veterinarian, certification true and createAgreements');
            }
        }
        System.assertEquals(false,ImprovacContactsService.canIrun,'CreateAgreement method executed');
        
    }
    
   
    @isTest
    private static void updateContactCertificationStatusTest(){
        
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,Account.Certification_Status__c,Certification_Status__c,AccountId,FirstName from Contact where Certification_Status__c = true AND((ZTS_EU_Contact_type__c = 'Farmer' AND Email = 'test@Zoetis.com') OR (ZTS_EU_Contact_type__c = 'Veterinarian'))];
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(
            [SELECT Id, Name,Email,Certification_Status__c,AccountId,ZTS_EU_Contact_type__c FROM Contact WHERE Id IN :contactList]);


        Set<Id> accIdSet = new Set<Id>();
        List<Contact> newConList = new List<Contact>();
        for(Contact con:contactList){
            con.Certification_Status__c = false;
            accIdSet.add(con.AccountId);
            newConList.add(con);
        }
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        update newConList;
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        
        
        Test.startTest();
        ImprovacContactsService.prepareContacts('afterUpdate', newConList, oldContactMap);
        test.stopTest();
        List<Account> accList = [Select Id,Certification_Status__c From Account where Id =:accIdSet];
        for(Account acc : accList){
                if(acc.id == contactList[0].AccountId){
                    System.assertEquals(false, acc.Certification_Status__c, 'Account certification status updated to false when contact updated with contact type Veterinarian or Farmer');
                }
                if(acc.id == contactList[1].AccountId){
                    System.assertEquals(false, acc.Certification_Status__c, 'Account certification status updated to false when contact updated with contact type Veterinarian or Farmer');
                }
        }
        System.assertEquals(true,ImprovacContactsService.canIrun, 'CreateAgreement method did not executed');
    }
    
    @isTest
    private static void updateContactContactTypeTest(){
        
        List<Contact> conList = [Select Id,ZTS_EU_Contact_type__c,Email,Certification_Status__c,AccountId,Account.Certification_Status__c from Contact where ZTS_EU_Contact_type__c = 'Academic'];
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(
            [SELECT Id, Name,Email,Certification_Status__c,AccountId,ZTS_EU_Contact_type__c FROM Contact WHERE Id IN :conList]);
        
        conList[0].ZTS_EU_Contact_type__c ='Veterinarian';
        conList[0].Certification_Status__c =true;

        Set<Id> accIdSet = new Set<Id> ();
        for(Contact con:conList){
            accIdSet.add(con.AccountId);

        }

        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        update conList[0];
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        
       
        Test.startTest();
        ImprovacContactsService.prepareContacts('afterUpdate' , conList, oldContactMap);
        test.stopTest();
        List<Account> accList = [Select Id, Certification_Status__c from Account where Id =:accIdSet];
        for(Account acc : accList){
            if(acc.Id ==conList[0].AccountId){
                System.assertEquals(true,acc.Certification_Status__c,' Account record certification status changed to true when Contact update ZTS_EU_Contact_type__c to Veterinarian');
            }
        }
        System.assertEquals(false,ImprovacContactsService.canIrun,'CreateAgreement method executed');
        
}
    
    @isTest
    private static void updateContactEmailTest(){
        
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,LastName,Certification_Status__c,AccountId,Account.Certification_Status__c from Contact where (ZTS_EU_Contact_type__c= 'Farmer' AND Certification_Status__c=false)];
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(
            [SELECT Id, Name,Email,Certification_Status__c,AccountId,ZTS_EU_Contact_type__c,Account.Certification_Status__c FROM Contact WHERE Id IN :contactList]);

        List<Contact>updateConList = new List<Contact>();
        Set<Id> accIdSet = new Set<Id> ();
        for(Contact con : contactList){
            con.Email ='testzoetis@zoetis.com';
            con.Certification_Status__c =true;
            accIdSet.add(con.AccountId);
            updateConList.add(con);
            
        }
        
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        update updateConList;
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
       
        Test.startTest();
        ImprovacContactsService.prepareContacts('afterUpdate' , updateConList, oldContactMap);
        test.stopTest();
        List<Account> accList = [Select Id, Certification_Status__c from Account where Id =:accIdSet];
        for(Account acc : accList){
            if(acc.Id ==contactList[0].AccountId){
                System.assertEquals(true,acc.Certification_Status__c,' Account record certification status updated to true when updating contact email');
            }  
        }
        System.assertEquals(false,ImprovacContactsService.canIrun,'CreateAgreement method executed');

    }
    @isTest
    private static void muiltipleConOnAccTest(){
        List<Contact> contactList = [Select Id,Email,ZTS_EU_Contact_type__c,LastName,Certification_Status__c,AccountId,Account.Certification_Status__c from Contact where (ZTS_EU_Contact_type__c= 'Farmer' AND Email='farmerCon@Zoetis.com' AND Certification_Status__c =true)];
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(
            [SELECT Id, Name,Email,Certification_Status__c,AccountId,ZTS_EU_Contact_type__c,Account.Certification_Status__c FROM Contact WHERE Id IN :contactList]);
        
        Set<Id> accIdSet = new Set<Id>();
        contactList[0].Certification_Status__c =false;
        accIdSet.add(contactList[0].AccountId);
        
        DispatchTriggerHandler.bypass('ContactTriggerHandler');
        update contactList[0];
        DispatchTriggerHandler.clearBypass('ContactTriggerHandler');
        
        Test.startTest();
        ImprovacContactsService.prepareContacts('afterUpdate' , contactList, oldContactMap);
        test.stopTest();
        List<Account> accList = [Select Id, Certification_Status__c from Account where Id =:accIdSet];
        for(Account acc: accList){
            if(acc.Id ==contactList[0].AccountId){
                System.assertEquals(true, acc.Certification_Status__c, 'Account certification status did not get updated since the selcted account is having two contacts and one of the contact certification status is still true');
            }
        }
        System.assertEquals(true,ImprovacContactsService.canIrun,'CreateAgreement method did not get executed since certification status is false');   
    }
    
}