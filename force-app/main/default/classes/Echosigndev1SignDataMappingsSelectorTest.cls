/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-09-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Ver   Date         Author                      Modification
 * 1.0   06-22-2023   Padma Nerella @ Zoetis Inc  Add test method for selectByName TPDEV-1070
**/
@isTest
private class Echosigndev1SignDataMappingsSelectorTest {
    
    @TestSetup
    private static void setup(){
        String name = 'NOALeadDM';
        echosign_dev1__SIGN_Data_Mapping__c echoSignDataMapping =TestDataFactory.createEchoSigndev1SignDataMapping(name);
        insert echoSignDataMapping;
    }
    
    @isTest
    private static void selectByNameTest(){
        List<echosign_dev1__SIGN_Data_Mapping__c> echoList = [Select Id, Name from echosign_dev1__SIGN_Data_Mapping__c where Name = 'NOALeadDM'];
        String echoSignDev1Name = echoList[0].Name;
        Set<String> echoSigndev1NameSet = new Set<String>{echoSignDev1Name};
        Test.startTest();
        List<echosign_dev1__SIGN_Data_Mapping__c> echoSignDataMappingList = Echosigndev1SignDataMappingsSelector.selectByName(echoSigndev1NameSet);
        Test.stopTest();
        Assert.areEqual(1, echoSignDataMappingList.size(), '1 echosign_dev1__SIGN_Data_Mapping__c record retrived with name NOALeadDM');
    }
    
}