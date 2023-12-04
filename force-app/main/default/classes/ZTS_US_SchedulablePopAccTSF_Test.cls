/***************************************************************************** 
 * Class Name     : ZTS_US_SchedulablePopAccTSF_Test
 * Description    : This is the testclass for ZTS_US_SchedulablePopulateAccountTSF class
 * Created By     : Aritra Chakraborty(Cognizant Technology Solutions)
 * Created Date   : 27th June, 2018.
 *
 * Modification Log: 
 * ----------------------------------------------------------------------------
 * Developer                Date               Description 
 * ----------------------------------------------------------------------------
 * 
******************************************************************************/
@isTest
public class ZTS_US_SchedulablePopAccTSF_Test {
    public static String ch='0 0 23 * * ?';
    static testmethod void testschedule()
    {
        Test.startTest();
        ZTS_US_SchedulablePopulateAccountTSF acc2=new ZTS_US_SchedulablePopulateAccountTSF();
        String jobId =system.schedule('Test Account TSF Population Batch Schedule',ch,acc2);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        test.stoptest();
        
    }

}