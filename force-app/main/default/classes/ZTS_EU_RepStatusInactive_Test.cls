/**
 * @description       : Test class for ZTS_EU_RepStatusInactive
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2014   Unknown                     Initial Version
 * 1.1   01-22-2021   Unknown                     Unknown Updates
 * 1.2   06-07-2022   Ethan Hirsch @ Zoetis Inc   Change reference to GER & CE Euro Business Administrator to not 
 *                                                include special characters as part of Profile Name changes to 
 *                                                avoid Copado deploy issues.
**/
@isTest (SeeAlldata = False)
public class ZTS_EU_RepStatusInactive_Test{


    static final String CONTACT_UPD_ERROR_ORIGIN = 'ZTS_EU_RepStatusInactive_Test - ZTS_EU_RepStatusInactive_method(): Update Contact ';
    
    static testMethod void ZTS_EU_RepStatusInactive_method(){
        
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        Profile profiles=[Select Id From Profile Where Name='GER and CE Euro Business Administrator'];
        List<User> usersList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='deneme@deneme.com';
        newuser.username='deneme1@deneme1.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        usersList.add(newuser);
        Insert  usersList;
        Account acc;
        List<Contact> conList = new List<Contact>();
        System.runas(usersList[0]){
            
            acc = new Account(name = 'Test Account',
                              Type = 'Farm',ZTS_EU_Sub_Type__c = 'Beef',ZTS_EU_Address_Line_1__c = 'Test Address Line ',
                              ZTS_EU_City__c = 'Test City',ZTS_EU_Zip_Postal_Code__c = 'LD',
                              RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId(),
                              ZTS_EU_Main_Phone__c='9876789876',CurrencyIsoCode='EUR',
                              ZTS_EU_Market__c='United Kingdom',
                              Practice_Management_Software__c = 'Other',
                              Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                              ZTS_EU_Vetsave_ID__c='200',
                              ZTS_EU_Vetsave_HO_ID__c='56', ownerid = usersList[0].id);           
            Insert acc;
            Test.starttest();
            Contact con = new Contact(); 
            con.firstname='Test First';
            con.lastname = 'Test Contact';
            con.ZTS_EU_Speaker_Flag__c=true;
            con.ZTS_EU_Rep_Contact_Status__c = 'Active';
            con.Accountid = acc.id;
            con.ownerid = usersList[0].id;
            con.ZTS_EU_Market__c = 'United Kingdom';
            conList.add(con);
            Insert conList;
            //    for(Account acnt : acc){
            acc.ZTS_EU_Primary_Contact__c= conList[0].id;
            //    }
            update acc;
        }
        
        System.runas(usersList[0]){
            try{
                List<Contact> lstcon = new List<Contact>();
                for(Contact connew : conList){
                    connew.ZTS_EU_Rep_Contact_Status__c = 'Inactive';
                    lstcon.add(connew);
                }
                Update lstcon;
            }
            catch(DmlException dex)
            {
                String errorMessages = '';
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(CONTACT_UPD_ERROR_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                }
                errorMessages.removeEnd('\n');
                ZTS_EU_Logger.notify = true;
                ZTS_EU_Logger.error(errorMessages,null, CONTACT_UPD_ERROR_ORIGIN);
            }
        }
        Test.Stoptest();
    }
}