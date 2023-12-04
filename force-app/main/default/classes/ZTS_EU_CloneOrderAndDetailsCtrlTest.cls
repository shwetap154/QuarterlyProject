/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_CloneOrderAndDetailsCtrlTest
* Description   :  This is the test class for the class: ZTS_EU_CloneOrderAndDetailsController.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     24th-Jul-15   Shreyas             Created the class.

********************************************************************************************************************************************/

@isTest(SeeAllData = false)
Public class ZTS_EU_CloneOrderAndDetailsCtrlTest{
    public static testMethod void testMethod1()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<Account> accList =new List<Account>() ;
            accList = ZTS_EU_DataUtilityTest1.createAccountRecord(2);
            accList[1].type = 'Distributor';
            insert accList;
            
            //Create SKU Product Hierarchy record
            
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec = new ZTS_EU_Species_Product__c();
            tgRec.Name = 'TestTG';
            tgRec.RecordTypeId = tgTypeId;
            tgRec.ZTS_EU_Market__c = 'United Kingdom';
            tgRec.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec.ZTS_EU_Is_Active__c = true;
            insert tgRec;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec = new ZTS_EU_Species_Product__c();
            brandRec.Name = 'Testbrand';
            brandRec.RecordTypeId = brandTypeId;
            brandRec.ZTS_EU_Market__c = 'United Kingdom';
            brandRec.ZTS_EU_Type__c = 'Brand';
            brandRec.ZTS_EU_Is_Active__c = true;
            brandRec.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
            insert brandRec;
            
            String MPGTypeId = [Select Id from RecordType where DeveloperName = 'MPG'].Id;
            ZTS_EU_Species_Product__c mpgRec = new ZTS_EU_Species_Product__c();
            mpgRec.Name = 'TestMPG';
            mpgRec.RecordTypeId = MPGTypeId;
            mpgRec.ZTS_EU_Market__c = 'United Kingdom';
            mpgRec.ZTS_EU_Type__c = 'MPG';
            mpgRec.ZTS_EU_Is_Active__c = true;
            mpgRec.ZTS_EU_Parent_Species_Product__c = brandRec.Id;
            insert mpgRec;
            
            String skuRecTypeId = [Select Id from RecordType where DeveloperName = 'SKU'].Id;
            ZTS_EU_Species_Product__c skuRec = new ZTS_EU_Species_Product__c();
            skuRec.Name = 'TestSKU';
            skuRec.RecordTypeId = skuRecTypeId;
            skuRec.ZTS_EU_Create_Samples__c = true;
            skuRec.ZTS_EU_Market__c = 'United Kingdom';
            skuRec.ZTS_EU_Type__c = 'SKU';
            skuRec.ZTS_EU_Is_Old__c = true;
            skuRec.ZTS_EU_Is_Active__c = true;
            skuRec.ZTS_EU_Is_Orderable__c = True;
            skuRec.ZTS_EU_Parent_Species_Product__c = mpgRec.Id;
            skuRec.ZTS_EU_is_Samplable__c = true;
            skuRec.ZTS_EU_Standard_Price__c = 100;
            insert skuRec;
            
            Call__c call = new Call__c();
            call.ZTS_EU_Account__c = accList[0].Id;
            call.Name = 'Test Call';
            dateTime dt = system.now();
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Start_Date_Time__c = dt+3;
            call.ZTS_EU_End_Date_Time__c = dt+4;
            call.ZTS_EU_Status__c = 'Planned';
            call.ZTS_EU_Duration__c = '0.5 Hour';
            insert call;
            
            Orders__c o = new Orders__c();
            o.ZTS_EU_Account__c = accList[0].Id;
            o.ZTS_EU_Status__c = 'New';
            o.Call__c = call.Id;
            o.Product__c = skuRec.Id;
            o.ZTS_EU_Dealer_Distributor__c = accList[1].Id;
            insert o;
            
            Order_Detail__c od = new Order_Detail__c();
            od.ZTS_EU_Order__c = o.Id;
            od.ZTS_EU_Quantity__c = 2;
            od.ZTS_EU_Species_Product__c = skuRec.Id;
            insert od;
            
            PageReference pageRef = Page.ZTS_EU_CloneOrderAndDetails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('orderId', o.Id);
            ApexPages.currentPage().getParameters().put('cloneFlag', o.Id);
            
            ZTS_EU_CloneOrderAndDetailsController obj1 = new ZTS_EU_CloneOrderAndDetailsController();
            obj1.cloneOrderAndOrderDetails();
        }
    }
}