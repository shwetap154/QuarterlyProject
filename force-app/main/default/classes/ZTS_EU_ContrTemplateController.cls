/**********************************************************************************************************************
 * Class Name   : ZTS_EU_ContrTemplateController
 * Description  : Controller class for ZTS_EU_ContractTemplate__c buttons with StandardController  
 * Created By   : Slalom/Art Smorodin
 * Created Date : 08 June 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------
 * ---------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     06/08/2020          Created.
 ***********************************************************************************************************************/
public with sharing class ZTS_EU_ContrTemplateController {

    private ApexPages.StandardController standardController;
    public ZTS_EU_ContractTemplate__c sourceTemplate;
    public String templateId;

    public ZTS_EU_ContrTemplateController(ApexPages.StandardController standardController) {

        this.standardController = standardController;
        ZTS_EU_ContractTemplate__c tmpContrTemplate = (ZTS_EU_ContractTemplate__c)standardController.getRecord();
        this.sourceTemplate = [SELECT Id, ZTS_EU_Discount__c 
                                    FROM ZTS_EU_ContractTemplate__c 
                                    WHERE Id = :tmpContrTemplate.Id LIMIT 1];
        templateId = sourceTemplate.Id;

    }

    public PageReference doAssign(){
        try {
            String returnUrl = '/lightning/cmp/c__CreateContrFromTemplLc?c__recordId='+sourceTemplate.Id;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static ZTS_EU_ContractTemplate__c getObjects(String templateId) {
        return [    SELECT Id, ZTS_EU_Discount__c 
                        FROM ZTS_EU_ContractTemplate__c
                        WHERE id =: templateId LIMIT 1];
    }
}