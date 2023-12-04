@isTest
public class NOA_NewOnlineAccount_eSign_test 
{
    public static Lead l;
    public static Veterinarian_Information__c v;
    
    static void init()
    {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        l = new Lead(Do_you_have_a_licensed_veterinarian__c = 'Yes',Company = 'test Company', Salutation = 'Mr.',FirstName = 'Test_F',
                     LastName = 'Test_L',Email='a@a.com',Phone='123',Business_Name__c = 'Test BN',
                     Customer_Type__c = 'University',Small_Animal__c = 12.00 , Billing_Street_1__c = 'B_ST_1',Billing_Street_2__c = 'B_ST_2',
                     Billing_City__c = 'test-city',Billing_County__c = 'test-county',Billing_State__c = 'Indiana',Billing_Zip_Code__c='B123',
                     Billing_Phone__c = '231564879',Billing_Fax__c = '215498',Billing_Email__c = 'a@a.com',Shipping_Street_1__c = 's1',
                     Shipping_Street_2__c = 's2',Shipping_County__c = 'test_county',Shipping_City__c = 'test_city',Shipping_State__c = 'Indiana',
                     Shipping_Zip_Code__c = 's213',Shipping_Phone__c = '21354879',Shipping_Fax__c = '21354987',Shipping_Email__c = 'a@b.com',
                     Existing_account_with_Zoetis_at_this_Loc__c = 'No',Ownership_Change__c = 'No',Existing_account_with_Zoetis__c = 'No',
                     Sales_Tax_Status__c = 'Charge tax',RecordTypeID = recTypeId,Ownership_Type__c = 'Sole-proprietorship',SP_Name__c = 'SP test',
                     SP_Telephone__c = '213458',SP_Email__c = 'a@test.com',SP_Fax__c = '21356879',SP_Address__c = 'Add_Test',SP_County__c = 'testC',
                     SP_City__c = 'Test',SP_State__c = 'Indiana',SP_Zip__c = 'ZP213',Principal_Bank_Name__c = 'test bank',Total_number_of_practitioners__c=23,
                     Principal_Bank_Phone__c = '213546879',Trade_Reference_1_Company_Name__c = 'C1',Trade_Reference_1_Company_Phone__c = '21546879',
                     Trade_Reference_2_Company_Name__c = 'C2',Trade_Reference_2_Company_Phone__c = '21546879',Trade_Reference_3_Company_Name__c = 'C3',
                     Trade_Reference_3_Company_Phone__c = '2154689',Contact_Preference__c = 'Email',Authorization_Email__c = 'z@z.com');
        Insert l; 
            
        v = new Veterinarian_Information__c (Veterinarian_First_Name__c = 'test v_first',Veterinarian_Last_Name__c = 'test v_last',Primary__c=True,
                                             Veterinarian_Email__c = 'a@test.com',State_License__c = 'test SL',DEA__c = 'a_DEA',
                                             Veterinarian_Role__c = 'Staff',Delete_Record__c = False,Lead__c = l.ID);
        Insert v;   

        echosign_dev1__SIGN_Data_Mapping__c objDM = new echosign_dev1__SIGN_Data_Mapping__c(Name = 'NOALeadDM'); 
        Insert objDM;
    }
    
    static testMethod void testESign()
    {
        init();
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        //test.starttest();
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        //Test.setMock(HttpCalloutMock.class, new NOA_eSignMock());
        noa.adobeSendForSignature();
        noa.saveNewOnlineAccount();
        //test.stopTest();  
    }
    
    static testmethod void testEsign1()
    {
        init();
        l.Ownership_Type__c='Partnership';
        update l;
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.adobeSendForSignature();
        noa.saveNewOnlineAccount();
    }
    
    static testmethod void testEsign2()
    {
        init();
        l.Ownership_Type__c='Corporation';
        update l;
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.adobeSendForSignature();
        noa.saveNewOnlineAccount();
    }
    
    static testmethod void testEsign3()
    {
        init();
        l.Ownership_Type__c=Null;
        update l;
        PageReference pageRef = Page.NOA_ReviewAndSubmit;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        NOA_NewOnlineAccount noa = new NOA_NewOnlineAccount(sc);
        noa.adobeSendForSignature();
        noa.saveNewOnlineAccount();
    }
}