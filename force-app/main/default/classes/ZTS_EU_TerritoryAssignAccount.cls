/*************************************************************************************
* Name          :    ZTS_EU_TerritoryAssignAccount.
* Description   :    Controller for assigning territory to an account based on zip code .
* Author        :    Deloitte/Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/9/2014       Sunil            Created
11/17/2014     Shefali          Modified for Market Changes
27th-Mar-2015  Shreyas         Modified the class to populate 3 TSF PBC fields via territory alignment. 
16th-Jul-2015  Shreyas         Modified the class to populate TSF PBC fields for countries that dont follow zip to brick alignment.  
**************************************************************************************/
public class ZTS_EU_TerritoryAssignAccount{
    
    public static void assignTerritory(List<Account> accList){
        Set<String> zipcodes=new Set<String>(); 
        Set<String> marketSet = new Set<String>();
        Set<String> zipMarketKey =new Set<String>();
        for(Account acc:accList){
            if(!String.isBlank(acc.ZTS_EU_Zip_Postal_Code__c) && acc.ZTS_EU_Market__c != ZTS_EU_GlobalConstants.MARKET_VAL && acc.ZTS_EU_Market__c != ZTS_EU_GlobalConstants.UK_MARKET_VAL){
                zipcodes.add(acc.ZTS_EU_Zip_Postal_Code__c);
            }else if(acc.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.MARKET_VAL){
                zipcodes.add(acc.ZTS_EU_State_County_Value__c);
            }else if(!String.isBlank(acc.ZTS_EU_Zip_Postal_Code__c) && acc.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.UK_MARKET_VAL){
                zipcodes.add(acc.ZTS_EU_UK_PC4_from_Postalcode__c);
            }
            marketSet.add(acc.ZTS_EU_Market__c);
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
            //Code By Shefali
            for(ZTS_GL_ZipToBrick__c zpToBk :ziptoBrickList){
                zipMarketKey.add(zpToBk.ZTS_EU_Query_Ext_ID__c+';'+ zpToBk.ZTS_EU_Market__c);
            }
            
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
                Boolean clearTerrIdentifier = true;
                
                String zipcode = (acc.ZTS_EU_Market__c == ZTS_EU_GlobalConstants.MARKET_VAL)?(acc.ZTS_EU_State_County_Value__c != null ? acc.ZTS_EU_State_County_Value__c : ''):
                                                    (acc.ZTS_EU_Market__c==ZTS_EU_GlobalConstants.UK_MARKET_VAL ? (acc.ZTS_EU_UK_PC4_from_Postalcode__c != '' ? acc.ZTS_EU_UK_PC4_from_Postalcode__c : ''):
                                                    (acc.ZTS_EU_Zip_Postal_Code__c != null ? acc.ZTS_EU_Zip_Postal_Code__c:''));
                                                    
                if(!String.isBlank(zipcode) && zipToBrickMap.containsKey(zipcode+';'+acc.ZTS_EU_Market__c)){
                    List<ZTS_GL_ZipToBrick__c> zipBrickList = zipToBrickMap.get(zipcode+';'+acc.ZTS_EU_Market__c);
                    Set<String> tsf_tokens=new Set<String>();
                    Set<String> brick_code =new Set<String>();
                    
                    acc.ZTS_EU_TSF_PBC__c=''; //new change
                    acc.ZTS_EU_BrickCode__c = '';
                    
                    for(ZTS_GL_ZipToBrick__c z : zipBrickList){
                        if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                            tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC__c.split(';')); 
                            
                            //prevent duplicates entry in Account TSF field
                            if(!tsf_tokens.contains(z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name)){
                                acc.ZTS_EU_TSF_PBC__c=acc.ZTS_EU_TSF_PBC__c+';'+z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name;
                            }
                        }else{
                            acc.ZTS_EU_TSF_PBC__c=z.ZTS_EU_BrickCode__r.ZTS_EU_Territory__r.name;
                        }
                        
                        if(!String.isBlank(acc.ZTS_EU_BrickCode__c)){
                            brick_code.addAll(acc.ZTS_EU_BrickCode__c.split(';'));
                            
                            //prevent duplicates entry in Account territory brick code field
                            if(!brick_code.contains(z.ZTS_EU_BrickCode__r.name)){
                                acc.ZTS_EU_BrickCode__c =acc.ZTS_EU_BrickCode__c+';'+z.ZTS_EU_BrickCode__r.name;
                            }
                        }else{
                            acc.ZTS_EU_BrickCode__c =z.ZTS_EU_BrickCode__r.name;
                        }
                    }
                      clearTerrIdentifier = false;
                } 
                
