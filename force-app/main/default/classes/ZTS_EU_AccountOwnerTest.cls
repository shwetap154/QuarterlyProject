/*
 * Name          :   ZTS_EU_AccountOwnerTest
* Description   :    This is used to test ZTS_EU_AccountOwnerTest
* Author        :    Amitabh
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
01/02/2018       Amitabh                      Created
 */
@isTest(seeAllData= false)
//public static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration Profile', false);
public with sharing class ZTS_EU_AccountOwnerTest 
{
   // private static User u = ZTS_EU_DataUtilityTest.createUserWithProfile('Integration Profile', false);
         static testMethod void TestZTS_EU_AccountOwner()
    {      
            integer i;
            List<Account> acclist=new List<Account>();
            List<AccountAndContactOwnerId__c> ownerids= AccountAndContactOwnerId__c.getall().values(); 
            Account acc;
        	User usr = new User();
            usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
            usr.FirstName = 'eltonUser';
            usr.zts_eu_market__c = 'United Kingdom';
            insert usr;
            for(i=0;i<=20;i++)
            {
            acc = new Account(Name = 'Test Account'+i, Type = 'Farm', ZTS_EU_Market__c='United Kingdom',
                Practice_Management_Software__c = 'Other',
                Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                ZTS_EU_Country__c = 'United Kingdom',
                ZTS_EU_Address_Line_1__c = 'city'+i,ZTS_EU_Zip_Postal_Code__c='3131',ZTS_EU_Account_Status__c='Active',Ownerid='005F0000003wxnb');
            acclist.add(acc); 
            }
        	System.runAs(usr)
            {
                insert acc;
            }
            
            test.startTest();
            ZTS_EU_AccountOwner ap = new  ZTS_EU_AccountOwner();
            database.executebatch(ap);
            test.stoptest();   
    }
}