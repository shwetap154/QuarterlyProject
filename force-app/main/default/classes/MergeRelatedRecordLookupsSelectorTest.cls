/**
 * @description       : Test class for MergeRelatedRecordLookupsSelector
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-11-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   05-13-2022   Ethan Hirsch @ Zoetis Inc   Initial Version with selectChildObjectsByParentObjectAndMarketTest
 * 1.1   07-11-2022   Ethan Hirsch @ Zoetis Inc   Modify the type of the response from selectChildObjectsByParentObjectAndMarket
**/
@isTest
private class MergeRelatedRecordLookupsSelectorTest {
    // This test is primarily for code coverage and is written to work regardless of the Metadata is present or not.
    @isTest
    private static void selectChildObjectsByParentObjectAndMarketTest() {
       List<Merge_Related_Record_Lookup__mdt> relatedRecords = [
           SELECT Parent_Object__r.QualifiedApiName, Market__c
           FROM Merge_Related_Record_Lookup__mdt
           LIMIT 1];

        // If no metadata is returned, run the selector class to get some code coverage and prevent any test failures
        if (relatedRecords.isEmpty()) {
            Test.startTest();
                MergeRelatedRecordLookupsSelector.selectChildObjectsByParentObjectAndMarket(
                    new Set<String>{'Account'}, 'INTL');
            Test.stopTest();
            return;
        }

        // If Market is blank on the Related Record Lookup Metadata, set Market to INTL.
        // A blank Market will be treated as US or INTL.
        string market = relatedRecords[0].Market__c;
        if (string.isBlank(market)) {
            market = 'INTL';
        }
        
        Test.startTest();
            Map<String, Map<String, MergeRelatedRecordLookupsSelector.ChildObject>> childObjectsByParent = 
                MergeRelatedRecordLookupsSelector.selectChildObjectsByParentObjectAndMarket(
                    new Set<String>{relatedRecords[0].Parent_Object__r.QualifiedApiName}, market);
        Test.stopTest();

        system.assertEquals(1, childObjectsByParent.size(), 'One Key Value Pair should have been returned.');
        
    }
}