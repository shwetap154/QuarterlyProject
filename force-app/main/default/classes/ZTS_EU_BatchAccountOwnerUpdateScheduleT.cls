/***************************************************************************** 
 * Class Name     : ZTS_EU_BatchAccountOwnerUpdateScheduleT
 * Description    : This is the testclass for ZTS_EU_BatchAccountOwnerUpdateSchedule class
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
public class ZTS_EU_BatchAccountOwnerUpdateScheduleT {
    public static String cron_exp='0 0 23 * * ?';
    @isTest static void testschedule()
    {
        Test.startTest();
        
        ZTS_EU_BatchAccountOwnerUpdateSchedule acc1=new ZTS_EU_BatchAccountOwnerUpdateSchedule();
        system.schedule('Test account owner update',cron_exp,acc1);
        test.stopTest();
        
    }
  
  
}