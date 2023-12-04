/****************************************************************************************************************************************** 
 * Class Name : INTLZTS_EU_Account_AffiliaTriggerService
 * Description  : Trigger on ZTS_EU_Account_Affiliations.
 *              	
 * @date Created:Jan 29, 2014
 * @author:      Ninad
 *                                                         
 * Modification Log    : 
 * ---------------------------------------------------------------------------------------------------------------------
 * Developer                             Date                   Description
 * ---------                             ----                   -----------
 * Ninad     				            01//29/2014             Created   
 * @bimba:								05/12/2014: 			Added check to bypass trigger
 * Art Smorodin			  				02/13/2020	      		Moved to Service Class
*****************************************************************************************************************************************/
public class INTLZTS_EU_Account_AffiliaTriggerService {
    
    public static List<Market_Setting__mdt> marketList = [ SELECT Id, Market__c, Exclude_Buying_Group_Account_Affiliation__c  FROM Market_Setting__mdt WHERE Exclude_Buying_Group_Account_Affiliation__c = true ];
    public static Map<String, Boolean> excludeBuyingGroupMarketsMap = new Map<String, Boolean>(); //map to hold market names and checkbox values
    
    static {
        for (Market_Setting__mdt marketSetting : marketList) {
                excludeBuyingGroupMarketsMap.put(marketSetting.Market__c, marketSetting.Exclude_Buying_Group_Account_Affiliation__c);
            }
    }
    
    public static void beforeUpdate(List<ZTS_EU_Account_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Account_Affiliations__c> triggerOldMap, List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){
		//Bimba 05/12/2014: Fetch logged in user Id and check if trigger has to be bypassed.
        ZTS_EU_BUG_AccountAffiliation.beforeupdateAffiliates(triggerNew);
        
    }
    
    public static void afterInsert(List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){
        //Bimba 05/12/2014: Fetch logged in user Id and check if trigger has to be bypassed.
        if(UtilityService.isAffInsertRun()){
        	UtilityService.AffInsertRun = false;
        	UtilityService.AffUpdateRun = false;
            UtilityService.reverseUpdAffRun = false;    
            List<ZTS_EU_Account_Affiliations__C> newAcctAffLst = new List<ZTS_EU_Account_Affiliations__C>();
            
            //TPDEV-1095: added filters
            List<ZTS_EU_Account_Affiliations__C> recordsToProcess = new List<ZTS_EU_Account_Affiliations__C>(); //hold records that meet criteria
            for (ZTS_EU_Account_Affiliations__c accAff: triggerNew) {
                if(!(excludeBuyingGroupMarketsMap.containsKey(accAff.ZTS_EU_Market_from_Primary_Account__c) && excludeBuyingGroupMarketsMap.get(accAff.ZTS_EU_Market_from_Primary_Account__c))) {
                    recordsToProcess.add(accAff);
                }
                   }
                   if(recordsToProcess.size()>0) {
                       newAcctAffLst = ZTS_EU_BUG_AccountAffiliation.insertAffiliates(recordsToProcess);
                   }
                   
                   System.debug('Records from BUG account affilication class'+newAcctAffLst );
             newAcctAffLst.addall(ZTS_EU_Affiliation_ReverseRecordCreation.insertRecord(triggerNew));
            System.debug('Records frm reverse record creating class' + ZTS_EU_Affiliation_ReverseRecordCreation.insertRecord(triggerNew));
            //condition added by SC-010047  
            if(!system.isBatch() && newAcctAffLst.size() > 0){
            AffiliationReverseRecordCreationBatch affiliationBatch = new AffiliationReverseRecordCreationBatch(newAcctAffLst);    
            Database.executeBatch(affiliationBatch);
            }
        }
            
            
    }
    
    public static void afterDelete(List<ZTS_EU_Account_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Account_Affiliations__c> triggerOldMap){}
    
    public static void afterUpdate(List<ZTS_EU_Account_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Account_Affiliations__c> triggerOldMap, List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){
        //Bimba 05/12/2014: Fetch logged in user Id and check if trigger has to be bypassed.
        if(UtilityService.isAffUpdateRun()){
            UtilityService.AffUpdateRun = false;        
            ZTS_EU_BUG_AccountAffiliation.updateAffiliates(triggerNew, triggerOldMap);
        }   
        if(UtilityService.isrevupdAffRun()){         
        	UtilityService.reverseUpdAffRun = false;
        	ZTS_EU_Affiliation_ReverseRecordCreation forUpdate = new ZTS_EU_Affiliation_ReverseRecordCreation();
        	forUpdate.updateAccountRecord(triggerNew, triggerOld,triggerNewMap,triggerOldMap);
        } 
        
    }
    
    public static void afterUndelete(List<ZTS_EU_Account_Affiliations__c> triggerNew, Map<Id, ZTS_EU_Account_Affiliations__c> triggerNewMap){}
    
    public static void beforeDelete(List<ZTS_EU_Account_Affiliations__c> triggerOld, Map<Id, ZTS_EU_Account_Affiliations__c> triggerOldMap){
        //Art Smorodin Slalom February 15th,2020
        //Logic below loops through Affiliation records to be deleteed and populates a Set
        //but that Set is never used, so it is redundant logic that consumes logic and tprocessing time.
        //TODO: confirm that this can be deleted.  
        if(UtilityService.AffDeleteRun){
            UtilityService.AffDeleteRun = false;
            //TPDEV-1095: added filters
            List<ZTS_EU_Account_Affiliations__C> recordsToProcess = new List<ZTS_EU_Account_Affiliations__C>(); //hold records that meet criteria
            for (ZTS_EU_Account_Affiliations__c accAff: triggerOld) {
                if(!(excludeBuyingGroupMarketsMap.containsKey(accAff.ZTS_EU_Market_from_Primary_Account__c) && excludeBuyingGroupMarketsMap.get(accAff.ZTS_EU_Market_from_Primary_Account__c))) {
                    recordsToProcess.add(accAff);
                }
            }
            if(recordsToProcess.size()>0) {
                ZTS_EU_BUG_AccountAffiliation.deleteBUGAffRecords(recordsToProcess);
            }
        }
        
        /*Set<String> setAccAff = new Set<String>();
        for(ZTS_EU_Account_Affiliations__c accAff : triggerOld){
          setAccAff.add(accAff.ZTS_EU_Account_Affiliation_Id__c);
      	}*/

    }

}