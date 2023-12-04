@isTest
public class TurnTriggersOnTest 
{
    @testSetup
    public static void setup()
    {
        CPQ_TestDataFactory.createMarkets(true);
    }
	@isTest
    public static void failTimeOffSalesRep()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            // Should skip.
            // TriggerActivation__c act = new TriggerActivation__c();
            // act.Name = 'TimeoffSalesRep';
            // act.ZTS_EU_Bypass__c = false;
            // insert act;
            
            ZTS_EU_Coaching__c newCoachingFail = new ZTS_EU_Coaching__c(ZTS_EU_Sales_Rep__c = usr.Id, ZTS_EU_start_Date__c = System.today() - 3, ZTS_EU_End_Date__c = System.today() + 1);
            insert newCoachingFail;
        }
    }
    
    @isTest
    public static void succeedTimeOffSalesRep()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            // // Should skip.
            // TriggerActivation__c act = new TriggerActivation__c();
            // act.Name = 'TimeoffSalesRep';
            // act.ZTS_EU_Bypass__c = true;
            // insert act;
            
            Time_Out_of_Territory__c TOT = new Time_Out_of_Territory__c(ZTS_EU_start_Date__c = System.today() - 2, ZTS_EU_End_Date__c = System.today() + 2, ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM');
            insert TOT;
            
            TOT.ZTS_EU_Status__c = 'Submitted';
            update TOT;
    		
            try
            {
                ZTS_EU_Coaching__c newCoaching = new ZTS_EU_Coaching__c(ZTS_EU_Sales_Rep__c = usr.Id, ZTS_EU_start_Date__c = System.today() - 1, ZTS_EU_End_Date__c = System.today() + 1);
                insert newCoaching;
            }
			catch (DMLException e)
            {
                System.debug('should catch: ' + e);
            }
                        
            try
            {
                ZTS_EU_Coaching__c newCoaching = new ZTS_EU_Coaching__c(ZTS_EU_Sales_Rep__c = usr.Id, ZTS_EU_start_Date__c = System.today() - 3, ZTS_EU_End_Date__c = System.today() + 1);
                insert newCoaching;
            }
			catch (DMLException e)
            {
                System.debug('should catch: ' + e);
            }
        }
    }
    @isTest
    public static void succeedPIT_Coaching_GuideTrigger()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        Account acc = new Account();
        acc.Name = 'Test123';
        acc.ZTS_EU_Market__c = 'United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        System.runAs(usr)
        {
            insert acc;
        }
        PIT_Coaching_Guide__c cg = new PIT_Coaching_Guide__c();
        cg.PIT_Coach__c = Userinfo.getUserId();
        cg.PIT_Coaching_Status__c = 'New';
        cg.PIT_Colleague__c = Userinfo.getUserId();
        cg.PIT_Colleague_Comments__c = 'comments123';
        cg.ZTS_EU_Market__c = 'United Kingdom';
        insert cg;
    }
    @isTest
    public static void succeedZTS_US_Contracted_Services()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            // Should skip.
            // TriggerActivation__c act = new TriggerActivation__c();
            // act.Name = 'ZTS_US_Contracted_Services';
            // act.ZTS_EU_Bypass__c = true;
            // act.isActive__c = true;
            // insert act;
            
            Account acc = new Account();
            acc.Name = 'Test123';
            acc.ZTS_EU_Market__c = 'United Kingdom';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc.ZTS_EU_Zip_Postal_Code__c = '00000';
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name = 'AA Test';
            opp.CloseDate = Date.Today();
            opp.Country1__c = 'United Kingdom';
            opp.Customer_Language__c = 'English';
            opp.CurrencyIsoCode = 'GBP';           
            opp.Pricebook2Id = Test.getStandardPricebookId();
            opp.Probability = 10;
            opp.TotalOpportunityQuantity = 0;
            opp.Sales_Org1__c = '7974 United Kingdom';
            opp.StageName = 'Qualified';
            opp.ZTS_EU_Market__c = 'United Kingdom';
            opp.Type = 'TPG_LM';
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('TPG_LM').getRecordTypeId();
            opp.AccountId = acc.Id;
            insert opp;
            
            ZTS_US_Contracted_Services__c contractedService = new ZTS_US_Contracted_Services__c(ZTS_US_Opportunity__c = opp.Id);
            insert contractedService;
            update contractedService;
            delete contractedService;
            undelete contractedService;
        }
    }
}