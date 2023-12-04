@isTest
public class BatchToUpdateAccountDailyTest
{
     
     @TestSetup
     static void setupData(){
          
          User usr = new User();
          usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
          usr.FirstName = 'intlUser';
          usr.zts_eu_market__c = 'France';
          insert usr;
          System.runAs(usr)
          {
               ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

               Account acc = new Account(Name = 'Test Account', ZTS_EU_Zip_Postal_Code__c='12345',ZTS_EU_Market__c = 'France', Practice_Management_Software__c = 'Animana', Type = 'Farm', ZTS_EU_District__c = 'XXXX', BillingPostalCode = '00000', BillingCity = 'testCity', BillingState = 'testState', BillingStreet = 'testStreet');
               List<account> accList = new List<Account>();
               List<ZTS_EU_Sales__c> salesList = new List<ZTS_EU_Sales__c>();
               accList.add(acc);
               insert accList;
               ZTS_EU_Species_Product__c prod = new ZTS_EU_Species_Product__c(Name= 'Test Product', ZTS_EU_Market__c = 'France', ZTS_EU_Type__c='Account',CurrencyIsoCode ='EUR');
               insert prod;
               ZTS_EU_Sales__c sales = new ZTS_EU_Sales__c(Name = 'Test',ZTS_EU_00_Current_Sales__c = 10,ZTS_EU_00_Previous_Sales__c = 10,ZTS_EU_01_Current_Sales__c = 20,ZTS_EU_01_Previous_Sales__c = 20, ZTS_EU_02_Current_Sales__c = 30, ZTS_EU_02_Previous_Sales__c = 30, ZTS_EU_03_Current_Sales__c = 40, ZTS_EU_03_Previous_Sales__c = 40,ZTS_EU_04_Current_Sales__c = 50, ZTS_EU_04_Previous_Sales__c = 50, ZTS_EU_05_Current_Sales__c = 60, ZTS_EU_05_Previous_Sales__c = 60, ZTS_EU_06_Current_Sales__c = 80, ZTS_EU_06_Previous_Sales__c = 80,ZTS_EU_07_Current_Sales__c = 500, ZTS_EU_07_Previous_Sales__c = 600, ZTS_EU_08_Current_Sales__c = 800, ZTS_EU_08_Previous_Sales__c = 856, ZTS_EU_09_Current_Sales__c = 600, ZTS_EU_09_Previous_Sales__c = 950, ZTS_EU_10_Current_Sales__c = 450, ZTS_EU_10_Previous_Sales__c = 650, ZTS_EU_11_Current_Sales__c = 780, ZTS_EU_11_Previous_Sales__c = 650, ZTS_EU_12_Current_Sales__c = 845, ZTS_EU_12_Previous_Sales__c = 985, ZTS_EU_Account__c = accList[0].id,ZTS_EU_Aggregated__c = false, ZTS_EU_Date__c = Date.newInstance(2015, 7, 1),ZTS_EU_Total_CYTD_Sales__c = 5000,ZTS_EU_Total_MAT_Current_Sales__c = 6000, ZTS_EU_Total_MAT_Prior_Sales__c = 9842);
               salesList.add(sales);
               ZTS_EU_Sales__c sales1 = new ZTS_EU_Sales__c(Name = 'Testing256',ZTS_EU_Product__c = prod.id, ZTS_EU_00_Current_Sales__c = 10,ZTS_EU_00_Previous_Sales__c = 10,ZTS_EU_01_Current_Sales__c = 20,ZTS_EU_01_Previous_Sales__c = 20, ZTS_EU_02_Current_Sales__c = 30, ZTS_EU_02_Previous_Sales__c = 30, ZTS_EU_03_Current_Sales__c = 40, ZTS_EU_03_Previous_Sales__c = 40,ZTS_EU_04_Current_Sales__c = 50, ZTS_EU_04_Previous_Sales__c = 50, ZTS_EU_05_Current_Sales__c = 60, ZTS_EU_05_Previous_Sales__c = 60, ZTS_EU_06_Current_Sales__c = 80, ZTS_EU_06_Previous_Sales__c = 80,ZTS_EU_07_Current_Sales__c = 500, ZTS_EU_07_Previous_Sales__c = 600, ZTS_EU_08_Current_Sales__c = 800, ZTS_EU_08_Previous_Sales__c = 856, ZTS_EU_09_Current_Sales__c = 600, ZTS_EU_09_Previous_Sales__c = 950, ZTS_EU_10_Current_Sales__c = 450, ZTS_EU_10_Previous_Sales__c = 650, ZTS_EU_11_Current_Sales__c = 780, ZTS_EU_11_Previous_Sales__c = 650, ZTS_EU_12_Current_Sales__c = 845, ZTS_EU_12_Previous_Sales__c = 985, ZTS_EU_Account__c = accList[0].id,ZTS_EU_Aggregated__c = false, ZTS_EU_Date__c = Date.newInstance(2015, 7, 1),ZTS_EU_Total_CYTD_Sales__c = 5000,ZTS_EU_Total_MAT_Current_Sales__c = 6000, ZTS_EU_Total_MAT_Prior_Sales__c = 9842);
               salesList.add(sales1);
               insert salesList;
               ZTS_EU_Accounting_Period__c ap = new ZTS_EU_Accounting_Period__c(ZTS_EU_No_of_Working_Days__c = 15,ZTS_EU_Account_Period__c = '07',ZTS_EU_AP_Start_Editable__c = Date.newInstance(2015, 4, 1), ZTS_EU_AP_End_Editable__c = Date.newInstance(2015, 7, 1),ZTS_EU_Market__c = 'France');
               insert ap;
          }
          
     }
     
     @isTest
     static void TestBatchToUpdateAccountDaily()
     {
          
          User intlUser = [SELECT Id FROM User WHERE FirstName = 'intlUser'];

          Account testAccount = [SELECT Id, AP_07_PY_TS__c FROM Account WHERE Name='Test Account' LIMIT 1]; 

          System.runAs(intlUser) {
               Test.startTest();
                    BatchToUpdateAccountDaily obj1 = new BatchToUpdateAccountDaily();
                    database.executebatch(obj1);
               Test.stopTest();
          }

          Account testAccountAfter = [SELECT Id, AP_07_PY_TS__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];
          System.assertNotEquals(null, testAccountAfter.AP_07_PY_TS__c, 'Field should be populated'); // Chose AP_07_PY_TS__c randomly, several fields should get update including all AP_*_ fields
          
          
     }
}