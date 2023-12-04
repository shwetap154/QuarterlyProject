@isTest
private class ZTS_US_accountContactAffController_Test {

      

    static final String ACCOUNTAFF_INST_ERROR_ORIGIN = 'ZTS_US_accountContactAffController_Test - ZTS_US_accountContactAffController_reverse(): insert Account Affiliations ';

    @testSetup
    static void setup()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
    }
    static testMethod void ZTS_US_accountContactAffController() {

        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
        
        for (Account record: Accountrecord)
        {
            record.ZTS_EU_Market__c = 'United States';
        }     
        insert Accountrecord;  
        List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1); 
        Contactrecord[0].ZTS_EU_Market__c = 'United States';
        insert Contactrecord;
        
        List<ZTS_EU_Affiliations__c> Accconaffrecord = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        List<ZTS_EU_Affiliations__c> Accconaffrecordlst = new List<ZTS_EU_Affiliations__c>();
        for(ZTS_EU_Affiliations__c acconaff : Accconaffrecord)
        {
            acconaff.ZTS_EU_Account__c = Accountrecord[0].id;
            acconaff.ZTS_EU_Contact__c = Contactrecord[0].id;
            acconaff.ZTS_EU_Affiliation_Status__c = 'Active';
            acconaff.ZTS_EU_Account_influence__c = 'Key Decision Maker';
            Accconaffrecordlst.add(acconaff);
        }
        
        insert Accconaffrecordlst;
        
        
        
        ZTS_EU_Affiliations__c accConAffrec = [Select id from ZTS_EU_Affiliations__c where Id = : Accconaffrecordlst[0].id AND ZTS_EU_Market_from_Parent__c = 'United States' limit 1];
        ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c(Id = accConAffrec.id);
        ApexPages.StandardController stdAccconaff = new ApexPages.StandardController(accConAff);            
        PageReference pageRef = Page.ZTS_US_accountContactAff;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',accConAffrec.id);            
        ZTS_US_accountContactAffController accObj = new ZTS_US_accountContactAffController(stdAccconaff);
        
        
        Test.startTest();
        accObj.populateProfValue();
        accObj.save();
        accObj.saveCon();
        accObj.doRedirect();
        Test.stopTest();
      
    } 
     
    static testMethod void ZTS_US_accountContactAffControllerConNull() {
        ZTS_DataUtilityTest.activateTriggerSettings();

        List<Profile> profile = [select Id from Profile where Name='System Administrator' limit 1];       
        User user = new User(username='testUser@testabcasdfasdf232323.com',alias='abctest',ProfileId=profile[0].Id,email='test@abc.com',CommunityNickname='abc',ZTS_EU_Market__c='United States',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert user;
        
       List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
           
        for (Account record: Accountrecord)
        {
            record.ZTS_EU_Market__c = 'United States';
        }     
        insert Accountrecord;  
        List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1); 
        Contactrecord[0].ZTS_EU_Market__c = 'United States';
        insert Contactrecord;        
        
        List<ZTS_EU_Affiliations__c> Accconaffrecord = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        List<ZTS_EU_Affiliations__c> Accconaffrecordlst = new List<ZTS_EU_Affiliations__c>();
        for(ZTS_EU_Affiliations__c acconaff : Accconaffrecord){
            acconaff.ZTS_EU_Account__c = Accountrecord[0].id;
            acconaff.ZTS_EU_Contact__c = Contactrecord[0].id;
            acconaff.ZTS_EU_Affiliation_Status__c = 'Active';
            acconaff.ZTS_EU_Account_influence__c = 'Key Decision Maker';
            Accconaffrecordlst.add(acconaff);
        }
        insert Accconaffrecordlst;
        ZTS_EU_Affiliations__c accConAffrec = [Select id from ZTS_EU_Affiliations__c where Id = : Accconaffrecordlst[0].id AND ZTS_EU_Market_from_Parent__c = 'United States' limit 1];
        ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c(Id = accConAffrec.id);
        ApexPages.StandardController stdAccconaff = new ApexPages.StandardController(accConAff);            
        PageReference pageRef = Page.ZTS_US_accountContactAff;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',accConAffrec.id);   
        ApexPages.currentPage().getParameters().put('accntId',Accountrecord[0].id);            
        ZTS_US_accountContactAffController accObj = new ZTS_US_accountContactAffController(stdAccconaff);
        accObj.editFunc = false;
        
        Test.startTest();
        
        accObj.save();
        accObj.saveCon();            
        Test.stopTest();
    }
    
    static testMethod void ZTS_US_accountContactAffControllerAccNull() {
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
           
        for (Account record: Accountrecord)
        {
            record.ZTS_EU_Market__c = 'United States';
        }     
        insert Accountrecord;  
        List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1); 
        Contactrecord[0].ZTS_EU_Market__c = 'United States';
        insert Contactrecord;
        
        List<ZTS_EU_Affiliations__c> Accconaffrecord = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        List<ZTS_EU_Affiliations__c> Accconaffrecordlst = new List<ZTS_EU_Affiliations__c>();
        for(ZTS_EU_Affiliations__c acconaff : Accconaffrecord){
            acconaff.ZTS_EU_Account__c = Accountrecord[0].id;
            acconaff.ZTS_EU_Contact__c = Contactrecord[0].id;
            acconaff.ZTS_EU_Affiliation_Status__c = 'Active';
            acconaff.ZTS_EU_Account_influence__c = 'Key Decision Maker';
            Accconaffrecordlst.add(acconaff);
        }
        insert Accconaffrecordlst;
        ZTS_EU_Affiliations__c accConAffrec = [Select id from ZTS_EU_Affiliations__c where Id = : Accconaffrecordlst[0].id AND ZTS_EU_Market_from_Parent__c = 'United States' limit 1];
        ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c(Id = accConAffrec.id);
        ApexPages.StandardController stdAccconaff = new ApexPages.StandardController(accConAff);            
        PageReference pageRef = Page.ZTS_US_accountContactAff;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',accConAffrec.id);   
        ApexPages.currentPage().getParameters().put('accntId',Null);
        ApexPages.currentPage().getParameters().put('conId',Contactrecord[0].Id);
        ZTS_US_accountContactAffController accObj = new ZTS_US_accountContactAffController(stdAccconaff);
        accObj.editFunc = false;
        
        Test.startTest();
        
        accObj.save();
        accObj.saveCon();            
        Test.stopTest();
    }
    
     
    static testMethod void ZTS_US_accountContactAffController_reverse() {
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
           
        for (Account record: Accountrecord)
        {
            record.ZTS_EU_Market__c = 'United States';
        }     
        insert Accountrecord;  
        List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1); 
        Contactrecord[0].ZTS_EU_Market__c = 'United States';
        insert Contactrecord;
        
        List<ZTS_EU_Affiliations__c> Accconaffrecord = ZTS_DataUtilityTest.createAccConAffiliationRecord(2);
        List<ZTS_EU_Affiliations__c> Accconaffrecordlst = new List<ZTS_EU_Affiliations__c>();
        for(ZTS_EU_Affiliations__c acconaff : Accconaffrecord){
            acconaff.ZTS_EU_Account__c = Accountrecord[0].id;
            acconaff.ZTS_EU_Contact__c = Contactrecord[0].id;
            acconaff.ZTS_EU_Affiliation_Status__c = 'Active';
            acconaff.ZTS_EU_Account_influence__c = 'Key Decision Maker';
            acconaff.Key_Contact__c = true;
            Accconaffrecordlst.add(acconaff);
        }
        try{
            insert Accconaffrecordlst;
            ZTS_EU_Affiliations__c accConAffrec = [Select id from ZTS_EU_Affiliations__c where Id = : Accconaffrecordlst[0].id AND ZTS_EU_Market_from_Parent__c = 'United States' limit 1];
            ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c(Id = accConAffrec.id);
            ApexPages.StandardController stdAccconaff = new ApexPages.StandardController(accConAff);            
            PageReference pageRef = Page.ZTS_US_accountContactAff;
            
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id',accConAffrec.id);            
            ZTS_US_accountContactAffController accObj = new ZTS_US_accountContactAffController(stdAccconaff);
            Test.startTest();
            accObj.populateProfValue();
            accObj.save();
            accObj.saveCon();            
            Test.stopTest();
        }
        catch(DmlException dex)
		{
			String errorMessages = '';
			for (Integer i = 0; i < dex.getNumDml(); i++) {
				System.debug(ACCOUNTAFF_INST_ERROR_ORIGIN);
				System.debug('DML Message: ' + dex.getDmlMessage(i));
				errorMessages += dex.getDmlMessage(i) + '\n';
			}
			errorMessages.removeEnd('\n');
			ZTS_EU_Logger.notify = true;
			ZTS_EU_Logger.error(errorMessages,null, ACCOUNTAFF_INST_ERROR_ORIGIN);
		}
    } 
    
    static testMethod void ZTS_US_accountNonUsContactAffController() {

        ZTS_DataUtilityTest.activateTriggerSettings();
        
        List<Account> Accountrecord = ZTS_DataUtilityTest.createAccountRecord(1);
        
        for (Account record: Accountrecord)
        {
            record.ZTS_EU_Market__c = 'Spain';
        }     
        insert Accountrecord;  
        List<Contact> Contactrecord = ZTS_DataUtilityTest.createContactRecord(1); 
        Contactrecord[0].ZTS_EU_Market__c = 'Spain';
        insert Contactrecord;
        
        List<ZTS_EU_Affiliations__c> Accconaffrecord = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
        List<ZTS_EU_Affiliations__c> Accconaffrecordlst = new List<ZTS_EU_Affiliations__c>();
        for(ZTS_EU_Affiliations__c acconaff : Accconaffrecord)
        {
            acconaff.ZTS_EU_Account__c = Accountrecord[0].id;
            acconaff.ZTS_EU_Contact__c = Contactrecord[0].id;
            acconaff.ZTS_EU_Affiliation_Status__c = 'Active';
            acconaff.ZTS_EU_Account_influence__c = 'Key Decision Maker';
            Accconaffrecordlst.add(acconaff);
        }
        
        insert Accconaffrecordlst;
        
        
        
        ZTS_EU_Affiliations__c accConAffrec = [Select id from ZTS_EU_Affiliations__c where Id = : Accconaffrecordlst[0].id AND ZTS_EU_Market_from_Parent__c != 'United States' limit 1];
        System.debug('accConAffrec rec :'+accConAffrec);
        ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c(Id = accConAffrec.id);
        ApexPages.StandardController stdAccconaff = new ApexPages.StandardController(accConAff);            
        PageReference pageRef = Page.ZTS_US_accountContactAff;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',accConAffrec.id);            
        ZTS_US_accountContactAffController accObj = new ZTS_US_accountContactAffController(stdAccconaff);
        
        
        Test.startTest();
        accObj.doRedirect();
        Test.stopTest();
      
    } 
     
    
}