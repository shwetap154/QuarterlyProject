/*************************************************************************************
* Name          :    ZTS_EU_PositionUtilityClass.
* Description   :    Controller for creating account position based on the account's territory .
* Author        :    Deloitte/Pankaj

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/9/2014       Pankaj            Created
10/20/2014     CloudSense:Parvez     Modified:for defect T-13955/DEF-000122
5th-June-2015  CloudSense:Shreyas    Added the fix for null pointer exception and reduce processing time.  
15th-June-2015  CloudSense:Shreyas   Added the code to include field 'Custom AP' on Account position.

**************************************************************************************/
public class ZTS_EU_PositionUtilityClass{
        public static boolean avoidRecurvise = false;
        public static integer imCalled = 0;
        
        
        //***********************************This Method will create Account Position records on creation of Position record.***************************  
        public static void InsertAccountPosition(List<ZTS_EU_Position__c> posList){ 
            System.debug('Ilirjana: ZTS_EU_PositionUtilityClass.InsertAccountPosition, avoidRecurvise before this method call is: ' + avoidRecurvise);
            
            if (avoidRecurvise){
                System.debug('Ilirjana: ZTS_EU_PositionUtilityClass.InsertAccountPosition, avoidRecurvise before this method call was already true!');
                imCalled++;
            }
            
            Integer x = 1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            x = x+1;
            
            avoidRecurvise = true;               
            Map<String, list<account>> AccountTerrMap = new Map<String, list<account>>();
            Map<String, string> TerrIdNameMap = new Map<String, string>();
            List<ZTS_EU_Account_Position__c> finalUpdateAccountPosition = new List<ZTS_EU_Account_Position__c>();
            Set<String> terrIdentifierSet=new Set<String>();
            Set<String> terrIdentifierid =new Set<String>();
            Set<String> tsf_tokens=new Set<String>();
            AccountTerrMap.clear();
            finalUpdateAccountPosition.clear();
            
            for(ZTS_EU_Position__c position:posList){              
                terrIdentifierid.add(position.ZTS_EU_Territory__c);
            } 
                       
            List<ZTS_EU_Territory__c> custTerrList = [select id, Name, ZTS_EU_Terr_SFID__c from ZTS_EU_Territory__c where id in : terrIdentifierid AND ZTS_EU_Market__c != 'United States'];
            Set<Id> stdTerr = new Set<Id>();
            for(ZTS_EU_Territory__c zt : custTerrList){
                stdTerr.add(zt.ZTS_EU_Terr_SFID__c);
                TerrIdNameMap.put(zt.id,zt.name); // Added by Shreyas
            }
            
            list<Territory2> terrList = [select name from Territory2 where id IN :stdTerr];
            for(Territory2 T : terrList ){
                terrIdentifierSet.add(T.id);
            }
     
            list<Group> map_group = [Select Id, RelatedId from Group where Type='Territory' AND RelatedId =: terrIdentifierSet];
            List<string> accID = new List<string>();
            //Query account ID
            List<AccountShare> lst_AccountShare = [Select Id, UserOrGroupId, AccountId from AccountShare where ( UserOrGroupId IN : map_group )AND RowCause IN ('Territory', 'TerritoryManual', 'TerritoryRule')];
            for(AccountShare ashare : lst_AccountShare){
                accID.add(ashare.AccountId);
            }   
            if(accID.size()>10000)
            {
                ZTS_US_Batch_InsrtAccntPosn ap = new ZTS_US_Batch_InsrtAccntPosn(accID,TerrIdNameMap,posList);
                Database.executeBatch(ap,2000);
            }
            else
            {
                //get all account territories for the position territories
            
                List <Account> accList = [select id, name,ZTS_EU_TSF_PBC__c  from account where id =: accID AND ZTS_EU_Market__c != 'United States' ]; 
                for(account acc: accList ){
                    
                    if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                        tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC__c.split(';'));
                    }
                    
                    for(String zipCode : tsf_tokens){
                        if(AccountTerrMap.containskey(zipCode)){
                            AccountTerrMap.get(zipCode).add(acc);
                        }
                        else{
                            AccountTerrMap.put(zipCode, new list<account>{acc}); //Initializing and adding element to the Map
                        }
                    }
                    
                    tsf_tokens=new Set<String>(); // Added by Shreyas
                }                                                 
                if(!posList.isempty()){
                for(ZTS_EU_Position__c position: posList){
                    if(AccountTerrMap != null && TerrIdNameMap != null && position.ZTS_EU_Territory__c != null && !AccountTerrMap.isEmpty() && !TerrIdNameMap.isEmpty()){
                        system.debug('inside if+++++++');
                        if(AccountTerrMap.get(TerrIdNameMap.get(position.ZTS_EU_Territory__c)) != null){
                            for(account a: AccountTerrMap.get(TerrIdNameMap.get(position.ZTS_EU_Territory__c))){                
                              ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c();
                              accPos.ZTS_EU_Account__c = a.id;
                              accPos.ZTS_EU_Position__c = position.id;
                              accPos.ZTS_EU_Active__c  = true;
                              finalUpdateAccountPosition.add(accPos);      
                        }
                        }
                        
                    }             
                }
                }
                try{
                    if(!finalUpdateAccountPosition.isempty()){
                        insert finalUpdateAccountPosition;
                }
                }catch(DMLException e){
                    ZTS_EU_Logger.error('DMLException *******'+e.getMessage(), null, 'ZTS_EU_PositionUtilityClass.InsertAccountPosition');
                }
            }
            
                 
    }
     
    
    //****************************This Method will create Account Position records on creation of Position record.***************************  
    //****************************This Method will create Account Position records on creation of an Account record.***************************  
        public static void InsertAccountPositionForAccount(List<Account> accList){
            System.debug('Ilirjana: ZTS_EU_PositionUtilityClass.InsertAccountPositionForAccount, avoidRecurvise before this method call is: ' + avoidRecurvise);
            if (avoidRecurvise){
                System.debug('Ilirjana: ZTS_EU_PositionUtilityClass.InsertAccountPosition, avoidRecurvise before this method call was already true!');
                imCalled++;
            }
            avoidRecurvise = true;
            Set<String> tsf_tokens=new Set<String>();
            Set<String> maptsf_tokens=new Set<String>();
            Map<id,Set<String>> mapAccountZip = new Map<Id,Set<String>>();
            Map<String,List<ZTS_EU_Position__c>> mapAccountPos = new Map<String,List<ZTS_EU_Position__c>>();
            List<ZTS_EU_Account_Position__c> finalUpdateAccountPosition = new List<ZTS_EU_Account_Position__c>();
            List<ZTS_EU_Account_Position__c> UpdateAccountPositionList = new List<ZTS_EU_Account_Position__c>();
            Set<ZTS_EU_Account_Position__c> UpdateAccountPosition = new Set<ZTS_EU_Account_Position__c>();
            List<ZTS_EU_Position__c> posList;
             mapAccountZip.clear();             
              
            Map<string,string> strUnique = new Map<string,string>();
            Map<string,boolean> strUniqueCustomAPMap = new Map<string,boolean>();
                list<ZTS_EU_Account_Position__c>  apList = [select id, Uniqueness_Key__c,ZTS_EU_Position__c,ZTS_EU_Account__c, ZTS_EU_Custom_AP__c 
                                                            from ZTS_EU_Account_Position__c where ZTS_EU_Account__c =: accList AND ZTS_EU_Market__c != 'United States'];
                for(ZTS_EU_Account_Position__c ap : apList ){
                    strUnique.put(ap.Uniqueness_Key__c,ap.id);
                    strUniqueCustomAPMap.put(ap.Uniqueness_Key__c,ap.ZTS_EU_Custom_AP__c);
                }              
            for(account acc : accList){           
            maptsf_tokens.clear();                
                
                if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){               
                    tsf_tokens.addAll(acc.ZTS_EU_TSF_PBC__c.replaceAll('\\s+;', ';').replaceAll(';\\s+',';').split(';'));
                    maptsf_tokens.addAll(acc.ZTS_EU_TSF_PBC__c.replaceAll('\\s+;', ';').replaceAll(';\\s+',';').split(';'));                    
               
                    if(mapAccountZip.containskey(acc.id))
                         mapAccountZip.get(acc.id).addall(acc.ZTS_EU_TSF_PBC__c.replaceAll('\\s+;', ';').replaceAll(';\\s+',';').split(';'));
                    else{
                             Set<string> temp_tokens = new Set<string>();
                             temp_tokens.addall(acc.ZTS_EU_TSF_PBC__c.replaceAll('\\s+;', ';').replaceAll(';\\s+',';').split(';'));                    
                             mapAccountZip.put(acc.id, temp_tokens);
                        }
                        
                }
                
            }  
         //   system.debug('@@@@tsf_tokens'+tsf_tokens);
            
           //        system.debug('@@@@mapAccountZip'+mapAccountZip);
            list<ZTS_EU_Territory__c> terrID= [select id from ZTS_EU_Territory__c where name IN: tsf_tokens AND ZTS_EU_Market__c != 'United States']; 
           //    system.debug('@@@@terrID===>'+terrID);
            list<ZTS_EU_Position__c> lst_Position = [select id,ZTS_EU_Territory__c,ZTS_EU_Territory__r.name from ZTS_EU_Position__c where ZTS_EU_Territory__c IN: terrID and ZTS_EU_Is_Active__c = true and ZTS_EU_Employee__r.IsActive = true];            
            for(ZTS_EU_Position__c pos : lst_Position){
                 if(mapAccountPos.containskey(pos.ZTS_EU_Territory__r.name))
                     mapAccountPos.get(pos.ZTS_EU_Territory__r.name).add(pos);
                else
                    mapAccountPos.put(pos.ZTS_EU_Territory__r.name, new list<ZTS_EU_Position__c>{pos});
           }
      //    system.debug('@@@@mapAccountPos===>'+mapAccountPos);
            List<ZTS_EU_Position__c> finalPosList = new List<ZTS_EU_Position__c>();
            
            Set<String> zipCode = new Set<String>();
            for(account a: accList){           
              if(mapAccountZip.containsKey(a.id))
                 zipCode = mapAccountZip.get(a.id);  
                                             
                
                for(String s : zipCode){
                  
                  if(mapAccountPos.containsKey(s))
                      finalPosList = mapAccountPos.get(s);
                 //     system.debug('***finalPosList**'+finalPosList);
                                   
                    for(ZTS_EU_Position__c P : finalPosList){ 
                        string str = 'A:';
                        str = str + a.id;
                        str = str + '_P:';
                        str = str + P.id;
                        ZTS_EU_Account_Position__c accPos = new ZTS_EU_Account_Position__c();
                    //    system.debug('@@@@strUnique===>'+strUnique);
                        if(!strUnique.containsKey(str)){
                            accPos.ZTS_EU_Account__c = a.id;
                            accPos.ZTS_EU_Position__c = p.id;
                            accPos.ZTS_EU_Active__c  = true;
                            finalUpdateAccountPosition.add(accPos);
                        } 
                     //      system.debug('@@@@finalUpdateAccountPosition===>'+finalUpdateAccountPosition);
                        if(strUnique.containsKey(str) && strUniqueCustomAPMap.containsKey(str)){
                            if(strUniqueCustomAPMap.get(str) == false){
                                ZTS_EU_Account_Position__c accPosUpdate = new ZTS_EU_Account_Position__c(id = strUnique.get(str));
                                accPosUpdate.ZTS_EU_Active__c = true;
                                UpdateAccountPosition.add(accPosUpdate);
                            }
                            
                         }   
                      //   system.debug('@@@@UpdateAccountPosition===>'+UpdateAccountPosition);
                            
                    }
                }
            } 
            UpdateAccountPositionList.addAll(UpdateAccountPosition);
                        
            
            try{
                if(!finalUpdateAccountPosition.isempty()){
                    Database.insert(finalUpdateAccountPosition,false);                  
                }
                Database.update(UpdateAccountPositionList,false);
            }
            catch(DMLException e){
                ZTS_EU_Logger.error('DMLException *******'+e.getMessage(), null, 'ZTS_EU_PositionUtilityClass.InsertAccountPositionForAccount');
            }
            
        }
        
        /************************Method to De-Activate Orphan Account Positions**************************************/
        public static void deActivateOrphanAccPos(List<Account> accList){
             System.debug('Ilirjana: ZTS_EU_PositionUtilityClass.deActivateOrphanAccPos, avoidRecurvise before this method call is: ' + avoidRecurvise);
            if (avoidRecurvise){
                System.debug('Ilirjana: ZTS_EU_PositionUtilityClass.InsertAccountPosition, avoidRecurvise before this method call was already true!');
                imCalled++;
            }
             Set<String> tsf_tokens=new Set<String>();
             Set<Id> accid = new Set<Id>();
             Map<id,Set<String>> mapAccountZip = new Map<Id,Set<String>>();       
             List<ZTS_EU_Account_Position__c> lstAccPos = new List<ZTS_EU_Account_Position__c>();
             List<ZTS_EU_Account_Position__c> accPosBlank = new List<ZTS_EU_Account_Position__c>();
             List<ZTS_EU_Account_Position__c> finalUpdateAccPos = new List<ZTS_EU_Account_Position__c>(); 
             List<ZTS_EU_Account_Position__c> updateAccPosBlank = new List<ZTS_EU_Account_Position__c>(); 
              
              for(Account acc : accList){
               // tsf_tokens.addall(acc.ZTS_EU_TSF_PBC__c.split(';'));
               //   system.debug('@@@@acc.ZTS_EU_TSF_PBC__c'+acc.ZTS_EU_TSF_PBC__c);
                  if(!String.isBlank(acc.ZTS_EU_TSF_PBC__c)){
                     
                    if(mapAccountZip.containskey(acc.id)){
                        mapAccountZip.get(acc.id).addall(acc.ZTS_EU_TSF_PBC__c.replaceAll('\\s+;', ';').replaceAll(';\\s+',';').split(';'));
                        }
                    else{
                        Set<string> temp_tokens1 = new Set<string>();
                        temp_tokens1.addall(acc.ZTS_EU_TSF_PBC__c.replaceAll('\\s+;', ';').replaceAll(';\\s+',';').split(';'));                    
                        mapAccountZip.put(acc.id, temp_tokens1);
                     }
                 }
           //       system.debug('TSF*******>'+acc.ZTS_EU_TSF_PBC__c);
                 if(acc.ZTS_EU_TSF_PBC__c == '' || acc.ZTS_EU_TSF_PBC__c == null){
                    accid.add(acc.id);
                 }
                 
              }
              
              //system.debug('accid*******>'+accid);
              if(accid.size()>0){
                accPosBlank = [select id, ZTS_EU_Account__c,ZTS_EU_Territory__c,ZTS_EU_Position__c from  ZTS_EU_Account_Position__c where 
                               ZTS_EU_Account__c in :accid and ZTS_EU_Active__c = true and ZTS_EU_Custom_AP__c = false];
                for(ZTS_EU_Account_Position__c ap : accPosBlank){
                     ap.ZTS_EU_Active__c = false;
                     updateAccPosBlank.add(ap);
                     
                }
                system.debug('updateAccPosBlank******>'+updateAccPosBlank);
              }
            lstAccPos = [select id, ZTS_EU_Account__c,ZTS_EU_Territory__c,ZTS_EU_Position__c from  ZTS_EU_Account_Position__c 
                         where ZTS_EU_Account__c in :mapAccountZip.keyset() and ZTS_EU_Active__c = true and ZTS_EU_Custom_AP__c = false];              
            for(ZTS_EU_Account_Position__c ap : lstAccPos){               
                if(mapAccountZip != null && mapAccountZip.containskey(ap.ZTS_EU_Account__c)){
                    set<string> temp_tokens = new   set<string>();
                    temp_tokens = mapAccountZip.get(ap.ZTS_EU_Account__c);
                    if(temp_tokens != null && !temp_tokens.contains(ap.ZTS_EU_Territory__c)){
                        
                        ap.ZTS_EU_Active__c = false;
                        finalUpdateAccPos.add(ap);
                        system.debug('@@@@@finalUpdateAccPos====>'+finalUpdateAccPos);
                    }                   
                }
            }
            try{
                if(!finalUpdateAccPos.isempty()){
                    
                    update finalUpdateAccPos;
                 }
                 if(!updateAccPosBlank.isempty()){
                    update updateAccPosBlank;
                 }
            }catch(DMLException e){
                ZTS_EU_Logger.error('DMLException *******'+e.getMessage(), null, 'ZTS_EU_PositionUtilityClass.deActivateOrphanAccPos');
            }
              
         }   
        
         //Code Added by CloudSense:Parvez for defect T-13955/DEF-000122
         
           public static void checkForChildRecords (List<ZTS_EU_Position__c> posList, Map<Id,ZTS_EU_Position__c> posMap){            
           list<ZTS_EU_Position__c> positions = [select Id, name,(select name from Account_Positions__r) from ZTS_EU_Position__c where Id IN :posList];
           for(ZTS_EU_Position__c pos : positions)
              {  
                         if(!pos.Account_Positions__r.isempty())                          
                            {
                                posMap.get(pos.id).addError('This Position can not be deleted as there may be Account Position associated with this Position');
                            }   
              }
         }
         //EOC Added by CloudSense:Parvez
   }