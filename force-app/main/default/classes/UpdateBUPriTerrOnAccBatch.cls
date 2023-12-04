/*
* Class Name   : UpdateBUPriTerrOnAccBatch
* Description  : TPDEV-490, UpdateBUPriTerrOnAccBatch runs every day and Populate the BU primary territory fields on Accounts from Account Position 
* Summary      : The system  check the AP active and without Exclude sales and then check the BU to populate the field according to the BU.
* Test Class   : UpdateBUPriTerronAccBatch_test
*/
global class UpdateBUPriTerrOnAccBatch implements Database.Batchable <sObject>,System.Schedulable,Database.stateful {
    
    static Map<id,wrapaccount> mainAccountsMap;
    private static final Integer SCHEDULABLE_BATCH_SIZE = 150;
    global Database.QueryLocator start (Database.BatchableContext BC) {
        Market_Metadata_Record__mdt[] getLATAMmarkets = [SELECT id,DeveloperName FROM Market_Metadata_Record__mdt WHERE IsLATAM__c = true];
        Set<String> LATAMmarketset =  new Set<String>();
        for(Market_Metadata_Record__mdt mdtRec :getLATAMmarkets ){
            LATAMmarketset.add(mdtRec.DeveloperName);
        }
        String query = 'SELECT id from Account where ZTS_EU_Market__c IN:LATAMmarketset';
        return Database.getQueryLocator(query);  
    }
    global void Execute(Database.BatchableContext BC,List<sObject> Scope){
        Set<Id>accIDs = new Set<ID>();
        mainAccountsMap = new map<id,wrapaccount>();
        
        for(Account var1:(List<Account>)Scope){
            accIDs.add(var1.id);
        }
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%RU%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             
                             if(acc.Account_Positions__r !=null){
                                 
                                 for(ZTS_EU_Account_Position__c ruPos:acc.Account_Positions__r){
                                      system.debug('mainAccountsmap1' +mainAccountsMap);
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         system.debug('mainAccountsmap1' +mainAccountsMap);
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.RU == null){
                                             instance.RU = ruPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount ruObj = new wrapAccount();
                                         ruObj.RU = ruPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, ruObj);
                                     }
                                 }
                             }
                         }
        
        
        
        for(Account acc:[SELECT Id,(SELECT Id,name,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%CA%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c caPos:acc.Account_Positions__r){
                                     system.debug('mainAccountsMap2' +mainAccountsMap);
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         system.debug('Inside if mainAccountsMap2' +mainAccountsMap);
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.CA == null){
                                             instance.CA = caPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         system.debug('Inside else mainAccountsMap2' +mainAccountsMap);
                                         wrapAccount caObj = new wrapAccount();
                                         caObj.CA = caPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, caObj);
                                          system.debug('Inside else end mainAccountsMap2' +mainAccountsMap);
                                     }
                                 }
                             }
                         }
        
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%SW%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c swPos:acc.Account_Positions__r){
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.SW == null){
                                             instance.SW = swPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount swObj = new wrapAccount();
                                         swObj.SW = swPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, swObj);
                                     }
                                 }
                             }
                         }
        
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%EQ%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c eqPos:acc.Account_Positions__r){
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.EQ == null){
                                             instance.EQ = eqPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount eqObj = new wrapAccount();
                                         eqObj.EQ = eqPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, eqObj);
                                     }
                                 }
                             }
                         }
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%AQ%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c aqPos:acc.Account_Positions__r){
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.AQ == null){
                                             instance.AQ = aqPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount aqObj = new wrapAccount();
                                         aqObj.AQ = aqPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, aqObj);
                                     }
                                 }
                             }
                         }
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%VX%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c vxPos:acc.Account_Positions__r){
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.VX == null){
                                             instance.VX = vxPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount vxObj = new wrapAccount();
                                         vxObj.VX = vxPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, vxObj);
                                     }
                                 }
                             }
                         }
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE ZTS_EU_Position__r.name like '%PY%' AND Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true  LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c pyPos:acc.Account_Positions__r){
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.PY == null){
                                             instance.PY = pyPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount pyObj = new wrapAccount();
                                         pyObj.PY = pyPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, pyObj);
                                     }
                                 }
                             }
                         }
        
        for(Account acc:[SELECT Id,(SELECT Id,ZTS_EU_Position__r.Name FROM Account_Positions__r 
                                    WHERE Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true and ZTS_EU_Position__r.ZTS_PrimaryUser__c = true 
                                    AND ZTS_EU_Call_Target__c!=null Order By ZTS_EU_Call_Target__c DESC LIMIT 1) 
                         FROM Account WHERE Id IN:accIDs ]){
                             if(acc.Account_Positions__r !=null){
                                 for(ZTS_EU_Account_Position__c prmPos:acc.Account_Positions__r){
                                     if(mainAccountsMap.containsKey(acc.Id)){
                                         wrapAccount instance = mainAccountsMap.get(acc.Id);
                                         if(instance.primaryTerr == null){
                                             instance.primaryTerr = prmPos.ZTS_EU_Position__r.Name;
                                             mainAccountsMap.remove(acc.Id);
                                             mainAccountsMap.put(acc.Id,instance);
                                         }
                                     }else{
                                         wrapAccount prmObj = new wrapAccount();
                                         prmObj.primaryTerr = prmPos.ZTS_EU_Position__r.Name ;
                                         mainAccountsMap.put(acc.Id, prmObj);
                                     }
                                 }
                             }
                         }
        
        List<Account> accountToUpdate = new List<Account>();
        for(String accId: mainAccountsMap.keySet()){
            Account accUpdate = new Account();
            accUpdate.Id = accId;
            if(accUpdate.ZTS_CLAR_CA_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_CA_Primary_Territory__c =  mainAccountsMap.get(accId).CA;
            }
            if(accUpdate.ZTS_CLAR_EQ_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_EQ_Primary_Territory__c =  mainAccountsMap.get(accId).EQ;
            }
            if(accUpdate.ZTS_CLAR_PY_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_PY_Primary_Territory__c =  mainAccountsMap.get(accId).PY;
            }
            if(accUpdate.ZTS_CLAR_RU_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_RU_Primary_Territory__c =  mainAccountsMap.get(accId).RU;
            }
            if(accUpdate.ZTS_CLAR_SW_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_SW_Primary_Territory__c =  mainAccountsMap.get(accId).SW;
            }
            if(accUpdate.ZTS_CLAR_AQ_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_AQ_Primary_Territory__c =  mainAccountsMap.get(accId).AQ;
            }
            if(accUpdate.ZTS_CLAR_VX_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_VX_Primary_Territory__c =  mainAccountsMap.get(accId).VX;
            }
            if(accUpdate.ZTS_CLAR_Zoetis_Primary_Territory__c == null){
                accUpdate.ZTS_CLAR_Zoetis_Primary_Territory__c =  mainAccountsMap.get(accId).primaryTerr;
            }
            accountToUpdate.add(accUpdate);
        }            
        if(accountToUpdate.size()>0){
            Database.SaveResult[] AccList = database.update(accountToUpdate,false);
            
            list<ZTS_EU_Error_Log__c> lstError = new list<ZTS_EU_Error_Log__c>();
            for(Database.SaveResult srac :AccList){
                if(!srac.isSuccess()){
                    // Operation failed, so get all errors 
                    String errorMsg = 'UpdateBUPriTerrOnAccBatch '+Datetime.now()+'\n';    
                    for(Database.Error err : srac.getErrors()) {
                        ZTS_EU_Error_Log__c objError = new ZTS_EU_Error_Log__c();
                        objError.ZTS_EU_Message__c = errorMsg+' :: ' + err.getMessage()+' :: fields - '+ err.getFields();
                        objError.ZTS_EU_Log_level__c = 'ERROR';
                        objError.ZTS_EU_Origin_Type__c = 'DML Operations';
                        objError.ZTS_EU_Status_Code__c = string.valueOf(err.getStatusCode()).substring(0,9);
                        objError.ZTS_EU_SObject__c = 'Account';
                        objError.ZTS_EU_Notify_Admin__c = true;
                        lstError.add(objError);
                    }  
                }
            }
            if(lstError.size() > 0){
                insert lstError;
            }
        }
        
        
    }
    global void finish(database.BatchableContext BC){}
    
    global class wrapAccount{
        string VX {get;set;}
        string RU {get;set;}
        string SW {get;set;}
        string AQ {get;set;}
        string CA {get;set;}
        string PY {get;set;}
        string EQ {get;set;}
        string primaryTerr {get;set;}
        wrapAccount(){
            VX = null;
            RU = null;
            SW = null;
            AQ = null;
            CA = null;
            PY = null;
            EQ = null;
            primaryTerr = null;
        }
    }
    
    //The batch class would be scheduled to run  on each day
    public void execute(System.SchedulableContext schedulablecontext){
        database.executeBatch(new UpdateBUPriTerrOnAccBatch(),SCHEDULABLE_BATCH_SIZE);//calling batch class from this point
    }
}