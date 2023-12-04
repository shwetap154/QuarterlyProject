public with sharing class PIT_CustomContactLookupController {

    public List<Contact> results { get; set; } // search results
    public String searchString { get; set; } // search keyword
    public String accId{get;set;}

    public PIT_CustomContactLookupController() {
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        accId = System.currentPageReference().getParameters().get('accId');
        runSearch();  
    }

    public PageReference search() {
        runSearch();
        return null;
    }
    
    private void runSearch() {
        results = performSearch(searchString);               
    } 
  
    // run the search and return the records found. 
    private List<Contact> performSearch(string searchString) {
        List<ZTS_EU_Affiliations__c> ctcAffiliations = [SELECT id, ZTS_EU_Contact__c
                                                         FROM ZTS_EU_Affiliations__c WHERE 
                                                         ZTS_EU_Account__c = :accId AND ZTS_EU_Affiliation_Status__c = 'Active' AND ZTS_EU_Market_from_Parent__c = 'United States'];
        
       
        Set<id> contactIds = new Set<id>();
        
        for(ZTS_EU_Affiliations__c ctcAffiliation : ctcAffiliations) {
            contactIds.add(ctcAffiliation.ZTS_EU_Contact__c);
        }


        String soql = 'select id, name from Contact where id in :contactIds AND ZTS_EU_Market__c = \'United States\'';
        if(searchString != '' && searchString != null) {
            soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';
        }  
        soql = soql + ' limit 25';
        System.debug(soql);
        return database.query(soql); 
    
    }
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }

    
}