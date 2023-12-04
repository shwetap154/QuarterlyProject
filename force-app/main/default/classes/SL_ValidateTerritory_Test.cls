/**
* @ClassName    : SL_ValidateTerritory_Test 
* @JIRATicket   : ZETM-9
* @CreatedOn    : 23rd November,2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Test class to validate if the Territory standarad object is no more used in schema.
*/
@isTest
private class SL_ValidateTerritory_Test
{
    @isTest static void test_SL_ValidateTerritory() 
    {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

        for(String name : schemaMap.keySet())
        {
            system.assertEquals(name != 'Territory', True);
        }
    }
}