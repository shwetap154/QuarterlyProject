/**
 * @description       : Test class for alphaDistExcelController
 * @author            : Cognizant
 * @group             : 
 * @last modified on  : 04-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   08-28-2021   Unknown                       Initial Version
 * 1.1   09-16-2021   Morgan Marchese @ Zoetis Inc  Add file header
 * 1.1   04-01-2022   Ethan Hirsch @ Zoetis Inc     Update Test 3 to have a Price greater than 1000 to cover the replace comma logic
**/
@isTest
public class alphaDistExcelControllerTest {
  private static final Profile p = [
    SELECT Id
    FROM Profile
    WHERE Name = 'Distributor Community User'
  ];

  @TestSetup
  public static void setup() {
    DispatchTriggerHandler.bypass('AccountTriggerHandler');
    DispatchTriggerHandler.bypass('ContactTriggerHandler');
    account acc = new account();
    acc.name = 'test acc';
    acc.ZTS_EU_Market__c = 'ALPHA';
    acc.ZTS_EU_Country__c = 'Albania';
    acc.ZTS_EU_Zip_Postal_Code__c = '00000';
    acc.BillingStreet = '123 Street';
    acc.BillingCity = 'Parsippany';
    acc.BillingState = 'New Jersey';
    acc.BillingPostalCode = '07054';
    acc.BillingCountry = 'United States';
    insert acc;
    contact con = new contact();
    con.lastname = 'test last';
    con.accountid = acc.id;
    con.email = 'test@email.com';
    con.ZTS_EU_Market__c = 'ALPHA';
    insert con;
    User usr = new User(
      alias = 'standt',
      email = 'standarduser@testorg.com',
      emailencodingkey = 'UTF-8',
      lastname = 'Testing',
      languagelocalekey = 'fr',
      localesidkey = 'fr',
      profileid = p.Id,
      ZTS_EU_Market__c = 'ALPHA',
      timezonesidkey = 'America/Los_Angeles',
      contactid = con.id,
      username = 'testUser@testsales.com'
    );
    insert usr;
    Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
    insert prod;
    State_Country__c stc = new State_Country__c();
    stc.name = 'test co';
    stc.ZTS_EU_Country__c = 'Albania';
    insert stc;

    Address__c adds = new Address__c();
    adds.name = 'test line';
    adds.ZTS_EU_Account__c = acc.id;
    adds.ZTS_EU_District__c = 'Teast';
    adds.ZTS_EU_Country__c = 'Albania';
    adds.ZTS_EU_State_County__c = stc.id;
    adds.Zip_Postal_Code__c = '738747';
    adds.ZTS_US_Source_Account_Number__c = '908090';
    insert adds;

    SAPCustomerMaterialPrice__c sapc = new SAPCustomerMaterialPrice__c();
    sapc.Customer_Number__c = '908090';
    sapc.Product__c = prod.id;
    sapc.Sales_Organization__c = '2941';
    sapc.Material_Number__c = 'test';
    sapc.Valid_From__c = system.today();
    sapc.Valid_To__c = system.today().adddays(10);
    sapc.Price__c = 20;
    sapc.External_ID__c = '1';
    insert sapc;
    Forecast__c fa = new Forecast__c();
    fa.Year__c = '2021';
    fa.Month__c = 'June';
    fa.Account__c = acc.id;
    insert fa;

    Forecast__History fh = new Forecast__History();
    fh.parentId = fa.Id;
    fh.Field = 'Year__c';

    insert fh;

    Forecast_Product__c fcp = new Forecast_Product__c();
    fcp.SAP_Product_Code__c = '000000000010000312';
    fcp.Quantity__c = 5;
    fcp.Forecast__c = fa.id;
    fcp.Price__c = 4;
    insert fcp;
    Forecast_Product__History fph = new Forecast_Product__History();
    fph.ParentId = fcp.Id;
    fph.Field = 'Quantity__c';
    insert fph;
    Stock__c st = new Stock__c();
    st.Market_Account__c = '';
    st.Year__c = '2021';
    st.Month__c = 'June';
    st.Account__c = acc.id;
    insert st;
    Stock_Product__c stockprod = new Stock_Product__c(
      Product__c = prod.id,
      Quantity__c = 1,
      SAP_Product_Code__c = 'ABCOde',
      Stock__c = st.id
    );
    insert stockprod;
  }
  public static testMethod void alphaDistExcelTest() {
    Map<String, String> aMap = new Map<String, String>();
    Map<String, String> bMap = new Map<String, String>();
    aMap.put('Currency', 'EUR');
    aMap.put('Distributor Price', '12');
    aMap.put('roduct Description', 'ZENIQUIN FCT 200MGX50BTX1 EN US');
    aMap.put('Quantity', '1');
    aMap.put('SAP Material Code', '0000123451');
    bMap.put('Month', 'August');
    bMap.put('Year', '2022');
    List<Map<String, String>> aList = new List<Map<String, String>>();
    aList.add(aMap);
    User usr = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
    System.runAs(usr) {
      List<sobject> accountList = UtilityController.returnObjList();
      alphaDistExcelController.getProductList('Forecast');
      alphaDistExcelController.getProductListDemo('Forecast');
      alphaDistExcelController.parseForecastExcelJson(aList, bMap);
      alphaDistExcelController.parseStockExcelJson(aList, bMap);
    }
  }

  public static testMethod void alphaDistExcelTest2() {
    Map<String, String> aMap = new Map<String, String>();
    Map<String, String> bMap = new Map<String, String>();
    aMap.put('Currency', 'EUR');
    aMap.put('Distributor Price', '12');
    aMap.put('Product Description', 'ZENIQUIN FCT 200MGX50BTX1 EN US');
    aMap.put('Quantity', '1');
    aMap.put('SAP Material Code', '0000123451');
    bMap.put('Month', 'August');
    bMap.put('Year', '2022');
    List<Map<String, String>> aList = new List<Map<String, String>>();
    aList.add(aMap);
    User usr = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
    System.runAs(usr) {
      List<sobject> accountList = UtilityController.returnObjList();

      alphaDistExcelController.parseForecastExcelJson(aList, bMap);
      alphaDistExcelController.parseStockExcelJson(aList, bMap);
    }
  }

  public static testMethod void alphaDistExcelTest3() {
    Map<String, String> aMap = new Map<String, String>();
    Map<String, String> bMap = new Map<String, String>();
    aMap.put('Currency', 'EUR');
    aMap.put('Distributor Price', '12,000,123.44');
    aMap.put('Product Description', 'ZENIQUIN FCT 200MGX50BTX1 EN US');
    //aMap.put('Quantity','1');
    aMap.put('SAP Material Code', '0000123451');
    bMap.put('Month', 'August');
    bMap.put('Year', '2022');
    List<Map<String, String>> aList = new List<Map<String, String>>();
    aList.add(aMap);
    User usr = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
    System.runAs(usr) {
      List<sobject> accountList = UtilityController.returnObjList();

      alphaDistExcelController.parseForecastExcelJson(aList, bMap);
      alphaDistExcelController.parseStockExcelJson(aList, bMap);
    }
  }
  public static testMethod void alphaDistExcelTest1() {
    User usr = [SELECT Id FROM User WHERE Email = 'standarduser@testorg.com' LIMIT 1];
    System.runAs(usr) {
      List<sobject> accountList = UtilityController.returnObjList();
      alphaDistExcelController.getProductList('Stock');
      alphaDistExcelController.getProductListDemo('Stock');
    }
  }
}