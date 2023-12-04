@isTest
public class alpha_UpdateStockEmailAlert_Batch_Test {
	@isTest
    static void testMe(){
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
        con.Send_Alert_For_Stock__c = true;       
        con.Email = 'usa123@test.com';
        insert con;       
        
        
		Stock__c st=new Stock__c();
        st.Year__c= String.valueOf(System.today().year());
        st.Month__c='December';
        st.Account__c=acc.id;               
        insert st;
        
        st.Month__c='October';
        update st;
		
        Stock__History sh = new Stock__History();
        sh.parentId = st.Id;
        sh.Field = 'Year__c';     
        insert sh;
        
        Test.startTest();
        alpha_UpdateStockEmailAlert_Batch an = new alpha_UpdateStockEmailAlert_Batch();
        Id JobId = database.executeBatch(an);
        Test.stopTest();
                
    }
}