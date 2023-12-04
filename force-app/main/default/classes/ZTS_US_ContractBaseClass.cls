/*
* @Name: ZTS_US_ContractBaseClass
* @Desciption: All webservice methods called from Contract custom buttons are defined here.
* @date May 21, 2014
* @author Ketan Prakash Singh
*/

global class ZTS_US_ContractBaseClass{
    public static List<Contract> lstContract{get;set;}{lstContract=new List<Contract>();}
    
/*
*@name massApproveRenewal
*@description Method that updates the status fields of the selected Renewal Contract records to 'Proposal Approved'on click of 'Mass Approve Renewals' button on specific condition.  
*@params List of Ids of the Renewal Contract records
*/ 
  webservice static void massApproveRenewal(list<string> lstContractIds)
   {    
       System.debug('The Ids you have selected are: '+lstContractIds);
        
        lstContract = [Select c.RecordTypeId, c.AccountId, c.ZTS_US_External_ID__c, c.ZTS_US_Review_Committee_Proposed_Tier__c, c.ZTS_US_Field_Proposed_Tier__c, c.ZTS_US_Current_Tier__c, c.Id,c.Record_Type_Name__c,
                                c.ZTS_US_BIOs_Proposed_Tier__c, c.ZTS_US_BIOs_Field_Proposed_Tier__c,c.ZTS_US_PARAs_Proposed_Tier__c,ZTS_US_PARAs_Field_Proposed_Tier__c,c.ZTS_US_PAS_Proposed_Tier__c, 
                                    c.ZTS_US_PAS_Field_Proposed_Tier__c From Contract c where c.id in :lstContractIds AND ZTS_EU_Market__c = 'United States' limit 1000]; 
        List<Contract> listContrToUpdate = new List<Contract>();                        
        System.debug('@@@@@@@@@ The list of Contract is: '+lstContract);
        
         for(Contract objContr: lstContract){
              if ((objContr.RecordTypeId == System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal &&
                  objContr.ZTS_US_Field_Proposed_Tier__c == objContr.ZTS_US_Review_Committee_Proposed_Tier__c && 
                  (objContr.ZTS_US_Field_Proposed_Tier__c != '' && objContr.ZTS_US_Field_Proposed_Tier__c != null) && 
                  (objContr.ZTS_US_Review_Committee_Proposed_Tier__c !='' && objContr.ZTS_US_Review_Committee_Proposed_Tier__c != null))||((objContr.Record_Type_Name__c == 'MZR BIOS Renewal' &&
                  objContr.ZTS_US_BIOs_Proposed_Tier__c == objContr.ZTS_US_BIOs_Field_Proposed_Tier__c  &&
                  (objContr.ZTS_US_BIOs_Field_Proposed_Tier__c != '' && objContr.ZTS_US_BIOs_Field_Proposed_Tier__c != null)))){ 
                      objContr.Status = 'Proposal Approved';  
                      listContrToUpdate.add(objContr);
              }
         }
         System.debug('@@@@@@@@@ The list of Contract to update is: '+listContrToUpdate);
          if(listContrToUpdate.size()>0){
                try{
                    Database.update(listContrToUpdate);
                }
                catch(Exception e){
                    system.debug('Exception*******>'+e);
                }
          }     
   }
     webservice static void SingleApproveRenewal(Contract cntrct)
   {    
       System.debug('The Ids you have selected are: '+cntrct.Id);
        
        lstContract = [Select c.RecordTypeId, c.AccountId, c.ZTS_US_External_ID__c, c.ZTS_US_Review_Committee_Proposed_Tier__c, c.ZTS_US_Field_Proposed_Tier__c, c.ZTS_US_Current_Tier__c, c.Id,c.Record_Type_Name__c,
                                c.ZTS_US_BIOs_Proposed_Tier__c, c.ZTS_US_BIOs_Field_Proposed_Tier__c,c.ZTS_US_PARAs_Proposed_Tier__c,ZTS_US_PARAs_Field_Proposed_Tier__c,c.ZTS_US_PAS_Proposed_Tier__c, 
                                    c.ZTS_US_PAS_Field_Proposed_Tier__c From Contract c where c.id =:cntrct.Id AND ZTS_EU_Market__c = 'United States']; 
        List<Contract> listContrToUpdate = new List<Contract>();                        
        System.debug('@@@@@@@@@ The list of Contract is: '+lstContract);
        
         for(Contract objContr: lstContract){
              if ((objContr.RecordTypeId == System.Label.ZTS_US_Contract_Record_Type_Id_for_Contract_Renewal &&
                  objContr.ZTS_US_Field_Proposed_Tier__c == objContr.ZTS_US_Review_Committee_Proposed_Tier__c && 
                  (objContr.ZTS_US_Field_Proposed_Tier__c != '' && objContr.ZTS_US_Field_Proposed_Tier__c != null) && 
                  (objContr.ZTS_US_Review_Committee_Proposed_Tier__c !='' && objContr.ZTS_US_Review_Committee_Proposed_Tier__c != null))||((objContr.Record_Type_Name__c == 'MZR BIOS Renewal' &&
                  objContr.ZTS_US_BIOs_Proposed_Tier__c == objContr.ZTS_US_BIOs_Field_Proposed_Tier__c  &&
                  (objContr.ZTS_US_BIOs_Field_Proposed_Tier__c != '' && objContr.ZTS_US_BIOs_Field_Proposed_Tier__c != null)))){ 
                      objContr.Status = 'Proposal Approved';  
                      listContrToUpdate.add(objContr);
              }
         }
         System.debug('@@@@@@@@@ The list of Contract to update is: '+listContrToUpdate);
          if(listContrToUpdate.size()>0){
                try{
                    Database.update(listContrToUpdate);
                }
                catch(Exception e){
                    system.debug('Exception*******>'+e);
                }
          }     
   } 
}