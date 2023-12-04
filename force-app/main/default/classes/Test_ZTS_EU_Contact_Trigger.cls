/*******************************************************************************************************************************************
* File Name     :  Test_ZTS_EU_Contact_Trigger
* Description   :  Test class for ZTS_EU_Contact_Trigger
                :  Test class for ZTS_EU_Account_Trigger       
                :  Test class for ZTS_EU_populateAccOnContTrigger 
                :  Test class for ZTS_EU_AddressUpdateonAccountContact
                :  Test class for ZTS_EU_Account_Vetsave_Functionality 
                :  Test class for ZTS_EU_AffiliationUpdate 
                :  Test class for ZTS_EU_addressCreationFromAccount
                :  Test class for ZTS_EU_accUpdateClass
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
/*******************************************************************************************************************************************
* File Name     :  Test_ZTS_EU_Contact_Trigger
* Description   :  Test class for ZTS_EU_Contact_Trigger
                :  Test class for ZTS_EU_Account_Trigger       
                :  Test class for ZTS_EU_populateAccOnContTrigger 
                :  Test class for ZTS_EU_AddressUpdateonAccountContact
                :  Test class for ZTS_EU_Account_Vetsave_Functionality 
                :  Test class for ZTS_EU_AffiliationUpdate 
                :  Test class for ZTS_EU_addressCreationFromAccount
                :  Test class for ZTS_EU_accUpdateClass
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/14         Teresa           Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class Test_ZTS_EU_Contact_Trigger{

    @TestSetup
    static void makeData()
    {
        Test.startTest();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        list <State_Country__c> statelst= new list<State_Country__c>();
    
        State_Country__c statecon = new State_Country__c(ZTS_EU_uniqueCOUNTY__c = 'United Kingdom-Banffshire',ZTS_EU_Country__c='Austria', Name='Banffshire', CurrencyIsoCode = 'EUR' );
        //insert statecon;
            statelst.add(statecon);
        State_Country__c statecon1 = new State_Country__c(ZTS_EU_uniqueCOUNTY__c = 'United Kingdom-Anglesey',ZTS_EU_Country__c='United Kingdom', Name='Anglesey', CurrencyIsoCode = 'EUR' );
        //insert statecon1;
        statelst.add(statecon1);
        insert statelst;

        List<Account> Acclst =new List<Account> ();
        Account accparent = new Account(Name = 'Test Account Parent real', Type='Farm', ZTS_EU_Address_Line_1__c='test address',ZTS_EU_Main_Phone__c='9876789876',ZTS_EU_City__c='new delhi',CurrencyIsoCode='EUR',ZTS_EU_Market__c='United Kingdom',ZTS_EU_Vetsave_ID__c='200',ZTS_EU_Vetsave_HO_ID__c='56',ZTS_EU_Zip_Postal_Code__c='A1 1AA', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
        Acclst.add(accparent);
            //insert accparent;
        
        Account acc = new Account(Name = 'Test Account real', Type='Farm', ZTS_EU_Reason__c='Moved', ZTS_EU_Address_Line_1__c='test address',ZTS_EU_Main_Phone__c='9876789876',ZTS_EU_City__c='new delhi',CurrencyIsoCode='EUR',ZTS_EU_Market__c='United Kingdom',ZTS_EU_Vetsave_ID__c='200',ZTS_EU_Vetsave_HO_ID__c='56',ZTS_EU_Zip_Postal_Code__c='A1 1AA', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
        acc.ZTS_EU_Account_Status__c='Inactive';
        acc.ZTS_EU_Vetsave_ID__c='56';
        acc.ZTS_EU_Vetsave_HO_ID__c='56';
        acc.BillingCity = 'Boca Raton';
        acc.BillingCountry = 'US';
        acc.BillingState = 'FL';
        acc.BillingStreet  = 'Cypress way';
        acc.BillingPostalCode = '33333';
        acc.ZTS_EU_Corporate_Flag__c = true;
        Acclst.add(acc);
            //insert acc;
        
        Account accparent1 = new Account(Name = 'Test Account Parent',Type='Farm', ZTS_EU_Address_Line_1__c='test address',ZTS_EU_Main_Phone__c='9876789876',ZTS_EU_City__c='new delhi',ZTS_EU_State_County__c =statecon1.Id,ZTS_EU_Country__c='United Kingdom',ZTS_EU_Zip_Postal_Code__c='A1 1AA',CurrencyIsoCode='EUR',ZTS_EU_Market__c='United Kingdom',ZTS_EU_RAT_CTBF__c='A',ZTS_EU_PEN_CTDY__c='C',ZTS_EU_RAT_RU__c='R1', Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
        //insert accparent1;
        Acclst.add(accparent1);
        
        Account acc1 = new Account(Name = 'Test Account', Type='Farm',ZTS_EU_Reason__c='Moved', ZTS_EU_Address_Line_1__c='test address',ZTS_EU_Main_Phone__c='9876789876',ZTS_EU_City__c='new delhi',ZTS_EU_State_County__c =statecon1.Id, ZTS_EU_Country__c='United Kingdom',ZTS_EU_Zip_Postal_Code__c='A1 1AA',CurrencyIsoCode='EUR',ZTS_EU_Market__c='United Kingdom',ZTS_EU_Parent_Id__c=accparent1.id, Practice_Management_Software__c = 'Other', Other_Practice_Management_Software__c = 'Sample Practice Management Software');
        //insert acc1;
            Acclst.add(acc1);
                
        System.runAs(usr)
        {
            insert Acclst; 
        }

        test.stopTest();
    }
static testMethod void validate_ZTS_EU_Contact_Trigger() {
    
// List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
// TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_Contact_Trigger',ZTS_EU_Bypass__c = false);
// triggerActiveList.add(tr);
// TriggerActivation__c tr1 = new TriggerActivation__c(Name = 'ZTS_EU_Account_Trigger',ZTS_EU_Bypass__c = false);
// triggerActiveList.add(tr1);
// TriggerActivation__c tr2 = new TriggerActivation__c(Name = 'ZTS_EU_populateAccOnContTrigger',ZTS_EU_Bypass__c = false);
// triggerActiveList.add(tr2);
// TriggerActivation__c tr3 = new TriggerActivation__c(Name = 'ZTS_EU_AddressUpdateonAccountContact',ZTS_EU_Bypass__c = false);
// triggerActiveList.add(tr3);
 

// insert triggerActiveList;
    
 
    
  
Primary_Contact_Inactive_Profile_List__c obj = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names',Profile__c = 'ZTS PL Business Administrator');
        Primary_Contact_Inactive_Profile_List__c obj1 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 1',Profile__c = 'ZTS PL Business Administrator');
        Primary_Contact_Inactive_Profile_List__c obj2 = new Primary_Contact_Inactive_Profile_List__c(Name = 'Profile Names 2',Profile__c = 'ZTS PL Business Administrator');
        insert new List<Primary_Contact_Inactive_Profile_List__c>{obj,obj1,obj2};

List<Contact> contactsList = new List<Contact>();

List<ZTS_EU_Affiliations__c> acaList = new List<ZTS_EU_Affiliations__c>();

    Account acc = [SELECT Id, ZTS_EU_Primary_Address__c, ZTS_EU_Parent_Id__c FROM Account WHERE name = 'Test Account real' AND ZTS_EU_Market__c != 'United States'];
    Account accparent = [SELECT Id FROM Account WHERE name = 'Test Account Parent real'];
    User usr = [Select Id from User where FirstName = 'davidsUser' LIMIT 1];

    State_Country__c statecon = [SELECT Id FROM State_Country__c WHERE ZTS_EU_uniqueCOUNTY__c = 'United Kingdom-Banffshire'];
    State_Country__c statecon1 = [SELECT Id FROM State_Country__c WHERE ZTS_EU_uniqueCOUNTY__c = 'United Kingdom-Anglesey'];

Address__c add = new Address__c(Name='TestAddress',ZTS_EU_Account__c=acc.id,ZTS_EU_Country__c='Austria',ZTS_EU_State_County__c=statecon.id, Zip_Postal_Code__c='110046',RecordTypeId='012F0000000WRKaIAO');
insert add;
System.runAs(usr)
{
acc.ZTS_EU_Primary_Address__c = add.id;
acc.ZTS_EU_Parent_Id__c=accparent.id;


update acc;
}

//acc1.ZTS_EU_Vetsave_ID__c='300';
//acc1.ZTS_EU_Vetsave_HO_ID__c='56';

//update acc1;

update add;

contactsList.add(new Contact(LastName = 'Test',FirstName='Name', ZTS_EU_Market__c = 'United Kingdom', AccountId = acc.Id,ZTS_EU_Reason_for_Inactivation__c='Moved', Phone = '123456789', MobilePhone = '9876454321', Is_Government_Official__c = 'Yes',ZTS_EU_Address_Line_1__c='test address',ZTS_EU_City__c='Tweeddale',ZTS_EU_State_County__c=statecon.id,ZTS_EU_Zip_Postal_Code__c='M1 1AA',ZTS_EU_Country__c='Austria'));
Test.startTest();
System.runAs(usr)
{
insert contactsList;
}


acaList.add(new ZTS_EU_Affiliations__c(ZTS_EU_Account__c = acc.Id,ZTS_EU_Contact__c= contactsList[0].Id));
//insert acaList;
contactsList[0].MobilePhone = '29758649';
contactsList[0].ZTS_EU_Contact_type__c='Technician';
contactsList[0].ZTS_EU_Contact_Status__c='Active';
contactsList[0].Communication_Authorization_Flag__c=True;
contactsList[0].ZTS_EU_Opt_Out_Email__c=False;
contactsList[0].ZTS_EU_Opt_Out_Fax__c=False;    
contactsList[0].ZTS_EU_Opt_Out_Mail__c=False;
contactsList[0].ZTS_EU_Opt_Out_Phone__c=False;
contactsList[0].Privacy_Authorisation__c='Si';    
//Communication_Authorization_Flag__c=True,ZTS_EU_Opt_Out_Email__c=False,ZTS_EU_Opt_Out_Fax__c=False,ZTS_EU_Opt_Out_Mail__c=False,ZTS_EU_Opt_Out_Phone__c=False
//update contactsList[0];

List<ZTS_EU_Affiliations__c> acctContAffiliations = [SELECT ZTS_EU_Account__c,ZTS_EU_Contact__c FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Contact__c =: contactsList[0].Id AND ZTS_EU_Market_from_Parent__c != 'United States'];
update acctContAffiliations;
UtilityService.contactTriggerRun = true;
contactsList[0].ZTS_EU_Rep_Contact_Status__c='Inactive';
//update contactsList[0];
system.assertNotEquals(contactsList.size(),0);

//List<Account>acPrimaryRecord=ZTS_EU_DataUtilityTest1.createAccountRecord(1);
List<Account>acAffliatedRecord=ZTS_EU_DataUtilityTest1.createAccountRecord(1);
List<ZTS_EU_Account_Affiliations__c> finalList=new List<ZTS_EU_Account_Affiliations__c>();
List<ZTS_EU_Account_Affiliations__c> finalDeleteList=new List<ZTS_EU_Account_Affiliations__c>();

//insert acPrimaryRecord;
//insert acAffliatedRecord;

ZTS_EU_Account_Affiliations__c affNew = new ZTS_EU_Account_Affiliations__c();
//affNew.ZTS_EU_Affiliated_Account__c=acPrimaryRecord.get(0).id;
affNew.ZTS_EU_Account__c=acAffliatedRecord.get(0).id;
affNew.ZTS_EU_Account_influence__c = 'Low';
finalList.add(affNew);

//insert finalList;
UtilityService.accountTriggerRun = true;
UtilityService.AccAffInsertRun = true;
//acPrimaryRecord[0].ZTS_EU_Rep_Account_Status__c='Inactive';
//acPrimaryRecord[0].ZTS_EU_Reason__c='Moved';
//update acPrimaryRecord;
List<Account>acPrimaryRecord1=ZTS_EU_DataUtilityTest1.createAccountRecord(1);
List<Account>acAffliatedRecord1=ZTS_EU_DataUtilityTest1.createAccountRecord(1);
List<ZTS_EU_Account_Affiliations__c> finalList1=new List<ZTS_EU_Account_Affiliations__c>();
List<ZTS_EU_Account_Affiliations__c> finalDeleteList1=new List<ZTS_EU_Account_Affiliations__c>();
Test.stopTest();

System.runAs(usr)
{
insert acPrimaryRecord1;
insert acAffliatedRecord1;
}

ZTS_EU_Account_Affiliations__c affNew1 = new ZTS_EU_Account_Affiliations__c();
affNew1.ZTS_EU_Affiliated_Account__c=acPrimaryRecord1.get(0).id;
affNew1.ZTS_EU_Account__c=acAffliatedRecord1.get(0).id;
affNew1.ZTS_EU_Account_influence__c = 'Low';
finalList1.add(affNew1);

insert finalList1;

UtilityService.accountTriggerRun = true;
UtilityService.AccAffInsertRun = true;
acAffliatedRecord1[0].ZTS_EU_Account_Status__c='Inactive';
//update acPrimaryRecord1;
//delete contactsList;
}


}