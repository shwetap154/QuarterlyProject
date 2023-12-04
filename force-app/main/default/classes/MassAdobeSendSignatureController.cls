/*********************************************************************************************************************************************
 * Class Name   : Adobe_Send_For_Signature
 * Description  : This is used to prepare document and Adobe send for signature for MASS contracts
 * Created By   : Shiva Kudikilla
 * Created Date : Nov 04, 2016 
 *
 * Modification History:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Author                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Shiva Kudikilla       11/04/2016         Initial Version
***********************************************************************************************************************************************/

public class MassAdobeSendSignatureController { 
    
    public List<SendStatus> statusList {get;set;}  
    public ApexPages.StandardSetController controller {get; set;}
    List<Contract> lstContractIds; 
    public String vetAnimJobId {get;set;}
    public String producerJobId {get;set;} 
    
    public MassAdobeSendSignatureController(ApexPages.StandardSetController stdCntrlr) {
        controller = stdCntrlr;
        lstContractIds = controller.getSelected(); 
        System.debug('Agreements are getting created for: ' + lstContractIds);  
        }
    
    public void executeSignBatch(){
        statusList = new List<SendStatus>();    
        List<Contract> toBeProcessedList = new List<Contract>();    
        //filtering contracts to be processed
        for(Contract ct : [select id, Name,ContractNumber,AccountId,Status,Contract_Recipient__c,ZTS_US_Current_Tier__c,ZTS_US_Field_Proposed_Tier__c 
                           from Contract where Id in :lstContractIds AND ZTS_EU_Market__c = 'United States']){
                               if((ct.Status == null || ct.Status != 'Proposal Approved') && (ct.Contract_Recipient__c == null)){
                                   statusList.add(new SendStatus(ct.ContractNumber,'Error', 'Not Approved, No Contract Recipient Found', ct.Id, ct.Name, ct.ZTS_US_Field_Proposed_Tier__c));
                                   
                               }else if(ct.Status == null || ct.Status != 'Proposal Approved'){
                                   statusList.add(new SendStatus(ct.ContractNumber,'Error', 'Not Approved', ct.Id, ct.Name, ct.ZTS_US_Field_Proposed_Tier__c));
                                   
                               }else if(ct.Contract_Recipient__c == null){
                                   statusList.add(new SendStatus(ct.ContractNumber,'Error', 'No Contract Recipient Found', ct.Id, ct.Name, ct.ZTS_US_Field_Proposed_Tier__c));
                                   
                               }else{
                                   toBeProcessedList.add(ct);
                               } 
                           } 
            
        
        //updating attachments
        List<Attachment> attachments = new List<Attachment>();
        for(Contract contract : toBeProcessedList) {
            Attachment att = new Attachment();
            att.ParentId = contract.Id;
            att.Name = contract.ContractNumber + ' - Addendum - ' + DateTime.now() + '.pdf';
            PageReference addDoc = Page.CreateAddendum;
            addDoc.getParameters().put('id',contract.Id);     
            Blob docContent;
            if (Test.IsRunningTest()) {
                docContent=Blob.valueOf('UNIT.TEST');
            }else {
                docContent = addDoc.getContent(); 
            } 
            att.Body = docContent;
            attachments.add(att);
        } 
        if(attachments.size() > 0){
            try{
                insert attachments; 
            }catch(Exception ex){ 
                System.debug('Unable to insert addendum attachments: '+ ex.getMessage()); 
            } 
        }    
        Id vetAgTemplate = null;
        Id producerAgTemplate = null; 
        
        Id porkPrestigeAT = null;
        Id porkPremierAT = null;
        Id porkPlatinumAT = null;
        Id porkEliteAT = null;
        Id porkExecutiveAT = null;
        Id porkSuggestedResaleAT = null;
        Id porkResellerPricingAT = null;
        Id cattlePrestigeAT = null;
        Id cattlePremierAT = null;
        Id cattlePlatinumAT = null;
        Id cattleEliteAT = null;
        Id cattleExecutiveAT = null;
        Id cattleSuggestedResaleAT = null;
        Id cattleResellerPricingAT = null;
        
        List<echosign_dev1__Agreement_Template__c> ats = [SELECT id,Name FROM echosign_dev1__Agreement_Template__c];
        
        for(echosign_dev1__Agreement_Template__c at : ats){
            if(at.Name != null && at.Name.contains('Veterinarian and Animal Health _Auto_')){
                vetAgTemplate = at.Id;
            }else if(at.Name != null && at.Name.contains('Producers') ){
                if(at.Name.contains('PORK_Prestige')){
                    porkPrestigeAT = at.Id;
                }else if(at.Name.contains('PORK_Platinum')){
                    porkPlatinumAT = at.Id;
                }else if(at.Name.contains('PORK_Elite')){
                    porkEliteAT = at.Id;
                }else if(at.Name.contains('PORK_Premier')){
                    porkPremierAT = at.Id;
                }else if(at.Name.contains('PORK_Executive')){
                    porkExecutiveAT = at.Id;
                }else if(at.Name.contains('PORK_SuggestedResale')){
                    porkSuggestedResaleAT = at.Id;
                }else if(at.Name.contains('PORK_Reseller')){
                    porkResellerPricingAT = at.Id;
                }else if(at.Name.contains('CATTLE_Prestige')){
                    cattlePrestigeAT = at.Id;
                }else if(at.Name.contains('CATTLE_Platinum')){
                    cattlePlatinumAT = at.Id;
                }else if(at.Name.contains('CATTLE_Elite')){
                    cattleEliteAT = at.Id;
                }else if(at.Name.contains('CATTLE_Premier')){
                    cattlePremierAT = at.Id;
                }else if(at.Name.contains('CATTLE_Executive')){
                    cattleExecutiveAT = at.Id;
                }else if(at.Name.contains('CATTLE_SuggestedResale')){
                    cattleSuggestedResaleAT = at.Id;
                }else if(at.Name.contains('CATTLE_Reseller')){
                    cattleResellerPricingAT = at.Id;
                }
                //producerAgTemplate = at.Id;
            }
        }   
        System.debug(vetAgTemplate + '....Agreement Ids....' + producerAgTemplate);
        List<Id> vetAnimContracts = new List<Id>();
        List<Id> prodContracts = new List<Id>();
        
        for(Contract ct : toBeProcessedList){ 
            if(ct.ZTS_US_Field_Proposed_Tier__c == 'Veterinarian' || ct.ZTS_US_Field_Proposed_Tier__c == 'Animal Health Account'){ 
                vetAnimContracts.add(ct.Id);
                statusList.add(new SendStatus(ct.ContractNumber,'Success', 'Submitted for batch', ct.Id, ct.Name, ct.ZTS_US_Field_Proposed_Tier__c));
            }else{
                prodContracts.add(ct.Id); 
                statusList.add(new SendStatus(ct.ContractNumber,'Success', 'Submitted for batch', ct.Id, ct.Name, ct.ZTS_US_Field_Proposed_Tier__c));
            } 
        }
        System.debug(vetAnimContracts.size() + '....contracts size.....' + prodContracts.size());
        System.debug(vetAnimContracts + '....contracts.....' + prodContracts);
        try{ 
            if(vetAnimContracts.size() > 0 && vetAgTemplate != null){  
                System.debug('.....vet Id shivas.....' + vetAnimContracts);
                List<Contract> contractsUpdate = [SELECT id, Agreement_Send_Status__c FROM Contract WHERE id in :vetAnimContracts AND ZTS_EU_Market__c = 'United States'];
                for(Contract contract : contractsUpdate){
                    contract.Agreement_Send_Status__c = 'Queued';
                }
                update contractsUpdate;
                System.debug('.....Contracts Agr Status updated to Queued...' + vetAnimContracts);
                
                echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(vetAnimContracts, vetAgTemplate,'Contract'); 
                vetAnimJobId = Database.executeBatch(batch,5); 
                System.debug('Vet and Animal Health contract agreements batch started. Batch Id: ' + vetAnimJobId); 
                
                /*
                List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT id,name,echosign_dev1__Contract__c,echosign_dev1__Status__c, CreatedDate FROM echosign_dev1__SIGN_Agreement__c 
                                                                     WHERE echosign_dev1__Contract__c IN :vetAnimContracts AND echosign_dev1__Status__c = 'Draft' ORDER BY CreatedDate DESC ];
                System.debug('...shiva. agreements...' + agreements);
                Map<Id,Id> contractToAgreement = new Map<Id,Id>();
                if(agreements != null && agreements.size() > 0){
                    for(echosign_dev1__SIGN_Agreement__c agr : agreements){ 
                        if(contractToAgreement.get(agr.echosign_dev1__Contract__c) == null){
                            contractToAgreement.put(agr.echosign_dev1__Contract__c, agr.Id);      
                        }                          
                    }
                     System.debug('....shiva map...' + contractToAgreement);
                    User user = [Select Id from user where id = :UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States' limit 1];
                    String syncAgrProcessId = null;
                    if(contractToAgreement.size() > 0){
                        echosign_dev1.EchoSignActionBatch agreementsBatch = new echosign_dev1.EchoSignActionBatch(contractToAgreement.values(), 'Send', UserInfo.getSessionId(), user);
                        syncAgrProcessId = Database.executeBatch(agreementsBatch,5); 
                        
                    }
                    System.debug('Vet and Animal Health contract agreements send batch started. Batch Id: ' + syncAgrProcessId);
                }   */
            }
            if(prodContracts.size() > 0){   
                System.debug('.....prod Id shivas.....' + prodContracts);
                List<Contract> contractsUpdate = [SELECT id, Agreement_Send_Status__c FROM Contract WHERE id in :prodContracts AND ZTS_EU_Market__c = 'United States'];
                for(Contract contract : contractsUpdate){
                    contract.Agreement_Send_Status__c = 'Queued';
                }
                update contractsUpdate;
                System.debug('.....Contracts Agr Status updated to Queued...' + vetAnimContracts);
                List<Id> CATTLE_SuggestedResale_Contracts = new List<Id>();
                List<Id> CATTLE_ResellerPricing_Contracts = new List<Id>();
                List<Id> CATTLE_Prestige_Contracts = new List<Id>();
                List<Id> CATTLE_Premier_Contracts = new List<Id>();
                List<Id> CATTLE_Platinum_Contracts = new List<Id>();
                List<Id> CATTLE_Executive_Contracts = new List<Id>();
                List<Id> CATTLE_Elite_Contracts = new List<Id>();
                List<Id> Pork_SuggestedResale_Contracts = new List<Id>();
                List<Id> Pork_ResellerPricing_Contracts = new List<Id>();
                List<Id> Pork_Prestige_Contracts = new List<Id>();
                List<Id> Pork_Premier_Contracts = new List<Id>();
                List<Id> Pork_Platinum_Contracts = new List<Id>();
                List<Id> Pork_Executive_Contracts = new List<Id>();
                List<Id> Pork_Elite_Contracts = new List<Id>();
                List<Contract> tobeProdContracts = [select id,name,AccountId,Status,ZTS_US_Current_Tier__c,ContractNumber,Contract_Recipient__c,Primary_Business_Focus__c,ZTS_US_Field_Proposed_Tier__c 
                                 from Contract where Id in :prodContracts AND ZTS_EU_Market__c = 'United States'];
                for(Contract c: tobeProdContracts){
                    if(c.Primary_Business_Focus__c != null && c.Primary_Business_Focus__c.contains('Pork')){
                        if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Prestige')){
                            Pork_Prestige_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Platinum')){
                            Pork_Platinum_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Premier')){
                            Pork_Premier_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Elite')){
                            Pork_Elite_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Executive')){
                            Pork_Executive_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('SuggestedResale')){
                            Pork_SuggestedResale_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('ResellerPricing')){
                            Pork_ResellerPricing_Contracts.add(c.Id);
                        }
                    }else{
                        if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Prestige')){
                            CATTLE_Prestige_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Platinum')){
                            CATTLE_Platinum_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Premier')){
                            CATTLE_Premier_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Elite')){
                            CATTLE_Elite_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('Executive')){
                            CATTLE_Executive_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('SuggestedResale')){
                            CATTLE_SuggestedResale_Contracts.add(c.Id);
                        }else if(c.ZTS_US_Field_Proposed_Tier__c != null && c.ZTS_US_Field_Proposed_Tier__c.contains('ResellerPricing')){
                            CATTLE_ResellerPricing_Contracts.add(c.Id);
                        }
                    }
                }
                
                if(Pork_Prestige_Contracts != null && Pork_Prestige_Contracts.size() > 0 && porkPrestigeAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_Prestige_Contracts, porkPrestigeAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Pork_Platinum_Contracts != null && Pork_Platinum_Contracts.size() > 0 && porkPlatinumAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_Platinum_Contracts, porkPlatinumAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Pork_Premier_Contracts != null && Pork_Premier_Contracts.size() > 0 && porkPremierAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_Premier_Contracts, porkPremierAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Pork_Elite_Contracts != null && Pork_Elite_Contracts.size() > 0 && porkEliteAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_Elite_Contracts, porkEliteAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Pork_Executive_Contracts != null && Pork_Executive_Contracts.size() > 0 && porkExecutiveAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_Executive_Contracts, porkExecutiveAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Pork_SuggestedResale_Contracts != null && Pork_SuggestedResale_Contracts.size() > 0 && porkSuggestedResaleAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_SuggestedResale_Contracts, porkSuggestedResaleAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Pork_ResellerPricing_Contracts != null && Pork_ResellerPricing_Contracts.size() > 0 && porkResellerPricingAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Pork_ResellerPricing_Contracts, porkResellerPricingAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                
                if(Cattle_Prestige_Contracts != null && Cattle_Prestige_Contracts.size() > 0 && CattlePrestigeAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_Prestige_Contracts, CattlePrestigeAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Cattle_Platinum_Contracts != null && Cattle_Platinum_Contracts.size() > 0 && CattlePlatinumAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_Platinum_Contracts, CattlePlatinumAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Cattle_Premier_Contracts != null && Cattle_Premier_Contracts.size() > 0 && CattlePremierAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_Premier_Contracts, CattlePremierAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Cattle_Elite_Contracts != null && Cattle_Elite_Contracts.size() > 0 && CattleEliteAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_Elite_Contracts, CattleEliteAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Cattle_Executive_Contracts != null && Cattle_Executive_Contracts.size() > 0 && CattleExecutiveAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_Executive_Contracts, CattleExecutiveAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Cattle_SuggestedResale_Contracts != null && Cattle_SuggestedResale_Contracts.size() > 0 && CattleSuggestedResaleAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_SuggestedResale_Contracts, CattleSuggestedResaleAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                if(Cattle_ResellerPricing_Contracts != null && Cattle_ResellerPricing_Contracts.size() > 0 && CattleResellerPricingAT != null){
                    echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(Cattle_ResellerPricing_Contracts, CattleResellerPricingAT, 'Contract'); 
                    producerJobId = Database.executeBatch(batch,5); 
                    System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);  
                }
                 
                
                //echosign_dev1.AgreementTemplateServiceBatch batch = new echosign_dev1.AgreementTemplateServiceBatch(prodContracts, producerAgTemplate, 'Contract'); 
                //producerJobId = Database.executeBatch(batch,5); 
                //System.debug('Producer contract agreements batch started. Batch Id: ' + producerJobId);
                
                /*
                List<echosign_dev1__SIGN_Agreement__c> agreements = [SELECT id,name,echosign_dev1__Contract__c,echosign_dev1__Status__c, CreatedDate FROM echosign_dev1__SIGN_Agreement__c 
                                                                     WHERE echosign_dev1__Contract__c IN :prodContracts AND echosign_dev1__Status__c = 'Draft' ORDER BY CreatedDate DESC];
                if(agreements != null && agreements.size() > 0){
                    List<Id> agrIds = new List<Id>();
                    for(echosign_dev1__SIGN_Agreement__c agr : agreements){
                        agrIds.add(agr.Id);
                    } 
                    User user = [Select Id from user where id = :UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States' limit 1];
                    echosign_dev1.EchoSignActionBatch agreementsBatch = new echosign_dev1.EchoSignActionBatch(agrIds, 'Send', UserInfo.getSessionId(), user);
                    String syncAgrProcessId = Database.executeBatch(agreementsBatch,5); 
                    System.debug('Producer contract agreements send batch started. Batch Id: ' + syncAgrProcessId);
                }   */
            }
            System.debug('Mass send for signature process is completed.');
        }catch(Exception ex){
            System.debug('Error mass sending for signature:'  + ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
    }
 
 
    public class SendStatus{
        public String contractNumber {get;set;} 
        public String contractName {get;set;} 
        public String CurrentTier {get;set;} 
        public String contractId {get;set;}
        public String statusCode {get;set;}
        public String statusMsg {get;set;}
        
        public SendStatus(){ 
        }
        public SendStatus(String contractNumber, String code, String msg, String cid, String contractName, String CurrentTier ){
            this.contractNumber = contractNumber;
            this.contractName = contractName;
            this.statusCode = code;
            this.statusMsg = msg;
            this.contractId = cid;
            this.CurrentTier = CurrentTier;
        }
    }


}