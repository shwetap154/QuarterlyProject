@isTest
public class GetUserAvailableRecordTypesTest {
    
    @isTest
    static void testGetUserAvailableRecordTypes(){

        List<List<RecordType>> rTypes = new List<List<RecordType>>();

        Test.startTest();
            rTypes = GetUserAvailableRecordTypes.getRecordTypes();
        Test.stopTest();

        System.assertNotEquals(0,rTypes.size(), 'The running user should have access to create contact or case patient recordtypes.');

    }
}