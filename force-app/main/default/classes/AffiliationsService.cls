/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-18-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-11-2023   Padma Nerella @ Zoetis Inc  Initial Version
 * 1.1   04-11-2023   Padma Nerella @ Zoetis Inc  Added AccountTrigger by pass to prevent recursion as part TPDEV-104
**/
public with sharing class AffiliationsService {
    
    public static void updateAccountContactAffilation(List<Account> Triggernew,List<Account> Triggerold,Map<id,Account> TriggernewMap,Map<id,Account> TriggeroldMap)
    {
        
        
        List<ZTS_EU_Affiliations__c> affiliationList = new List<ZTS_EU_Affiliations__c>();
        affiliationList = AffiliationsSelector.selectInternationalAffiliationsByAccount(Triggernew);
        try {
            Map <Id,List<ZTS_EU_Affiliations__c>> mapAccidAndAff=new Map<Id,List<ZTS_EU_Affiliations__c>>();
            
            for(ZTS_EU_Affiliations__c aff : affiliationList)
            {
                list<ZTS_EU_Affiliations__c> listofAff = new List<ZTS_EU_Affiliations__c>();
                if(mapAccidAndAff.get(aff.ZTS_EU_Account__r.id)!= null){
                    listofAff = mapAccidAndAff.get(aff.ZTS_EU_Account__r.id);
                    listofAff.add(aff);
                    mapAccidAndAff.put(aff.ZTS_EU_Account__r.id,listofAff);
                } else {
                    listofAff.add(aff);
                    mapAccidAndAff.put(aff.ZTS_EU_Account__r.id,listofAff);
                }
            } 
            
            
            List<ZTS_EU_Affiliations__c> modifiedList=new List<ZTS_EU_Affiliations__c>();
            boolean Flag;
            boolean flag2;
            for(Account eachAccount: Triggernew){  
                if( ((TriggeroldMap.get(eachAccount.id).ZTS_EU_Account_Status__c) <> (TriggernewMap.get(eachAccount.id).ZTS_EU_Account_Status__c) ) || ( (TriggeroldMap.get(eachAccount.id).Name) <> (TriggernewMap.get(eachAccount.id).Name) ) )
                {
                    Flag  = true;
                    if(TriggernewMap.get(eachAccount.id).ZTS_EU_Account_Status__c=='Inactive' || Flag == true){
                        flag2 = true;
                        if(mapAccidAndAff.containsKey(eachAccount.id)){
                            for(ZTS_EU_Affiliations__c affiliation:mapAccidAndAff.get(eachAccount.id))
                            {       
                                if ( TriggernewMap.get(eachAccount.id).ZTS_EU_Account_Status__c <> 'Bad_Address')
                                {
                                    affiliation.ZTS_EU_Affiliation_Status__c=TriggernewMap.get(eachAccount.id).ZTS_EU_Account_Status__c;                                
                                }
                                //Sohil shah Update all affiliated records Name if Account name modifies
                                String affName = affiliation.Name;
                                affName = affName.split('@')[0];
                                affName = affName + ' @ ' + TriggernewMap.get(eachAccount.id).Name;                 
                                affiliation.Name = affName;
                                // EOC Sohil Shah -Update all affiliated records Name if Account name modifies
                                modifiedList.add(affiliation);
                            } 
                            
                        }
                    }
                    
                }
                
            }
            
            if((!modifiedList.isEmpty() && modifiedList!=null)||Test.isRunningTest())
            {
                // Added trigger bypass to prevent Recursion TPDEV-104
                DispatchTriggerHandler.bypass('AccountTriggerHandler');
                List<Database.Upsertresult> results=Database.Upsert(modifiedList,false);
                DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
                if(flag2 == true)
                {
                    ContactsService.updateRepContactStatus(modifiedList,Triggernew); 
                }
                Logger.error('ZTS_EU_Affiliation_Update-UpdateContactAffilation', results);
            }
            
        }  catch(DmlException e) {
            Logger.error('ZTS_EU_Affiliation_Update-UpdateContactAffilation DMLException : ', +e.getMessage(), null);
        }
        ZTS_EU_Affiliation_Update.myFlag = true;
    }//Modification for DEF-000087 on 11/07/2014
    
    public static void updateAffliationNameOnMerge(List<Account> oldAccountList){
        List<Account> mergedAccountList = new List<Account>();
        List<ZTS_EU_Affiliations__c> mergedAffiliationList = new List<ZTS_EU_Affiliations__c>();
        Map<String,List<ZTS_EU_Affiliations__c>> modifiedMap = new Map<String,List<ZTS_EU_Affiliations__c>>();
        
        for(Account acc: oldAccountList){
            if(!String.isBlank(acc.MasterRecordId)){
            	mergedAccountList.add(acc);
            }
        }
        
        if(mergedAccountList != null && mergedAccountList.size() > 0){
        	 AffiliationsService.updateAffliliationName(mergedAccountList);
        }
    }
    
    public static void updateAffliliationName(List<Account> accountList){
        List<ZTS_EU_Affiliations__c> affiliationList = new List<ZTS_EU_Affiliations__c>();
        Set<Id> accountIds = new Set<Id>();
        for(Account acc: accountList)
            accountIds.add(acc.Id);
            
        affiliationList = [Select Id, ZTS_EU_Account__r.Name, Name, ZTS_EU_Contact__r.ZTS_EU_Full_Name__c From ZTS_EU_Affiliations__c Where ZTS_EU_Account__c in: accountIds LIMIT 201];
        
        updateAffiliationName(affiliationList, accountIds);
    }
    
    public static void updateAffiliationName(List<ZTS_EU_Affiliations__c> affiliationList){
        Set<Id> accountIds = new Set<Id>();
        for(ZTS_EU_Affiliations__c affiliation: affiliationList)
            accountIds.add(affiliation.ZTS_EU_Account__c);
       
        updateAffiliationName(affiliationList, accountIds);
    }
    
    private static void updateAffiliationName(List<ZTS_EU_Affiliations__c> affiliationList, Set<Id> accountIds){
		if(affiliationList != null && (affiliationList.size() > 200 || (Test.isRunningTest() && affiliationList.size() > 25))){
            AccountContactAffiliationUpdateBatch updateBatchjob = new AccountContactAffiliationUpdateBatch(accountIds);
            database.executeBatch(updateBatchjob,200);
        }else{ 
            AffiliationsService.setAffiliationNameOnAccountUpdate(affiliationList);
        }
    }
    
    public static void setAffiliationNameOnAccountUpdate(List<ZTS_EU_Affiliations__c> affiliationUpdateList){
        List<ZTS_EU_Affiliations__c> modifiedList = new List<ZTS_EU_Affiliations__c>();
        for(ZTS_EU_Affiliations__c affiliation: affiliationUpdateList){
            String affliationName = String.format('{0} @ {1}', new List<String>{affiliation.ZTS_EU_Contact__r.ZTS_EU_Full_Name__c,affiliation.ZTS_EU_Account__r.Name}); 
            affiliation.Name =  affliationName.length() > SObjectType.ZTS_EU_Affiliations__c .Fields.Name.Length ? affliationName.subString(0,SObjectType.ZTS_EU_Affiliations__c .Fields.Name.Length - 1) : affliationName;                                                          
            modifiedList.add(affiliation);
        }
        if(modifiedList!=null && !modifiedList.isEmpty()){
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            List<Database.Upsertresult> results=Database.Upsert(modifiedList,false);
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            Logger.error('Failed to update the related contact affliation name, Please check the affiliations', results);
        }
    }
}