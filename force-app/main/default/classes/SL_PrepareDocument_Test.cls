@isTest
private class SL_PrepareDocument_Test {
    @testSetup 
    static void test_SetUp() { 

        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        String strTemplateName = 'Contrat de partenariat AD 2021 Ruminants';
        ApexPages.StandardSetController setCon;
        SL_LinkContactToAccountController objCntl;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
        User intlUsr1 = new User();
        intlUsr1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr1.FirstName = 'IntUser1';
        intlUsr1.ZTS_EU_Market__c = 'France';
        insert intlUsr1;   
        
        User intlUsr2 = new User();
        intlUsr2 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr2.FirstName = 'IntUser2';
        intlUsr2.ZTS_EU_Market__c = 'Italy';
        insert intlUsr2;  
        User intlUsr3 = new User();
        intlUsr3 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr3.FirstName = 'IntUser3';
        intlUsr3.ZTS_EU_Market__c = 'Turkey';
        insert intlUsr3; 
		
        User intlUser4 = new user();
        intlUser4 =  ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUser4.FirstName = 'IntlUser4';    
        intlUser4.ZTS_EU_Market__c = 'Thailand';
        insert intlUser4;    
               
            
            State_Country__c statecon= new State_Country__c(Name='test33',ZTS_EU_Country__c='France');
            insert statecon;
            
            Account objAccount1 = new Account(Name='Test Acc11', Type = 'Farm',
                                            Fr_Contract_Email__c='Test12@email.com',Owner=intlUsr1,ZTS_EU_Address_Line_1__c='test33',ZTS_EU_Country__c ='France',ZTS_EU_State_County__c=statecon.id,ZTS_EU_City__c='Test23', ZTS_EU_Zip_Postal_Code__c='8728424',FR_Contract_Template__c ='Contrat annuel AD CA',ZTS_EU_Main_Phone__c='498249211', ZTS_EU_Market__c = 'France');
            insert objAccount1;
            
            
            
            Contact objContact = new Contact(FirstName='Test C', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
                                            ZTS_EU_Species_Specialty__c='Cattle', Select_Consent_for_eSign__c ='Privacy', ZTS_EU_District__c='UK', ZTS_EU_Market__c = 'Italy');
            insert objContact;
            
            Contact objContact1 = new Contact(FirstName='Test C1', LastName='Test Contact 1', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
                                            ZTS_EU_Species_Specialty__c='Cattle', Select_Consent_for_eSign__c ='Privacy',IT_Contact_Template__c = 'Global Data Privacy' , ZTS_EU_District__c='Italy', ZTS_EU_Market__c = 'Italy');
            insert objContact1;
            
            Contact objContact2 = new Contact(FirstName='Test C2', LastName='Test Contact 2', AccountId = objAccount.Id, ZTS_EU_Contact_type__c = 'Academic',
                                            ZTS_EU_Species_Specialty__c='Cattle', Select_Consent_for_eSign__c ='Privacy-TH',IT_Contact_Template__c = 'VS CO Model 1' , ZTS_EU_District__c='Thailand', ZTS_EU_Market__c = 'Thailand');
            insert objContact2;
            
                      
            ZTS_EU_Sample__c objSample = new ZTS_EU_Sample__c(ZTS_EU_Contact__c = objContact.Id, 
                                                            ZTS_EU_Start_Quantity__c = 15,
                                                            ZTS_EU_Is_used_for_old_SKUs__c = true);
            insert objSample;
            
            ZTS_EU_ContractTemplate__c objcontemplate = new ZTS_EU_ContractTemplate__c(Name= 'A AD ANNUEL BURSA 2021',ZTS_EU_Discount__c=10.00, Negotiation_lever__c= true, Negotiation_lever_per__c = 0, ZTS_EU_Fiscal_Year__c='2021');
            
            insert objcontemplate;
            
            Contract objContract = new Contract(AccountId = objAccount.Id, 
                                                ZTS_EU_Committed_Amount__c = 25000, Status = 'Draft',
                                                eSign_Document__c = 'Directo Avicultura');
            insert objContract;
            
            Contract objContract1 = new Contract(AccountId = objAccount1.Id, 
                                                ZTS_EU_Committed_Amount__c = 25000, Status = 'Draft',
                                                ZTS_EU_Related_Contract_Template__c = objcontemplate.id);
            insert objContract1;
            
            List<echosign_dev1__Agreement_Template__c> lstAT = new List<echosign_dev1__Agreement_Template__c> {
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Account', Name = 'Account AT'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Account', Name = 'Contrat de partenariat AD 2023 Ruminants'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Account', Name = 'Contrat de partenariat AD 2023 Equine'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Account', Name = 'Contrat de partenariat AD 2021 Aviaire'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Account', Name = 'Contrat de partenariat AD 2023 Animaux de Compagnie'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Contact AT for Privacy'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Contact AT for Privacy Pharmaq - Turkey'),  
            //   new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Contact AT for Privacy - turkey'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Contact AT for Privacy - belgium(french)'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Contact AT for Privacy - belgium(dutch)'),    
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Contact AT for Privacy - italy'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Customer Service Form CS1 - italy'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'Customer Service Form CS3 - italy'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contact', Name = 'VS CO Model 1'),    
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='ZTS_EU_Sample__c', Name = 'Sample AT'),
                new echosign_dev1__Agreement_Template__c(echosign_dev1__Master_Object_Type__c='Contract', Name = 'Contract AT for Privacy')
            }; 
            insert lstAT;
            
        }
    }
    
    private static testMethod void Test_SL_PrepareDocumentForAccount() {
        
        List<Account> lstAccounts = [Select Id,FR_Contract_Template__c
                                     From Account
                                     where name='Test Acc11'];
        
        SL_PrepareDocument.fetchPrepareDocumentURL(lstAccounts[0].Id);
        
        lstAccounts[0].FR_Contract_Template__c = 'Contrat annuel AD RU';
        update lstAccounts[0];
        SL_PrepareDocument.fetchPrepareDocumentURL(lstAccounts[0].Id);
        
        lstAccounts[0].FR_Contract_Template__c = 'Contrat annuel AD EQ';
        update lstAccounts[0];
        SL_PrepareDocument.fetchPrepareDocumentURL(lstAccounts[0].Id);
        
        lstAccounts[0].FR_Contract_Template__c = 'Contrat annuel AD AV';
        update lstAccounts[0];
        SL_PrepareDocument.fetchPrepareDocumentURL(lstAccounts[0].Id);
        
        
       system.assertNotEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstAccounts[0].Id), null);
        
        
        
    }
    
    private static testMethod void Test_SL_PrepareDocumentForSample() {
        
        List<ZTS_EU_Sample__c> lstSamples = [Select Id
                                             From ZTS_EU_Sample__c
                                             Limit 10];
        
        system.assertNotEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstSamples[0].Id), null);
    }
    
    private static testMethod void Test_SL_PrepareDocumentForContactANDContract() {
        
        User intlUser = [SELECT Id FROM User WHERE FirstName = 'IntUser'];
        List<Contact> lstContact = [Select Id
                                    From Contact];
        
        System.runAs(intlUser) {

            try {
                system.assertNotEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContact[0].Id), null);
            }
            catch(Exception e) {
                system.assertEquals(e.getMessage(), 'Script-thrown exception');
            }
            
            echosign_dev1__Agreement_Template__c objAT = [Select Id, echosign_dev1__Master_Object_Type__c From echosign_dev1__Agreement_Template__c Limit 1];
            
            objAT.Name = 'Contact AT for Privacy - canada';
            update objAT;
            
            try {
                system.assertEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContact[0].Id), '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' 
                                    + lstContact[0].Id + '&TemplateId=' + objAT.Id + '&loggedinUser=' + UserInfo.getUserId());
            }
            catch(Exception ex){}
            
            List<Contract> lstContarct = [Select Id
                                          From Contract WHERE ZTS_EU_Market__c != 'United States'];
            try {
                system.assertEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContarct[0].Id), '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' 
                                    + lstContarct[0].Id + '&TemplateId=' + objAT.Id + '&loggedinUser=' + UserInfo.getUserId());
            }
            catch(Exception ex){
                
            }
        }
    }
  public static testMethod void Test_SL_PrepareDocumentForContact1(){
       User intlUser = [SELECT Id FROM User WHERE FirstName = 'IntUser2'];
       List<Contact> lstContacts = [Select id,IT_Contact_Template__c from Contact where FirstName = 'Test C1'];
       List<Contact> lstContact1 = [Select id,Select_Consent_for_eSign__c from Contact where Firstname = 'Test C'];
       test.startTest(); 
       system.runAs(intlUser){
                
       SL_PrepareDocument.fetchPrepareDocumentURL(lstContacts[0].Id);
           
       echosign_dev1__Agreement_Template__c objAT = [Select Id, echosign_dev1__Master_Object_Type__c From echosign_dev1__Agreement_Template__c Limit 1];    
       objAT.Name = 'Customer Service Form CS1 - italy' ;   
           
       try{   
       system.assertEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContact1[0].Id), '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' 
                                    + lstContact1[0].Id + '&TemplateId=' + objAT.Id + '&loggedinUser=' + UserInfo.getUserId());
        }
       catch(Exception ex){}
        
       lstContacts[0].IT_Contact_Template__c = 'Customer Service Form CS1';
       update lstContacts[0];      
        
       SL_PrepareDocument.fetchPrepareDocumentURL(lstContacts[0].Id);
           
       objAT.Name = 'Customer Service Form CS3 - italy';
       update objAT;
       try{   
       system.assertEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContact1[0].Id), '/apex/echosign_dev1__AgreementTemplateProcess?masterId=' 
                                    + lstContact1[0].Id + '&TemplateId=' + objAT.Id + '&loggedinUser=' + UserInfo.getUserId());
        }
        catch(Exception ex){}   
           
       lstContacts[0].IT_Contact_Template__c = 'Customer Service Form CS3';
       update lstContacts[0]; 
       SL_PrepareDocument.fetchPrepareDocumentURL(lstContacts[0].Id); 
       
      
       }   
      
      intlUser.ZTS_EU_Market__c = 'Belgium';
      update intlUser;
      
      System.runAs(intlUser){
      
      lstContact1[0].Select_Consent_for_eSign__c = 'Privacy - FR' ;
      update lstContact1[0];
      SL_PrepareDocument.fetchPrepareDocumentURL(lstContact1[0].id);
      
          
      lstContact1[0].Select_Consent_for_eSign__c = 'Privacy - NL' ;
      update lstContact1[0];
      SL_PrepareDocument.fetchPrepareDocumentURL(lstContact1[0].id);     
      }
      
      intlUser.ZTS_EU_Market__c = 'Turkey';
      update intlUser;
      
      System.runAs(intlUser){
      
      lstContact1[0].Select_Consent_for_eSign__c = 'Privacy - PH' ;
      update lstContact1[0];
      SL_PrepareDocument.fetchPrepareDocumentURL(lstContact1[0].id);
      system.assertNotEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContact1[0].Id), null);    
      }
     Test.stopTest();    
    }
    public static testMethod void Test_SL_PrepareDocumentForContact2(){
        User intlUser = [SELECT Id FROM User WHERE FirstName = 'IntlUser4'];
        List<Contact> lstContacts = [Select id,Select_Consent_for_eSign__c,IT_Contact_Template__c from Contact where FirstName = 'Test C2'];
        test.startTest(); 
        system.runAs(intlUser){
            SL_PrepareDocument.fetchPrepareDocumentURL(lstContacts[0].Id);
            echosign_dev1__Agreement_Template__c objAT = [Select Id, echosign_dev1__Master_Object_Type__c From echosign_dev1__Agreement_Template__c where name ='VS CO Model 1' Limit 1];    
            system.assertEquals(SL_PrepareDocument.fetchPrepareDocumentURL(lstContacts[0].Id), '/apex/echosign_dev1__AgreementTemplateProcess?loggedinUser=' 
                                +UserInfo.getUserId()  + '&masterId=' +lstContacts[0].Id + '&TemplateId=' + objAT.Id + '&common.udd.actions.ActionsUtilORIG_URI=%2Fapex%2Fechosign_dev1__AgreementTemplateProcess');
        }      
        Test.stopTest();    
    }

  
}