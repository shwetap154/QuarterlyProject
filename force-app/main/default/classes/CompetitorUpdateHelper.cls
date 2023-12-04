/**
* File Name     :  CompetitorUpdateHelper
* @description  :  Helper class to update a competitor from a Lead when the Lead has a discussion item of "Reference Lab" associate to it.
                    The lead is created for the first attendee associated to the discussion.
                    Once the lead has been created, it is assigned to the account owner of the account associated to the call. 
					Competior will be created under that account 
* @author       :  Mila Imas
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     8/3/2021		Mila Imas    Created the Class for SC-008625,SC-008281
**/
public class CompetitorUpdateHelper {
    public static void updateCompetior(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap){
       Set<Id> accIds = new Set<Id>(); 
       Map<id,Lead> refLeads = new map<id,Lead>();
       List<Lead>  updLead = new List<Lead>();
        for(Lead lead : newLeadList) {
            if (lead.Reference_Lab_Lead__c){
                if(String.isNotBlank(string.ValueOf( lead.Date_Contract_expires__c)) || (String.isNotBlank(lead.Are_their_contract_minimums__c))
                     || (String.isNotBlank(lead.Contract_include_POC_analyzers__c)) || (String.isNotBlank(lead.Any_special_terms_or_pricing__c))){
                       accIds.add(lead.Account_ID__c); 
                       refLeads.put(lead.Account_ID__c, lead);
                     
                   }
            }
        }
	
        List<ZTS_Competitor__c> insertCompList = new List<ZTS_Competitor__c>();
        List<ZTS_Competitor__c> updComp = new List<ZTS_Competitor__c>();
        List<ZTS_Competitor__c> compList = [select id,name ,Account__c,contract_minimums__c,POC__c,Special_terms_or_pricing__c,contract_auto_renewal_date__c,Date_Contract_Expires__c,Lead__c
                                            from ZTS_Competitor__c  where Account__c in :accIds ];//(SC-009384) Removed condition "name = 'Reference Lab'" in where clause as name field is now changed as Auto Number.
        if ( (compList != null) && compList.size()>0){
            for  ( ZTS_Competitor__c comp :compList)
            {
                Lead leadRec =  refLeads.get(comp.Account__c);
                //Lead oldLead = oldLeadMap.get(leadRec.Id);
                comp.contract_minimums__c = leadRec.Are_their_contract_minimums__c;
                comp.POC__c = leadRec.Contract_include_POC_analyzers__c;
                comp.Special_terms_or_pricing__c= leadRec.Any_special_terms_or_pricing__c;
                comp.Date_Contract_Expires__c = leadRec.Date_Contract_expires__c;
                comp.contract_auto_renewal_date__c = leadRec.Date_Contract_expires__c;
                if (comp.Lead__c == null) {comp.Lead__c = leadRec.id;} 
                updComp.add(comp);
                accIds.remove(comp.Account__c);
            }
        }
        if (updComp.size()> 0) {
            update updComp;
            
        }  
        for (Id aid : accIds) {
                Lead newLead =  refLeads.get(aid);
                ZTS_Competitor__c newComp = new ZTS_Competitor__c();
                //newComp.name = 'Reference Lab';--Commented as the Name field is now changed to Auto number (SC-009384)
                newComp.Account__c = aid; 
                newComp.contract_minimums__c = newLead.Are_their_contract_minimums__c;
                newComp.POC__c = newLead.Contract_include_POC_analyzers__c;
                newComp.Special_terms_or_pricing__c= newLead.Any_special_terms_or_pricing__c;
                newComp.Date_Contract_Expires__c = newLead.Date_Contract_expires__c;
                newComp.contract_auto_renewal_date__c = newLead.Date_Contract_expires__c;
                
                insertCompList.add(newComp);
        }
        if (insertCompList.size() > 0) {
              system.debug('Iserting list ' + insertCompList);
              insert insertCompList;
           }
        system.debug('CompetitorUpdateHelper updating  updComp===> ' + updComp);
    }
}