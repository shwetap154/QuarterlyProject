/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 07-28-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   07-28-2023   Padma Nerella @ Zoetis Inc  Added selectByLeadIdTest
**/
@isTest
private class VetInfoShippingAddressSelectorTest {
    @TestSetup
    static void setup() {
        List<Lead> noaLead = TestDataFactory.createLeadRec(1);
        insert noaLead;
        
        Veterinarian_Information__c vetInfoRec = TestDataFactory.createVetInformationRec(noaLead[0].Id);
        vetInfoRec.Veterinarian_Email__c = 'test@Zoetis.com';
        vetInfoRec.Primary__c =true;
        insert vetInfoRec;
        
        List<Address__c> addressList = TestDataFactory.createAddressesWithLead(1,noaLead[0].Id);
        insert addressList;
        
        Vet_Information_Shipping_Address__c vetInfoAddrress = TestDataFactory.createVetShippingAddress(vetInfoRec.Id,addressList[0].Id);
        insert vetInfoAddrress;
    }
    
    @isTest
    static void selectByLeadIdTest(){
        List<Vet_Information_Shipping_Address__c> vetAddressList = [Select Id,Shipping_Address__c,Veterinarian_Information__c,
                                                                   Veterinarian_Information__r.Id,Veterinarian_Information__r.Lead__c From Vet_Information_Shipping_Address__c];
        Set<Id> leadIdSet = new Set<Id>();
        for(Vet_Information_Shipping_Address__c vet : vetAddressList){
            leadIdSet.add(vet.Veterinarian_Information__r.Lead__c);
        }
        Test.startTest();
        List<Vet_Information_Shipping_Address__c> vetAddressList1 = VetInformationShippingAddressSelector.selectByLeadId(leadIdSet);
        Test.stopTest();
        
        Assert.areEqual(1, vetAddressList1.size(), '1 Vet_Information_Shipping_Address__c record retrived');
    }

}