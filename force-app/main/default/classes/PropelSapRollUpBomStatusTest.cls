@isTest
public with sharing class PropelSapRollUpBomStatusTest {
    static void SetUpData(){
        PDLM__Configuration__c config = new PDLM__Configuration__c(Name = 'SapBomBatchScope', PDLM__Value__c = '200');
        insert config;

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
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Parent Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem1;
        PDLM__Item_Revision__c parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, 
                                                    PDLM__Revision__c = 'A',
                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                    Description_Standard__c = 'N/A',
                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                    Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                    Sales_VC_BOM_Plant_Extension__c = 'US87:5:01;US13:3:01',
                                                    PDLM__Released__c = true);
        revsListToInsert.add(parentItem1Rev);

        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Parent Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem2;
        PDLM__Item_Revision__c parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, 
                                                    PDLM__Revision__c = 'A',
                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                    Description_Standard__c = 'N/A',
                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                    Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                    Sales_VC_BOM_Plant_Extension__c = 'US87:5:01',
                                                    PDLM__Released__c = true);
        revsListToInsert.add(parentItem2Rev);

        insert revsListToInsert;

        List<SAP_BOM_Interface_Status__c> bomStatusesToInsert = new List<SAP_BOM_Interface_Status__c>();
        bomStatusItem1Site1 = new SAP_BOM_Interface_Status__c();
        bomStatusItem1Site1.Item_Revision__c = parentItem1Rev.Id;
        bomStatusItem1Site1.Site__c = 'US45:1:01';
        bomStatusesToInsert.add(bomStatusItem1Site1);

        bomStatusItem1Site2 = new SAP_BOM_Interface_Status__c();
        bomStatusItem1Site2.Item_Revision__c = parentItem1Rev.Id;
        bomStatusItem1Site2.Site__c = 'US87:5:01';
        bomStatusesToInsert.add(bomStatusItem1Site2);

        bomStatusItem1Site3 = new SAP_BOM_Interface_Status__c();
        bomStatusItem1Site3.Item_Revision__c = parentItem1Rev.Id;
        bomStatusItem1Site3.Site__c = 'US13:3:01';
        bomStatusesToInsert.add(bomStatusItem1Site3);

        bomStatusItem2Site1 = new SAP_BOM_Interface_Status__c();
        bomStatusItem2Site1.Item_Revision__c = parentItem2Rev.Id;
        bomStatusItem2Site1.Site__c = 'US45:1:01';
        bomStatusesToInsert.add(bomStatusItem2Site1);

        bomStatusItem2Site2 = new SAP_BOM_Interface_Status__c();
        bomStatusItem2Site2.Item_Revision__c = parentItem2Rev.Id;
        bomStatusItem2Site2.Site__c = 'US87:5:01';
        bomStatusesToInsert.add(bomStatusItem2Site2);

        insert bomStatusesToInsert;
    }
    
    static SAP_BOM_Interface_Status__c bomStatusItem1Site1;
    static SAP_BOM_Interface_Status__c bomStatusItem1Site2;
    static SAP_BOM_Interface_Status__c bomStatusItem1Site3;
    static SAP_BOM_Interface_Status__c bomStatusItem2Site1;
    static SAP_BOM_Interface_Status__c bomStatusItem2Site2;

    @isTest static void successfulRollUp() {
        SetUpData();

        List<SAP_BOM_Interface_Status__c> statusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        List<Id> revIds = new List<Id>();

        bomStatusItem1Site1.SAP_BOM_Interface_Status__c = 'Manually Completed';
        bomStatusItem1Site2.SAP_BOM_Interface_Status__c = 'Completed';
        bomStatusItem1Site3.SAP_BOM_Interface_Status__c = 'Completed';
        bomStatusItem2Site1.SAP_BOM_Interface_Status__c = 'Completed';
        bomStatusItem2Site2.SAP_BOM_Interface_Status__c = 'Completed';

        statusesToUpdate.addAll(new List<SAP_BOM_Interface_Status__c> {bomStatusItem1Site1, bomStatusItem1Site2, bomStatusItem1Site3, 
                                                                       bomStatusItem2Site1, bomStatusItem2Site2});
        update statusesToUpdate;

        revIds.addAll(new List<Id> {bomStatusItem1Site1.Item_Revision__c, bomStatusItem1Site2.Item_Revision__c, bomStatusItem1Site3.Item_Revision__c,
                                    bomStatusItem2Site1.Item_Revision__c, bomStatusItem2Site2.Item_Revision__c});
        
        Test.startTest();

        PropelSapRollUpBomStatus tsub = new PropelSapRollUpBomStatus();
        Database.executeBatch(tsub);

        Test.stopTest();

        List<PDLM__Item_Revision__c> revs = [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c WHERE Id in :revIds];

        System.assertEquals(2, revs.size());

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id, Status_Rolled_Up_to_Rev__c, Completed__c FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revIds];
        System.assertEquals(5, statuses.size());

        for (SAP_BOM_Interface_Status__c status : statuses){
            System.assertEquals(true, status.Status_Rolled_Up_to_Rev__c);
            System.assertEquals(true, status.Completed__c);
        }

        for (PDLM__Item_Revision__c rev : revs){
            System.assertEquals('Completed', rev.SAP_BOM_Interface_Status__c);
        }
    }

    @isTest static void failedRollUp() {
        SetUpData();
        
        List<SAP_BOM_Interface_Status__c> statusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        List<Id> revIds = new List<Id>();

        bomStatusItem1Site1.SAP_BOM_Interface_Status__c = 'Completed';
        bomStatusItem1Site2.SAP_BOM_Interface_Status__c = 'Manually Completed';
        bomStatusItem1Site3.SAP_BOM_Interface_Status__c = 'Completed';
        bomStatusItem2Site1.SAP_BOM_Interface_Status__c = 'Failed';
        bomStatusItem2Site2.SAP_BOM_Interface_Status__c = 'Completed';

        statusesToUpdate.addAll(new List<SAP_BOM_Interface_Status__c> {bomStatusItem1Site1, bomStatusItem1Site2, bomStatusItem1Site3, 
                                                                       bomStatusItem2Site1, bomStatusItem2Site2});
        update statusesToUpdate;

        revIds.addAll(new List<Id> {bomStatusItem1Site1.Item_Revision__c, bomStatusItem1Site2.Item_Revision__c, bomStatusItem1Site3.Item_Revision__c,
                                    bomStatusItem2Site1.Item_Revision__c, bomStatusItem2Site2.Item_Revision__c});
        
        Test.startTest();

        PropelSapRollUpBomStatus tsub = new PropelSapRollUpBomStatus();
        Database.executeBatch(tsub);

        Test.stopTest();

        List<PDLM__Item_Revision__c> revs = [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c WHERE Id in :revIds];

        System.assertEquals(2, revs.size());

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id, Status_Rolled_Up_to_Rev__c, Completed__c FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revIds];
        System.assertEquals(5, statuses.size());

        for (SAP_BOM_Interface_Status__c status : statuses){
            if (status.Id == bomStatusItem2Site1.Id || status.Id == bomStatusItem2Site2.Id){
                System.assertEquals(true, status.Status_Rolled_Up_to_Rev__c);
                System.assertEquals(false, status.Completed__c);
            }
            else{
                System.assertEquals(true, status.Status_Rolled_Up_to_Rev__c);
                System.assertEquals(true, status.Completed__c);
            }
        }

        for (PDLM__Item_Revision__c rev : revs){
            if (rev.Id == bomStatusItem2Site1.Item_Revision__c || rev.Id == bomStatusItem2Site2.Item_Revision__c){
                System.assertEquals('Failed', rev.SAP_BOM_Interface_Status__c);
            }
            else{
                System.assertEquals('Completed', rev.SAP_BOM_Interface_Status__c);
            }
        }
    }

    @isTest static void pendingRollUp() {
        SetUpData();
        
        List<SAP_BOM_Interface_Status__c> statusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        List<Id> revIds = new List<Id>();

        bomStatusItem1Site1.SAP_BOM_Interface_Status__c = 'Manually Completed';
        bomStatusItem1Site2.SAP_BOM_Interface_Status__c = 'Completed';
        bomStatusItem2Site1.SAP_BOM_Interface_Status__c = 'Failed';
        bomStatusItem2Site2.SAP_BOM_Interface_Status__c = 'Completed';

        statusesToUpdate.addAll(new List<SAP_BOM_Interface_Status__c> {bomStatusItem1Site1, bomStatusItem1Site2, 
                                                                       bomStatusItem2Site1, bomStatusItem2Site2});
        update statusesToUpdate;

        revIds.addAll(new List<Id> {bomStatusItem1Site1.Item_Revision__c, bomStatusItem1Site2.Item_Revision__c, 
                                    bomStatusItem2Site1.Item_Revision__c, bomStatusItem2Site2.Item_Revision__c});
        
        Test.startTest();

        PropelSapRollUpBomStatus tsub = new PropelSapRollUpBomStatus();
        Database.executeBatch(tsub);

        Test.stopTest();

        List<PDLM__Item_Revision__c> revs = [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c WHERE Id in :revIds];

        System.assertEquals(2, revs.size());

        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id, Status_Rolled_Up_to_Rev__c, Completed__c FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revIds];
        System.assertEquals(5, statuses.size());

        for (SAP_BOM_Interface_Status__c status : statuses){
            if (status.Id == bomStatusItem2Site1.Id || status.Id == bomStatusItem2Site2.Id){
                System.assertEquals(true, status.Status_Rolled_Up_to_Rev__c);
                System.assertEquals(false, status.Completed__c);
            }
            else{
                System.assertEquals(false, status.Status_Rolled_Up_to_Rev__c);
                System.assertEquals(false, status.Completed__c);
            }
        }

        for (PDLM__Item_Revision__c rev : revs){
            if (rev.Id == bomStatusItem2Site1.Item_Revision__c || rev.Id == bomStatusItem2Site2.Item_Revision__c){
                System.assertEquals('Failed', rev.SAP_BOM_Interface_Status__c);
            }
            else{
                System.assertEquals(null, rev.SAP_BOM_Interface_Status__c);
            }
        }
    }
}