@IsTest
public class ImprovacAgreementsSchedularTest {
    public static String CRON_EXP = '0 1 * * * ?';
    
    @isTest static void testschedule()
    {
        Test.startTest();
        ImprovacAgreementsSchedular imprSchd = new ImprovacAgreementsSchedular();
        List<Contact> lstMockContacts = imprSchd.getMockContacts();
        System.assertEquals(lstMockContacts.size(), 1);
        String jobId = System.schedule('Test ImprovacAgreementsSchedular class', CRON_EXP, imprSchd);
        Test.stoptest();
        System.assert(jobId != null);
    }
    
}