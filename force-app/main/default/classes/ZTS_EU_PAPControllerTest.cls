/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_PAPControllerTest
* Description   :  This is the test class for the class: ZTS_EU_PAPController.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4th-May-15   Shreyas             Created the class.

********************************************************************************************************************************************/
@isTest(SeeAllData = false)
Public class ZTS_EU_PAPControllerTest{

    @TestSetup
    static void makeData()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();    
    }
    public static testMethod void testMethod1(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
            ZTS_EU_Species_Product__c tgRec = new ZTS_EU_Species_Product__c();
            tgRec.Name = 'TestTG';
            tgRec.RecordTypeId = tgTypeId;
            tgRec.ZTS_EU_Market__c = 'Brazil';
            tgRec.ZTS_EU_Type__c = 'Therapeutic Group';
            tgRec.ZTS_EU_Is_Active__c = true;
            insert tgRec;
            
            String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
            ZTS_EU_Species_Product__c brandRec = new ZTS_EU_Species_Product__c();
            brandRec.Name = 'Testbrand';
            brandRec.RecordTypeId = brandTypeId;
            brandRec.ZTS_EU_Market__c = 'Brazil';
            brandRec.ZTS_EU_Type__c = 'Brand';
            brandRec.ZTS_EU_Is_Active__c = true;
            brandRec.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
            insert brandRec;
            
            ZTS_EU_Brand_Indication__c bi = new ZTS_EU_Brand_Indication__c();
            bi.Name = 'Test BI';
            bi.ZTS_EU_Product__c = brandRec.Id;
            bi.Market__c = 'United Kingdom';
            insert bi;
            
            ZTS_EU_Product_Barrier__c pb = new ZTS_EU_Product_Barrier__c();
            pb.Name = 'test pb';
            pb.ZTS_EU_Brand_Indication__c = bi.Id;
            insert pb;
            
            ZTS_EU_Competitor_Product__c cp = new ZTS_EU_Competitor_Product__c();
            cp.name = 'Test cp';
            //cp.ZTS_EU_Brand_Indication__c = bi.Id;
            insert cp;
            
            
            
            List<Contact> contList = ZTS_EU_DataUtilityTest1.createContactRecord(1);
            insert contList;
            
            ZTS_EU_Product_Adoption_Profile__c pap = new ZTS_EU_Product_Adoption_Profile__c();
            pap.ZTS_EU_Contact__c = contList[0].Id;
            pap.ZTS_EU_Brand_Indication__c = bi.Id;
            pap.ZTS_EU_Competitor_Product__c = cp.Id;
            pap.ZTS_EU_Product_Barrier__c = pb.Id;
            pap.ZTS_EU_Usage__c = 'Advocate';
            insert pap;
            
            test.startTest();
            
            PageReference pgRef = Page.ZTS_EU_PAP;
            Test.setCurrentPage(pgRef);
            
            // edit mode
            System.currentPageReference().getParameters().put('Id', pap.Id);
            System.currentPageReference().getParameters().put('mode', 'edit');
            System.currentPageReference().getParameters().put('biId', bi.Id);
            System.currentPageReference().getParameters().put('field', 'field_pb');
            apexpages.standardcontroller std = new apexpages.standardcontroller(pap);
            ZTS_EU_PAPController obj1_std = new ZTS_EU_PAPController(std);
            
            ZTS_EU_PAPController obj1 = new ZTS_EU_PAPController();
            obj1.editPAP();
            
            obj1.getDetails();
            obj1.redirectToNewPAPrecord();
            obj1.redirectToEditPAPrecord();
            
            obj1.papId = pap.Id;
            obj1.savePAP();
            
            
            // new mode
            PageReference pgRef2 = Page.ZTS_EU_PAP;
            Test.setCurrentPage(pgRef2);
            System.currentPageReference().getParameters().put('Id', null);
            System.currentPageReference().getParameters().put('mode', 'new');
            apexpages.standardcontroller std2 = new apexpages.standardcontroller(pap);
            ZTS_EU_PAPController obj2_std = new ZTS_EU_PAPController(std2);
            obj2_std.savePAP();
            
            // clone
            PageReference pgRef3 = Page.ZTS_EU_PAP;
            Test.setCurrentPage(pgRef3);
            System.currentPageReference().getParameters().put('clone', '1');
            System.currentPageReference().getParameters().put('parentId', pap.Id);
            apexpages.standardcontroller std3 = new apexpages.standardcontroller(pap);
            ZTS_EU_PAPController obj3_std = new ZTS_EU_PAPController(std3);
            
            // product barrier lookup
            PageReference pgRef4 = Page.ZTS_EU_PAP;
            Test.setCurrentPage(pgRef4);
            System.currentPageReference().getParameters().put('biId', bi.Id);
            System.currentPageReference().getParameters().put('field', 'field_cp');
            ZTS_EU_PAPController obj2 = new ZTS_EU_PAPController();
            
            
            test.stopTest();
        }
    }

    @isTest
    private static void lightningCancel_noVariables_hasRequiredUrlAndRedirect() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            ZTS_EU_PAPController testController = new ZTS_EU_PAPController();

            Test.startTest();
            PageReference testPageReference = testController.lightningCancel();
            Test.stopTest();

            System.assertEquals('/lightning/page/home', testPageReference.getUrl(), 
                'Expected the Lightning Home page but instead got: ' + testPageReference.getUrl());
            System.assert(testPageReference.getRedirect(), 
                'Expected the page reference to redirect, but the redirect was set to false.');
        }
    }
}