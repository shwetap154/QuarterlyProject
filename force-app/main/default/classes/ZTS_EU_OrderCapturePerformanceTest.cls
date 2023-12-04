@isTest
private class ZTS_EU_OrderCapturePerformanceTest {
    
    static Map<String, ZTS_EU_Accounting_Period__c> getAPs() {
        Map<String, ZTS_EU_Accounting_Period__c> APs = new Map<String, ZTS_EU_Accounting_Period__c>();
        ZTS_EU_Accounting_Period__c ap = null;
        
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '01';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2017, 12, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2017, 12, 31);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 21;
        APs.put('2017-01',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '02';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 01, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2017, 01, 31 );
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-02',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '03';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 02, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 02, 28 );
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 18;
        APs.put('2017-03',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '04';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 03, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 03, 31);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-04',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '05';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 04, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 04, 30);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-05',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '06';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 05, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 05, 31);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-06',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '07';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 06, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 06, 30);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-07',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '08';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 07, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 07, 31);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-08',ap);
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '09';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 08, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 08, 31);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-09',ap);
        
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '10';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 09, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 09, 30);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-10',ap);
        
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '11';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 10, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 10, 31);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-11',ap);
        
        ap = new ZTS_EU_Accounting_Period__c();
        ap.ZTS_EU_Fiscal_Year__c = '2018';
        ap.ZTS_EU_Account_Period__c = '12';
        ap.ZTS_EU_AP_Start_Editable__c = Date.newInstance(2018, 11, 01);
        ap.ZTS_EU_AP_End_Editable__c = Date.newInstance(2018, 11, 30);
        ap.ZTS_EU_Market__c = 'Mexico';
        ap.ZTS_EU_No_of_Working_Days__c = 20;
        APs.put('2017-12',ap);
        
        
        
        
        
        system.debug('APs>>'+APs);
        insert (APs.values());
        
        return APs;
    }
    
    static Map<String, ZTS_EU_Species_Product__c> getPH() {
        Map<String, ZTS_EU_Species_Product__c> ph = new Map<String, ZTS_EU_Species_Product__c>();
        
        Map<String, Schema.RecordTypeInfo> phrt = Schema.SObjectType.ZTS_EU_Species_Product__c.getRecordTypeInfosByDeveloperName();
        
        ZTS_EU_Species_Product__c tg = new ZTS_EU_Species_Product__c();
        tg.ZTS_EU_Market__c = 'Mexico';
        tg.ZTS_EU_Type__c = 'Therapeutic Group';
        tg.Name = 'TestTG';
        tg.ZTS_EU_Product_Unique_ID__c = 'MX-TEST-TG';
        tg.ZTS_EU_Product_External_ID__c = 'MX-TEST-TG';
        tg.RecordTypeId = phrt.get('Therapeutic_Group').getRecordTypeId();
        insert(tg);
        ph.put('MX-TEST-TG',tg);
        
        
        ZTS_EU_Species_Product__c br = new ZTS_EU_Species_Product__c();
        br.ZTS_EU_Market__c = 'Mexico';
        br.ZTS_EU_Type__c = 'Brand';
        br.Name = 'TestBR';
        br.ZTS_EU_Product_Unique_ID__c = 'MX-TEST-BR';
        br.ZTS_EU_Product_External_ID__c = 'MX-TEST-BR';
        br.ZTS_EU_Parent_Species_Product__c = tg.Id;
        br.RecordTypeId = phrt.get('Brand').getRecordTypeId();
        insert(br);
        ph.put('MX-TEST-BR',br);
        
        
        ZTS_EU_Species_Product__c mpg = new ZTS_EU_Species_Product__c();
        mpg.ZTS_EU_Market__c = 'Mexico';
        mpg.ZTS_EU_Type__c = 'MPG';
        mpg.Name = 'TestMPG';
        mpg.ZTS_EU_Product_Unique_ID__c = 'MX-TEST-MPG';
        mpg.ZTS_EU_Product_External_ID__c = 'MX-TEST-MPG';
        mpg.ZTS_EU_Parent_Species_Product__c = br.Id;
        mpg.RecordTypeId = phrt.get('MPG').getRecordTypeId();
        insert(mpg);
        ph.put('MX-TEST-MPG',mpg);
        
        ZTS_EU_Species_Product__c sku = new ZTS_EU_Species_Product__c();
        sku.ZTS_EU_Market__c = 'Mexico';
        sku.ZTS_EU_Type__c = 'SKU';
        sku.Name = 'TestSKU1';
        sku.ZTS_EU_Product_Unique_ID__c = 'MX-TEST-SKU-1';
        sku.ZTS_EU_Product_External_ID__c = 'MX-TEST-SKU-1';
        sku.ZTS_EU_Parent_Species_Product__c = mpg.Id;
        sku.ZTS_EU_Standard_Price__c = 100;
        //sku.CurrencyIsoCode='USD';
        sku.RecordTypeId = phrt.get('SKU').getRecordTypeId();
        sku.ZTS_EU_Is_Orderable__c = true;
        sku.ZTS_EU_Is_Active__c = true;
        insert(sku);
        ph.put('MX-TEST-SKU-1',sku);
        
        sku = new ZTS_EU_Species_Product__c();
        sku.ZTS_EU_Market__c = 'Mexico';
        sku.ZTS_EU_Type__c = 'SKU';
        sku.Name = 'TestSKU2';
        sku.ZTS_EU_Product_Unique_ID__c = 'MX-TEST-SKU-2';
        sku.ZTS_EU_Product_External_ID__c = 'MX-TEST-SKU-2';
        sku.ZTS_EU_Parent_Species_Product__c = mpg.Id;
        sku.ZTS_EU_Standard_Price__c = 200;
        //sku.CurrencyIsoCode='USD';
        sku.RecordTypeId = phrt.get('SKU').getRecordTypeId();
        sku.ZTS_EU_Is_Orderable__c = true;
        sku.ZTS_EU_Is_Active__c = true;
        insert(sku);
        ph.put('MX-TEST-SKU-2',sku);
        
        return ph;
    }
    
    static Map<String, ZTS_EU_User_Target__c> getTargets(User u) {
        Map<String, ZTS_EU_User_Target__c> tgts = new Map<String, ZTS_EU_User_Target__c>();
        
        ZTS_EU_User_Target__c fq1 = new ZTS_EU_User_Target__c();
        fq1.ZTS_EU_User__c = u.Id;
        fq1.ZTS_EU_Period_Type__c = 'Fiscal';
        fq1.ZTS_EU_Year__c = '2018';
        fq1.ZTS_EU_Period_Length__c = 'Quarter';
        fq1.ZTS_EU_Period__c = '01';
        //fq1.CurrencyIsoCode='USD';
        fq1.ZTS_EU_Sales_Target__c = 10000;
        tgts.put('01', fq1);
        
        ZTS_EU_User_Target__c fq2 = new ZTS_EU_User_Target__c();
        fq2.ZTS_EU_User__c = u.Id;
        fq2.ZTS_EU_Period_Type__c = 'Fiscal';
        fq2.ZTS_EU_Year__c = '2018';
        fq2.ZTS_EU_Period_Length__c = 'Quarter';
        fq2.ZTS_EU_Period__c = '02';
        //fq2.CurrencyIsoCode='USD';
        fq2.ZTS_EU_Sales_Target__c = 10000;
        tgts.put('02', fq2);
        
        ZTS_EU_User_Target__c fq3 = new ZTS_EU_User_Target__c();
        fq3.ZTS_EU_User__c = u.Id;
        fq3.ZTS_EU_Period_Type__c = 'Fiscal';
        fq3.ZTS_EU_Year__c = '2018';
        fq3.ZTS_EU_Period_Length__c = 'Quarter';
        fq3.ZTS_EU_Period__c = '03';
        //fq3.CurrencyIsoCode='USD';
        fq3.ZTS_EU_Sales_Target__c = 10000;
        tgts.put('03', fq3);
        
        ZTS_EU_User_Target__c fq4 = new ZTS_EU_User_Target__c();
        fq4.ZTS_EU_User__c = u.Id;
        fq4.ZTS_EU_Period_Type__c = 'Fiscal';
        fq4.ZTS_EU_Year__c = '2018';
        fq4.ZTS_EU_Period_Length__c = 'Quarter';
        fq4.ZTS_EU_Period__c = '04';
        //fq4.CurrencyIsoCode='USD';
        fq4.ZTS_EU_Sales_Target__c = 10000;
        tgts.put('04', fq4);
        
        insert(tgts.values());
        
        return tgts;
    }
    
    static User getTestUser() {
        String id = UserInfo.getUserId();
        User u = [select LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey, ZTS_EU_Market__c from User where Id = :id AND ZTS_EU_Market__c != 'United States'];
        u.ZTS_EU_Market__c = 'Mexico';
        //u.CurrencyIsoCode = 'USD';
        return u;
    }
    
    static Map<String, Account> getAccounts() {
        Map<String, Account> res = new Map<String, Account>();
        
        Account acc = new Account();
        acc.Name = 'Test Account 1 for testclass';
        acc.Type = 'Farm';
        acc.ZTS_EU_Market__c='United Kingdom';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Rep_Account_Status__c = 'Active';
        acc.ZTS_EU_Zip_Postal_Code__c = '12345';
        insert(acc);
        res.put('acc', acc);
        
        Account dist = new Account();
        dist.Name = 'Test Distributor 1 for testclass';
        dist.Type = 'Distributor';
        dist.ZTS_EU_Market__c='United Kingdom';
        dist.Practice_Management_Software__c = 'Other';
        dist.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        dist.ZTS_EU_Rep_Account_Status__c = 'Active';
        dist.ZTS_EU_Zip_Postal_Code__c = '12345';
        insert(dist);
        res.put('dist', dist);
        
        return res;
    }
    
    static List<Orders__c> getOrders(Map<String, ZTS_EU_Accounting_Period__c> APs, Map<String, ZTS_EU_Species_Product__c> ph, Map<String, ZTS_EU_User_Target__c> tgts, Map<String, Account> accs) {
        Map<String, Schema.RecordTypeInfo> ort = Schema.SObjectType.Orders__c.getRecordTypeInfosByDeveloperName();
        List<Orders__c> orders = new List<Orders__c>();
        Orders__c o1 = new Orders__c();
        o1.RecordTypeId = ort.get('Order').getRecordTypeId();
        o1.ZTS_EU_Account__c = accs.get('acc').Id;
        o1.ZTS_EU_Dealer_Distributor__c = accs.get('dist').Id;
        o1.ZTS_EU_Fulfillment_Date__c = Date.today();
        o1.ZTS_EU_Status__c = 'Open';
        o1.Product__c = ph.get('MX-TEST-SKU-1').Id;
        o1.Quantity__c = 5;
        insert(o1);
        
        
        Order_Detail__c od1 = new Order_Detail__c();
        od1.ZTS_EU_Order__c = o1.Id;
        od1.ZTS_EU_Species_Product__c = ph.get('MX-TEST-SKU-1').Id;
        od1.ZTS_EU_Quantity__c = 5;
        insert(od1);
        
        orders.add(o1);
        
        return orders;
    }
    
    static testMethod void periodTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Test.startTest();
            List<ZTS_EU_Accounting_Period__c> accountingperiodList = new List<ZTS_EU_Accounting_Period__c>();
            for(Integer i = 1; i<10; i++){
                ZTS_EU_Accounting_Period__c ap = new ZTS_EU_Accounting_Period__c(ZTS_EU_Fiscal_Year__c = '2015',ZTS_EU_No_of_Working_Days__c = 15,ZTS_EU_Account_Period__c = '0'+i,ZTS_EU_AP_Start_Editable__c = Date.newInstance(2015, 4, 1), ZTS_EU_AP_End_Editable__c = Date.newInstance(2015, 7, 1),ZTS_EU_Market__c = 'United Kingdom');
                accountingperiodList.add(ap);
            }

            insert accountingperiodList;
            ZTS_EU_Accounting_Period__c ap = new ZTS_EU_Accounting_Period__c(ZTS_EU_Fiscal_Year__c = '2015',ZTS_EU_No_of_Working_Days__c = 15,ZTS_EU_Account_Period__c = '10',ZTS_EU_AP_Start_Editable__c = Date.newInstance(2015, 4, 1), ZTS_EU_AP_End_Editable__c = Date.newInstance(2015, 7, 1),ZTS_EU_Market__c = 'United Kingdom');
            insert ap;
            ZTS_EU_Accounting_Period__c ap1 = new ZTS_EU_Accounting_Period__c(ZTS_EU_Fiscal_Year__c = '2015', ZTS_EU_No_of_Working_Days__c = 15,ZTS_EU_Account_Period__c = '11',ZTS_EU_AP_Start_Editable__c = Date.newInstance(2015, 4, 1), ZTS_EU_AP_End_Editable__c = Date.newInstance(2015, 7, 1),ZTS_EU_Market__c = 'United Kingdom');
            insert ap1;
            ZTS_EU_Accounting_Period__c ap2 = new ZTS_EU_Accounting_Period__c(ZTS_EU_Fiscal_Year__c = '2015',ZTS_EU_No_of_Working_Days__c = 15,ZTS_EU_Account_Period__c = '12',ZTS_EU_AP_Start_Editable__c = Date.newInstance(2015, 4, 1), ZTS_EU_AP_End_Editable__c = Date.newInstance(2015, 7, 1),ZTS_EU_Market__c = 'United Kingdom');
            insert ap2;
            ZTS_EU_OrderCapturePerformanceController.Period p = new ZTS_EU_OrderCapturePerformanceController.Period( 'TEST', Date.today(), Date.today());
            System.assertEquals('TEST', p.name);
            System.assertEquals(Date.today(), p.startDate);
            System.assertEquals(Date.today(), p.endDate);
            
            ZTS_EU_OrderCapturePerformanceController.Performance perf = new ZTS_EU_OrderCapturePerformanceController.Performance(p);
            ZTS_EU_OrderCapturePerformanceController c = new ZTS_EU_OrderCapturePerformanceController();
            c.Year = '2015';
            ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance uc = new ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance(usr);
            List<ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance> ucps = c.getCapturePerformance();
            Test.stopTest();

        }
    }
    
    static testMethod void constructorTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        User u;
        System.runAs(usr)
        {
            u = getTestUser();
        }
        u.zts_eu_market__c = 'United Kingdom';
        update(u);
        
        
        System.runAs(u) {
            
            Map<String, ZTS_EU_Accounting_Period__c> APs = getAPs();
            //ZTS_EU_OrderCapturePerformanceController c = new ZTS_EU_OrderCapturePerformanceController();
            //System.assertEquals('Mexico', c.market);
            //System.assertEquals('2018', c.Year);
        }
        
    }
    
    static testMethod void reportTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        User u;
        System.runAs(usr)
        {
            u = getTestUser();
        }
        u.Username = 'ordercaptureperformance@test.com';
        u.Alias = 'ocptest';
        u.Id = null;
        u.zts_eu_market__c = 'United Kingdom';
        insert(u);
        System.runAs(u) {
            Map<String, ZTS_EU_Accounting_Period__c> APs = getAPs();
            Map<String, ZTS_EU_Species_Product__c> ph = getPH();
            Map<String, ZTS_EU_User_Target__c> tgts = getTargets(u);
            Map<String, Account> accs = getAccounts();
            
            /*test.starttest();

            // Test user with no orders
            ZTS_EU_OrderCapturePerformanceController c = new ZTS_EU_OrderCapturePerformanceController();
            List<ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance> ucps = c.getCapturePerformance();
            System.assertEquals(true, ucps.size()>0);
            ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance myucp;
            for (ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance ucp : ucps) {
            if (ucp.user.Id.equals(u.Id)) {
            myucp = ucp;
            break;
            }
            }
            System.assertEquals(0, myucp.performance.get('FY').OrderValue);

            List<Orders__c> orders = getOrders(APs, ph, tgts, accs);

            ucps = c.getCapturePerformance();
            System.assertEquals(true, ucps.size()>0);
            for (ZTS_EU_OrderCapturePerformanceController.UserCapturePerformance ucp : ucps) {
            if (ucp.user.Id.equals(u.Id)) {
            myucp = ucp;
            break;
            }
            }
            System.assertEquals(0, myucp.performance.get('FY').OrderValue);
            System.assertEquals(true, myucp.performance.get('FY').OrderValue < myucp.performance.get('FY').target);
            test.stoptest(); */
        }
    }
}