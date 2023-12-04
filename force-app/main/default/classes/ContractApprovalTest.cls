@isTest
public class ContractApprovalTest{
    
    @IsTest
    static void validate_contractApprovalTest(){
        List<Contract> contractsList = ZTS_DataUtilityTest.createContractRecord(1);
        insert contractsList;
        List<ProcessInstance> objProcessInstance;

        test.startTest();
        ContractApproval.submitContractApprovalRequest(contractsList[0].Id);
        objProcessInstance = [SELECT Id, TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :contractsList[0].Id];
        test.stopTest();

        /*
        TODO:

        Review try/catch in ContractApproval class
        */
        System.assert( objProcessInstance.isEmpty(), 'Contact record not submitted for approval' );
    }
}