global class EventApproval {
      @AuraEnabled
      webservice static void submitEventApprovalRequest(Id event ) {
               
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitted for Approval');
            req1.setObjectId(event);
            Approval.ProcessResult res = Approval.Process(req1);  
         
      }
}