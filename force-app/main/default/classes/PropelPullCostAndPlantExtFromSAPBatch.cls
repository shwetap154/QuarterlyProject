global with sharing class PropelPullCostAndPlantExtFromSAPBatch implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public static final integer DEFAULT_BATCHSIZE = 200;
    public static Integer batchSize;
    public static String endPointUrl;
    public static PDLM__Configuration__c cfgFrequency = [SELECT PDLM__Value__c FROM PDLM__Configuration__c WHERE Name = 'SapSyncFrequency' LIMIT 1];
    public static PDLM__Configuration__c costPlantBatchScope = [SELECT PDLM__Value__c FROM PDLM__Configuration__c WHERE Name = 'SapCostPlantBatchScope' LIMIT 1];
    public static PDLM__Configuration__c endPointUrlHost = [SELECT PDLM__Value__c FROM PDLM__Configuration__c WHERE Name = 'SapEndPointUrlHost' LIMIT 1];
    public Map<Id, String> revIdMessageMap = new Map<Id, String>();
    public List<String> erroredItemsList = new List<String>();
    public Map<Id, PDLM__Item_Revision__c> revIdRevMap = new Map<Id, PDLM__Item_Revision__c>();
    // @testVisible static Integer num_of_emails_sent = 0;
    public Integer num_of_emails_sent = 0;
    
    /**
     * getBatchSize the as configured size is available to use
     * as a default or as configured with 'SapCostPlantBatchScope'
     * custom Configuration setting, default is DEFAULT_BATCHSIZE
     */
    public Integer getBatchSize() {
        Integer batchSize = DEFAULT_BATCHSIZE;

        if (costPlantBatchScope != null && Integer.valueof(costPlantBatchScope.PDLM__Value__c) > 0 && Integer.valueof(costPlantBatchScope.PDLM__Value__c) <= 200) {
            batchSize = Integer.valueof(costPlantBatchScope.PDLM__Value__c) ;
        }

        return batchSize;
    }

    //
    // Schedulable
    //
    public void execute(SchedulableContext sc) {
        //Don't execute if frequency is not set
        if (cfgFrequency == null){return;}
        if (endPointUrlHost == null){return;}

        Database.executeBatch(this, this.getBatchSize());
    }

    //
    // Batchable
    //
    public PropelPullCostAndPlantExtFromSAPBatch() {
        batchSize = getBatchSize();
    }

    //
    // Batchable Interface
    //

    //Where the Batch starts
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        endPointUrl = endPointUrlHost.PDLM__Value__c;

        if (cfgFrequency.PDLM__Value__c == 'Annually'){
            return Database.getQueryLocator(
                    [
                        SELECT Id, Name, Unit_Cost__c, Extended_Site_s__c, Manufacturing_Plant_Extension__c 
                        FROM PDLM__Item_Revision__c 
                        WHERE PDLM__Is_Latest_Released__c = true
                        AND SAP_Material_Type_Formula__c in ('ZASP', 'ZEQU', 'ROH') 
                        AND PDLM__Lifecycle_Phase__c in ('Pre-Production', 'Production', 'Discontinued')
                    ]
            );
        }
        else{
            return Database.getQueryLocator(
                [
                    SELECT Id, Name, PDLM__Master_Item_Number__c, Unit_Cost__c, Extended_Site_s__c, Manufacturing_Plant_Extension__c 
                    FROM PDLM__Item_Revision__c 
                    WHERE PDLM__Is_Latest_Released__c = true
                    AND (Unit_Cost__c = null or Unit_Cost__c = 0)  
                    AND SAP_Material_Type_Formula__c in ('ZASP', 'ZEQU', 'ROH') 
                    AND PDLM__Lifecycle_Phase__c in ('Pre-Production', 'Production', 'Discontinued')
                ]
            );
        }
    }

    //Where the Batch executes
    public void execute(Database.BatchableContext bc, List<PDLM__Item_Revision__c> scope) {
        // List<PDLM__Item_Revision__c> revs = (List<PDLM__Item_Revision__c>) scope;
        List<PDLM__Item_Revision__c> revsToUpdate = new List<PDLM__Item_Revision__c>();
        String returnedResBody = null;
        endPointUrl = endPointUrlHost.PDLM__Value__c;

        //Prepare the revIds
        for (PDLM__Item_Revision__c rev : scope){
            revIdRevMap.put(rev.Id, rev);
        }

        System.debug('revIdRevMap:' + revIdRevMap);

        //Callout to SAP
        if (revIdRevMap.size() > 0){
            List <PropelPullCostAndPlantExtFromSAPBatch.requestParameters> data = new List<PropelPullCostAndPlantExtFromSAPBatch.requestParameters>();

            for (Id revId : revIdRevMap.keySet()){
                PropelPullCostAndPlantExtFromSAPBatch.requestParameters req = new PropelPullCostAndPlantExtFromSAPBatch.requestParameters ();
                req.SFDC_ID= revIdRevMap.get(revId).Id;
                req.MATERIAL = revIdRevMap.get(revId).PDLM__Master_Item_Number__c;
                //Per Greg: for the Site field, you will pull this from “Manufacturing Plant Extension” field in PLM. 
                //Only pull the first 4 characters from that list value.
                if (revIdRevMap.get(revId).Manufacturing_Plant_Extension__c != null && 
                revIdRevMap.get(revId).Manufacturing_Plant_Extension__c != '<<< Not Applicable >>>'){
                    req.SITE = revIdRevMap.get(revId).Manufacturing_Plant_Extension__c.left(4);
                }
                else{
                    req.SITE = '';
                }
                data.add(req);
            }

            returnedResBody = PropelPullCostAndPlantExtFromSapXml(data, endPointUrl);
        }

        //Update Item Revision with Cost Data nd Plant Extension Data if successful
        if (returnedResBody != 'Send Error Email'){
            //Start parsing the returned body here
            XmlStreamReader reader = new XmlStreamReader(returnedResBody);
            system.debug('reader: ' + reader);

            while (reader.hasNext()) {
                PDLM__Item_Revision__c tempRev = null;
                Double tempCost = null;
                String tempSites = null;

                System.debug('$$$ reader.getEventType(): ' + reader.getEventType());

                if (reader.hasName()) {
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SFDC_ID'){
                        System.debug('$$$ reader.getLocalName() revId: ' + reader.getLocalName());
        
                        reader.next();
        
                        if (reader.hasText()){
                            System.debug('$$$ revId: ' + reader.getText());
                            
                            Id tempRevId = reader.getText();
                            tempRev = revIdRevMap.get(tempRevId);
                        }

                        while (reader.getEventType() != XmlTag.START_ELEMENT && reader.getLocalName() != 'MAT_COST'){
                            reader.next();
                        }

                        if (tempRev != null && reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MAT_COST'){
                            System.debug('$$$ reader.getLocalName() cost: ' + reader.getLocalName());
            
                            reader.next();
            
                            if (reader.hasText()){
                                System.debug('$$$ cost: ' + reader.getText());
                                
                                tempCost = Double.valueOf(reader.getText());
                                tempRev.Unit_Cost__c = tempCost;
                            }
                        }

                        System.debug('tempCost: ' + tempCost);

                        while (reader.getEventType() != XmlTag.START_ELEMENT && reader.getLocalName() != 'SITES_EXT'){
                            reader.next();
                        }

                        if (tempRev != null && reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SITES_EXT'){
                            System.debug('$$$ reader.getLocalName() sites: ' + reader.getLocalName());
            
                            reader.next();
            
                            if (cfgFrequency.PDLM__Value__c == 'Weekly' && reader.hasText()){
                                System.debug('$$$ sites: ' + reader.getText());
    
                                tempSites = reader.getText();
                                tempRev.Extended_Site_s__c = tempSites;
                            }
                        }

                        while (reader.getEventType() != XmlTag.START_ELEMENT && reader.getLocalName() != 'MESSAGE'){
                            reader.next();
                        }

                        if (tempRev != null && reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MESSAGE'){
                            System.debug('$$$ reader.getLocalName() message: ' + reader.getLocalName());
            
                            reader.next();
            
                            if (reader.hasText()){
                                System.debug('$$$ message: ' + reader.getText());
                                revIdMessageMap.put(tempRev.Id, reader.getText());
                            }
                        }
                    }

                    if (tempSites != null || tempCost != null){
                        revsToUpdate.add(tempRev);
                    }
                }
                
                System.debug('$$$ Go to next');
                reader.next();
            }
        }
        else{
            for (PDLM__Item_Revision__c rev : revIdRevMap.values()){
                erroredItemsList.add(rev.PDLM__Master_Item_Number__c);
            }
        }

        System.debug('revsToUpdate: ' + revsToUpdate);
        System.debug('erroredItemsList: ' + erroredItemsList);

        //DMLs
        if (revsToUpdate.size() > 0){
            update revsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
        //Need to send email after the batch job is done
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Id> propelAdminMemberIdsList = new List<Id>();

        for (GroupMember mem : [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Propel_Admin']){
            if (mem.UserOrGroupId.getSobjectType() == User.SObjectType){
                propelAdminMemberIdsList.add(mem.UserOrGroupId);
            }
        }   

        System.debug('propelAdminMemberIdsList: ' + propelAdminMemberIdsList);

        //Loop and construct the emails from revIdMessageMap
        if (propelAdminMemberIdsList.size() > 0){
            //Email the Propel Admin Group when seeing messages from Payload file from SAP PI per call
            if (revIdMessageMap.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String costPlantItemListString = '';

                for (Id revId : revIdMessageMap.keySet()){
                    if (costPlantItemListString == ''){
                        costPlantItemListString = '<ul>';
                    }

                    costPlantItemListString += '<li>' + '<a href=\"' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + revId 
                                            + '\">'+ revIdRevMap.get(revId).Name + '</a>' + ': ' + revIdMessageMap.get(revId) + '</li>';
                }
                if (costPlantItemListString != ''){
                    costPlantItemListString += '</ul>';
                }


                mail.setToAddresses(propelAdminMemberIdsList);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setSenderDisplayName(userInfo.getName());
                mail.setSubject('SAP INTEGRATION: ' + 'Cost and/or Extended Sites are not available');
                
                mail.setHtmlBody('Hello,'
                                + '<br><br>Cost and/or Extended Sites are not available from SAP. Please see details below: '
                                + costPlantItemListString
                                + '<br>Thank you,<br>Propel');

                mails.add(mail);
            }

            //Construct the emails from erroredItemsList
            //Email the Propel Admin Group when there is an error
            if (erroredItemsList.size() > 0){
                Messaging.SingleEmailMessage erroredMail = new Messaging.SingleEmailMessage();
                
                String itemListString = '';
                for (String str : erroredItemsList){
                    if (itemListString == ''){
                        itemListString = '<ul>';
                    }

                    itemListString += '<li>' + str + '</li>';
                }

                if (itemListString != ''){
                    itemListString += '</ul>';
                }
                
                erroredMail.setToAddresses(propelAdminMemberIdsList);
                erroredMail.setSaveAsActivity(false);
                erroredMail.setUseSignature(false);
                erroredMail.setSenderDisplayName(userInfo.getName());
                erroredMail.setSubject('SAP INTEGRATION: Cost and Extended Sites are Failed to be Pulled');
                erroredMail.setHtmlBody('Hello,'
                                + '<br><br>Cost and Extended Sites cannot be pulled from SAP for Items below: <br>'
                                + itemListString
                                + '<br>Thank you,<br>Propel');

                mails.add(erroredMail);
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

        System.debug(Logginglevel.WARN, 'PropelPullCostAndPlantExtFromSAPBatch: finish()');
    }

    /* Debug Log
    PropelPullCostAndPlantExtFromSAPBatch.PropelPullCostAndPlantExtFromSAP(new List<Id>(), new List<String>());
    List <PropelPullCostAndPlantExtFromSAPBatch.requestParameters> data = new List<PropelPullCostAndPlantExtFromSAPBatch.requestParameters>();
    PropelPullCostAndPlantExtFromSAPBatch.requestParameters req = new PropelPullCostAndPlantExtFromSAPBatch.requestParameters ();
    req.SFDC_ID= 'GUID_5';
    req.MATERIAL = '95050322';
    req.SITE = 'US01';
    data.add(req);
    PropelPullCostAndPlantExtFromSAPBatch.requestParameters req2 = new PropelPullCostAndPlantExtFromSAPBatch.requestParameters ();
    req2.SFDC_ID= '520000001';
    req2.MATERIAL = '950000122';
    req2.SITE = 'US45';
    data.add(req2);
    PropelPullCostAndPlantExtFromSAPBatch.PropelPullCostAndPlantExtFromSapXml(data);
    */

    public class requestParameters{
        public String SFDC_ID = '';
        public String MATERIAL = '';
        public String SITE = '';
    }

    public static String PropelPullCostAndPlantExtFromSapXml(List <requestParameters> data, String endPointUrlHostName){
        String returnedBody = null;
        String endpoint_x = endPointUrlHostName + '/XISOAPAdapter/MessageServlet?senderParty=&senderService=BC_PLM&receiverParty=&receiverService=&interface=ZM2D_GET_MATCOST_PLNTEXT&interfaceNamespace=urn%3Asap-com%3Adocument%3Asap%3Arfc%3Afunctions';
        String username = 'rfcuser_plm';
        String password = 'zoetis123@';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        String xmlEnv = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">';
        String xmlHeader = '<soapenv:Header/>';
        String xmlBodyStart = '<soapenv:Body><urn:ZM2D_GET_MATCOST_PLNTEXT><IT_INPUT>';
        String xmlBodyMain = '';
        String xmlBodyClose = '</IT_INPUT></urn:ZM2D_GET_MATCOST_PLNTEXT></soapenv:Body></soapenv:Envelope>';
        
        for (requestParameters r : data){
            xmlBodyMain += '<item><SFDC_ID>' + r.SFDC_ID + '</SFDC_ID><MATERIAL>' + r.MATERIAL + 
                           '</MATERIAL><SITE>' + r.SITE + '</SITE></item>';
        }

        String xmlRequest = xmlEnv + xmlHeader + xmlBodyStart + xmlBodyMain + xmlBodyClose;
        
        System.debug('xmlRequest: ' + xmlRequest);
        
        //Post the request to get the response
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        req.setEndPoint(endpoint_x);
        req.setMethod('GET');
        req.setHeader('Content-type', 'application/xml');
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(xmlRequest);
        HTTPResponse res = h.send(req); 

        //Add error check
        //Add to the map if 200
        //If broken, throw an exception
        if (res.getStatusCode() == 200){
            returnedBody = res.getBody();
        }
        else {
            returnedBody = 'Send Error Email';
        }

        System.debug('returnedBody:' + returnedBody);
        return returnedBody;
    }
}