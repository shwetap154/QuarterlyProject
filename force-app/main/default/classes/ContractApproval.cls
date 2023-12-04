global class ContractApproval {

   webservice static String submitContractApprovalRequest(Id con ) {
       
       try{        
         Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitted for Approval');
        req1.setObjectId(con);
        Approval.ProcessResult res = Approval.Process(req1);  
         }
        catch(Exception e){
        System.debug('No Approval process can process this request : ');
            
        //ApexPages.addMessages(e);
		return 'No Approval Process found matching the the criteria';
        }
       return null;
       }
}