                if(clearTerrIdentifier){
                    acc.ZTS_EU_BrickCode__c='';
                    acc.ZTS_EU_TSF_PBC__c= ''; 
                    acc.ZTS_EU_TSF_PBC_1__c='';
                    acc.ZTS_EU_TSF_PBC_2__c='';
                    acc.ZTS_EU_TSF_PBC_3__c='';
                }
            }
        }
    }
  
    /*
    Name: populateTsfPbcFields
    Purpose: populate the 3 tsf pbc fields by splitting the field 'ZTS_EU_TSF_PBC__c' into 3 parts.
    arguments: List<Account>
    return type: none
   */
   
    public static void populateTsfPbcFields(List<Account> accList){
        
        for(Account acc : accList){
            acc.ZTS_EU_TSF_PBC_1__c='';
            acc.ZTS_EU_TSF_PBC_2__c='';
            acc.ZTS_EU_TSF_PBC_3__c='';
            Set<String> tsf_tokens_TSFPBC =new Set<String>();
            if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                tsf_tokens_TSFPBC.addAll(acc.ZTS_EU_TSF_PBC__c.split(';'));
                
                for(string s: tsf_tokens_TSFPBC){
                    String incomingString = s;  
                    Integer len1 = 0;
                    Integer len2 = 0;
                    Integer len3 = 0;
                    Integer incomingLength = 0;
                    Schema.DescribeFieldResult F = Account.ZTS_EU_TSF_PBC_1__c.getDescribe();
                    Integer fieldLength = F.getLength();
                    Set<String> tsf_tokens=new Set<String>();
                    
                    if(!String.isBlank(acc.ZTS_EU_TSF_PBC_1__c)){
                        tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC_1__c.split(';')); 
                        len1 = acc.ZTS_EU_TSF_PBC_1__c.length();
                    }
                    
                    if(!String.isBlank(acc.ZTS_EU_TSF_PBC_2__c)){
                        tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC_2__c.split(';')); 
                        len2 = acc.ZTS_EU_TSF_PBC_2__c.length();
                    }
                    
                    if(!String.isBlank(acc.ZTS_EU_TSF_PBC_3__c)){
                        tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC_3__c.split(';'));
                        len3 = acc.ZTS_EU_TSF_PBC_3__c.length();
                    }
                
                    if(String.isBlank(acc.ZTS_EU_TSF_PBC_1__c)){
                        acc.ZTS_EU_TSF_PBC_1__c = incomingString;
                    }else{
                        //prevent duplicates entry in Account TSF field                                                   
                        if(!tsf_tokens.contains(incomingString)){
                            String incomingStringWithSemiColon = '';
                            incomingStringWithSemiColon = ';' + incomingString;
                            incomingLength = incomingStringWithSemiColon.length();
                            
                            if(len1 + incomingLength <= fieldLength){
                                acc.ZTS_EU_TSF_PBC_1__c = acc.ZTS_EU_TSF_PBC_1__c + incomingStringWithSemiColon;
                            }else{
                                if(String.isBlank(acc.ZTS_EU_TSF_PBC_2__c)){
                                    acc.ZTS_EU_TSF_PBC_2__c = incomingString;
                                }else{
                                    if(len2 + incomingLength <= fieldLength){
                                        acc.ZTS_EU_TSF_PBC_2__c = acc.ZTS_EU_TSF_PBC_2__c + incomingStringWithSemiColon;
                                    }else{
                                        if(String.isBlank(acc.ZTS_EU_TSF_PBC_3__c)){
                                            acc.ZTS_EU_TSF_PBC_3__c = incomingString;
                                        }else{
                                            if(len3 + incomingLength <= fieldLength){
                                                acc.ZTS_EU_TSF_PBC_3__c = acc.ZTS_EU_TSF_PBC_3__c + incomingStringWithSemiColon;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                acc.ZTS_EU_TSF_PBC_1__c='';
                acc.ZTS_EU_TSF_PBC_2__c='';
                acc.ZTS_EU_TSF_PBC_3__c='';
            }
        }
    }
  
   /*
    Name: pageBreak_TsfPbc
    Purpose: This method breaks the contents of the 'TSF PBC' field. Inserts data in new line after every 4 territory names
    arguments: List<Account>
    return type: none
   */
   
    public static void pageBreak_TsfPbc(List<Account> accList){
        List<String> accIdList = new List<String>();
        List<Account> accListFetched = new List<Account>();
        List<Account> accListToUpdate = new List<Account>();
        
        for(Account acc:accList){
            accIdList.add(acc.Id);
        }
        
        accListFetched = [SELECT Id, ZTS_EU_TSF_PBC__c 
        FROM Account 
        WHERE Id IN: accIdList
        AND ZTS_EU_Market__c != 'United States'];
        
        for(Account acc: accListFetched){
            if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                String inputString = acc.ZTS_EU_TSF_PBC__c;
                String inputString_final1 = '';
                List<string> inputString_List = new List<string>();
                Integer i = 0;
                
                inputString_List = inputString.split(';');
                
                for(string s: inputString_List){
                    i = i + 1;
                    if(inputString_final1 == ''){
                        inputString_final1 = inputString_final1 + s.trim();
                    }else{
                        inputString_final1 = inputString_final1 + ';' + s.trim();
                    }
                    
                    if(i == 4){
                        i = 0;
                        inputString_final1 = inputString_final1 + '\r\n';
                    }
                }
                
                String s = inputString_final1.trim();
                
                //inputString_final1=inputString_final1.replaceAll('\n\n','');
                
                acc.ZTS_EU_TSF_PBC__c = inputString_final1;
            }
            accListToUpdate.add(acc);
        }
        
        update accListToUpdate;
        UtilityService.stopUpdateTSFonAccount = true;
    }
     
    /*
    Name: assignTerritoriesForMarketsNotFollowingZipToBrick
    Purpose: This method populates 
    arguments: List<Account>
    return type: none
   */
    public static void assignTerritoriesForMarketsNotFollowingZipToBrick(List<Account> accList){
        
        String userId = UserInfo.getUserId();
        
        List<ZTS_EU_Position__c> positionList = [SELECT Id, ZTS_EU_Territory__c, ZTS_EU_Territory__r.Name, Name, ZTS_EU_Employee__c 
        FROM ZTS_EU_Position__c
        WHERE ZTS_EU_Employee__c =: userId 
        AND ZTS_EU_Territory__c != null 
        AND ZTS_EU_Is_Active__c = true];
        
        Map<String, String> positionMap = new Map<String, String>();
        
        if(positionList.size() > 0){
            
            for(ZTS_EU_Position__c position: positionList){
                
                if(positionMap.containsKey(position.ZTS_EU_Employee__c) ){
                    String tempString = positionMap.get(position.ZTS_EU_Employee__c) + ';' + position.ZTS_EU_Territory__r.Name;
                    positionMap.put(position.ZTS_EU_Employee__c, tempString);
                }else{
                    positionMap.put(position.ZTS_EU_Employee__c, position.ZTS_EU_Territory__r.Name);
                }
            }
        }
        
        for(Account acc: accList){
            if(positionMap.get(userId) != null){
                acc.ZTS_EU_TSF_PBC__c = positionMap.get(userId);
            }
        }
    }
}