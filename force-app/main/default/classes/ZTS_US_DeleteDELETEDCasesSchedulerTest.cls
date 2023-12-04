/*************************************************************************************
* Name          :    ZTS_US_DeleteDELETEDCasesSchedulerTest.
* Description   :    Schecdule the Batch Test class(ZTS_US_DeleteDELETEDCasesScheduler)daily to test cases which contains status as DELETED are deleted.
* Author        :    Kaushik Ghosh(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
05/17/2017       Kaushik Ghosh(Cognizant)         Created
**************************************************************************************/


@isTest                            
public class ZTS_US_DeleteDELETEDCasesSchedulerTest {

    static testmethod void testScheduler() {  
        Id recTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Items Request').getRecordTypeId();
        Case c = new Case(recordtypeId = recTypeId);
        insert c;
        c.status = 'DELETE';
        UPDATE C;
        test.startTest();
       ZTS_US_DeleteDELETEDCasesScheduler.start();
       //Database.executeBatch(new ZTS_US_DeleteDELETEDCasesScheduler(),100); 
       test.stopTest();
    }
}