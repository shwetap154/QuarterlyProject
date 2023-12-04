/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_OrderUtility_Test
* Description   :  Test Class for class ZTS_EU_OrderUtility

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     8th-July-15   Shreyas             Created the class.

********************************************************************************************************************************************/


@isTest (SeeAllData = false)
public class ZTS_EU_OrderUtility_Test {
    
    static testMethod void Method1(){
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
            accList[1].ZTS_EU_VAT_Code__c = 'TestVATCode';
            accList[1].ZTS_EU_District__c = 'District 1';
            insert accList;
            
            //Create SKU Product Hierarchy record
            
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec = new ZTS_EU_Species_Product__c();
            tgRec.Name = 'TestTG';
            tgRec.RecordTypeId = tgTypeId;
            tgRec.ZTS_EU_Market__c = 'United Kingdom';
            tgRec.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec.ZTS_EU_Is_Active__c = true;
            tgRec.ZTS_US_Abaxis_Orderable__c = true;
            insert tgRec;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec = new ZTS_EU_Species_Product__c();
            brandRec.Name = 'Testbrand';
            brandRec.RecordTypeId = brandTypeId;
            brandRec.ZTS_EU_Market__c = 'United Kingdom';
            brandRec.ZTS_EU_Type__c = 'Brand';
            brandRec.ZTS_EU_Is_Active__c = true;
            brandRec.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
            brandRec.ZTS_US_Abaxis_Orderable__c = true;
            insert brandRec;
            
            String MPGTypeId = [Select Id from RecordType where DeveloperName = 'MPG'].Id;
            ZTS_EU_Species_Product__c mpgRec = new ZTS_EU_Species_Product__c();
            mpgRec.Name = 'TestMPG';
            mpgRec.RecordTypeId = MPGTypeId;
            mpgRec.ZTS_EU_Market__c = 'United Kingdom';
            mpgRec.ZTS_EU_Type__c = 'MPG';
            mpgRec.ZTS_EU_Is_Active__c = true;
            mpgRec.ZTS_EU_Parent_Species_Product__c = brandRec.Id;
            mpgRec.ZTS_US_Abaxis_Orderable__c = true;
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
            skuRec.ZTS_US_Abaxis_Orderable__c = true;
            insert skuRec;
            
            Call__c call = new Call__c();
            call.ZTS_EU_Account__c = accList[0].Id;
            call.Name = 'Test Call';
            dateTime dt = system.now();
            call.ZTS_EU_Sub_Type__c = 'Order';
            call.ZTS_EU_Start_Date_Time__c = dt+3;
            call.ZTS_EU_End_Date_Time__c = dt+4;
            call.ZTS_EU_Status__c = 'Planned';
            call.ZTS_EU_Duration__c = '0.5 Hour';
            insert call;
            
            Orders__c o = new Orders__c();
            o.ZTS_EU_Account__c = accList[0].Id;
            o.Call__c = call.Id;
            o.Product__c = skuRec.Id;
            o.ZTS_EU_Dealer_Distributor__c = accList[1].Id;
            o.ZTS_EU_Approval_Status__c = 'Approved';
            //Added by priya - INC0449142
            o.Quantity__c = 4;
            insert o;
            List<Order_Detail__c> ordlst = new List<Order_Detail__c>();
            Order_Detail__c od = new Order_Detail__c();
            od.ZTS_EU_Order__c = o.Id;
            od.ZTS_EU_Quantity__c = 2;
            od.ZTS_EU_Species_Product__c = skuRec.Id;
            ordlst.add(od);
            insert ordlst;
            //ZTS_EU_OrderUtility.restrictOrderDetailDelete(ordlst);
            // delete ordlst;
            
            //  delete o;
        }
    }
}