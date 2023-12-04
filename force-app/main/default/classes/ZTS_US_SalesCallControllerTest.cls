/*******************************************************************************************************************************************
* File Name     :  ZTS_US_SalesCallControllerTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/15         Vidya             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_SalesCallControllerTest 
{   
    
    static List<ZTS_Events__c> listEvents;
    static List<Account> listAccount;
    static List<Contact> listContact;
    static Task tak;
    static List<Call__c> listCalls;
    static List<ZTS_EU_Discussion__c> discList;
    static ZTS_EU_Colleague__c coll;
    static Attendee__c att;
    
    public static void createTestData(Integer narcVal){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            listAccount = ZTS_DataUtilityTest.createAccountRecord(1, narcVal);
            insert listAccount;
            /*listAccount[0].BillingCountry = 'a';
            listAccount[0].BillingCity = 'd';
            listAccount[0].BillingState = 'c';
            listAccount[0].BillingStreet = 'v';*/
            listAccount[0].ZTS_EU_Market__c = 'United States';
            update listAccount;
            listCalls = createCalls(listAccount);
            try{
                insert listCalls;
            }
            catch(Exception e){
                System.debug('excetion error : '+e);
            }
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            listContact = ZTS_DataUtilityTest.createContactRecord(1);
            listContact[0].ZTS_EU_Market__c = 'United States';
            insert listContact;
            
            //ZTS_DataUtilityTest.activateTriggerSettings();
            
            List<ZTS_EU_Territory__c> customterrList=ZTS_DataUtilityTest.createCustomTerritory(1);
            insert customterrList;
            customterrList[0].ZTS_FieldForce_ID__c = 'testName';
            update customterrList;
            
            List<ZTS_EU_Position__c> userterrlist= ZTS_DataUtilityTest.createUserTerritory(customterrList);
            insert userterrlist;
            ZTS_US_Call_CS__c callCS = new ZTS_US_Call_CS__c(Name='testName', ZTS_US_Sub_Type_Value__c='Account,SampleDrop',ZTS_US_Sub_Type_Value_2__c='Test Sample Drop');
            insert callCS;
            
            List<ZTS_AccountTerritory__c> accterr=ZTS_DataUtilityTest.createAccountTerritory(listAccount, customterrList);
            insert accterr;
            ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_NotificationUser__c=UserInfo.getUserId(),ZTS_Alignment_Date__c=system.today(),ZTS_AccountTerritory__c=accterr[0].Id);
        }
    }
    
    static testMethod void createStandardControllerT(){
        test.startTest();
        createTestData(153);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        
        
        salesCall.accountChange();
        test.stoptest();
    }
    
    
    static testMethod void createStandardControllerTest(){
        test.startTest();
        createTestData(154);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
        //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
        State_Country__c sc1 = new State_Country__c();         
        sc1.name = 'County';
        sc1.ZTS_EU_Country__c = 'United States';
        insert sc1;
        SalesCallController salesCall = new SalesCallController(sc);
        Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New York',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
        insert address;
        //String profleName = salesCall.userProfileName;
        //String cityName = salesCall.City;
        //List<SelectOption> addList = salesCall.addressList;
        //List<SelectOption> titlList = salesCall.titleList;
        test.stopTest();
    }
    
    static testMethod void createStandardControllerTest2(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            //createTestData(155);
            /*Contact con = new Contact(); 
con.firstname='Test First';
con.lastname = 'Test Contact'; 
con.ZTS_EU_Profession__c='Executive Leadership';
con.ZTS_Job_Function__c='CEO/President';
con.ZTS_EU_Market__c = 'United Kingdom';
insert con;*/
            //generateData();
            listAccount = ZTS_DataUtilityTest.createAccountRecord(1, 1);
            insert listAccount;
            listAccount[0].ZTS_EU_Market__c = 'United States';
            update listAccount;
            List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            Product_Metrics__c p = new Product_Metrics__c();
            p.Name = 'test';
            p.ZTS_EU_Call__c = call.Id;
            pmList.add(p);
            insert pmList;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            
            ApexPages.currentPage().getParameters().put('removediscussionItm', 'false');
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.productRemoveId = p.Id;
            salesCall.keyMsgRemoveId = 'test';
            //salesCall.discRemoveId = discList[0].Id;
            salesCall.productList = pmList;
            salesCall.accid = 'test';
            salesCall.forceid = 'test';
            //salesCall.attendeeRemoveId = att.Id;
            salesCall.attendeeRemoveFlag = false;
            salesCall.removeAttendee();
            salesCall.removeDiscussionItem();
            salesCall.removeProduct();
            salesCall.getPreviousCallObjectives();
            salesCall.accountChange();
            salesCall.removeColleague();
            
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            insert sc1;
            
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New Yok',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address;
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest2AtendeeException(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(155);
            test.startTest();
            generateData();
            List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            Product_Metrics__c p = new Product_Metrics__c();
            p.Name = 'test';
            p.ZTS_EU_Call__c = call.Id;
            pmList.add(p);
            insert pmList;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            
            ApexPages.currentPage().getParameters().put('removediscussionItm', 'false');
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.productRemoveId = p.Id;
            salesCall.keyMsgRemoveId = 'test';
            salesCall.discRemoveId = discList[0].Id;
            salesCall.productList = pmList;
            salesCall.accid = 'test';
            salesCall.forceid = 'test';
            salesCall.attendeeRemoveId = att.Id;
            salesCall.attendeeRemoveFlag = false;
            delete att;
            salesCall.removeAttendee();
            salesCall.removeDiscussionItem();
            salesCall.removeProduct();
            salesCall.getPreviousCallObjectives();
            salesCall.accountChange();
            salesCall.removeColleague();
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            insert sc1;
            
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New Yok',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address;
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest2AtendeeRemoveFlag(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(155);
            test.startTest();
            generateData();
            List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            Product_Metrics__c p = new Product_Metrics__c();
            p.Name = 'test';
            p.ZTS_EU_Call__c = call.Id;
            pmList.add(p);
            insert pmList;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            
            ApexPages.currentPage().getParameters().put('removediscussionItm', 'false');
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.productRemoveId = p.Id;
            salesCall.keyMsgRemoveId = 'test';
            salesCall.discRemoveId = discList[0].Id;
            salesCall.productList = pmList;
            salesCall.accid = 'test';
            salesCall.forceid = 'test';
            salesCall.attendeeRemoveId = att.Id;
            salesCall.attendeeRemoveFlag = true;
            salesCall.selectedop = '---NONE---';
            delete att;
            salesCall.removeAttendee();
            salesCall.removeDiscussionItem();
            salesCall.removeProduct();
            salesCall.getPreviousCallObjectives();
            salesCall.accountChange();
            salesCall.removeColleague();
            
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            insert sc1;
            
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New Yok',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address;
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest2Exception(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            //createTestData(155);
            //generateData();
            listAccount = ZTS_DataUtilityTest.createAccountRecord(1, 1);
            insert listAccount;
            listAccount[0].ZTS_EU_Market__c = 'United States';
            update listAccount;
            List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            Product_Metrics__c p = new Product_Metrics__c();
            p.Name = 'test';
            p.ZTS_EU_Call__c = call.Id;
            pmList.add(p);
            insert pmList;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
        
        ApexPages.currentPage().getParameters().put('removediscussionItm', 'false');
        SalesCallController salesCall = new SalesCallController(sc);
        salesCall.productRemoveId = p.Id;
        salesCall.keyMsgRemoveId = 'test';
        //salesCall.discRemoveId = discList[0].Id;
        salesCall.productList = pmList;
        salesCall.accid = 'test';
        salesCall.forceid = 'test';
        salesCall.removeAttendee();
        salesCall.removeDiscussionItem();
        delete pmList;
        salesCall.removeProduct();
        salesCall.getPreviousCallObjectives();
        salesCall.accountChange();
        salesCall.removeColleague();
        
        State_Country__c sc1 = new State_Country__c();         
        sc1.name = 'County';
        sc1.ZTS_EU_Country__c = 'United States';
        insert sc1;
        
        Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New Yok',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
        insert address;
        //String profleName = salesCall.userProfileName;
        //String cityName = salesCall.City;
        //List<SelectOption> addList = salesCall.addressList;
        //List<SelectOption> titlList = salesCall.titleList;
        test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest2DiscussionRemoveException(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(1); 
            test.startTest();
            generateData();
            List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            Product_Metrics__c p = new Product_Metrics__c();
            p.Name = 'test';
            p.ZTS_EU_Call__c = call.id;
            pmList.add(p);
            insert pmList;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            
            ApexPages.currentPage().getParameters().put('removediscussionItm', 'false');
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.productRemoveId = p.Id;
            salesCall.keyMsgRemoveId = 'test';
            salesCall.discRemoveId = discList[0].Id;
            salesCall.productList = pmList;
            salesCall.accid = 'test';
            salesCall.forceid = 'test';
            salesCall.removeAttendee();
            delete discList;
            salesCall.removeDiscussionItem();
            delete pmList;
            salesCall.removeProduct();
            salesCall.getPreviousCallObjectives();
            salesCall.accountChange();
            salesCall.removeColleague();
            
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            insert sc1;
            
            Address__c address2 = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New Yok',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address2;
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest2evt4(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            //createTestData(155);
            //generateData();
            listAccount = ZTS_DataUtilityTest.createAccountRecord(1, 1);
            insert listAccount;
            listAccount[0].ZTS_EU_Market__c = 'United States';
            update listAccount;
            List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            Product_Metrics__c p = new Product_Metrics__c();
            p.Name = 'test';
            p.ZTS_EU_Call__c = call.Id;
            pmList.add(p);
            insert pmList;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            ApexPages.currentPage().getParameters().put('evt4', String.valueOf(Date.newInstance(2014,07,10)));
            
            ApexPages.currentPage().getParameters().put('removediscussionItm', 'true');
            SalesCallController salesCall = new SalesCallController(sc);
            
            salesCall.productRemoveId = p.Id;
            salesCall.keyMsgRemoveId = 'test';
            //salesCall.discRemoveId = discList[0].Id;
            salesCall.productList = pmList;
            salesCall.accid = 'test';
            salesCall.forceid = 'test';
            salesCall.removeAttendee();
            salesCall.removeDiscussionItem();
            salesCall.removeProduct();
            salesCall.getPreviousCallObjectives();
            salesCall.accountChange();
            
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            insert sc1;
            
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New Yok',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address;
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    //added by laxmikanth to cover populate sub class method
    static testMethod void userProfileNameTest(){
        test.startTest();
        createTestData(156);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
        //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
        
        SalesCallController salesCall = new SalesCallController(sc);
        salesCall.accountChange();
        test.stopTest();
    }
    
    
    static testMethod void removeSampleDropTest(){
        createTestData(157);
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        generateData();
        
        set<string> objNames = new set<String>();
        objNames.add('Account');
        objNames.add('ZTS_EU_Species_Product__c');
        list<recordtype> recordtypesLst = new list<recordtype>();
        recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
        
        map<string, string> recordtypeMap = new map<string, string>();
        
        for(Recordtype r : recordtypesLst){
            string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
            recordtypeMap.put(objName_DeveloperName, r.id);
            system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
        }
        
        ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
        tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
        insert tgRecord;
        
        ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
        brandRecord = createProdHierarchyRecord('Ph 2','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
        insert brandRecord;
        ZTS_US_Sample__c sample = new ZTS_US_Sample__c( ZTS_US_Position__c='abc',ZTS_US_Ship_Date__c=system.today(),ZTS_US_Start_Quantity__c=5, ZTS_US_Product__c=brandRecord.Id);
        insert sample;
        ZTS_US_Sample_Drop__c s = new ZTS_US_Sample_Drop__c(ZTS_US_Account__c=listAccount[0].Id,ZTS_US_Call__c=listCalls[0].Id,ZTS_US_Sample__c=sample.Id,ZTS_US_Sample_Drop_Type__c='Sample Drop');
        insert s;
        salesCall.showSampleDrop();
        salesCall.sDropRemoveId = s.Id;
        
        salesCall.removeSampleDrop();
        test.stopTest();
    }
    
    static testMethod void removeSampleDropTestException(){
        createTestData(157);
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        generateData();
        
        set<string> objNames = new set<String>();
        objNames.add('Account');
        objNames.add('ZTS_EU_Species_Product__c');
        list<recordtype> recordtypesLst = new list<recordtype>();
        recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
        
        map<string, string> recordtypeMap = new map<string, string>();
        
        for(Recordtype r : recordtypesLst){
            string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
            recordtypeMap.put(objName_DeveloperName, r.id);
            system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
        }
        
        ZTS_EU_Species_Product__c tgRecord = new ZTS_EU_Species_Product__c();
        tgRecord = TestUtilities.createNoInsertBrand('Ph 1','Therapeutic Group','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Therapeutic_Group'));
        insert tgRecord;
        
        ZTS_EU_Species_Product__c brandRecord = new ZTS_EU_Species_Product__c();
        brandRecord = createProdHierarchyRecord('Ph 2','Brand','Canada',recordtypeMap.get('ZTS_EU_Species_Product__c-Brand'),tgRecord.id);
        insert brandRecord;
        ZTS_US_Sample__c sample = new ZTS_US_Sample__c( ZTS_US_Position__c='abc',ZTS_US_Ship_Date__c=system.today(),ZTS_US_Start_Quantity__c=5, ZTS_US_Product__c=brandRecord.Id);
        insert sample;
        
        ZTS_US_Sample_Drop__c s = new ZTS_US_Sample_Drop__c(ZTS_US_Account__c=listAccount[0].Id,ZTS_US_Call__c=listCalls[0].Id,ZTS_US_Sample__c=sample.Id,ZTS_US_Sample_Drop_Type__c='Sample Drop');
        insert s;
        salesCall.sDropRemoveId = s.Id;
        delete s;
        salesCall.removeSampleDrop();
        test.stopTest();
    }
    
    static testMethod void saveCallTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(157);
            test.startTest();
            for(Account a : listAccount){
                a.BillingCountry = 'India';
                a.BillingCity = 'TestCity';
                a.BillingState = 'West Bengal';
                a.BillingStreet = 'TestStreet';
            }
            
            update listAccount;
            listCalls[0].ZTS_EU_Account__c = listAccount[0].Id;
            
            update listCalls;
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            
            generateData();
            //salesCall.attConID = listContact[0].Id;
            //salesCall.productAdaptation();
            //salesCall.selIndex = 0;
            salesCall.saveCall();
            test.stopTest();
        }
    }
    
    
    
    static testMethod void saveCallTest2(){
        test.startTest();
        createTestData(158);
        Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
        ApexPAges.StandardController sc = new ApexPages.StandardController(call);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        
        generateData();
        /*salesCall.attConID = listContact[0].Id;
        salesCall.productAdaptation();
        salesCall.selIndex = 0;*/
        salesCall.saveCall();
        test.stopTest();
    }
    
    static testMethod void cancelCallTest(){
        test.startTest();
        createTestData(159);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        salesCall.cancelCall();
        test.stopTest();
    }
    
    static testMethod void editCallTest(){
        test.startTest();
        createTestData(160);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        salesCall.editCall();
        test.stopTest();
    }
    
    static testMethod void updateCallDetailsTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(1);
            Attendee__c att = new Attendee__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert att;
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Discussion_Item_Title__c='Test Item',ZTS_EU_Start_Date__c=system.today().addDays(-2));
            insert discItem;
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c = att.Id,ZTS_EU_Discussion_Items__c = discItem.Id);
            insert disc;
            test.startTest();
            listCalls[0].ZTS_EU_Status__c = 'Submitted';
            update listCalls;
            
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            
            List<SalesCallController.attendeerWrapper > wrapList = createAttendeeWrapList(1);
            salesCall.colleagueWraList = wrapList;
            salesCall.attendeeWraList = wrapList;
            Campaign camp = new Campaign(Name='TestCamp',isActive=true,StartDate=system.today());
            camp.Campaign_Name_English__c = 'English';
            insert camp;
            CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
            insert campMem;
            salesCall.campaignMemberList = new List<CampaignMember>{campMem};
            salesCall.updateCallDetails();
            test.stopTest();
        }
    }
    
    static List<SalesCallController.attendeerWrapper> createAttendeeWrapList(Integer num){
        createTestData(162);
        Attendee__c attn = new Attendee__c(ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Employee__c=UserInfo.getUserId(),
        ZTS_EU_Represents_Account__c=listAccount[0].Id,PIT_External_ID__c='testExt'+num);
        insert attn;
        ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_Account_influence__c='High',ZTS_EU_Affiliation_Status__c='Active', 
        ZTS_EU_Contact__c=listContact[0].Id,ZTS_US_Job_Function__c='Lead Technician',ZTS_US_Profession__c='Consultant');
        insert aff;
        coll = new ZTS_EU_Colleague__c(ZTS_EU_Call__c=listCalls[0].Id,ZTS_EU_User__c=UserInfo.getUserId());
        insert coll;
        SalesCallController.attendeerWrapper attWrapList = new SalesCallController.attendeerWrapper();
        attWrapList.attendeeObj = attn;
        attWrapList.aConAff = aff;
        //attWrapList.selectedAcctPos = listAccount[0].Id;
        attWrapList.colleagueobj = coll;
        List<SalesCallController.attendeerWrapper > wrapList = new List<SalesCallController.attendeerWrapper >{attWrapList};
        return wrapList;
    }
    
    static testMethod void saveAndSubmitTest(){
        createTestData(163);
        test.startTest();
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        Attendee__c attn = new Attendee__c(ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_Employee__c=UserInfo.getUserId(),PIT_External_ID__c='test123',
        ZTS_EU_Represents_Account__c=listAccount[0].Id);
        generateData();
        salesCall.isSubmit = true;
        salesCall.flag = false;
        salesCall.saveAndSubmit();
        test.stopTest();
    }
    
    static testMethod void showAttendee(){     
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {  
            createTestData(1);
            Attendee__c att = new Attendee__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert att;
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Discussion_Item_Title__c='Test Item',ZTS_EU_Start_Date__c=system.today().addDays(-2));
            insert discItem;
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c = att.Id,ZTS_EU_Discussion_Items__c = discItem.Id);
            insert disc;
            test.startTest();
            listCalls[0].ZTS_EU_Status__c = 'Submitted';
            update listCalls;
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            generateData();
            List<SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(2);
            //Campaign camp = new Campaign(Name='TestCamp',isActive=true,StartDate=system.today());
            //insert camp;
            //CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
            //insert campMem;
            //salesCall.showAttendee();
            test.stopTest();
        }
    }
    
    static testMethod void removeAttendeeTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(165);
            Attendee__c att = new Attendee__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert att;
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Discussion_Item_Title__c='Test Item',ZTS_EU_Start_Date__c=system.today().addDays(-2));
            insert discItem;
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c = att.Id,ZTS_EU_Discussion_Items__c = discItem.Id);
            insert disc;
            test.startTest();
            listCalls[0].ZTS_EU_Status__c = 'Submitted';
            update listCalls;
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            generateData();
            List<SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(3);
            salesCall.attendeeRemoveId = wrapList[0].attendeeObj.Id;
            //salesCall.removeAttendee();
            test.stopTest();
        }
    }
    
    static testMethod void removeColleagueTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(166);
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            List<SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(5);
            salesCall.colleagueRemoveId = wrapList[0].colleagueobj.Id;
            salesCall.removeColleague();
            test.stopTest();
        }
    }
    
    static testMethod void removeColleagueTestException(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(1);
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            List<SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(5);
            salesCall.colleagueRemoveId = wrapList[0].colleagueobj.Id;
            delete coll;
            salesCall.removeColleague();
            test.stopTest();
        }
    }
    
    static testMethod void removeDiscussionItemTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(167);
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            generateData();
            List<SalesCallController.attendeerWrapper> wrapList = createAttendeeWrapList(4);
            //salesCall.discRemoveId = wrapList[0].colleagueobj.Id;
            salesCall.discRemoveId = [select id from ZTS_EU_Discussion__c WHERE ZTS_EU_Market__c = 'United States' limit 1 ].Id;
            ApexPages.currentPage().getParameters().put('removediscussionItm',salesCall.discRemoveId);         
            //salesCall.removeDiscussionItem();
            test.stopTest();
        }
    }
    
    
    
    static testMethod void deleteCallTest(){
        test.startTest();
        createTestData(168);
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
        PageReference massAddAccPage = Page.ViewSalesCall;
        Test.setCurrentPage(massAddAccPage);
        SalesCallController salesCall = new SalesCallController(sc);
        salesCall.deleteCall();
        test.stopTest();
    }
    
    static testMethod void deleteCallTestException(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(168);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            delete listCalls; 
            salesCall.deleteCall();
            test.stopTest();
        }
    }
    
    static testMethod void showFollowUpActivitiesTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(169);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.showFollowUpActivities();
            test.stopTest();
        }
    }
    
    static testMethod void removeFollowUpActivitiesTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(170);
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            generateData();
            salesCall.followUpActivityRemoveId = tak.Id;
            salesCall.removeFollowUpActivities();
            test.stopTest();
        }
    }
    
    static testMethod void removeFollowUpActivitiesTestException(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(170);
            test.startTest();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            generateData();
            salesCall.followUpActivityRemoveId = tak.Id;
            delete tak;
            salesCall.removeFollowUpActivities();
            test.stopTest();
        }
    }
    
    static testMethod void calculateEndDateTimeTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(171);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            salesCAll.calculateEndDateTime(listCalls[0]);
            test.stopTest();
        }
    }
    
    static testMethod void saveTaskTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            createTestData(172);
            test.startTest();
            generateData();
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.taskObj = tak;
            salesCall.saveTask();
            test.stopTest();
        }
    }
    
    
    
    static testMethod void addSectionToTaskTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(173);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.addSectionToTask();
            test.stopTest();
        }
    }
    
    static testMethod void showDiscussionAFTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(174);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.showDiscussionAF();
            test.stopTest();
        }
    }
    
    static testMethod void hideDiscussionAFTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData(175);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listCalls[0]);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            SalesCallController salesCall = new SalesCallController(sc);
            salesCall.hideDiscussionAF();
            test.stopTest();
        }
    }
    
    
    
    static void generateData(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            att = new Attendee__c(ZTS_EU_Contact__c=listContact[0].Id,ZTS_EU_call__c=listCalls[0].Id,ZTS_EU_Represents_Account__c=listAccount[0].Id);
            insert att;
            /*ZTS_US_Species_Product__c spProd = new ZTS_US_Species_Product__c(ZTS_US_Is_Active__c=true,ZTS_US_Market__c='United Kingdom',ZTS_EU_Type__c='Brand',Name='Test',ZTS_US_Is_Detailable__c=true);
            insert spProd;
            ZTS_US_Species_Product__c spProd1 = new ZTS_US_Species_Product__c(ZTS_US_Is_Active__c=true,ZTS_US_Market__c='United Kingdom',ZTS_EU_Type__c='Business Unit',Name='Test');
            insert spProd1;
            Product2 prod = new Product2(ZTS_US_Market__c='United Kingdom',Name='Test Product',ZTS_US_Product_Type__c='Brand',isActive=true);
            insert prod;
            /*ZTS_Species__c sp = new ZTS_Species__c(ZTS_US_Business_Unit__c=spProd1.Id,ZTS_External_ID__c='Test12',ZTS_US_Market__c='United Kingdom',ZTS_Species__c='TEst Species');
            insert sp;
            ZTS_US_Brand_Indication__c brndInd = new ZTS_US_Brand_Indication__c(ZTS_US_Product__c=spProd.Id, Market__c='United Kingdom',ZTS_US_Applicable_to_Species__c=sp.Id);
            insert brndInd;
            ZTS_US_Product_Barrier__c prodBar = new ZTS_US_Product_Barrier__c(ZTS_US_Brand_Indication__c=brndInd.Id);
            insert prodBar;
            ZTS_US_Product_Adoption_Profile__c prodAdop = new ZTS_US_Product_Adoption_Profile__c(ZTS_US_Contact__c=listContact[0].Id,ZTS_US_Contact_Primary_Account__c=listAccount[0].Id,
            ZTS_US_Brand_Indication__c=brndInd.Id,ZTS_US_Uniqueness_Key__c='test12',ZTS_US_Product_Barrier__c=prodBar.Id,ZTS_US_Usage__c='High');
            insert prodAdop;//ZTS_US_Competitor_Product__c=compProd.Id,*/
            State_Country__c sc1 = new State_Country__c();         
            sc1.name = 'County';
            sc1.ZTS_EU_Country__c = 'United States';
            insert sc1;
            
            Address__c address = new Address__c(ZTS_EU_Account__c=listAccount[0].Id,ZTS_EU_City__c='New York',ZTS_US_Street__c='test street',ZTS_EU_Country__c='United States',Zip_Postal_Code__c ='440013', ZTS_EU_State_County__c = sc1.Id);
            insert address;
            Campaign camp = new Campaign(Name='TestCamp',isActive=true,StartDate=system.today());
            camp.Campaign_Name_English__c = 'English';
            insert camp;
            CampaignMember campMem = new CampaignMember(CampaignId=camp.Id,ContactId=listContact[0].Id);
            insert campMem;
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c(ZTS_EU_Discussion_Item_Title__c='Test Item',ZTS_EU_Start_Date__c=system.today().addDays(-2));
            insert discItem;
            discList = new List<ZTS_EU_Discussion__c>();
            ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c=att.Id,ZTS_EU_Campaign__c=camp.Id);
            discList.add(disc);
            disc = new ZTS_EU_Discussion__c(ZTS_EU_Call_Attendee__c=att.Id,ZTS_EU_Discussion_Items__c=discItem.Id);
            discList.add(disc);
            insert discList;
            tak = new Task(OwnerId=UserInfo.getUserId(),CallDurationInSeconds=10,ActivityDate=system.today(),WhoId=listContact[0].Id,Status='Completed',Subject='Call',Type='Call');
            insert tak;
        }
    }
    
    /*-------------insert ZTS_Events__c objects---------------*/
    public static List<ZTS_Events__c> createEvents(Integer counter){ // 6/14
        List<ZTS_Events__c> listEvents1 = new List<ZTS_Events__c>();
        for(Integer i=0; i< counter; i++){
            ZTS_Events__c event = new ZTS_Events__c();
            event.ZTS_US_Will_Firearms_be_Present__c = true;
            event.ZTS_US_Type__c = 'Cattle General';
            //event.Total_Number_of_Invitees__c = i;
            event.ZTS_US_Status__c = 'New';
            event.ZTS_US_Start_Date__c = system.now();
            event.ZTS_US_Is_Event_Private__c = false;
            event.ZTS_US_Name__c = 'Test Event'+i;
            event.ZTS_US_End_Date__c = system.today().addDays(i);
            event.ZTS_US_Compliance_Status__c = 'Acceptable';
            event.ZTS_US_Event_Category__c = 'Educational Meeting';
            event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
            event.ZTS_US_Number_of_Attendees__c = i+2;
          //  event.ZTS_US_Purpose_Agenda__c = 'Test purpose';
            event.Purpose_Agenda__c = 'Test purpose';
            listEvents1.add(event);
        }
        return listEvents1;
    }
    
    static testMethod void callTestDelete(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            //createTestData(1);
            //generateData();
            listAccount = ZTS_DataUtilityTest.createAccountRecord(1, 1);
            insert listAccount;
            listAccount[0].ZTS_EU_Market__c = 'United States';
            update listAccount;
            // List<Product_Metrics__c> pmList = new List<Product_Metrics__c>();
            Call__c call = new Call__c(ZTS_EU_Account__c=listAccount[0].Id, 
                                       ZTS_EU_Start_Date_Time__c=system.today(),
                                       ZTS_EU_Duration__c='0.5 Hour',
                                       ZTS_EU_End_Date_Time__c=system.today().addDays(2), 
                                       ZTS_EU_Sub_Type__c='Account Call',
                                       ZTS_EU_Status__c='Planned'
                                      );
            insert call;
            test.stopTest();
            
            List<Call__c> testCall = [ SELECT Id, Name 
                                      FROM Call__c
                                      WHERE Name='Account Call' AND ZTS_EU_Status__c='Planned'
                                      LIMIT 1
                                     ];
            
            System.debug('   testCall   ::::: '+testCall);
            System.assertNotEquals(null, testCall);
        }
    }
    
    /*-------insert Call__c object records------*/
    public static List<Call__c> createCalls(List<Account> listAcct){
        User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        u1.ZTS_EU_Market__c = 'United States';
        u1.Email = 'd@d.d';
        insert u1;
        List<Call__c> listCall = new List<Call__c>();
        for(Account acc: listAcct){
            Call__c call = new Call__c(ZTS_EU_Account__c=acc.Id, 
            ZTS_EU_Start_Date_Time__c=system.today(),
            ZTS_EU_Duration__c='0.5 Hour',
            ZTS_EU_End_Date_Time__c=system.today().addDays(2),
            ZTS_EU_Sub_Type__c='Account Call',
            ZTS_EU_Status__c='Planned',
            Name='Account Call',
            ZTS_EU_Next_Call_Date__c=system.today(),
            ZTS_EU_Submitted_Date__c=System.Today(), 
            ZTS_EU_Call_Owner__c = u1.Id
            );
            listCall.add(call);
        }
        return listCall;
    }
    /*
    static testMethod void createStandardControllerTest3(){
        
        
        Profile profiles=[Select Id From Profile Where Name='US Small Animal Rep'];
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='testem@deneme.com';
        newuser.username='testem@deneme1.com';
        newuser.lastname='testem';
        newuser.alias='testem';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';  
        newuser.EmailEncodingKey='ISO-8859-1';
        newuser.PIT_Coaching_Group__c='TBM';
        newuser.ZTS_EU_Market__c = 'United States';
        insert newuser;
        ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='Terr',ZTS_FieldForce_ID__c='100',ZTS_Field_Force_Name__c='Small Animal',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Territory',ZTS_Species__c='Small Animal', ZTS_EU_Market__c = 'United States');
        insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=newuser.id,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        
        insert usrTerr;
        System.runAs(newuser){
            test.startTest();
            List<Account> accts = new List<Account>();
            Integer count=1;
            Account acc = new Account();         
            acc.name = 'Test Account';
            acc.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc.Billingcountry = 'United States';
            acc.BillingStreet = 'Test Street';
            acc.BillingCity = 'Test City';
            acc.BillingState   = 'OH';  
            acc.BillingPostalCode = '12345';
            acc.ZTS_US_NARC_ID__c='1234';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            accts.add(acc);
            insert accts;
            List<ZTS_EU_Account_Position__c> accposlist;
            accposlist =[SELECT Id,ZTS_EU_Employee__c,ZTS_Field_ForceID__c,ZTS_EU_Account__c from ZTS_EU_Account_Position__c where ZTS_EU_Account__c=:accts[0].Id AND ZTS_EU_Market__c = 'United States'];
            delete accposlist;
            Call__c call = new Call__c(ZTS_EU_Account__c=accts[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call;
            ZTS_US_Call_CS__c subtype = new ZTS_US_Call_CS__c(Name='100',ZTS_US_Sub_Type_Value__c='100',ZTS_US_Sub_Type_Value_2__c='Account Call;Sample Drop');
            insert subtype;
            ApexPAges.StandardController sc = new ApexPages.StandardController(call);
            PageReference massAddAccPage = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage);
            //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
            
            SalesCallController salesCall = new SalesCallController(sc);
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }
    
    static testMethod void createStandardControllerTest4(){
        
        
        Profile profiles=[Select Id From Profile Where Name='US Poultry Rep'];
        User newuser1=new User();
        newuser1.profileid=profiles.Id;
        newuser1.email='testemuser@deneme.com';
        newuser1.username='testemuser1@deneme1.com';
        newuser1.lastname='testemuser';
        newuser1.alias='testali';
        newuser1.languagelocalekey='en_US';
        newuser1.localesidkey='en_US';
        newuser1.timezonesidkey='America/Los_Angeles';
        newuser1.localesidkey='en_US';  
        newuser1.EmailEncodingKey='ISO-8859-1';
        newuser1.PIT_Coaching_Group__c='TBM';
        newuser1.ZTS_EU_Market__c = 'United States';
        insert newuser1;
        ZTS_EU_Territory__c cterr1=new ZTS_EU_Territory__c(Name='Terr1',ZTS_FieldForce_ID__c='100',ZTS_Field_Force_Name__c='Small Animal',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Territory',ZTS_Species__c='Small Animal', ZTS_EU_Market__c = 'United States');
        insert cterr1;
        
        ZTS_EU_Position__c usrTerr1=new ZTS_EU_Position__c(ZTS_EU_Employee__c=newuser1.id,ZTS_EU_Territory__c=cterr1.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        
        insert usrTerr1;
        System.runAs(newuser1){
            test.startTest();
            List<Account> accts1 = new List<Account>();
            Integer count=1;
            Account acc1 = new Account();         
            acc1.name = 'Test Account';
            acc1.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc1.Billingcountry = 'United States';
            acc1.BillingStreet = 'Test Street';
            acc1.BillingCity = 'Test City';
            acc1.BillingState   = 'OH';  
            acc1.BillingPostalCode = '12345';
            acc1.ZTS_US_NARC_ID__c='1234';
            acc1.ZTS_EU_Zip_Postal_Code__c = '12345';
            accts1.add(acc1);
            insert accts1;
            List<ZTS_EU_Account_Position__c> accposlist;
            accposlist =[SELECT Id,ZTS_EU_Employee__c,ZTS_Field_ForceID__c,ZTS_EU_Account__c from ZTS_EU_Account_Position__c where ZTS_EU_Account__c=:accts1[0].Id AND ZTS_EU_Market__c = 'United States'];
            delete accposlist;
            Call__c call1 = new Call__c(ZTS_EU_Account__c=accts1[0].Id, ZTS_EU_Start_Date_Time__c=system.today(),ZTS_EU_Duration__c='0.5 Hour',ZTS_EU_End_Date_Time__c=system.today().addDays(2), ZTS_EU_Sub_Type__c='Account Call',ZTS_EU_Status__c='Planned');
            insert call1;
            ZTS_US_Call_CS__c subtype1 = new ZTS_US_Call_CS__c(Name='100',ZTS_US_Sub_Type_Value__c='100',ZTS_US_Sub_Type_Value_2__c='Account Call;Sample Drop');
            insert subtype1;
            ApexPAges.StandardController sc1 = new ApexPages.StandardController(call1);
            PageReference massAddAccPage1 = Page.ViewSalesCall;
            Test.setCurrentPage(massAddAccPage1);
            //ApexPages.currentPage().getParameters().put('evt13', String.valueOf(Date.newInstance(2014,07,10)));
            //ApexPages.currentPage().getParameters().put('evt4', String.valueOf(datetime.newInstance(2014, 9, 1, 12, 30, 2)));
            
            SalesCallController salesCall = new SalesCallController(sc1);
            //String profleName = salesCall.userProfileName;
            //String cityName = salesCall.City;
            //List<SelectOption> addList = salesCall.addressList;
            //List<SelectOption> titlList = salesCall.titleList;
            test.stopTest();
        }
    }*/
    
    static ZTS_EU_Species_Product__c createProdHierarchyRecord(String speciesProdName,String recType,String Market,String recTypeId,string parentRecord){
        ZTS_EU_Species_Product__c speciesProdRec = new ZTS_EU_Species_Product__c(Name= speciesProdName,
        ZTS_EU_Type__c= recType ,
        ZTS_EU_Market__c= Market,
        RecordTypeID = recTypeId,
        ZTS_EU_Parent_Species_Product__c = parentRecord);
        
        return speciesProdRec;                                                                           
    }
}