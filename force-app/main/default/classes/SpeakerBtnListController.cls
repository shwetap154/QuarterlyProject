/********************** 
 * CLass Name : SpeakerBtnListController
 * Description  : Controller for new buttons (that used to be JS) on ZTS_US_Speaker__c object
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 12th May, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           05/12/2020          Created 
*****************************************************************************************************************************************/

public with sharing class SpeakerBtnListController {

    private ApexPages.StandardSetController standardController;
    public String evntId;
    public static final String MARKET_CHECK = 'United States';
	@testVisible static String eventIdTest = ''; 
    public SpeakerBtnListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference doAddSpeakerRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        evntId = theUrl.substring(n+3, n+21);
        if(Test.isRunningTest()){
            evntId = eventIdTest;
        }
        List<ZTS_Events__c> intlEvt = [Select ZTS_EU_Market__c from ZTS_Events__c Where Id= :evntId];
        if(intlEvt.size() > 0) {
            if(isIntlRedirect(intlEvt[0].ZTS_EU_Market__c)) {
                return doRedirectIntl();
            }
        }

        try {
            pageReference pg = new pageReference('/apex/USZTS_US_AddSpeaker?eventId='+evntId);
            return pg.setRedirect(true);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }
    private Pagereference doRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_NewSpeakerRelatedList?id=' + evntId);
        return pg.setRedirect(true);
    }
    public static Boolean isIntlRedirect(String evtMarket) {
        if(evtMarket != null && evtMarket != MARKET_CHECK) {
            return true;
        } 
        else if(evtMarket == null){
            List<User> runningUser = [SELECT ZTS_EU_Market__c FROM User WHERE Id = :UserInfo.getUserId()];
            if(runningUser.size() > 0 && runningUser[0].ZTS_EU_Market__c != MARKET_CHECK) return true;
        }
        return false;
    }
}