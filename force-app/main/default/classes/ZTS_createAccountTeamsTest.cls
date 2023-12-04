@isTest
public class ZTS_createAccountTeamsTest
{
    public static testMethod void accountRecords()
    {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Account a = new Account(Name = 'Account With Account Team',ZTS_EU_Account_Status__c = 'Pending',ZTS_EU_Market__c='United Kingdom',
            Practice_Management_Software__c = 'Other',
            Other_Practice_Management_Software__c = 'Sample Practice Management Software',ZTS_EU_Zip_Postal_Code__c = '00000');
            List<Account> accountList = new List<Account>();
            accountList.add(a); 
            ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_EU_Territory_synced__c = true, ZTS_EU_Market__c ='India');
            insert territory;
            ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
            insert userTerritory;   
            Test.StartTest();  
            insert accountList; 
            
            //ZTS_createAccountTeams myObject = new ZTS_createAccountTeams();
            ZTS_createAccountTeams.AccountTeamCreation(accountList);
            Test.StopTest();
        }
        List<AggregateResult> accountTeam  =  new List<AggregateResult>();
        accountTeam = [Select Count(Id) from ZTS_EU_Account_Position__c];
        System.assertEquals(accountTeam.Size(), 1);
    }
    public static testMethod void accountRecords2()
    {
        
        //User u = [select Id, username from User where Name = 'Data Admin'][0]; 
        User u = new User();
        u = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        u.FirstName = 'intlUser';
        u.zts_eu_market__c = 'United Kingdom';
        insert u;
        System.runAs(u)
        {
            Account a = new Account(Name = 'Account With Account Team',ZTS_Business_Class__c = 'Breeder',ZTS_EU_Account_Status__c = 'Pending',ZTS_EU_Market__c='United Kingdom', ZTS_EU_Zip_Postal_Code__c='11112',
            Practice_Management_Software__c = 'Other',
            Other_Practice_Management_Software__c = 'Sample Practice Management Software');
            List<Account> accountList = new List<Account>();
            accountList.add(a); 
            ZTS_EU_Territory__c territory = new ZTS_EU_Territory__c(Name = 'Test Territory',ZTS_EU_Territory_synced__c = true, ZTS_EU_Market__c ='India');
            insert territory;
            ZTS_EU_Position__c userTerritory = new ZTS_EU_Position__c(ZTS_EU_Territory__c = territory.id,ZTS_EU_Employee__c = a.OwnerId);
            insert userTerritory;   
            Test.StartTest();           
            insert accountList;
            //ZTS_createAccountTeams myObject = new ZTS_createAccountTeams();
            ZTS_createAccountTeams.AccountTeamCreation(accountList);
            Test.StopTest();
        }
        List<AggregateResult> accountTeam  =  new List<AggregateResult>();
        accountTeam = [Select Count(Id) from ZTS_EU_Account_Position__c];
        System.assertEquals(accountTeam.Size(), 1);
    }
}