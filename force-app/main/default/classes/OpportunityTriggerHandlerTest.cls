/**
* File Name     :  OpportunityTriggerHandlerTest
* @description  :  Test class for 'OpportunityTriggerHandler'.
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     2/17/2020     Ramiro Alvarez @ ATG     Created the Class.
* 1.0     06/17/2022    Padma Nerella @ Zoetis   added test method for updateOpptyRefLab
*/
@istest

public class OpportunityTriggerHandlerTest {

    private static final Id carystaRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CARYSTA_HVC').getRecordTypeId();
    private static final Id dxRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Non_Quoting').getRecordTypeId();
    private static final Id oppRefLabRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Zoetis_Reference_Labs_Opportunity').getRecordTypeId();
    
    @testSetup
    public static void setup() {     

        Territory2Type territoryType = [
            SELECT 
                Id, 
                DeveloperName 
            FROM Territory2Type 
            LIMIT 1
        ];
        Territory2Model territoryModel = new Territory2Model();
        territoryModel.DeveloperName = 'TestModel';
        territoryModel.Name = 'TestModel';
        insert territoryModel;

        Territory2 territory = new Territory2();
        territory.AccountAccessLevel = 'Edit';
        territory.CaseAccessLevel = 'Edit';
        territory.DeveloperName = 'TestTerritory';
        territory.Name = 'TestTerritory';
        territory.OpportunityAccessLevel = 'Edit';
        territory.Territory2ModelId = territoryModel.Id;
        territory.Territory2TypeId = territoryType.Id;
        insert territory;

        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new Carysta_Default_Opportunity_Owner__c(SetupOwnerId=UserInfo.getOrganizationId(), Default_Owner_Id__c=UserInfo.getUserId());
            insert new Carysta_Default_Opportunity_Owner__c(SetupOwnerId=UserInfo.getUserId(), Default_Owner_Id__c=UserInfo.getUserId());

            //insert custom settings DATA
            List<Territory_Role_Matrix__c> csList = new lIST<Territory_Role_Matrix__c>();
            Territory_Role_Matrix__c cs1=new Territory_Role_Matrix__c(Name='BSM',Role_Value__c='LM');
            csList.add(cs1);
            Territory_Role_Matrix__c cs2=new Territory_Role_Matrix__c(Name='SAM',Role_Value__c='SAM');
            csList.add(cs2);
            insert csList;

            ZTS_EU_Territory__c ztsTerritoryUS = TestDataFactory.createZTSTerritory('TestTerritoryUS', territory.Id, 'United States', false);
            ztsTerritoryUS.ZTS_EU_Type__c = 'Area';
            ztsTerritoryUS.ZTS_Field_Force_Name__c = 'Diagnostics Solution Consultant';
            ztsTerritoryUS.ZTS_TerritoryRole__c = 'LM';
            insert ztsTerritoryUS;
        
            ZTS_EU_Position__c tempPosition = TestDataFactory.createPosition(ztsTerritoryUS.Name, ztsTerritoryUS.Id, ztsTerritoryUS.ZTS_EU_Market__c, false);
            tempPosition.ZTS_EU_Employee__c = UserInfo.getUserId(); 
            insert tempPosition;

            // Create Markets and Market Countries 
            List<Market__c> markets = CPQ_TestDataFactory.createMarkets(true);
            CPQ_TestDataFactory.createMarketCountrys(markets, true);

            // Create an account and a contact
            Account account = CPQ_TestDataFactory.createAccount(true);

            //Create UserTerritory2Association record
            createUserTerritoryToAssociation();

            ZTS_AccountTerritory__c tempTerritory = TestDataFactory.createAccountTerritory(account.Id, ztsTerritoryUS.Id, true);
        }
    }

    @istest
    public static void createOppty() {    

        UserTerritory2Association userTerr = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0];
        //System.debug('User Terr Test: ' + userTerr);

        Test.startTest();

        Account account = [SELECT Id FROM Account][0];

        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty = createOppty(account,usMarket,userTerr.UserId,true);        
        
        System.debug('Oppty OwnerID: ' + oppty.OwnerId);

        Test.stopTest();        

    }




    static void createUserTerritoryToAssociation()  {
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
         User u2 = new User(firstname= 'Test-RA',
                              lastname='XXXX-RA',
                              Alias='testRA1',
                              email = 'testRA123@test.com',
                              username= 'testRA123@test.com', 
                              profileId= p.id, 
                              emailencodingkey='UTF-8',
                              languagelocalekey='en_US',
                              localesidkey='en_US',
                              timezonesidkey='America/Los_Angeles',
                              ZTS_EU_Market__c ='India');
        insert u2;   
        
        List<ETM_Required_Ids__mdt> mdtETMRequiredIds = [SELECT DeveloperName,ETM_Model_ID__c,ETM_Type_Id__c FROM ETM_Required_Ids__mdt Where DeveloperName = 'Default_Values' Limit 1];
        
        Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c, Name='TestTerritory', Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c);
        System.RunAs(u2){
        insert objTerr;
        }

        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2='');

        System.RunAs(u2){
        insert objUserTerritory2Association;
        }
        
    }

    
	public static Opportunity createOppty(Account account, Market__c market,Id ownerId,Boolean doInsert) {
		//Oppty
		Opportunity opportunity = new Opportunity();
		opportunity.Name = 'AA Test';
		opportunity.AccountId = account.Id;
		opportunity.CloseDate = Date.Today();
		opportunity.Country1__c = 'United States';
		opportunity.Customer_Language__c = 'English';
		opportunity.Market__c = market.Id;
		opportunity.CurrencyIsoCode = 'USD';           
		opportunity.Pricebook2Id = Test.getStandardPricebookId();
		opportunity.Probability = 10;
		opportunity.TotalOpportunityQuantity = 0;
		opportunity.Sales_Org1__c = '1436 United States';
        opportunity.StageName = 'Qualified';
        opportunity.OwnerId = ownerId;
		if(doInsert) { insert opportunity;}
		return opportunity;   

	}
        
    @istest
    public static void updateOppty() { 
        string testAfter = 'Animana';
        string testBefore= 'Cornerstone';
        Test.startTest();
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        acnt.Practice_Management_Software__c = testBefore;
        update acnt;

        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
          
        oppty2.name = 'test Lead Ref lab conversion';
        oppty2.RecordTypeId = dxRecTypeId ;
        oppty2.LeadSource = 'Reference Lab Lead';
        List<Opportunity> triggerNew = new List<Opportunity>();
        Map<Id, Opportunity> triggerNewMap = new Map<Id, Opportunity>();
        insert oppty2;
        oppty2.StageName = 'Closed/Installed (100%)';
        oppty2.What_PIMS_integration_wanted__c = testAfter;
        oppty2.Carrier_UPS_Courier__c = 'UPS';
        triggerNew.add(oppty2);
        triggerNewMap.put(oppty2.id,oppty2);
        USOpportunityTriggerService.afterUpdate(triggerNew, triggerNewMap);
        //System.debug('Oppty OwnerID: ' + oppty.OwnerId);
        Test.stopTest();        
        Account testAcnt = [select id,Practice_Management_Software__c , Send_In_Courier__c from Account where id =: acnt.id];   
        System.assertEquals('UPS', testAcnt.Send_In_Courier__c);
        System.assertNotEquals(testBefore, testAcnt.Practice_Management_Software__c);
    }
    
    
     @istest
    public static void updateOpptyRefLab() { 
        string testAfter = 'Animana';
        string testBefore= 'Cornerstone';
        Test.startTest();
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        acnt.Practice_Management_Software__c = testBefore;
        update acnt;

        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
          
        oppty2.name = 'test Lead Ref lab conversion';
        oppty2.RecordTypeId = oppRefLabRecTypeId ;
        List<Opportunity> triggerNew = new List<Opportunity>();
        Map<Id, Opportunity> triggerNewMap = new Map<Id, Opportunity>();
        insert oppty2;
        oppty2.StageName = 'Closed/Installed (100%)';
       oppty2.What_PIMS_integration_wanted__c = testAfter;
        oppty2.Carrier_UPS_Courier__c = 'UPS';
        triggerNew.add(oppty2);
        triggerNewMap.put(oppty2.id,oppty2);
        USOpportunityTriggerService.afterUpdate(triggerNew, triggerNewMap);
        //System.debug('Oppty OwnerID: ' + oppty.OwnerId);
        Test.stopTest();        
        Account testAcnt = [select id,Practice_Management_Software__c , Send_In_Courier__c from Account where id =: acnt.id];   
        System.assertEquals('UPS', testAcnt.Send_In_Courier__c);
        System.assertNotEquals(testBefore, testAcnt.Practice_Management_Software__c);
    }

    @istest
    public static void updateOpptyRefLab_Other() { 
        string testAfter = 'Other';
        string testBefore= 'Cornerstone';
        string testOtherValue = 'After Integration';
        Test.startTest();
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        acnt.Practice_Management_Software__c = testBefore;
        update acnt;

        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
          
        oppty2.name = 'test Lead Ref lab conversion';
        oppty2.RecordTypeId = oppRefLabRecTypeId ;
        List<Opportunity> triggerNew = new List<Opportunity>();
        Map<Id, Opportunity> triggerNewMap = new Map<Id, Opportunity>();
        insert oppty2;
        oppty2.StageName = 'Closed/Installed (100%)';
        oppty2.What_PIMS_integration_wanted__c = testAfter;
        oppty2.if_other_please_describe__c = testOtherValue;
        oppty2.Carrier_UPS_Courier__c = 'UPS';
        triggerNew.add(oppty2);
        triggerNewMap.put(oppty2.id,oppty2);
        USOpportunityTriggerService.afterUpdate(triggerNew, triggerNewMap);
        //System.debug('Oppty OwnerID: ' + oppty.OwnerId);
        Test.stopTest();        
        Account testAcnt = [select id,Practice_Management_Software__c , Send_In_Courier__c, Other_Practice_Management_Software__c from Account where id =: acnt.id];   
        
        System.assertEquals('UPS', testAcnt.Send_In_Courier__c, 'Send in Courier was not set as expected.');
        System.assertEquals(testAfter, testAcnt.Practice_Management_Software__c, 
            'Practice Management Software was not set as expected');
        System.assertEquals(testOtherValue, testAcnt.Other_Practice_Management_Software__c,
            'Other Practice Management Software was not set as expected');
    }

    @istest
    public static void updateOpptyRefLab_OtherTruncate() { 
        string testAfter = 'Other';
        string testBefore= 'Cornerstone';
        string testOtherValue = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis,.';
        Test.startTest();
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        acnt.Practice_Management_Software__c = testBefore;
        update acnt;

        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
          
        oppty2.name = 'test Lead Ref lab conversion';
        oppty2.RecordTypeId = oppRefLabRecTypeId ;
        List<Opportunity> triggerNew = new List<Opportunity>();
        Map<Id, Opportunity> triggerNewMap = new Map<Id, Opportunity>();
        insert oppty2;
        oppty2.StageName = 'Closed/Installed (100%)';
        oppty2.What_PIMS_integration_wanted__c = testAfter;
        oppty2.if_other_please_describe__c = testOtherValue;
        oppty2.Carrier_UPS_Courier__c = 'UPS';
        triggerNew.add(oppty2);
        triggerNewMap.put(oppty2.id,oppty2);
        USOpportunityTriggerService.afterUpdate(triggerNew, triggerNewMap);
        //System.debug('Oppty OwnerID: ' + oppty.OwnerId);
        Test.stopTest();        
        Account testAcnt = [select id,Practice_Management_Software__c , Send_In_Courier__c, Other_Practice_Management_Software__c from Account where id =: acnt.id];   
        
        System.assertEquals('UPS', testAcnt.Send_In_Courier__c, 'Send in Courier was not set as expected.');
        System.assertEquals(testAfter, testAcnt.Practice_Management_Software__c, 
            'Practice Management Software was not set as expected');
        System.assertEquals(testOtherValue.substring(0, 255), testAcnt.Other_Practice_Management_Software__c,
            'Other Practice Management Software was not set as expected');
    }

    @istest
    public static void carystaTest() { 
        Test.startTest();
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];

        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
        
        oppty2.Type = 'CARYSTA HVC';
        oppty2.name = 'Carysta Test';
        oppty2.RecordTypeId = carystaRecTypeId;
        oppty2.LeadSource = 'Sales Call';
        oppty2.ZTS_EU_Market__c = 'United States';
        insert oppty2;
        Test.stopTest();        
    }

    @istest
    public static void carystaTest_NO_APs() { 
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];

        List<ZTS_EU_Account_Position__c> aps = [SELECT Id FROM ZTS_EU_Account_Position__c];
        delete aps;

        Test.startTest();
        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
        
        oppty2.Type = 'CARYSTA HVC';
        oppty2.name = 'Carysta Test';
        oppty2.RecordTypeId = carystaRecTypeId;
        oppty2.LeadSource = 'Sales Call';
        oppty2.ZTS_EU_Market__c = 'United States';
        insert oppty2;
        Test.stopTest();        
    }

    @istest
    public static void carystaTest_AreaType() { 
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];

        List<ZTS_EU_Account_Position__c> aps = [SELECT Id FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_EU_Type__c != 'Area'];
        delete aps;

        Test.startTest();
        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
        
        oppty2.Type = 'CARYSTA HVC';
        oppty2.name = 'Carysta Test';
        oppty2.RecordTypeId = carystaRecTypeId;
        oppty2.LeadSource = 'Sales Call';
        oppty2.ZTS_EU_Market__c = 'United States';
        insert oppty2;
        Test.stopTest();        
    }

    @istest
    public static void carystaTest_TerritoryType() { 
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        ZTS_EU_Territory__c ztsTerritoryUS = [SELECT Id,ZTS_EU_Type__c FROM ZTS_EU_Territory__c LIMIT 1];
        ztsTerritoryUS.ZTS_EU_Type__c = 'Territory';
        update ztsTerritoryUS;

        Test.startTest();
        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
        
        oppty2.Type = 'CARYSTA HVC';
        oppty2.name = 'Carysta Test';
        oppty2.RecordTypeId = carystaRecTypeId;
        oppty2.LeadSource = 'Sales Call';
        oppty2.ZTS_EU_Market__c = 'United States';
        insert oppty2;
        Test.stopTest();        
    }

    @istest
    public static void NoncarystaTest_TerritoryType() { 
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        ZTS_EU_Territory__c ztsTerritoryUS = [SELECT Id,ZTS_EU_Type__c FROM ZTS_EU_Territory__c LIMIT 1];
        ztsTerritoryUS.ZTS_EU_Type__c = 'Territory';
        update ztsTerritoryUS;

        Test.startTest();
        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
        
        oppty2.name = 'Non-Carysta Test';
        oppty2.RecordTypeId = carystaRecTypeId;
        oppty2.LeadSource = 'Sales Call';
        oppty2.ZTS_EU_Market__c = 'United States';
        insert oppty2;
        Test.stopTest();        
    }

    @istest
    public static void NoncarystaTest_TerritoryType_SAM() { 
        UserTerritory2Association userTer = [SELECT Id, Territory2Id, UserId  FROM UserTerritory2Association][0]; 
        Account acnt = [SELECT Id FROM Account][0];
        ZTS_EU_Territory__c ztsTerritoryUS = [SELECT Id,ZTS_EU_Type__c FROM ZTS_EU_Territory__c LIMIT 1];
        ztsTerritoryUS.ZTS_EU_Type__c = 'Territory';
        ztsTerritoryUS.ZTS_TerritoryRole__c = 'SAM';
        update ztsTerritoryUS;

        Test.startTest();
        // Get US market
        List<Market__c> markets = [SELECT Id, Name from Market__c];
        Market__c usMarket = CPQ_TestDataFactory.getMarketByName(markets, 'United States');
        
        // Create an opportunity for the account in the US Market        
        Opportunity oppty2 = createOppty(acnt,usMarket,userTer.UserId,false);        
        
        oppty2.name = 'Non-Carysta Test';
        oppty2.RecordTypeId = carystaRecTypeId;
        oppty2.LeadSource = 'Sales Call';
        oppty2.ZTS_EU_Market__c = 'United States';
        insert oppty2;
        Test.stopTest();        
    }
}