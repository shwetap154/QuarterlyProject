/***************************************************************************** 
 * Class Name     : ZTS_EU_ECCcurrentYearFYFlag_UpdateSche
 * Description    : This is the testclass for ZTS_EU_ECCcurrentYearFYFlag_UpdateSche class              
******************************************************************************/
@isTest
public class ZTS_EU_ECCcurrentYearFYFlag_Test{
    public static String ch='0 0 23 * * ?';
    @isTest static void testschedule()
    {
        Test.startTest();
        ZTS_EU_ECCcurrentYearFYFlag_UpdateSche acc2=new ZTS_EU_ECCcurrentYearFYFlag_UpdateSche();
        system.schedule('Test ECC updatebatch schedule',ch,acc2);
        test.stoptest();
        
    }

}