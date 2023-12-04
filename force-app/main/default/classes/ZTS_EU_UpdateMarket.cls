/*************************************************************************************
* Name          :    ZTS_EU_UpdateMarket
* Description   :    This code is written to handle null value of Market on Contact. For FBF users
                     as the market field is read-only and as Market on Contact shouldn't be empty,
                     when the user creates new contact, Market field on Contact will be filled based
                     on Account Market field 
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
 6/13/2014       Chandra            Created

**************************************************************************************/
public Class ZTS_EU_UpdateMarket{
    
    public static void Contact_updateMarket(List<Contact> lstCon){
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        for(Contact con : lstCon){
            if(con.Accountid != Null)
            mapContact.put(con.Accountid,con);
        }
        List<Account> accList = new List<Account>();
        accList = [Select Id, ZTS_EU_Market__c from Account where Id IN : mapContact.keyset() AND ZTS_EU_Market__c != 'United States'];
        Map<Id,String> accountMarketMap = new Map<Id, String>();
        for(Account a : accList){        
            accountMarketMap.put(a.id,a.ZTS_EU_Market__c);
        }
        for(Contact con1 : lstCon){
             if(accountMarketMap.containsKey(con1.accountID)) {
                con1.ZTS_EU_Market__c = accountMarketMap.get(con1.accountid);
            }     
        
        }
    }
}