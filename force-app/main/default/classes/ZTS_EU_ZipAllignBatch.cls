/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_ZipAllignBatch 
* Description   :  Query all the zip codes where To Be Synced is checked.
                   Based on the zip code query all the active accounts and update the ZTS_EU_TSF_PBC__c field based on the zipcode.
                   Based on the ZTS_EU_TSF_PBC__c field value, OOTB assignment rule run and territory is aasigned.

Sequence of events : Account(s) is/are updated with ZTS_EU_TSF_PBC__c field value.
                   : Finish method triggers 
                         ->Execute ZTS_EU_UncheckZip batch class.

* @author       :   Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/14/2014     Sunil           Created the class.
* 1.1    11/18/2014     Shefali         Modified the class for  Market changes
* 1.2    27th-Mar-2015  Shreyas         Modified the class to populate 3 TSF PBC fields via territory alignment. 
********************************************************************************************************************************************/
public class ZTS_EU_ZipAllignBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Double failedUpdates = 0;
    public Set<Id> failedAccountId = new Set<Id>();
    public Map<id,Account> failedAccMap = new Map<id,Account>();
    public List<ZTS_GL_ZipToBrick__c> zipcodeList = new List<ZTS_GL_ZipToBrick__c>();
    public Set<String> marketSet = new Set<String>();   //Added by Shefali
    public string market; //Added by Shefali
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
     // Query all the zipcodes which is changed
      zipcodeList = [select id,ZTS_EU_ZipPostalCode__c,name,ZTS_EU_To_Be_Synced__c,ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c,ZTS_EU_Inactive__c from ZTS_GL_ZipToBrick__c  where ZTS_EU_To_Be_Synced__c = true and ZTS_EU_BrickCode__r.ZTS_EU_Inactive__c = false and ZTS_EU_Inactive__c = false];
     Set<String> zipcodeSet = new Set<String>();
     for(ZTS_GL_ZipToBrick__c  zip :  zipcodeList){
        zipcodeSet.add(zip.ZTS_EU_ZipPostalCode__c);
     
     }
      
      return Database.getQueryLocator([select id,ZTS_EU_TSF_PBC__c,ZTS_EU_TSF_PBC_1__c, ZTS_EU_TSF_PBC_2__c, ZTS_EU_TSF_PBC_3__c, ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Account_Status__c,ZTS_EU_Market__c,ZTS_EU_UK_PC4_from_Postalcode__c,ZTS_EU_State_County_Value__c,ZTS_EU_Excludezipbrickterralignment__c from Account 
                                      where (ZTS_EU_Zip_Postal_Code__c in : zipcodeSet or ZTS_EU_State_County_Value__c in :zipcodeSet or ZTS_EU_UK_PC4_from_Postalcode__c in : zipcodeSet)and IsExcludedFromRealign = false and ZTS_EU_Excludezipbrickterralignment__c = false and ZTS_EU_Market__c =:market]);
    }
    
    public void execute(Database.BatchableContext BC,List<sObject> scope){
        UtilityService.stopUpdateTSFonAccount = true;
        List<Account> accUpdateList = new List<Account>();      
         Set<String> zipcodes=new Set<String>();
          for(sObject s : scope){
            Account a = (Account)s;         
             if(!String.isBlank(a.ZTS_EU_Zip_Postal_Code__c) && a.ZTS_EU_Market__c != ZTS_EU_GlobalConstants.MARKET_VAL && a.ZTS_EU_Market__c != ZTS_EU_GlobalConstants.UK_MARKET_VAL){
                zipcodes.add(a.ZTS_EU_Zip_Postal_Code__c);
              }
              else if(a.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.MARKET_VAL){
                zipcodes.add(a.ZTS_EU_State_County_Value__c);
              }  
              else if(!String.isBlank(a.ZTS_EU_Zip_Postal_Code__c) && a.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.UK_MARKET_VAL){
                zipcodes.add(a.ZTS_EU_UK_PC4_from_Postalcode__c);
              }  
              marketSet.add(a.ZTS_EU_Market__c); // Added by Shefali
         } 
         if(!zipcodes.isEmpty()){
                List<ZTS_GL_ZipToBrick__c> zipList;
                //Query ziptobrick 
               List<ZTS_GL_ZipToBrick__c> ziptoBrickList=[SELECT Name,ZTS_EU_Market__c,ZTS_EU_ZipCode__c,ZTS_EU_ZipPostalCode__c,ZTS_EU_BrickCode__c,ZTS_EU_BrickCode__r.Name,ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name 
                                                          FROM  ZTS_GL_ZipToBrick__c WHERE ZTS_EU_ZipPostalCode__c IN :zipcodes and ZTS_EU_Market__c IN : marketSet];    // Added by Shefali
                                                          
                Map<String,List<ZTS_GL_ZipToBrick__c>> zipToBrickMap=new Map<String,List<ZTS_GL_ZipToBrick__c>>();    
                for(ZTS_GL_ZipToBrick__c zipToBrick:ziptoBrickList){
                     if(zipToBrickMap.containsKey(zipToBrick.ZTS_EU_ZipCode__c +';'+ zipToBrick.ZTS_EU_Market__c)){ // Added by Shefali
                    zipToBrickMap.get(zipToBrick.ZTS_EU_ZipPostalCode__c+';'+ zipToBrick.ZTS_EU_Market__c).add(zipToBrick);    // Added by Shefali                
                }
                else{
                    zipList = new List<ZTS_GL_ZipToBrick__c>();
                    zipList.add(zipToBrick);
                    zipToBrickMap.put(zipToBrick.ZTS_EU_ZipPostalCode__c+';'+ zipToBrick.ZTS_EU_Market__c,zipList);// Added by Shefali
                } // Store ZiptoBrick info based on ZipCode and market. 
                }           
             
             for(sObject s : scope){
                Account acc = (Account)s;
                boolean clearTerrIdentifier=true;
                string trim_str;
                string trim_str2;
                String zipcode=acc.ZTS_EU_Market__c==ZTS_EU_GlobalConstants.MARKET_VAL?(acc.ZTS_EU_State_County_Value__c!= null?acc.ZTS_EU_State_County_Value__c : ''):
                                                    (acc.ZTS_EU_Market__c==ZTS_EU_GlobalConstants.UK_MARKET_VAL ? (acc.ZTS_EU_UK_PC4_from_Postalcode__c!= ''?acc.ZTS_EU_UK_PC4_from_Postalcode__c : ''):
                                                    (acc.ZTS_EU_Zip_Postal_Code__c != null ? acc.ZTS_EU_Zip_Postal_Code__c:''));
                    if(!String.isBlank(zipcode) && zipToBrickMap.containsKey(zipcode+';'+ acc.ZTS_EU_Market__c)){  // Added by Shefali              
                            List<ZTS_GL_ZipToBrick__c> zipBrickList = zipToBrickMap.get(zipcode+';'+ acc.ZTS_EU_Market__c);       // Added by Shefali      
                            Set<String> tsf_tokens=new Set<String>();
                            Set<String> brick_code =new Set<String>();
                            
                            acc.ZTS_EU_TSF_PBC__c='';//new change 
                            acc.ZTS_EU_BrickCode__c = '';
                            for(ZTS_GL_ZipToBrick__c z : zipBrickList){
                                
                                
                                if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                                    tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC__c.split(';')); 
                                    //prevent duplicates entry in Account TSF field                                                   
                                    if(!tsf_tokens.contains(z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name)){
                                        acc.ZTS_EU_TSF_PBC__c=acc.ZTS_EU_TSF_PBC__c+';'+z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name;
                                        trim_str = acc.ZTS_EU_TSF_PBC__c;
                                        acc.ZTS_EU_TSF_PBC__c = trim_str.trim();
                                       
                                    }
                                }
                                else{
                                    acc.ZTS_EU_TSF_PBC__c=z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name;
                                    trim_str2 = acc.ZTS_EU_TSF_PBC__c;
                                    acc.ZTS_EU_TSF_PBC__c = trim_str2.trim();
                                }
                                
                                if(!String.isBlank(acc.ZTS_EU_BrickCode__c)){
                                brick_code.addAll(acc.ZTS_EU_BrickCode__c.split(';')); 
                                //prevent duplicates entry in Account territory brick code field                                                   
                                    if(!brick_code.contains(z.ZTS_EU_BrickCode__r.name)){
                                    acc.ZTS_EU_BrickCode__c =acc.ZTS_EU_BrickCode__c+';'+z.ZTS_EU_BrickCode__r.name;
                                   
                                    }
                                }
                                else{
                                acc.ZTS_EU_BrickCode__c =z.ZTS_EU_BrickCode__r.name;
                                }
                            }
                            clearTerrIdentifier=false;
                        
                    }           
                    if(clearTerrIdentifier){                        
                        acc.ZTS_EU_BrickCode__c='';
                        
                        acc.ZTS_EU_TSF_PBC__c= ''; 
                        acc.ZTS_EU_TSF_PBC_1__c='';
                        acc.ZTS_EU_TSF_PBC_2__c='';
                        acc.ZTS_EU_TSF_PBC_3__c='';
                        
                    }
                    accUpdateList.add(acc);
                    failedAccMap.put(acc.id,acc);
             }
            List<Database.SaveResult> dResult = Database.update(accUpdateList, false);           
                // Iterate through each returned result
            for (Database.SaveResult sr : dResult) {
                if (!sr.isSuccess()) {
                    // Operation was failed, so get the ID of the record that was not processed
                    failedAccountId.add(sr.getId());
                    failedUpdates++;
                }               
             }
         }
    }
    
    public void finish(Database.BatchableContext ctx){  
                
        ZTS_EU_UncheckZip zipUncheck = new ZTS_EU_UncheckZip();
        zipUncheck.failedAccMap = failedAccMap;
        zipUncheck.failedAccountId = failedAccountId;           
        database.executebatch(zipUncheck,20);
   }
}