/******************************************************************************************************************************************
 * Class Name   : GiftWrapper
 * Description  : Wrapper Class to pull Gift Details on Sales call load (SC-004726)
 * Created By   : Aritra (Cognizant)
 * Created Date : 18 May 2021
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)      18 May 2021          Created.
**************************************************************************************************************************************/
public with sharing class GiftWrapper {
        @AuraEnabled
        public List<LookupSearchResultWrapper> contact {get;set;} // should only be a list of one, needs to be list for lookup lwc even with only a single entry
        @AuraEnabled
		public List<LookupSearchResultWrapper> product {get;set;} // should only be a list of one, needs to be list for lookup lwc even with only a single entry
        @AuraEnabled
        public Id giftId {get;set;}

        @AuraEnabled
        public Decimal quantity  {get;set;}

        @AuraEnabled
        public String description {get;set;}

    
       

        public GiftWrapper(ZTS_EU_Gift__c g) {
            giftId = g.Id;
            quantity = g.ZTS_EU_Quantity__c;
            system.debug('***********Quantity************'+quantity);
            description = g.ZTS_EU_Description__c;
            
        }
}