public with sharing class ZTS_EU_BuyingGroup_Display {

  //Variables declared to hold ids and date fields
    public List<ZTS_EU_Account_Affiliations__c> AccountAffiliation {get; set;} 
    public Account acc {get;set;}
    public boolean showSection{get;set;} 
    public string Message = 'This account is not affiliated to a Buying Group';   
    public ZTS_EU_BuyingGroup_Display(ApexPages.StandardController controller) {
          showSection  = true;
          acc = (Account)controller.getrecord();         
    }
    public pagereference bugaffdisplay(){
    AccountAffiliation = [select id,ZTS_EU_Affiliated_Account__c,ZTS_EU_Account_influence__c,ZTS_EU_Affiliated_Account__r.name,ZTS_EU_Affiliation_Status__c,ZTS_EU_Account__c,ZTS_EU_Account_Role__c,ZTS_EU_Affiliated_Account__r.RecordType.DeveloperName,
                                                                 ZTS_EU_Account__r.RecordType.DeveloperName
                                                                  from ZTS_EU_Account_Affiliations__c 
                                                                  where ZTS_EU_Affiliated_Account__r.RecordType.DeveloperName = 'ZTS_EU_Buying_Group'
                                                                  and ZTS_EU_Account__r.RecordType.DeveloperName != 'ZTS_EU_Buying_Group' 
                                                                  and ZTS_EU_Account__c =:acc.id
                                                                  and ZTS_EU_Affiliation_Status__c ='Active'
                                                                  AND ZTS_EU_Market_from_Primary_Account__c != 'United States' ]; 
    if(AccountAffiliation.size() == 0){
        showSection  = false;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,System.Label.ZTS_EU_BuyingGroupMsg);
        ApexPages.addMessage(myMsg);
    }
           return null;
}
}