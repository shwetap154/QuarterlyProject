/*************************************************************************************
* Name          :    ZTS_EU_HQRating_Update
* Description   :    This class is written to update HQ Rating fields on Child Accounts
                     with top most accounts HQ Rating values in the heirarchy. This class
                     will overwrite the HQ Rating section field values with parent HQ Rating
                     field values
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
 07/02/2014       Chandra            Created

**************************************************************************************/
public class ZTS_EU_HQRating_Update {
    /***********
        * Method name  : HQRating_Update
        * Description  : This method will update all the Accounts HQ Rating field sections with grand parents HQ Rating field value
        * Return Type  : None
        * Parameters   : Set of Accounts on which the HQ Rating fields are changed
    ***********/
    public static set<Id> AccIdsUpdated= new Set<Id>();
    
    public static void HQRating_Update(Map<Id,Account> newMap,Map<id,account> oldMap) {
        Set<Id> parentAccs = new Set<Id>();
        for(Account acc : newMap.values()){
            if(!AccIdsUpdated.contains(acc.ZTS_EU_Parent_Id__c)){
                if(acc.ZTS_EU_CA_HQ_Penetration_Rating__c != oldMap.get(acc.id).ZTS_EU_CA_HQ_Penetration_Rating__c || 
                    acc.ZTS_EU_RAT_CA_HQ__c != oldMap.get(acc.id).ZTS_EU_RAT_CA_HQ__c || 
                    acc.ZTS_EU_EQ_HQ_Penetration_Rating__c != oldMap.get(acc.id).ZTS_EU_EQ_HQ_Penetration_Rating__c || 
                    acc.ZTS_EU_RAT_EQ_HQ__c != oldMap.get(acc.id).ZTS_EU_RAT_EQ_HQ__c || 
                    acc.ZTS_EU_PY_HQ_Penetration_Rating__c != oldMap.get(acc.id).ZTS_EU_PY_HQ_Penetration_Rating__c || 
                    acc.ZTS_EU_RAT_PY_HQ__c != oldMap.get(acc.id).ZTS_EU_RAT_PY_HQ__c || 
                    acc.ZTS_EU_RU_HQ_Penetration_Rating__c != oldMap.get(acc.id).ZTS_EU_RU_HQ_Penetration_Rating__c || 
                    acc.ZTS_EU_RAT_RU_HQ__c != oldMap.get(acc.id).ZTS_EU_RAT_RU_HQ__c || 
                    acc.ZTS_EU_SW_HQ_Penetration_Rating__c != oldMap.get(acc.id).ZTS_EU_SW_HQ_Penetration_Rating__c || 
                    acc.ZTS_EU_RAT_SW_HQ__c != oldMap.get(acc.id).ZTS_EU_RAT_SW_HQ__c || 
                    acc.ZTS_EU_RAT_VPS_HQ__c != oldMap.get(acc.id).ZTS_EU_RAT_VPS_HQ__c){
                        parentAccs.add(acc.ZTS_EU_Parent_Id__c);
                }
            }
        }
        
        if(parentAccs.size()>0){
            Map<Id,Account> mpParentAccs = new Map<id,account>([SELECT id,ZTS_EU_Parent_Id__c,ZTS_EU_CA_HQ_Penetration_Rating__c,ZTS_EU_RAT_CA_HQ__c,
                                                                   ZTS_EU_EQ_HQ_Penetration_Rating__c, ZTS_EU_RAT_EQ_HQ__c, ZTS_EU_PY_HQ_Penetration_Rating__c,
                                                                   ZTS_EU_RAT_PY_HQ__c, ZTS_EU_RU_HQ_Penetration_Rating__c, ZTS_EU_RAT_RU_HQ__c, 
                                                                   ZTS_EU_SW_HQ_Penetration_Rating__c, ZTS_EU_RAT_SW_HQ__c, ZTS_EU_RAT_VPS_HQ__c
                                                                   FROM Account 
                                                                   WHERE (id in: parentAccs OR ZTS_EU_Parent_Id__c in:parentAccs) AND ZTS_EU_Market__c != 'United States']);
            List<Account> lstToUpdate = new List<Account>();
            for(Account accs :mpParentAccs.values()){
                Account accObj = new Account(Id=accs.Id);  
                accObj.ZTS_EU_CA_HQ_Penetration_Rating__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_CA_HQ_Penetration_Rating__c;
                accObj.ZTS_EU_RAT_CA_HQ__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RAT_CA_HQ__c;
                accObj.ZTS_EU_EQ_HQ_Penetration_Rating__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_EQ_HQ_Penetration_Rating__c;
                accObj.ZTS_EU_RAT_EQ_HQ__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RAT_EQ_HQ__c;
                accObj.ZTS_EU_PY_HQ_Penetration_Rating__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_PY_HQ_Penetration_Rating__c;
                accObj.ZTS_EU_RAT_PY_HQ__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RAT_PY_HQ__c;
                accObj.ZTS_EU_RU_HQ_Penetration_Rating__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RU_HQ_Penetration_Rating__c;
                accObj.ZTS_EU_RAT_RU_HQ__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RAT_RU_HQ__c;
                accObj.ZTS_EU_SW_HQ_Penetration_Rating__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_SW_HQ_Penetration_Rating__c;
                accObj.ZTS_EU_RAT_SW_HQ__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RAT_SW_HQ__c;
                accObj.ZTS_EU_RAT_VPS_HQ__c = mpParentAccs.get(accs.ZTS_EU_Parent_Id__c).ZTS_EU_RAT_VPS_HQ__c;
                AccIdsUpdated.add(accObj.Id);
                lstToUpdate.add(accObj);
            }
            
            if(lstToUpdate.size()>0){
                //Bypass the Account Trigger when updating Accounts (TPDEV-84)
                DispatchTriggerHandler.bypass('AccountTriggerHandler');
                update lstToUpdate;
                DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            }
        }
    }
}