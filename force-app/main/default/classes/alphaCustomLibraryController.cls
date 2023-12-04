/**
 * @description       : 
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : 
 * @last modified on  : 08-28-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
**/
public without sharing class alphaCustomLibraryController {
    public virtual class NothingFoundException extends Exception {}
    
    @AuraEnabled
    public static String getMarket(Id userId) { //
        try {
            User userAccount = [SELECT Id, ZTS_EU_Market__c, ContactId, Contact.AccountId, Contact.Account.ZTS_EU_Market__c FROM User WHERE Id = :userId LIMIT 1];
            if (String.isNotBlank(userAccount.Contact.Account.ZTS_EU_Market__c)) {
                return userAccount.Contact.Account.ZTS_EU_Market__c;
            }
            else if (String.isNotBlank(userAccount.ZTS_EU_Market__c)) {
                return userAccount.ZTS_EU_Market__c;
            }
            else {
                throw new NothingFoundException('No market found.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion> getFiles(Id userId, Boolean findEditable) {
        try {
            Id libraryRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('Library_Content').getRecordTypeId();
            List<ContentVersion> fileList = new List<ContentVersion>();
            String userMarket = [SELECT Id, ZTS_EU_Market__c FROM User WHERE Id = :userId].ZTS_EU_Market__c;
            
            if (findEditable) {
                fileList = [SELECT Id, Applicable_Distributors__c, Applicable_Markets__c, Applicable_Species__c, FileType, Product_Line__c, Library_File_Type__c, Title, Owner.ZTS_EU_Market__c FROM ContentVersion WHERE Owner.ZTS_EU_Market__c = :userMarket AND IsLatest = true AND RecordTypeId = :libraryRecordTypeId AND Applicable_Species__c != null ORDER BY CreatedDate];
            }
            else {
                fileList = [SELECT Id, Applicable_Distributors__c, Applicable_Markets__c, Applicable_Species__c, FileType, Product_Line__c, Library_File_Type__c, Title, Owner.ZTS_EU_Market__c FROM ContentVersion WHERE Owner.ZTS_EU_Market__c != :userMarket AND IsLatest = true AND RecordTypeId = :libraryRecordTypeId AND Applicable_Species__c != null ORDER BY CreatedDate];
            }
            
            return fileList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Account> accountSearch(List<Id> accountIds){
        try {
            return [SELECT Id, Name, ZTS_EU_Market__c FROM Account WHERE Id IN :accountIds];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean saveFiles(List<Map<String, Object>> dataJson) {
        try {
            List<ContentVersion> allFiles = new List<ContentVersion>();
            Map<String, String> newFileToLibrary = new Map<String, String>();
            for (Map<String, Object> file : dataJson) {
                // Prep library data for later use
                newFileToLibrary.put((String) file.get('Id'), (String) file.get('Library'));
                
                ContentVersion updateFile = new ContentVersion();
                
                updateFile.Id = (String) file.get('Id');
                updateFile.Title = (String) file.get('Title');
                updateFile.Library_File_Type__c = (String) file.get('Library_File_Type__c');
                
                if (String.isNotBlank((String) file.get('Product_Line__c'))) {
                    updateFile.Product_Line__c = (String) file.get('Product_Line__c');
                }
                
                if (((List<Object>) file.get('Applicable_Distributors__c')).size() > 0) {
                    String distributorNames = '';
                    // Because of how Apex parses JSON objects, we need to retrieve the data one unit at a time.
                    for (Object distributor : (List<Object>) file.get('Applicable_Distributors__c')) {
                        Map<String, Object> distributorList = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(distributor));
                        String distributorName = (String) distributorList.get('Id');
                        distributorNames += distributorName + ';';
                    }
                    if (distributorNames.length() > 0) {
                        updateFile.Applicable_Distributors__c = distributorNames.substring(0, distributorNames.length() - 1);
                    }
                }
                else {
                    updateFile.Applicable_Distributors__c = '';
                }
                
                if (((List<Object>) file.get('Applicable_Markets__c')).size() > 0) {
                    String marketNames = '';
                    for (Object market : (List<Object>) file.get('Applicable_Markets__c')) {
                        Map<String, Object> marketList = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(market));
                        String marketName = (String) marketList.get('value');
                        marketNames += marketName + ';';
                    }
                    if (marketNames.length() > 0) {
                        updateFile.Applicable_Markets__c = marketNames.substring(0, marketNames.length() - 1);
                    }
                }
                else {
                    updateFile.Applicable_Markets__c = '';
                }
                
                if (((List<Object>) file.get('Applicable_Species__c')).size() > 0) {
                    String speciesNames = '';
                    for (Object species : (List<Object>) file.get('Applicable_Species__c')) {
                        Map<String, Object> speciesList = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(species));
                        String speciesName = (String) speciesList.get('value');
                        speciesNames += speciesName + ';';
                    }
                    if (speciesNames.length() > 0) {
                        updateFile.Applicable_Species__c = speciesNames.substring(0, speciesNames.length() - 1);
                    }
                }
                else {
                    updateFile.Applicable_Species__c = 'Poultry;Ruminants;Equine;Companion Animals;Swine';
                }
                
                allFiles.add(updateFile);
            }
            update allFiles;
            
            // Check the library value, make changes to all the files that have changed libraries.
            // This section has multiple loops with SOQL calls, which may need to be checked for governor limits.
            List<String> cvIds = new List<String>(newFileToLibrary.keySet());
            Map<String, String> currentFileToLibrary = getFileLibraries(cvIds);
            Map<String, List<String>> newCatalog = new Map<String, List<String>>();
            for (String fileId : cvIds) {
                String newLibrary = newFileToLibrary.get(fileId);
                if (newLibrary != currentFileToLibrary.get(fileId)) {
                    if (newCatalog.get(newLibrary) != null) {
                        newCatalog.get(newLibrary).add(fileId);
                    }
                    else {
                        List<String> fileIdList = new List<String>();
                        fileIdList.add(fileId);
                        newCatalog.put(newLibrary, fileIdList);
                    }
                }
            }
            for (String library : newCatalog.keySet()) {
                changeLibraries(newCatalog.get(library), library);
            }
            
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static ContentVersion uploadFile(String file, Map<String, Object> fileData) {
        // try {
        ContentVersion newFile = new ContentVersion();
        newFile.versionData = EncodingUtil.Base64Decode(file);
        newFile.RecordTypeId = '0123k000000zt0fAAA'; // Library Content record type
        newFile.Title = (String) fileData.get('title');
        newFile.Product_Line__c = (String) fileData.get('productLine');
        newFile.Library_File_Type__c = (String) fileData.get('fileType');
        newFile.PathOnClient = (String) fileData.get('path');
        String allSpecies = '';
        for (Object species : (List<Object>) fileData.get('species')) {
            allSpecies += ((String) species) + ';';
        }
        if (allSpecies.length() > 0) {
            newFile.Applicable_Species__c = allSpecies.substring(0, allSpecies.length() - 1);
        }
        
        String allMarkets = '';
        for (Object market : (List<Object>) fileData.get('market')) {
            allMarkets += ((String) market) + ';';
        }
        if (allMarkets.length() > 0) {
            newFile.Applicable_Markets__c = allMarkets.substring(0, allMarkets.length() - 1);
        }
        
        String allDistributorIds = '';
        for (Object distributorData : (List<Object>) fileData.get('distributor')) {
            Map<String, Object> distributorMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(distributorData));
            String distributorId = (String) distributorMap.get('Id');
            allDistributorIds += distributorId + ';';
        }
        if (allDistributorIds.length() > 0) {
            newFile.Applicable_Distributors__c = allDistributorIds.substring(0, allDistributorIds.length() - 1);
        }
        // newFile.VersionData = Blob.valueOf('a');
        insert newFile;
        
        if (newFile.Id != null) {
            /*
ContentVersion newContentDocument = [SELECT Id, ContentDocumentId, FileType FROM ContentVersion WHERE Id = :newFile.Id];
// Add documents to library
ContentDocumentLink cdl = new ContentDocumentLink();
cdl.ContentDocumentId = newContentDocument.ContentDocumentId;
cdl.ShareType = 'I';
cdl.Visibility = 'AllUsers';
cdl.LinkedEntityId = '0582A000000MIFHQA4'; // Asset Library library
insert cdl;

// Clear the base64 so we pass a much smaller item back to LWC
newFile.versionData = null;
return newFile;
*/
            ContentVersion insertedFile = [SELECT Id, ContentDocumentId, Applicable_Distributors__c, Applicable_Markets__c, Applicable_Species__c, FileType, Library_File_Type__c, Product_Line__c, Title FROM ContentVersion WHERE Id = :newFile.Id];
            // Add documents to library
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = insertedFile.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            // cdl.LinkedEntityId = [SELECT Id FROM ContentWorkSpace WHERE Name = 'Library Content' LIMIT 1].Id;
            cdl.LinkedEntityId = (String) fileData.get('library');
            insert cdl;
            
            return insertedFile;
        }
        else {
            throw new NothingFoundException('File was not uploaded correctly.');
        }
        // } catch (Exception e) {
        //    System.debug(e.getMessage());
        //    throw new AuraHandledException(e.getMessage());
        // }
    }
    
    @AuraEnabled (cacheable = true)
    public static List<ContentWorkSpace> getLibraries(List<String> validLibraries) {
        return [SELECT Id, Name FROM ContentWorkSpace WHERE Name IN :validLibraries];
    }
    
    @AuraEnabled (cacheable = true)
    public static Map<String, String> getFileLibraries(List<String> contentVersionIds) {
        // Must convert from ContentVersion to ContentDocument first
        List<ContentVersion> cvTranslations = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds];
        Map<String, String> cdTranslations = new Map<String, String>();
        List<String> contentDocumentIds = new List<String>();
        for (ContentVersion translation : cvTranslations) {
            cdTranslations.put(translation.ContentDocumentId, translation.Id);
            contentDocumentIds.add(translation.ContentDocumentId);
        }
        
        List<ContentDocumentLink> fileLinks = new List<ContentDocumentLink>();
        if (contentDocumentIds.size() > 0) { 
            fileLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIds];
        }
        Map<String, String> translationReturn = new Map<String, String>();
        for (ContentDocumentLink link : fileLinks) {
            translationReturn.put(cdTranslations.get(link.ContentDocumentId), link.LinkedEntityId);
        }
        return translationReturn;
    }
    
    public static Boolean changeLibraries(List<String> fileIdList, String libraryId) {
        // TODO: Rework flow so that fileIdList is a list of ContentDocument IDs
        if (!String.isBlank(libraryId)) {
            List<String> cdIdList = new List<String>();
            for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :fileIdList]) {
                cdIdList.add(cv.ContentDocumentId);
            }
            
            // Create the link to the new library and update the contentDocument so that it recognizes the library as its parent
            List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
            List<ContentDocument> updateList = new List<ContentDocument>();
            for (String fileId : cdIdList) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = fileId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                cdl.LinkedEntityId = libraryId;
                insertList.add(cdl);
                ContentDocument cd = new ContentDocument();
                cd.Id = fileId;
                cd.ParentId = libraryId;
                updateList.add(cd);
            }
            insert insertList;
            update updateList;
            
            // Delete the old links
            List<ContentDocumentLink> deleteList = new List<ContentDocumentLink>();
            for (String fileId : cdIdList) {
                List<ContentDocumentLink> documentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :fileId AND LinkedEntityId != :libraryId];
                deleteList.addAll(documentLinkList);
            }
            delete deleteList;
        }
        
        return true;
    }
    
    @AuraEnabled
    public static void deleteFile(String fileId) {
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :fileId];
        ContentDocument cd = new ContentDocument(Id = cv.ContentDocumentId);
        delete cd;
    }
    //Added by sweta Kumari-TPDEV-766 -will work for downloading the file.
    @AuraEnabled
    public static List<ContentVersion> downloadFile(String fileId)
    { 
        set<Id> fileIds = new set<Id>();
        fileIds.add(fileId);
        List<ContentVersion> cv = ContentVersionsSelector.selectById(fileIds);
        return cv;
    }
}