/**
 * @description       : Test class for NOA_FInalFOrmPDFV2Controller
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-28-2023   Ethan Hirsch @ Zoetis Inc   Initial Version TPDEV-1079
 * 1.1   08-17-2023   Padma Nerella @ Zoetis Inc  Add Signature and date tags to be generated with two curly braces TPDEV-1809
 * 1.2   08-31-2023   Padma Nerella @ Zoetis Inc  Add Signature test for Nonprimary and Primary Financially Authorized Person TPDEV-1865
**/
@isTest
private class NOA_FinalFormPDFV2ControllerTest {
    private static final String leadNoDataLastName = 'NoData';
    private static final String leadFullDataLastName = 'FulLData';
    private static final String leadWithExemptSignatureLastName = 'ExemptSignature';
    private static final Integer maxRecordsForFullData = 5;

    @TestSetup
    private static void setup(){
        Lead leadNoData = TestDataFactory.createLeadRec(1)[0];
        leadNoData.LastName = leadNoDataLastName;

        Lead leadFullData = TestDataFactory.createLeadRec(1)[0];
        leadFullData.LastName = leadFullDataLastName;
        leadFullData.Customer_Type__c = 'Pet Owner';
        leadFullData.Customer_Sub_Type__c = 'Reproductive Services';
        leadFullData.Billing_Street_1__c = '555 Main St.';
        leadFullData.Billing_City__c = 'Chicago';
        leadFullData.Billing_State__c = 'IL';
        leadFulLData.Billing_Zip_Code__c = '60606';
        leadFullData.Beef_Business__c = true;
        leadFullData.Cats_Business__c = true;
        leadFullData.Horses_Business__c = true;
        leadFullData.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        
        Lead leadExemptFromSignature = TestDataFactory.createLeadRec(1)[0];
        leadExemptFromSignature.Business_Name__c = NOA_Accounts_Exempt__mdt.getAll().values()[0].Entity_Name__c;
        leadExemptFromSignature.LastName = leadWithExemptSignatureLastName;

        insert new List<Lead> {
            leadNoData,
            leadFullData,
            leadExemptFromSignature
        };

        List<Address__c> fullDataAddresses = TestDataFactory.createAddresses(maxRecordsForFullData, null);
        for (Integer i = 0; i < fullDataAddresses.size(); i++) {
            Address__c address = fullDataAddresses[i];
            address.Lead__c = leadFullData.Id;
            address.Source_Address_Name__c = String.format('Address {0}', new List<object> {i});
            address.ZTS_Address_Line_1__c = String.format('{0} Main St.', new List<object> {i});
            address.ZTS_EU_City__c = String.format('Test City{0}', new List<object> {i});
            address.Facility_State_Veterinary_License__c = String.format('F{0}', new List<object> {i});
            address.Facility_DEA_License__c = String.format('D{0}', new List<object> {i});
        }

        Address__c exemptSignatureAddress = TestDataFactory.createAddresses(1, null)[0];
        exemptSignatureAddress.Lead__c = leadExemptFromSignature.Id;

        List<Address__C> allAddresses = new List<Address__C>();
        allAddresses.addAll(fullDataAddresses);
        allAddresses.add(exemptSignatureAddress);
        insert allAddresses;

        List<NOA_Financially_Authorized_Person__c> fullDatafinancialPersons = TestDataFactory.createFinanciallyAuthorizedPerson(
            maxRecordsForFullData, leadFullData.Id);

        for (integer i = 0; i < fullDatafinancialPersons.size(); i++) {
            Integer emailCounter = i;

            // Set the last email to the same as the first to test duplicate email signer logic
            if (i == fullDatafinancialPersons.size() - 1) {
                emailCounter = 0;
            }
            fullDatafinancialPersons[i].Email__c = String.format('testfp{0}@zoetis.com', new List<Object> {i});
            fullDatafinancialPersons[i].Primary__c=true;
        }

        NOA_Financially_Authorized_Person__c exemptSignatureFinancialPerson = TestDataFactory.createFinanciallyAuthorizedPerson(
            1, leadExemptFromSignature.Id)[0];

        exemptSignatureFinancialPerson.Email__c = 'single-email@zoetis.com';
        exemptSignatureFinancialPerson.Primary__c=true;

        List<NOA_Financially_Authorized_Person__c> allFinancialPersons = new List<NOA_Financially_Authorized_Person__c>();
        allFinancialPersons.addAll(fullDatafinancialPersons);
        allFinancialPersons.add(exemptSignatureFinancialPerson);

        insert allFinancialPersons;

        List<Veterinarian_Information__c> allVets = new List<Veterinarian_Information__c>();
        for (integer i = 0; i < maxRecordsForFullData; i++) {
            Veterinarian_Information__c vetInformation = TestDataFactory.createVetInformationRec(leadFullData.Id);
            vetInformation.Primary__c = true;
            
            if (i == 0 || i == 2) {
                vetInformation.Veterinarian_Email__c = fullDatafinancialPersons[i].Email__c;
            }
            else if (i == 4) {
                vetInformation.Veterinarian_Email__c = allVets[1].Veterinarian_Email__c;
            }
            else {
                vetInformation.Veterinarian_Email__c = String.format('vetemail{0}@zoetis.com', new List<Object> {i});
            }

            allVets.add(vetInformation);
        }

        // Add non-primary vets. Add double so each Address has 2
        for (integer i = 0; i < maxRecordsForFullData * 2; i++) {
            Veterinarian_Information__c vetInformation = TestDataFactory.createVetInformationRec(leadFullData.Id);
            allVets.add(vetInformation);
        }
        
        Veterinarian_Information__c exemptSignatureVetInformation = TestDataFactory.createVetInformationRec(leadExemptFromSignature.Id);
        exemptSignatureVetInformation.Veterinarian_Email__c = exemptSignatureFinancialPerson.EMail__c;
        exemptSignatureVetInformation.Primary__c = true;
        allVets.add(exemptSignatureVetInformation);

        insert allVets;
        
        List<Vet_Information_Shipping_Address__c> vetShippingAddresses = new List<Vet_Information_Shipping_Address__c>();
        for (integer i = 0; i < maxRecordsForFullData ; i++) {
            Id addressId = fullDataAddresses[i].Id;
            vetShippingAddresses.add(TestDataFactory.createVetShippingAddress(allVets[i].Id, addressId));
            // Add Additional Vets to the same address
            vetShippingAddresses.add(TestDataFactory.createVetShippingAddress(allVets[i + maxRecordsForFullData].Id, addressId));
            vetShippingAddresses.add(TestDataFactory.createVetShippingAddress(allVets[i + maxRecordsForFullData * 2].Id, addressId));

        }

        vetShippingAddresses.add(TestDataFactory.createVetShippingAddress(exemptSignatureVetInformation.Id, exemptSignatureAddress.Id));

        insert vetShippingAddresses;

        List<ContentVersion> contentVersions = TestDataFactory.createContentVersion(maxRecordsForFullData,'Test Document','TestDocument.pdf','Test content',true);
        insert contentVersions;

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        for (ContentVersion file : [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id in: contentVersions]) {
            contentDocumentLinks.addAll(TestDataFactory.createContentDocumentLink(1,leadFullData.Id,file.ContentDocumentId,'I'));
        }

        insert contentDocumentLinks;

    }

