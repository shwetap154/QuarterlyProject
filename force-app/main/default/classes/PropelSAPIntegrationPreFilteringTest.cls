@isTest
public with sharing class PropelSAPIntegrationPreFilteringTest {
    static void SetUpData(){
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        List<PDLM__Autonumber__c> autonumbersToInsert = new List<PDLM__Autonumber__c>();
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

        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Approved', PDLM__order__c = 3, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(approvedPhase);

        PDLM__Autonumber__c autonumberChange = new PDLM__Autonumber__c(Name='Autonumber for ECO', PDLM__prefix__c = 'ECO-', 
                                                                        PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        autonumbersToInsert.add(autonumberChange);

        //ECR Lifecycle and related
        PDLM__Lifecycle__c lifecycleECR = new PDLM__Lifecycle__c(Name='ECR', PDLM__primary_key__c = 'ECR');
        insert lifecycleECR;

        PDLM__Phase__c pendingPhaseECR = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycleECR.id);
        phasesToInsert.add(pendingPhaseECR);

        PDLM__Phase__c CCBPhaseECR = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
                                                        PDLM__lifecycle__c = lifecycleECR.id);
        phasesToInsert.add(CCBPhaseECR);

        PDLM__Phase__c approvedPhaseECR = new PDLM__Phase__c(Name='Approved', PDLM__order__c = 3, 
                                                                PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycleECR.id);
        phasesToInsert.add(approvedPhaseECR);

        PDLM__Autonumber__c autonumberChangeECR = new PDLM__Autonumber__c(name='Autonumber for ECR', PDLM__prefix__c = 'ECR-', 
                                                                            PDLM__Length__c = 5, PDLM__Next_Number__c = 1);
        autonumbersToInsert.add(autonumberChangeECR);

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
        autonumbersToInsert.add(autonumberItem);
        insert autonumbersToInsert;

        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__autonumber__c = autonumberChange.id, 
                                                                    PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        categoriesToInsert.add(categoryForChange);

        PDLM__Category__c deviationCategory = new PDLM__Category__c(Name='Temp Change', PDLM__autonumber__c = autonumberChange.id, 
                                          PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        categoriesToInsert.add(deviationCategory);
        
        PDLM__Category__c categoryForECR = new PDLM__Category__c(Name='ECR', PDLM__autonumber__c = autonumberChangeECR.id, 
                                                                 PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycleECR.id);
        categoriesToInsert.add(categoryForECR);

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Parts', PDLM__autonumber__c = autonumberItem.id, 
                                                                        PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        categoriesToInsert.add(categoryForPartItem);

        PDLM__Category__c categoryForNonPartItem = new PDLM__Category__c(Name='Assembly', PDLM__autonumber__c = autonumberItem.id, 
                                                                        PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        categoriesToInsert.add(categoryForNonPartItem);
        insert categoriesToInsert;

        //Create Change Orders
        List<PDLM__Change__c> changesToInsert = new List<PDLM__Change__c>();

        changeSap = new PDLM__Change__c(PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test SAP ECO');
        changesToInsert.add(changeSap);
        changeSapNoQualAis = new PDLM__Change__c(PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test SAP ECO with No Qualified AIs');
        changesToInsert.add(changeSapNoQualAis);
        changeNonSap = new PDLM__Change__c(PDLM__Category__c = categoryForECR.id, PDLM__title__c='Test Non-SAP ECR');
        changesToInsert.add(changeNonSap);
        deviation = new PDLM__Change__c(PDLM__Category__c = deviationCategory.id, PDLM__title__c='Test Deviation');
        changesToInsert.add(deviation);
        insert changesToInsert;

        mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected');

        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Create Paretnt Item and Item Revision
        parentItemSap = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP');
        insert parentItemSap;
        parentItemSapRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSap.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      PDLM__Released__c = true,
                                                      Manufacturing_Plant_Extension__c = 'US45:1:01');
        revsListToInsert.add(parentItemSapRev);

        Base_Unit_of_Measure__c base_uom = new Base_Unit_of_Measure__c(Name = 'EA - Each');
        insert base_uom;

        parentItemSapWith2Revs = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP', Base_UOM_Descriptive__c = base_uom.Id);
        insert parentItemSapWith2Revs;
        parentItemSapWith2RevsRev1 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                       PDLM__Revision__c = 'A',
                                                                                       PDLM__Lifecycle_Phase__c = 'Production',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       PDLM__Released__c = true,
                                                                                       PDLM__Released_Date__c = date.today().addDays(-1),
                                                                                       PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        revsListToInsert.add(parentItemSapWith2RevsRev1);

        parentItemForFlag = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP');
        insert parentItemForFlag;
        PDLM__Item_Revision__c parentItemForFlagRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemForFlag.Id, 
                                                                                       PDLM__Revision__c = 'A',
                                                                                       PDLM__Lifecycle_Phase__c = 'Prototype',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       PDLM__Released__c = true,
                                                                                       PDLM__Released_Date__c = date.today().addDays(-1),
                                                                                       PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        revsListToInsert.add(parentItemForFlagRev);

        parentItemNonSap = new PDLM__Item__c(PDLM__Category__c = categoryForNonPartItem.id, SAP_Material_Type__c = 'ZASP (NS)');
        insert parentItemNonSap;
        parentItemNonSapRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemNonSap.Id,
                                                         PDLM__Revision__c = 'A',
                                                         PDLM__Lifecycle_Phase__c = 'Production',
                                                         Description_Standard__c = 'N/A',
                                                         PDLM__Released__c = true);
        revsListToInsert.add(parentItemNonSapRev);
        
        //Create Child Item and Item Revision
        childItemSAP = new PDLM__Item__c(PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert childItemSAP;
        PDLM__Item_Revision__c childItemSAPRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItemSAP.Id,
                                                                            PDLM__Revision__c = 'A',
                                                                            PDLM__Lifecycle_Phase__c = 'Production',
                                                                            Description_Standard__c = 'N/A',
                                                                            SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                            PDLM__Released__c = true);
        revsListToInsert.add(childItemSAPRev);

        childItemNonSAP = new PDLM__Item__c(PDLM__Category__c = categoryForNonPartItem.id, SAP_Material_Type__c = 'ZASP (NS)');
        insert childItemNonSAP;
        PDLM__Item_Revision__c childItemNonSAPRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItemNonSAP.Id,
                                                                                PDLM__Revision__c = 'A',
                                                                                Description_Standard__c = 'N/A',
                                                                                PDLM__Released__c = true);
        revsListToInsert.add(childItemNonSAPRev);

        insert revsListToInsert;

        List<PDLM__Item__c> items = new List<PDLM__Item__c>();
        makeBuyPart = new PDLM__Item__c(Name = 'Make Buy Part', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP', Base_UOM_Descriptive__c = base_uom.Id);
        items.add(makeBuyPart);
        buyBuyPart = new PDLM__Item__c(Name = 'Buy Buy Part', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP', Base_UOM_Descriptive__c = base_uom.Id);
        items.add(buyBuyPart);
        insert items;
    }

    static PDLM__Change__c changeSap;
    static PDLM__Change__c changeSapNoQualAis;
    static PDLM__Change__c changeNonSap;
    static PDLM__Change__c deviation;
    static PDLM__Item__c childItemSAP;
    static PDLM__Item__c childItemNonSAP;
    static PDLM__Item__c parentItemSapWith2Revs;
    static PDLM__Item__c parentItemForFlag;
    static PDLM__Item__c parentItemSap;
    static PDLM__Item__c parentItemNonSap;
    static PDLM__Item_Revision__c parentItemSapRev;
    static PDLM__Item_Revision__c parentItemNonSapRev;
    static PDLM__Item_Revision__c parentItemSapWith2RevsRev1;
    static Propel_Lookup_Table__c mscRecord;
    static PDLM__Item__c makeBuyPart;
    static PDLM__Item__c buyBuyPart;
    
    @isTest public static void testTrigger(){
        SetUpData();

        Test.startTest();

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id,
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        
        Database.SaveResult sr = Eventbus.publish(event);

        Test.stopTest();

        // Verify that the publish was successful
        System.assertEquals(true, sr.isSuccess(), 'publish event should be successful');
    }

    @isTest public static void ChangeItemBomToSap(){
        SetUpData();
        
        Test.startTest();

        //Create Affected Item
        PDLM__Affected_Item__c  ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        insert ai;

        //Create Assembly
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        insert ass;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id,
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals(null, chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }

        List<PDLM__Affected_Item__c> aisMaterialStatus = [SELECT Id FROM PDLM__Affected_Item__c WHERE PDLM__Change_Order_lk__c = :event.Change_Record_Id__c 
                                                          and PDLM__Item_Revision__r.SAP_Material_Interface_Status__c = null 
                                                          and Send_To_SAP__c = true];
        System.assertEquals(1, aisMaterialStatus.size());

        List<PDLM__Affected_Item__c> aisBOMlStatus = [SELECT Id FROM PDLM__Affected_Item__c WHERE PDLM__Change_Order_lk__c = :event.Change_Record_Id__c 
                                                      and PDLM__Item_Revision__r.SAP_BOM_Interface_Status__c = null 
                                                      and Send_To_SAP__c = true];
        System.assertEquals(1, aisBOMlStatus.size());

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItemSap.Id){
                System.assertEquals(parentItemSapRev.Id, item.PDLM__Latest_Released_Revision__c);
                System.assertEquals(null, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(1, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void ChangeItemNoBomToSap(){
        SetUpData();
        
        Test.startTest();

        //Create Affected Item
        PDLM__Affected_Item__c  ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        insert ai;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id,
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;
        Id parentRevId = parentItemSapRev.Id;
        Id parentItemId = parentItemSap.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals(null, chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revisions
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRevId){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItemId){
                System.assertEquals(parentItemSapRev.Id, item.PDLM__Latest_Released_Revision__c);
                System.assertEquals(null, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(0, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void ChangeItemNoBomQualToSap(){
        SetUpData();
        
        Test.startTest();

        //Create Affected Item
        PDLM__Affected_Item__c  ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        insert ai;

        //Create Assembly
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemNonSAP.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        insert ass;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;
        Id parentRevId = parentItemSapRev.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals(null, chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revision
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRevId){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItemSap.Id){
                System.assertEquals(parentItemSapRev.Id, item.PDLM__Latest_Released_Revision__c);
                System.assertEquals(null, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(0, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void NoChangeToSapWhenNoItem(){
        SetUpData();

        Test.startTest();

        //Create Affected Item
        PDLM__Affected_Item__c  ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSapNoQualAis.Id, PDLM__Item_Revision__c = parentItemNonSapRev.Id);
        insert ai;

        //Create Assembly
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = parentItemNonSapRev.Id, PDLM__Quantity__c = 1);
        insert ass;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSapNoQualAis.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeNonQualSapId = changeSapNoQualAis.Id;
        Id parentRevId = parentItemSapRev.Id;
        Id parentNonSapItemId = parentItemNonSap.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeNonQualSapId){
                System.assertEquals(event.Not_Applicable_Picklist_API_Name__c, chg.Change_Interface_Status__c);
                System.assertEquals(false, chg.Ready_for_SAP_Processing__c);
            }
        }

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revisions
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRevId){
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentNonSapItemId){
                System.assertEquals(parentItemNonSapRev.Id, item.PDLM__Latest_Released_Revision__c);
                    System.assertEquals(null, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(0, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void NoChangeToSapWhenNoChange(){
        SetUpData();

        Test.startTest();

        //Create Affected Item
        PDLM__Affected_Item__c  ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeNonSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        insert ai;

        //Create Assembly
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        insert ass;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeNonSap.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id curreNonSapChangeId = changeNonSap.Id;
        Id parentRevId = parentItemSapRev.Id;
        Id parentItemId = parentItemSap.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == curreNonSapChangeId){
                System.assertEquals(event.Not_Applicable_Picklist_API_Name__c, chg.Change_Interface_Status__c);
                System.assertEquals(false, chg.Ready_for_SAP_Processing__c);
            }
        }

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revisions
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRevId){
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItemId){
                System.assertEquals(parentItemSapRev.Id, item.PDLM__Latest_Released_Revision__c);
                System.assertEquals(null, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(0, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void ChangeToSapWhenSAPItemFieldNoChange(){
        SetUpData();

        Test.startTest();

        //Insert an Item Revision
        PDLM__Item_Revision__c parentItemSapWith2RevsRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                    PDLM__Revision__c = 'A',
                                                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                                                    Description_Standard__c = 'N/A',
                                                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                    PDLM__Released__c = true,
                                                                                    Manufacturing_Plant_Extension__c = 'US45:1:01');
        insert parentItemSapWith2RevsRev2;

        //Create Affected Item
        List<PDLM__Affected_Item__c> ais = new List<PDLM__Affected_Item__c>();
        PDLM__Affected_Item__c ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id);
        ais.add(ai);
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        ais.add(ai2);
        insert ais;

        //Create Assembly
        List<PDLM__Assembly__c> assemblies = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass);
        PDLM__Assembly__c ass2 = new PDLM__Assembly__c(PDLM__Item__c = childItemNonSAP.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass2);
        insert assemblies;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;
        Id parentRev2RevsRev2Id = parentItemSapWith2RevsRev2.Id;
        Id parentRevId = parentItemSapRev.Id;
        Id parentItem2RevsId = parentItemSapWith2Revs.Id;
        Id parentRev2RevsRev1Id = parentItemSapWith2RevsRev1.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals(null, chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revisions
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRev2RevsRev2Id){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals(null, rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
            else if (rev.Id == parentRevId){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItem2RevsId){
                System.assertEquals(parentRev2RevsRev1Id, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(1, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void ChangeToSapWhenSAPItemFieldChanges(){
        SetUpData();

        Test.startTest();

        //Insert an Item Revision
        PDLM__Item_Revision__c parentItemSapWith2RevsRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                    PDLM__Revision__c = 'B',
                                                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                                                    Description_Standard__c = 'N/A',
                                                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                    PDLM__Released__c = true,
                                                                                    Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                                    Sales_VC_BOM_Plant_Extension__c = 'BR04:3:01');
        insert parentItemSapWith2RevsRev2;

        //Create Affected Item
        List<PDLM__Affected_Item__c> ais = new List<PDLM__Affected_Item__c>();
        PDLM__Affected_Item__c ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id);
        ais.add(ai);
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        ais.add(ai2);
        insert ais;

        //Create Assembly
        List<PDLM__Assembly__c> assemblies = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass);
        PDLM__Assembly__c ass2 = new PDLM__Assembly__c(PDLM__Item__c = childItemNonSAP.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass2);
        insert assemblies;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;
        Id parentRev2RevsRev2Id = parentItemSapWith2RevsRev2.Id;
        Id parentRevId = parentItemSapRev.Id;
        Id parentItem2RevsId = parentItemSapWith2Revs.Id;
        Id parentRev2RevsRev1Id = parentItemSapWith2RevsRev1.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals(null, chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revisions
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRev2RevsRev2Id){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals(null, rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
            else if (rev.Id == parentRevId){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
                System.assertEquals(true, rev.Send_To_SAP__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItem2RevsId){
                System.assertEquals(parentRev2RevsRev1Id, item.Previously_Released_Revision__c);
            }
        }

        System.debug('ChangeToSapWhenSAPItemFieldChanges BOM Statuses: ' + resultsReturned.bomStatusesFromInsert);
        System.assertEquals(2, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void checkQueuedInterfaceStatus(){
        SetUpData();

        Test.startTest();

        //Insert an Item Revision
        changeNonSap.Overall_Interface_Status__c = 'In Process';
        update changeNonSap;
        parentItemSapWith2RevsRev1.PDLM__Related_Change__c = changeNonSap.Id;
        update parentItemSapWith2RevsRev1;

        PDLM__Item_Revision__c parentItemSapWith2RevsRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                    PDLM__Revision__c = 'B',
                                                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                                                    Description_Standard__c = 'N/A',
                                                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                    PDLM__Released__c = true,
                                                                                    Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                                    Sales_VC_BOM_Plant_Extension__c = 'BR04:3:01');
        insert parentItemSapWith2RevsRev2;

        //Create Affected Item
        List<PDLM__Affected_Item__c> ais = new List<PDLM__Affected_Item__c>();
        PDLM__Affected_Item__c ai = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id);
        ais.add(ai);
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapRev.Id);
        ais.add(ai2);
        insert ais;

        //Create Assembly
        List<PDLM__Assembly__c> assemblies = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass);
        PDLM__Assembly__c ass2 = new PDLM__Assembly__c(PDLM__Item__c = childItemNonSAP.Id, PDLM__Item_Revision__c = parentItemSapRev.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass2);
        insert assemblies;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;

        Test.stopTest();

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals('Queued', chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }
    }

    @isTest public static void NfrToFrChangeAndCreateSapMaterialFlagsTest(){
        SetUpData();

        Test.startTest();

        //Insert an Item Revision
        List<PDLM__Item_Revision__c> itemRevs = new List<PDLM__Item_Revision__c>();

        PDLM__Item_Revision__c parentItemSapWith2RevsRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                       PDLM__Revision__c = 'B',
                                                                                       PDLM__Lifecycle_Phase__c = 'Production',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       Field_Service_Replaceable_Part__c = 'Yes');
        itemRevs.add(parentItemSapWith2RevsRev2);

        PDLM__Item_Revision__c parentItemForFlagRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemForFlag.Id, 
                                                                                  PDLM__Revision__c = 'B',
                                                                                  PDLM__Lifecycle_Phase__c = 'Production',
                                                                                  Description_Standard__c = 'N/A',
                                                                                  SAP_Material_Setup_Code__c = mscRecord.Id);
        itemRevs.add(parentItemForFlagRev2);
        insert itemRevs;

        //Create Affected Item
        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id);
        insert ai1;
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemForFlagRev2.Id);
        insert ai2;
        
        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id, Field_Update_Before_Release__c = true);
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id parentRev2RevsRev2Id = parentItemSapWith2RevsRev2.Id;
        Id parentRevFlagRev2Id = parentItemForFlagRev2.Id;
        Id parentItemId = parentItemSapWith2Revs.Id;
        Id parentRev2RevsRev1Id = parentItemSapWith2RevsRev1.Id;

        Test.stopTest();

        //Check Material_Interface_Status__c and BOM_Interface_Status__c on Item Revisions
        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == parentRev2RevsRev2Id){
                System.assertEquals(false, rev.Create_SAP_Material__c);
                System.assertEquals(true, rev.NFR_to_FR_Change__c);
            }
            else if (rev.Id == parentRevFlagRev2Id){
                System.assertEquals(true, rev.Create_SAP_Material__c);
                System.assertEquals(false, rev.NFR_to_FR_Change__c);
            }
        }

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItemId){
                System.assertEquals(parentRev2RevsRev1Id, item.PDLM__Latest_Released_Revision__c);
                System.assertEquals(null, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(0, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void TestDeviationRevsWereExcluded(){
        SetUpData();

        Test.startTest();

        //Insert an Item Revision
        List<PDLM__Item_Revision__c> itemRevs = new List<PDLM__Item_Revision__c>();

        PDLM__Item_Revision__c parentItemSapWith2RevsRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                       PDLM__Revision__c = 'B',
                                                                                       PDLM__Lifecycle_Phase__c = 'Production',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       Field_Service_Replaceable_Part__c = 'Yes',
                                                                                       PDLM__Released__c = true,
                                                                                       PDLM__Released_Date__c = date.today().addDays(-1),
                                                                                       PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        itemRevs.add(parentItemSapWith2RevsRev2);

        PDLM__Item_Revision__c parentItemSapWith2RevsRev3 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItemSapWith2Revs.Id, 
                                                                                       PDLM__Revision__c = 'C',
                                                                                       PDLM__Lifecycle_Phase__c = 'Production',
                                                                                       Description_Standard__c = 'N/A',
                                                                                       SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                                       Field_Service_Replaceable_Part__c = 'Yes',
                                                                                       PDLM__Released__c = true);
        itemRevs.add(parentItemSapWith2RevsRev3);
        insert itemRevs;
        
        //Create Affected Item
        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSapNoQualAis.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev1.Id);
        insert ai1;

        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = deviation.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev2.Id);
        insert ai2;

        PDLM__Affected_Item__c ai3 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = parentItemSapWith2RevsRev3.Id);
        insert ai3;
        
        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id, 
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id parentItemId = parentItemSapWith2Revs.Id;
        Id parentRev2RevsRev1Id = parentItemSapWith2RevsRev1.Id;
        
        Test.stopTest();

        for (PDLM__Item__c item : resultsReturned.itemsFromUpdate){
            if (item.Id == parentItemId){
                System.assertEquals(parentRev2RevsRev1Id, item.Previously_Released_Revision__c);
            }
        }

        System.assertEquals(0, resultsReturned.bomStatusesFromInsert.size());
    }

    @isTest public static void changeWithNoAi(){
        SetUpData();

        Test.startTest();

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id,
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned =PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;

        Test.stopTest();    

        //Check Change_Interface_Status__c on Change
        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals('<<< Not Applicable >>>', chg.Change_Interface_Status__c);
                System.assertEquals(false, chg.Ready_for_SAP_Processing__c);
            }
        }
    }

    @isTest public static void testMakeBuyTransitionException(){
        SetUpData();

        Test.startTest();

        //Insert Item Revisions
        List<PDLM__Item_Revision__c> itemRevs = new List<PDLM__Item_Revision__c>();

        PDLM__Item_Revision__c makeBuyPartRev1 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = makeBuyPart.Id, 
                                                                            PDLM__Revision__c = 'A',
                                                                            PDLM__Lifecycle_Phase__c = 'Production',
                                                                            Description_Standard__c = 'Make Buy Part Rev 1',
                                                                            SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                            Make_or_Buy__c = 'Make',
                                                                            Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                            PDLM__Released__c = true,
                                                                            PDLM__Released_Date__c = date.today().addDays(-1),
                                                                            PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        itemRevs.add(makeBuyPartRev1);
        PDLM__Item_Revision__c makeBuyPartRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = makeBuyPart.Id, 
                                                                            PDLM__Revision__c = 'B',
                                                                            PDLM__Lifecycle_Phase__c = 'Production',
                                                                            Description_Standard__c = 'Make Buy Part Rev 2',
                                                                            SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                            Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                            Make_or_Buy__c = 'Buy',
                                                                            PDLM__Released__c = true);
        itemRevs.add(makeBuyPartRev2);
        PDLM__Item_Revision__c buyBuyPartRev1 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = buyBuyPart.Id, 
                                                                            PDLM__Revision__c = 'A',
                                                                            PDLM__Lifecycle_Phase__c = 'Production',
                                                                            Description_Standard__c = 'Buy Buy Part Rev 1',
                                                                            SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                            Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                            Make_or_Buy__c = 'Buy',
                                                                            PDLM__Released__c = true,
                                                                            PDLM__Released_Date__c = date.today().addDays(-1),
                                                                            PDLM__Released_Date_Time__c = dateTime.now().addDays(-1));
        itemRevs.add(buyBuyPartRev1);
        PDLM__Item_Revision__c buyBuyPartRev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = buyBuyPart.Id, 
                                                                            PDLM__Revision__c = 'B',
                                                                            PDLM__Lifecycle_Phase__c = 'Production',
                                                                            Description_Standard__c = 'Buy Buy Part Rev 2',
                                                                            SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                            Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                            Make_or_Buy__c = 'Buy',
                                                                            PDLM__Released__c = true);
        itemRevs.add(buyBuyPartRev2);
        insert itemRevs;

        System.debug('itemRevs:' + itemRevs);
        
        //Create Affected Item
        changeNonSap.Overall_Interface_Status__c = '<<< Not Applicable >>>';
        update changeNonSap;
        
        List<PDLM__Affected_Item__c> ais = new List<PDLM__Affected_Item__c>();
        PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = makeBuyPartRev2.Id);
        ais.add(ai1);
        PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeSap.Id, PDLM__Item_Revision__c = buyBuyPartRev2.Id);
        ais.add(ai2);
        PDLM__Affected_Item__c ai3 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeNonSap.Id, PDLM__Item_Revision__c = makeBuyPartRev1.Id);
        ais.add(ai3);
        PDLM__Affected_Item__c ai4 = new PDLM__Affected_Item__c(PDLM__Change_Order_lk__c = changeNonSap.Id, PDLM__Item_Revision__c = buyBuyPartRev1.Id);
        ais.add(ai4);
        insert ais;

        //Create Assembly
        List<PDLM__Assembly__c> assemblies = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass1 = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = makeBuyPartRev2.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass1);
        PDLM__Assembly__c ass2 = new PDLM__Assembly__c(PDLM__Item__c = childItemSAP.Id, PDLM__Item_Revision__c = buyBuyPartRev2.Id, PDLM__Quantity__c = 1);
        assemblies.add(ass2);
        insert assemblies;

        SAP_Integration_Event__e event = new SAP_Integration_Event__e(Change_Record_Id__c = changeSap.Id,
                                                                      Pre_filtering_After_Release__c = true,
                                                                      X30_Subcontracting_Picklist_API_Name__c = '30 - Subcontracting',
                                                                      Buy_Picklist_API_Nam__c = 'Buy',
                                                                      Change_Category_e_g_ECO_ECO_QMS__c = 'ECO;ECO-QMS;BCO;BCO-QMS',
                                                                      Not_Applicable_Picklist_API_Name__c = '<<< Not Applicable >>>',
                                                                      Rev_Fields_e_g_Name_MSC_Group_c__c = 'PDLM__Master_Item_Number__c;Description_Standard__c;MSC_Group__c;Serial_Number_Profile__c;Old_Material_Number__c;Batch_Controlled__c;Discontinuation_Indicator__c;Replaced_by_Material__c;Special_Procurement__c;Manufacturing_Plant_Extension__c;PDLM__Lifecycle_Phase__c;Make_or_Buy__c;Inspection_Setup_Required__c;Use_up_by_for_Discontinued_Lifecycle__c;Net_Weight_g__c;PDLM__Revision__c;NFR_to_FR_Change__c');
        List<SAP_Integration_Event__e> events = new List<SAP_Integration_Event__e> {event};
        PropelSapEventServiceClass.results resultsReturned = PropelSapEventServiceClass.afterInsert(events);

        Id currChangeSapId = changeSap.Id;
        Id makeBuyRev2Id = makeBuyPartRev2.Id;
        Id buyBuyRev2Id = buyBuyPartRev2.Id;

        Test.stopTest();

        for (PDLM__Change__c chg : resultsReturned.changesFromUpdate){
            if (chg.Id == currChangeSapId){
                System.assertEquals(null, chg.Change_Interface_Status__c);
                System.assertEquals(true, chg.Ready_for_SAP_Processing__c);
            }
        }

        for (PDLM__Item_Revision__c rev : resultsReturned.revsFromUpdate){
            if (rev.Id == makeBuyRev2Id){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals(null, rev.SAP_BOM_Interface_Status__c);
            }
            else if (rev.Id == buyBuyRev2Id){
                System.assertEquals(null, rev.SAP_Material_Interface_Status__c);
                System.assertEquals('<<< Not Applicable >>>', rev.SAP_BOM_Interface_Status__c);
            }
        }

        System.debug('testMakeBuyTransitionException BOM Statuses: ' + resultsReturned.bomStatusesFromInsert);
        System.assertEquals(1, resultsReturned.bomStatusesFromInsert.size());

        //Check Custom Settings
        PDLM__Configuration__c itemConfig = PDLM__Configuration__c.getValues('ItemTriggerDisable');
        PDLM__Configuration__c itemRevConfig = PDLM__Configuration__c.getValues('ItemRevisionTriggerDisable');
        System.assertEquals('false', itemConfig.PDLM__Value__c);
        System.assertEquals('false', itemRevConfig.PDLM__Value__c);
    }
}