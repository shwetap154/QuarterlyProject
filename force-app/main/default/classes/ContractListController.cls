public with sharing class ContractListController {

    private ApexPages.StandardSetController standardController;
    public List<Contract> selContractList;
    public List<String> targContractIds = new List<String>();
    public String accId;

    public ContractListController(ApexPages.StandardSetController standardController)
    {
        //Getting list of ids from records selected in the list view 
        this.standardController = standardController;
        selContractList = standardController.getSelected();
        for(Contract contr : selContractList){
            targContractIds.add(contr.Id);                       
        }
        System.debug('targContractIds :::'+targContractIds);

        String theUrl = Apexpages.currentPage().getUrl();
        Integer n = theUrl.indexOf('id=');
        accId = theUrl.substring(n+3, n+21);

        System.debug('accId :::'+accId);

    }

    public PageReference doNewRecCreate()
    {   
        try {
            String returnUrl = '/lightning/cmp/c__CreateContractNewLC';
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }

    }

    public PageReference doMassApproveCallout()
    {   
        ZTS_US_ContractBaseClass.massApproveRenewal(targContractIds);
        PageReference pg = new PageReference('/800');
        pg.setRedirect(true);
        return pg;  
    }

    public PageReference doRelListCreate(){
        try {
            String returnUrl = '/lightning/cmp/c__ContractRelListCreateLC?c__accId='+accId;
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static Account getObjects(String account) {
        System.debug('getObjects account ::: '+account);
        return [SELECT id, Name
                        FROM Account
                        WHERE id =: account LIMIT 1];
    }
}