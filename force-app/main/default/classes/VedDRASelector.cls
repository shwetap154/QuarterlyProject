/****************************************************************************************************************************************** 
 * Class Name   : VedDRASelector
 * Description  : This Class is to query VedDRA Coding records.
 * Created By   : Deloitte/ Sai Saranya Siruvuri
 * Created Date : September 14th 2023
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer               				  Date                Description 
 *
 * ---------------------------------------------------------------------------------------------------------------------------------------
 */
public class VedDRASelector {
    //Retrieves the highest version of VedDRA Coding.
    public static Decimal getHighestVersion() {
        Decimal highestVersion = 0;
        
        List<AggregateResult> maxVersion = [SELECT MAX(Version__c) FROM ZTS_US_VedDRA_Coding__c];
        if (!maxVersion.isEmpty()) {
            highestVersion = (Decimal)maxVersion[0].get('expr0');
        }
        return highestVersion;
    }
    // Retrieves a map of VedDRA Coding records by their Ids.
    public static Map<Id, ZTS_US_VedDRA_Coding__c> getVedDRACodingMap(Set<Id> veddraCodingIds) {
        Map<Id, ZTS_US_VedDRA_Coding__c> mapVedDRACoding = new Map<Id, ZTS_US_VedDRA_Coding__c>(
            [SELECT Id, Version__c FROM ZTS_US_VedDRA_Coding__c WHERE Id IN :veddraCodingIds]
        );

        return mapVedDRACoding;
    }
}