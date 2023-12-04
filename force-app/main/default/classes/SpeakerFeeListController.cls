/****************************************************************************************************************************************** 
 * CLass Name : SpeakerFeeListController
 * Description  : Controller for new button (that used to be JS) on ZTS_US_Speaker_Fee__c object
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 13th May, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           05/13/2020          Created 
*****************************************************************************************************************************************/
public with sharing class SpeakerFeeListController {
    private ApexPages.StandardSetController standardController;
    public String contactId;

    public SpeakerFeeListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        contactId = theUrl.substring(n+3, n+21);
    }

    public PageReference doRedirect()
    {   
        try {
            String returnUrl = '/lightning/cmp/c__CreateSpeakerFeeLC?c__contId='+contactId;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
       
    }

    @AuraEnabled
    public static Contact getObjects(String conid) {
        return [SELECT id, ZTS_US_Cal_Speaker_Flag__c 
                        FROM Contact
                        WHERE id =: conid LIMIT 1];
    }
}