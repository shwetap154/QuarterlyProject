public with sharing class AccountListController {
    private ApexPages.StandardSetController standardController;
    public Boolean intlUserInUSVFPage {get; set;}

    public AccountListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        String url = Apexpages.currentPage().geturl().substringBefore('?');
        try
        {
            Id accountId = ((Account)standardController.getRecords()[0]).Id;
            
            /* Check to see if in wrong VF Page */
            Account acct = [
                SELECT Id, ZTS_EU_Market__c
                FROM Account
                WHERE Id = :accountId
            ];
            
            if (acct.ZTS_EU_Market__c != 'United States' && !url.contains('INTL'))
            {
                intlUserInUSVFPage = true;
            }
            else
            {
                intlUserInUSVFPage = false;
                if (System.currentPageReference().getParameters().get('chosenIds') != null)
                {
                    List<Account> chosenAccounts = new List<Account>();
                    for (Id acctId : (List<Id>)System.currentPageReference().getParameters().get('chosenIds').split(','))
                    {
                        chosenAccounts.add(new Account(Id = acctId));
                    }
                    standardController.setSelected(chosenAccounts);
                }
            }
        }
        catch (Exception e)
        {
            System.debug('Exception caught: ' + e);
            intlUserInUSVFPage = false;
        }
    }

    public PageReference goToInternationFromUS()
    {
        PageReference pageRef = new PageReference('/apex/AccountAddToCampaignINTL');
        pageRef.getParameters().putAll(System.currentPageReference().getParameters());
		
        List<String> ids = new List<String>();
        for (Account acct : (List<Account>)standardController.getSelected())
        {
            ids.add(acct.Id);
        }
        
        if (ids.size() > 0)
	        pageRef.getParameters().put('chosenIds', String.join(ids, ','));
        
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference doRedirect()
    {       
        if (intlUserInUSVFPage)
        {
            return goToInternationFromUS();
        }
        else
        {
            List<Account> selectedAccs = (List<Account>) standardController.getSelected();
            List<String> selectedRecs = new List<String>();
            String idString;     
            String campId; 
            if (selectedAccs.size() >= 1){
                for(Account selectedAccount : selectedAccs)
                {
                    selectedRecs.add(selectedAccount.id);
                }
                String retUrl = ApexPages.currentpage().getparameters().get('retUrl');
                if(retUrl != null)
                {
                    String prefix = SObjectType.Campaign.getKeyPrefix();
                    campId = prefix + retUrl.subStringBetween('id=' + prefix, '&');
                }
                if(retUrl != null && campId.length() < 15){
                    Integer n = retUrl.indexOf('=a0s');
                    campId = retUrl.substring(n+1, n+16);
                }
                idString = string.join(selectedRecs,',');
                PageReference pg; 
                if(campId != null) {
                    pg = new PageReference('/apex/ZTS_US_AddtoCampaign_Redirect?records=' +idString + '&fromCamp=true&fromCampId=' +campId);
                }
                else {
                    pg = new PageReference('/apex/ZTS_US_AddtoCampaign_Redirect?records=' +idString);
                }
                return pg.setRedirect(true);
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one record.');
                ApexPages.addMessage(myMsg);
                return null;
            }   
        }
    }

    public PageReference doRedirectINTL()
    {       
        List<Account> selectedAccs = (List<Account>) standardController.getSelected();
        List<String> selectedRecs = new List<String>();
        String idString;     
        String campId;
        

        if (selectedAccs.size() >= 1){
            for(Account selectedAccount : selectedAccs)
            {
                selectedRecs.add(selectedAccount.id);
            }       
            String retUrl = ApexPages.currentpage().getparameters().get('retUrl');
            if(retUrl != null)
            {
                String prefix = SObjectType.Campaign.getKeyPrefix();
                campId = prefix + retUrl.subStringBetween('id=' + prefix, '&');
            }
            if(retUrl != null && campId.length() < 15)
            {
                Integer n = retUrl.indexOf('=a0s');
                campId = retUrl.substring(n+1, n+16);
            }
            idString = string.join(selectedRecs,',');
            pageReference pg = new pageReference('/apex/ZTS_EU_AddtoCampaign_Redirect?records=' +idString + '&fromCamp=true&fromCampId=' +campId);
            return pg.setRedirect(true);
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one record.');
            ApexPages.addMessage(myMsg);
            return null;
        }   
    }
}