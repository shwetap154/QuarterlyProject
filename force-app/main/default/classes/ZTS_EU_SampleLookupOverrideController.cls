/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AddSampleDropsController
* Description   :  This is the controller of the vf page: ZTS_EU_SampleLookupOverride.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     20th-Nov-14   Shreyas             Created the class.

********************************************************************************************************************************************/

public with sharing class ZTS_EU_SampleLookupOverrideController {

    public string callId {get; set;}
    public List<ZTS_EU_Sample__c> sampleList {get; set;}
    public String searchText {get;set;}
    public List<String> contactIdList;
    public string sampleQuery;
    public string sampleQuerySearchConditions;
    public string searchText_Like;
    public boolean showSamples {get; set;}
    public string currentYear;
    public string previousYear;
    
    //tpdev-486
    public static List<Market_Setting__mdt> marketList = [ SELECT Id, Market__c, Enable_Sample_Drop_Call_Year_Limitation__c FROM Market_Setting__mdt WHERE Enable_Sample_Drop_Call_Year_Limitation__c = true ];
    public static Map<String, Boolean> marketValidationMap = new Map<String, Boolean>(); //map to hold market names and checkbox values
    
    static {
        for (Market_Setting__mdt marketSetting : marketList) {
                marketValidationMap.put(marketSetting.Market__c, marketSetting.Enable_Sample_Drop_Call_Year_Limitation__c);
            }
    }
    
    // Constructor
    public ZTS_EU_SampleLookupOverrideController(ApexPages.StandardController controller){
        callId = ApexPages.currentPage().getParameters().get('callId');
        sampleList = new List<ZTS_EU_Sample__c>();
        searchText = '';
        searchText = ApexPages.currentPage().getParameters().get('lksrch');
        
        searchText_Like = '%'+searchText+'%';
        sampleQuery = 'Select Id, Name, ZTS_EU_Product__r.Name, ZTS_EU_Contact__r.Name, ZTS_EU_Account__r.Name, ZTS_EU_Year__c, ZTS_EU_On_Hand_Balance__c from ZTS_EU_Sample__c where ZTS_EU_Contact__c IN: contactIdList';
        
        //tpdev-486: added filters
        List<Call__c> callMarket = [ Select ZTS_EU_Market__c from Call__c where Id =: callId ];
        sampleQuerySearchConditions = '(Name like: searchText_Like OR ZTS_EU_Product__r.Name like: searchText_Like OR ZTS_EU_Contact__r.Name like: searchText_Like OR ZTS_EU_Account__r.Name like: searchText_Like OR ZTS_EU_Year__c like: searchText_Like)';
        if(marketValidationMap.containsKey(callMarket[0].ZTS_EU_Market__c) && marketValidationMap.get(callMarket[0].ZTS_EU_Market__c)) {
            currentYear = String.valueOf(Date.Today().Year());
            previousYear = String.valueOf(Integer.valueOf(currentYear) - 1);
            sampleQuerySearchConditions += ' AND (ZTS_EU_Year__c = :currentYear OR ZTS_EU_Year__c = :previousYear)';
        }
        showSamples = true;
    }   
    
    /*
        Name: getSampleRecords
        Purpose: to fetch the sample records based on the contacts in the attendee list. 
        arguments: none
        return type: none
    */
    public void getSampleRecords(){
    
         contactIdList = new List<String>();
         for(Attendee__c att: [Select ZTS_EU_Contact__c, ZTS_EU_Contact_Profession__c, ZTS_EU_Represents_Account__c from Attendee__c where ZTS_EU_call__c =: callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']){
             contactIdList.add(att.ZTS_EU_Contact__c);
         }
         if(searchText != null){
             sampleQuery = sampleQuery + ' AND '  + sampleQuerySearchConditions;
         }   
        
        sampleList = Database.Query(sampleQuery);
        if(sampleList.size() == 0){
            showSamples = false;
        }
        
    }
    
    /*
        Name: searchSample
        purpose: to search the samples based on the entered text. 
        arguments: pagereference 
        return type: null
    */
    public pagereference searchSample() {
           
           sampleList = new List<ZTS_EU_Sample__c>();
           
           if(searchText != null && searchText.length() > 0){
               searchText_Like = '%'+searchText+'%';
               sampleQuery = sampleQuery + ' AND '  + sampleQuerySearchConditions;
               sampleList = Database.Query(sampleQuery);
           }
           
           if(sampleList.size() > 0){
                 showSamples = true;
           }
           else{
               showSamples = false;
           }
           
           return null; 
    }

}