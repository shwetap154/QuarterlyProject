/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
Private class JobUtiltiesTest {

	@IsTest
	static void jobTest(){	
		JobUtilities.JobInfo job= new JobUtilities.JobInfo('Contact',JobUtilities.OPERATION.insert_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
		JobUtilities jobUtil=new JobUtilities();
		jobUtil.sessionId=UserInfo.getSessionId();

		MultiStaticResourceCalloutMock multimock = ZTS_DataUtilityTest.getJobUtilitiesMock();
		
		Test.setMock(HttpCalloutMock.class, multimock);
		Test.startTest();
		String jid=jobUtil.createJob(job, new JobUtilities.BulkConnection());
		jobUtil.closeJob(jid, new JobUtilities.BulkConnection());
		System.debug('## JOB ID : '+jid);
		System.assert(jid!=null);
		//create batch
		job=jobUtil.job;
		String payload='LastName\nBt11\nBt22\nBt33\nBt44';
		jobUtil.createBatch(job,new JobUtilities.BulkConnection(),payload );
		
		String jobId='750c0000000FusYAAS';
		jobUtil=new JobUtilities();
		jobUtil.sessionId=UserInfo.getSessionId();
		String jbid='750c0000000FusYAAS';
        String batchId='751x00000000079AAA';
		//JobUtilities.checkBatchStatus(jbid, batchId, new JobUtilities.BulkConnection(), jobUtil.sessionId);
		//JobUtilities.closeJob(jbid,new JobUtilities.BulkConnection(),jobUtil.sessionId);
		Test.stopTest();
	}

	@IsTest
	static void testParseJobInfoResponse(){ 
    	
    	String resp='<?xml version="1.0" encoding="UTF-8"?><jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload"> <id>750c0000000FusYAAS</id> <operation>insert</operation> <object>Contact</object> <createdById>005c0000000vgmbAAA</createdById> <createdDate>2014-04-26T14:24:03.000Z</createdDate> <systemModstamp>2014-04-26T14:24:03.000Z</systemModstamp> <state>Closed</state> <concurrencyMode>Serial</concurrencyMode> <contentType>CSV</contentType> <numberBatchesQueued>0</numberBatchesQueued> <numberBatchesInProgress>0</numberBatchesInProgress> <numberBatchesCompleted>0</numberBatchesCompleted> <numberBatchesFailed>0</numberBatchesFailed> <numberBatchesTotal>0</numberBatchesTotal> <numberRecordsProcessed>0</numberRecordsProcessed> <numberRetries>0</numberRetries> <apiVersion>30.0</apiVersion> <numberRecordsFailed>0</numberRecordsFailed> <totalProcessingTime>0</totalProcessingTime> <apiActiveProcessingTime>0</apiActiveProcessingTime> <apexProcessingTime>0</apexProcessingTime> </jobInfo>';
		JobUtilities.JobInfo job= new JobUtilities.JobInfo('Contact',JobUtilities.OPERATION.insert_x,JobUtilities.CONCURRENCY_MODE.Serial,JobUtilities.CONTENT_TYPE.CSV);
         job= JobUtilities.parseJobInfoResponse(resp,job);
         System.debug('## JOB '+JOB);
         System.assert(job.id=='750c0000000FusYAAS', 'Failed to parse XML Data , Job ID not found' );
         System.assert(job.createdDate!=null, 'Failed to parse XML Data , CreatedDate not found' );
         Map<String,String> result=JobUtilities.parse(resp,job.elements);
         for(String key:result.keySet()){
         	 System.debug(key+': '+result.get(key)+' , ');
         }
         
    }
	
	@IsTest
    static void testCloseJob(){
		ZTS_BatchInfo__c binfo=new ZTS_BatchInfo__c(ZTS_JobID__c='750c0000000FusYAAS',ZTS_BatchID__c='751x00000000079AAA',Name='BINFO-33');
    	System.runAs(new User(id=UserInfo.getUserId())){
    		insert binfo;
    	}
    	MultiStaticResourceCalloutMock mock=ZTS_DataUtilityTest.getJobUtilitiesMock();
    	Test.startTest();
       	Test.setMock(HttpCalloutMock.class, mock);
		JobUtilities.doJobBatchStatusCheck('750c0000000FusYAAS','751x00000000079AAA',binfo.id,UserInfo.getSessionId());
    	Test.stopTest();
    	List<ZTS_BatchInfo__c> binfolist=[SELECT Id,Name from ZTS_BatchInfo__c];
    	System.assert(binfolist.size()!=0);
    
    }
}