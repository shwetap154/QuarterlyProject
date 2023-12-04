/****************************************************************************************************************************************** 
 * CLass Name : AccountContactAffiliationListController
 * Description  : Controller for new buttons (that used to be JS) on ZTS_EU_Affiliations__c object
 * Created By   : Slalom(David Stern) 
 * Created Date : 4th June, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern            06/04/2020          Created 
*****************************************************************************************************************************************/
public class AccountContactAffiliationListController 
{
    private ApexPages.StandardController standardController;
    private ApexPages.StandardSetController standardSetController;
    public Id recordId;
    public ZTS_EU_Affiliations__c ACA;
    public List<ZTS_EU_Affiliations__c> queriedACAs;
    public Id contactId;
    public Boolean failTest = false;
    public static final String MARKET_CHECK = 'United States';

    public AccountContactAffiliationListController(ApexPages.StandardController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        recordId = standardController.getRecord().Id;
        ACA = [
            SELECT Id, ZTS_EU_Contact__c, ZTS_EU_Account__c, ZTS_US_LE_Contact__c,
                   ZTS_EU_Account_influence__c, ZTS_US_Job_Function__c
            FROM ZTS_EU_Affiliations__c
            WHERE Id = :recordId
              AND ZTS_EU_Market_from_Parent__c = 'United States'
        ];
        
        contactId = ACA.ZTS_EU_Contact__c;
    }
    
    public AccountContactAffiliationListController(ApexPages.StandardSetController standardSetController)
    {
        //Getting list of ids from records selected in the list view 
        recordId = ApexPages.CurrentPage().GetParameters().get('id');     
    }
    
    public PageReference doMakePrimaryRedirect()
    {
        Contact contactToUpdate = [
            SELECT Id, AccountId, ZTS_US_Account_influence__c, ZTS_US_LE_Contact__c,
                   ZTS_US_Job_Function__c, ZTS_US_UpdateHappeningFromAff__c
            FROM Contact
            WHERE Id = :ACA.ZTS_EU_Contact__c
              AND ZTS_EU_Market__c = 'United States'
        ];
        
        contactToUpdate.AccountId = ACA.ZTS_EU_Account__c;
        contactToUpdate.ZTS_US_Account_influence__c = ACA.ZTS_EU_Account_influence__c;
        contactToUpdate.ZTS_US_LE_Contact__c = ACA.ZTS_US_LE_Contact__c;
        contactToUpdate.ZTS_US_Job_Function__c = ACA.ZTS_US_Job_Function__c;
        contactToUpdate.ZTS_US_UpdateHappeningFromAff__c = true;
        
        //Added below lines to bypass contact duplicate rule during DML on Contact for US (SC-008149)
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.SaveResult sr = Database.update(contactToUpdate,dml);
        if (sr.isSuccess()) {
            System.debug('Possible Duplicate contact has been inserted in Salesforce!');
        }
        
        //update contactToUpdate; -- commented the libe as part of SC-008149
        PageReference pg = new PageReference('/' + ACA.Id);
        return pg.setRedirect(true);
    }
    
    public PageReference doAddAccountAffiliation()
    {
        PageReference pg = new PageReference('/apex/ZTS_US_accountContactAff?conId=' + recordId);
        return pg.setRedirect(true);
    }
    public PageReference doAffiliateExistingContact()
    {
        
        List<ZTS_EU_Affiliations__c> conAff = new List<ZTS_EU_Affiliations__c>();
        if(String.valueOf(recordId).subString(0,3) == '001') {
            List<Account> accountRecord = [SELECT ZTS_EU_Market__c FROM Account WHERE Id = :recordId];
            if(accountRecord.size() > 0 && accountRecord[0].ZTS_EU_Market__c != MARKET_CHECK) {
                return doRedirectIntl();
            }
        } 
        else {
            conAff = [SELECT ZTS_EU_Market_from_Parent__c FROM ZTS_EU_Affiliations__c WHERE Id = :recordId]; // should this check account id?
        }
        if(conAff.size() > 0) {
            if(isIntlRedirect(conAff[0].ZTS_EU_Market_from_Parent__c)) {
                return doRedirectIntl();
            }
        }

        try
        {
            if (Test.isRunningTest() && failTest)
            {
                throw new TestAccountContactAffiliationListCntrl.MyException();
            }
            PageReference pg = new PageReference('/apex/ZTS_US_accountContactAff?accntId=' + recordId);
            return pg.setRedirect(true);
        }
        catch(Exception ex)
        {
            System.debug('Exception:'+ex);
            return null;
        }
    }

    @TestVisible
    private Pagereference doRedirectIntl() {
        PageReference pg = new PageReference('/apex/SL_AffiliateExistingContact?id=' + recordId);
        return pg.setRedirect(true);
    }
    public static Boolean isIntlRedirect(String conAffMarket) {
        if(conAffMarket != null && conAffMarket != MARKET_CHECK) {
            return true;
        } 
        else if(conAffMarket == null){
            List<User> runningUser = [SELECT ZTS_EU_Market__c FROM User WHERE Id = :UserInfo.getUserId()];
            if(runningUser.size() > 0 && runningUser[0].ZTS_EU_Market__c != MARKET_CHECK) return true;
        }
        return false;
    }
}