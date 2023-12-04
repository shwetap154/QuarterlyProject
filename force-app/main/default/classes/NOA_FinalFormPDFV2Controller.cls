/**
 * @description       : Controller class for the NOA_FinalFormPDFV2 VF Page
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-27-2023
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-27-2023   Ethan Hirsch @ Zoetis Inc   Initial Version TPDEV-1079
 * 1.1   08-17-2023   Padma Nerella @ Zoetis Inc  Add Signature and date tags to be generated with two curly braces TPDEV-1809
 * 1.2   08-31-2023   Padma Nerella @ Zoetis Inc  Add Logic get only Primary Financial Authorized Person signature tpdev-1865
**/
public with sharing class NOA_FinalFormPDFV2Controller {
    
    public List<AddressWrapper> addressList {get; private set;}
    public List<ShipAddressVetWrapper> shipAddressVetList {get; private set;}
    public List<NOA_Financially_Authorized_Person__c> financiallyAuthPersonList {get; private set;}
    public List<FinancialSigner> financialSigners {get; private set;}
    public List<ContentDocumentLink> leadContentDocLinklist {get; private set;}
    public string whatYourBusinessDoes {get;private set;}
    public String animalsYourBusinessWorksWith {get; private set;}
    public String billingAddress {get;private set;}
    // If false, the Visualforce Page will output Adobe Signature Tags
    public Boolean downloadPdf {get; private set;}
    // If true, Hospital Type and Full time staff veterinarians fields are displayed
    public Boolean rxForm {get; private set;}
    // If true, Only Primary Vets will need to sign.
    public Boolean exemptFromSignature {get; private set;}
    private Integer signatureCounter = 1;
    
    // This list is used in setCustomLeadFields to populate animalsYourBusinessWorksWith
    private List<Schema.sObjectField> businessCheckboxes = new List<Schema.sObjectField> {
        Lead.Beef_Business__c,
        Lead.Cats_Business__c,
        Lead.Dogs_Business__c,
        Lead.Dairy_Business__c,
        Lead.Pork_Business__c,
        Lead.Poultry_Business__c,
        Lead.Sheep_Business__c,
        Lead.Horses_Business__c,
        Lead.Other_Small_Animals_Business__c
    };
    
    /**
     * Constructor for orchestrating the setup of data needed by the Visualforce Page
     * @param controller 
     */
    public NOA_FinalFormPDFV2Controller(ApexPages.StandardController controller) {
        setDownloadPdf();
        
        Lead leadRecord = (Lead) controller.getRecord();
        Set<Id> leadIdSet = new Set<Id> {leadRecord.Id};
        
        loadAddresses(leadIdSet);
        setExemptFromSignature(leadRecord);

        Map<String, FinancialSigner> financialSignerByEmail = setupFinanciallyAuthorizedPersonsAndSigners(leadIdSet);

        List<Vet_Information_Shipping_Address__c> vetAddressList = VetInformationShippingAddressSelector.selectByLeadId(leadIdSet);
        this.shipAddressVetList = buileadRecordShipAddressVetWrappers(vetAddressList, financialSignerByEmail);

        // If Lead Id is null, this query will error. Return an empty list to avoid that
        if (leadRecord?.Id != null) {
            this.leadContentDocLinklist = [SELECT Id, LinkedEntityId,ContentDocument.FileType,ContentDocument.Title,  ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:leadIdSet];
        }
        else {
            this.leadContentDocLinklist = new List<ContentDocumentLink>();
        }

       setCustomLeadFields(leadIdSet);
    }

    /**
     * Sets the downloadPdf boolean value based on if it's passed into the PDF or not.
     * If false, this will generate Adobe eSignature Tags
     */
    private void setDownloadPdf() {
        this.downloadPdf = false;
        String downloadPdf = ApexPages.currentPage().getParameters().get('downloadPdf');
        if (String.isNotBlank(downloadPdf)) {
            try {
                this.downloadPdf = Boolean.valueOf(downloadPdf);
            }
            catch (exception e) {
                // Ignore errors, downloadPdf will default to false
            }
        }
    }

    /**
     * Populates addressList with the Addresses of the Lead 
     * @param leadIdSet 
     */
    private void loadAddresses(Set<Id> leadIdSet) {
        this.addressList = new List<AddressWrapper>();

        List<Address__c> addressList = AddressesSelector.selectByLeadId(leadIdSet);
        for(Integer i=0;i<addressList.size();i++){
            this.addressList.add(new AddressWrapper(addressList[i],i+1));
        }
    }
    
    /**
     * If the Lead's Business Name is in the NOA_Accounts_Exempt__mdt Custom Metadata,
     * this will set exemptFromSignature to true. This will only require the Vets to sign
     * @param leadRecord
     */
    private void setExemptFromSignature(Lead leadRecord) {
        Set<String> exemptAccountNames = NOALeadsService.retrieveNOAExemptSignedAccounts();

        if (exemptAccountNames.contains(leadRecord.Business_Name__c)) {
            this.exemptFromSignature = true;
        }
        else {
            this.exemptFromSignature = false;
        }
    }
    
    /**
     * Sets up Financially Authorized Person data from the related Lead, including their Signature and date tags for Adobe
     * The Financiially Authorized Person signatures are returned so that the same Signature Tags can be used by Vets
     * with the same email
     * @param leadIdSet 
     * @return  `Map<String, FinancialSigner>`
     */
    private Map<String, FinancialSigner> setupFinanciallyAuthorizedPersonsAndSigners(Set<Id> leadIdSet) {
        this.financiallyAuthPersonList = FinanciallyAuthorizedPersonSelector.selectByLeadId(leadIdSet);
        Map<String, FinancialSigner> financialSignerByEmail = new Map<String, FinancialSigner>();
        this.financialSigners = new List<FinancialSigner>();
        
        for (NOA_Financially_Authorized_Person__c financialPerson : this.financiallyAuthPersonList) {
            if(!financialPerson.Primary__c){
                continue;
            }
            String email = financialPerson.Email__c;
            
            FinancialSigner signer = new FinancialSigner(financialPerson);
            if (!exemptFromSignature) {
                if (financialSignerByEmail.containsKey(email)) {
                    signer.cloneTags(financialSignerByEmail.get(email));
                }
                else {
                    generateSignatureAndDateTag(signer, signatureCounter++);
                }
            }

            this.financialSigners.add(signer);

            // If this Customer is exempt from signatures, do not populate the map so all Vets generate proper Signature Tags
            if (!exemptFromSignature && !financialSignerByEmail.containsKey(email)) {
                financialSignerByEmail.put(email, signer);
            }

        }

        return financialSignerByEmail;
    }

    /**
     * Setup Shipping Address and Vet information for the signature section of the PDF
     * @param vetAddressList 
     * @param financialSignerByEmail 
     * @return  `List<ShipAddressVetWrapper>`
     */
    private List<ShipAddressVetWrapper> buileadRecordShipAddressVetWrappers(List<Vet_Information_Shipping_Address__c> vetAddressList, Map<String, FinancialSigner> financialSignerByEmail) {
        Map<Id, ShipAddressVetWrapper> shipAddressVetsByAddressId = new Map<Id, ShipAddressVetWrapper>();


        // Group Primary Vets by existing signature to more easily generate Signature Tags later on in the code
        Map<String, Signer> existingPrimaryVetSignaturesByEmail = new Map<String, Signer>();
        for (Vet_Information_Shipping_Address__c vetInfo : vetAddressList) {
            if (vetInfo.Veterinarian_Information__r.Primary__c) {
                String email = vetInfo.Veterinarian_Information__r.Veterinarian_Email__c;

                if (financialSignerByEmail.containsKey(email)) {
                    existingPrimaryVetSignaturesByEmail.put(email, financialSignerByEmail.get(email));
                }
            }
            
        }

        for(Vet_Information_Shipping_Address__c vetInfo : vetAddressList){
            Id addressId = vetInfo.Shipping_Address__r.Id;
            // As there can be multiple Vets on a Shipping Address, make sure the Address is only added once
            if (!shipAddressVetsByAddressId.containsKey(addressId)) {
                shipAddressVetsByAddressId.put(addressId, new ShipAddressVetWrapper(
                    vetInfo.Shipping_Address__r.Source_Address_Name__c,
                    vetInfo.Shipping_Address__r.ZTS_Address_Line_1__c,
                    vetInfo.Shipping_Address__r.ZTS_EU_City__c,
                    vetInfo.Shipping_Address__r.Facility_State_Veterinary_License__c,
                    vetInfo.Shipping_Address__r.Facility_DEA_License__c
                ));
            }

            ShipAddressVetWrapper shipAddressVet = shipAddressVetsByAddressId.get(addressId);

            // Only Primary Vets are setup as signers
            if (vetInfo.Veterinarian_Information__r.Primary__c) {
                Id vetId = vetInfo.Veterinarian_Information__c;
                String email = vetInfo.Veterinarian_Information__r.Veterinarian_Email__c;
                
                VetSignerWrapper vetWrapper = new VetSignerWrapper(vetInfo.Veterinarian_Information__r);
                if (existingPrimaryVetSignaturesByEmail.containsKey(email)) {
                    vetWrapper.cloneTags(existingPrimaryVetSignaturesByEmail.get(email));
                }
                else {
                    // Set Signature Tag # based on the order of emails in the Agreement
                    generateSignatureAndDateTag(vetWrapper, signatureCounter++);
                    existingPrimaryVetSignaturesByEmail.put(email, vetWrapper);
                }

                shipAddressVet.primaryVet = vetWrapper;
            }
            else {
                shipAddressVet.additionalVets.add(vetInfo.Veterinarian_Information__r);
            }
        }

        return shipAddressVetsByAddressId.values();
    }
    
    /**
     * Set additional fields based on the Lead record
     * @param leadIdSet 
     */
    private void setCustomLeadFields(Set<Id> leadIdSet) {
        List<Lead> leadList = leadsSelector.selectNOALeadsById(leadIdSet);
        
        // Default rxForm to false in case no Lead record is passed in
        this.rxForm = false;
        
        // Only one Lead should be returned
        for(Lead queriedLead : leadList){
            if(queriedLead.Customer_Sub_Type__c !=null){
                this.whatYourBusinessDoes = queriedLead.Customer_Type__c +' - '+queriedLead.Customer_Sub_Type__c;
            } else{
                this.whatYourBusinessDoes = queriedLead.Customer_Type__c;
            }

            this.billingAddress = String.format('{0}, {1} {2} {3}',
                new List<String> {queriedLead.Billing_Street_1__c, queriedLead.Billing_City__c,
                    queriedLead.Billing_State__c,queriedLead.Billing_Zip_Code__c});

            List<String> doesBusinessWithList = new List<string>();

            for (Schema.SObjectField businessCheckbox : businessCheckboxes) {
                if ((Boolean)queriedLead.get(businessCheckbox)) {
                    doesBusinessWithList.add(businessCheckbox.getDescribe().getLabel().replace('Business', '').trim());
                }
            }

            this.animalsYourBusinessWorksWith = String.join(doesBusinessWithList, ', ');

            this.rxForm = queriedLead.RecordTypeId ==  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        }
    }

    /**
     * Generates the Adobe eSign Signature Tag and Date Tag for the passed in Signer 
     * @param signWrapper 
     * @param signatureCounter 
     */
    private void generateSignatureAndDateTag(Signer signWrapper, integer signatureCounter) {
        signWrapper.signatureTag = String.format('\'{{\'O{0}_es_:signer{0}:signature\'}}\'', new List<Object> {signatureCounter});
        signWrapper.dateTag = String.format('\'{{\'Date{0}_es_:signer{0}:date\'}}\'', new List<Object> {signatureCounter});
        
    }

    // Helper class for storing Address and their index
    public class AddressWrapper{
        public Address__c address{get;set;}
        public Integer counter{get;set;}
       
        public AddressWrapper(Address__c address,Integer counter){
            this.address = address;
            this.counter = counter;
        }
    }

    // Helper class for storing a Financially Authorized Person and their Signature information
    public class FinancialSigner extends Signer {
        public String name {get; set;}

        public FinancialSigner(NOA_Financially_Authorized_Person__c financialPerson) {
            this.name = String.format('{0} {1}', new List<String>{financialPerson.First_Name__c, financialPerson.Last_Name__c});
        }
    }
    
    // Helper class for the Vets by Address at the bottom of the page
    public class ShipAddressVetWrapper {
        public String addressName {get; private set;}
        public String addressStreet {get; private set;}
        public String addressCity {get; private set;}
        public String facilityStateLicense {get; private set;}
        public String facilityDEA {get; private set;}
        public VetSignerWrapper primaryVet {get; set;}
        public List<Veterinarian_Information__c> additionalVets {get; set;}
        
        public ShipAddressVetWrapper(String addressName, String addressStreet, String addressCity, String facilityStateLicense, String facilityDEA){
            this.addressName = addressName;
            this.addressStreet = addressStreet;
            this.addressCity = addressCity;
            this.facilityStateLicense = facilityStateLicense;
            this.facilityDEA = facilityDEA;
            this.additionalVets = new List<Veterinarian_Information__c>();
        }
    }

    // Helper class for storing a Vet and their Signature information
    public class VetSignerWrapper extends Signer {
        public Veterinarian_Information__c vet {get; private set;}

        public VetSignerWrapper (Veterinarian_Information__c vet) {
            this.vet = vet;
        }
    }

    // Helper class for storing Signature Tag and Date Tag
    public abstract class Signer {
        public String signatureTag {get; set;}
        public String dateTag {get; set;}

        public void cloneTags(Signer otherSigner) {
            this.signatureTag = otherSigner.signatureTag;
            this.dateTag = otherSigner.dateTag;
        }
    }
}