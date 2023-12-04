/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-10-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-06-2023   Padma Nerella @ Zoetis Inc  Add selectEchoSignAgreementTemplateRec method to return improvac echosign Agreement Template 
**/
public with sharing class EchoSignAgreementTemplatesSelector {


    public static List<echosign_dev1__Agreement_Template__c> selectEchoSignAgreementTemplateByName(List<String> echoSignAgreementTemplateNames){
        List<echosign_dev1__Agreement_Template__c> echoSignAgreementTemplateList = [SELECT Id,Name from echosign_dev1__Agreement_Template__c WHERE Name IN :echoSignAgreementTemplateNames];
        return echoSignAgreementTemplateList;
    }
}