/******************************************************************************************************************************************
 * Class Name   : LookupSearchResultWrapper
 * Description  : Class used to serialize a single Lookup search result item
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 24 March 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     03/24/2020          Created.
 * Aritra (Cognizant)		  08/17/2021		  Added new variable sObjectAPIName 
 *****************************************************************************************************************************************/
    public class LookupSearchResultWrapper {
        @AuraEnabled public Id id {get; set;}
        @AuraEnabled public String sObjectType {get; set;}
        @AuraEnabled public SObject record {get; set;}
        @AuraEnabled public String icon {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String subtitle {get; set;}
        @AuraEnabled public String sObjectAPIName {get; set;}

        public LookupSearchResultWrapper(
                Id id,
                String sObjectType,
                String sObjectAPIName,
                String icon,
                String title,
                String subtitle,
                SObject record
        ) {
            this.id = id;
            this.sObjectType = sObjectType;
            this.sObjectAPIName = sObjectAPIName;
            this.icon = icon;
            this.title = title;
            this.subtitle = subtitle;
            this.record = record;
        }


    }