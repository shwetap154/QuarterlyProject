@isTest(isParallel=true)
public with sharing class FixQuotesFromVistexDealTest {   

    @isTest
    static void compareTo_should_work_with_two_null_titles() {
        FixQuotesFromVistexDeal.LookupSearchResult r1 = getSearchResult(null);
        FixQuotesFromVistexDeal.LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(0, compareResult);
    }

    @isTest
    static void compareTo_should_work_with_this_null_title() {
        FixQuotesFromVistexDeal.LookupSearchResult r1 = getSearchResult(null);
        FixQuotesFromVistexDeal.LookupSearchResult r2 = getSearchResult('a');

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(1, compareResult);
    }

    @isTest
    static void compareTo_should_work_with_other_null_title() {
        FixQuotesFromVistexDeal.LookupSearchResult r1 = getSearchResult('a');
        FixQuotesFromVistexDeal.LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(-1, compareResult);
    }

    @isTest
    static void compareTo_should_work_with_non_null_titles() {
        FixQuotesFromVistexDeal.LookupSearchResult r1 = getSearchResult('a');
        FixQuotesFromVistexDeal.LookupSearchResult r2 = getSearchResult('b');

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(-1, compareResult);
    }

    @isTest
    static void getters_should_work() {
        // For the sake of code coverage
        FixQuotesFromVistexDeal.LookupSearchResult r = new FixQuotesFromVistexDeal.LookupSearchResult('0010R00000yvEyRQAU', 'type', 'icon', 'title', 'subtitle');

        System.assertEquals('0010R00000yvEyRQAU', r.getId());
        System.assertEquals('type', r.getSObjectType());
        System.assertEquals('icon', r.getIcon());
        System.assertEquals('title', r.getTitle());
        System.assertEquals('subtitle', r.getSubtitle());
    }

    private static FixQuotesFromVistexDeal.LookupSearchResult getSearchResult(String title) {
        return new FixQuotesFromVistexDeal.LookupSearchResult(null, null, null, title, null);
    }

    @isTest
    static void search_should_return_Account_and_Opportunity() {
        List<Id> fixedResults = new List<Id>(2);
        Vistex_Deal_Header__c deal = CPQ_TestDataFactory.createVistexDealHeader('000001234', '1436', true);
        fixedResults.add(deal.Id);        

        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<FixQuotesFromVistexDeal.LookupSearchResult> results = FixQuotesFromVistexDeal.search('Acc', selectedIds);               
    }

    @isTest
    static void search_should_not_return_selected_item() {
        List<Id> fixedResults = new List<Id>(2);
        Vistex_Deal_Header__c deal1 = CPQ_TestDataFactory.createVistexDealHeader('000001236', '1438', true);
        fixedResults.add(deal1.Id);
        Vistex_Deal_Header__c deal2 = CPQ_TestDataFactory.createVistexDealHeader('000001238', '1438', true);
        fixedResults.add(deal2.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(deal2.Id);

        List<FixQuotesFromVistexDeal.LookupSearchResult> results = FixQuotesFromVistexDeal.search('Acc', selectedIds);
          
    }    
    
}