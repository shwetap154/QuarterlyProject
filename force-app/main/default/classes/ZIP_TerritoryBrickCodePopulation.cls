/****************************************************************************************************************************************** 
* Class Name   : ZIP_TerritoryBrickCodePopulation
* Description  : To Populate Territory Brick Code field during New Account creation
* Created By   : Chanbasha NBSK 
* Created Date : 29 June 2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Chanbasha NBSK        29/06/2021            To Populate Territory Brick Code field during New Account creation
*****************************************************************************************************************************************/

public class ZIP_TerritoryBrickCodePopulation{
    
    public void territoryBrickCodePopulation(List<Account> accList){
        
        String marketValue = system.label.BrickToTerritory_Market;  
        Set<String> zipcodes=new Set<String>(); 
        Set<String> marketSet = new Set<String>();
        Set<String> zipMarketKey =new Set<String>();
        Set<String> setBrickName = new Set<String>();
        
        
        
        for(Account acc:accList){
            
            if (marketValue != null && marketValue.contains(acc.ZTS_EU_Market__c)){
                
                if(!String.isBlank(acc.ZTS_EU_Zip_Postal_Code__c) && acc.ZTS_EU_Market__c != ZTS_EU_GlobalConstants.MARKET_VAL && acc.ZTS_EU_Market__c != ZTS_EU_GlobalConstants.UK_MARKET_VAL){
                    zipcodes.add(acc.ZTS_EU_Zip_Postal_Code__c);
                }else if(acc.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.MARKET_VAL){
                    zipcodes.add(acc.ZTS_EU_State_County_Value__c);
                }else if(!String.isBlank(acc.ZTS_EU_Zip_Postal_Code__c) && acc.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.UK_MARKET_VAL){
                    zipcodes.add(acc.ZTS_EU_UK_PC4_from_Postalcode__c);
                }
                marketSet.add(acc.ZTS_EU_Market__c);
            }
        }
        if(!zipcodes.isEmpty()){
            
            //Query ziptobrick 
            List<ZTS_GL_ZipToBrick__c> ziptoBrickList = [SELECT Name,ZTS_EU_ZipCode__c,ZTS_EU_BrickCode__c,ZTS_EU_Market__c,ZTS_EU_ZipPostalCode__c,ZTS_EU_Inactive__c,ZTS_EU_Query_Ext_ID__c,ZTS_EU_BrickCode__r.Name,ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c,ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name 
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
                String zipcode = (acc.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.MARKET_VAL)?(acc.ZTS_EU_State_County_Value__c != null ? acc.ZTS_EU_State_County_Value__c : ''):
                (acc.ZTS_EU_Market__c==ZTS_EU_GlobalConstants.UK_MARKET_VAL ? (acc.ZTS_EU_UK_PC4_from_Postalcode__c != '' ? acc.ZTS_EU_UK_PC4_from_Postalcode__c : ''):
                 (acc.ZTS_EU_Zip_Postal_Code__c != null ? acc.ZTS_EU_Zip_Postal_Code__c:''));
                     
                     if(!String.isBlank(zipcode) && zipToBrickMap.containsKey(zipcode+';'+acc.ZTS_EU_Market__c)){
                         List<ZTS_GL_ZipToBrick__c> zipBrickList = zipToBrickMap.get(zipcode+';'+acc.ZTS_EU_Market__c);
                         if(zipBrickList.size()>0)
                         {
                             for(ZTS_GL_ZipToBrick__c z : zipBrickList){
                                 setBrickName.add(z.ZTS_EU_BrickCode__r.Name);
                             }
                             acc.ZTS_EU_BrickCode__c = String.join((Iterable<String>)setBrickName, ';');
                         }
                     }
                
            }
        } 
    }
  }