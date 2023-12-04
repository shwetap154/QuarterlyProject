/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_SalesCallController_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/15         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_EU_SalesCallController_Test
{   
    
    static List<ZTS_Events__c> listEvents;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static Task tak;
    static List<Call__c> listCalls;
    static List<Address__c> listAddress;
    
    @testSetup
    public static void createTestData(){
        Primary_Contact_Inactive_Profile_List__c newCustomSetting = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting.Name = 'Profile Names';
        newCustomSetting.profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
        insert newCustomSetting;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting2 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting2.Name = 'Profile Names 1';
        newCustomSetting2.profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
        insert newCustomSetting2;
        
        Primary_Contact_Inactive_Profile_List__c newCustomSetting3 = new Primary_Contact_Inactive_Profile_List__c();
        newCustomSetting3.Name = 'Profile Names 2';
        newCustomSetting3.profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';
        insert newCustomSetting3;
        
        //Code change on 6th Oct-17
        User userRecord1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        userRecord1.FirstName = 'David';
        userRecord1.LastName = 'Seliman';
        userRecord1.Email = 'temp@temp.com';
        userRecord1.zts_eu_market__c = 'United Kingdom';
        insert userRecord1;
        
        System.runAs(userRecord1)
        {
            listAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            listAccount[0].ZTS_EU_Market__c = 'United Kingdom';
            insert listAccount;
        }
        
        listAddress = ZTS_EU_DataUtilityTest.createAddressRecord(1);
        for(Address__c a : listAddress){
            a.ZTS_EU_Account__c = listAccount[0].Id;
        }
        
        Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='London',ZTS_EU_Street__c='test street',ZTS_EU_Country__c='United Kingdom',ZTS_EU_State_County__c=listAddress[0].ZTS_EU_State_County__c,Zip_Postal_Code__c ='440013');
        listAddress.add(address);
        insert listAddress;
        System.debug('List Address:' + listAddress);
        Test.startTest();
        
        listCalls = createCalls(listAccount);
        for(Call__c c : listCalls){
            c.ZTS_EU_SelectedAdress__c = 'Test'; 
            c.ZTS_EU_Address__c = listAddress[0].Id; 
            c.ZTS_EU_Call_Owner__c = userRecord1.Id;
        }
        System.runAs(userRecord1)
        {
            insert listCalls;
            
            listContact = ZTS_EU_DataUtilityTest.createContactRecord(2);
            listContact[0].ZTS_EU_Market__c = 'United Kingdom';
            listContact[1].ZTS_EU_Market__c = 'United Kingdom';
            insert listContact;
            //below lines added by Mayukh Deb as part of SC-002827
            
            Attendee__c lstatnd = new Attendee__c(Name='TestAtt1',ZTS_EU_call__c=listCalls[0].id,ZTS_EU_Contact__c=listContact[0].Id);
            Attendee__c att = new Attendee__c(ZTS_EU_Contact__c=listContact[1].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert new List<Attendee__c>{lstatnd, att};
                
                ZTS_EU_Species_Product__c spProd = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Brand',Name='Test',ZTS_EU_Is_Detailable__c=true, ZTS_Hierarchy_Level__c='Brand' );
            ZTS_EU_Species_Product__c spProd1 = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Business Unit',Name='Test');
            insert new List<ZTS_EU_Species_Product__c>{spProd, spProd1};
                Product2 prod = new Product2(ZTS_EU_Market__c='United Kingdom',Name='Test Product',ZTS_EU_Product_Type__c='Brand',isActive=true);
            insert prod;
            ZTS_EU_Species__c sp = new ZTS_EU_Species__c(ZTS_EU_Business_Unit__c=spProd1.Id,ZTS_External_ID__c='Test12',ZTS_EU_Market__c='United Kingdom',ZTS_EU_Species__c='TEst Species');
            insert sp;
            ZTS_EU_Brand_Indication__c brndInd = new ZTS_EU_Brand_Indication__c(ZTS_EU_Product__c=spProd.Id, Market__c='United Kingdom');
            insert brndInd;
            ZTS_EU_Product_Barrier__c prodBar = new ZTS_EU_Product_Barrier__c(ZTS_EU_Brand_Indication__c=brndInd.Id);
            insert prodBar;
            ZTS_EU_Product_Adoption_Profile__c prodAdop = new ZTS_EU_Product_Adoption_Profile__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Contact_Primary_Account__c=listAccount[0].Id,
                                                                                                 ZTS_EU_Brand_Indication__c=brndInd.Id,ZTS_EU_Uniqueness_Key__c='test12',ZTS_EU_Product_Barrier__c=prodBar.Id,ZTS_EU_Usage__c='Advocate');
            insert prodAdop;//ZTS_EU_Competitor_Product__c=compProd.Id,
            
            Campaign camp = new Campaign(Name='TestCamp',isActive=true,StartDate=system.today(),Campaign_Name_English__c='Test');
            insert camp;
            
            CampaignMemberStatus cms = new CampaignMemberStatus();
            cms.CampaignId = camp.id;
            cms.Label = 'test';
            cms.IsDefault = True;
            insert cms;
            
            CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
            insert campMem;
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Market__c='Brand',ZTS_EU_Active__c=true,ZTS_EU_Discussion_Item_Title__c='Test Item', ZTS_EU_Start_Date__c = (system.today() - 1));
            insert discItem;
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c=att.Id,ZTS_EU_Campaign__c=camp.Id,ZTS_EU_Discussion_Items__c=discItem.Id,ZTS_EU_Product__c=spProd.Id);
            ZTS_EU_Discussion__c lstdis = new ZTS_EU_Discussion__c(Name='TestDis1',ZTS_EU_Call_Attendee__c=lstatnd.id);
            insert new List<ZTS_EU_Discussion__c>{disc, lstdis};
                
            tak = new Task(OwnerId=UserInfo.getUserId(),CallDurationInSeconds=10,ActivityDate=system.today(),WhoId=listContact[0].Id,Status='Completed',Subject='Call',Type='Call');
            insert tak;   
            
            ZTS_EU_Competitor_Product__c ComProd = new ZTS_EU_Competitor_Product__c();
            ComProd.Name = 'Test Com';
            ComProd.CurrencyIsoCode ='EUR';
            insert ComProd;

            Competitor_and_BI_Association__c competitorBIAssociation= new Competitor_and_BI_Association__c(ZTS_EU_Brand_Indication__c = brndInd.Id,
                                                                          ZTS_EU_Competitor_Product__c = ComProd.Id );
            insert competitorBIAssociation; 
               
            Test.stopTest();
        }
        
    }
    
    static testMethod void createStandardControllerT(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stoptest();
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.accountChange();
        salesCall.getPreviousCallObjectives();
    }
    
    
    static testMethod void createStandardControllerTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c, ZTS_EU_City__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listAccount = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];

        listAddress = [
            SELECT Id, ZTS_EU_State_County__c,
            ZTS_EU_State_County__r.Name 
            FROM Address__c 
            WHERE ZTS_EU_Country__c = 'United Kingdom'
        ];

        System.assertNotEquals(null, listAddress[0].ZTS_EU_State_County__c);
        //State_Country__c stateC = new State_Country__c(ZTS_EU_Country__c='United Kingdom',ZTS_EU_uniqueCOUNTY__c='UK');
        //insert stateC;
        //Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='London',ZTS_EU_Street__c='test street',ZTS_EU_Country__c='United Kingdom',ZTS_EU_State_County__c=stateC.Id,Zip_Postal_Code__c ='440013');
        //insert address;
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        String profleName = salesCall.userProfileName;
        String cityName = salesCall.City;
        List<SelectOption> addList = salesCall.addressList;
        List<SelectOption> titlList = salesCall.titleList;
        test.stopTest();
    }
    
    static testMethod void createStandardControllerTest2(){
        listAccount = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
        ApexPAges.StandardController sc = new ApexPages.StandardController(call);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
        //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        State_Country__c stateC = new State_Country__c(ZTS_EU_Country__c='United Kingdom',ZTS_EU_uniqueCOUNTY__c='UK');
        insert stateC;
        Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='London',ZTS_EU_Street__c='test street',ZTS_EU_Country__c='United Kingdom',ZTS_EU_State_County__c=stateC.Id,Zip_Postal_Code__c ='440013');
        insert address;
        String profleName = salesCall.userProfileName;
        String cityName = salesCall.City;
        List<SelectOption> addList = salesCall.addressList;
        List<SelectOption> titlList = salesCall.titleList;
    }
    static testMethod void Test(){
      
    }
    /*static testMethod void userProfileNameTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listAccount = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
        //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.accountChange();
        listCalls[0].name = 'Account Call';
        update listCalls;
        ApexPAges.StandardController sc2 = new ApexPages.StandardController(listCalls[0]);
        ZTS_EU_SalesCallController salesCall2 = new ZTS_EU_SalesCallController(sc2);
        List<SelectOption> titlList2 = salesCall2.titleList;
        listCalls[0].name = 'Meeting';
        update listCalls;
        ApexPAges.StandardController sc3 = new ApexPages.StandardController(listCalls[0]);
        ZTS_EU_SalesCallController salesCall3 = new ZTS_EU_SalesCallController(sc3);
        List<SelectOption> titlList3 = salesCall3.titleList;
    }*/
    
    static testMethod void productAdaptationTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
            ZTS_EU_Species_Product__c spProd2 = new ZTS_EU_Species_Product__c(ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='United Kingdom',ZTS_EU_Type__c='Brand',Name='Test');
            insert spProd2;
            
            ZTS_EU_Brand_Indication__c brndInd = new ZTS_EU_Brand_Indication__c(ZTS_EU_Product__c=spProd2.Id, Market__c='United Kingdom');
            insert brndInd;
            ZTS_EU_Product_Barrier__c prodBar = new ZTS_EU_Product_Barrier__c(ZTS_EU_Brand_Indication__c=brndInd.Id);
            insert prodBar;
        
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        
        salesCall.attConID = listContact[0].Id;
        salesCall.productAdaptation();
        salesCall.selIndex = 0;
        salesCall.productAdaptationChange();
        salesCall.addBrandIndication();
    }
    
    static testMethod void cancelBrandIndicationTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        
        salesCall.attConID = listContact[0].Id;
        salesCall.productAdaptation();
        salesCall.selIndex = 0;
        salesCall.cancelBrandIndication();
    }
    
    static testMethod void addNewPAPTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.attConID = listContact[0].Id;
        test.stopTest();
        salesCall.productAdaptation();
        salesCall.selIndex = 0;
        salesCall.addNewPAP();
        
    }
    
    static testMethod void displaySaveTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.attConID = listContact[0].Id;
        salesCall.productAdaptation();
        salesCall.selIndex = 0;
        salesCall.displaySave();
    }
    
    static testMethod void saveCallTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c,ZTS_EU_Call_Objectives__c,ZTS_EU_Additional_Notes__c,ZTS_EU_Next_Step__c,ZTS_EU_Local_Subtype__c,ZTS_EU_Expense_Value__c,
            ZTS_EU_Expense_Type__c,ZTS_EU_Expense_Comments__c,ZTS_EU_Agree_To_Purchase__c,ZTS_EU_Next_Call_Type__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        
        salesCall.productRemoveId = 'Test';
        salesCall.keyMsgRemoveId = 'Test';
        salesCall.sDropRemoveId = 'Test';
        salesCall.aapRemoveId = 'Test';
        salesCall.accid = 'Test';
        salesCall.attConID = listContact[0].Id;
        salesCall.productAdaptation();
        salesCall.selIndex = 0;
        salesCall.saveCall();
        salesCall.getPreviousCallObjectives();
        MarketGeoMapping__c testGeo = new MarketGeoMapping__c(Geo__c = 'CLAR',
                                                              Name = 'United Kingdom');
        insert testGeo;
        salesCall.getIsMarketFromCLAR();
        test.stopTest();
        }
    }
    
    static testMethod void saveCallTest2(){
                User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listAccount = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        Call__c call = new Call__c( ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),
                                    ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), 
                                    ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',ZTS_EU_Next_Call_Date__c=system.today());
        ApexPAges.StandardController sc = new ApexPages.StandardController(call);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.attConID = listContact[0].Id;
        salesCall.productAdaptation();
        salesCall.selIndex = 0;
        salesCall.saveCall();

        }
    }

    static testMethod void saveCallTest3(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            listContact = [
                SELECT Id
                FROM Contact
                WHERE ZTS_EU_Market__c != 'United States'
            ];
            listAccount = [
                SELECT Id
                FROM Account
                WHERE ZTS_EU_Market__c != 'United States'
            ];
            test.startTest();
            Call__c call = new Call__c( ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),
                                        ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), 
                                        ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Completed');
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            test.stopTest();

            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            System.assertNotEquals(null, listContact[0]);
            System.assertEquals('Completed', call.ZTS_EU_Status__c);
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            salesCall.saveCall();
        }
    }

    static testMethod void saveCallTest4(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            listContact = [
                SELECT Id
                FROM Contact
                WHERE ZTS_EU_Market__c != 'United States'
            ];

            List<Account> listAccTest = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            listAccTest[0].ZTS_EU_Market__c = 'United Kingdom';
            insert listAccTest;

            Call__c call = new Call__c(ZTS_EU_Account__c=listAccTest[0].Id,  ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',
                                        ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Submitted_Date__c = System.today(),
                                        ZTS_EU_Status__c='Completed',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today());

            insert call;

            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);

            test.startTest();
            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            System.assertNotEquals(null, listContact[0]);
            System.assertNotEquals(null, call.ZTS_EU_Submitted_Date__c);
            salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            System.assertEquals('Completed', call.ZTS_EU_Status__c);
            salesCall.saveCall();
            test.stopTest();

        }
    }
    
    static testMethod void cancelCallTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.cancelCall();
    }
    
    static testMethod void editCallTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        User standarduser = new User();
        standarduser.FirstName='test';
        standarduser.LastName='standard user';
        standarduser.zts_eu_market__c='United Kingdom';
        standardUser.Email='test@test.com';
        standardUser.ProfileId=[SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        standardUser.EmailEncodingKey = 'UTF-8';
        standardUser.LanguageLocaleKey = 'en_US';
        standardUser.LocaleSidKey = 'en_US';
        standardUser.Username = 'test12122@company12122.example.com';
        standardUser.Alias ='standard';
        standardUser.TimeZoneSidKey='Europe/London';
        insert standarduser;
        listAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1);
        listAccount[0].ZTS_EU_Market__c = 'United Kingdom';
        listAccount[0].OwnerId=standarduser.Id;
        insert listAccount;
        User  userRecord3= [SELECT Id FROM User WHERE Name = 'NGSE Connect INTL' LIMIT 1];
        
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.editCall();
        
        system.runAs(userRecord3){
            
            call__c call = new call__c();
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.Name='Test call';
            call.ZTS_EU_Duration__c = '0.5';
            call.ZTS_EU_Next_Step__c = 'Test next step';
            call.ZTS_EU_Account__c = listAccount[0].Id;
            call.ZTS_EU_Call_Owner__c=listAccount[0].OwnerId;
            call.CreatedById = userRecord3.Id;
            call.LastModifiedById = userRecord3.Id;
            
            insert call;
            
        }
       system.runAs(standarduser){
            
            Call__c insertedCall = [SELECT ZTS_EU_Call_Owner__c FROM Call__c WHERE CreatedById = :userRecord3.Id];
            system.assertEquals(salesCall.callEditForUser, true);
            
        }
    }
    
    
    static testMethod void updateCallDetailsTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        System.debug('listCalls[0]------>'+listCalls[0]);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        
        List<ZTS_EU_SalesCallController.attendeerWrapper > wrapList = createAttendeeWrapList(1);
        salesCall.colleagueWraList = wrapList;
        salesCall.attendeeWraList = wrapList;
        Campaign camp = new Campaign(Name='TestCamp',isActive=true,StartDate=system.today(),Campaign_Name_English__c='Test');
        insert camp;
        System.debug('listContact------>'+listContact);
        CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
        insert campMem;
        System.debug('campMem------>'+campMem);
        salesCall.campaignMemberList = new List<CampaignMember>{campMem};
            salesCall.updateCallDetails();
        test.stopTest();
        
        //Sayan added some lines to cover the getter variables
        ZTS_EU_SalesCallController.attendeerWrapper ob = new ZTS_EU_SalesCallController.attendeerWrapper();
        ob.empAcctPos = new List<SelectOption>();
        ob.empAcctPos = ob.empAcctPos;
        ob.relCamRespOption = new List<SelectOption>();
        ob.relCamRespOption = ob.relCamRespOption;
        ob.selectedAttendee = 'New Attendee';
        salesCall.productList = new List<Product_Metrics__c>();
        salesCall.surveyalertmessage = 'New Survey';
        salesCall.accposlist = new List<ZTS_EU_Account_Position__c>();
        salesCall.forceid = 'New ForceId';
        salesCall.EUdiscuss = new List<ZTS_EU_Discussion__c>();
        salesCall.EUFinaldiscuss = new List<ZTS_EU_Discussion__c>();
        salesCall.call = [SELECT Id,Name FROM Call__c][0];
        salesCall.call.Name = 'Account Call';
        salesCall.titleList = new List<SelectOption>();
        salesCall.titleList = salesCall.titleList;
        salesCall.call.Name = 'Meeting';
        salesCall.titleList = new List<SelectOption>();
        salesCall.titleList = salesCall.titleList;
        //Sayan End
    } 
    
    static List<ZTS_EU_SalesCallController.attendeerWrapper> createAttendeeWrapList(Integer num){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        List<ZTS_EU_SalesCallController.attendeerWrapper > wrapList;
        System.runAs(usr)
        {
            listCalls = [
                SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
                ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
                ZTS_EU_Next_Call_Date__c
                FROM Call__c
                WHERE ZTS_EU_Market__c != 'United States'
            ];
            listContact = [
                SELECT Id
                FROM Contact
                WHERE ZTS_EU_Market__c != 'United States'
            ];
            listAccount = [
                SELECT Id
                FROM Account
                WHERE ZTS_EU_Market__c != 'United States'
            ];
            //
            Attendee__c att = new Attendee__c();
            List<Attendee__c> attnList  = new List<Attendee__c>([SELECT Id,ZTS_EU_call__c,ZTS_EU_Contact__c,ZTS_EU_Employee__c,ZTS_EU_Represents_Account__c,ZTS_EU_External_ID__c,ZTS_EU_Uniqueness_Key__c,ZTS_EU_Related_Campaign__c FROM Attendee__c WHERE ZTS_EU_call__c=:listCalls[0].Id AND ZTS_EU_Contact__c =: listContact[0].Id]);
            if(attnList.size()>0){
                att = attnList[0];
            }
            else{
                att = new Attendee__c(ZTS_EU_call__c= listCalls[0].id,ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Employee__c=UserInfo.getUserId(),
                                               ZTS_EU_Represents_Account__c=listAccount[0].Id,ZTS_EU_External_ID__c='testExt'+num,ZTS_EU_Uniqueness_Key__c='testKey'+num);
                insert att;
                
            }
            
            ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_Account_influence__c='High',ZTS_EU_Affiliation_Status__c='Active',
                                                                    ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Commitment_Level__c='Supporter',ZTS_EU_Job_Function__c='Lead Technician',ZTS_EU_Profession__c='Consultant');
            insert aff;
            ZTS_EU_Colleague__c coll = new ZTS_EU_Colleague__c(ZTS_EU_Call__c=listCalls[0].Id,ZTS_EU_User__c=UserInfo.getUserId(),ZTS_EU_Automatic_ECC_creation__c='To be Created');
            insert coll;
            
            ZTS_EU_SalesCallController.attendeerWrapper attWrapList = new ZTS_EU_SalesCallController.attendeerWrapper();
            attWrapList.attendeeObj = att;
            attWrapList.aConAff = aff;
            attWrapList.selectedAcctPos = listAccount[0].Id;
            attWrapList.colleagueobj = coll;
            List<SelectOption> newSP = new List<SelectOption>();
            attWrapList.empAcctPos = newSP;
            attWrapList.relCamRespOption = newSP;
            wrapList = new List<ZTS_EU_SalesCallController.attendeerWrapper >{attWrapList};
        }
        return wrapList;
    }
    
    static testMethod void saveAndSubmitTest(){
                User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listAccount = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        Attendee__c attn = new Attendee__c(ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Employee__c=UserInfo.getUserId(),
                                            ZTS_EU_External_ID__c='test123', ZTS_EU_Represents_Account__c=listAccount[0].Id);        
        salesCall.saveAndSubmit();
        test.stopTest();
        }
    }
    
    static testMethod void showAttendee(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listContact = [
            SELECT Id
            FROM Contact
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(2);
        Campaign camp = new Campaign(Name='TestCamp',isActive=true,StartDate=system.today(),Campaign_Name_English__c='Test');
        insert camp;
        CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
        insert campMem;
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.CampaignId = camp.id;
        cms.Label = 'test';
        cms.IsDefault = True;
        insert cms;
        salesCall.showAttendee();
        test.stopTest();
        
    } 
    
    static testMethod void removeAttendeeTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        
        Test.setCurrentPage(massAddAccPage);
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        test.startTest();
        
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        //generateData();
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(3);
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        test.stoptest();
        
        salesCall.attendeeRemoveId = wrapList[0].attendeeObj.Id;
        salesCall.removeAttendee();
        
    }
    
    
    static testMethod void removeColleagueTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(5);
        salesCall.colleagueRemoveId = wrapList[0].colleagueobj.Id;
        salesCall.removeColleague();
        test.stopTest();
        
    } 
    
    static testMethod void removeDiscussionItemTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.startTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);       
        List<ZTS_EU_SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(4);
        //salesCall.discRemoveId = wrapList[0].colleagueobj.Id;
        salesCall.removeDiscussionItem();
        test.stopTest();
        
    } 
    
    static testMethod void deleteCallTest(){
                User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.deleteCall();
    }
    }
    
    static testMethod void showFollowUpActivitiesTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        listAccount = [
            SELECT Id
            FROM Account
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.showFollowUpActivities();
    }
    
    static testMethod void removeFollowUpActivitiesTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        tak = [
            SELECT Id
            FROM Task
            LIMIT 1
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);        
        salesCall.followUpActivityRemoveId = tak.Id;
        salesCall.removeFollowUpActivities();
    }
    
    static testMethod void calculateEndDateTimeTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCAll.calculateEndDateTime();
    }
    
    static testMethod void saveTaskTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.saveTask();
    }
    
    static testMethod void addSectionToTaskTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.addSectionToTask();
    }
    
    static testMethod void showDiscussionAFTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.showDiscussionAF();
    }
    
    static testMethod void hideDiscussionAFTest(){
        listCalls = [
            SELECT Id, ZTS_EU_SelectedAdress__c, ZTS_EU_Address__c, ZTS_EU_Call_Owner__c, ZTS_EU_Account__c,
            ZTS_EU_Start_Date_Time__c, ZTS_EU_Duration__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Sub_Type__c, ZTS_EU_Status__c, Name,
            ZTS_EU_Next_Call_Date__c
            FROM Call__c
            WHERE ZTS_EU_Market__c != 'United States'
        ];
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
        Test.setCurrentPage(massAddAccPage);
        test.stopTest();
        
        ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
        salesCall.hideDiscussionAF();
    }
    
    /*-------------insert ZTS_Events__c objects---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ // 6/14
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            event.Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.now();
            event.ZTS_US_Is_Event_Private__c = false;
            event.ZTS_US_Name__c = 'Test Event'+i;
            event.ZTS_US_End_Date__c = system.today().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
           // event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';//Pooja - Added new rich text field insted old text field "ZTS_US_Purpose_Agenda__c"
            listEvents1.add(event);
        }
        return listEvents1;
    }
    /*-------insert Call__c object records */
    public static List<Call__c> createCalls(List<Account> listAcct){
        
        
        List<Call__c> listCall = new List<Call__c>();
        for(Account acc: listAcct){
            Call__c call = new Call__c(ZTS_EU_Account__c=acc.Id,  ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2),
                                       ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned',Name='Account Call',ZTS_EU_Next_Call_Date__c=system.today(),ZTS_EU_Next_Call_Type__c='Training');
            listCall.add(call);
        }
        System.debug('listCall ------->'+listCall);
        return listCall;
    }

    static testMethod void redirectEditCloneNew_test(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr)
        {
            // listContact = [
            //     SELECT Id
            //     FROM Contact
            //     WHERE ZTS_EU_Market__c != 'United States'
            // ];
            Account acc = new Account();         
            acc.name = 'Test Account 13';
            acc.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc.ZTS_EU_Country__c = 'United States';
            acc.ZTS_EU_Market__c = 'United States';
            acc.BillingCity = 'Test City 12';
            acc.ZTS_US_State_Province__c  = 'Ohio';
            acc.BillingStreet = 'Test Street 11';  
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            acc.BillingPostalCode = '12345';
            acc.BillingState = 'Florida';
            acc.ZTS_US_NARC_ID__c='NC13546843';
            acc.ZTS_US_LE_Account__c = true;

            insert acc;

            List <Account> accList =  [SELECT Id, ZTS_US_NARC_ID__c, ZTS_EU_Market__c 
                                                FROM Account
                                                WHERE ZTS_US_NARC_ID__c = 'NC13546843' LIMIT 1];
            System.assertEquals('United States', accList[0].ZTS_EU_Market__c);
            test.startTest();
            Call__c call = new Call__c( ZTS_EU_Account__c= accList[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),
                                        ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), 
                                        ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned', ZTS_EU_Submitted_Date__c = System.today());
            insert call;
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ZTS_EU_ViewSalesCallDetails;
            Test.setCurrentPage(massAddAccPage);
            test.stopTest();

            ZTS_EU_SalesCallController salesCall = new ZTS_EU_SalesCallController(sc);
            //System.assertNotEquals(null, listContact[0]);
            System.assertNotEquals(null, call.ZTS_EU_Submitted_Date__c);
            //salesCall.attConID = listContact[0].Id;
            salesCall.productAdaptation();
            salesCall.selIndex = 0;
            //System.assertEquals('United States', call.ZTS_EU_Account__r.ZTS_EU_Market__c);
            System.currentPageReference().getParameters().put('id', call.Id);
            salesCall.redirectEditCloneNew();
            salesCall.redirect();
        }
    }
    
}