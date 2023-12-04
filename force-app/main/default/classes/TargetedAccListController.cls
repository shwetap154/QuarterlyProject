/****************************************************************************************************************************************** 
* CLass Name : TargetedAccListController
* Description  : Controller for new buttons (that used to be JS) on ZTS_EU_Campaign_Account__c object
* Created By   : Slalom(Art Smorodin) 
* Created Date : 5th May, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Art Smorodin           05/07/2020          Created 
* Aritra(Cognizant)      03/03/2021          Changed the logic of fetching campaign id in doTgAccountsRedirect method(SC-008159)
*****************************************************************************************************************************************/

public with sharing class TargetedAccListController {
    private ApexPages.StandardSetController standardController;
    public List<ZTS_EU_Campaign_Account__c> selTargAccLst;
    public String targAccIds;
    public String campaignId;
    
    public static final String MARKET_CHECK = 'United States';
    
    public TargetedAccListController(ApexPages.StandardSetController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        selTargAccLst = standardController.getSelected();
        targAccIds = '';  
        for(ZTS_EU_Campaign_Account__c acc : selTargAccLst){
            targAccIds += acc.Id + ',';                       
        }
        targAccIds = targAccIds.removeEnd(','); 
    }
    
    public PageReference doRemoveRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        campaignId = theUrl.substring(n+3, n+21);
        
        Campaign targetCampaign = [SELECT Id, ZTS_EU_Field_Targeting__c,ZTS_EU_Market__c FROM Campaign WHERE id =: campaignId LIMIT 1];
        if(isIntlRedirect(targetCampaign.ZTS_EU_Market__c)) {
            return doRemoveRedirectIntl();
        }
        
        if (selTargAccLst.size() >= 1 && targetCampaign.ZTS_EU_Field_Targeting__c == 'Open'){
            pageReference pg = new pageReference('/apex/ZTS_US_removeTargetAccnts?records='+targAccIds+'&campId='+campaignId);
            return pg.setRedirect(true);
        }
        else{
            String returnUrl = '/lightning/cmp/c__ErrorToastLC?c__campId='+campaignId+'&c__campTargeting='+targetCampaign.ZTS_EU_Field_Targeting__c;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        }  
        
    }
    
    public PageReference doAccountRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        campaignId = theUrl.substring(n+3, n+21);
        
        Campaign targetCampaign = [SELECT Id, ZTS_EU_Field_Targeting__c,ZTS_EU_Market__c FROM Campaign WHERE id =: campaignId LIMIT 1];
        if(isIntlRedirect(targetCampaign.ZTS_EU_Market__c)) {
            return doAccRedirectIntl();
        }
        
        if (targetCampaign.ZTS_EU_Field_Targeting__c == 'Open'){
            pageReference pg = new pageReference('/apex/ZTS_US_targetAccount?campId='+campaignId);
            return pg.setRedirect(true);
        }
        else{
            String returnUrl = '/lightning/cmp/c__ErrorToastLC?c__campId='+campaignId+'&c__campTargeting='+targetCampaign.ZTS_EU_Field_Targeting__c;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        }  
        
    }
    
    public PageReference doTgAccountsRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        //campaignId = theUrl.substring(n+3, n+21);--Commented by Aritra (SC-008159)
        campaignId = theUrl.substring(n+3, n+18);//Changed by Aritra SC-008159
        system.debug(campaignId);
        
        Campaign targetCampaign = [SELECT Id, ZTS_EU_Field_Targeting__c,ZTS_EU_Market__c FROM Campaign WHERE id =: campaignId LIMIT 1];
        if(isIntlRedirect(targetCampaign.ZTS_EU_Market__c)) {
            return doTgAccountsRedirectIntl();
        }
        if (targetCampaign.ZTS_EU_Field_Targeting__c == 'Open'){
            pageReference pg = new pageReference('/apex/ZTS_US_Mass_Add_Account_to_Campaign?id='+campaignId+'&fromCamp=true');
            return pg.setRedirect(true);
        }
        else{
            String returnUrl = '/lightning/cmp/c__ErrorToastLC?c__campId='+campaignId+'&c__campTargeting='+targetCampaign.ZTS_EU_Field_Targeting__c;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        }  
        
    }
    
    public PageReference doAccountNARCRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        campaignId = theUrl.substring(n+3, n+21);
        Campaign targetCampaign = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign WHERE id =: campaignId LIMIT 1];
        if (targetCampaign.ZTS_EU_Field_Targeting__c == 'Open'){
            pageReference pg = new pageReference('/apex/ZTS_US_targetAccountNARC?campId='+campaignId);
            return pg.setRedirect(true);
        }
        else{
            String returnUrl = '/lightning/cmp/c__ErrorToastLC?c__campId='+campaignId+'&c__campTargeting='+targetCampaign.ZTS_EU_Field_Targeting__c;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        }  
        
    }
    
    public PageReference doAccountAccIdRedirect()
    {   
        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        campaignId = theUrl.substring(n+3, n+21);
        Campaign targetCampaign = [SELECT Id, ZTS_EU_Field_Targeting__c FROM Campaign WHERE id =: campaignId LIMIT 1];
        if (targetCampaign.ZTS_EU_Field_Targeting__c == 'Open'){
            pageReference pg = new pageReference('/apex/ZTS_EU_targetAccountID?campId='+campaignId);
            return pg.setRedirect(true);
        }
        else{
            String returnUrl = '/lightning/cmp/c__ErrorToastLC?c__campId='+campaignId+'&c__campTargeting='+targetCampaign.ZTS_EU_Field_Targeting__c;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        }  
        
    }
    
    @testVisible
    private Pagereference doRemoveRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_RemoveAccount?id=' + campaignId + '&selectedAccounts=' +targAccIds);
        return pg.setRedirect(true);
    }
    
    @testVisible
    private Pagereference doAccRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_TargetAccount?id=' + campaignId);
        return pg.setRedirect(true);
    }
    
    @testVisible
    private Pagereference doTgAccountsRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_TargetAccounts?id=' + campaignId);
        return pg.setRedirect(true);
    }
    
    @testVisible
    static Boolean isIntlRedirect(String campaignMarket) {
        if(campaignMarket != null && campaignMarket != MARKET_CHECK) {
            return true;
        } 
        else if(campaignMarket == null){
            List<User> runningUser = [SELECT ZTS_EU_Market__c FROM User WHERE Id = :UserInfo.getUserId()];
            if(runningUser.size() > 0 && runningUser[0].ZTS_EU_Market__c != MARKET_CHECK) return true;
        }
        return false;
    }
    
}