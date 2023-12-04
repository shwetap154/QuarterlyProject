@isTest
public with sharing class PropelSAPIntClearFailedStatusesTest {
    static void SetUpData(){
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        
        //ECO Lifecycle and related
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'ECO');
        insert lifecycle;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(pendingPhase);

        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
                                                        PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(CCBPhase);

        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Released', PDLM__order__c = 3, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(approvedPhase);

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(Name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', 
                                                                        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__autonumber__c = autonumberChange.id, 
                                                                    PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        insert categoryForChange;

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

        change = new PDLM__Change__c(Name = 'ECO-000001', PDLM__Category__c = categoryForChange.Id, PDLM__Title__c='Test SAP ECO');
        insert change;

        Propel_Lookup_Table__c mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected');

        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Create Paretnt Item and Item Revision
        PDLM__Item__c parentItemSap = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItemSap;
        parentItemSapRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSap.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      SAP_BOM_Interface_Status__c = 'In Process',
                                                      SAP_Material_Interface_Status__c = 'In Process',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItemSapRev);

        PDLM__Item__c parentItemSap2 = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItemSap2;
        parentItemSap2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSap2.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      SAP_BOM_Interface_Status__c = 'In Process',
                                                      SAP_Material_Interface_Status__c = 'In Process',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItemSap2Rev);

        insert revsListToInsert;

        List<PDLM__Affected_Item__c> aisListToInsert = new List<PDLM__Affected_Item__c>();

        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        aisListToInsert.add(ai1);

        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItemSap2Rev.Id);
        aisListToInsert.add(ai2);

        insert aisListToInsert;

        List<SAP_BOM_Interface_Status__c> statuses = new List<SAP_BOM_Interface_Status__c>();
        status1 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItemSapRev.Id, Site__c = 'US45:01:01', SAP_BOM_Interface_Status__c = 'In Process');
        statuses.add(status1);

        status2 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItemSapRev.Id, Site__c = 'RU00:03:01', SAP_BOM_Interface_Status__c = 'In Process');
        statuses.add(status2);

        status3 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItemSap2Rev.Id, Site__c = 'US45:01:01', SAP_BOM_Interface_Status__c = 'In Process');
        statuses.add(status3);

        status4 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItemSap2Rev.Id, Site__c = 'RU00:03:01', SAP_BOM_Interface_Status__c = 'In Process');
        statuses.add(status4);

        insert statuses;
    }

    static PDLM__Item_Revision__c parentItemSapRev;
    static PDLM__Item_Revision__c parentItemSap2Rev;
    static SAP_BOM_Interface_Status__c status1;
    static SAP_BOM_Interface_Status__c status2;
    static SAP_BOM_Interface_Status__c status3;
    static SAP_BOM_Interface_Status__c status4;
    static PDLM__Change__c change;

    @isTest public static void noChanges(){
        SetUpData();

        test.startTest();

        change.PDLM__Approved__c = true;
        update change;

        SAP_Material_BOM_Status_Clear_Event__e event1 = new SAP_Material_BOM_Status_Clear_Event__e(Change_Id__c = change.Id, Status_to_Set__c = 'Material and BOM');
        SAP_Material_BOM_Status_Clear_Event__e event2 = new SAP_Material_BOM_Status_Clear_Event__e(Change_Id__c = change.Id, Status_to_Set__c = 'Material Only');
        SAP_Material_BOM_Status_Clear_Event__e event3 = new SAP_Material_BOM_Status_Clear_Event__e(Change_Id__c = change.Id, Status_to_Set__c = 'BOM Only');
        List<Database.SaveResult> srs = Eventbus.publish(new List<SAP_Material_BOM_Status_Clear_Event__e> {event1, event2, event3});

        Id changeId = change.Id;

        test.stopTest();

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id FROM SAP_BOM_Interface_Status__c 
                                                      WHERE Item_Revision__r.PDLM__Related_Change__c = : changeId AND SAP_BOM_Interface_Status__c = null];
        System.assertEquals(0, statuses.size());

        List<PDLM__Item_Revision__c> revs = [SELECT Id, SAP_Material_Interface_Status__c, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c 
                                             WHERE PDLM__Related_Change__c = : changeId AND 
                                             (SAP_Material_Interface_Status__c = null OR SAP_BOM_Interface_Status__c = null)];

        System.assertEquals(0, revs.size());
    }

    @isTest public static void PropelSAPIntClearFailedMaterialStatusesTest() {
        SetUpData();

        test.startTest();

        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        parentItemSapRev.SAP_BOM_Interface_Status__c = 'In Process';
        parentItemSapRev.SAP_Material_Interface_Status__c = 'Failed';
        revsToUpdate.add(parentItemSapRev);
        parentItemSap2Rev.SAP_BOM_Interface_Status__c = 'In Process';
        parentItemSap2Rev.SAP_Material_Interface_Status__c = 'In Process';
        revsToUpdate.add(parentItemSap2Rev);
        update revsToUpdate;

        change.PDLM__Approved__c = true;
        update change;
        
        SAP_Material_BOM_Status_Clear_Event__e event1 = new SAP_Material_BOM_Status_Clear_Event__e(Change_Id__c = change.Id, Status_to_Set__c = 'Material Only');
        List<Database.SaveResult> srs = Eventbus.publish(new List<SAP_Material_BOM_Status_Clear_Event__e> {event1});

        Id changeId = change.Id;
        Id parentRevId = parentItemSapRev.Id;

        test.stopTest();

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id FROM SAP_BOM_Interface_Status__c 
                                                      WHERE Item_Revision__r.PDLM__Related_Change__c = : changeId AND SAP_BOM_Interface_Status__c = null];
        System.assertEquals(0, statuses.size());

        List<PDLM__Item_Revision__c> revs = [SELECT Id, SAP_Material_Interface_Status__c FROM PDLM__Item_Revision__c 
                                             WHERE PDLM__Related_Change__c = : changeId AND SAP_Material_Interface_Status__c = null];

        System.assertEquals(1, revs.size());
        System.assertEquals(parentRevId, revs[0].Id);
    }

    @isTest public static void PropelSAPIntClearFailedBomStatusesTest() {
        SetUpData();

        test.startTest();

        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        parentItemSapRev.SAP_BOM_Interface_Status__c = 'In Process';
        parentItemSapRev.SAP_Material_Interface_Status__c = 'In Process';
        revsToUpdate.add(parentItemSapRev);
        parentItemSap2Rev.SAP_BOM_Interface_Status__c = 'Failed';
        parentItemSap2Rev.SAP_Material_Interface_Status__c = 'In Process';
        revsToUpdate.add(parentItemSap2Rev);
        update revsToUpdate;

        List<SAP_BOM_Interface_Status__c> statusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        status1.SAP_BOM_Interface_Status__c = 'Failed';
        status2.SAP_BOM_Interface_Status__c = 'Failed';
        statusesToUpdate.add(status1);
        statusesToUpdate.add(status2);
        update statusesToUpdate;

        change.PDLM__Approved__c = true;
        update change;
        
        SAP_Material_BOM_Status_Clear_Event__e event1 = new SAP_Material_BOM_Status_Clear_Event__e(Change_Id__c = change.Id, Status_to_Set__c = 'BOM Only');
        List<Database.SaveResult> srs = Eventbus.publish(new List<SAP_Material_BOM_Status_Clear_Event__e> {event1});

        Id changeId = change.Id;
        Id parentRevId = parentItemSap2Rev.Id;

        test.stopTest();

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id FROM SAP_BOM_Interface_Status__c 
                                                      WHERE Item_Revision__r.PDLM__Related_Change__c = : changeId AND SAP_BOM_Interface_Status__c = null];
        System.assertEquals(2, statuses.size());

        List<PDLM__Item_Revision__c> revs = [SELECT Id, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c 
                                             WHERE PDLM__Related_Change__c = : changeId AND SAP_BOM_Interface_Status__c = null];

        System.assertEquals(1, revs.size());
        System.assertEquals(parentRevId, revs[0].Id);
    }

    @isTest public static void PropelSAPIntClearFailedMaterialAndBomStatusesTest() {
        SetUpData();

        test.startTest();

        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        parentItemSapRev.SAP_BOM_Interface_Status__c = 'Failed';
        parentItemSapRev.SAP_Material_Interface_Status__c = 'In Process';
        revsToUpdate.add(parentItemSapRev);
        parentItemSap2Rev.SAP_BOM_Interface_Status__c = 'Failed';
        parentItemSap2Rev.SAP_Material_Interface_Status__c = 'Failed';
        revsToUpdate.add(parentItemSap2Rev);
        update revsToUpdate;

        List<SAP_BOM_Interface_Status__c> statusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        status1.SAP_BOM_Interface_Status__c = 'Failed';
        status2.SAP_BOM_Interface_Status__c = 'Failed';
        status3.SAP_BOM_Interface_Status__c = 'Failed';
        statusesToUpdate.add(status1);
        statusesToUpdate.add(status2);
        statusesToUpdate.add(status3);
        update statusesToUpdate;

        change.PDLM__Approved__c = true;
        update change;
        
        SAP_Material_BOM_Status_Clear_Event__e event1 = new SAP_Material_BOM_Status_Clear_Event__e(Change_Id__c = change.Id, Status_to_Set__c = 'Material and BOM');
        List<Database.SaveResult> srs = Eventbus.publish(new List<SAP_Material_BOM_Status_Clear_Event__e> {event1});

        Id changeId = change.Id;
        Id parentRev1Id = parentItemSapRev.Id;
        Id parentRev2Id = parentItemSap2Rev.Id;
        test.stopTest();

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id FROM SAP_BOM_Interface_Status__c 
                                                      WHERE Item_Revision__r.PDLM__Related_Change__c = : changeId AND SAP_BOM_Interface_Status__c = null];
        System.assertEquals(3, statuses.size());

        List<PDLM__Item_Revision__c> revs = [SELECT Id, SAP_Material_Interface_Status__c, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c 
                                             WHERE PDLM__Related_Change__c = : changeId AND 
                                             (SAP_BOM_Interface_Status__c = null OR SAP_Material_Interface_Status__c = null)];

        for (PDLM__Item_Revision__c rev : revs){
            if (rev.Id == parentRev1Id){
                System.assertEquals(null, rev.SAP_BOM_Interface_Status__c);
                System.assertEquals('In Process', rev.SAP_Material_Interface_Status__c);
            }
            else if (rev.Id == parentRev2Id){
                System.assertEquals(null, rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
            }
        }

        System.assertEquals(2, revs.size());
    }
}