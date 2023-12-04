/**
 * @description       : Main Query Class for Vet_Information_Shipping_Address__c
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             :
 * @last modified on  : 07-17-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-17-2023   Padma Nerella @ Zoetis Inc     Add selectByLeadId method
 * 1.1   07-27-2023   Ethan Hirsch @ Zoetis Inc      Add Source_Address_Name__c to selectByLead for Noa_FinalFormPDFV2Controller
 * 1.2   07-28-2023   Ethan Hirsch @ Zoetis Inc      Add Order By Id to Shipping_Address__c so data is returned in a consistent order
 *                                                   and in parallel with AddressSelector.selectByLeadId
 **/
public inherited sharing class VetInformationShippingAddressSelector {
    
    /**
     * Retrieve Vet_Information_Shipping_Address__c by the LeadIdSet
     * @param LeadIdSet 
     * @return  `List<Vet_Information_Shipping_Address__c>`
     */
    public static List<Vet_Information_Shipping_Address__c> selectByLeadId(Set<Id> leadIdSet){
        List<Vet_Information_Shipping_Address__c> selectVetInfoShippingAddList = [Select Shipping_Address__c,Veterinarian_Information__c,
                                                                                  Veterinarian_Information__r.Id,Veterinarian_Information__r.Lead__c,
                                                                                  Veterinarian_Information__r.Primary__c,
                                                                                  Veterinarian_Information__r.Veterinarian_First_Name__c,
                                                                                  Veterinarian_Information__r.Veterinarian_Last_Name__c,
                                                                                  Veterinarian_Information__r.DEA__c,
                                                                                  Veterinarian_Information__r.State_License__c,
                                                                                  Veterinarian_Information__r.Veterinarian_Role__c,
                                                                                  Veterinarian_Information__r.Veterinarian_Email__c,
                                                                                  Shipping_Address__r.Facility_DEA_License__c,
                                                                                  Shipping_Address__r.Facility_State_Veterinary_License__c,
                                                                                  Shipping_Address__r.ZTS_Address_Line_1__c,
                                                                                  Shipping_Address__r.Name,
                                                                                  Shipping_Address__r.ZTS_EU_City__c,
                                                                                  Shipping_Address__r.Full_Address__c,
                                                                                  Shipping_Address__r.Source_Address_Name__c
                                                                                  From Vet_Information_Shipping_Address__c 
                                                                                  where Veterinarian_Information__r.Lead__c=:leadIdSet
                                                                                  Order by Shipping_Address__c];
        return selectVetInfoShippingAddList;
    }

}