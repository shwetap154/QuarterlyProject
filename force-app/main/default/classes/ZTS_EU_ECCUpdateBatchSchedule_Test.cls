/***************************************************************************** 
 * Class Name     : ZTS_EU_ECCUpdateBatchSchedule_Test
 * Description    : This is the testclass for ZTS_EU_ECCUpdateBatchSchedule class
 *                
 *      
 * Created By   : Oeeshi Roy Choudhury(Cognizant Technology Solutions)
 * Created Date : 13th Feb, 2017.
 *
 * Modification Log: 
 * ----------------------------------------------------------------------------
 * Developer                Date               Description 
 * ----------------------------------------------------------------------------
 * 
******************************************************************************/



@isTest
public class ZTS_EU_ECCUpdateBatchSchedule_Test {
    public static String ch='0 0 23 * * ?';
    @isTest static void testschedule()
    {
        Test.startTest();
        ZTS_EU_ECCUpdateBatchSchedule acc2=new ZTS_EU_ECCUpdateBatchSchedule();
        system.schedule('Test ECC updatebatch schedule',ch,acc2);
        test.stoptest();
        
    }

}