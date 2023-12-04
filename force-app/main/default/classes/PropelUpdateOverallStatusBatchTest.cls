@isTest
public with sharing class PropelUpdateOverallStatusBatchTest {
    static void SetUpData(){
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        List<PDLM__Category__c> categoriesToInsert = new List<PDLM__Category__c>();

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

        // PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(Name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', 
        //                                                                 PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        // insert autonumberChange;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        categoriesToInsert.add(categoryForChange);

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
        
        // PDLM__Autonumber__c autonumberItem = new PDLM__Autonumber__c(Name='Autonumber for Part', PDLM__prefix__c = 'PART-', 
        //                                                                 PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        // insert autonumberItem;

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Parts', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        categoriesToInsert.add(categoryForPartItem);
        insert categoriesToInsert;

        //Create Change Orders
        change = new PDLM__Change__c(Name = 'ECO-00001', PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test SAP ECO');
        insert change;

        Propel_Lookup_Table__c mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected');
        
        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Create Paretnt Item and Item Revision
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem1;
        parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      SAP_BOM_Interface_Status__c = 'Completed',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItem1Rev);

        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem2;
        PDLM__Item_Revision__c parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      SAP_BOM_Interface_Status__c = 'Completed',
                                                      SAP_Material_Interface_Status__c = '<<< Not Applicable >>>',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItem2Rev);

        PDLM__Item__c parentItem3 = new PDLM__Item__c(Name = 'Item 3', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem3;
        PDLM__Item_Revision__c parentItem3Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem3.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      SAP_BOM_Interface_Status__c = '<<< Not Applicable >>>',
                                                      SAP_Material_Interface_Status__c = 'Manually Completed',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItem3Rev);

        insert revsListToInsert;

        //Add Affected Items
        List<PDLM__Affected_Item__c> aisListToInsert = new List<PDLM__Affected_Item__c>();
        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        aisListToInsert.add(ai1);

        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        aisListToInsert.add(ai2);

        PDLM__Affected_Item__c ai3 = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem3Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        aisListToInsert.add(ai3);

        insert aisListToInsert;
    }

    static PDLM__Change__c change;
    static PDLM__Item_Revision__c parentItem1Rev;

    @isTest public static void testCompletedOverallStatus() {
        SetUpData();

        Test.startTest();

        change.Overall_Interface_Status__c = 'In Process';
        update change;

        parentItem1Rev.SAP_Material_Interface_Status__c = 'Completed';
        update parentItem1Rev;

        PDLM__Change_Phase__c releasedStatus = [Select Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];
        change.PDLM__Status_lk__c = releasedStatus.Id;
        update change;
        
        PropelUpdateOverallInterfaceStatusBatch tsub = new PropelUpdateOverallInterfaceStatusBatch();
        Database.executeBatch(tsub);

        Id changeId = change.Id;

        Test.stopTest();

        //Query Change and check the Overall_Interface_Status__c
        List<PDLM__Change__c> chg = [SELECT Id, Overall_Interface_Status__c FROM PDLM__Change__c WHERE Id = :changeId Limit 1];
        System.assertEquals('Completed', chg[0].Overall_Interface_Status__c);
    }   

    @isTest public static void testFailedOverallStatus() {
        SetUpData();

        Test.startTest();
        
        change.Overall_Interface_Status__c = 'In Process';
        update change;

        parentItem1Rev.SAP_Material_Interface_Status__c = 'Failed';
        update parentItem1Rev;

        PDLM__Change_Phase__c releasedStatus = [Select Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];
        change.PDLM__Status_lk__c = releasedStatus.Id;
        update change;

        PropelUpdateOverallInterfaceStatusBatch tsub = new PropelUpdateOverallInterfaceStatusBatch();
        Database.executeBatch(tsub);

        Id changeId = change.Id;

        Test.stopTest();

        //Query Change and check the Overall_Interface_Status__c
        List<PDLM__Change__c> chg = [SELECT Id, Overall_Interface_Status__c FROM PDLM__Change__c WHERE Id = :changeId Limit 1];
        System.assertEquals('Failed', chg[0].Overall_Interface_Status__c);
    }

    @isTest public static void testNoUpdates() {
        SetUpData();

        Test.startTest();
        
        PDLM__Change_Phase__c releasedStatus = [Select Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];
        change.PDLM__Status_lk__c = releasedStatus.Id;
        update change;

        PropelUpdateOverallInterfaceStatusBatch tsub = new PropelUpdateOverallInterfaceStatusBatch();
        Database.executeBatch(tsub);

        Id changeId = change.Id;

        Test.stopTest();

        //Query Change and check the Overall_Interface_Status__c
        List<PDLM__Change__c> chg = [SELECT Id, Overall_Interface_Status__c FROM PDLM__Change__c WHERE Id = :changeId Limit 1];
        System.assertEquals(null, chg[0].Overall_Interface_Status__c);
    }
}