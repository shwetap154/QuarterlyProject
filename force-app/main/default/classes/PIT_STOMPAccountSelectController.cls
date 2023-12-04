public with sharing class PIT_STOMPAccountSelectController {

    public PIT_STOMP__c stomp {get;set;}

    public PIT_STOMPAccountSelectController(ApexPages.StandardController controller) {
        stomp = (PIT_STOMP__c)controller.getRecord();
    }

    public PageReference nextButtonAction() {
        if(stomp.PIT_Account__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Account.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        PageReference stompEditPage = new PageReference('/apex/PIT_STOMP_edit?accId='+stomp.PIT_Account__c);
        
        return stompEditPage.setRedirect(true);
    }
    
    public PageReference autoRedirectAction() {
        String accId = ApexPages.currentPage().getParameters().get('accId');
        if(accId == null || accId == '') {
            return null;
        } else {
            stomp.PIT_Account__c = accId;
            return nextButtonAction();
        }
    }
}