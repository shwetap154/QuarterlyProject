public with sharing class CustomContractControllerLwc {
    @AuraEnabled(cacheable=true)
    public static List<Document> getDocList() {
        List<Document> docList = new List<Document>();
        docList = [SELECT Id,Name FROM Document WHERE Name = 'MZR BIOS Calculator'];
        System.debug('docList  ::: '+docList);
        return docList;
    }
}