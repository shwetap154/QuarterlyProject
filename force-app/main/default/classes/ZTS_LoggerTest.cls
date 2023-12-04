/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
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
private class ZTS_LoggerTest {

    static testMethod void testLogs() {
        ZTS_Logger logger = new ZTS_Logger();
        ZTS_Logger.notify = true;

        ZTS_Logger.error('Error message', null, 'Test LogType');
        ZTS_Logger.info('Info message', null, 'Test LogType');
        ZTS_Logger.trace('Trace message', null, 'Test LogType');
        ZTS_Logger.warn('Warn message', null, 'Test LogType');
        ZTS_Logger.debug('Debug message', null, 'Test LogType');
        ZTS_Logger.addPageMessage(ApexPages.Severity.INFO, 'Message Info');
        ZTS_EU_Error_Log__c errorlog = [SELECT Id, ZTS_EU_Message__c, ZTS_EU_Log_level__c from ZTS_EU_Error_Log__c where createdDate = TODAY LIMIT 1];
        String msg=ZTS_Logger.toString(errorlog);
        System.assert(msg!=null,'Error message is empty');
        Test.startTest();
        ZTS_Logger.errorAsync('Error message', 'FutureMethodError');
        ZTS_Logger.errorAsync('Error message', 'FutureMethodError', null);
        Test.stopTest();

    }

    static testMethod void testDMLOpLogs() {
        ZTS_DataUtilityTest.activateTriggerSettings();
        List < Account > acclist = ZTS_DataUtilityTest.createAccountRecord(5);
        System.debug('acclist------>'+acclist);
        List < Database.Saveresult > results = Database.insert(acclist, false);
        ZTS_Logger.error(results, 'test method logs-update');
        //insert acclist;
        acclist = [SELECT Id FROM Account];
        System.debug('acclist------>'+acclist);
        delete acclist[0];

        List < Database.Saveresult > updateResult = Database.update(acclist, false);
        ZTS_Logger.error(updateResult, 'test method logs-update');

        String msg = ZTS_Logger.getDMLSuccessMsg(updateResult);

        System.assert(msg != null, 'Upate operation failed');

        List < Database.Upsertresult > upsertResult = Database.upsert(acclist, false);
        ZTS_Logger.error(upsertResult, 'test method logs-upsert');

        msg = ZTS_Logger.getDMLSuccessMsg(upsertResult);

        List < Database.Deleteresult > delResult = Database.delete(acclist, false);
        ZTS_Logger.error(delResult, 'test method logs-delete');

        msg = ZTS_Logger.getDMLSuccessMsg(delResult);
    }
    
    static testMethod void testEULogs() {
        ZTS_EU_Logger logger = new ZTS_EU_Logger();
        ZTS_EU_Logger.notify = true;
        
        String longMessage;
        
        for(Integer i = 0; i < 32768; i++)
        {
            longMessage += 'E';
        }

        ZTS_EU_Logger.error(longMessage, null, 'Test LogType');
        ZTS_EU_Logger.info('Info message', null, 'Test LogType');
        ZTS_EU_Logger.trace('Trace message', null, 'Test LogType');
        ZTS_EU_Logger.warn('Warn message', null, 'Test LogType');
        ZTS_EU_Logger.debug('Debug message', null, 'Test LogType');
        ZTS_EU_Logger.addPageMessage(ApexPages.Severity.INFO, 'Message Info');
        ZTS_EU_Error_Log__c errorlog = [SELECT Id, ZTS_EU_Message__c, ZTS_EU_Log_level__c from ZTS_EU_Error_Log__c where createdDate = TODAY LIMIT 1];
        String msg=ZTS_EU_Logger.toString(errorlog);
        System.assert(msg!=null,'Error message is empty');
        Test.startTest();
        ZTS_EU_Logger.errorAsync('Error message', 'FutureMethodError');
        ZTS_EU_Logger.errorAsync('Error message', 'FutureMethodError', null);
        Test.stopTest();

    }

    static testMethod void testEUDMLOpLogs() {
        ZTS_DataUtilityTest.activateTriggerSettings();
        List < Account > acclist = ZTS_DataUtilityTest.createAccountRecord(5);
        System.debug('acclist------>'+acclist);
        List < Database.Saveresult > results = Database.insert(acclist, false);
        ZTS_EU_Logger.error(results, 'test method logs-update');
        //insert acclist;
        acclist = [SELECT Id FROM Account];
        delete acclist[0];

        List < Database.Saveresult > updateResult = Database.update(acclist, false);
        ZTS_EU_Logger.error(updateResult, 'test method logs-update');

        String msg = ZTS_EU_Logger.getDMLSuccessMsg(updateResult);

        System.assert(msg != null, 'Upate operation failed');

        List < Database.Upsertresult > upsertResult = Database.upsert(acclist, false);
        ZTS_EU_Logger.error(upsertResult, 'test method logs-upsert');

        msg = ZTS_EU_Logger.getDMLSuccessMsg(upsertResult);

        List < Database.Deleteresult > delResult = Database.delete(acclist, false);
        ZTS_EU_Logger.error(delResult, 'test method logs-delete');

        msg = ZTS_EU_Logger.getDMLSuccessMsg(delResult);
    }
    
    /* created by Chanbasha Noorbashasheik on 19-July-2021 */
    static testMethod void assignedTerritoryStatustest(){   
        Test.startTest();  
          ZTS_Logger.processAsyncUS();
        Test.stopTest();   
    }
}