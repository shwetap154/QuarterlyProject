public with sharing class AccountEventListController 
{
    private ApexPages.StandardSetController standardController;

    public AccountEventListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
        String retUrlOG = ApexPages.currentpage().getparameters().get('retUrl');
        System.debug('   OG    :::' +retUrlOG);
        System.debug('   OG    :::' + ApexPages.currentPage().getParameters().get('eventId'));
    }

    public PageReference doRedirect()
    {   
        System.debug('doRedirect :::: ');
        List<Account> selectedAccs = (List<Account>) standardController.getSelected();
        List<String> selectedRecs = new List<String>();
        String idString;     
        String evntId = '';

        if (selectedAccs.size() >= 1)
        {
            for(Account selectedAccount : selectedAccs)
            {
                selectedRecs.add(selectedAccount.id);
            }       
            idString = string.join(selectedRecs,',');

            String retUrl = ApexPages.currentpage().getparameters().get('retUrl');
            System.debug('   retUrl2    :::' + retUrl);
            if(retUrl != null)
            {
                String prefix = SObjectType.ZTS_Events__c.getKeyPrefix();
                evntId = prefix + retUrl.subStringBetween('id=' + prefix, '&');
            }
            if(retUrl != null && evntId.length() < 15){
                Integer n = retUrl.indexOf('=a0s');
                evntId = retUrl.substring(n+1, n+16);
 
            }
        	String pgRefString = '/apex/ZTS_US_Add_Account_Redirect?records=' + idString; 
            if(String.isNotEmpty(evntId))
            {
                pgRefString += '&eventId=' + evntId;
            }
            pageReference pg = new pageReference(pgRefString);
            System.debug('   before return    :::');
            return pg.setRedirect(false);
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one record.');
            ApexPages.addMessage(myMsg);
            return null;
        }   
    }
}