@isTest
public class alpha_NewForecastEmailAlert_BatchTest {
  
   Public static TestMethod void TestPositive(){
       
       AlphaMarketCountry__c alp=new AlphaMarketCountry__c();
        alp.name='testalp';
        alp.CL_Email__c='TestCL@email.com';
       	alp.CL_2_Email__c='TestCL2@email.com';
       	alp.CL_3_Email__c='TestCL3@email.com';
       	alp.CL_4_Email__c='TestCL4@email.com';
       	alp.CL_5_Email__c='TestCL5@email.com';
       	alp.CS_Agent_Email__c='TestCSA@email.com';
       	alp.CS_Agent_2_Email__c='TestCSA2@email.com';
       	alp.CS_Agent_3_Email__c='TestCSA3@email.com';
       	alp.CS_Agent_4_Email__c='TestCSA4@email.com';
       	alp.CS_Agent_5_Email__c='TestCSA5@email.com';
        alp.Country__c='United Kingdom';
        alp.Market__c='ALPHA';
        insert alp;
       
       
		account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'ALPHA';
        acc.ZTS_EU_Country__c='United Kingdom';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        insert acc;

		Contact con = new Contact();         
            con.lastname = 'Test Contact';  
            con.firstname = 'first name'; 
            con.AccountId = acc.Id;    
            con.ZTS_EU_Market__c ='United Kingdom';
            con.Send_Alert_For_Forecast__c = true;
       con.Send_Alert_For_Stock__c = true;
       con.Selected_For_Alert__c = true;
            con.Email = 'usa123@test.com';
        insert con;       
        
        Forecast__c fa=new Forecast__c();
            fa.Year__c='2021';
            fa.Month__c='December';
            fa.Account__c=acc.id;
            insert fa;
       fa.Year__c='2022';
       update fa;
       Forecast__History fh = new Forecast__History();
       fh.parentId = fa.Id;
       fh.Field = 'Year__c';
      
       insert fh;
       
       
       Stock__c faa=new Stock__c();
            faa.Year__c='2021';
            faa.Month__c='December';
            faa.Account__c=acc.id;
            insert faa;
       faa.Year__c='2022';
       update faa;
       Stock__History fha = new Stock__History();
       fha.parentId = faa.Id;
       fha.Field = 'Year__c';
      
       insert fha;
       
       
       Test.startTest();
        alpha_NewForecastEmailAlert_Batch an = new alpha_NewForecastEmailAlert_Batch();
        database.executeBatch(an);
       alpha_UpdateForecastEmailAlert_Batch ann = new alpha_UpdateForecastEmailAlert_Batch();
        database.executeBatch(ann);
       alpha_UpdateStockEmailAlert_Batch annn = new alpha_UpdateStockEmailAlert_Batch();
        database.executeBatch(annn);
       alpha_StockAndForecastReminder_Batch annnb = new alpha_StockAndForecastReminder_Batch();
        database.executeBatch(annnb);
       alpha_OrderSubmissionReminder_Batch annnbc = new alpha_OrderSubmissionReminder_Batch();
        database.executeBatch(annnbc);
       
        Test.stopTest();
    }
    // Created as part of TPDEV-1026
	public static TestMethod void testForecastEmail(){
       
       AlphaMarketCountry__c alp=new AlphaMarketCountry__c();
        alp.name='testalp';
        alp.CL_Email__c='TestCL@email.com';     	
       	alp.CS_Agent_5_Email__c='TestCSA5@email.com';
        alp.Country__c='Panama';
        alp.Market__c='Panama';
        alp.Language__c='es';
        insert alp;
        
		account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = 'Panama';
        acc.ZTS_EU_Country__c='Panama';
        acc.ZTS_EU_Zip_Postal_Code__c = '00000';
        insert acc;

		Contact con = new Contact();         
            con.lastname = 'Test Contact 1';  
            con.firstname = 'first name'; 
            con.AccountId = acc.Id;    
            con.ZTS_EU_Market__c ='Panama';
            con.Send_Alert_For_Forecast__c = true;
            con.Email = 'usa123@test.com';
        insert con;   
        
        Contact con2 = new Contact();         
            con2.lastname = 'Test Contact 2';  
            con2.firstname = 'first name 2'; 
            con2.AccountId = acc.Id;    
            con2.ZTS_EU_Market__c ='Costa Rica';
            con2.Send_Alert_For_Forecast__c = false;
            con2.Email = 'usa456@test.com';
        insert con2;
   
        Forecast__c fa=new Forecast__c();
            fa.Year__c='2022';
            fa.Month__c='December';
            fa.Account__c=acc.id;
            insert fa;
       
       fa.Year__c='2023';
       update fa;
        
       Forecast__History fh = new Forecast__History();
       fh.parentId = fa.Id;
       fh.Field = 'Year__c';
      
       insert fh;

       Test.startTest();
        alpha_NewForecastEmailAlert_Batch an = new alpha_NewForecastEmailAlert_Batch();
        database.executeBatch(an);     
       Test.stopTest();
        System.assertEquals(2, [SELECT count() FROM EmailMessage]);    
       
    }      
}