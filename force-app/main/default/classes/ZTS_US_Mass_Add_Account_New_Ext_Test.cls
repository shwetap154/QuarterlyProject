/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Mass_Add_Account_New_Ext_Test
* Description   :  Tests the ZTS_US_Mass_Add_account_New_Ext apex class.         
* @author       :  Cognizant
**************************************************************************************************
* Ver.    Date          Author                    Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/10         Rachana Prabhu             Created the Class.
*****************************************************************************************************************************************/
@isTest
public class ZTS_US_Mass_Add_Account_New_Ext_Test {
    
    @TestSetup
    static void setup(){
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EventsTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_TerritoryTriggerHandler');
        
        List<ZTS_Events__c> listEvents;
        Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id;
        
        Id standardProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1].Id;
        
        List<User> intlUsers = new List<User>();
        User u1 = TestDataFactory.createUser(adminProfileId, null, null, false);
        u1.FirstName = String.format('User1{0}', new List<Object>{1});
        
        u1.ZTS_EU_Market__c = 'United States';
        u1.ManagerId = Userinfo.getUserId();
        u1.IsActive = true;
        u1.Territory__c = 'TestTerritory';
        intlUsers.add(u1);
        
        User u2 = TestDataFactory.createUser(standardProfileId, null, null, false);
        u2.FirstName = String.format('User2{0}', new List<Object>{2});
        u2.ZTS_EU_Market__c = 'United States';
        u2.Territory__c='Sample Territory';
        u2.ManagerId = Userinfo.getUserId();
        u2.IsActive = true;
        intlUsers.add(u2);
        
        INSERT intlUsers;
        
        List<Account> AccountList = new List<Account>();
        System.runAs(u1){
            List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type LIMIT 1];
            Territory2Model terrModel = new Territory2Model();
            terrModel.Name = 'Name'; // required field
            terrModel.DeveloperName = 'Sample_territory_1'; 
            insert terrModel ;
            
            Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
            insert objTerr;
            listEvents = ZTS_EU_DataUtilityTest.createEvents(1);
            INSERT listEvents;
            
            for(Integer i=0;i<=18;i++){
                AccountList.add(new account(name='test123'+i, ZTS_EU_Market__c='United States',
                                            Practice_Management_Software__c = 'Other',
                                            Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                            ZTS_EU_Zip_Postal_Code__c = '00000',
                                            ZTS_US_NARC_ID__c='0001'+i,
                                            Phone='9748694980',
                                            Type='Diagnostic',
                                            BillingStreet='123 Main St',
                                            BillingCity='abc city',
                                            BillingCountry='United States',
                                            BillingState='California',
                                            BillingPostalCode='12345',
                                            ZTS_EU_City__c='abc town',
                                            ZTS_EU_Country__c='United States',
                                            ZTS_US_State_Province__c='CA',
                                            ZTS_US_Business_Class__c='Business Class',
                                            ZTS_US_Sub_Class_1__c='Sub Class 1',
                                            
                                            Email__c='abc@xyz.com',
                                            ZTS_EU_Account_Status__c='Active'));
            }
            insert AccountList;
            List<ZTS_US_Event_Account__c> listEventAccounts = new List<ZTS_US_Event_Account__c>();
            listEventAccounts.add(new ZTS_US_Event_Account__c(ZTS_US_Event_Account__c=AccountList[0].Id,ZTS_US_Events__c=listEvents[0].Id));
            
            
            List<Account> AccountList2 = new List<Account>();
            for(Integer i=0;i<=10;i++){
                AccountList2.add(new account(name='test456'+i, ZTS_EU_Market__c='United States',
                                             Practice_Management_Software__c = 'Other',
                                             Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                             ZTS_EU_Zip_Postal_Code__c = '00000',
                                             ZTS_US_NARC_ID__c='0002'+i,
                                             Type='Diagnostic',
                                             Phone='9748694980',
                                             BillingStreet='123 Main St',
                                             BillingCity='abc city',
                                             BillingCountry='United States',
                                             BillingPostalCode='12345',
                                             BillingState='California',
                                             ZTS_EU_City__c='abc town',
                                             ZTS_US_State_Province__c='CA',
                                             ZTS_EU_Country__c='United States',
                                             ZTS_US_Business_Class__c='Business Class',
                                             ZTS_US_Sub_Class_1__c='Sub Class 1',
                                             
                                             Email__c='abc@xyz.com',
                                             ZTS_EU_Account_Status__c='Active'));
            }
            insert AccountList2;
            Integer i = 1;
            for(Account var:AccountList2){
                if(i<=3){
                    listEventAccounts.add(new ZTS_US_Event_Account__c(ZTS_US_Event_Account__c=var.Id,ZTS_US_Events__c=listEvents[0].Id));
                    i++;
                }
            }
            INSERT ListEventAccounts;
            