    @isTest
    private static void constructor_NoLeadTest() {
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                new Lead()));
        Test.stopTest();

        assertNoControllerData(controller);
        
        Assert.isTrue(String.isBlank(controller.billingAddress), String.format(
            'Unexpected value in billingAddress: {0}', new List<Object> {controller.billingAddress}));
    }

    @isTest
    private static void constructor_LeadNoDataTest() {
        Lead testLead = retrieveLeadByLastName(leadNoDataLastName);
        
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();

        assertNoControllerData(controller);
    }

    @isTest
    private static void constructor_LeadWithFullData() {
        Lead testLead = retrieveLeadByLastName(leadFullDataLastName);

        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();

        // Assert Financially Authorized Persons
        // All lists are ordered by Id so that all lists are in parallel
        Map<String, NOA_FinalFormPDFV2Controller.Signer> signerByEmail = new Map<String, NOA_FinalFormPDFV2Controller.Signer>();
        Integer signatureCounter = 1;
        List<NOA_Financially_Authorized_Person__c> fullDatafinancialPersons = [
            SELECT Id, First_Name__c, Last_Name__c, Email__c
            FROM NOA_Financially_Authorized_Person__c
            WHERE Lead__c =: testLead.Id
            ORDER BY Id];
        
        Assert.areEqual(fullDatafinancialPersons.size(), controller.financiallyAuthPersonList.size(),
            'More/Less Financially Authorized Persons returned than expected.');

        for (Integer i = 0; i < fullDatafinancialPersons.size(); i++) {
            NOA_Financially_Authorized_Person__c financialPerson = fullDatafinancialPersons[i];
            Assert.areEqual(financialPerson.Id, controller.financiallyAuthPersonList[i].Id,
                'Financial Person not in the expected order or not returned as expected');
            
            NOA_FinalFormPDFV2Controller.FinancialSigner financialSigner = controller.financialSigners[i];

            String expectedName = String.format('{0} {1}', 
                new List<String>{financialPerson.First_Name__c, financialPerson.Last_Name__c});

            Assert.areEqual(expectedName, financialSigner.name);

            if (signerByEmail.containsKey(financialPerson.Email__c)) {
                NOA_FinalFormPDFV2Controller.Signer existingSigner = signerByEmail.get(financialPerson.Email__c);
                Assert.areEqual(existingSigner.signatureTag, financialSigner.signatureTag,
                    'Signature Tag not set as expected.');

                Assert.areEqual(existingSigner.dateTag, financialSigner.dateTag,
                    'Date Tag not set as expected.');
            } else {
                assertSignatureTag(signatureCounter, financialSigner.signatureTag);
                assertDateTag(signatureCounter, financialSigner.dateTag);
                
                signatureCounter += 1;

                signerByEmail.put(financialPerson.Email__c, financialSigner);
            }
        }

        // Order by Id to be in parallel with the controller
        List<Address__c> leadAddresses = [
            SELECT Id, Source_Address_Name__c, ZTS_Address_Line_1__c, ZTS_EU_City__c, 
                   Facility_State_Veterinary_License__c, Facility_DEA_License__c
            FROM Address__c
            WHERE Lead__c =: testLead.Id
            ORDER BY Id];

        Map<Id, Address__c> leadAddressMap = new Map<Id, Address__c>(leadAddresses);

        // Verify Addresses are returned correctly
        List<Id> foundAddressIds = new List<Id>();
        Assert.areEqual(leadAddressMap.size(), controller.addressList.size(), 'More/Less Addresses added than expected');
        for (integer i = 0; i < controller.addressList.size(); i++) {
            NOA_FinalFormPDFV2Controller.AddressWrapper addressWrapper = controller.addressList[i];
            Assert.areEqual(addressWrapper.counter, i + 1, 'Counter not set as expected.');

            Id addressId = addressWrapper.address.Id;
            Assert.isTrue(leadAddressMap.containsKey(addressId),
                String.format('Address {0} was not returned in the controller as expected.',
                new List<Object> {addressWrapper.address.Id}));

            foundAddressIds.add(addressWrapper.address.Id);
        }

        Set<Id> allAddressIds = leadAddressMap.keySet().clone();
        allAddressIds.removeAll(foundAddressIds);
        Assert.isTrue(allAddressIds.isEmpty(), 
            String.format('The following addresses were not returned properly: {0}',
            new List<String> {JSON.serialize(allAddressIds)}));

        // Assert Vet Information Shipping Address
        Assert.areEqual(leadAddressMap.size(), controller.shipAddressVetList.size(),
            'More/Less Ship Address Vets were created than expected');

        Map<Id, Veterinarian_Information__c> primaryVetByShippingAddress = new Map<Id, Veterinarian_Information__c>();
        Map<Id, Set<Id>> additionalVetIdsByShippingAddress = new Map<Id, Set<Id>>();
        // Order by Shipping_Address__c to parallel the controller
        for (Vet_Information_Shipping_Address__c vetShippingAddress :[
            SELECT Id, Shipping_Address__c, Veterinarian_Information__c, Veterinarian_Information__r.Primary__c,
            Veterinarian_Information__r.Veterinarian_Email__c
            FROM Vet_Information_Shipping_Address__c 
            WHERE Shipping_Address__c in: leadAddressMap.keySet()
            Order by Shipping_Address__c]) {
            Id addressId = vetShippingAddress.Shipping_Address__c;
            if (vetShippingAddress.Veterinarian_Information__r.Primary__c) {
                primaryVetByShippingAddress.put(addressId, vetShippingAddress.Veterinarian_Information__r);
            }
            else {
                if (!additionalVetIdsByShippingAddress.containsKey(addressId)) {
                    additionalVetIdsByShippingAddress.put(addressId, new Set<Id>());
                }

                additionalVetIdsByShippingAddress.get(addressId).add(vetShippingAddress.Veterinarian_Information__c);
            }
        }

        for (integer i = 0; i < controller.shipAddressVetList.size(); i++) {
            // Both lists should be in parallel as they are both ordered by Address Id
            NOA_FinalFormPDFV2Controller.ShipAddressVetWrapper shipAddressWrapper = controller.shipAddressVetList[i];
            Address__c address = leadAddresses[i];

            Assert.areEqual(address.Source_Address_Name__c, shipAddressWrapper.addressName,
                'Address name not set as expected.');

            Assert.areEqual(address.ZTS_Address_Line_1__c, shipAddressWrapper.addressStreet,
                'Address Street not set as expected.');

            Assert.areEqual(address.ZTS_EU_City__c, shipAddressWrapper.addressCity,
                'Address City not set as expected.');

            Assert.areEqual(address.Facility_State_Veterinary_License__c, shipAddressWrapper.facilityStateLicense,
                'Facility State LIcense not set as expected.');

            Assert.areEqual(address.Facility_DEA_License__c, shipAddressWrapper.facilityDEA,
                'Facility DEA License not set as expected.');

            Veterinarian_Information__c primaryVet = primaryVetByShippingAddress.get(address.Id);
            Assert.areEqual(primaryVet.Id, shipAddressWrapper.primaryVet.vet.Id, 'Primary Vet not set as expected');

            String primaryVetEmail = primaryVet.Veterinarian_Email__c;
            if (signerByEmail.containsKey(primaryVetEmail)) {
                NOA_FinalFormPDFV2Controller.Signer existingSigner = signerByEmail.get(primaryVetEmail);
                Assert.areEqual(existingSigner.signatureTag, shipAddressWrapper.primaryVet.signatureTag,
                    'Signature Tag not set as expected.');

                Assert.areEqual(existingSigner.dateTag, shipAddressWrapper.primaryVet.dateTag,
                    'Date Tag not set as expected.');
            }
            else {
                assertSignatureTag(signatureCounter, shipAddressWrapper.primaryVet.signatureTag);
                assertDateTag(signatureCounter, shipAddressWrapper.primaryVet.dateTag);

                signatureCounter += 1;

                signerByEmail.put(primaryVetEmail, shipAddressWrapper.primaryVet);
            }

            Assert.areEqual(2, shipAddressWrapper.additionalVets.size(),
                'More/Less Additional Vets returned than expected.');
            
            Set<Id> additionalVetIds = additionalVetIdsByShippingAddress.get(address.Id);
            additionalVetIds.removeAll(new Map<Id, Veterinarian_Information__c>(shipAddressWrapper.additionalVets).keySet());
            
            Assert.isTrue(additionalVetIds.isEmpty(), String.format('The following Vets were not added to address {0}: {1}',
                new List<Object>{address.Id, JSON.serialize(additionalVetIds)}));
        }

        // Assert fields
        String expectedWhatYourBusinessDoes = String.format('{0} - {1}', 
            new List<String> {testLead.Customer_Type__c, testLead.Customer_Sub_Type__c});

        Assert.areEqual(expectedWhatYourBusinessDoes, controller.whatYourBusinessDoes,
            'What your business does is not set as expected.');

        Assert.areEqual('Beef, Cats, Horses', controller.animalsYourBusinessWorksWith,
            'Animals your business works with not set as expected.');
        
        String expectedBillingAddress = String.format('{0}, {1} {2} {3}',
            new List<String> {testLead.Billing_Street_1__c, testLead.Billing_City__c,
                testLead.Billing_State__c,testLead.Billing_Zip_Code__c});

        Assert.areEqual(expectedBillingAddress, controller.billingAddress, 'Billing Address not set as expected.');

        Assert.isFalse(controller.downloadPdf, 'Download PDF not set as expected.');
        Assert.isTrue(controller.rxForm, 'RX Form not set as expected.');
        Assert.isFalse(controller.exemptFromSignature, 'Exempt from Signature not set as expected.');
    }

    @isTest
    private static void constructor_downloadPdfTrue() {
        Lead testLead = retrieveLeadByLastName(leadNoDataLastName);
        
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);
        ApexPages.currentPage().getParameters().put('downloadPdf', 'true');

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();

        Assert.isTrue(controller.downloadPdf, 'Download PDF not set as expected.');
    }

    @isTest
    private static void constructor_downloadPdfFalse() {
        Lead testLead = retrieveLeadByLastName(leadNoDataLastName);
        
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);
        ApexPages.currentPage().getParameters().put('downloadPdf', 'false');

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();

        Assert.isFalse(controller.downloadPdf, 'Download PDF not set as expected.');
    }

    @isTest
    private static void constructor_downloadPdfNonBoolean() {
        Lead testLead = retrieveLeadByLastName(leadNoDataLastName);
        
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);
        ApexPages.currentPage().getParameters().put('downloadPdf', 'Test');

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();

        Assert.isFalse(controller.downloadPdf, 'Download PDF not set as expected.');
    }

    @isTest
    private static void constructor_exemptFromSignatureTrue() {
        Lead testLead = retrieveLeadByLastName(leadWithExemptSignatureLastName);
        
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();

        Assert.isTrue(controller.exemptFromSignature, 'Exempt from Signature not set as expected.');

        Assert.areEqual(1, controller.financialSigners.size(), 'More/Less Financial Signers than expected.');
        Assert.isTrue(String.isBlank(controller.financialSigners[0].signatureTag),
            'Signature Tag of the Financial Signer should be blank');

        Assert.areEqual(1, controller.shipAddressVetList.size(), 'More/Less Ship Address Vets than expected.');

        NOA_FinalFormPDFV2Controller.ShipAddressVetWrapper shipAddressVet = controller.shipAddressVetList[0];
        assertSignatureTag(1, shipAddressVet.primaryVet.signatureTag);

        Assert.areEqual(controller.financiallyAuthPersonList[0].Email__c, shipAddressVet.primaryVet.vet.Veterinarian_Email__c,
            'Sanity check failed. Vet and Financially Authorized Person have different emails');
    }

    private static void assertNoControllerData(NOA_FinalFormPDFV2Controller controller) {
        Assert.isTrue(controller.addressList.isEmpty(), String.format('Unexpected values in addressList: {0}',
            new List<Object> {JSON.serialize(controller.addressList)}));

        Assert.isTrue(controller.shipAddressVetList.isEmpty(), String.format(
            'Unexpected values in shipAddressVetList: {0}',
            new List<Object> {JSON.serialize(controller.shipAddressVetList)}));
        
        Assert.isTrue(controller.financiallyAuthPersonList.isEmpty(), String.format(
            'Unexpected values in financiallyAuthPersonList: {0}',
            new List<Object> {JSON.serialize(controller.financiallyAuthPersonList)}));

        Assert.isTrue(controller.financialSigners.isEmpty(), String.format('Unexpected values in financialSigners: {0}',
            new List<Object> {JSON.serialize(controller.financialSigners)}));

        Assert.isTrue(controller.leadContentDocLinklist.isEmpty(), String.format(
            'Unexpected values in leadContentDocLinklist: {0}',
            new List<Object> {JSON.serialize(controller.leadContentDocLinklist)}));

        Assert.isTrue(controller.addressList.isEmpty(), String.format('Unexpected values in addressList: {0}',
            new List<Object> {JSON.serialize(controller.addressList)}));

        Assert.isTrue(String.isBlank(controller.whatYourBusinessDoes), String.format(
            'Unexpected value in whatYourBusinessDoes: {0}', new List<Object> {controller.whatYourBusinessDoes}));

        Assert.isTrue(String.isBlank(controller.animalsYourBusinessWorksWith), String.format(
            'Unexpected value in animalsYourBusinessWorksWith: {0}',
            new List<Object> {controller.animalsYourBusinessWorksWith}));

        Assert.isFalse(controller.downloadPdf, 'downloadPdf was set to true unexpectdly');
        
        Assert.isFalse(controller.rxForm, 'rxForm set to true unexpectdly');

        Assert.isFalse(controller.exemptFromSignature, 'exemptFromSignature set ot true unexpectdly');
    }

    private static Lead retrieveLeadByLastName(String lastName) {
        return [
            SELECT Id, LastName, Business_Name__c, Billing_Street_1__c, Billing_City__c, Billing_State__c,
                    Billing_Zip_Code__c, Customer_Type__c, Customer_Sub_Type__c
            FROM Lead
            WHERE LastName =: lastName
            LIMIT 1
        ];
    }

    private static void assertSignatureTag(Integer signatureCounter, String actualTag) {
        String expectedTag = String.format('\'{{\'O{0}_es_:signer{0}:signature\'}}\'', new List<Object> {signatureCounter});

        Assert.areEqual(expectedTag, actualTag, 'Signature Tag not set as expected');
    }

    private static void assertDateTag(Integer signatureCounter, String actualTag) {
        String expectedTag = String.format('\'{{\'Date{0}_es_:signer{0}:date\'}}\'', new List<Object> {signatureCounter});

        Assert.areEqual(expectedTag, actualTag, 'Date Tag not set as expected');
    }
   
    @isTest
    private static void nonPrimaryANDPrimaryFinanciallyAuthorizedPersonSignatureTest(){
        Lead testLead = retrieveLeadByLastName(leadFullDataLastName);
        Map<String, NOA_FinalFormPDFV2Controller.Signer> signerByEmail = new Map<String, NOA_FinalFormPDFV2Controller.Signer>();
        List<NOA_Financially_Authorized_Person__c> financialAuthPersonsList = [SELECT Id, First_Name__c, Last_Name__c, Email__c,Primary__c FROM NOA_Financially_Authorized_Person__c WHERE Lead__c =: testLead.Id
                                                                              ORDER BY Id];
        financialAuthPersonsList[0].Primary__c=False;
        update financialAuthPersonsList;
        Test.setCurrentPage(Page.NOA_FinalFormPDFV2);
        ApexPages.currentPage().getParameters().put('id', testLead.Id);

        Test.startTest();
            NOA_FinalFormPDFV2Controller controller = new NOA_FinalFormPDFV2Controller(new ApexPages.StandardController(
                testLead));
        Test.stopTest();
        List<NOA_Financially_Authorized_Person__c> financialAuthPersonsList1 = [SELECT Id, First_Name__c, Last_Name__c, Email__c,Primary__c FROM NOA_Financially_Authorized_Person__c WHERE Lead__c =: testLead.Id
                                                                              ORDER BY Id];
        Assert.areEqual(financialAuthPersonsList1.size(), controller.financiallyAuthPersonList.size(),'All financial Auth Persons are in the form');
        Integer signatureCounter =1;
        
        for (Integer i = 0; i < financialAuthPersonsList1.size(); i++) {
            if(financialAuthPersonsList1[i].Primary__c==true){
                NOA_Financially_Authorized_Person__c financialPerson = financialAuthPersonsList1[i];
                NOA_FinalFormPDFV2Controller.FinancialSigner financialSigner = controller.financialSigners[signatureCounter-1];
                String expectedName = String.format('{0} {1}', 
                                                    new List<String>{financialPerson.First_Name__c, financialPerson.Last_Name__c});
                Assert.areEqual(expectedName, financialSigner.name);
                assertSignatureTag(signatureCounter, financialSigner.signatureTag);
                assertDateTag(signatureCounter, financialSigner.dateTag);
                
                signatureCounter += 1;
                
                signerByEmail.put(financialPerson.Email__c, financialSigner);
            }
        }
        Assert.areEqual(4, signerByEmail.size(),'4 financialPersons signature ');
        
    }
}