/*************************************************************************************
* Name          :    ZTS_US_DeleteCancelledCasesSchedulerTest.
* Description   :    Schecdule the Batch Test class(ZTS_US_DeleteCancelledCasesScheduler)daily to test Cancelled Cases are deleted.
* Author        :    John Zachariah(Cognizant)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
07/21/2016       John Zachariah(Cognizant)         Created
11/17/2016       Anwesha Goswami(Cognizant)        Updated test logic
04/06/2017       Kaushik Ghosh(Cognizant)          Included 'Phone' criteria to differentiate email-to-case
**************************************************************************************/


@isTest                            
public class ZTS_US_DeleteCancelledCasesSchedulerTest {

    static testmethod void testScheduler() {  
        Id recTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Order Inquiry').getRecordTypeId();
        Case c = new Case(recordtypeId = recTypeId,origin='Phone');
        insert c;
        test.startTest();
        ZTS_US_DeleteCancelledCasesScheduler.start();
        test.stopTest();
    }
}