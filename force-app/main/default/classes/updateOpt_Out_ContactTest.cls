/*************************************************************************************************************************
  Class Name     : updateOpt_Out_ContactTest
  Description    : Test Class for class updateOpt_Out_Contact
  Created By     : Sohil Shah(CloudSense)
  Created On     : 04/22/2015
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  CloudSense/Sohil Shah               04/22/2015              Created DEF-001643
***************************************************************************************************************************/
@isTest
public class updateOpt_Out_ContactTest
{
    static testMethod void opt_Out_ContactUpdateTest()
    {       
        List<Account> acc1 = ZTS_DataUtilityTest.createAccountRecord(1);
        insert acc1;
        Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Account_Contact').getRecordTypeId(); 
        Contact con = new Contact(RecordTypeId = rtId, FirstName='Test',LastName='Contact1', AccountId = acc1[0].id, Interface_Email_Opt_Out__c = false, ZTS_Invalid_Email__c = false,ZTS_EU_Contact_Status__c = 'Active',ZTS_US_Profession__c = 'Academia', ZTS_US_Job_Function__c= 'Clinical Faculty');
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        insert conList;
        updateOpt_Out_Contact.copyAccountEmailOnContactInsert(conList);
        acc1[0].Email__c = 'abe@1111.com';
        acc1[0].ZTS_US_Email_Opt_Out__c = true;
        acc1[0].ZTS_Invalid_Email__c = true;
        List<Account> accountList = new List<Account>();
        accountList.add(acc1[0]);  
        test.StartTest();
        update accountList;
        Contact c = new Contact();
        c.LastName = 'Test';
        c.AccountId = accountList[0].Id;
        c.ZTS_US_Profession__c = 'Account Contact';
        c.ZTS_US_Job_Function__c = 'Account Contact';
        c.ZTS_EU_Contact_Status__c = 'Active';
        
        insert c;
        test.StopTest();
    }
    
}