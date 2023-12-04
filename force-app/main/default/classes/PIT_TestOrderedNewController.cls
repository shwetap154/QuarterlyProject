public with sharing class PIT_TestOrderedNewController {
    
    private final PIT_Test_Ordered__c testOrdered;
    
    private list<PIT_Test_Cost__c> tests;
    private Id rtypeId;
    public String rtypeName{get;set;}
    private ApexPages.StandardController sController;
    
    public PIT_TestOrderedNewController (ApexPages.StandardController stdController) {
        sController = stdController;
        testOrdered = (PIT_Test_Ordered__c) stdController.getRecord();
        
        if(testOrdered.Id == null) {
            rtypeId = ApexPages.currentPage().getParameters().get('RecordType');
        } else {
            rtypeId = testOrdered.RecordTypeId;
        }
        
        rtypeName = [select Id, DeveloperName from RecordType where Id = :rtypeId].DeveloperName;
        String testType = '';
        
        if(rtypeName.contains('Serology')) {
            testType = 'PAHUS_SEROLOGY_TEST';
        } else if(rtypeName.contains('Swab')) {
            testType = 'PAHUS_SWAB_TEST';
        } else {
            testType = 'PAHUS_TISSUE_TEST';
        }
        
        
        tests = new List<PIT_Test_Cost__c>();
        List<PIT_STOMP__c> parentList = [select Id, PIT_Diagnostic_Lab__c from PIT_STOMP__c where Id = :testOrdered.PIT_STOMP__c];
        if(!parentList.isEmpty()) {
            String lab = parentList[0].PIT_Diagnostic_Lab__c;
        
            tests = [select PIT_Test__c from PIT_Test_Cost__c 
                where PIT_Type__c = :testType and PIT_Diagnostic_Lab__c = :lab ORDER BY PIT_Test__c];
        }
        
       
        
    }
    
    public PageReference saveAndNew() {
        try {
            sController.save();
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg); 
            return null;
        }    
        Map<String, String> headersMap = ApexPages.currentPage().getHeaders();
        PageReference newSTOMPpage = new PageReference(headersMap.get('Referer'));

        return newSTOMPpage.setRedirect(true);
    }
    
    public List<selectOption> getTests() {
        List<selectOption> options = new List<selectOption>();
        options.add(new selectOption('', '--None--'));
        for(PIT_Test_Cost__c t: tests) {
            options.add(new SelectOption(t.PIT_Test__c, t.PIT_Test__c));
        }
        return options; //return the picklist options
    }

}