@isTest
public with sharing class PropelParentChildBomErrorCheckTest {
    static void SetUpData(){
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        List<PDLM__Category__c> categoriesToInsert = new List<PDLM__Category__c>();

        //ECO Lifecycle and related
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO');
        insert lifecycle;

        PDLM__Phase__c initialPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(initialPhase);

        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(CCBPhase);

        PDLM__Phase__c approvalPhase = new PDLM__Phase__c(Name='Approval', PDLM__order__c = 3, PDLM__Auto_Submit_For_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(approvalPhase);

        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Released', PDLM__order__c = 4, PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(approvedPhase);

        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        categoriesToInsert.add(categoryForChange);

        //Item Lifecycle and Related
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(name='Assembly123', PDLM__primary_key__c = 'Assembly123');
        insert lifecycleItem;

        PDLM__Phase__c firstPhase = new PDLM__Phase__c(Name='Prototype', PDLM__order__c = 1, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id, PDLM__Next_Phases__c = '["Discontinue Production", "Production"]');
        phasesToInsert.add(firstPhase);

        PDLM__Phase__c secondPhase = new PDLM__Phase__c(Name='Production', PDLM__order__c = 2, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id, PDLM__Next_Phases__c = '["Discontinue Production"]');
        phasesToInsert.add(secondPhase);

        PDLM__Phase__c thirdPhase = new PDLM__Phase__c(Name='Discontinue Production', PDLM__order__c = 3, PDLM__Default_No_Change_Control__c = true, PDLM__lifecycle__c = lifecycleItem.id);
        phasesToInsert.add(thirdPhase);

        insert phasesToInsert;

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Parts123', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        categoriesToInsert.add(categoryForPartItem);
        insert categoriesToInsert;

        //Create Change Orders
        change = new PDLM__Change__c(Name = 'Test Change 123', PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test SAP ECO');
        insert change;

        Propel_Lookup_Table__c mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected', MSC_Plant_Extensions__c = 'US45');
        insert mscRecord;

        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Create Paretnt Item and Item Revision
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Parent Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZEQU');
        insert parentItem1;
        parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Prototype',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Sales_VC_BOM_Plant_Extension__c = 'US87:5:01',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItem1Rev);

        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Parent Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZEQU');
        insert parentItem2;
        parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Sales_VC_BOM_Plant_Extension__c = 'US87:5:01',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(parentItem2Rev);

        PDLM__Item__c childItem1 = new PDLM__Item__c(Name = 'Child Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert childItem1;
        childItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Extended_Site_s__c = 'US13',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(childItem1Rev);

        PDLM__Item__c childItem2 = new PDLM__Item__c(Name = 'Child Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert childItem2;
        childItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem2.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Extended_Site_s__c = 'US45',
                                                      PDLM__Released__c = true);
        revsListToInsert.add(childItem2Rev);
        insert revsListToInsert;

        //Add Assemblies
        List<PDLM__Assembly__c> assListToInsert = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass1 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem1.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass1);
        PDLM__Assembly__c ass2 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem2.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass2);
        PDLM__Assembly__c ass3 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Item__c = childItem1.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass3);
        insert assListToInsert;
    }

    static PDLM__Change__c change;
    static PDLM__Item_Revision__c parentItem1Rev;
    static PDLM__Item_Revision__c parentItem2Rev;
    static PDLM__Item_Revision__c childItem1Rev;
    static PDLM__Item_Revision__c childItem2Rev;

    @isTest public static void testWithBomError() {
        SetUpData();

        test.StartTest();
        //Add Affected Items
        List<PDLM__Affected_Item__c> aisToInsert = new List<PDLM__Affected_Item__C>();
        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItem1Rev.Id);
        aisToInsert.add(ai1);
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItem2Rev.Id);
        aisToInsert.add(ai2);
        PDLM__Affected_Item__c ai3 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = childItem2Rev.Id);
        aisToInsert.add(ai3);
        PDLM__Affected_Item__c ai4 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = childItem1Rev.Id);
        aisToInsert.add(ai4);
        insert aisToInsert;

        PDLM__Change_Phase__c plmReviewPhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE Name = 'PLM Review' AND PDLM__Change_lk__c = :change.Id LIMIT 1];
        change.PDLM__Status_lk__c = plmReviewPhase.Id;
        update change;

        test.StopTest();

        List<PDLM__Affected_Item__c> aisReturned = PropelBomErrorCheckServiceClass.afterUpdate(new List<PDLM__Change__c> {change});

        for (PDLM__Affected_Item__c ai : aisReturned){
            System.assertEquals(true, ai.Parent_Child_BOM_Error__c);
        }        
    }

    @isTest public static void testWithoutBomError() {
        SetUpData();
        
        test.StartTest();

        //Add Affected Items
        List<PDLM__Affected_Item__c> aisToInsert = new List<PDLM__Affected_Item__C>();
        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItem1Rev.Id);
        aisToInsert.add(ai1);
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = parentItem2Rev.Id);
        aisToInsert.add(ai2);
        PDLM__Affected_Item__c ai3 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = childItem2Rev.Id);
        aisToInsert.add(ai3);
        PDLM__Affected_Item__c ai4 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = change.Id, PDLM__Item_Revision__c = childItem1Rev.Id);
        aisToInsert.add(ai4);
        insert aisToInsert;

        List<PDLM__Item_Revision__c> revToUpdate = new List<PDLM__Item_Revision__c>();
        parentItem1Rev.Manufacturing_Plant_Extension__c = 'US45:1:01';
        revToUpdate.add(parentItem1Rev);

        parentItem2Rev.Manufacturing_Plant_Extension__c = 'US45:1:01';
        revToUpdate.add(parentItem2Rev);

        childItem1Rev.Extended_Site_s__c = 'US13;BE02;US87';
        revToUpdate.add(childItem1Rev);

        childItem2Rev.Extended_Site_s__c = 'US45;BE02;US87';
        revToUpdate.add(childItem2Rev);

        update revToUpdate;

        PDLM__Change_Phase__c plmReviewPhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE Name = 'PLM Review' AND PDLM__Change_lk__c = :change.Id LIMIT 1];
        change.PDLM__Status_lk__c = plmReviewPhase.Id;
        update change;

        test.StopTest();

        List<PDLM__Affected_Item__c> aisReturned = PropelBomErrorCheckServiceClass.afterUpdate(new List<PDLM__Change__c> {change});

        for (PDLM__Affected_Item__c ai : aisReturned){
            System.assertEquals(false, ai.Parent_Child_BOM_Error__c);
        }    
    }
}