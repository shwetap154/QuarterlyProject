/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-09-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
**/
@isTest
private class Veterinarian_InformationSelectorTest {
   @TestSetup
    private static void setup(){
        List<Lead> leadRecList = TestDataFactory.createLeadRec(1);
        leadRecList[0].FirstName = 'lead1';
        leadRecList[0].LastName = 'leadlastName';
        insert leadRecList;
        
        Veterinarian_Information__c vetInfoRec = TestDataFactory.createVetInformationRec(leadRecList[0].Id);
        insert vetInfoRec;
    }
    
    @isTest
    private static void selectVetInforListByLeadIdTest(){
        Set<Id> leadIdSet = new Set<Id>();
        List<Lead> leadList = [Select Id,FirstName from Lead where FirstName='lead1'];
        for(Lead ld : leadList){
            leadIdSet.add(ld.Id);
        }
        Test.startTest();
        List<Veterinarian_Information__c> vetInfoListByLead = Veterinarian_InformationSelector.selectVetInforListByLeadId(leadIdSet);
        Test.stopTest();
        
        Assert.areEqual(1, vetInfoListByLead.size(), '1 Veterinarian Information record retrived');
    }

}