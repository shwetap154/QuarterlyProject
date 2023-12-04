/**
 * @description       : Test Class for class update_Opt_Out_Account
 * @author            : Sohil Shah @ CloudSense
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-22-2015   Sohil Shah @ CloudSense     Created DEF-001643
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc   Fix issues with inserting Contacts that caused Unit Test failures
**/
@isTest
public class update_Opt_Out_AccountTest
{
    static testMethod void Opt_Out_AccountUpdateUpdateTest()
    {     
   
        List<Account> acc1 = ZTS_DataUtilityTest.createAccountRecord(1);
        insert acc1;
        Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId(); 
        Contact con = ZTS_DataUtilityTest.createContactRecord(1)[0];
        con.Interface_Email__c = 'abe@1112.com';
        con.RecordTypeId = rtId;
        con.AccountId = acc1[0].id;
        con.Interface_Email_Opt_Out__c = false;
        con.ZTS_Invalid_Email__c = false;
        insert con;
        con.Interface_Email__c = 'abe@1111.com';
        con.Interface_Email_Opt_Out__c = true;
        con.ZTS_Invalid_Email__c = true;
        List<Contact> contactList = new List<Contact>();
        contactList.add(con);   
        test.StartTest();
        update contactList;
        USupdate_Opt_Out_Account.Opt_Out_AccountUpdate(contactList);
        test.StopTest();
    }
}