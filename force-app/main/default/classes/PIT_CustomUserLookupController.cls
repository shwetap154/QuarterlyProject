public with sharing class PIT_CustomUserLookupController {
    
    public List<User> results{get;set;} // search results
    public String searchString{get;set;} // search keyword
    public String accId{get;set;}
    
    public PIT_CustomUserLookupController() {
        
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
    private List<User> performSearch(string searchString) {

        List<ZTS_EU_Position__c> userTerritories = [SELECT id, ZTS_EU_Employee__c FROM ZTS_EU_Position__c WHERE ZTS_EU_Territory__r.ZTS_FieldForce_ID__c = '813'];
       
        Set<id> vetsId = new Set<id>();
        
        for(ZTS_EU_Position__c userTerritory : userTerritories) {
            vetsId.add(userTerritory.ZTS_EU_Employee__c);
        }


        String soql = 'select id, name from User where id in :vetsId AND ZTS_EU_Market__c = \'United States\'';
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