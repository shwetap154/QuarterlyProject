@isTest
public class alpha_OrderSubmissionReminder_BatchTest {
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
            con.ZTS_EU_Market__c = 'Panama';
            con.Selected_For_Alert__c = true;
            con.Email = 'usa123@test.com';
        insert con;
        list<contact> conlist=new list<contact>();
        for(integer i=0; i<=1;i++){
            contact conn=new contact();
            conn.lastname='test last'+i;
            conn.accountid=acc.id;
            conn.Selected_For_Alert__c=true;
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
        
        Primary_Contact_Inactive_Profile_List__c customSetting = new Primary_Contact_Inactive_Profile_List__c();
        Primary_Contact_Inactive_Profile_List__c customSetting1 = new Primary_Contact_Inactive_Profile_List__c();
        Primary_Contact_Inactive_Profile_List__c customSetting2 = new Primary_Contact_Inactive_Profile_List__c();
		
        customSetting.Name = 'Profile Names';
        customSetting1.Name = 'Profile Names 1';
        customSetting2.Name = 'Profile Names 2';
        customSetting.Profile__c = 'ZTS AUT Business Administrator;ZTS BAL Business Administrator;ZTS BGR Business Administrator;ZTS BNLX Business Administrator;ZTS EGY Business Administrator;ZTS ESP Business Administrator;ZTS FIN Business Administrator;System Administrator';
        customSetting1.Profile__c = 'ZTS FRA Business Administrator;ZTS UK Business Administrator;ZTS ITA Business Administrator,Integration Profile,ZTS KOR Business Administrator,ZTS THA Business Administrator,ZTS PHL Business Administrator,ZTS VNM Business Administrator';
        customSetting2.Profile__c = 'ZTS TWN Business Administrator,ZTS IDN Business Administrator,ZTS IND Business Administrator,ZTS CHN Business Administrator,Intll Business Administrator,ZTS CLAR SoLA Business Administrator';
	
        List<Primary_Contact_Inactive_Profile_List__c> lstcs = new List<Primary_Contact_Inactive_Profile_List__c>();
		lstcs.add(customSetting);
        lstcs.add(customSetting1);
        lstcs.add(customSetting2);
		insert lstcs;
        
        List<Account> lstacc = [SELECT Id from Account WHERE Id = :acc.Id];

        lstacc.add(acc);
        
        Test.startTest();
        alpha_OrderSubmissionReminder_Batch an = new alpha_OrderSubmissionReminder_Batch();
        Id JobId = database.executeBatch(an);
        Test.stopTest();
        
        
    }

}