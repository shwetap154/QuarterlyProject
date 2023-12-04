/**
Class Name	    : CompetencyGroupsService
Description	    : Service Class created as part of TPDEV-558 for the Competency Group object. 
Created By		: Raut, Pranav Krushnarao
Created Date	: 03-28-2023

Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01   Raut, Pranav Krushnarao	03-28-2023   Added 'preventDuplicateCompetencyGroup' Method to throw an error when user tries to create duplicate Competency Group record.
02   Raut, Pranav Krushnarao	04-10-2023   Added 'preventDuplicateCompGroupForCompModel' Method to throw an error when updated Market and Role Combinations are already assigned to the Competency Models.
*/
public With Sharing class CompetencyGroupsService {
    
    /**     
* @Description As part of TPDEV-558 this method will throw an error when user tries to create duplicate Competency Group record.
* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 03-28-2023
*/    
    public static void preventDuplicateCompetencyGroup(List<Competency_Group__c> lstNewCompetencyGroup, Map<Id,Competency_Group__c> mapOldCompetencyGrp){
        Set<String> setMarket = new Set<String>();
        if(!lstNewCompetencyGroup.isEmpty()){
            for(Competency_Group__c objCompGroup : lstNewCompetencyGroup){
                setMarket.add(objCompGroup.Market__c);                
            }           
        } 
        
        Map<String, Competency_Group__c> mapMrktRoleCompGrp = new Map<String, Competency_Group__c>();
        List<Competency_Group__c> lstExistingCompGrp = CompetencyGroupSelector.selectByCompeGroupByMarketSet(setMarket);
        if(!lstExistingCompGrp.isEmpty()){
            for(Competency_Group__c objExistingCompGrp : lstExistingCompGrp){
                String marketRole = objExistingCompGrp.Market__c+objExistingCompGrp.Role__c;
                mapMrktRoleCompGrp.put(marketRole, objExistingCompGrp);                
            }          
        }       
        for(Competency_Group__c objCompGroup : lstNewCompetencyGroup){
            if(mapOldCompetencyGrp == null && mapMrktRoleCompGrp.containsKey(objCompGroup.Market__c+objCompGroup.Role__c)){
                objCompGroup.addError(System.Label.Duplicate_Competency_Group_Error);
            }
            if(mapOldCompetencyGrp != null && 
               (mapOldCompetencyGrp.get(objCompGroup.Id).Market__c != objCompGroup.Market__c || mapOldCompetencyGrp.get(objCompGroup.Id).Role__c != objCompGroup.Role__c) &&
               mapMrktRoleCompGrp.containsKey(objCompGroup.Market__c+objCompGroup.Role__c)){
                   objCompGroup.addError(System.Label.Duplicate_Competency_Group_Error);
               }                           
        }     
    }
    
    /**     
* @Description As part of TPDEV-558 this method will throw an error when updated Market and Role Combinations are already assigned to the Competency Models.
* @Author      Raut, Pranav Krushnarao @ Zoetis Inc | 04-10-2023
*/    
    public static void preventDuplicateCompGroupForCompModel(Map<Id,Competency_Group__c> mapNewCompetencyGrp, Map<Id,Competency_Group__c> mapOldCompetencyGrp){
        
        Set<String> setMarket = new Set<String>();
        Map<Id, Competency_Group__c> mapCompetencyGroup = new Map<Id, Competency_Group__c>();
        
        if(mapNewCompetencyGrp != null && mapOldCompetencyGrp != null){
            for(Competency_Group__c objCompGrp : mapNewCompetencyGrp.values()){
                if(mapOldCompetencyGrp.get(objCompGrp.Id).Market__c != objCompGrp.Market__c || mapOldCompetencyGrp.get(objCompGrp.Id).Role__c != objCompGrp.Role__c){                
                    setMarket.add(objCompGrp.Market__c);
                    mapCompetencyGroup.put(objCompGrp.Id, objCompGrp);
                }
            }       
        }
        Map<String,String> mapCompGrpMrktRoleVsCompModel = new Map<String,String>();
        if(!setMarket.isEmpty()){            
            List<Competency_Group_Assignment__c> lstCompGrpAssignment = CompetencyGroupAssignSelector.selectByCompeGroupSetOfMarket(setMarket);
            if(!lstCompGrpAssignment.isEmpty()){
                for(Competency_Group_Assignment__c objCompGrpAssign : lstCompGrpAssignment){
                    String existingCompGrpMrktRole = objCompGrpAssign.Competency_Group__r.Market__c+objCompGrpAssign.Competency_Group__r.Role__c;
                    mapCompGrpMrktRoleVsCompModel.put(existingCompGrpMrktRole, objCompGrpAssign.Competency_Model__r.Name);
                }               
            }            
        }
        
        string CompModelName='{CompetencyModelName}';
        string CompGrpMarket='{CompetencyGroupMarket}';
        string CompGrpRole='{CompetencyGroupRole}';
        
        for(Competency_Group__c objCmpGroup : mapCompetencyGroup.values()){
            if(mapCompGrpMrktRoleVsCompModel.containsKey(objCmpGroup.Market__c+objCmpGroup.Role__c)){                
                String errorMessage = System.Label.Duplicate_CompetencyGroup_On_CompetencyModel_Error.replace(CompModelName,mapCompGrpMrktRoleVsCompModel.get(objCmpGroup.Market__c+objCmpGroup.Role__c)).replace(CompGrpMarket,objCmpGroup.Market__c).replace(CompGrpRole,objCmpGroup.Role__c);
                objCmpGroup.addError(errorMessage);
            }           
        }       
    }    
}