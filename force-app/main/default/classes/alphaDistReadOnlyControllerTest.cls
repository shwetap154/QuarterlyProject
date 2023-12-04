/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-27-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
@isTest
public class alphaDistReadOnlyControllerTest {
    
   

       

       
  public static testmethod void alphaDistReadOnly(){
       
         account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='Albania';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        acc.ZTS_EU_District__c = 'Test';
        acc.BillingStreet = '123 Street';
        acc.BillingCity = 'Parsippany';
        acc.BillingState = 'New Jersey';
        acc.BillingPostalCode = '07054';
        acc.BillingCountry = 'United States';
        insert acc;
        
        

      
       contact con=new contact();
        con.ZTS_EU_Market__c = 'ALPHA';
        con.lastname='test last';
        con.accountid=acc.id;
        con.email='test@email.com';
        insert con;
    
      Profile p = [
         SELECT id
         FROM profile
         WHERE name = 'Distributor Community User' ];
   
         List<UserRole> usrrole = [
         SELECT Id,Name
         FROM UserRole
         WHERE name = 'Sales Operations'];

        User usr = new User(
        alias = 'standt',
        email = 'zoetisDistributorTest@test.zts.com',
        emailencodingkey = 'UTF-8',
        lastname = 'Testing',
        languagelocalekey = 'en_us',
        localesidkey = 'en_us',
        profileid = p.Id,
        ZTS_EU_Market__c = 'ALPHA',
        timezonesidkey = 'America/Los_Angeles',
        contactid = con.id,
        username = 'zoetisDistributorTest@test.zts.com'
        );
        insert usr;
      
        
         Product2 prod = new Product2(Name = 'Laptop X200',
                                     Family = 'Hardware');
        insert prod;
        
        
        State_Country__c stc = new State_Country__c();
            stc.name='test co';
            stc.ZTS_EU_Country__c='Albania';
            insert stc;
            
            Address__c adds=new Address__c();
            adds.name='test line';
            adds.ZTS_EU_Account__c=acc.id;
            adds.ZTS_EU_District__c='Teast';
            adds.ZTS_EU_Country__c='Albania';
            adds.ZTS_EU_State_County__c=stc.id;
            adds.Zip_Postal_Code__c='738747';
            adds.ZTS_US_Source_Account_Number__c='908090';
            insert adds;
        
        
        SAPCustomerMaterialPrice__c sapc = new SAPCustomerMaterialPrice__c();
            sapc.Customer_Number__c='908090';
            sapc.Product__c=prod.id;
            sapc.Sales_Organization__c='2941'; 
            sapc.Material_Number__c='test'; 
            sapc.Valid_From__c=system.today(); 
            sapc.Valid_To__c=system.today().adddays(10); 
            sapc.Price__c=20;
            sapc.External_ID__c = '87766';
            sapc.Unit_of_Measure__c = '111';
            insert sapc;

          Forecast__c fa=new Forecast__c();
          fa.Year__c='2021';
          fa.Month__c='June';
          fa.Account__c=acc.id;
          insert fa;
       
       Forecast__History fh = new Forecast__History();
       fh.parentId = fa.Id;
       fh.Field = 'Year__c';
       insert fh;
       
        
        List<Forecast_Product__c> fcpList = new List<Forecast_Product__c>();
        for(Integer i=0; i < 2; i++){
        Forecast_Product__c fcp=new Forecast_Product__c();
        fcp.SAP_Product_Code__c='000000000010000312';
        fcp.Quantity__c=5+i;
        fcp.Forecast__c=fa.id;
        fcp.Price__c=4+i;
        fcp.Product__c = prod.id;
        fcpList.add(fcp);
        }
        
        insert fcpList;
       Forecast_Product__History fph = new Forecast_Product__History();
       fph.ParentId =fcpList[0].Id;
       fph.Field= 'Quantity__c';
        insert fph; 
        Stock__c st=new Stock__c();
        st.Market_Account__c = '';
        st.Year__c='2021';
        st.Month__c='June';
        st.Account__c=acc.id;
        insert st; 
       Stock_Product__c stockprod = new Stock_Product__c(Product__c = prod.id,Quantity__c=1,SAP_Product_Code__c = 'ABCOde',Stock__c=st.id);
       insert stockprod;
            
       System.runAs(usr){
        List<Product2> prod1 = UtilityController.returnProdList();
          List<sobject> accountList = UtilityController.returnObjList();
            system.debug('accountList>>>>>>>>>>>>>>>>>.'+accountList);
         List<SObject> getColumnsList = alphaDistReadOnlyController.getColumns('forecast');
           alphaDistReadOnlyController.getProductStock(string.valueof(prod.Id));
           alphaDistReadOnlyController.getProductForecast(string.valueof(prod.Id));
           alphaDistReadOnlyController.getIntialList();
           alphaDistReadOnlyController.getInitialListForecast();
           alphaDistReadOnlyController.getMonthlyForecast('June','2021');
           alphaDistReadONlyController.getMonthlyStock('June', '2021');
            alphaDistReadOnlyController.loadForecastView('June','2021',acc.Id);
            alphaDistReadOnlyController.loadStockView('June','2021',acc.Id);
            alphaDistReadOnlyController.loadStockView('June','2021','');
            alphaDistReadOnlyController.saveForecastRecord('{"pfOfList":[{"forecast":{"Product__c":"01t3k000007H3r5AAC","SAP_Product_Code__c":"000000000010002748","Quantity__c":"05","Distributor_Product_Code__c":"","Distributor_Product_Name__c":""},"prod":{"Id":"01t3k000007H3r5AAC","Name":"TEATSEAL SUS 2.6GM/DSX1DS SYRX120 BRA","SAP_Product_Number__c":"000000000010002748","Description":"TEATSEAL NSSUS 2.6 GM/DOSE 1 DOSE PSYR 120 EA IFC POR - Recurring","SAP_Sales_Unit_of_Measure__c":"CT"}}]}','2021','June');

           alphaDistReadOnlyController.saveStockRecord('{"psOfList":[{"prod":{"Id":"01t3k000007H3okAAC","Name":"TACKZURON PRON 2.5%/LX5L BTX4 PT","SAP_Product_Number__c":"000000000010009329","Description":"TACKZURON SPOURO 2.5 PCT/L 5 L PBTL 4 EA SHIPPE POR - Recurring"},"stock":{"SAP_Product_Code__c":"000000000010009329","Product__c":"01t3k000007H3okAAC","Distributor_Product_Code__c":"","Distributor_Product_Name__c":"","Batch_Lot_Number__c":"56","Quantity__c":0,"Expiration_Date__c":"2021-08-15"}}]}','2022','June');
       }
        
        
        
       
          }
  public static testmethod void alphaDistReadOnly1(){
    
		alphaDistReadOnlyController.getMonthlyForecast('','');  
       
   }
        
    }