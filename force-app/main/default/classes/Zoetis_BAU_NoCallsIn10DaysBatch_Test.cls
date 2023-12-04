@isTest
private class Zoetis_BAU_NoCallsIn10DaysBatch_Test {
    @testSetup
    static void setup(){
        DispatchTriggerHandler.bypass('ZTS_EU_Account_PositionTriggerHandler');
        DispatchTriggerHandler.bypass('CallTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_PositionTriggerHandler');
        DispatchTriggerHandler.bypass('Time_Out_of_TerritoryTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        
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
        intlUsers.add(u1);
        
        User u2 = TestDataFactory.createUser(standardProfileId, null, null, false);
        u2.FirstName = String.format('User2{0}', new List<Object>{2});
        u2.ZTS_EU_Market__c = 'United States';
        u2.ManagerId = Userinfo.getUserId();
        u2.IsActive = true;
        intlUsers.add(u2);
        
        INSERT intlUsers;
        
        
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        
        
        ObjectPermissions obp = new ObjectPermissions();
        obp.ParentId = ps.Id;
        obp.SobjectType = 'ZTS_US_Key_Account_Email_Reminders__c';
        obp.PermissionsRead = true;
        obp.PermissionsCreate = false;
        obp.PermissionsEdit = false;
        obp.PermissionsDelete = false;
        obp.PermissionsViewAllRecords = false;
        obp.PermissionsModifyAllRecords = false;
        INSERT obp;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u2.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        //Create Territory Model
        Territory2Model territoryModel = new Territory2Model();
        territoryModel.DeveloperName = 'TestModel';
        territoryModel.Name = 'TestModel';
        insert territoryModel;
        
        //Fetch Territory type
        Territory2Type territoryType = [
            SELECT Id, DeveloperName
            FROM Territory2Type
            LIMIT 1
        ];
        
        //Create record in Standard Territory object
        Territory2 territory = new Territory2();
        territory.AccountAccessLevel = 'Edit';
        territory.CaseAccessLevel = 'Edit';
        territory.DeveloperName = 'TestTerritory';
        territory.Name = 'TestTerritory';
        territory.OpportunityAccessLevel = 'Edit';
        territory.Territory2ModelId = territoryModel.Id;
        territory.Territory2TypeId = territoryType.Id;
        insert territory;
        
        
        System.runAs(u1){
            //Account Creation
            Account acc = TestDataFactory.createAccount_US('US Test Account',false);
            
            //Updation of that account to a Pork
            acc.ZTS_EU_Key_Account__c = true;
            acc.CreatedDate = Date.today() - 20;
            acc.ZTS_EU_Market__c = 'United States';
            INSERT acc;
            
            
            Account acc1 = TestDataFactory.createAccount_US('US Test Account1',false);
            acc1.ZTS_EU_Key_Account__c = true;
            acc1.CreatedDate = Date.today() - 20;
            INSERT acc1;
            
            
            Map<Id, ZTS_AccountTerritory__c> accountTerritoryByAccountId = new Map<Id, ZTS_AccountTerritory__c>();
            
            ZTS_EU_Territory__c ztsTerritoryUS = TestDataFactory.createZTSTerritory('TestTerritoryUS',territory.Id,'United States',true);
            ZTS_AccountTerritory__c tempTerritory = TestDataFactory.createAccountTerritory(acc.Id,ztsTerritoryUS.Id,true);
            accountTerritoryByAccountId.put(acc.Id,tempTerritory);
            
            
            
            Map<Id, ZTS_EU_Position__c> positionsByUserId = new Map<Id, ZTS_EU_Position__c>();
            ZTS_EU_Position__c ZEP = TestDataFactory.createPosition('TestTerritoryUS',ztsTerritoryUS.Id,'United States',UserInfo.getUserId(),false);
            ZEP.ZTS_EU_Employee__c = UserInfo.getUserId();
            ZEP.ZTS_EU_Is_Active__c = true;
            INSERT ZEP;
            positionsByUserId.put(UserInfo.getUserId(), ZEP);
            
            
            //Call Creation for that account
            Call__c call = TestDataFactory.createCall(acc.Id, false);
            call.CreatedDate = Date.today()-10;
            INSERT call;
            
            //Call Creation for that account
            Call__c call2 = TestDataFactory.createCall(acc.Id, false);
            call2.CreatedDate = Date.today()-14;
            INSERT call2;
            
            //Call Creation for that account
            Call__c call3 = TestDataFactory.createCall(acc1.Id, false);
            INSERT call3;
            
            
            ZTS_EU_Account_Position__c accountPosition1 = TestDataFactory.createAccountPosition(acc.Id,accountTerritoryByAccountId.get(acc.Id).Id, false);
            accountPosition1.ZTS_US_Receive_Call_Reminders__c = true;
            accountPosition1.ZTS_EU_Position__c = ZEP.Id;
            INSERT accountPosition1;
            ZTS_EU_Account_Position__c accountPosition2 = TestDataFactory.createAccountPosition(acc.Id,accountTerritoryByAccountId.get(acc.Id).Id, false);
            accountPosition2.ZTS_EU_Position__c = ZEP.Id;
            INSERT accountPosition2;
            Time_Out_of_Territory__c TOT = new Time_Out_of_Territory__c();
            TOT.ZTS_EU_Status__c = 'Planned';
            TOT.ZTS_EU_Type__c = 'Time Off';
            TOT.ZTS_EU_Reason__c = 'Normal Holiday';
            TOT.ZTS_EU_Start_Date__c = Date.today()-7;
            TOT.ZTS_EU_End_Date__c = Date.Today()-5;
            TOT.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            INSERT TOT;
            
            Time_Out_of_Territory__c TOT2 = new Time_Out_of_Territory__c();
            TOT2.ZTS_EU_Status__c = 'Submitted';
            TOT2.ZTS_EU_Type__c = 'Time Off';
            TOT2.ZTS_EU_Reason__c = 'Company Holiday';
            TOT2.ZTS_EU_Start_Date__c = Date.today()-2;
            TOT2.ZTS_EU_End_Date__c = Date.Today()-2;
            TOT2.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            INSERT TOT2;
            
            ZTS_US_Key_Account_Email_Reminders__c ob = new ZTS_US_Key_Account_Email_Reminders__c();
            ob.ZTS_US_Account_Position_Employee__c = UserInfo.getUserId();
            ob.ZTS_US_Account__c = acc.Id;
            ob.ZTS_US_Key__c = acc.Id;
            ob.ZTS_US_Last_Call_Created_Date__c = Date.today()-10;
            ob.ZTS_US_Email_Reminder_Date__c = Date.today();
            UPSERT ob;
            
            ZTS_US_Key_Account_Email_Reminders__c ob1 = new ZTS_US_Key_Account_Email_Reminders__c();
            ob1.ZTS_US_Account_Position_Employee__c = u1.Id;
            ob1.ZTS_US_Account__c = acc1.Id;
            ob1.ZTS_US_Key__c = u1.Id+'-'+acc1.Id;
            ob1.ZTS_US_Last_Call_Created_Date__c = Date.today()-10;
            ob1.ZTS_US_Email_Reminder_Date__c = Date.today();
            UPSERT ob1;
            
            ZTS_US_Key_Account_Email_Reminders__c ob2 = new ZTS_US_Key_Account_Email_Reminders__c();
            ob2.ZTS_US_Account_Position_Employee__c = u1.Id;
            ob2.ZTS_US_Account__c = acc.Id;
            ob2.ZTS_US_Key__c = u1.Id+'-'+acc.Id;
            ob2.ZTS_US_Last_Call_Created_Date__c = Date.today()-10;
            ob2.ZTS_US_Email_Reminder_Date__c = Date.today();
            UPSERT ob2;
        }
        
        DispatchTriggerHandler.clearBypass('ZTS_EU_Account_PositionTriggerHandler');
        DispatchTriggerHandler.clearBypass('CallTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_PositionTriggerHandler');
        DispatchTriggerHandler.clearBypass('Time_Out_of_TerritoryTriggerHandler');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
    }
    
    
    
    @isTest
    static void test1(){
        test.startTest();
        User U = [SELECT Id,IsActive FROM User WHERE FirstName='User22'];
        
        system.runAs(U){
            system.debug('reminder object create access Standard User--->'+schema.SObjectType.ZTS_US_Key_Account_Email_Reminders__c.isCreateable());
            database.executeBatch(new Zoetis_BAU_NoCallsIn10DaysBatch());
        }
        
        User U2 =[SELECT Id FROM User WHERE FirstName='User11'];
        system.runAs(U2){
            system.debug('reminder object create access Sys Admin--->'+schema.SObjectType.ZTS_US_Key_Account_Email_Reminders__c.isCreateable());
            Zoetis_BAU_NoCallsIn10DaysBatch sh1 = new Zoetis_BAU_NoCallsIn10DaysBatch();
            String sch = '0 0 23 * * ?';
            system.schedule('Zoetis_BAU_NoCallsIn10DaysBatc', sch, sh1);
        }
        test.stopTest();
    }
}