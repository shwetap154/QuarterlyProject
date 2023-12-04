@isTest 
public with sharing class PropelPullCostAndPlantExtFromSAPTest {
    static void SetUpData(){
        //Create Configuration entries
        List <PDLM__Configuration__c> configs = new List<PDLM__Configuration__c>();
        PDLM__Configuration__c config1 = new PDLM__Configuration__c(Name = 'SapSyncFrequency', PDLM__Value__c = 'Weekly');
        PDLM__Configuration__c config2 = new PDLM__Configuration__c(Name = 'SapCostPlantBatchScope', PDLM__Value__c = '200');
        PDLM__Configuration__c config3 = new PDLM__Configuration__c(Name = 'SapEndPointUrlHost', PDLM__Value__c = 'https://sldx3.zoetis.com');
        configs.add(config1);
        configs.add(config2);
        configs.add(config3);
        insert configs;

        sampleEndPoint = config3.PDLM__Value__c;
        
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        List<PDLM__Category__c> categoriesToInsert = new List<PDLM__Category__c>();

        //ECO Lifecycle and related
        PDLM__Lifecycle__c lifecycle = new PDLM__Lifecycle__c(name='ECO');
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

        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycle.id);
        categoriesToInsert.add(categoryForChange);

        //Item Lifecycle and Related
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(name='Assembly123', PDLM__primary_key__c = 'Assembly123');
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

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Parts123', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        categoriesToInsert.add(categoryForPartItem);
        insert categoriesToInsert;

        //Create Change Orders
        change = new PDLM__Change__c(Name = 'Test Change 123', PDLM__Category__c = categoryForChange.id, PDLM__title__c='Test SAP ECO');
        insert change;

        Propel_Lookup_Table__c mscRecord = new Propel_Lookup_Table__c(Name = 'No Valid MSC Selected');

        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();

        //Create Paretnt Item and Item Revision
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Item 1', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem1;
        PDLM__Item_Revision__c parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Prototype',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                      PDLM__Released__c = true,
                                                      PDLM__Related_Change__c = change.Id);
        revsListToInsert.add(parentItem1Rev);

        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Item 2', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem2;
        parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                      PDLM__Released__c = true,
                                                      SAP_Material_Interface_Status__c = 'Completed',
                                                      PDLM__Related_Change__c = change.Id);
        revsListToInsert.add(parentItem2Rev);

        PDLM__Item__c parentItem3 = new PDLM__Item__c(Name = 'Item 3', PDLM__Category__c = categoryForPartItem.id, SAP_Material_Type__c = 'ROH');
        insert parentItem3;
        parentItem3Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem3.Id, 
                                                      PDLM__Revision__c = 'A',
                                                      PDLM__Lifecycle_Phase__c = 'Production',
                                                      Description_Standard__c = 'N/A',
                                                      SAP_Material_Setup_Code__c = mscRecord.Id,
                                                      Manufacturing_Plant_Extension__c = 'US45:1:01',
                                                      PDLM__Released__c = true,
                                                      SAP_Material_Interface_Status__c = 'Completed',
                                                      PDLM__Related_Change__c = change.Id);
        revsListToInsert.add(parentItem3Rev);

        insert revsListToInsert;

        // //Add Affected Items
        // List<PDLM__Affected_Item__c> aisListToInsert = new List<PDLM__Affected_Item__c>();
        // PDLM__Affected_Item__c ai1 = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        // aisListToInsert.add(ai1);

        // PDLM__Affected_Item__c ai2 = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        // aisListToInsert.add(ai2);

        // PDLM__Affected_Item__c ai3 = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem3Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        // aisListToInsert.add(ai3);

        // insert aisListToInsert;
    }

    static PDLM__Change__c change;
    static PDLM__Item_Revision__c parentItem2Rev;
    static PDLM__Item_Revision__c parentItem3Rev;
    static String sampleEndPoint;

    public class MockHttpResponseFailed implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method
            System.assertEquals(sampleEndPoint + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=ZM2D_GET_MATCOST_PLNTEXT&interfaceNamespace=urn%3Asap-com%3Adocument%3Asap%3Arfc%3Afunctions', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake failed response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Header/><SOAP:Body><ns0:ZM2D_GET_MATCOST_PLNTEXT.Response xmlns:ns0="urn:sap-com:document:sap:rfc:functions"><ET_OUTPUT><item><SFDC_ID>GUID_5</SFDC_ID><MAT_COST>0</MAT_COST><SITES_EXT/><MESSAGE>Material:95050322 not extended to any plant</MESSAGE></item></ET_OUTPUT></ns0:ZM2D_GET_MATCOST_PLNTEXT.Response></SOAP:Body></SOAP:Envelope>');
            res.setStatusCode(500);
            return res;
        }
    }

    public class MockHttpResponseSuccessful implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method
            System.assertEquals(sampleEndPoint + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=ZM2D_GET_MATCOST_PLNTEXT&interfaceNamespace=urn%3Asap-com%3Adocument%3Asap%3Arfc%3Afunctions', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake failed response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Header/>' + 
                        '<SOAP:Body><ns0:ZM2D_GET_MATCOST_PLNTEXT.Response xmlns:ns0="urn:sap-com:document:sap:rfc:functions">' + 
                        '<ET_OUTPUT><item><SFDC_ID>' + parentItem2Rev.Id + '</SFDC_ID><MAT_COST>1</MAT_COST><SITES_EXT/>' + 
                        '<MESSAGE>Material:95050322 not extended to any plant</MESSAGE></item></ET_OUTPUT>' + 
                        '</ns0:ZM2D_GET_MATCOST_PLNTEXT.Response></SOAP:Body></SOAP:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockHttpResponseSuccessfulSite implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint and method
            System.assertEquals(sampleEndPoint + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=ZM2D_GET_MATCOST_PLNTEXT&interfaceNamespace=urn%3Asap-com%3Adocument%3Asap%3Arfc%3Afunctions', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake failed response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Header/>' + 
                        '<SOAP:Body><ns0:ZM2D_GET_MATCOST_PLNTEXT.Response xmlns:ns0="urn:sap-com:document:sap:rfc:functions">' + 
                        '<ET_OUTPUT><item><SFDC_ID>' + parentItem2Rev.Id + '</SFDC_ID><MAT_COST>1</MAT_COST><SITES_EXT>US45</SITES_EXT>' + 
                        '<MESSAGE>Material:95050322 not extended to any plant</MESSAGE></item></ET_OUTPUT>' + 
                        '</ns0:ZM2D_GET_MATCOST_PLNTEXT.Response></SOAP:Body></SOAP:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testCostExtendedSitesPullFail() {
        SetUpData();

        Test.startTest();

        PDLM__Change_Phase__c releasedStatus = [Select Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];

        change.PDLM__Status_lk__c = releasedStatus.Id;
        update change;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFailed());

        PropelPullCostAndPlantExtFromSAPBatch tsub = new PropelPullCostAndPlantExtFromSAPBatch();
        // Database.executeBatch(tsub);
        tsub.revIdRevMap.put(parentItem2Rev.Id, parentItem2Rev);
        tsub.revIdMessageMap.put(parentItem2Rev.Id, 'Test Text');
        tsub.erroredItemsList.add(parentItem2Rev.PDLM__Master_Item_Number__c);
        tsub.finish(null);

        Test.stopTest();
        
        // System.assertEquals(1, PropelPullCostAndPlantExtFromSAPBatch.num_of_emails_sent);
        System.assertEquals(2, tsub.num_of_emails_sent);
    }

    @isTest static void testCostExtendedSitesPullSuccess() {
        SetUpData();

        Test.startTest();
        PDLM__Change_Phase__c releasedStatus = [Select Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];

        change.PDLM__Status_lk__c = releasedStatus.Id;
        update change;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessful());

        PropelPullCostAndPlantExtFromSAPBatch tsub = new PropelPullCostAndPlantExtFromSAPBatch();
        Database.executeBatch(tsub);

        Id parentRevId = parentItem2Rev.Id;

        Test.stopTest();

        PDLM__Item_Revision__c rev = [SELECT Id, Name, Unit_Cost__c, Extended_Site_s__c FROM PDLM__Item_Revision__c WHERE Id = :parentRevId];
        System.assertEquals(1, rev.Unit_Cost__c);
        System.assertEquals(null, rev.Extended_Site_s__c);
    }

    @isTest static void testCostExtendedSitesPullSuccessWithSite() {
        SetUpData();

        Test.startTest();
        PDLM__Change_Phase__c releasedStatus = [Select Id FROM PDLM__Change_Phase__c WHERE PDLM__Change_lk__c = :change.Id and Name = 'Released' LIMIT 1];

        change.PDLM__Status_lk__c = releasedStatus.Id;
        update change;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccessfulSite());

        PropelPullCostAndPlantExtFromSAPBatch tsub = new PropelPullCostAndPlantExtFromSAPBatch();
        Database.executeBatch(tsub);

        Id parentRevId = parentItem2Rev.Id;

        Test.stopTest();

        PDLM__Item_Revision__c rev = [SELECT Id, Name, Unit_Cost__c, Extended_Site_s__c FROM PDLM__Item_Revision__c WHERE Id = :parentRevId];
        System.assertEquals(1, rev.Unit_Cost__c);
        System.assertEquals('US45', rev.Extended_Site_s__c);
    }
}