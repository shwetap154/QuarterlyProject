/**
 * @description       : Test class for PVWProductLineTypeGroupingsSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-08-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectProductLinesByType test
**/
@isTest
private class PVWProductLineTypeGroupingsSlctrTest {
    @isTest
    private static void selectProductLinesByType_Test() {
        // Retrieve one Metadata with a Type to verify at least one record is returned.
        PVW_Product_Line_Type_Grouping__mdt existingMetadata = [
            SELECT Product_Type__c
            FROM PVW_Product_Line_Type_Grouping__mdt
            LIMIT 1];

        String testType = existingMetadata.Product_Type__c;
        Test.startTest();
            Map<String, Set<String>> productLinesByType = 
                PVWProductLineTypeGroupingsSelector.newInstance().selectProductLinesByType(
                    new Set<String> {testType});
        Test.stopTest();

        System.assert(productLinesByType.containsKey(testType), String.format('Type {0} should return at least one record',
            new List<String> {testType}));

        System.assert(!productLinesByType.get(testType).isEmpty(), String.format('Type {0} should return at least one record',
            new List<String> {testType}));
    }
}