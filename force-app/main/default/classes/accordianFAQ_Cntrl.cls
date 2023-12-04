public without sharing class accordianFAQ_Cntrl {

    @AuraEnabled
    Public static  string getMarketBasedOnUser(){
        List<user> marketvalue= new List<user>();
        String u = userinfo.getUserId();
        marketvalue = [Select contact.AccountId,ZTS_EU_Market__c from user where Id=: u limit 1];
        
        return marketvalue[0].ZTS_EU_Market__c;
    }
}