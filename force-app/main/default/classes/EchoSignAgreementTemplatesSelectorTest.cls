/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-10-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-06-2023   Padma Nerella @ Zoetis Inc  Add selectEchoSignAgreementTemplateRecTest method
**/
@isTest
private class EchoSignAgreementTemplatesSelectorTest{

    @TestSetup
    private static void setup(){
        List<echosign_dev1__Agreement_Template__c> echoSignDev1AgreementTemplate = ZTS_DataUtilityTest.createEchoSignDev1AgreementTemplateRec(2);
        echoSignDev1AgreementTemplate[0].Name = 'Improvac Certificate for Vet';
        echoSignDev1AgreementTemplate[0].echosign_dev1__Name__c = 'Improvac Certificate for Vet';
        insert echoSignDev1AgreementTemplate;
    }

    @isTest
    private static void selectEchoSignAgreementTemplateRecTest(){
        List<String> echoSigndev1TempalteName = new List<String>{'Improvac Certificate for Vet','Improvac Certificate for LW'};
        List<echosign_dev1__Agreement_Template__c> echosignDev1AgreementTemplate = [SELECT Id,Name from echosign_dev1__Agreement_Template__c WHERE Name =:echoSigndev1TempalteName];

        Test.startTest();
        List<echosign_dev1__Agreement_Template__c> echoSignAgreementTemplateList = EchoSignAgreementTemplatesSelector.selectEchoSignAgreementTemplateByName(echoSigndev1TempalteName);
        Test.stopTest();

        System.assertEquals(2, echoSignAgreementTemplateList.size(), '2 EchoSignAgreementTemplate records found');
    }
}