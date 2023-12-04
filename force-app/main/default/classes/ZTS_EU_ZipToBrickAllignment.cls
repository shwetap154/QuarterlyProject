/****************************************************************************************************************************************** 
* Class Name   : ZTS_EU_ZipToBrickAllignment
* Description  : To automatic territory assignment from zip to break during New Account creation
* Created By   : Sreekanth Battala
* Created Date : 12 Jan 2023
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sreekanth Battala      12/01/2022         To automatic territory assignment from zip to break during New Account creation
*****************************************************************************************************************************************/

public without sharing class ZTS_EU_ZipToBrickAllignment {
    
     public static Set<String> territoryMarkets(list<Account> accList){
        Set<String> setAllMarket = new Set<String>();
        Set<String> marketSet = new Set<String>();
        string markets  = System.label.ZipToBrickAllignmentMarkets;
        list<string> lstMarkets = markets.split(';');
        for(string market : lstMarkets){
            setAllMarket.add(market);
        }
        for(Account acc:accList){
            if(setAllMarket.contains(acc.ZTS_EU_Market__c)){
                marketSet.add(acc.ZTS_EU_Market__c);
            }
        }
        return marketSet;
    }

    public static void assignTerritory(list<Account> accList, Map<Id, Account> accListOldMap, string action, Set<String> marketSet){
        List<ZTS_AccountTerritory__c> lstAT2Insert = new List<ZTS_AccountTerritory__c>();
        Set<String> zipcodes=new Set<String>(); 

        Set<String> setAccountIds =new Set<String>();
        List<ZTS_AccountTerritory__c> lstOldAts = new List<ZTS_AccountTerritory__c>();
        
        for(Account acc:accList){
            if(!String.isBlank(acc.ZTS_EU_Zip_Postal_Code__c)){
                zipcodes.add(acc.ZTS_EU_Zip_Postal_Code__c);
            }
        }
        
        if(!zipcodes.isEmpty()){
            
            //Query ziptobrick 
            List<ZTS_GL_ZipToBrick__c> ziptoBrickList = [SELECT Name,ZTS_EU_ZipCode__c,ZTS_EU_BrickCode__c,ZTS_EU_Market__c,ZTS_EU_ZipPostalCode__c,ZTS_EU_Inactive__c,
                                                         ZTS_EU_Query_Ext_ID__c,
                                                         ZTS_EU_BrickCode__r.Name,ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c,ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name 
                                                         FROM ZTS_GL_ZipToBrick__c 
                                                         WHERE ZTS_EU_Query_Ext_ID__c IN :zipcodes 
                                                         AND Name != '' 
                                                         AND ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c = false 
                                                         AND ZTS_EU_Inactive__c = false 
                                                         AND ZTS_EU_Market__c IN : marketSet];
            
            List<ZTS_GL_ZipToBrick__c> zipList;
            Map<String,List<ZTS_GL_ZipToBrick__c>> zipToBrickMap = new Map<String,List<ZTS_GL_ZipToBrick__c>>();
            
            for(ZTS_GL_ZipToBrick__c zipToBrick : ziptoBrickList){       
                if(zipToBrickMap.containsKey(zipToBrick.ZTS_EU_Query_Ext_ID__c+';'+zipToBrick.ZTS_EU_Market__c)){
                    zipToBrickMap.get(zipToBrick.ZTS_EU_Query_Ext_ID__c+';'+zipToBrick.ZTS_EU_Market__c).add(zipToBrick);                    
                }else{
                    zipList = new List<ZTS_GL_ZipToBrick__c>();
                    zipList.add(zipToBrick);
                    zipToBrickMap.put(zipToBrick.ZTS_EU_Query_Ext_ID__c+';'+zipToBrick.ZTS_EU_Market__c,zipList);
                }
            }
            
            for(Account acc:accList){
                if(action == 'update' && ((accListOldMap.get(acc.id).ZTS_EU_Market__c != acc.ZTS_EU_Market__c) 
                                          ||(accListOldMap.get(acc.id).ZTS_EU_Sub_Type__c != acc.ZTS_EU_Sub_Type__c)
                                          ||(accListOldMap.get(acc.id).ZTS_EU_Zip_Postal_Code__c != acc.ZTS_EU_Zip_Postal_Code__c)))
                {
                    setAccountIds.add(acc.id);
                }
                
                string zipcode = acc.ZTS_EU_Zip_Postal_Code__c;
                
                if(!String.isBlank(zipcode) && zipToBrickMap.containsKey(zipcode+';'+acc.ZTS_EU_Market__c)){
                    List<ZTS_GL_ZipToBrick__c> zipBrickList = zipToBrickMap.get(zipcode+';'+acc.ZTS_EU_Market__c);
                    
                    Boolean isMultiZipCode = false;
                    Boolean isSubTypeCA = false;
                    Boolean isSubTypeLS = false;
                    if(zipBrickList.size() >= 2){
                        isMultiZipCode = true;
                        if(acc.ZTS_EU_Sub_Type__c.contains('Companion Animal'))
                            isSubTypeCA = true;
                        else 
                            isSubTypeLS = true;
                    }
                    
                    for(ZTS_GL_ZipToBrick__c z : zipBrickList){
                        if(isMultiZipCode){
                            if(isSubTypeCA && z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.Name.Contains('TER-CA')){
                                ZTS_AccountTerritory__c at = createATRecord(z,acc);
                                lstAT2Insert.add(at);
                            } 
                            else if(isSubTypeLS && z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.Name.Contains('TER-LS')){
                                
                                ZTS_AccountTerritory__c at = createATRecord(z,acc);
                                lstAT2Insert.add(at);
                            }
                        }
                        else {
                            ZTS_AccountTerritory__c at = createATRecord(z,acc);
                            lstAT2Insert.add(at);
                        }
                    }                
                }
                
            } 
            
            if(setAccountIds.size() > 0){
                lstOldAts = [Select id from ZTS_AccountTerritory__c where ZTS_EU_Account__c in :setAccountIds];
            }
            if(lstOldAts.size()>0)
            {
                try{
                    delete lstOldAts;
                } catch(Exception ex){
                    ZTS_EU_Logger.error('Exception on ZipToBrick AT Delete : '+ex.getMessage(), null, 'ZTS_EU_ZipToBrickAllignment-generateAndSetupEventsFromCalls - assignTerritory-Delete ');
                }
            }
            if(lstAT2Insert.size()>0)
            {
                try{
                    DispatchTriggerHandler.bypass('AccountTriggerHandler');
                    insert lstAT2Insert;
                    DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
                } catch(Exception ex){
                    ZTS_EU_Logger.error('Exception on ZipToBrick AT Create : '+ex.getMessage(), null, 'ZTS_EU_ZipToBrickAllignment-generateAndSetupEventsFromCalls - assignTerritory ');
                }
            }
            
        }
    }
    public static ZTS_AccountTerritory__c createATRecord(ZTS_GL_ZipToBrick__c z, Account acc){
        ZTS_AccountTerritory__c at = new ZTS_AccountTerritory__c();
        at.ZTS_EU_Territory__c = z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__c;
        at.ZTS_EU_Account__c = acc.Id;
        at.ZTS_Zoetis_SFDC_ID__c = acc.ZTS_EU_Zoetis_SFDC_ID__c;
        at.ZTS_ChangeFlag__c = 'Insert';
        return at;
    }
    
}