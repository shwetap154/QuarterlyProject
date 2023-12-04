/****************************************************************************************************************************************** 
 * Class Name   : JobUtilities
 * Description  : This class contain methods used for Bulk Job data operation.
 *                
 *      
 * Created By   : Deloitte Consulting/ Raghu
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				 Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Deloitte Consulting/Raghu             04/28/2014           Created
 * Deloitte Consulting/Raghu              05/06/2014           Added/Modified  methods
*****************************************************************************************************************************************/
public with sharing class JobUtilities {

    public String sessionId {
        get;
        set;
    }
    public enum CONTENT_TYPE {
        CSV, XML, ZIP_CSV, ZIP_XML

    }

    public enum CONCURRENCY_MODE {
        Serial, Parallel_x

    }


    public enum OPERATION {
        delete_x, insert_x, query_x, upsert_x, update_x, hardDelete_x

    }

    public List < BatchInfo > batchInfos = new List < BatchInfo > ();
    public JobInfo job {
        get;
        set;
    }
   
    /***********  
     * Method name  : createJob
     * Description  : This method creates bulk job request to initiate bulk job in SF.
     * Return Type  : JobId.
     * Parameters   : JobInfo and Connection
     ***********/
    public String createJob(JobInfo job, BulkConnection connection) {
        String reqBody = JobUtilities.newJobRequest(job);


        Map < String, String > headerInfo = new Map < String, String > ();
        headerInfo.put('Content-Type', 'application/xml');
        headerInfo.put('X-SFDC-Session', sessionId);
        connection.headers = headerInfo;

        String response = connection.sendRequest(connection.job_endpoint, 'POST', reqBody);
        job = JobUtilities.parseJobInfoResponse(response, job);
        System.debug('##JOB RAW RESPONSE : ' + response);
        System.debug('### JOB INFO : ' + job);
        this.job = job;
        return this.job != null ? this.job.Id : null;

    }
    
     /***********  
     * Method name  : closeJob
     * Description  : This method closed bulk job.
     * Return Type  : None.
     * Parameters   : JobId and BulkConnection.
     ***********/ 
    public void closeJob(String jobId, BulkConnection connection) {
        Map < String, String > headerInfo = new Map < String, String > ();
        headerInfo.put('Content-Type', 'application/xml');
        headerInfo.put('X-SFDC-Session', sessionId);

        connection.headers = headerInfo;

        String reqbody = JobUtilities.closeJobRequest();
        String endpoint = connection.job_endpoint + '/' + jobId;
        System.debug('## close end point ' + endpoint);
        String response = connection.sendRequest(endpoint, 'POST', reqbody);
        System.debug('## RESP : ' + response);
        parseJobInfoResponse(response, job);
    }
	
	 /***********  
     * Method name  : closeJob
     * Description  : This static method closed bulk job.
     * Return Type  : Response data.
     * Parameters   : JobId and BulkConnection,salesforce sessionid.
     ***********/ 
    public static String closeJob(String jobId, BulkConnection connection, String sessionId) {
        Map < String, String > headerInfo = new Map < String, String > ();
        headerInfo.put('Content-Type', 'application/xml');
        headerInfo.put('X-SFDC-Session', sessionId);
        connection.headers = headerInfo;
        String reqbody = JobUtilities.closeJobRequest();
        String endpoint = connection.job_endpoint + '/' + jobId;
        System.debug('## close end point ' + endpoint);
        String response = connection.sendRequest(endpoint, 'POST', reqbody);
        System.debug('## RESP : ' + response);
        return response;

    }
	
	 /***********  
     * Method name  : createBatch
     * Description  : This method prepares and send batch request to SF.
     * Return Type  : Response data.
     * Parameters   : JobId and BulkConnection,data payload.
     ***********/ 
    public String createBatch(JobInfo job, BulkConnection connection, String payload) {
        Map < String, String > headerInfo = new Map < String, String > ();

        headerInfo.put('X-SFDC-Session', sessionId);
        if (job.contentType == 'CSV') {
            headerInfo.put('Content-Type', 'text/csv');
        }

        String endpoint = connection.batch_endpoint.replace('{jobId}', job.Id);
        connection.headers = headerInfo;        
        String response = connection.sendRequest(endpoint, 'POST', payload);
        BatchInfo bInfo = new BatchInfo();
        String[] elements = bInfo.elements;
        bInfo = parseBatchInfo(response, elements);
        batchInfos.add(binfo);
        return binfo.id;

    }

    /***********  
     * Method name  : checkBatchStatus
     * Description  : This method prepares and send batch request to SF.
     * Return Type  : BatchInfo.
     * Parameters   : BatchId and BulkConnection.
     ***********/
    public BatchInfo checkBatchStatus(String batchId, BulkConnection connection) {
        Map < String, String > headerInfo = new Map < String, String > ();

        headerInfo.put('X-SFDC-Session', sessionId);
        if (job.contentType == 'CSV') {
            headerInfo.put('Content-Type', 'text/csv');
        }

        String endpoint = connection.batch_status_endpoint.replace('{jobId}', job.Id).replace('{batchId}', batchId);
        connection.headers = headerInfo;
        String response = connection.sendRequest(endpoint, 'GET', null);
        BatchInfo bInfo = new BatchInfo();
        String[] elements = bInfo.elements;
        bInfo = parseBatchInfo(response, elements);
        batchInfos.add(binfo);
        return binfo;

    }

    /***********  
     * Method name  : checkBatchStatus
     * Description  : This method checks current progress of batch in bulk job.
     * Return Type  : BatchInfo.
     * Parameters   : JobId and BulkConnection,salesforce sessionid.
     ***********/
    public static BatchInfo checkBatchStatus(String jobId, String batchId, BulkConnection connection, String sessionId) {
        Map < String, String > headerInfo = new Map < String, String > ();

        headerInfo.put('X-SFDC-Session', sessionId);
        String endpoint = connection.batch_status_endpoint.replace('{jobId}', jobId).replace('{batchId}', batchId);
        connection.headers = headerInfo;
        String response = connection.sendRequest(endpoint, 'GET', null);
        BatchInfo bInfo = new BatchInfo();
        String[] elements = bInfo.elements;
        bInfo = parseBatchInfo(response, elements);
        return binfo;

    }
    
     /***********  
     * Method name  : checkBatchStatus
     * Description  : This method checks progress of batch jobs.
     * Return Type  : None.
     * Parameters   : JobId ,batchId ,batchInfoId ,salesforce sessionid.
     ***********/
    @future(callout=true)
    public static  void doJobBatchStatusCheck(String jobId, String batchId, String batchInfoId, String sessionId) {
    	    Id completed_binfo_ids=null;
        try {
            BatchInfo binfo = JobUtilities.checkBatchStatus(jobId, batchId, new BulkConnection(), sessionId);
            System.debug('## BatchInfo -- > ' + binfo);
            if (binfo.state == 'Completed') {
                String resp = JobUtilities.closeJob(jobId, new BulkConnection(), sessionId);
                System.debug('Response : ' + resp);
                if (resp != null && (resp.contains('Closed') || resp.contains('closed'))) {
                    Database.Deleteresult delRes = Database.delete(batchInfoId, false);
                    ZTS_Logger.error(new Database.Deleteresult[] {
                        delRes
                    }, 'JobUtilites.doJobBatchStatusCheck');
                    
                }
            }
        } catch (Exception ex) {
        	System.debug('### ERROR-jobclose : '+ex);
            ZTS_Logger.error(ex.getMessage(), null, 'JobUtilites.doJobBatchStatusCheck');
        }
       // return completed_binfo_ids;
    }
    
    
    

   /****** Wrapper to prepare and capture JobRequest information *****/
    public class JobInfo {

        //constructor
        public JobInfo(String object_x, OPERATION operation_x, CONCURRENCY_MODE concurrencyMode, CONTENT_TYPE contentType) {
            this.object_x = object_x;
            this.operation = operation_x.name().replace('_x', '');
            this.concurrencyMode = concurrencyMode.name().replace('_x', '');
            this.contentType = contentType.name();
        }

        //used only for status and close activities
        public JobInfo(String jobId) {
            jobMap.put('id', jobId);
        }

        public Map < String, String > jobMap = new Map < String, String > ();
        public String object_x {
            get;
            set;
        }
        public String operation {
            get;
            private set;
        }
        public String concurrencyMode {
            get;
            private set;
        } //Parallel,Serial
        public String contentType {
            get;
            private set;
        }
        public String assignmentRuleId {
            get;
            set;
        }
        public String externalIdFieldName {
            get;
            set;
        }
        public String apiVersion {
            get;
            set;
        }
        public long apiActiveProcessingTime {
            get;
            set;
        }
        //Do not specify for new job
        public long apexProcessingTime {
            get;
            set;
        }
        public String createdById {
            get;
            set;
        }
        public String createdDate {
            get {
                return jobMap.containsKey('createdDate') ? jobMap.get('createdDate') : null;
            }
        }

        public String id {
            get {
                return jobMap.containsKey('id') ? jobMap.get('id') : null;
            }
        }

        public String numberBatchesCompleted {
            get;
            set;
        }
        public Integer numberBatchesQueued {
            get;
            set;
        }
        public Integer numberBatchesFailed {
            get;
            set;
        }
        public Integer numberBatchesInProgress {
            get;
            set;
        }
        public Integer numberBatchesTotal {
            get;
            set;
        }
        public String numberRecordsFailed {
            get;
            set;
        }
        public String numberRecordsProcessed {
            get;
            set;
        }
        public String numberRetries {
            get;
            set;
        }
        public String state {
            get {
                return jobMap.containsKey('state') ? jobMap.get('state') : state;

            }
            set;
        }
        public datetime systemModstamp {
            get;
            set;
        }
        public long totalProcessingTime {
            get;
            set;
        }
        public String xmlns = 'xmlns:http://www.force.com/2009/06/asyncapi/dataload';

        public String[] elements = new String[] {
            'id', 'createdById', 'createdDate', 'systemModstamp', 'state', 'numberBatchesQueued',
            'numberBatchesInProgress', 'numberBatchesCompleted', 'numberBatchesCompleted',
            'numberBatchesTotal', 'numberRecordsProcessed', 'numberRetries', 'apiVersion',
            'numberRecordsFailed', 'totalProcessingTime', 'apiActiveProcessingTime',
            'apexProcessingTime'
        };
        //use for debug 									
        public String rawResponse {
            get;
            set;
        }

    }

    /****** Wrapper to prepare and capture BatchResponse information *****/
    public class BatchInfo {
        public String apiVersion {
            get {
                return batchInfoMap.containsKey('apiVersion') ? batchInfoMap.get('apiVersion') : apiVersion;
            }
            set;
        }
        public long apiActiveProcessingTime {
            get;
            set;
        }
        public Datetime createdDate {
            get;
            set;
        }
        public String id {
            get {
                return batchInfoMap.containsKey('id') ? batchInfoMap.get('id') : id;
            }
            set;
        }
        public String jobId {
            get {
                return batchInfoMap.containsKey('jobId') ? batchInfoMap.get('jobId') : jobId;
            }
            set;
        }
        public Integer numberRecordsFailed {
            get {
                return batchInfoMap.containsKey('numberRecordsFailed') ? Integer.valueOf(batchInfoMap.get('numberRecordsFailed')) : numberRecordsFailed;
            }
            set;
        }
        public Integer numberRecordsProcessed {
            get {
                return batchInfoMap.containsKey('numberRecordsProcessed') ? Integer.valueOf(batchInfoMap.get('numberRecordsProcessed')) : numberRecordsProcessed;
            }
            set;
        }
        public String state {
            get {
                return batchInfoMap.containsKey('state') ? batchInfoMap.get('state') : state;
            }
            set;
        }
        public String stateMessage {
            get {
                return batchInfoMap.containsKey('stateMessage') ? batchInfoMap.get('stateMessage') : stateMessage;
            }
            set;
        }
        public datetime systemModstamp {
            get;
            set;
        }
        public long totalProcessingTime {
            get;
            set;
        }

        public Map < String, String > batchInfoMap = new Map < String, String > ();

        public String[] elements = new String[] {
            'apiVersion', 'apiActiveProcessingTime', 'createdDate', 'systemModstamp', 'state', 'id',
            'jobId', 'numberRecordsFailed', 'numberRecordsProcessed',
            'stateMessage', 'numberRecordsProcessed', 'numberRetries', 'apiVersion',
            'numberRecordsFailed', 'totalProcessingTime'
        };
        public String rawData {
            get;
            set;
        }
    }

    public class BulkConnection {
        public Decimal version = 30.0;
        public Map < String, String > headers {
            get;
            set;
        }
        public String endpoint = ZTS_GlobalConstants.SERVER_URL;

        public String job_endpoint = endpoint + '/services/async/' + version + '/job';
        public String batch_endpoint = endpoint + '/services/async/' + version + '/job/{jobId}/batch';
        public String batch_status_endpoint = batch_endpoint + '/{batchId}';
        public String batch_results_endpoint = batch_status_endpoint + '/result';

        public boolean isCompressed = false;
        
	    /***********  
	     * Method name  : sendRequest
	     * Description  : This method does HTTP callout.
	     * Return Type  : Reponse body.
	     * Parameters   : Endpoint ,HTTP method ,HTTP Request
	     ***********/
        public String sendRequest(String endpoint_url, String method, String body) {
            // Instantiate a new http object
            Http h = new Http();

            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint_url);
            req = setHeadersInfo(req);
            req.setMethod(method);
            if (!String.isBlank(body)) {
                req.setBody(body);
            }

            if (isCompressed) {
                req.setCompressed(TRUE);
            }

            // Send the request, and return a response
            HttpResponse res = h.send(req);
            if (res.getStatusCode() != 200) {
                String msg = res.toString();
                System.debug('### ERROR : ' + msg);
                //ZTS_Logger.warn(msg, null, 'sendRequest-StatusCode NOT OK(200)');
            }
            return res.getBody();
        }
        
	     /***********  
	     * Method name  : setHeadersInfo
	     * Description  : This method sets HTTP headers.
	     * Return Type  : Reponse data.
	     * Parameters   : Endpoint ,HTTP method ,HTTP Request
	     ***********/
        public HttpRequest setHeadersInfo(HttpRequest req) {
            System.debug('# HEADERS INFO : ' + headers);
            for (String headerKey: headers.keySet()) {
                req.setHeader(headerKey, headers.get(headerKey));
            }
            return req;
        }

    }
    
        /***********  
	     * Method name  : newJobRequest
	     * Description  : This method creates new JobRequest.
	     * Return Type  : Request payload string.
	     * Parameters   : JobInfo
	     ***********/
    public static String newJobRequest(JobInfo job) {
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('utf-8', '1.0');
        writer.writeStartElement(null, 'jobInfo', null);
        writer.writeDefaultNamespace('http://www.force.com/2009/06/asyncapi/dataload');

        writer.writeStartElement('', 'operation', '');
        writer.writeCharacters(job.operation);
        writer.writeEndElement();

        writer.writeStartElement('', 'object', '');
        writer.writeCharacters(job.object_x);
        writer.writeEndElement();

        if (!String.isBlank(job.concurrencyMode)) {
            writer.writeStartElement('', 'concurrencyMode', '');
            writer.writeCharacters(job.concurrencyMode);
            writer.writeEndElement();
        }

        writer.writeStartElement('', 'contentType', '');
        writer.writeCharacters(job.contentType);
        writer.writeEndElement();


        writer.writeEndElement();
        writer.writeEndDocument();
        String xmlStr = writer.getXmlString();
        System.debug('The XML :' + writer.getXmlString());
        writer.close();
        return xmlStr;
    }

      /***********  
	     * Method name  : closeJobRequest
	     * Description  : This method creates close JobRequest.
	     * Return Type  : close JobRequest  string.
	     * Parameters   : None
	 ***********/
    public static String closeJobRequest() {
        return '<?xml version="1.0" encoding="UTF-8"?><jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload"><state>Closed</state></jobInfo>';
    }
    
     /***********  
	     * Method name  : parseJobInfoResponse
	     * Description  : This method parses Job response to JobInfo.
	     * Return Type  : close JobRequest  string.
	     * Parameters   : Response body and JobInfo
	***********/
    public static JobInfo parseJobInfoResponse(String response, JobInfo job) {
        Xmlstreamreader reader = new Xmlstreamreader(response);
        job.rawResponse = response;
        reader.next();
        while (reader.hasNext()) {
            reader.next();
            for (String element: job.elements) {
                if (reader.getEventType() == Xmltag.START_ELEMENT) {
                    if (element == reader.getLocalName()) {
                        if (reader.hasNext()) {
                            reader.next();
                            if (reader.getEventType() == Xmltag.CHARACTERS)
                                job.jobMap.put(element, reader.getText());
                        }
                    } else if (reader.getEventType() == XMLtag.END_ELEMENT) {
                        break;
                    }
                }
            }
        }
        System.debug('#### : ' + job.jobMap);
        return job;
    }


    /***********  
     * Method name  : parseBatchInfo
     * Description  : This method parses the batch response.
     * Return Type  : BatchInfo.
     * Parameters   : XML Response ,elements names array
     ***********/
    public static BatchInfo parseBatchInfo(String xmlData, String[] elements) {
        BatchInfo batch_info = new BatchInfo();
        batch_info.batchInfoMap = parse(xmlData, elements);
        batch_info.rawData = xmlData;
        return batch_info;
    }

   /***********  
     * Method name  : parse
     * Description  : This method parses the xmlData with corresponding xml elements to a Map.
     * Return Type  : Map.
     * Parameters   : XML data ,elements names array
     ***********/ 
    public static Map < String, String > parse(String xmlData, String[] elements) {
        Map < String, String > tagValueMap = new Map < String, String > ();

        Xmlstreamreader reader = new Xmlstreamreader(xmlData);
        reader.next();
        while (reader.hasNext()) {
            reader.next();
            for (String element: elements) {
                if (reader.getEventType() == Xmltag.START_ELEMENT) {
                    if (element == reader.getLocalName()) {
                        if (reader.hasNext()) {
                            reader.next();
                            if (reader.getEventType() == Xmltag.CHARACTERS)
                                tagValueMap.put(element, reader.getText());
                        }
                    } else if (reader.getEventType() == XMLtag.END_ELEMENT) {
                        break;
                    }
                }
            }
        }
        return tagValueMap;
    }
    
     /***********  
     * Method name  : createBatchInfoEntry
     * Description  : This method create a BatchInfo entry in customsettings.
     * Return Type  : None.
     * Parameters   : JobId ,Batch Id
     ***********/
    public static void createBatchInfoEntry(String jobid, String batchId) {
        ZTS_BatchInfo__c binfo = new ZTS_BatchInfo__c(Name = 'BINFO-' + jobId, ZTS_JobID__c = jobid, ZTS_BatchID__c = batchId);
        Database.Saveresult result = Database.insert(binfo, false);
        ZTS_Logger.error(new Database.Saveresult[] {
            result
        }, 'JobUtility-createBatchInfoEntry');

    }
}