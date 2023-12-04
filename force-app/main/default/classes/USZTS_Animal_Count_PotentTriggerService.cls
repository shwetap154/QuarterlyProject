/****************************************************************************************************************************************** 
* Class Name   : USZTS_Animal_Count_PotentTriggerService
* Description  : Logic for all US ZTS_Animal_Count_Potential__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 29 June 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     06/29/2020          Created, Logic from all triggers moved to this class.
* Yadagiri Avula          10/13/2023          Added if condition to skip error meesaage for 'Feed Mill' and 'Poultry Count' record types
*****************************************************************************************************************************************/

public without sharing class USZTS_Animal_Count_PotentTriggerService 
{
    
   
    public static void beforeInsert(List<ZTS_Animal_Count_Potential__c> triggerNew) 
    {
        // Added by Yadagiri for TPDEV-1217
        Id feedMillRecordtypeId = Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('Feed_Mill').getRecordTypeId();
        Id poultryCountRecordtypeId = Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('Poultry_Count').getRecordTypeId();
        
        String errorMsg = 'The record of same type already exists on the Selected Account.';
        List<String> accountname = new List<String>();
        List<String> newAccountList = new List<String>();
        List<Id> rcrdtyp = new List<Id>();

        for(ZTS_Animal_Count_Potential__c animalCount : triggerNew){
            newAccountList.add(animalCount.ZTS_EU_Account__c);
        }
        
        List<ZTS_Animal_Count_Potential__c> ACPRecords = [SELECT ZTS_EU_Account__c, RecordTypeId FROM ZTS_Animal_Count_Potential__c WHERE ZTS_EU_Account__c IN: newAccountList];
        System.debug('ACPRecords-->'+ACPRecords);
        //Check if the record type being created on account already exists on it.If yes, display the error message.
        for (ZTS_Animal_Count_Potential__c ExistingRec: ACPRecords)
        {
            for(ZTS_Animal_Count_Potential__c newRec : triggerNew)
            {
                // Added If condition by Yadagiri for TPDEV-1217
                if(newRec.RecordTypeId != feedMillRecordtypeId && newRec.RecordTypeId != poultryCountRecordtypeId ){
                    if(ExistingRec.ZTS_EU_Account__c == newRec.ZTS_EU_Account__c 
                       && ExistingRec.RecordTypeId == newRec.RecordTypeId)
                    {
                        newRec.addError(errorMsg);
                    }
                }
            }       
        } 
    }
    public static void beforeUpdate(List<ZTS_Animal_Count_Potential__c> triggerOld, Map<Id, ZTS_Animal_Count_Potential__c> triggerOldMap, List<ZTS_Animal_Count_Potential__c> triggerNew, Map<Id, ZTS_Animal_Count_Potential__c> triggerNewMap) 
    {
        // Added by Yadagiri for TPDEV-1217
        Id feedMillRecordtypeId = Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('Feed_Mill').getRecordTypeId();
        Id poultryCountRecordtypeId = Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('Poultry_Count').getRecordTypeId();
        String errorMsg = 'The record of same type already exists on the Selected Account.';

        Set<Id> animalCountIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        Map<Id, List<ZTS_Animal_Count_Potential__c>> mapAccountToAcfList = new Map<Id, List<ZTS_Animal_Count_Potential__c>>();

        for(ZTS_Animal_Count_Potential__c animalCount : triggerNew){
            
            animalCountIds.add(animalCount.Id);
            accountIds.add(animalCount.ZTS_EU_Account__c);
        }

        List<ZTS_Animal_Count_Potential__c> animalCountPotList = [ SELECT Id, RecordTypeId, ZTS_EU_Account__c 
                                                                    FROM ZTS_Animal_Count_Potential__c 
                                                                    WHERE ZTS_EU_Account__c IN : accountIds 
                                                                    AND Id NOT IN :animalCountIds ];

        for(ZTS_Animal_Count_Potential__c animalCountPotRec : animalCountPotList){
            if(mapAccountToAcfList.containsKey(animalCountPotRec.ZTS_EU_Account__c))
            {
                List<ZTS_Animal_Count_Potential__c> animalCountList = mapAccountToAcfList.get(animalCountPotRec.ZTS_EU_Account__c);
                animalCountList.add(animalCountPotRec);
                mapAccountToAcfList.put(animalCountPotRec.ZTS_EU_Account__c, animalCountList);

            }
            else 
            {
                List<ZTS_Animal_Count_Potential__c> animalCountList = new List<ZTS_Animal_Count_Potential__c>();
                animalCountList.add(animalCountPotRec);
                mapAccountToAcfList.put(animalCountPotRec.ZTS_EU_Account__c, animalCountList);

            }
        }

        for(ZTS_Animal_Count_Potential__c animalCount : triggerNew)
        {
            if(triggerOldMap.get(animalCount.Id).RecordTypeId != triggerNewMap.get(animalCount.Id).RecordTypeId)
            {
                if(mapAccountToAcfList.containsKey(animalCount.ZTS_EU_Account__c))
                {
                    List<ZTS_Animal_Count_Potential__c> acfList = mapAccountToAcfList.get(animalCount.ZTS_EU_Account__c);

                        for(ZTS_Animal_Count_Potential__c acf:acfList)
                        {
                            // Added if condition by Yadagiri for TPDEV-1217
                            if(animalCount.RecordTypeId != feedMillRecordtypeId && animalCount.RecordTypeId != poultryCountRecordtypeId ){
                            if(acf.RecordTypeId == animalCount.RecordTypeId)
                            {
                                animalCount.addError(errorMsg);
                                break;
                            }
                            }
                        } 

                }
            }
        }
    }
}