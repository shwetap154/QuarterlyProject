/****************************************************************************************************************************************** 
* Class Name   : INTLAccountPotentialProductService
* Description  : Logic for all ZTS_EU_Account_Product_Potential__c triggers housed here.
* Created By   : Slalom/Allister McKenzie 
* Created Date : 24 November 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                     Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Allister McKenzie(Slalom)     11/24/2020         Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public inherited sharing class INTLAccountPotentialProductService {

    public static void beforeInsert(List<ZTS_EU_Account_Product_Potential__c> triggerNew) {
        set<id> ascIds = new set<id>();
        for(ZTS_EU_Account_Product_Potential__c app : triggerNew){
            if(app.Account_Species_Consultation__c != null){
                ascIds.add(app.Account_Species_Consultation__c);
            }
        }
        
        AccountProductPotentialHelper.calculateAndSumAccountProductPotential(triggerNew,ascIds);
        
        /*****/
        if(!ascIds.isEmpty()){
            map<id,ZTS_EU_Account_Species_Potential__c> ascMp = new map<id,ZTS_EU_Account_Species_Potential__c>([select id, account__c from ZTS_EU_Account_Species_Potential__c where id in:ascIds]);
            for(ZTS_EU_Account_Product_Potential__c app : triggerNew){
                if(app.Account_Species_Consultation__c != null){
                    if(ascMp.get(app.Account_Species_Consultation__c) != null){
                        app.account__c = ascMp.get(app.Account_Species_Consultation__c).account__c;
                    }
                }
            }
        }  
    }

    public static void beforeUpdate(List<ZTS_EU_Account_Product_Potential__c> triggerOld, Map<Id, ZTS_EU_Account_Product_Potential__c> triggerOldMap, List<ZTS_EU_Account_Product_Potential__c> triggerNew, Map<Id, ZTS_EU_Account_Product_Potential__c> triggerNewMap) {
        set<id> ascIds = new set<id>();
        for(ZTS_EU_Account_Product_Potential__c app : triggerNew){
            if(app.Account_Species_Consultation__c != null){
                ascIds.add(app.Account_Species_Consultation__c);
            }
        }
        
        AccountProductPotentialHelper.calculateAndSumAccountProductPotential(trigger.new,ascIds);
        
        /*****/
        if(!ascIds.isEmpty()){
            map<id,ZTS_EU_Account_Species_Potential__c> ascMp = new map<id,ZTS_EU_Account_Species_Potential__c>([select id, account__c from ZTS_EU_Account_Species_Potential__c where id in:ascIds]);
            for(ZTS_EU_Account_Product_Potential__c app : triggerNew){
                if(app.Account_Species_Consultation__c != null && triggerOldMap.get(app.Id).Account_Species_Consultation__c == null){
                    if(ascMp.get(app.Account_Species_Consultation__c) != null){
                        app.account__c = ascMp.get(app.Account_Species_Consultation__c).account__c;
                    }
                }
            }
        }
    }

}