            ObjectTerritory2Association objectTerritory2Assoc = new ObjectTerritory2Association(Territory2Id= objTerr.Id , ObjectId = AccountList[0].Id, AssociationCause='Territory2Manual');
            insert  objectTerritory2Assoc;
            UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u1.Id, RoleInTerritory2='Sales / Marketing Manager');
            insert objUserTerritory2Association;
        }
        
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EventsTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_TerritoryTriggerHandler');
    }
    
    @isTest static void testExecuteSearch(){
        User usUser = [SELECT Id,IsActive,ZTS_EU_Market__c,Territory__c 
                       FROM User 
                       WHERE ZTS_EU_Market__c ='United States' 
                       AND Territory__c = 'TestTerritory' Limit 1];
        System.runAs(usUser){
            test.startTest();
            List<ZTS_Events__c> listEvents = [SELECT Id FROM ZTS_Events__c];
            List<Account> AccountList2=[SELECT Id From Account];
            ZTS_US_Mass_Add_Account_New_Ext massAccount = new ZTS_US_Mass_Add_Account_New_Ext();
            massAccount = new ZTS_US_Mass_Add_Account_New_Ext();
            ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
            ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM ZTS_Events__c].Id);
            massAccount = new ZTS_US_Mass_Add_Account_New_Ext();
            massAccount.territoryId = new List<Id>(); 
            massAccount.listAccID = new List<ID>(); 
            massAccount.searchKey = ''; 
            massAccount.masterChechBoxVal = false; 
            List<ZTS_US_Mass_Add_Account_New_Ext.AccountWrapper> categories = massAccount.getCategories();
            ZTS_US_Mass_Add_Account_New_Ext.AccountWrapper category = categories[0];
            massAccount.masterChechBoxVal = true;
            massAccount.getCategories();
            massAccount.selected.put(AccountList2[0].Id, true); 
            massAccount.getCategories();
            Integer accountCount = massAccount.getAccountCounts();
            massAccount.offSetSize = 10;
            Boolean prvResult = massAccount.getprv();
            System.assertEquals(false, prvResult);
            massAccount.offSetSize = 0;
            prvResult = massAccount.getprv();
            System.assertEquals(true, prvResult);
            
            massAccount.offSetSize = 10;
            massAccount.queryLimit = 20;
            massAccount.CountTotalRecords = 50;
            Boolean nxtResult = massAccount.getnxt();
            System.assertEquals(false, nxtResult);
            massAccount.offSetSize = 30;
            nxtResult = massAccount.getnxt();
            System.assertEquals(true, nxtResult);
            PageReference pageRef = massAccount.cancel();
            system.assertEquals(0, massAccount.listAccID.size());
            PageReference pageRefsaveacc = massAccount.saveAccounts();
            system.assertEquals(true, massAccount.listAccID.size()>0);
			system.assertEquals(20, massAccount.listAccID.size());
            test.stoptest();
        }
    }
}