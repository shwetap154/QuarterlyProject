/***************************************************************************** 
 * Class Name     : ZTS_EU_Batch_SampleHandler_NewYear_SchT
 * Description    : This is the testclass for ZTS_EU_Batch_SampleHandler_NewYear_Sch class
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
public class ZTS_EU_Batch_SampleHandler_NewYear_SchT {
public static String exp='0 0 23 * * ?';
     @isTest static void testschedule()
     {
         Test.startTest();
         ZTS_EU_Batch_SampleHandler_NewYear_Sch obj=new ZTS_EU_Batch_SampleHandler_NewYear_Sch();
         system.schedule('Test SampleHandler NewYear batchschedule' ,exp, obj);
         test.stopTest();
     }
    
}