/**
* @ClassName    : SL_CaseConsumableTriggerHandler 
* @JIRATicket   : LIGHTNI-1798
* @CreatedOn    : 18th Nov 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : Poonam Dalvi
* @Description  : Handler for the case comsumable trigger.
*/
public with sharing class SL_CaseConsumableTriggerHandler {

    class CaseUpdateFailedException extends Exception { }

    public static Boolean isCaseUpdateFromConsumable = false;
    /***********
    * Method name  : onAfterInsert
    * Description  : This method call on after insert trigger event and process the data.
    * Return Type  : NA
    * Parameters   : Map<Id, Case_Consumable__c> mapNew
    ***********/
    public void onAfterInsert(Map<Id, Case_Consumable__c> mapNew) {
        createUpdateRotorCredit(mapNew, null);
    }

    /***********
    * Method name  : onBeforeUpdate
    * Description  : This method call on before update trigger event and process the data.
    * Return Type  : NA
    * Parameters   : Map<Id, Case_Consumable__c> mapNew, Map<Id, Case_Consumable__c> mapOld.
    ***********/
    public void onBeforeUpdate(Map<Id, Case_Consumable__c> mapNew, Map<Id, Case_Consumable__c> mapOld) {
        createUpdateRotorCredit(mapNew, mapOld);
    }
    
     /***********
    * Method name  : onBeforeDelete
    * Description  : This method call on before delte trigger event and process the data.
    * Return Type  : NA
    * Parameters   : List Case_Consumable__c
    ***********/
    public void onBeforeDelete(List<Case_Consumable__c> lstCaseConsumable)
    {
        deleteErrorCaseConsumable(lstCaseConsumable);
    }
    /***********
    * Method name  : createUpdateRotorCredit
    * Description  : This method create and update the rotor Transactions from case consumable.
    * Return Type  : NA
    * Parameters   : Map<Id, Case_Consumable__c> mapNew, Map<Id, Case_Consumable__c> mapOld.
    ***********/
    private void createUpdateRotorCredit(Map<Id, Case_Consumable__c> mapNew, Map<Id, Case_Consumable__c> mapOld) {

        List<Rotor_Transaction__c> lstRotorTxns = new List<Rotor_Transaction__c>();
        List<Rotor_Transaction__c> lstDeletableRotorTxns = new List<Rotor_Transaction__c>();
        Map<Id, Case_Consumable__c> mapIdToCaseConsumeObjs = new Map<Id, Case_Consumable__c>();
        Set<Id> setCaseIds = new Set<Id>();
        Set<String> setFieldAPI = new Set<String>();
        
        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get('Case_Consumable__c').getDescribe().fields.getMap();
        
        for(String fieldName : mapFields.keySet())
        {
            if(mapFields.get(fieldName).getDescribe().isUpdateable()) 
                setFieldAPI.add(fieldName);
        }
        
        for(Case_Consumable__c caseCon : mapNew.values()) 
        {   
            if(SL_AvoidCaseConsumableRecursion.isCaseUpdate != true)
            {
                for(String strFieldAPIName : setFieldAPI)
                {
                    if(mapOld != null && mapOld.get(caseCon.Id).Primary__c && (mapOld.get(caseCon.Id).get(strFieldAPIName) != caseCon.get(strFieldAPIName)))   
                        caseCon.addError('If you want to update the primary consumable Error Code, Lot #, Lot # Unknown or Rotor Credits fields, you must do this directly on the case fields.');
                    else if(mapOld != null && mapOld.get(caseCon.Id).Primary__c == false && mapOld.get(caseCon.Id).Primary__c != caseCon.Primary__c && caseCon.Primary__c)
                        caseCon.addError('You cannot update the primary field from Case Consumable.');
                }
            }
            setCaseIds.add(caseCon.Case__c);
        }
        SL_AvoidCaseConsumableRecursion.isCaseUpdate = false;
        
        Map<Id, Case> mapIdToCase = new Map<Id, Case>([SELECT Id, AccountId FROM Case WHERE Id IN :setCaseIds]);

        for(Case_Consumable__c caseCon : mapNew.values()) {
            if( mapOld == null && caseCon.Rotor_Credit__c > 0) {
                lstRotorTxns.add(new Rotor_Transaction__c(  Account__c = mapIdToCase.get(caseCon.Case__c).AccountId,
                                                            Case_Consumable__c = caseCon.Id,
                                                            Rotor_Credit__c = caseCon.Rotor_Credit__c,
                                                            Product__c = caseCon.Consumable_Product__c));
            } else if(mapOld != null && ( mapOld.get(caseCon.Id).Rotor_Credit__c != caseCon.Rotor_Credit__c )) {
                if(mapOld.get(caseCon.Id).Rotor_Credit__c == 0) {
                    lstRotorTxns.add(new Rotor_Transaction__c(  Account__c = mapIdToCase.get(caseCon.Case__c).AccountId,
                                                                Case_Consumable__c = caseCon.Id,
                                                                Rotor_Credit__c = caseCon.Rotor_Credit__c,
                                                                Product__c = caseCon.Consumable_Product__c));
                }else{
                    mapIdToCaseConsumeObjs.put(caseCon.Id, caseCon);
                }
            }
        }
        for(Rotor_Transaction__c objRTxn : [SELECT Id, Account__c, Case_Consumable__c, Rotor_Credit__c, Locked__c 
                                            FROM Rotor_Transaction__c
                                            WHERE Case_Consumable__c IN :mapIdToCaseConsumeObjs.keySet()]) {
            Case_Consumable__c caseCon = mapIdToCaseConsumeObjs.get(objRTxn.Case_Consumable__c);
            if(objRTxn.Locked__c) {
                caseCon.addError('Cannot be modified after the related Rotor Transaction has been locked.');
            }else if(caseCon.Rotor_Credit__c > 0) {
                lstRotorTxns.add(new Rotor_Transaction__c(Id = objRTxn.Id, 
                                                          Rotor_Credit__c = caseCon.Rotor_Credit__c));
            }else if(caseCon.Rotor_Credit__c == 0) {
                lstDeletableRotorTxns.add(objRTxn);
            }
        }

        if(!lstRotorTxns.isEmpty())
            upsert lstRotorTxns;

        if(!lstDeletableRotorTxns.isEmpty())
            delete lstDeletableRotorTxns;
    }
    
     /***********
    * Method name  : deleteErrorCaseConsumable
    * Description  : This method throws error while trying to delete the case consumable record if it is primary.
    * Return Type  : NA
    * Parameters   : List Case_Consumable__c
    ***********/
    private void deleteErrorCaseConsumable(List<Case_Consumable__c> lstCaseConsumable) {
        
        Id AdminProfileId = [SELECT Id FROM Profile Where Name = 'System Administrator' LIMIT 1].Id;
        Set<Id> setRelatedCaseId = new Set<Id>();
        Map<Id, Case_Consumable__c> mapCaseConsumable = new Map<Id, Case_Consumable__c>();
        List<Rotor_Transaction__c> lstRotorTxns = new List<Rotor_Transaction__c>();
        List<Rotor_Transaction__c> lstDeletableRotorTxns = new List<Rotor_Transaction__c>();

        for(Case_Consumable__c objCC : lstCaseConsumable){
            if(objCC.Primary__c == true ) {
                if(UserInfo.getProfileId() != AdminProfileId) {
                    objCC.addError('Primary Case consumable record cannot be deleted.');
                } else {
                    setRelatedCaseId.add(objCC.Case__c);
                    mapCaseConsumable.put(objCC.Id, objCC);
                }
            }
        }

        SL_CaseConsumableTriggerHandler.isCaseUpdateFromConsumable = true;
        if(!setRelatedCaseId.isEmpty() && SL_AvoidCaseConsumableRecursion.isCaseUpdate != true){
            
            List<case> relatedCaseRecs = new List<case>();
            for(Id recId : setRelatedCaseId) {
                relatedCaseRecs.add(new Case(Id = recId,
                                             Primary_Consumable__c = null,
                                             Primary_Error_Code__c = null,
                                             Primary_Lot_Num__c = null,
                                             Primary_Lot_Num_Unknown__c = false));
            }

            try {
                update relatedCaseRecs;
            } catch (Exception ex) {
                throw new CaseUpdateFailedException('Unexpected error occured. Please contact your Administrator.');
            }
        }
    }
}