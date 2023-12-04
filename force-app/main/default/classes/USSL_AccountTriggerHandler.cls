/**
* @ClassName    : SL_AccountTriggerHandler 
* @JIRATicket   : ZETM-16
* @CreatedOn    : 21st November,2018
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : 
* @Description  : Handler for the trigger ZTS_US_Account on the object Account for the various event functionality.
* Update log:
*    Updated By                Date             Comments
*    Shiva Kudikilla           15-Feb-2019      SC-002752 - Update LE Contract's Send_Email_to_LE_Owner__c field to True when Prospect Account is NARC'd
*    Shiva Kudikilla           02-May-2019      SC-002907 - Ref SC-002883- Additional MZR Fields to Inherit from Parent Account
*    Keerthi Chandra           13-Apr-2019      SC-002910 - Avoid duplicate AT & Account Team
*    Ethan Hirsch              07-Jul-2022      US-000871 - Remove Test.isRunningTest around updateAccountContractDetails in afterUpdate to fix a Unit Test 
*                                                           in AccSegmentationTest
*    Padma Nerella             01-Jan-2023      TPDev-103 - added logic to get the accounts with emails changes and passed those accounts to ContactsService class to update the contact
*    Prasun Dubey 			   03-Oct-2023      TPDEV-1005 Update the account contact affliation name on accountMerge 
*/
public with sharing class USSL_AccountTriggerHandler 
{

    @testVisible static final String BEFORE_UPDATE_ORIGIN_TYPE = 'USSL_AccountTriggerHandler - onBeforeUpdate: update accounts';
    @testVisible static final String AFTER_DELETE_ACC_POS_ORIGIN_TYPE = 'USSL_AccountTriggerHandler - onAfterDelete: delete account positions';
    @testVisible static final String AFTER_DELETE_ACC_TERR_ORIGIN_TYPE = 'USSL_AccountTriggerHandler - onAfterDelete: delete account territories';

    /***********
    * Method name  : onBeforeInsert
    * Description  : This will update MZR fields on Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/  
    public void onBeforeInsert(List<Account> lstAccountNew)
    {
        for(Account acc : lstAccountNew)
        {
            if(acc.ZTS_US_NARC_ID__c != null)
            {
                acc.MZR_Status__c = 'Eligible';
                acc.MZR_Tier__c = 'T0 - Opal ($0 - $24,999)';
            }
        }
    }
    
    /***********
    * Method name  : onBeforeUpdate
    * Description  : This will update MZR fields on Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public void onBeforeUpdate(List<Account> lstAccountNew, Map<Id, Account> mapAccountOld)
    {
        // update Account Contact Affiliation to inactive if Account is inactive.
        Map <Id,Account> updMap = new Map <Id,Account>();
        ZTS_US_addrCreationAndUpdateFromAccount.updateAccConAffInactive(lstAccountNew);
        
        // update the contract related fields to null if the parent account is blanked out.
        Map <Id,Account> childAccs = new Map <Id,Account>();
        Map <Id,Account> parentAccs = new Map <Id,Account>();
        //Map <Id,Account> parentAccs_Tier = new Map <Id,Account>();
        List <Id> oldParentAccIds = new List<Id>();
        
        for(Account acc:lstAccountNew)
        {
            if((mapAccountOld.get(acc.id).ParentId!=acc.ParentId) && (String.isBlank(acc.ParentId)))
            updMap.put(acc.id, acc);
            
            //SC-002613 - updated listening logic 08012018
            if( (String.isBlank(acc.MZR_Status__c) || acc.MZR_Status__c =='Eligible' )
            && (((mapAccountOld.get(acc.Id).ZTS_US_VGP_Enrollment_Status__c != acc.ZTS_US_VGP_Enrollment_Status__c) 
            && (acc.ZTS_US_VGP_Enrollment_Status__c != null && (acc.ZTS_US_VGP_Enrollment_Status__c.contains('Accepted T&C') || acc.ZTS_US_VGP_Enrollment_Status__c == 'VGP Enrolled')))))
            {
                acc.MZR_Status__c = 'Not Eligible';
                acc.MZR_Tier__c = null;
            }
            
            //SC-002613 Update and Compilation of all listening logics
            if( (mapAccountOld.get(acc.Id).ZTS_US_NARC_ID__c == null && acc.ZTS_US_NARC_ID__c != null) )
            { 
                acc.MZR_Status__c = 'Eligible';
                acc.MZR_Tier__c = 'T0 - Opal ($0 - $24,999)';
            } 
            
            //SC-002202 
            //When a new prospect account gets NARC'd then set MZR Status to Eligible
            //When child Account leaves hierarchy from Parent, then make child's MZR status to Eligible 
            if( (mapAccountOld.get(acc.Id).ParentId != null && mapAccountOld.get(acc.id).ParentId != acc.ParentId))
            {
                //oldParentAccIds.add(mapAccountOld.get(acc.id).ParentId);
                acc.MZR_Status__c = 'Eligible';
                acc.MZR_Tier__c = null;
            } 
            
            //SC-002482 When child Account leaves hierarchy from Parent, then make child's MZR BIOS Account to False
            if( (mapAccountOld.get(acc.Id).ParentId != null && mapAccountOld.get(acc.id).ParentId != acc.ParentId))
            { 
                acc.ZTS_US_MVP_Account__c = false;
                acc.ZTS_US_MVP_BIOS__c = null;
            } 
            
            //SC-002202 -- When Parent Account's MZR Status is updated then update its children accordingly
            if( (mapAccountOld.get(acc.Id).ParentId == acc.ParentId) && (acc.ParentId == null) 
            && (mapAccountOld.get(acc.Id).MZR_Status__c != acc.MZR_Status__c) 
            && (acc.MZR_Status__c == 'Active' || acc.MZR_Status__c == 'Not Eligible'))
            {
                if(acc.MZR_Status__c == 'Not Eligible'){
                    acc.MZR_Tier__c = null;
                }
                parentAccs.put(acc.Id, acc);
            }
            
            /** SC-002907 commenting this code as MZR Tier is covered in below list of fields
            //SC-002202 -- When Parent Account's MZR Tier is updated then update its children's Tier equal to parent
            if( (mapAccountOld.get(acc.Id).ParentId == acc.ParentId) && (acc.ParentId == null) 
            && (mapAccountOld.get(acc.Id).MZR_Tier__c != acc.MZR_Tier__c))
            parentAccs_Tier.put(acc.Id, acc);       
            **/
            
            //SC-002863 -- When Parent Account's MZR details are updated then update its children's details equal to parent
            if( (mapAccountOld.get(acc.Id).ParentId == acc.ParentId) && (acc.ParentId == null) 
            && ( (mapAccountOld.get(acc.Id).ZTS_US_MVP_BIOS__c != acc.ZTS_US_MVP_BIOS__c) ||
            (mapAccountOld.get(acc.Id).MZR_PARAs_Tier__c != acc.MZR_PARAs_Tier__c) ||
            (mapAccountOld.get(acc.Id).MZR_PARAs_Account__c != acc.MZR_PARAs_Account__c) ||
            (mapAccountOld.get(acc.Id).ZTS_US_MVP_Account__c != acc.ZTS_US_MVP_Account__c) ||
            (mapAccountOld.get(acc.Id).MZR_Enrollment_Date__c != acc.MZR_Enrollment_Date__c) ||
            (mapAccountOld.get(acc.Id).MZR_Enrollment_Start_Date__c != acc.MZR_Enrollment_Start_Date__c) ||
            (mapAccountOld.get(acc.Id).MZR_BIOS_Enrollment_Date__c != acc.MZR_BIOS_Enrollment_Date__c) ||
            (mapAccountOld.get(acc.Id).MZR_PARAs_Enrollment_Date__c != acc.MZR_PARAs_Enrollment_Date__c)  ||             
            (mapAccountOld.get(acc.Id).MZR_Status__c != acc.MZR_Status__c) ||
            (mapAccountOld.get(acc.Id).MZR_Accepted_Declined_Date__c != acc.MZR_Accepted_Declined_Date__c) ||  
            (mapAccountOld.get(acc.Id).MZR_Account__c != acc.MZR_Account__c) || 
            (mapAccountOld.get(acc.Id).MZR_Account_data_change__c != acc.MZR_Account_data_change__c) || 
            (mapAccountOld.get(acc.Id).MZR_BIOS_Accepted_T_C_Date__c != acc.MZR_BIOS_Accepted_T_C_Date__c) || 
            (mapAccountOld.get(acc.Id).MZR_Decline_Additional_Notes__c != acc.MZR_Decline_Additional_Notes__c) || 
            (mapAccountOld.get(acc.Id).MZR_Derm_Rebate__c != acc.MZR_Derm_Rebate__c) || 
            (mapAccountOld.get(acc.Id).MZR_End_Date__c != acc.MZR_End_Date__c) || 
            (mapAccountOld.get(acc.Id).MZR_Enrollment_Experience__c != acc.MZR_Enrollment_Experience__c) || 
            (mapAccountOld.get(acc.Id).MZR_PARAs_Accepted_T_C_Date__c != acc.MZR_PARAs_Accepted_T_C_Date__c) || 
            (mapAccountOld.get(acc.Id).MZR_Reason_for_Not_Enrolling__c != acc.MZR_Reason_for_Not_Enrolling__c) || 
            (mapAccountOld.get(acc.Id).MZR_Tier__c != acc.MZR_Tier__c) || 
            (mapAccountOld.get(acc.Id).MZR_Feedback__c != acc.MZR_Feedback__c) || 
            (mapAccountOld.get(acc.Id).MZR_Tier__c != acc.MZR_Tier__c)
            )
            )
            parentAccs.put(acc.Id, acc);
        }
        
        if(ZTS_US_checkTriggerRun.runOnce() || Test.isRunningTest())
        {
            System.debug('%%% ....INSIDE ACCOUNT TRIGGER HANDLER.....');
            if(!updMap.isEmpty())
            ZTS_US_addrCreationAndUpdateFromAccount.updatenullvaluesonchildaccounts(updMap);
            
            Map<Id, Account> childAcctsMapToUpdate = new Map<Id, Account>();
            if(!parentAccs.isEmpty())
            {
                for(Account acc: [Select Id,ParentId,MZR_Status__c,MZR_Tier__C,ZTS_US_MVP_Account__c,ZTS_US_MVP_BIOS__c,MZR_PARAs_Account__c,MZR_PARAs_Tier__c,
                MZR_Enrollment_Date__c,MZR_Enrollment_Start_Date__c,MZR_BIOS_Enrollment_Date__c,MZR_PARAs_Enrollment_Date__c,
                MZR_Accepted_Declined_Date__c,MZR_Account__c,MZR_Account_data_change__c,MZR_BIOS_Accepted_T_C_Date__c,
                MZR_Decline_Additional_Notes__c,MZR_End_Date__c,MZR_Enrollment_Experience__c,MZR_PARAs_Accepted_T_C_Date__c,
                MZR_Reason_for_Not_Enrolling__c,MZR_Feedback__c
                FROM Account Where ParentId in :parentAccs.keySet() 
                AND ZTS_EU_Market__c = 'United States'])
                {
                    /** SC-002907 commenting below code as we need to copy MZR Tier from parent always when changed 
                    Account parent = parentAccs.get(acc.ParentId);
                    String st = parentAccs.get(acc.ParentId).MZR_Status__c;
                    
                    if(String.isNotBlank(st) && st == 'Active')
                    acc.MZR_Tier__c = parentAccs.get(acc.ParentId).MZR_Tier__c;                        
                    else
                    acc.MZR_Tier__c = null;
                    **/
                    
                    //SC-002482, SC-002863, SC-002907 -- When Parent Account's MZR details are updated then update its children accordingly 
                    if(parentAccs.get(acc.ParentId) != null)
                    {
                        acc.MZR_Status__c = parentAccs.get(acc.ParentId).MZR_Status__c;
                        acc.ZTS_US_MVP_Account__c = parentAccs.get(acc.ParentId).ZTS_US_MVP_Account__c;                
                        acc.MZR_PARAs_Account__c = parentAccs.get(acc.ParentId).MZR_PARAs_Account__c;
                        acc.ZTS_US_MVP_BIOS__c = parentAccs.get(acc.ParentId).ZTS_US_MVP_BIOS__c;  
                        acc.MZR_PARAs_Tier__c = parentAccs.get(acc.ParentId).MZR_PARAs_Tier__c;
                        acc.MZR_Enrollment_Date__c = parentAccs.get(acc.ParentId).MZR_Enrollment_Date__c;
                        acc.MZR_Enrollment_Start_Date__c = parentAccs.get(acc.ParentId).MZR_Enrollment_Start_Date__c;
                        acc.MZR_BIOS_Enrollment_Date__c = parentAccs.get(acc.ParentId).MZR_BIOS_Enrollment_Date__c;
                        acc.MZR_PARAs_Enrollment_Date__c = parentAccs.get(acc.ParentId).MZR_PARAs_Enrollment_Date__c;
                        acc.MZR_Accepted_Declined_Date__c = parentAccs.get(acc.ParentId).MZR_Accepted_Declined_Date__c;
                        acc.MZR_Account__c = parentAccs.get(acc.ParentId).MZR_Account__c;
                        acc.MZR_Account_data_change__c = parentAccs.get(acc.ParentId).MZR_Account_data_change__c;
                        acc.MZR_BIOS_Accepted_T_C_Date__c = parentAccs.get(acc.ParentId).MZR_BIOS_Accepted_T_C_Date__c;
                        acc.MZR_Decline_Additional_Notes__c = parentAccs.get(acc.ParentId).MZR_Decline_Additional_Notes__c;
                        acc.MZR_Derm_Rebate__c = parentAccs.get(acc.ParentId).MZR_Derm_Rebate__c;
                        acc.MZR_End_Date__c = parentAccs.get(acc.ParentId).MZR_End_Date__c;
                        acc.MZR_Enrollment_Experience__c = parentAccs.get(acc.ParentId).MZR_Enrollment_Experience__c;
                        acc.MZR_PARAs_Accepted_T_C_Date__c = parentAccs.get(acc.ParentId).MZR_PARAs_Accepted_T_C_Date__c;
                        acc.MZR_Reason_for_Not_Enrolling__c = parentAccs.get(acc.ParentId).MZR_Reason_for_Not_Enrolling__c;
                        acc.MZR_Tier__c = parentAccs.get(acc.ParentId).MZR_Tier__c;
                        acc.MZR_Feedback__c = parentAccs.get(acc.ParentId).MZR_Feedback__c;
                        acc.MZR_Status__c = parentAccs.get(acc.ParentId).MZR_Status__c;
                        
                        /** SC-002907 copy MZR Bios Tier from parent to child when changed
                        if(acc.ZTS_US_MVP_Account__c)
                        acc.ZTS_US_MVP_BIOS__c = parentAccs.get(acc.ParentId).ZTS_US_MVP_BIOS__c;
                        else
                        acc.ZTS_US_MVP_BIOS__c = null;
                        ***/
                    }
                    childAcctsMapToUpdate.put(acc.Id, acc);
                } 
            }    
            
            /***
            //SC-002202 -- When Parent Account's MZR Tier is updated then update its children's MZR Tier equals to Parent
            if(!parentAccs_Tier.isEmpty())
            {
                for(Account acc: [Select Id,ParentId,MZR_Status__c,MZR_Tier__C from Account Where ParentId in :parentAccs_Tier.keySet() AND ZTS_EU_Market__c = 'United States' ]) 
                {
                    if(childAcctsMapToUpdate.get(acc.Id) != null)
                    childAcctsMapToUpdate.get(acc.Id).MZR_Tier__c = parentAccs_Tier.get(acc.ParentId).MZR_Tier__c;
                    else 
                    {
                        acc.MZR_Tier__c = parentAccs_Tier.get(acc.ParentId).MZR_Tier__c;
                        childAcctsMapToUpdate.put(acc.Id, acc);
                    }                       
                } 
            }  **/
            if(!childAcctsMapToUpdate.isEmpty()){
                try{
                    update childAcctsMapToUpdate.values();    
                }
                catch(DmlException dex){
                    String errorMessages = '';
                    for (Integer i = 0; i < dex.getNumDml(); i++) {
                        System.debug(BEFORE_UPDATE_ORIGIN_TYPE);
                        System.debug('%%% DML Message: ' + dex.getDmlMessage(i));
                        errorMessages += dex.getDmlMessage(i) + '\n';
                    }
                    errorMessages.removeEnd('\n');
                    ZTS_EU_Logger.notify = true;
                    ZTS_EU_Logger.error(errorMessages,null, BEFORE_UPDATE_ORIGIN_TYPE);
                }
                
            }
        }
    }
    
    /***********
    * Method name  : onBeforeDelete
    * Description  : This will delete ZTS_Animal_Count_Potential__c records.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public void onBeforeDelete(List<Account> lstAccountOld)
    {
        list<ZTS_Animal_Count_Potential__c> animalCountList= new list<ZTS_Animal_Count_Potential__c> ();
        Map<Id, List<ZTS_Animal_Count_Potential__c>> mapIdToAnimalCountPotentials = new Map<Id, List<ZTS_Animal_Count_Potential__c>>{};
        
        for(ZTS_Animal_Count_Potential__c objACP : [SELECT Id,RecordTypeId, ZTS_EU_Account__c 
                                                    FROM ZTS_Animal_Count_Potential__c 
                                                    WHERE ZTS_EU_Account__c IN: lstAccountOld
        AND ZTS_EU_Market_from_Parent__c = 'United States' ]){
            if(!mapIdToAnimalCountPotentials.containsKey(objACP.ZTS_EU_Account__c))
            mapIdToAnimalCountPotentials.put(objACP.ZTS_EU_Account__c, new List<ZTS_Animal_Count_Potential__c>());
            mapIdToAnimalCountPotentials.get(objACP.ZTS_EU_Account__c).add(objACP);
            
        }
        
        for (Account acc: lstAccountOld){
            /********* START - Modified by: Poonam to avoid the SOQL inside the For Loop.*************/
            /*list<ZTS_Animal_Count_Potential__c> acfList = [SELECT Id,RecordTypeId FROM ZTS_Animal_Count_Potential__c 
            WHERE ZTS_EU_Account__c =: acc.Id
            AND ZTS_EU_Market_from_Parent__c = 'United States'];  
            if(!acfList.isEmpty())
            {
                USStaticACFVars.mapOldACFLoser.put(acc.Id, acfList);
                animalCountList.addAll(acfList);
            }*/
            /*********END - Modified by: Poonam to avoid the SOQL inside the For Loop.*************/
            if(mapIdToAnimalCountPotentials.containsKey(acc.Id) && mapIdToAnimalCountPotentials.get(acc.Id) != null)
            {
                USStaticACFVars.mapOldACFLoser.put(acc.Id, mapIdToAnimalCountPotentials.get(acc.Id));
                animalCountList.addAll(mapIdToAnimalCountPotentials.get(acc.Id));
            }
        }
        
        if(!animalCountList.isEmpty()) Database.delete(animalCountList, false); 
        
        // SC-002910 - To Avoid the duplicate Account Territory (Added By Keerthi Chandra)
        Map<Id, List<ZTS_AccountTerritory__c>> mapAT = new Map<Id, List<ZTS_AccountTerritory__c>>{};
        for(ZTS_AccountTerritory__c objACP : [SELECT Id,ZTS_EU_Territory__c, ZTS_EU_Account__c 
                                                FROM ZTS_AccountTerritory__c 
                                                WHERE ZTS_EU_Account__c IN: lstAccountOld])
        {
            if(!mapAT.containsKey(objACP.ZTS_EU_Account__c)) mapAT.put(objACP.ZTS_EU_Account__c, new List<ZTS_AccountTerritory__c>());
            mapAT.get(objACP.ZTS_EU_Account__c).add(objACP);
        }
        for (Account acc: lstAccountOld){
            if(mapAT.containsKey(acc.Id) && mapAT.get(acc.Id) != null){ 
                USStaticACFVars.mapOldATLoser.put(acc.Id, mapAT.get(acc.Id));
            }
        }
        
        // SC-002910 - To Avoid the duplicate Account Team (Added By Keerthi Chandra)  
        Map<Id, List<ZTS_EU_Account_Position__c>> mapAP = new Map<Id, List<ZTS_EU_Account_Position__c>>{};
        for(ZTS_EU_Account_Position__c objACP : [SELECT Id,ZTS_EU_Position__c, ZTS_EU_Account__c,ZTS_AccountTerritory__c 
                                                    FROM ZTS_EU_Account_Position__c 
                                                    WHERE ZTS_EU_Account__c IN: lstAccountOld
                                                    AND ZTS_EU_Market__c = 'United States']){
            if(!mapAP.containsKey(objACP.ZTS_EU_Account__c)) mapAP.put(objACP.ZTS_EU_Account__c, new List<ZTS_EU_Account_Position__c>());
            mapAP.get(objACP.ZTS_EU_Account__c).add(objACP);
        }
        for (Account acc: lstAccountOld){
            if(mapAP.containsKey(acc.Id) && mapAP.get(acc.Id) != null){   
                USStaticACFVars.mapOldAPLoser.put(acc.Id, mapAP.get(acc.Id));
            }
        }
        
    }
    
    /***********
    * Method name  : onAfterDelete
    * Description  : This will undelete ZTS_Animal_Count_Potential__c records.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public void onAfterDelete(List<Account> lstAccountOld)
    {
        List<ZTS_Animal_Count_Potential__c> undACFAll = new List<ZTS_Animal_Count_Potential__c> ();
        //List<ZTS_Animal_Count_Potential__c> undACF = new List<ZTS_Animal_Count_Potential__c> ();
        
        /**********
        * Modifed By: Poonam
        * Description: Optimized code to avoid For inside For and SOQL within FOR....
        ***********/
        
        Map<Id, List<ZTS_Animal_Count_Potential__c>> mapACPIdToAnimalCountPotentials = new Map<Id, List<ZTS_Animal_Count_Potential__c>>();
        
        for(Account acct : lstAccountOld) 
        {
            if(String.isNotBlank(acct.MasterRecordId) && USStaticACFVars.mapOldACFLoser.containsKey(acct.Id)) 
            mapACPIdToAnimalCountPotentials.put(acct.MasterRecordId, new List<ZTS_Animal_Count_Potential__c>());
        }
        
        for(ZTS_Animal_Count_Potential__c objACP : [SELECT Id,RecordTypeId, ZTS_EU_Account__c FROM ZTS_Animal_Count_Potential__c 
        WHERE ZTS_EU_Account__c IN: mapACPIdToAnimalCountPotentials.keySet() 
        AND ZTS_EU_Market_from_Parent__c = 'United States'])
        {
            mapACPIdToAnimalCountPotentials.get(objACP.ZTS_EU_Account__c).add(objACP);
        }
        
        for(Account acct : lstAccountOld) 
        {  
            if(String.isNotBlank(acct.MasterRecordId) && USStaticACFVars.mapOldACFLoser.containsKey(acct.Id)) 
            { // Means the account is deleted due to merge
                //existing species of Winner Record are inserted into this set
                Set <Id> setWinnerACFspecies = new Set <Id>();
                if(mapACPIdToAnimalCountPotentials.containsKey(acct.MasterRecordId)) 
                {
                    //if winner account has existing ACFs present then only non-duplicate ACF records from loser are moved
                    for (ZTS_Animal_Count_Potential__c acf1: mapACPIdToAnimalCountPotentials.get(acct.MasterRecordId))
                    setWinnerACFspecies.add(acf1.RecordTypeId);
                    
                    //Now get the Loser Account ACF List
                    List <ZTS_Animal_Count_Potential__c> listCheck = USStaticACFVars.mapOldACFLoser.get(acct.Id);
                    //Loop through the Loser Account ACF List
                    for (ZTS_Animal_Count_Potential__c acp: listCheck)
                    {
                        if(!setWinnerACFspecies.contains(acp.RecordTypeId)) // if the Loser ACF Species does not exist in Winner
                        undACFAll.add(acp);
                    }
                }
                else
                {
                    //if winner account doesn't have ACFs present,then copy all ACF from loser account
                    undACFAll.addAll(USStaticACFVars.mapOldACFLoser.get(acct.Id));
                }
            }  
        }      
        undelete undACFAll;
        
        /**********END Optmized Code ***********/
        
        // SC-002910 - To Avoid the duplicate Account Territory (Added By Keerthi Chandra)
        try{
            List<ZTS_AccountTerritory__c> lstATM = new List<ZTS_AccountTerritory__c> (); 
            List<ZTS_AccountTerritory__c> lstATMOrdr = new List<ZTS_AccountTerritory__c> ();
            List<ZTS_AccountTerritory__c> lstATF = new List<ZTS_AccountTerritory__c> ();
            List<ZTS_AccountTerritory__c> lstATFnl = new List<ZTS_AccountTerritory__c> ();
            List<ZTS_AccountTerritory__c> lstATIntl = new List<ZTS_AccountTerritory__c> ();
            Map<Id,List<ZTS_AccountTerritory__c>> mapATl = new Map<Id,List<ZTS_AccountTerritory__c>>();
            Map<string,List<ZTS_AccountTerritory__c>> mapATF = new Map<string,List<ZTS_AccountTerritory__c>>();
            set<Id> setAccId = new set<Id>();
            set<Id> setATIdOrdr = new set<Id>();
            for(Account acct : lstAccountOld) {
                if(String.isNotBlank(acct.MasterRecordId) && USStaticACFVars.mapOldATLoser.containsKey(acct.Id)) setAccId.add(acct.MasterRecordId);
            }   
            lstATIntl = [SELECT Id,ZTS_EU_Territory__c,Createddate,ZTS_EU_Account__r.Name,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Account__c IN: setAccId ORDER BY ZTS_EU_Account__r.Name];
            for(ZTS_AccountTerritory__c at : lstATIntl) {setATIdOrdr.add(at.Id);} 
            
            lstATM = [SELECT Id,ZTS_EU_Territory__c,ZTS_EU_Territory__r.Name,Createddate,ZTS_EU_Account__r.Name,ZTS_EU_Account__c FROM ZTS_AccountTerritory__c WHERE ZTS_EU_Account__c IN: setATIdOrdr ORDER BY ZTS_EU_Territory__r.Name , Createddate ASC];                                                        
            for(ZTS_AccountTerritory__c at: lstATM){
                mapATl.put(at.ZTS_EU_Account__c, new List<ZTS_AccountTerritory__c>());
                mapATF.put(at.ZTS_EU_Territory__c, new List<ZTS_AccountTerritory__c>());
            }
            for(ZTS_AccountTerritory__c at: lstATM){
                mapATl.get(at.ZTS_EU_Account__c).add(at);
                mapATF.get(at.ZTS_EU_Territory__c).add(at);
            } 
            for(Account acct : lstAccountOld) {
                if(mapATl.containsKey(acct.MasterRecordId)){
                    for(ZTS_AccountTerritory__c a: mapATl.get(acct.MasterRecordId)){
                        if(mapATF.containsKey(a.ZTS_EU_Territory__c)){
                            for(ZTS_AccountTerritory__c ats: mapATF.get(a.ZTS_EU_Territory__c)){
                                lstATF.add(ats); break;
                            }   
                        }               
                    }               
                }
            }    
            for(ZTS_AccountTerritory__c a:lstATM){
                if(!lstATF.contains(a)){lstATFnl.add(a);}
            }
            Database.delete(lstATFnl,false);
        }
        catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(AFTER_DELETE_ACC_TERR_ORIGIN_TYPE);
                System.debug('%%% DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, AFTER_DELETE_ACC_TERR_ORIGIN_TYPE);
        }
        // SC-002910 - To Avoid the duplicate Account Team (Added By Keerthi Chandra)
        try{
            List<ZTS_EU_Account_Position__c> lstAPM = new List<ZTS_EU_Account_Position__c> (); 
            List<ZTS_EU_Account_Position__c> lstAPF = new List<ZTS_EU_Account_Position__c> ();
            List<ZTS_EU_Account_Position__c> lstAPFnl = new List<ZTS_EU_Account_Position__c> ();
            List<ZTS_EU_Account_Position__c> lstAPIntl = new List<ZTS_EU_Account_Position__c> ();
            Map<Id,List<ZTS_EU_Account_Position__c>> mapAPl = new Map<Id,List<ZTS_EU_Account_Position__c>>();
            Map<string,List<ZTS_EU_Account_Position__c>> mapAPF = new Map<string,List<ZTS_EU_Account_Position__c>>();
            set<Id> setAcc = new set<Id>();
            set<Id> setAPOrdr = new set<Id>();
            for(Account acct : lstAccountOld) {
                if(String.isNotBlank(acct.MasterRecordId) && USStaticACFVars.mapOldAPLoser.containsKey(acct.Id)) 
                setAcc.add(acct.MasterRecordId);
            }   
            lstAPIntl = [SELECT Id,ZTS_EU_Position__c,Createddate,ZTS_EU_Account__r.Name,ZTS_EU_Account__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Account__c IN: setAcc AND ZTS_EU_Market__c = 'United States' ORDER By ZTS_EU_Account__r.Name ];
            for(ZTS_EU_Account_Position__c ap : lstAPIntl) {setAPOrdr.add(ap.Id);}
            lstAPM = [SELECT Id,ZTS_EU_Position__c,ZTS_EU_Position__r.Name,Createddate,ZTS_EU_Account__r.Name,ZTS_EU_Account__c FROM ZTS_EU_Account_Position__c WHERE ID IN: setAPOrdr AND ZTS_EU_Market__c = 'United States' ORDER By ZTS_EU_Position__r.Name, CreatedDate ASC];
            
            for(ZTS_EU_Account_Position__c ap: lstAPM){
                mapAPl.put(ap.ZTS_EU_Account__c, new List<ZTS_EU_Account_Position__c>());
                mapAPF.put(ap.ZTS_EU_Position__c, new List<ZTS_EU_Account_Position__c>());
            }
            for(ZTS_EU_Account_Position__c ap: lstAPM){
                mapAPl.get(ap.ZTS_EU_Account__c).add(ap);
                mapAPF.get(ap.ZTS_EU_Position__c).add(ap);
            }       
            for(Account acct : lstAccountOld) {
                if(mapAPl.containsKey(acct.MasterRecordId)){
                    for(ZTS_EU_Account_Position__c a: mapAPl.get(acct.MasterRecordId)){
                        if(mapAPF.containsKey(a.ZTS_EU_Position__c)){
                            for(ZTS_EU_Account_Position__c aps: mapAPF.get(a.ZTS_EU_Position__c)){lstAPF.add(aps); break;}   
                        }               
                    }               
                }
            }    
            for(ZTS_EU_Account_Position__c a:lstAPM){
                if(!lstAPF.contains(a)){ lstAPFnl.add(a);}
            }
            Database.delete(lstAPFnl,false); 
        }
        catch(DmlException dex){
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(AFTER_DELETE_ACC_POS_ORIGIN_TYPE);
                System.debug('%%% DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, AFTER_DELETE_ACC_POS_ORIGIN_TYPE);
        }
        
        //  TPDEV-1005 Update the account contact affliation name on accountMerge 
      	AffiliationsService.updateAffliationNameOnMerge(lstAccountOld);
        
        /*for(Account acct : lstAccountOld) 
        {  
            if(String.isNotBlank(acct.MasterRecordId) && USStaticACFVars.mapOldACFLoser.containsKey(acct.Id)) 
            { // Means the account is deleted due to merge
                //existing species of Winner Record are inserted into this set
                Set <Id> setWinnerACFspecies = new Set <Id>();
                List <ZTS_Animal_Count_Potential__c> lstWinnerACFspecies = new List <ZTS_Animal_Count_Potential__c>([SELECT Id,RecordTypeId FROM ZTS_Animal_Count_Potential__c WHERE ZTS_EU_Account__c =: acct.MasterRecordId AND ZTS_EU_Market_from_Parent__c = 'United States']);
                
                if(!lstWinnerACFspecies.isEmpty()) 
                {
                    //if winner account has existing ACFs present then only non-duplicate ACF records from loser are moved
                    for (ZTS_Animal_Count_Potential__c acf1: lstWinnerACFspecies)
                    setWinnerACFspecies.add(acf1.RecordTypeId);
                    
                    //Now get the Loser Account ACF List
                    List <ZTS_Animal_Count_Potential__c> listCheck = USStaticACFVars.mapOldACFLoser.get(acct.Id);
                    //Loop through the Loser Account ACF List
                    for (ZTS_Animal_Count_Potential__c acp: listCheck)
                    {
                        if(!setWinnerACFspecies.contains(acp.RecordTypeId)) // if the Loser ACF Species does not exist in Winner
                        {
                            undACF = [Select Id,RecordTypeId FROM ZTS_Animal_Count_Potential__c where Id =: acp.Id ALL ROWS AND ZTS_EU_Market_from_Parent__c = 'United States'];
                            undACFAll.addAll(undACF);
                        }
                    }
                }
                else
                {
                    //if winner account doesn't have ACFs present,then copy all ACF from loser account
                    undACF = USStaticACFVars.mapOldACFLoser.get(acct.Id);
                    undACFAll.addAll(undACF);
                }
                // }
            }  
        }      
        if(!undACFAll.isEmpty())
        undelete undACFAll;*/ 
    }
    
    /***********
    * Method name  : onAfterUpdate
    * Description  : This will delete inactive Account records.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public void onAfterUpdate(List<Account> lstAccountNew, Map<Id, Account> mapAccountOld, Map<Id, Account> mapAccountNew)
    {
        Map<Id,Account> accmapparent = new Map<Id,Account>();
        Map<Id,Account> accmapVGP = new Map<Id,Account>();
        Map<Id,Account> accmapMVP = new Map<Id,Account>();
        List<Account> accmapchild = new List<Account>();
        list<Account> childacclist = new list<Account>(); //sai
        List<Account> accountList = New List<Account>();
        System.debug('%%% lstAccountNew  :::'+ lstAccountNew);
        for(Account acc:lstAccountNew)
        {
            System.debug('%%% mapAccountOld.get(acc.id).MZR_Status__c  :::'+ mapAccountOld.get(acc.id).MZR_Status__c);
            if((mapAccountOld.get(acc.id).MZR_Status__c!=acc.MZR_Status__c && (acc.MZR_Status__c=='Active' || acc.MZR_Status__c=='Un-enrolled in MZR'))
            ||(mapAccountOld.get(acc.id).ZTS_US_VGP_Enrollment_Status__c!=acc.ZTS_US_VGP_Enrollment_Status__c && (acc.ZTS_US_VGP_Enrollment_Status__c=='VGP Enrolled'||acc.ZTS_US_VGP_Enrollment_Status__c=='Un-enrolled in VGP'))
            ||(mapAccountOld.get(acc.id).ZTS_US_MVP_Account__c!=acc.ZTS_US_MVP_Account__c))
            accmapparent.put(acc.id,acc);
            
            if(acc.ParentId!=null)
            accmapchild.add(acc);
            
            //SC-002486 - sai
            if((mapAccountOld.get(acc.id).ParentId!=acc.ParentId) && (acc.ParentId!=null))
            childacclist.add(acc);
        }
        System.debug('%%% accmapparent  :::'+accmapparent);
        System.debug('%%% childacclist  :::'+childacclist);
        System.debug('%%% childacclist.isEmpty() ::: '+childacclist.isEmpty());
        if(!accmapparent.isEmpty()&& (ZTS_US_checkTriggerRun.runOnce() || Test.isRunningTest()))
        	ZTS_US_addrCreationAndUpdateFromAccount.updatecontractdetailschildaccounts(accmapparent);
        
        if(!accmapchild.isEmpty() && (ZTS_US_checkTriggerRun.runOnce()))
        ZTS_US_addrCreationAndUpdateFromAccount.updateAccountContractDetails(accmapchild);
        
        if(!childacclist.isEmpty())
        ZTS_US_addrCreationAndUpdateFromAccount.updatecontractparentvaluesonchildaccounts(childacclist);
        
        
        accountList = AccountsService.getAccountsWithEmailChanges(mapAccountNew, mapAccountOld);
        if(!accountList.isEmpty()){
            ContactsService.updateContactwithAccountEmail(accountList);
        }
        /* EOD by SOHIL For DEF-001643 */
        
        List<Id> inActiveAccIdList=new List<Id>();
        
        //remove access to Inactive Accounts
        for(Account acc:lstAccountNew)
        {
            if(mapAccountOld.get(acc.id).ZTS_EU_Account_Status__c!=acc.ZTS_EU_Account_Status__c && acc.ZTS_EU_Account_Status__c==ZTS_GlobalConstants.INACTIVE_STATUS)
            inActiveAccIdList.add(acc.id);
        }
        
        if(!inActiveAccIdList.isEmpty())
        ZTS_TerritoryManager.deleteAccountTerritoryShares(inActiveAccIdList);
        // update Address record on updation of Account.
        ZTS_US_addrCreationAndUpdateFromAccount.updateAddressRecord(lstAccountNew,mapAccountOld);        
        // update Account Contact Affiliation to inactive if Account is inactive.
        //update contact address with changed Billing Address in account.
        ZTS_US_addrCreationAndUpdateFromAccount.updateAccContactsAddress(mapAccountOld, mapAccountNew);  
        
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<Contract> contractsToUpdate = new List<Contract>();
        for(Account acc: lstAccountNew){
            if(acc.ZTS_US_NARC_ID__c != null && mapAccountOld != null && mapAccountOld.get(acc.id) != null && mapAccountOld.get(acc.id).Zts_US_NARC_ID__c == null){
                accMap.put(acc.Id, acc);
            }
        }    
        if(accMap.size() > 0){
            for(Contract c : [Select Id,AccountId,Contract_Type__c,Status,Name from Contract where AccountId in :accMap.keyset() AND Contract_Type__c='Proposal' 
            AND Name LIKE '% LE %' AND ZTS_EU_Market__c = 'United States' ] ){
                c.Send_Email_to_LE_Owner__c = true;
                contractsToUpdate.add(c);
            }
        }
        if(contractsToUpdate.size() > 0){
            update contractsToUpdate;
        }
        
        // TPDEV-1005 Update the account contact affliation name on account update
      	AffiliationsService.updateAffliliationName(lstAccountNew);
        
    }//end of after update method
}//end of class