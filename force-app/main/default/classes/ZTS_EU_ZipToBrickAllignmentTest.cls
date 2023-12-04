@isTest
public class ZTS_EU_ZipToBrickAllignmentTest {
    
    @TestSetup
    static void makeData(){
        List<Account> accList = new List<Account>();        
        State_Country__c sc = new State_Country__c();         
        sc.name = 'Test State';
        sc.ZTS_EU_Country__c = 'Denmark';
        sc.ZTS_EU_uniqueCOUNTY__c = 'Test State';
        insert sc;
        
        Account acc = new Account();         
        acc.name = 'Test Account'; 
        acc.Type = 'Farm';
        acc.ZTS_EU_Sub_Type__c = 'Beef';
        acc.ZTS_EU_Address_Line_1__c = 'Test Address Line';
        acc.ZTS_EU_City__c = 'Test City';
        acc.ZTS_EU_Zip_Postal_Code__c = '123654';                
        acc.ZTS_EU_Main_Phone__c='9876789876';
        acc.ZTS_EU_District__c ='Test';
        acc.CurrencyIsoCode='EUR';
        acc.ZTS_EU_Market__c='Denmark';
        acc.ZTS_EU_Vetsave_ID__c='200';
        acc.ZTS_EU_Vetsave_HO_ID__c='56';
        acc.ZTS_EU_Country__c = 'Denmark';
        acc.ZTS_EU_VAT_Code__c = '132434223';
        acc.ZTS_EU_State_County__c = sc.Id;
        //acc.ZTS_EU_BrickCode__c = '5698';  
        accList.add(acc);
        
        insert accList; 
        
        //User Data creation
        user u = new user();
        Profile profiles=[Select Id From Profile Where Name='ZTS DEN Business Administrator'];
        u.ZTS_EU_Market__c = 'Denmark';
        u.ProfileId = profiles.id;
        u.FirstName = 'Test UK';
        u.LastName = 'Admin';
        u.Alias = 'xysd';
        u.Email = 'xyz269@example963.com';
        u.Username = 'xyz269@example963.com';
        u.languagelocalekey='en_US';
        u.localesidkey='en_US';
        u.timezonesidkey='America/Los_Angeles';
        u.localesidkey='en_US';  
        u.EmailEncodingKey='ISO-8859-1';
        insert u;
        
        //Territory data creation
        List<ZTS_EU_Territory__c> terrlst = new List<ZTS_EU_Territory__c>();
        ZTS_EU_Territory__c terr = new ZTS_EU_Territory__c();
        terr.Name = 'Test Terr';
        terr.ZTS_EU_Is_Active__c = True;
        terr.ZTS_EU_Market__c = 'Denmark';  
        terr.ZTS_Field_Force_Name__c='FieldForceName-1';
        terr.ZTS_EU_Description__c='Terr Desc-1';
        terr.ZTS_EU_Type__c='Territory';		
        terrlst.add(terr);
        
        ZTS_EU_Territory__c terr1 = new ZTS_EU_Territory__c();
        terr1.Name = 'TER-CA';
        terr1.ZTS_EU_Is_Active__c = True;
        terr1.ZTS_EU_Market__c = 'Denmark';  
        terr1.ZTS_Field_Force_Name__c='FieldForceName-1';
        terr1.ZTS_EU_Description__c='Terr Desc-1';
        terr1.ZTS_EU_Type__c='Territory';		
        terrlst.add(terr1);
        
        ZTS_EU_Territory__c terr2 = new ZTS_EU_Territory__c();
        terr2.Name = 'TER-LS';
        terr2.ZTS_EU_Is_Active__c = True;
        terr2.ZTS_EU_Market__c = 'Denmark';  
        terr2.ZTS_Field_Force_Name__c='FieldForceName-1';
        terr2.ZTS_EU_Description__c='Terr Desc-1';
        terr2.ZTS_EU_Type__c='Territory';		
        terrlst.add(terr2);
        insert terrlst;
        
        
        List<ZTS_AccountTerritory__c> lstAT2Insert = new List<ZTS_AccountTerritory__c>();
        List<ZTS_GL_ZipToBrick__c> zipBrickList = new List<ZTS_GL_ZipToBrick__c>();
        
        
        
        //BrickToterr
        List<ZTS_GL_BrickToTerr__c> b2tList = New List<ZTS_GL_BrickToTerr__c>();
        ZTS_GL_BrickToTerr__c b2t = new ZTS_GL_BrickToTerr__c();
        b2t.ZTS_EU_BrickName__c = '123654';
        b2t.Name = '123654';
        b2t.ZTS_EU_Market__c = 'Denmark';
        b2t.ZTS_EU_Inactive__c = False;
        b2t.ZTS_EU_Territory__c = terr.Id;
        b2tList.add(b2t);
        
        ZTS_GL_BrickToTerr__c b2t1 = new ZTS_GL_BrickToTerr__c();
        b2t1.ZTS_EU_BrickName__c = '4700';
        b2t1.Name = '4700';
        b2t1.ZTS_EU_Market__c = 'Denmark';
        b2t1.ZTS_EU_Inactive__c = False;
        b2t1.ZTS_EU_Territory__c = terr1.Id;
        b2tList.add(b2t1);
        
        ZTS_GL_BrickToTerr__c b2t2 = new ZTS_GL_BrickToTerr__c();
        b2t2.ZTS_EU_BrickName__c = '4700';
        b2t2.Name = '4700';
        b2t2.ZTS_EU_Market__c = 'Denmark';
        b2t2.ZTS_EU_Inactive__c = False;
        b2t2.ZTS_EU_Territory__c = terr2.Id;
        b2tList.add(b2t2);
        insert b2tList;
        
        //Insert ZipToBrick
        List <ZTS_GL_ZipToBrick__c> ztblst = new List <ZTS_GL_ZipToBrick__c>();  	
        ZTS_GL_ZipToBrick__c ztb = new ZTS_GL_ZipToBrick__c();
        ztb.Name = '123654';
        ztb.ZTS_EU_Market__c = 'Denmark';
        ztb.ZTS_EU_BrickCode__c  =  b2t.id; 
        ztblst.add(ztb);
        
        ZTS_GL_ZipToBrick__c ztb1 = new ZTS_GL_ZipToBrick__c();
        ztb1.Name = '4700';
        ztb1.ZTS_EU_Market__c = 'Denmark';
        ztb1.ZTS_EU_BrickCode__c  =  b2t1.id; 
        ztblst.add(ztb1);
        
        ZTS_GL_ZipToBrick__c ztb2 = new ZTS_GL_ZipToBrick__c();
        ztb2.Name = '4700';
        ztb2.ZTS_EU_Market__c = 'Denmark';
        ztb2.ZTS_EU_BrickCode__c  =  b2t2.id; 
        ztblst.add(ztb2);
        insert ztblst;
        
        
    }
    
