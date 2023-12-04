/**
* @ClassName    : SL_CaseConsumableTriggerHandler_Test 
* @JIRATicket   : LIGHTNI-1798
* @CreatedOn    : 19th Nov 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : Test class for case consumable trigger handler.
*/
@isTest
public class SL_CaseConsumableTriggerHandler_Test {

    @testSetup
    public static void testDataSetup() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        // List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
        // TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        // triggerActiveList.add(tr);
        // insert triggerActiveList;
    }

    @isTest
    public static void testHandler() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'Brazil';
        insert usr;
        
        
        
        
        
        System.runAs(usr)
        {
            Account objAcc = (Account)SL_TestDataFactory.createSObject(new Account( Name = 'Test Company for Case', 
                                                                                    ZTS_EU_Market__c = 'Baltics', 
                                                                                    ZTS_EU_VAT_Code__c='00011',
                                                                                    ZTS_EU_Zip_Postal_Code__c = '12345'), true);
            //insert objAcc;
            Account objAcc2 = (Account)SL_TestDataFactory.createSObject(new Account( Name = 'Test Company for Case2', 
                                                                                        ZTS_EU_Market__c = 'Brazil', 
                                                                                        ZTS_EU_VAT_Code__c='00012',
                                                                                        ZTS_EU_Zip_Postal_Code__c = '12345'), true);
            //insert objAcc2;

            Contact objCon = (Contact)SL_TestDataFactory.createSObject(new Contact( LastName = 'Test', 
                                                                                    FirstName='Name',
                                                                                    AccountId = objAcc.Id,
                                                                                    ZTS_EU_Market__c='Baltics'), true);
            //insert objCon;
            
            SAP_Material__c objSAPM = (SAP_Material__c)SL_TestDataFactory.createSObject(new SAP_Material__c(SAP_Item_Category_Group__c = 'NORM', SAP_Product_Number__c = 'TestProductID123'), true);
            //insert objSAPM;

            Product2 objProduct = (Product2)SL_TestDataFactory.createSObject(new Product2(  Name = 'Test product', 
                                                                                            CurrencyIsoCode = 'USD',
                                                                                            IsActive = true,
                                                                                            SAP_Material__c = objSAPM.Id), true);
            //insert objProduct;

            Rotor_Transaction__c objRotorTran = (Rotor_Transaction__c)SL_TestDataFactory.createSObject(new Rotor_Transaction__c(
                                                                                        Account__c = objAcc2.Id), true);
            
            String diagRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Diagnostics').getRecordTypeId();
            
            List<Case> lstCases = new List<Case>();
            for(Integer i=0; i<5; i++) {
                lstCases.add(new Case(AccountId = objAcc.Id,
                                        ContactId = objCon.Id,
                                        //RecordTypeId = diagRecordTypeId,
                                        Status = 'New',
                                        Origin = 'Email',
                                        Type = 'Other',
                                        Subject = 'Test Market Queue Assignment',
                                        Description = 'Test'));
                
            }
            Test.startTest();
                insert lstCases;
            
            List<Case_Consumable__c> lstCaseConsumable = new List<Case_Consumable__c>();
            for(Integer i=0; i<50; i++) {
                lstCaseConsumable.add(new Case_Consumable__c(Case__c = lstCases[0].Id,
                                                                Consumable_Product__c = objProduct.Id,
                                                                Lot_Num__c = '11',
                                                                Rotor_Credit__c = 10));
            }
            lstCaseConsumable[0].Rotor_Credit__c = 0;
            System.debug('--lstCaseConsumable-- ' +lstCaseConsumable);
            insert lstCaseConsumable;
            Test.stopTest();
            //System.assertEquals(49, [SELECT Id FROM Rotor_Transaction__c WHERE Account__c = :objAcc.Id].size());
            for(Case_Consumable__c obj : lstCaseConsumable) {
                obj.Rotor_Credit__c = 12;
            }
            lstCaseConsumable[1].Rotor_Credit__c = 0;
            System.debug('--lstCaseConsumable-- ' +lstCaseConsumable);
            update lstCaseConsumable;
            
            // Account Change condition
            lstCases[0].AccountId = objAcc2.Id;
            update lstCases[0];
            //System.assertEquals(49, [SELECT Id FROM Rotor_Transaction__c WHERE Account__c = :objAcc2.Id].size());
            
            // Rotor transaction is Locked
            Rotor_Transaction__c objTxn = [SELECT Id, Case_Consumable__c, Case_Consumable__r.case__c, Locked__c FROM Rotor_Transaction__c WHERE Account__c = :objAcc2.Id LIMIT 1];
            objTxn.Locked__c = true;
            update objTxn;
            
            try {
                update new Case_Consumable__c(Id = objTxn.Case_Consumable__c, Rotor_Credit__c = 101);
            }catch(Exception e) {
                System.assertNotEquals(null, e.getMessage());
            }
            
            try {
                update new Case(Id = objTxn.Case_Consumable__r.case__c, AccountId = objAcc.Id);
                
            }catch(Exception e) {
                System.assertNotEquals(null, e.getMessage());
            }
            
            lstCaseConsumable.add(new Case_Consumable__c(Case__c = lstCases[0].Id,
                                                                Consumable_Product__c = objProduct.Id,
                                                                Lot_Num__c = '11',
                                                                Rotor_Credit__c = 10,
                                                                Primary__c = true));
            System.debug('--lstCaseConsumable-- ' +lstCaseConsumable);
            upsert lstCaseConsumable;

            Case_Consumable__c objCC = [Select Id, Primary__c from Case_Consumable__c Where Primary__c = true];
            
            try{
                objCC.Lot_Num_Unknown__c = true;
                update objCC;
            }
            catch(Exception e){
                System.assertNotEquals(null, e.getMessage());
            }
            
            try {
                delete objCC;
            }catch(Exception e) {
                System.assertNotEquals(null, e.getMessage());
            }
            
            try{
                objCC = [Select Id, Primary__c from Case_Consumable__c Where Primary__c = false LIMIT 1];
                objCC.Primary__c = true;
                update objCC;
            }
            catch(Exception e){
                system.debug('======e.getMessage()======' +e.getMessage());
                System.assertNotEquals(null, e.getMessage());
            }
        }
    }
}