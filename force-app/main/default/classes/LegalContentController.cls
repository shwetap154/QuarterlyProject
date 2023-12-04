public class LegalContentController{   
    public List<ContentVersion> lstContentVersions{get;set;} 
    
    public LegalContentController()
    {
        lstContentVersions = [SELECT Id, title, Library_File_Type__c, Product_Line__c, Applicable_Distributors__c, Applicable_Countries__c, Applicable_Species__c, Applicable_Markets__c FROM contentVersion WHERE Library_File_Type__c IN ('Legal', 'Regulatory')];
    }
    @AuraEnabled
    public static List<ContentVersion> retrieveContentRecords()
        
    {
        Account currentAccount;
        String currentUserId = UserInfo.getUserId();
        User currentUserInfo = [SELECT Id, Contact.Id, Contact.AccountId FROM User WHERE Id = :currentUserId];
        String currentUserAccount = currentUserInfo.Contact.AccountId;
                      
        List<ContentVersion> contentVersions = new List<ContentVersion>();        
        List<ContentVersion> unsortedDocs = new List<ContentVersion>();

        unsortedDocs = [SELECT Id, title, Library_File_Type__c, Product_Line__c, Applicable_Distributors__c, Applicable_Countries__c, Applicable_Species__c, Applicable_Markets__c FROM contentVersion WHERE Library_File_Type__c IN ('Legal', 'Regulatory')];
            
            for (ContentVersion cv : unsortedDocs) {
                
                if (!String.isBlank(cv.Applicable_Distributors__c))
                {
                    if(currentUserAccount != null && cv.Applicable_Distributors__c.contains(currentUserAccount)){
                       contentVersions.add(cv); 
                    }
                }
                else
                {
                    contentVersions.add(cv); 
                }
            }
        
        return contentVersions;           
    }
    @AuraEnabled
    public static String getBaseURL(){ 

        String domainURL = URL.getOrgDomainUrl().toExternalForm();
        List<String> domainName = domainURL.split('.cs');
        String finishedURL = domainName[0] + '.lightning.force.com/sfc/servlet.shepherd/version/download/';
        System.debug('Finished URL = ' + finishedURL);

        return finishedURL;       

    }      
}