    /*static testMethod void Zip_Allign_Method1() {
        
        user u = [Select id,profile.name from User where isActive = true and Profile.Name='ZTS DEN Business Administrator' limit 1];
        list<Account> lstAccount = [Select Id,ZTS_EU_Market__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Sub_Type__c, ZTS_EU_Zoetis_SFDC_ID__c from Account limit 1];
        Test.startTest();
        System.debug('u profile :'+u.Profile.name);
        System.runAs(u){
            
            ZTS_EU_ZipToBrickAllignment.assignTerritory(lstAccount,null,'Insert');
            
            List<AggregateResult> result  = [Select count(id) total from ZTS_AccountTerritory__c];
            Integer ATCount = result[0].get('total') != null ? (Integer)result[0].get('total') : 0;
            system.assert( ATCount > 0, 'AT count should not be zero.');
        }
        Test.stopTest();
    }
    
    static testMethod void Zip_Allign_Method2() {
        
        user u = [Select id,profile.name from User where isActive = true and Profile.Name='ZTS DEN Business Administrator' limit 1];
        list<Account> lstAccount = [Select Id,ZTS_EU_Market__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Sub_Type__c, ZTS_EU_Zoetis_SFDC_ID__c from Account limit 1];
        lstAccount[0].ZTS_EU_Zip_Postal_Code__c = '4700';
        update lstAccount;
        System.debug('u profile :'+u.Profile.name);
        Test.startTest();
        
        System.runAs(u){
            System.debug('u profile :'+u.Profile.name);
            ZTS_EU_ZipToBrickAllignment.assignTerritory(lstAccount,null,'Insert');
            
            List<AggregateResult> result  = [Select count(id) total from ZTS_AccountTerritory__c];
            Integer ATCount = result[0].get('total') != null ? (Integer)result[0].get('total') : 0;
            system.assert( ATCount > 0, 'AT count should not be zero.');
        }
        Test.stopTest();
    }
   */ 
    static testMethod void Zip_Allign_Method3() {
        
        user u = [Select id from User limit 1];
        
        Map<Id, Account> accListOldMap = new Map<Id, Account>([Select Id,ZTS_EU_Market__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Sub_Type__c, ZTS_EU_Zoetis_SFDC_ID__c from Account limit 1]);
        
        list<Account> lstAccount = [Select Id,ZTS_EU_Market__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Sub_Type__c, ZTS_EU_Zoetis_SFDC_ID__c from Account limit 1];
        lstAccount[0].ZTS_EU_Zip_Postal_Code__c = '4700';
        lstAccount[0].ZTS_EU_Sub_Type__c = 'Companion Animal';
        update lstAccount;
        
        Test.startTest();
        
        System.runAs(u){
            Set<String> marketSet = ZTS_EU_ZipToBrickAllignment.territoryMarkets(lstAccount);
            ZTS_EU_ZipToBrickAllignment.assignTerritory(lstAccount,accListOldMap,'Update',marketSet);
            
            List<AggregateResult> result  = [Select count(id) total from ZTS_AccountTerritory__c];
            Integer ATCount = result[0].get('total') != null ? (Integer)result[0].get('total') : 0;
            system.assert( ATCount > 0, 'AT count should not be zero.');
        }
        Test.stopTest();
    }
    
}