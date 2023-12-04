public with sharing class FixQuotesFromVistexDeal {    

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static string submit(String dealId){        
        System.debug('DealId:' + dealId);
        if (dealId == null){            
            return 'No Vistex Deal to remove';
        }

        try{
            // Call RemoveDealFromQuoteLinesBatchable batch class to remove incorrect deals from quotelines
            RemoveDealFromQuoteLinesBatchable batch = new RemoveDealFromQuoteLinesBatchable(dealId);
            Id batchId = Database.executeBatch(batch);
        } catch (Exception ex) {
            System.debug('Exception: ' + ex);
            return 'Exception: ' + ex.getMessage();
        }
        
        return '';
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING                
                Vistex_Deal_Header__c(Id, Name WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();        

        // Extract Viste Deal & convert them into LookupSearchResult
        String dealIcon = 'standard:article';
        Vistex_Deal_Header__c[] deals = (List<Vistex_Deal_Header__c>) searchResults[0];
        for (Vistex_Deal_Header__c deal : deals) {
            results.add(
                new LookupSearchResult(
                    deal.Id,
                    'Vistex_Deal_Header__c',
                    dealIcon,
                    deal.Name,
                    'Deal • ' + deal.Name
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }  
    


    /**
     * Class used to serialize a single Lookup search result item
     * The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
     */
    public class LookupSearchResult implements Comparable {
        private Id id;
        private String sObjectType;
        private String icon;
        private String title;
        private String subtitle;

        public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
            this.id = id;
            this.sObjectType = sObjectType;
            this.icon = icon;
            this.title = title;
            this.subtitle = subtitle;
        }

        @AuraEnabled
        public Id getId() {
            return id;
        }

        @AuraEnabled
        public String getSObjectType() {
            return sObjectType;
        }

        @AuraEnabled
        public String getIcon() {
            return icon;
        }

        @AuraEnabled
        public String getTitle() {
            return title;
        }

        @AuraEnabled
        public String getSubtitle() {
            return subtitle;
        }

        /**
         * Allow to sort search results based on title
         */
        public Integer compareTo(Object compareTo) {
            LookupSearchResult other = (LookupSearchResult) compareTo;
            if (this.getTitle() == null) {
                return (other.getTitle() == null) ? 0 : 1;
            }
            if (other.getTitle() == null) {
                return -1;
            }
            return this.getTitle().compareTo(other.getTitle());
        }
    }

}