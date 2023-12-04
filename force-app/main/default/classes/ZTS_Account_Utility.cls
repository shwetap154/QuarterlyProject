/*******************************************************************************************************************************************
* File Name     :  ZTS_Account_Utility
* Description   :  This is the utility class for Account Trigger.                          

* @author       :   CloudSense (Shefali Vinchurkar)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     12th-Dec-14   Shefali Vinchurkar  Created the class.

********************************************************************************************************************************************/

public with sharing class ZTS_Account_Utility{
    public static void checkTerrAlignment(List<Account> newAccounts){
        List<MarketGeoMapping__c> listCustomSettings = [Select Name from MarketGeoMapping__c where Geo__c =: 'CLAR'];
        Set<String> marketSet =new Set<String>();
        for(MarketGeoMapping__c m :listCustomSettings){
            marketSet.add(m.Name);
        }
        
        for(Account a : newAccounts){
            if(marketSet.contains(a.ZTS_EU_Market__c))
                a.ZTS_EU_Excludezipbrickterralignment__c = true;
        }
    }
    
    public static void populateCity(List<sObject> objectList){
        Set<Id> cityId = new Set<ID>();
        for(Sobject a: objectList){
            if((ID)a.get('ZTS_EU_City_Country__c')!=null){
                cityID.add((ID)a.get('ZTS_EU_City_Country__c'));
            } 
        }
        system.debug('cityID###'+cityId);     
        List<City_State__c> cityList =[Select Name from City_State__c where ID IN :cityID];
        Map<Id,String> cityIdNameMap = new Map<Id,String>();
        for(City_State__c c : cityList){
            cityIdNameMap.put(c.Id,c.Name);
        }
        
        for(Sobject a: objectList){
            if((ID)a.get('ZTS_EU_City_Country__c')!=null){
               a.put('ZTS_EU_City__c', cityIdNameMap.get((ID)a.get('ZTS_EU_City_Country__c')));
            }
        }
    }
}