global with sharing class ContentDisplayPageHandler {
       
    // Static hard-coded values
    private static final String LIBRARY_RECORD_TYPE     = 'Library_Content';
    private static final String NEWS_FEED_COMPONENT     = 'Communities_ContentNewsFeed';
    private static final String POWER_PARTNER_USER      = 'PowerPartner';
    private static final String NUM_NEWS_FEED_RECORDS   = '4';
    
    @AuraEnabled
    global static List<ContentVersion> retrieveContentRecords(String componentName){
        String applicableCountries = '';
        String applicableProductLines = '';
        String applicableMarkets = '';
        String applicableAccounts = '';
        String additionalQuery = '';       
        Boolean marketsFound = false;
        Account currentAccount;
        
        Id libraryRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get(LIBRARY_RECORD_TYPE).getRecordTypeId();
        
        // Get Applicable Countries information from User record
        String currentUserId = UserInfo.getUserId();
        User currentUserInfo = [SELECT Id, UserType, Contact.Id, Contact.AccountId, Applicable_Countries__c FROM User WHERE Id = :currentUserId AND ZTS_EU_Market__c != 'United States'];
        String currentUserAccount = currentUserInfo.Contact.AccountId;
        
        if (currentUserInfo.UserType == POWER_PARTNER_USER) { //Current User = PowerParter, apply filters
            
            // Get Applicable Product Lines and Market information from Account record
            Id userAccountId = currentUserInfo.Contact.AccountId;
            currentAccount = [SELECT Id, Name, Applicable_Product_Lines__c, ZTS_EU_Market__c FROM Account WHERE Id = :userAccountId AND ZTS_EU_Market__c != 'United States' LIMIT 1];
            
            // Consider removing, as the library uses markets rather than countries now.
            if (currentUserInfo.Applicable_Countries__c != null) {
                applicableCountries = 'AND Applicable_Countries__c INCLUDES (\'' + currentUserInfo.Applicable_Countries__c.replace(';' , '\',\'' ) + '\') '; // Update 'UGN;TZN' to ''UGN','TZN''...
            } 
            
            // Removed because it would cause documents with no product line to not show up.
            /*
if (currentAccount.Applicable_Product_Lines__c != null) {
applicableProductLines = 'AND Product_Line__c IN (\'' + currentAccount.Applicable_Product_Lines__c.replace(';' , '\',\'' ) + '\') '; // Update 'Apoquel;Stronghold' to ''Apoquel','Stronghold''...     
}
*/
        } 
        
        // Update the additional query based on which lightning component called the page
        if (componentName == NEWS_FEED_COMPONENT) { 
            // If being called from "Recently Added" component update query so Legal/Regulatory are also shown
            additionalQuery = 'AND (Library_File_Type__c IN (\'Legal\', \'Regulatory\') '
                + 'OR (Applicable_Species__c != null ' 
                + applicableCountries
                + applicableProductLines
                + ')) ' 
                + 'ORDER BY CreatedDate DESC LIMIT ' + NUM_NEWS_FEED_RECORDS;
        } else { 
            additionalQuery = 'AND Applicable_Species__c != null '
                + applicableCountries
                + applicableProductLines
                // + 'ORDER BY Product_Line__c ASC';
                + 'ORDER BY Title ASC, CreatedDate DESC';
        }
        
        String queryString = 'SELECT Id, Title, Product_Line__c, Applicable_Species__c, Library_File_Type__c, Applicable_Countries__c, Published_Date__c, CreatedDate, Applicable_Distributors__c, Applicable_Markets__c '
            + 'FROM ContentVersion WHERE RecordTypeId = \'' + libraryRecordTypeId + '\' '
            + 'AND IsLatest = true '
            + additionalQuery;
        
        // List<ContentVersion> contentVersions = Database.query(queryString);
      
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentVersion> unsortedDocs = Database.query(queryString);
        
    
        if (Test.IsRunningTest()) {
            ContentVersion testCV = new ContentVersion(Title = 'Test', VersionData = Blob.valueOf('This is a test attachement'), PathOnClient = 'Test', RecordTypeId = libraryRecordTypeId);
            unsortedDocs.add(testCV);
        }
        
        // Currently non-portal users like customer service and commerical leads can't see library files becuase they have no linked account, and so currentAccount will always be null.
        if (currentAccount != null && (currentUserAccount != null || currentAccount.ZTS_EU_Market__c != null)) {
            for (ContentVersion cv : unsortedDocs) {
                String accountStatus = 'false';
                String marketStatus = 'false';
                
                if (String.isBlank(cv.Applicable_Distributors__c)) {
                    accountStatus = 'blank';
                }
                else if (cv.Applicable_Distributors__c.contains(currentUserAccount)) {
                    accountStatus = 'true';
                }
                
                if (String.isBlank(cv.Applicable_Markets__c)) {
                    marketStatus = 'blank';
                }
                else if (cv.Applicable_Markets__c.contains(currentAccount.ZTS_EU_Market__c)) {
                    marketStatus = 'true';
                }
                if (accountStatus == 'true' || marketStatus == 'true' || (accountStatus == 'blank' && marketStatus == 'blank')) {
                    contentVersions.add(cv);
                }
            }
        }
        
        return contentVersions;
        
    }
    
    @AuraEnabled
    global static String getBaseURL(){ 
       
        String finishedURL;
        String networkId = Network.getNetworkId();
        
        if (Test.IsRunningTest()) {
            // Hard coding for Apex Test because NetworkId can only be retireved when user is logged into community, but in test context, we cannot explicitly login to the community. 
            // See Knowledge Article: https://help.salesforce.com/articleView?id=000320126&language=en_US&type=1
            finishedURL = 'test';
        } else {
            // Get base url (i.e. 'https://atgalpha-zoetis.cs45.force.com/ZoetisDistributorCommunity')
            ConnectApi.Community community = ConnectApi.Communities.getCommunity(networkId);
            finishedURL = community.siteURL + '/sfc/servlet.shepherd/version/download/';
        }
        
        return finishedURL;       
    } 
    
}