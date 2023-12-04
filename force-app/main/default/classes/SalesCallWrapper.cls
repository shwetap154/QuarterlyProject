/******************************************************************************************************************************************
* Class Name   : SalesCallWrapper
* Description  : Class used to serialize a Sales Call object along with its related objects
* Created By   : Slalom/Alex Carstairs
* Created Date : 30 March 2020
*
* Modification Log:
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Alex Carstairs(Slalom)     03/30/2020          Created.
* Aritra(Cognizant)          10/15/2020          Added part for Account Contact Affiliation (SC-008075)
* Aritra(Cognizant)          04/09/2021          Added part for INTL sample and sample drop (SC-004726)
* Aritra(Cognizant)			 06/11/2021			 Added part for Opportunity (SC-008128)
* Aritra(Cognizant)			 12/5/2022			 Added part for Competitors (SC-009358)
*****************************************************************************************************************************************/

public with sharing class SalesCallWrapper {

    @AuraEnabled
    public Id callId {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> attendees {get;set;}
    
    @AuraEnabled
    public List<LookupSearchResultWrapper> affiliations {get;set;} //Added by Aritra (SC-008075)

    @AuraEnabled
    public List<LookupSearchResultWrapper> contacts {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> discussionItems {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> campaigns {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> products {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> users {get;set;}
    
    @AuraEnabled
    public List<LookupSearchResultWrapper> colleagues {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> samples {get;set;}

    @AuraEnabled
    public List<LookupSearchResultWrapper> sampleDrops {get;set;}
    
    @AuraEnabled
    public List<LookupSearchResultWrapper> samplesINTL {get;set;} //Added by Aritra For SC-004726
    
    @AuraEnabled
    public List<LookupSearchResultWrapper> sampleDropsINTL {get;set;} //Added by Aritra For SC-004726

    @AuraEnabled
    public List<LookupSearchResultWrapper> discussions {get;set;}
    
    @AuraEnabled
    public List<FollowUpActivityWrapper> followUpActivities {get;set;}

    @AuraEnabled
    public List<GiftWrapper> gifts {get;set;} //Added by Aritra for SC-004726

    @AuraEnabled
    public List<LookupSearchResultWrapper> opportunities {get;set;} // Added by Aritra for SC-008128
    
    @AuraEnabled
    public List<sObject> competitors {get;set;}// Added by Aritra for SC-009358
    
    @AuraEnabled
    public List<Id> initialDiscussionIds{get; set;}

    @AuraEnabled
    public String nextCallFieldsJson {get; set;}

   
        

    public SalesCallWrapper() {
        attendees = new List<LookupSearchResultWrapper>();
        affiliations = new List<LookupSearchResultWrapper>();//Added by Aritra (SC-008075)
        discussionItems = new List<LookupSearchResultWrapper>();
        campaigns = new List<LookupSearchResultWrapper>();
        products = new List<LookupSearchResultWrapper>();
        colleagues = new List<LookupSearchResultWrapper>();
        opportunities = new List<LookupSearchResultWrapper>();//Added by Aritra for SC-008128
        users = new List<LookupSearchResultWrapper>();
        samples = new List<LookupSearchResultWrapper>();
        samplesINTL = new List<LookupSearchResultWrapper>();//Added for For SC-004726
        sampleDrops = new List<LookupSearchResultWrapper>();
        sampleDropsINTL = new List<LookupSearchResultWrapper>();//Added for For SC-004726
        products = new List<LookupSearchResultWrapper>();
        followUpActivities = new List<FollowUpActivityWrapper>();
        gifts = new List<GiftWrapper>();
        initialDiscussionIds = new List<Id>();
        competitors = new List<sObject>();
    }


}