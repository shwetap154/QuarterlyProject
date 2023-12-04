global with sharing class PropelPushPlantSpecBomsToSap implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public static final integer DEFAULT_BATCHSIZE = 1; //DO NOT CHANGE; SAP can only process ONE BOM per Plant per transacton
    public static Integer batchSize;
    // Set<Id> erroredRevIdsList = new Set<Id>();
    public static String endPointUrl;
    public static PDLM__Configuration__c endPointUrlHost = [SELECT PDLM__Value__c FROM PDLM__Configuration__c WHERE Name = 'SapEndPointUrlHost' LIMIT 1];
    public Map<Id, List<String>> erroredRevIdPlantsMap = new Map<Id, List<String>>();
    public Map<Id, String> revIdItemNameMap = new Map<Id, String>();
    public Map<Id, Set<Id>> plmAnalystIdErroredRevIdsMap = new Map<Id, Set<Id>>();
    // @testVisible static Integer num_of_emails_sent = 0;
    // @testVisible static String xmlRequestOutput = null;
    public Integer num_of_emails_sent = 0;
    public String xmlRequestOutput = null;

    /**
     * PropelSAPIntegrationPreFilteringAndFieldUpdateTrigger will insert qualified BOMs to the SAP_BOM_Interface_Status__c custom object
     * It pushes from SAP_BOM_Interface_Status__c (custom object)
     * Propel pushes BOMs to SAP PI and do the following things
     *      1. Set the status to 'In Process' if the response status code = 200
     *      2. If there is an error when I try to reach to SAP PI, notify PLM Analyst
     *      3. Update PDLM__Item_Revision__c.SAP_BOM_Interface_Status__c = 'In Process'
     * 
     * Added on 08/16/2022
     *      - When Make_Buy__c changed from Make to Buy from Previously Released Revision to Latest Released Revision and Special Procurement != '30 - Subcontracting'
     *              - If BOM Status = 02, only send the BOM Header
     * 
     * Addded on 10/24/2022
     *      - For any new items on a BOM, don’t send the BOM until all new items have been successfully processed.  
     *      - The issue we are seeing is that when an ECO has new materials along with a BOM update, it will start pushing the BOM after the parent material is pushed. 
     *      - But the BOM can’t be pushed until all the new part numbers have been processed by SAP.
     * 
     * Added on 01/03/2023
     *      - Formula field is “Relevant to Sales” on the assy object
     *      - Condition: Only send the value to the plants specified in the “Sales/VC BOM Plant Extension”. 
     *        In other words, if the value is true and you have plants (values) in the Sales/VC BOM Plant Extension and the Manufacturing Plant Extension, you would only read and send the value for just the Sales/VC BOM. 
     *        For the manufacturing site would send no value. This value is for each child on the BOM. The manufacturing and VC/Sales BOM value comes from the parent.
     *      - For each plant-specific BOM pushed, if the Plant is from “Sales/VC BOM Plant Extension”, send the “Relevant to Sales” flag; otherwise, always default to False
     */

    /**
     * getBatchSize the as configured size is available to use
     */
    public Integer getBatchSize() {
        //SAP PI can only take one BOM per transaction so we need to set the batchSize = 1
        Integer batchSize = DEFAULT_BATCHSIZE;
        return batchSize;
    }

    //
    // Schedulable
    //
    public void execute(SchedulableContext sc) {
        if (endPointUrlHost == null){return;}
        
        Database.executeBatch(this, this.getBatchSize());
    }

    //
    // Batchable
    //
    public PropelPushPlantSpecBomsToSap() {
        batchSize = getBatchSize();
    }

    //
    // Batchable Interface
    //

    //Where the Batch starts
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Need to initialize this particular map again here
        plmAnalystIdErroredRevIdsMap = new Map<Id, Set<Id>>();
        revIdItemNameMap = new Map<Id, String>();
        endPointUrl = endPointUrlHost.PDLM__Value__c;

        return Database.getQueryLocator(
            [
                SELECT Id, Name, Item_Revision__c, SAP_BOM_Interface_Status__c, Site__c, Item_Revision__r.PDLM__Master_Item_Number__c, 
                       Item_Revision__r.PDLM__Related_Change__r.Change_Analyst__c
                FROM SAP_BOM_Interface_Status__c 
                WHERE (Item_Revision__r.PDLM__Related_Change__r.Change_Interface_Status__c = 'Completed'
                       OR Item_Revision__r.PDLM__Related_Change__r.Change_Interface_Status__c = 'Manually Completed')
                       AND (Item_Revision__r.SAP_Material_Interface_Status__c = 'Completed'
                       OR Item_Revision__r.SAP_Material_Interface_Status__c = 'Manually Completed')
                       AND Item_Revision__r.PDLM__Related_Change__r.PDLM__Status_lk__r.Name = 'Released'
                       AND Item_Revision__r.PDLM__Related_Change__r.PDLM__Category__r.Name IN ('ECO', 'ECO-QMS', 'BCO', 'BCO-QMS', 'VCO')
                       AND Item_Revision__r.Send_To_SAP__c = TRUE
                       AND Item_Revision__r.PDLM__Has_Bom__c = TRUE
                       AND SAP_BOM_Interface_Status__c = NULL
            ]
        );
    }

    //Where the Batch executes
    public void execute(Database.BatchableContext bc, List<SAP_BOM_Interface_Status__c> scope) {
        // List<SAP_BOM_Interface_Status__c> statuses = (List<SAP_BOM_Interface_Status__c>) scope;
        List<SAP_BOM_Interface_Status__c> bomStatusesToUpdate = new List<SAP_BOM_Interface_Status__c>();
        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        Set<Id> revIds = new Set<Id>();
        Map<Id, String> statusRecordIdStatusCodeMap = new Map<Id, String>();
        Map<String, SAP_BOM_Interface_Status__c> revIdPlantStatusRecordMap = new Map<String, SAP_BOM_Interface_Status__c>();
        Map<Id, SAP_BOM_Interface_Status__c> statusIdRecordMap = new Map<Id, SAP_BOM_Interface_Status__c>();
        Map<Id, List<PDLM__Assembly__c>> revIdBOMRecordsMap = new Map<Id, List<PDLM__Assembly__c>>();
        Map<Id, List<String>> revIdSitesMap = new Map<Id, List<String>>();
        Map<Id, PDLM__Item_Revision__c> revIdRevRecordMap = new Map<Id, PDLM__Item_Revision__c>();
        String returnedResCode = null;
        endPointUrl = endPointUrlHost.PDLM__Value__c;

        System.debug('statuses in the current batch: ' + scope);

        //Prepare the revIds
        for (SAP_BOM_Interface_Status__c status : scope){
            Id tempRevId = status.Item_Revision__c;
            revIdItemNameMap.put(tempRevId, status.Item_Revision__r.PDLM__Master_Item_Number__c);
            revIds.add(tempRevId);
            
            String revIdSiteConcat = tempRevId + '-' + status.Site__c;
            revIdPlantStatusRecordMap.put(revIdSiteConcat, status);
            statusIdRecordMap.put(status.Id, status);

            if (status.Site__c != null){
                if (!revIdSitesMap.containsKey(tempRevId)){
                    revIdSitesMap.put(tempRevId, new  List <String> {status.Site__c});
                }
                else{
                    revIdSitesMap.get(tempRevId).add(status.Site__c);
                }
            }
        }

        System.debug('revIdItemNameMap:' + revIdItemNameMap);
        System.debug('revIdPlantStatusRecordMap:' + revIdPlantStatusRecordMap);
        System.debug('statusIdRecordMap:' + statusIdRecordMap);
        System.debug('revIdSitesMap:' + revIdSitesMap);
        System.debug('revIds before removing parents with unprocessed children:' + revIds);

        //Removing any parents when there are unprocessed children
        for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item_Revision__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c in :revIds 
                                      AND (PDLM__Item__r.PDLM__Latest_Released_Revision__r.SAP_Material_Interface_Status__c = 'Failed' 
                                      OR PDLM__Item__r.PDLM__Latest_Released_Revision__r.SAP_Material_Interface_Status__c = 'In Process')]){
            if (revIds.contains(ass.PDLM__Item_Revision__c)){
                revIds.remove(ass.PDLM__Item_Revision__c);
            }
        }

        System.debug('revIds after removing parents with unprocessed children:' + revIds);

        for (PDLM__Item_Revision__c rev : [SELECT Id, SAP_BOM_Interface_Status__c, Manufacturing_Plant_Extension__c, 
                                           Sales_VC_BOM_Plant_Extension__c, PDLM__Master_Item_Number__c, 
                                           PDLM__Related_Change__r.Final_Sap_Implementation_Date__c, SAP_New_BOM__c, 
                                           Item_Number__c, PDLM__Related_Change__r.Name, Base_UOM__c, Special_Procurement__c, 
                                           Make_or_Buy__c, PDLM__Master_Item__r.Previously_Released_Revision__r.Make_or_Buy__c  
                                           FROM PDLM__Item_Revision__c WHERE Id in : revIds]){
            revIdRevRecordMap.put(rev.Id, rev);
        }

        System.debug('revIdRevRecordMap:' + revIdRevRecordMap);

        List<PDLM__Assembly__c> bomsToLoop = [SELECT Id, PDLM__Item_Revision__c, Line_Number__c, PDLM__Item_Number__c, PDLM__Quantity__c, 
                                              Discontinue_Follow_Up_Group__c, Disc_or_Follow__c, VC_Dependency__c, 
                                              PDLM__Item__r.PDLM__Latest_Released_Revision__r.Base_UOM__c, 
                                              Relevant_to_Sales__c, PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c 
                                              FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c in : revIds
                                              and Send_To_SAP__c = TRUE];

        for (PDLM__Assembly__c ass : bomsToLoop){
            if (!revIdBOMRecordsMap.containsKey(ass.PDLM__Item_Revision__c)){
                revIdBOMRecordsMap.put(ass.PDLM__Item_Revision__c, new  List <PDLM__Assembly__c> {ass});
            }
            else{
                revIdBOMRecordsMap.get(ass.PDLM__Item_Revision__c).add(ass);
            }
        }

        System.debug('revIdBOMRecordsMap:' + revIdBOMRecordsMap);

        if (revIdBOMRecordsMap.size() == 0){return;}
        
        //Loop through revIdBOMRecordsMap and Callout to SAP for each BOM and for each Plant/Site
        for (Id revId : revIdBOMRecordsMap.keySet()){
            List<PDLM__Assembly__C> tempBOMsList = revIdBOMRecordsMap.get(revId);
            List<String> tempSites = revIdSitesMap.get(revId);
            Map<Id, String> assChildItemMap = new Map<Id, String>();
            Map<Id, String> assLineNumberMap = new Map<Id, String>();
            Map<Id, String> assQuantityMap = new Map<Id, String>();
            Map<Id, String> assDiscFollowMap = new Map<Id, String>();
            Map<Id, String> assDiscFollowGroupMap = new Map<Id, String>();
            Map<Id, String> assDependenctMap = new Map<Id, String>();
            Map<Id, String> childItemBaseUomMap = new Map<Id, String>();
            Map<Id, PDLM__Assembly__c> bomIdBomRecordMap = new Map<Id, PDLM__Assembly__c>();

            PropelPushPlantSpecBomsToSap.requestParameters req = new PropelPushPlantSpecBomsToSap.requestParameters ();
            PDLM__Item_Revision__c tempRevForReq = revIdRevRecordMap.get(revId);
            // req.ITEM_REV_ID= revId;
            req.PARENT_ITEM = tempRevForReq.Item_Number__c;
            req.SAP_IMPL_DATE = String.valueOf(tempRevForReq.PDLM__Related_Change__r.Final_Sap_Implementation_Date__c);
            req.CHANGE_INDICATOR = String.valueOf(tempRevForReq.SAP_New_BOM__c);
            req.CHANGE_NUMBER = tempRevForReq.PDLM__Related_Change__r.Name;
            req.PARENT_UOM = tempRevForReq.Base_UOM__c;
            
            if (tempRevForReq.Special_Procurement__c != '30 - Subcontracting' && tempRevForReq.Make_or_Buy__c == 'Buy' && 
            tempRevForReq.PDLM__Master_Item__r.Previously_Released_Revision__r.Make_or_Buy__c  == 'Make'){
                req.BOM_STATUS = '02';
            }
            else{
                req.BOM_STATUS = '01';
            }

            for (PDLM__Assembly__c bom : tempBOMsList){
                assChildItemMap.put(bom.Id, bom.PDLM__Item_Number__c);
                assLineNumberMap.put(bom.Id, bom.Line_Number__c);
                assQuantityMap.put(bom.Id, String.valueOf(bom.PDLM__Quantity__c));
                assDiscFollowMap.put(bom.Id, bom.Disc_or_Follow__c);
                assDiscFollowGroupMap.put(bom.Id, bom.Discontinue_Follow_Up_Group__c);
                assDependenctMap.put(bom.Id, bom.VC_Dependency__c);
                childItemBaseUomMap.put(bom.Id, bom.PDLM__Item__r.PDLM__Latest_Released_Revision__r.Base_UOM__c);
                bomIdBomRecordMap.put(bom.Id, bom);
            }

            for (String tempSite : tempSites){
                //This needs to be inside  this loop since it's always a new list when a new site starts
                List <PropelPushPlantSpecBomsToSap.requestParameters> data = new List<PropelPushPlantSpecBomsToSap.requestParameters>();
                String revIdSiteConcat = revId + '-' + tempSite;
                Id SapBomInterfaceStatusRecordId = revIdPlantStatusRecordMap.get(revIdSiteConcat).Id;

                req.PLANT_EXT_SINGLE = tempSite;
                req.SAP_BOM_INTERFACE_STATUS_ID = SapBomInterfaceStatusRecordId;
                data.add(req);

                //Callout to SAP to push the site-specific BOMs
                returnedResCode = PropelPushPlantSpecBomsToSapXml(data,bomIdBomRecordMap,assChildItemMap,assLineNumberMap,assQuantityMap,assDiscFollowMap,assDiscFollowGroupMap,assDependenctMap,childItemBaseUomMap, endPointUrl);
                System.debug('returnedResCode: ' + returnedResCode);
                
                statusRecordIdStatusCodeMap.put(SapBomInterfaceStatusRecordId, returnedResCode);
                
                if (returnedResCode == 'Send Error Email'){
                    if (!erroredRevIdPlantsMap.containsKey(revId)){
                        erroredRevIdPlantsMap.put(revId, new List<String> {tempSite});
                    }   
                    else{
                        erroredRevIdPlantsMap.get(revId).add(tempSite);
                    }
                }
            }
        }

        System.debug('statusRecordIdStatusCodeMap: ' + statusRecordIdStatusCodeMap);
        System.debug('erroredRevIdPlantsMap: ' + erroredRevIdPlantsMap);

        //Update SAP_BOM_Interface_Status__c on Item Revision with if successful
        for (Id recordId : statusRecordIdStatusCodeMap.keySet()){
            Id revId = statusIdRecordMap.get(recordId).Item_Revision__c;
            Id changeAnalystId = statusIdRecordMap.get(recordId).Item_Revision__r.PDLM__Related_Change__r.Change_Analyst__c;

            if (statusRecordIdStatusCodeMap.get(recordId) == '200'){
                SAP_BOM_Interface_Status__c tempStatus = statusIdRecordMap.get(recordId);
                tempStatus.SAP_BOM_Interface_Status__c = 'In Process';
                bomStatusesToUpdate.add(tempStatus);
                
                PDLM__Item_Revision__c tempRev = revIdRevRecordMap.get(revId);
                if (!revsToUpdate.contains(tempRev)){
                    tempRev.SAP_BOM_Interface_Status__c = 'In Process';
                    revsToUpdate.add(tempRev);
                }
            }
            else{
                // erroredRevIdsList.add(revId);

                if (changeAnalystId != null){
                    if(!plmAnalystIdErroredRevIdsMap.containsKey(changeAnalystId)){
                        plmAnalystIdErroredRevIdsMap.put(changeAnalystId, new Set<Id> {revId});
                    }
                    else{
                        plmAnalystIdErroredRevIdsMap.get(changeAnalystId).add(revId);
                    }
                }
            }
        }

        System.debug('bomStatusesToUpdate: ' + bomStatusesToUpdate);
        System.debug('revsToUpdate: ' + revsToUpdate);

        //DMLs
        if (bomStatusesToUpdate.size() > 0){
            update bomStatusesToUpdate;
        }

        if (revsToUpdate.size() > 0){
            update revsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        //Need to send email after the batch job is done
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        // List<Id> propelAdminMemberIdsList = new List<Id>();

        // for (GroupMember mem : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Propel_Admin']){
        //     if (mem.UserOrGroupId.getSobjectType() == User.SObjectType){
        //         propelAdminMemberIdsList.add(mem.UserOrGroupId);
        //     }
        // }   

        // System.debug('propelAdminMemberIdsList: ' + propelAdminMemberIdsList);
        // System.debug('erroredRevIdsList: ' + erroredRevIdsList);
        System.debug('erroredRevIdPlantsMap: ' + erroredRevIdPlantsMap);
        System.debug('plmAnalystIdErroredRevIdsMap: ' + plmAnalystIdErroredRevIdsMap);
        
        //Loop and construct the emails from revIdMessageMap
        if (plmAnalystIdErroredRevIdsMap.size() > 0){
            //Construct the emails from erroredItemsList
            //Email the Propel Admin Group when there is an error
            for (Id chgAnalyst : plmAnalystIdErroredRevIdsMap.keySet()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String erroredRevsString = '';
                Set<Id> tempErroredRevIdsList = plmAnalystIdErroredRevIdsMap.get(chgAnalyst);
                List<Id> recipientList = new List<Id> {chgAnalyst};

                for (Id revId : tempErroredRevIdsList){
                    if (erroredRevsString == ''){
                        erroredRevsString = '<ul>';
                    }

                    erroredRevsString += '<li>' + '<a href=\"' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + revId 
                                            + '\">'+ revIdItemNameMap.get(revId) + '</a>' + ': ' + String.valueOf(erroredRevIdPlantsMap.get(revId)).replace('(', '').replace(')', '') + '</li>';
                }
                if (erroredRevsString != ''){
                    erroredRevsString += '</ul>';
                }

                mail.setToAddresses(recipientList);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setSenderDisplayName(userInfo.getName());
                mail.setSubject('SAP INTEGRATION: ' + 'Fail to Push BOMs to SAP');
                
                mail.setHtmlBody('Hello,'
                                + '<br><br>Propel failed to push site specific BOMs to SAP. Please see the list of parent Item Revisions below.'
                                + erroredRevsString
                                + '<br>Thank you,<br>Propel');

                mails.add(mail);
            }

            //Send Emails
            try {
                num_of_emails_sent = mails.size();
                Messaging.reserveSingleEmailCapacity(num_of_emails_sent);
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
                System.debug('Number of emails sent: ' + num_of_emails_sent);
                System.debug('Email Results: ' + result);
            } catch (Exception e) {
                // deal with failure to send
                System.debug(LoggingLevel.WARN, 'Exception: ' + e);
            }
        }

        System.debug(Logginglevel.WARN, 'PropelPushPlantSpecBomsToSap: finish()');
    }

    public class requestParameters{
        public String SAP_BOM_INTERFACE_STATUS_ID = '';
        public String PLANT_EXT_SINGLE = '';
        public String PARENT_ITEM = '';
        public String SAP_IMPL_DATE = '';
        public String CHANGE_INDICATOR = '';
        public String CHANGE_NUMBER = '';
        public String PARENT_UOM = '';
        public String BOM_STATUS = '';
    }

    public String PropelPushPlantSpecBomsToSapXml(List<requestParameters> data, Map<Id, PDLM__Assembly__c> bomIdBomRecordMap, Map<Id,String> assChildItemMap, 
    Map<Id,String> assLineNumberMap, Map<Id,String> assQuantityMap, Map<Id,String> assDiscFollowMap, 
    Map<Id,String> assDiscFollowGroupMap, Map<Id,String> assDependenctMap, Map<Id, String> childItemBaseUomMap, String endPointUrlHostName){
        String returnedStatusCode = null;
        String endpoint_x = endPointUrlHostName + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=SI_BOMFromPLM_InA&interfaceNamespace=urn%3AZoetis.com%2FSL%2FM2D%2F594%2FBillOfMaterialPLM';
        String username = 'rfcuser_plm';
        String password = 'zoetis123@';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        String xmlStart = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +
                          'xmlns:bil="urn:Zoetis.com/SL/M2D/594/BillOfMaterialPLM"><soapenv:Header/>' + 
                          '<soapenv:Body><bil:MT_BOMFromPLM>';
        String xmlBodyBomHeader = '';
        String xmlBodyChildren = '';
        String xmlBodyClose = '</bil:MT_BOMFromPLM></soapenv:Body></soapenv:Envelope>';
        String changeValidFrom = null;
        String bomStatus = null;
        // Boolean tempRelToSalesFlag = false;
        String tempRelToSalesFlag = '';
        String currentPlant = null;

        //SAP BOM Header
        for (requestParameters r : data){
            xmlBodyBomHeader += '<Header>' +
                                '<BOM_Object_Id>' + r.SAP_BOM_INTERFACE_STATUS_ID + '</BOM_Object_Id>' + 
                                '<BOM_Usage>' + r.PLANT_EXT_SINGLE + '</BOM_Usage>' +
                                '<Alternative_BOM>' + r.PLANT_EXT_SINGLE + '</Alternative_BOM>' +
                                '<Plant>' + r.PLANT_EXT_SINGLE + '</Plant>' +
                                '<BOM_Header_Material>' + r.PARENT_ITEM + '</BOM_Header_Material>' +
                                '<Base_Quantity></Base_Quantity>' + 
                                '<Valid_From>' + r.SAP_IMPL_DATE + '</Valid_From>' +
                                '<Change_indicator>' + r.CHANGE_INDICATOR + '</Change_indicator>' +
                                '<Change_Number>' + r.CHANGE_NUMBER + '</Change_Number>' +
                                '<Base_UOM>' + r.PARENT_UOM + '</Base_UOM>' +
                                // '<BOM_Status>' + r.BOM_STATUS + '</BOM_Status>' + //Commented out on 08/22/2022
                                '</Header>';
            changeValidFrom = r.SAP_IMPL_DATE;
            bomStatus = r.BOM_STATUS;
            currentPlant = r.PLANT_EXT_SINGLE;
        }

        //SAP BOM Children
        if (bomStatus == '02'){
            xmlBodyChildren += '';
        }
        else{
            for (Id bomId : assChildItemMap.keySet()) {
                String tempLineNumber = assLineNumberMap.get(bomId) != null ? assLineNumberMap.get(bomId) : '';
                String tempBomComponent = assChildItemMap.get(bomId) != null ? assChildItemMap.get(bomId) : '';
                String tempQuantity = assQuantityMap.get(bomId) != null ? assQuantityMap.get(bomId) : '';
                String tempDiscFollowUp = assDiscFollowMap.get(bomId) != null ? assDiscFollowMap.get(bomId) : '';
                String tempDiscIndicator = assDiscFollowGroupMap.get(bomId) != null ? assDiscFollowGroupMap.get(bomId) : '';
                String tempDependency = assDependenctMap.get(bomId) != null ? assDependenctMap.get(bomId) : '';
                String tempBaseUom = childItemBaseUomMap.get(bomId) != null ? childItemBaseUomMap.get(bomId) : '';
                List<String> currrentSalesVcSites = bomIdBomRecordMap.containsKey(bomId) && bomIdBomRecordMap.get(bomId).PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c != null ? bomIdBomRecordMap.get(bomId).PDLM__Item_Revision__r.Sales_VC_BOM_Plant_Extension__c.split(';') : new List<String>();
                if (bomIdBomRecordMap.containsKey(bomId) && currrentSalesVcSites.contains(currentPlant)){
                    // tempRelToSalesFlag = bomIdBomRecordMap.get(bomId).Relevant_to_Sales__c;
                    tempRelToSalesFlag = 'X';
                } 

                xmlBodyChildren += '<Items>' + 
                                '<Line_Number>' + tempLineNumber + '</Line_Number>' +
                                '<Item_Category></Item_Category>' + 
                                '<BOM_Component>' + tempBomComponent + '</BOM_Component>' +
                                '<Quantity>' + tempQuantity + '</Quantity>' +
                                '<Discontinued_group>' + tempDiscFollowUp + '</Discontinued_group>' +
                                //    '<FollowUp_Group>' + tempDiscFollowUp + '</FollowUp_Group>' + //Commented out on 08/08/2022
                                '<Discontinuation_Ind>' + tempDiscIndicator + '</Discontinuation_Ind>' +
                                '<Valid_From>' + changeValidFrom + '</Valid_From>' + 
                                '<Dependancy>' + tempDependency + '</Dependancy>' +
                                '<Base_UOM>' + tempBaseUom + '</Base_UOM>' +
                                '<Relvnt_to_Sales>' + tempRelToSalesFlag+ '</Relvnt_to_Sales>' +
                                '</Items>';
            }
        }

        String xmlRequest = xmlStart + xmlBodyBomHeader + xmlBodyChildren + xmlBodyClose;
        xmlRequestOutput = xmlRequest;
        
        System.debug('xmlRequest: ' + xmlRequest);
        
        //Post the request to get the response
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndPoint(endpoint_x);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/xml');
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(xmlRequest);
        HTTPResponse res = h.send(req); 

        //Check returned response
        if (res.getStatusCode() == 200){
            returnedStatusCode = String.valueOf(res.getStatusCode());
        }
        else {
            returnedStatusCode = 'Send Error Email';
        }

        System.debug('returnedStatusCode:' + returnedStatusCode);
        return returnedStatusCode;
    }
}