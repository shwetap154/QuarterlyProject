@isTest
public class SL_SalesTacticSegmentationControllerTest {
    
    @testSetup 
    static void test_SetUp() {
        
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        System.runAs(intlUsr) {
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            
            Account objAccount = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert objAccount;
            
            ZTS_EU_Species_Product__c sp = new ZTS_EU_Species_Product__c(Name = 'Animales Compania', ZTS_EU_Type__c = 'Business Unit',
            ZTS_EU_Is_Active__c = true, ZTS_EU_Business_Unit_Abbr__c = 'CA',
            ZTS_EU_Market__c = 'United Kingdom');
            insert sp;
            
            ZTS_EU_Species__c species = new ZTS_EU_Species__c(Name = 'Gatos', ZTS_EU_Business_Unit__c = sp.Id, ZTS_EU_Market__c = 'United Kingdom',
            ZTS_EU_Species__c = 'Gatos');
            insert species;
            
            ZTS_EU_Account_Species_Potential__c asp = new ZTS_EU_Account_Species_Potential__c(Account__c = objAccount.Id, ZTS_EU_Species_Potential__c = species.Id);
            insert asp;
            
            ZTS_EU_Sales__c sales = new ZTS_EU_Sales__c(ZTS_EU_Account__c = objAccount.Id, ZTS_EU_Product__c = sp.Id,
            ZTS_EU_Date__c = Date.today());
            insert sales;
            
            
            Sales_Tactic__c objST = new Sales_Tactic__c(Market__c = 'Mexico', BU_Abbrv__c = 'CA',
            Penetration_Threshold__c = 15, Potential_Threshold__c = 10000);
            Sales_Tactic__c objST1 = new Sales_Tactic__c(Market__c = 'Mexico', BU_Abbrv__c = 'EQ',
            Penetration_Threshold__c = 15, Potential_Threshold__c = 10000);
            insert objST;
            insert objST1;
            
            ZTS_EU_Exception_Potential_Calculation__c expc = new ZTS_EU_Exception_Potential_Calculation__c(Name ='Mexico',ZTS_EU_Market__c='United Kingdom',
            ZTS_EU_Potential_Fields_to_Sum_up__c='CA',
            ZTS_EU_BU__c='EQ');
            insert expc;
        }
    }
    
    private static testMethod void Test_SalesTacticSegmentation() {
        
        List<Account> lstAccounts = [Select Id
        From Account
        Limit 1];
        
        SL_SalesTacticSegmentationController.fetchSegmentationData(lstAccounts[0].Id);
    }
}