/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AssignContractTemplateCtrlTest
* Description   :  This is the test class for the class: ZTS_EU_AssignContractTemplateController.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4th-Jan-15   Shreyas             Created the class.

********************************************************************************************************************************************/
@isTest (SeeAllData=false)
public class ZTS_EU_AssignContractTemplateCtrlTest{
    
    
    public static testMethod void testMethod1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        insertCustomSettings();
        
        System.runAs(usr)
        {
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);
            accList[0].Name = 'TestAccount';
            accList[0].ZTS_EU_Market__c = 'United Kingdom';            
            insert accList;
            
            Account a = new Account();
            a = [Select Id, Name from Account  where Id =: accList[0].Id AND ZTS_EU_Market__c != 'United States'];
            
            List<ZTS_EU_ContractTemplate__c> ctList = ZTS_EU_DataUtilityTest1.createContractTemplateRecord(1);
            ctList[0].Name = 'TestTemplate';
            insert ctList;
            
            ZTS_EU_ContractTemplate__c ct = new ZTS_EU_ContractTemplate__c();
            ct = [Select Id, Name, ZTS_EU_Discount__c from ZTS_EU_ContractTemplate__c where Id =: ctList[0].Id];
            
            
            PageReference pageRef = Page.ZTS_EU_AssignContractTemplate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('accId', accList[0].Id);
            ZTS_EU_AssignContractTemplateController obj1 = new ZTS_EU_AssignContractTemplateController();
            
            obj1.assignContractTemplate();
            string urlTest = obj1.assignContractTemplate().getUrl();
            
            string url = '/800/e?' + System.Label.ZTS_EU_Discount + '=' + ct.ZTS_EU_Discount__c;
            url = url + '&' + System.Label.ZTS_EU_CTLookupName + '=' + ct.Name;
            url = url + '&' + System.Label.ZTS_EU_CTLookupId+ '=' + ct.Id;
            url = url + '&clone=1';
            url = url + '&ctrc7=' + a.Name;
            url = url + '&ctrc7_lkid=' + a.Id;
            
            System.assertNotEquals(null,urlTest);
        }
    }
    
    private static void insertCustomSettings()
    {
        ZTS_EU_Field_ID__c record1 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_TemplateName_Id' );
        record1.Description__c = 'This field Stores the Template field Id of Contract Page layout';
        record1.ZTS_EU_ID__c = 'CF00NF000000CtQq0';
        
        ZTS_EU_Field_ID__c record2 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_Template_Id' );
        record2.Description__c = 'This field Stores the Template lookup field Id of Contract Page layout';
        record2.ZTS_EU_ID__c = 'CF00NF000000CtQq0_lkid';
        
        ZTS_EU_Field_ID__c record3 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_BUName_Id' );
        record3.Description__c = 'This field Stores the Business Unit field Id of Contract Page layout';
        record3.ZTS_EU_ID__c = 'CF00NF000000CtQpt';
        
        ZTS_EU_Field_ID__c record4 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_BU_Id' );
        record4.Description__c = 'This field Stores the Business Unit lookup field Id of Contract Page layout';
        record4.ZTS_EU_ID__c = 'CF00NF000000CtQpt_lkid';
        
        ZTS_EU_Field_ID__c record5 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_Type_Id' );
        record5.Description__c = 'This field Stores the Type field Id of Contract Page layout';
        record5.ZTS_EU_ID__c = '00NF000000CtQq2';
        
        ZTS_EU_Field_ID__c record6 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_DiscountType_Id' );
        record6.Description__c = 'This field Stores the Discount Type field Id of Contract Page layout';
        record6.ZTS_EU_ID__c = '00NF000000CtQpv';
        
        ZTS_EU_Field_ID__c record7 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_Discount_Id' );
        record7.Description__c = 'This field Stores the Discount field Id of Contract Page layout';
        record7.ZTS_EU_ID__c = '00NF000000CtQpw';
        
        ZTS_EU_Field_ID__c record8 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_EndDate_Id' );
        record8.Description__c = '	This field Stores the EndDate field Id of Contract Page layout';
        record8.ZTS_EU_ID__c = '00NF000000CtQpx';
        
        ZTS_EU_Field_ID__c record9 = new ZTS_EU_Field_ID__c(Name = 'ZTS_EU_Contract_FiscalYear_Id' );
        record9.Description__c = 'This field Stores the FiscalYear field Id of Contract Page layout';
        record9.ZTS_EU_ID__c = '00NF000000CtQpy';
        
        insert new List<ZTS_EU_Field_ID__c>{record1, record2, record3, record4, record5, record6, record7, record8, record9};    
        
    }
}