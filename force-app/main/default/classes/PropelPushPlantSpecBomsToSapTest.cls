@isTest
public with sharing class PropelPushPlantSpecBomsToSapTest {
    static void SetUpData(){
        //Create Configuration entries
        PDLM__Configuration__c config = new PDLM__Configuration__c(Name = 'SapEndPointUrlHost', PDLM__Value__c = 'https://sldx3.zoetis.com');
        insert config;

        sampleEndPoint = config.PDLM__Value__c;

        List<PDLM__Lifecycle__c> lifecyclesToInsert = new List<PDLM__Lifecycle__c>();
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        List<PDLM__Category__c> categoriesToInsert = new List<PDLM__Category__c>();
        List<PDLM__Change__c> changesToInsert = new List<PDLM__Change__c>();

        changeAnalyst = [SELECT Id FROM User WHERE Propel_Change_Analyst__c = true LIMIT 1];

        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO', PDLM__primary_key__c = 'ECO');
        lifecyclesToInsert.add(lifecycle);
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(name='Assembly123', PDLM__primary_key__c = 'Assembly123');
        lifecyclesToInsert.add(lifecycleItem);
        insert lifecyclesToInsert;

        //ECO Lifecycle and related
        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(pendingPhase);
        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, 
                                                        PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(CCBPhase);
        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Released', PDLM__order__c = 3, 
                                                            PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycle.id);
        phasesToInsert.add(approvedPhase);
        
        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        categoriesToInsert.add(categoryForChange);

        //Item Lifecycle and Related
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

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Parts123', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        categoriesToInsert.add(categoryForPartItem);
        insert categoriesToInsert;

        //Create Change Orders
        change = new PDLM__Change__c(Name = 'ECO-000001 123', PDLM__Category__c = categoryForChange.Id, Final_Sap_Implementation_Date__c = date.today(),
                                     PDLM__title__c='Test SAP ECO', Change_Interface_Status__c = 'Completed', Change_Analyst__c = changeAnalyst.Id);
        
        changesToInsert.add(change);
        changeMakeBuy = new PDLM__Change__c(Name = 'ECO-000002 123', PDLM__Category__c = categoryForChange.Id, Final_Sap_Implementation_Date__c = date.today(),
                                     PDLM__title__c='Test SAP ECO', Change_Interface_Status__c = 'Completed', Change_Analyst__c = changeAnalyst.Id);
        changesToInsert.add(changeMakeBuy);
        insert changesToInsert;

        Propel_Lookup_Table__c mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected');

        //Create Items
        List<PDLM__Item__c> itemsListToInsert = new List<PDLM__Item__c>();
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Parent Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP');
        itemsListToInsert.add(parentItem1);
        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Parent Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZASP');
        itemsListToInsert.add(parentItem2);
        PDLM__Item__c childItem1 = new PDLM__Item__c(Name = 'Child Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZEQU');
        itemsListToInsert.add(childItem1);
        PDLM__Item__c childItem2 = new PDLM__Item__c(Name = 'Child Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZEQU');
        itemsListToInsert.add(childItem2);
        PDLM__Item__c childItem3 = new PDLM__Item__c(Name = 'Child Item 3', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ZEQU');
        itemsListToInsert.add(childItem3);
        insert itemsListToInsert;
       
        //Create Item Revisions
        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();
        parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, 
                                                    PDLM__Revision__c = 'A',
                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                    Description_Standard__c = 'Site Cart',
                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                    Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                    Sales_VC_BOM_Plant_Extension__c = 'US87:5:01;US13:3:01',
                                                    PDLM__Released__c = true,
                                                    PDLM__Related_Change__c = change.Id,
                                                    SAP_Material_Interface_Status__c = 'Completed');
        revsListToInsert.add(parentItem1Rev);
        parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, 
                                                    PDLM__Revision__c = 'A',
                                                    PDLM__Lifecycle_Phase__c = 'Production',
                                                    Description_Standard__c = 'N/A',
                                                    SAP_Material_Setup_Code__c = mscRecord.Id,
                                                    Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                    Sales_VC_BOM_Plant_Extension__c = 'US87:5:01;US13:3:01',
                                                    PDLM__Released__c = true,
                                                    PDLM__Related_Change__c = change.Id,
                                                    SAP_Material_Interface_Status__c = 'Completed');
        revsListToInsert.add(parentItem2Rev);
        PDLM__Item_Revision__c childItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                      PDLM__Released__c = true,
                                                      SAP_Material_Interface_Status__c = 'Completed');
        revsListToInsert.add(childItem1Rev);
        childItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem2.Id, 
                                                                        PDLM__Revision__c = 'A',
                                                                        PDLM__Lifecycle_Phase__c = 'Production',
                                                                        Description_Standard__c = 'N/A',
                                                                        SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                        Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                        PDLM__Released__c = true,
                                                                        SAP_Material_Interface_Status__c = 'Completed');
        revsListToInsert.add(childItem2Rev);
        PDLM__Item_Revision__c childItem3Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem3.Id, 
                                                                        PDLM__Revision__c = 'A',
                                                                        PDLM__Lifecycle_Phase__c = 'Production',
                                                                        Description_Standard__c = 'N/A',
                                                                        SAP_Material_Setup_Code__c = mscRecord.Id,
                                                                        Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                                        PDLM__Released__c = true,
                                                                        SAP_Material_Interface_Status__c = 'Completed');
        revsListToInsert.add(childItem3Rev);
        insert revsListToInsert;

        //Add Assemblies
        List<PDLM__Assembly__c> assListToInsert = new List<PDLM__Assembly__c>();
        ass1 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id,
                                                       PDLM__Item__c = childItem1.Id,
                                                       PDLM__Quantity__c = 1,
                                                       Line_Number__c = '10',
                                                       Disc_or_Follow__c = 'Follow Up',
                                                       Discontinue_Follow_Up_Group__c = 'A');
        assListToInsert.add(ass1);
        ass2 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem2.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass2);
        ass3 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem2Rev.Id,
                                                       PDLM__Item__c = childItem3.Id,
                                                       PDLM__Quantity__c = 1,
                                                       Line_Number__c = '10',
                                                       Disc_or_Follow__c = 'Follow Up',
                                                       Discontinue_Follow_Up_Group__c = 'A');
        assListToInsert.add(ass3);
        insert assListToInsert;

        //Insert SAP_BOM_Interface_Status__c record
        List<SAP_BOM_Interface_Status__c> statusesToInsert = new List<SAP_BOM_Interface_Status__c>();
        status1 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItem1Rev.Id, Site__c = 'US45:1:01');
        status2 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItem1Rev.Id, Site__c = 'US87:5:01');
        SAP_BOM_Interface_Status__c status3 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItem1Rev.Id, Site__c = 'US13:3:01');
        SAP_BOM_Interface_Status__c status4 = new SAP_BOM_Interface_Status__c(Item_Revision__c = parentItem2Rev.Id, Site__c = 'US45:1:01');
        statusesToInsert.add(status1);
        statusesToInsert.add(status2);
        statusesToInsert.add(status3);
        statusesToInsert.add(status4);
        insert statusesToInsert;
    }

    static PDLM__Change__c change;
    static PDLM__Change__c changeMakeBuy;
    static PDLM__Item_Revision__c parentItem1Rev;
    static PDLM__Item_Revision__c parentItem2Rev;
    static PDLM__Item_Revision__c makeBuyPartRev2;
    static PDLM__Item_Revision__c buyBuyPartRev2;
    static PDLM__Item_Revision__c childItem2Rev;
    static PDLM__Assembly__c ass1;
    static PDLM__Assembly__c ass2;
    static PDLM__Assembly__c ass3;
    static String sampleEndPoint;
    static User changeAnalyst;
    static SAP_BOM_Interface_Status__c status1;
    static SAP_BOM_Interface_Status__c status2;

    public class MockHttpResponseFailed implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method
            System.assertEquals(sampleEndPoint + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=SI_BOMFromPLM_InA&interfaceNamespace=urn%3AZoetis.com%2FSL%2FM2D%2F594%2FBillOfMaterialPLM', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake failed response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><ns0:MT_BOMFromPLM xmlns:ns0="urn:Zoetis.com/SL/M2D/594/BillOfMaterialPLM">'+
                        '<Header><BOM_Object_Id>TestaAB8B0000008YhpWAE</BOM_Object_Id><BOM_Usage>US45:01:01</BOM_Usage><Alternative_BOM>US45:01:01</Alternative_BOM>'+
                        '<Plant>US45:01:01</Plant><BOM_Header_Material>Parent Item 1</BOM_Header_Material><Base_Quantity></Base_Quantity>'+
                        '<Valid_From>2022-06-17</Valid_From><Change_indicator>false</Change_indicator><Change_Number>ECO-000001</Change_Number></Header>'+
                        '<Items><Line_Number>10</Line_Number><Item_Category></Item_Category><BOM_Component>Child Item 1</BOM_Component>'+
                        '<Quantity>1.000000</Quantity><Discontinued_group>Follow Up</Discontinued_group><FollowUp_Group>Follow Up</FollowUp_Group>'+
                        '<Discontinuation_Ind>A</Discontinuation_Ind><Valid_From>2022-06-17</Valid_From><Dependancy></Dependancy></Items>'+
                        '<Items><Line_Number></Line_Number><Item_Category></Item_Category><BOM_Component>Child Item 2</BOM_Component>'+
                        '<Quantity>1.000000</Quantity><Discontinued_group></Discontinued_group><FollowUp_Group></FollowUp_Group>'+
                        '<Discontinuation_Ind></Discontinuation_Ind><Valid_From>2022-06-17</Valid_From><Dependancy></Dependancy></Items></ns0:MT_BOMFromPLM>');
            res.setStatusCode(500);
            return res;
        }
    }

    public class MockHttpResponseSuccessful implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method
            System.assertEquals(sampleEndPoint + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=SI_BOMFromPLM_InA&interfaceNamespace=urn%3AZoetis.com%2FSL%2FM2D%2F594%2FBillOfMaterialPLM', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake failed response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><ns0:MT_BOMFromPLM xmlns:ns0="urn:Zoetis.com/SL/M2D/594/BillOfMaterialPLM">'+
                        '<Header><BOM_Object_Id>aAB8B0000008YhpWAE</BOM_Object_Id><BOM_Usage>US45:01:01</BOM_Usage><Alternative_BOM>US45:01:01</Alternative_BOM>'+
                        '<Plant>US45:01:01</Plant><BOM_Header_Material>Parent Item 1</BOM_Header_Material><Base_Quantity></Base_Quantity>'+
                        '<Valid_From>2022-06-17</Valid_From><Change_indicator>false</Change_indicator><Change_Number>ECO-000001</Change_Number></Header>'+
                        '<Items><Line_Number>10</Line_Number><Item_Category></Item_Category><BOM_Component>Child Item 1</BOM_Component>'+
                        '<Quantity>1.000000</Quantity><Discontinued_group>Follow Up</Discontinued_group><FollowUp_Group>Follow Up</FollowUp_Group>'+
                        '<Discontinuation_Ind>A</Discontinuation_Ind><Valid_From>2022-06-17</Valid_From><Dependancy></Dependancy></Items>'+
                        '<Items><Line_Number></Line_Number><Item_Category></Item_Category><BOM_Component>Child Item 2</BOM_Component>'+
                        '<Quantity>1.000000</Quantity><Discontinued_group></Discontinued_group><FollowUp_Group></FollowUp_Group>'+
                        '<Discontinuation_Ind></Discontinuation_Ind><Valid_From>2022-06-17</Valid_From><Dependancy></Dependancy></Items></ns0:MT_BOMFromPLM>');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testBOMPushFail() {
        SetUpData();

        Test.startTest();

        //Update Change to Released phase
        PDLM__Change_Phase__c changePhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];
        change.PDLM__Status_lk__c = changePhase.Id;
        update change;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailed());

        PropelPushPlantSpecBomsToSap tsub = new PropelPushPlantSpecBomsToSap();
        // Database.executeBatch(tsub);
        tsub.plmAnalystIdErroredRevIdsMap.put(changeAnalyst.Id, new Set<Id> {parentItem1Rev.Id});
        tsub.erroredRevIdPlantsMap.put(parentItem1Rev.Id, new List<String> {'US60'});
        tsub.finish(null);

        Test.stopTest();

        System.assertEquals(true, tsub.num_of_emails_sent >= 1);
    }

    @isTest static void testBOMPushSuccess() {
        SetUpData();

        Test.startTest();
        
        //Update Change to Released phase
        PDLM__Change_Phase__c changePhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];
        change.PDLM__Status_lk__c = changePhase.Id;
        update change;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessful());

        PropelPushPlantSpecBomsToSap tsub = new PropelPushPlantSpecBomsToSap();
        Database.executeBatch(tsub);

        Id changeId = change.Id;

        Test.stopTest();

        List<PDLM__Item_Revision__c> revs = [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c 
                                             WHERE PDLM__Related_Change__c = :changeId];

        System.assertEquals(2, revs.size());
        System.assertEquals('In Process', revs[0].SAP_BOM_Interface_Status__c);
        System.assertEquals('In Process', revs[1].SAP_BOM_Interface_Status__c);

        List<SAP_BOM_Interface_Status__c> statusesInProcess = [SELECT Id FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revs 
                                                               and SAP_BOM_Interface_Status__c = 'In Process'];
        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revs];
        
        System.assertEquals(4, statusesInProcess.size());
        System.assertEquals(4, statuses.size());
    }

    @isTest static void testBomsPushWithUnProcessedChildren() {
        SetUpData();

        Test.startTest();
        
        //Update Change to Released phase
        PDLM__Change_Phase__c changePhase = [SELECT Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];
        change.PDLM__Status_lk__c = changePhase.Id;
        update change;

        childItem2Rev.SAP_Material_Interface_Status__c = 'Failed';
        update childItem2Rev;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessful());

        PropelPushPlantSpecBomsToSap tsub = new PropelPushPlantSpecBomsToSap();
        Database.executeBatch(tsub);
        
        Id changeId = change.Id;

        Test.stopTest();

        List<PDLM__Item_Revision__c> revs = [SELECT Id, Name, SAP_BOM_Interface_Status__c FROM PDLM__Item_Revision__c 
                                             WHERE PDLM__Related_Change__c = :changeId];

        System.assertEquals(2, revs.size());

        List<SAP_BOM_Interface_Status__c> statusesInProcess = [SELECT Id FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revs 
                                                               and SAP_BOM_Interface_Status__c = 'In Process'];
        List<SAP_BOM_Interface_Status__c> statuses = [SELECT Id FROM SAP_BOM_Interface_Status__c WHERE Item_Revision__c in :revs];
        
        System.assertEquals(1, statusesInProcess.size());
        System.assertEquals(4, statuses.size());
    }

    @isTest static void testBomWithRelToSalesFalse() {
        SetUpData();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessful());

        PropelPushPlantSpecBomsToSap tsub = new PropelPushPlantSpecBomsToSap();
        tsub.execute(null, new List<SAP_BOM_Interface_Status__c> {status1});
        tsub.finish(null);

        Test.stopTest();

        System.assertEquals(true, tsub.xmlRequestOutput.contains('<Relvnt_to_Sales></Relvnt_to_Sales>'));

        // if (tsub.xmlRequestOutput.contains('<BOM_Header_Material>Parent Item 1') && 
        // (tsub.xmlRequestOutput.contains('<Plant>US87:5:01</Plant>') || 
        // tsub.xmlRequestOutput.contains('<Plant>US13:3:01</Plant>'))){
        //     System.assertEquals(true, tsub.xmlRequestOutput.contains('<Relvnt_to_Sales>X</Relvnt_to_Sales>'));
        // }
        // else{
        //     System.assertEquals(true, tsub.xmlRequestOutput.contains('<Relvnt_to_Sales></Relvnt_to_Sales>'));
        // }
    }

    @isTest static void testBomWithRelToSalesTrue() {
        SetUpData();

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessful());

        PropelPushPlantSpecBomsToSap tsub = new PropelPushPlantSpecBomsToSap();
        tsub.execute(null, new List<SAP_BOM_Interface_Status__c> {status2});
        tsub.finish(null);

        Test.stopTest();

        System.assertEquals(true, tsub.xmlRequestOutput.contains('<Relvnt_to_Sales>X</Relvnt_to_Sales>'));
    }
}