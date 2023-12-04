@isTest
public class UtilityController_Test {
    
    public static testmethod void Test1(){
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='United Kingdom';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        insert acc;
        Address__c address2 = new Address__c();
        address2.name = 'test line';
        address2.ZTS_EU_Account__c = acc.id;
        address2.ZTS_EU_District__c = 'Teast';
        address2.ZTS_EU_Country__c = 'Albania';
        address2.Zip_Postal_Code__c = '738747';
        address2.ZTS_EU_Address_Type__c = 'Ship To';
        address2.ZTS_US_Source_Account_Number__c = '1000908090';
        insert address2;
        contact con = new contact();
        con.lastname = 'test last';
        con.accountid = acc.id;
        con.email = 'test@email.com';
        con.ZTS_EU_Market__c = 'ALPHA';
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
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert usr;
        }
        
        Product2 prod = new Product2(Name = 'Laptop X200Test', Family = 'Hardware');
        insert prod;
        SAPCustomerMaterialPrice__c sapc = new SAPCustomerMaterialPrice__c();
        sapc.Customer_Number__c = '1000908090';
        sapc.Product__c = prod.id;
        sapc.Sales_Organization__c = '2941';
        sapc.Material_Number__c = 'test';
        sapc.Valid_From__c = system.today();
        sapc.Valid_To__c = system.today().adddays(10);
        sapc.Price__c = 20;
        sapc.External_ID__c = '123456';
        sapc.Market__c = 'Panama';
        sapc.CurrencyIsoCode = 'EUR';
        insert sapc;
        
        
        System.runAs(usr) { 
            List<SObject> recordsList =UtilityController.findRecords('test','Account','Name');
            System.assertEquals(1, recordsList.size());
            List<SObject> recordsModularList = UtilityController.findRecordsModular('test','Account','Name  ','  ',' Limit 1 ');
            System.assertEquals(1, recordsModularList.size());
            List<sobject> objList=UtilityController.returnObjList(); 
            System.assertEquals(1, objList.size());
            Set<Id> prodIdSet = new Set<Id>();
            List<Product2> returnedProdList = UtilityController.returnProdList();
            Map<String,Decimal> returnPriceList= UtilityController.returnPriceList();
            Map<String,String> returnUOMList = UtilityController.returnUOMList();
            Map<String,String> returnCurrencyIsoCode = UtilityController.returnCurrencyIsoCode();
            String actualIsoCode = returnCurrencyIsoCode.get(prod.Id);
            Map<String,Address__c> getAccountNumbers = UtilityController.getAccountNumbers();   
        }        
    }
}