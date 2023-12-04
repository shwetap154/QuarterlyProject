@isTest
public class APPTriggerInvokeTemporaryBatch_Test {

    @isTest static void testBatchClass() {
        
        List<String> markets = new List<String>();
        markets.add('Brazil');
        
        Test.startTest();
            APPTriggerInvokeTemporaryBatch bTch= new APPTriggerInvokeTemporaryBatch(markets);
            Database.executeBatch(bTch);
        Test.stopTest();
    }
}