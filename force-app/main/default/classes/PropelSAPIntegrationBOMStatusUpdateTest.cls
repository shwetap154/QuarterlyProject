@isTest
public with sharing class PropelSAPIntegrationBOMStatusUpdateTest {
    static void SetUpData(){
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        
        //Item Lifecycle and Related
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(name='Assembly', PDLM__primary_key__c = 'Assembly');
        insert lifecycleItem;

        PDLM__Phase__c firstPhase = new PDLM__Phase__c(Name='Prototype', PDLM__order__c = 1, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id, 
                                                        PDLM__Next_Phases__c = '["Discontinue Production", "Production"]');
        phasesToInsert.add(firstPhase);

        PDLM__Phase__c secondPhase = new PDLM__Phase__c(Name='Production', PDLM__order__c = 2, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id, PDLM__Next_Phases__c = '["Discontinue Production"]');
        phasesToInsert.add(secondPhase);

        PDLM__Phase__c thirdPhase = new PDLM__Phase__c(Name='Discontinue Production', PDLM__order__c = 3, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id);
        phasesToInsert.add(thirdPhase);

        insert phasesToInsert;
        
        PDLM__Autonumber__c autonumberItem = new PDLM__Autonumber__c(Name='Autonumber for Part', PDLM__prefix__c = 'PART-', 
                                                                        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberItem;

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Parts', PDLM__autonumber__c = autonumberItem.id, 
                                                                        PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        insert categoryForPartItem;

        Propel_Lookup_Table__c mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected');

        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Create Paretnt Item and Item Revision
        PDLM__Item__c parentItemSap = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItemSap;
        PDLM__Item_Revision__c parentItemSapRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSap.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItemSapRev);

        Base_Unit_of_Measure__c base_uom = new Base_Unit_of_Measure__c(Name = 'EA - Each');
        insert base_uom;

        PDLM__Item__c childItem1 = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH', Base_UOM_Descriptive__c = base_uom.Id);
        insert childItem1;
        PDLM__Item_Revision__c childItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1.Id, 
                                                                                       PDLM__Revision__c = 'A',
                                                                                       PDLM__Lifecycle_Phase__c = 'Production',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       PDLM__Released__c = true,
                                                                                       PDLM__Released_Date__c = date.today().addDays(-1),
                                                                                       PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        revsListToInsert.add(childItem1Rev);

        PDLM__Item__c childItem2 = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert childItem2;
        PDLM__Item_Revision__c childItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem2.Id, 
                                                                                       PDLM__Revision__c = 'A',
                                                                                       PDLM__Lifecycle_Phase__c = 'Prototype',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       PDLM__Released__c = true,
                                                                                       PDLM__Released_Date__c = date.today().addDays(-1),
                                                                                       PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        revsListToInsert.add(childItem2Rev);

        insert revsListToInsert;

        List<PDLM__Assembly__c> assListToInsert = new List<PDLM__Assembly__c>();

        ass1 = new PDLM__Assembly__c(PDLM__Item__c = childItem1.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass1);

        ass2 = new PDLM__Assembly__c(PDLM__Item__c = childItem2.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass2);

        insert assListToInsert;
    }

    static PDLM__Assembly__c ass1;
    static PDLM__Assembly__C ass2;

    @isTest public static void validStatusSync() {
        SetUpData();

        Test.startTest();

        List<SAP_BOM_Status_Event__e> events = new List<SAP_BOM_Status_Event__e>();

        SAP_BOM_Status_Event__e event1 = new SAP_BOM_Status_Event__e(Rev_Record_Id__c = ass1.PDLM__Item_Revision__c, SAP_BOM_Interface_Status__c = 'In Process');
        events.add(event1);

        SAP_BOM_Status_Event__e event2 = new SAP_BOM_Status_Event__e(Rev_Record_Id__c = ass2.PDLM__Item_Revision__c, SAP_BOM_Interface_Status__c = 'Completed');
        events.add(event2);
        List<Database.SaveResult> srs = Eventbus.publish(events);

        Test.stopTest();

        PDLM__Item_Revision__c rev = [SELECT Id, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c WHERE Id = :event1.Rev_Record_Id__c or Id = :event2.Rev_Record_Id__c];
        System.assertEquals('In Process', rev.SAP_BOM_Interface_Status__c);
    }

    @isTest public static void invalidStatusSync() {
        SetUpData();

        Test.startTest();

        List<SAP_BOM_Status_Event__e> events = new List<SAP_BOM_Status_Event__e>();

        SAP_BOM_Status_Event__e event1 = new SAP_BOM_Status_Event__e(Rev_Record_Id__c = ass1.PDLM__Item_Revision__c, SAP_BOM_Interface_Status__c = 'In Progress');
        events.add(event1);

        SAP_BOM_Status_Event__e event2 = new SAP_BOM_Status_Event__e(Rev_Record_Id__c = ass2.PDLM__Item_Revision__c, SAP_BOM_Interface_Status__c = 'Completed');
        events.add(event2);
        List<Database.SaveResult> srs = Eventbus.publish(events);

        Test.stopTest();

        PDLM__Item_Revision__c rev = [SELECT Id, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c WHERE Id = :event1.Rev_Record_Id__c or Id = :event2.Rev_Record_Id__c];
        System.assertEquals(1, srs[0].getErrors().size());
    }
}