/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 *  Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   4/11/2023    Padma Nerella @ Zoetis Inc  Initial Version
**/
public with sharing class AffiliationsSelector {
    public static List<ZTS_EU_Affiliations__c> selectInternationalAffiliationsByAccount(List<Account> newAccList) {
        
        List<ZTS_EU_Affiliations__c> getAffiliationList = [select ZTS_EU_Account__r.id,ZTS_EU_Affiliation_Status__c, Name from ZTS_EU_Affiliations__c where ZTS_EU_Account__r.id IN :newAccList AND ZTS_EU_Market_from_Parent__c != 'United States'];
        
        return getAffiliationList;
        
    }
    
    public static List<ZTS_EU_Affiliations__c> selectInternationalAffiliationsById(List<ZTS_EU_Affiliations__c> accConAffiliationList){
        
        List<ZTS_EU_Affiliations__c> affliatiedContactLst = [Select id, Name, ZTS_EU_Contact__c,ZTS_EU_Account__c, ZTS_EU_Affiliation_Status__c from ZTS_EU_Affiliations__c where id IN:accConAffiliationList AND ZTS_EU_Market_from_Parent__c != 'United States' LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        
        return affliatiedContactLst;
        
    }
}