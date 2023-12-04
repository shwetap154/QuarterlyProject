@isTest
public class alpha_StockAndForecastReminder_BatchTest {
    @isTest
    static void testMe(){
        account acc=new account();
        acc.name='test acc';
        acc.ZTS_EU_Market__c = '123456';
        acc.ZTS_EU_Country__c='United Kingdom';
        acc.ZTS_EU_Zip_Postal_Code__c = '11111';
        insert acc;
        AlphaMarketCountry__c alp=new AlphaMarketCountry__c();
        alp.name='testalp';
        alp.CL_Email__c='Test@email.com';
        alp.Country__c='Test Country';
        alp.Market__c='123456';
        insert alp;
         Contact con = new Contact();         
            con.lastname = 'Test Contact';  
            con.firstname = 'first name'; 
            con.AccountId = acc.Id;    
            con.ZTS_EU_Market__c ='United Kingdom';
            con.Send_Alert_For_Forecast__c = true;
            con.Email = 'usa123@test.com';
        insert con;
        list<contact> conlist=new list<contact>();
        for(integer i=0; i<=1;i++){
            contact conn=new contact();
            conn.lastname='test last'+i;
            conn.accountid=acc.id;
            conn.Send_Alert_For_Forecast__c=true;
            conn.ZTS_EU_Market__c ='United Kingdom';
            conn.Email='xelliott'+i+'@example.net';
            conlist.add(conn);
        }
        insert conlist;
        Stock__c st=new Stock__c();
        st.Year__c='2021';
        st.Month__c='December';
        st.Account__c=acc.id;
        insert st;
        Test.startTest();
        alpha_StockAndForecastReminder_Batch an = new alpha_StockAndForecastReminder_Batch();
        Id JobId = database.executeBatch(an);
        Test.stopTest();
        
        
    }

}