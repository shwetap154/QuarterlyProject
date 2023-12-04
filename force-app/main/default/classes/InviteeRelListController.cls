public with sharing class InviteeRelListController {

    private ApexPages.StandardSetController standardController;
    public String theId;
    public static final String MARKET_CHECK = 'United States';

    public InviteeRelListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        theId = theUrl.substring(n+3, n+21);
    }

    public PageReference doEditPageRedirect()
    {       
        List<ZTS_Events__c> intlEvt = [Select ZTS_EU_Market__c from ZTS_Events__c Where Id= :theId];
        if(intlEvt.size() > 0) {
            if(isIntlRedirect(intlEvt[0].ZTS_EU_Market__c)) {
                return doEditPageRedirectIntl();
            }
        }
        pageReference pg = new pageReference('/apex/USZTS_US_ContactEditPage?eventId='+theId);
        return pg.setRedirect(true);
    }

    public PageReference doAddContactsRedirect()
    {       
        List<ZTS_Events__c> intlEvt = [Select ZTS_EU_Market__c from ZTS_Events__c Where Id= :theId];
        if(intlEvt.size() > 0) {
            if(isIntlRedirect(intlEvt[0].ZTS_EU_Market__c)) {
                return doAddContactsRedirectIntl();
            }
        }
        pageReference pg = new pageReference('/apex/USZTS_US_AddContactRedirect?eventId='+theId);
        return pg.setRedirect(true);
    }

    public PageReference doAddContRedirectIntl()
    {       
        pageReference pg = new pageReference('/apex/ZTS_US_AddContactRedirect?eventId='+theId);
        return pg.setRedirect(true);
    }
    private Pagereference doAddContactsRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_AddContactsEventInvitee?id=' + theId);
        return pg.setRedirect(true);
    }
    private Pagereference doEditPageRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_EditContactsEventInvitee?id=' + theId);
        return pg.setRedirect(true);
    }
    static Boolean isIntlRedirect(String evtMarket) {
        if(evtMarket != null && evtMarket != MARKET_CHECK) {
            return true;
        } 
        else if(evtMarket == null){
            List<User> runningUser = [SELECT ZTS_EU_Market__c FROM User WHERE Id = :UserInfo.getUserId()];
            if(runningUser.size() > 0 && runningUser[0].ZTS_EU_Market__c != MARKET_CHECK) return true;
        }
        return false;
    }
    
    public PageReference doAddNewContactsRedirect(){
       pageReference pg = new pageReference('/apex/USZTS_US_AddNewContactRedirect?eventId='+theId);
        return pg.setRedirect(true);
    }
}