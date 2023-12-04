/*
* @Name: ZTS_US_ContractTierChanges
* @Desciption: 1. Developed for the Tier Change functionality of Contracts.
* @date Created:April 30, 2014
* @author: Ketan Prakash Singh
*
*/
public class ZTS_US_ContractTierChanges{

    public static final String SUBMITTING_COMMENTS = 'Tier Change request submitted';
    
    @testVisible 
    static final String APPROVAL_PROCESS_EXCEP_ORIGIN = 'ZTS_US_ContractTierChanges - SubmitForApproval(): execute Approval Process for Contract';

    @testVisible 
    static final String INSERT_CONTRACT_EXCEP_ORIGIN = 'ZTS_US_ContractTierChanges - SubmitForApproval(): Insert Contract Error ';
  
    
    public String contractId{get;set;}
    public Contract CurrentContract {get;set;} {CurrentContract = new Contract ();}
    
    public ZTS_US_ContractTierChanges(ApexPages.StandardController cont){
        if(ApexPages.currentPage().getParameters().containsKey('contractId')){
            contractId = ApexPages.currentPage().getParameters().get('contractId');
        }
        if(contractId != null){
            CurrentContract = [Select c.RecordTypeId, c.AccountId, c.ZTS_US_External_ID__c, c.ZTS_US_Submitter_Comments__c, c.ZTS_US_Field_Proposed_Tier__c, 
                               c.ZTS_US_Current_Tier__c,c.Primary_Business_Focus__c, c.Contract_Recipient__c,  c.Id From 
                                Contract c where c.id = :contractId limit 1]; 
        }

    }
    /*
    *@name: SubmitForApproval
    *@description: 1. Updates Field Proposed Tier & Submitter Comments
    *              2. Flips the record type to Tier Change
    *              3. Stamps the Current Contract & External Id from the Existing Contract
    *              4. Creates a new Contract 
    *              5. Enters the new Contract in Approval Process    
    */ 
     
     public PageReference SubmitForApproval(){
     
        //CurrentContract.RecordTypeId = System.Label.ZTS_US_Tier_Change;
        
        Contract contr = new Contract();
        //contr.ZTS_US_External_ID__c = CurrentContract.ZTS_US_External_ID__c;
        contr.ZTS_US_Activated_Contract_Ext_Id__c = CurrentContract.ZTS_US_External_ID__c;
        contr.AccountId = CurrentContract.AccountId;
        contr.ZTS_US_Current_Tier__c  = CurrentContract.ZTS_US_Current_Tier__c;
        contr.ZTS_US_Field_Proposed_Tier__c = CurrentContract.ZTS_US_Field_Proposed_Tier__c;
        contr.ZTS_US_Submitter_Comments__c = CurrentContract.ZTS_US_Submitter_Comments__c;
        contr.ZTS_US_Current_Contract__c = CurrentContract.id;
        contr.RecordTypeId = System.Label.ZTS_US_Tier_Change;
        contr.Primary_Business_Focus__c = CurrentContract.Primary_Business_Focus__c;
        contr.Contract_Recipient__c =  CurrentContract.Contract_Recipient__c;

        try{
           //Update CurrentContract;
           insert contr;
           system.debug('@@@@ contr is: '+contr.id);
        }
        catch(Exception e){
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Only Silver, Elite or Platinum Tier can be used when submitting a Pork primary business focus LE Contract Proposal. Please go back and update your tier selection appropriately.'));    
            }
            ZTS_EU_Logger.error(e.getMessage(),null, INSERT_CONTRACT_EXCEP_ORIGIN);      
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Update Failed:CurrentContract'));
            return null;
       }
       
       try{
            // Create an approval request for the Contract
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(SUBMITTING_COMMENTS);
            req.setObjectId(contr.id);

            // Submit the approval request for the Contract
            Approval.ProcessResult result = Approval.process(req);

            // display if the reqeust was successful
            System.debug('Submitted for approval successfully: '+result.isSuccess());
       }
       catch(DmlException dex)
		{
			String errorMessages = '';
			for (Integer i = 0; i < dex.getNumDml(); i++) {
				System.debug(APPROVAL_PROCESS_EXCEP_ORIGIN);
				System.debug('DML Message: ' + dex.getDmlMessage(i));
				errorMessages += dex.getDmlMessage(i) + '\n';
			}
			errorMessages.removeEnd('\n');
			ZTS_EU_Logger.notify = true;
			ZTS_EU_Logger.error(errorMessages,null, APPROVAL_PROCESS_EXCEP_ORIGIN);
		}
         pageReference pg =  new pageReference('/'+contr.id);
         pg.setRedirect(false);
         return pg;   
      }
}