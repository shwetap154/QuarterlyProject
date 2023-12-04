/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 07-28-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   6-22-2023    Padma Nerella @ Zoetis Inc  Added sendNewOnlineAccountSignatureTest1 TPDEV-1070
* 1.2   6-26-2023    Padma Nerella @ Zoetis Inc  Added test methods to cover Exception
* 1.3   7-11-2023    Padma Nerella @ Zoetis Inc  Add generateNewOnlineAccountPDFTest method TPDEV-1268
* 1.4   7-27-2023    Ethan Hirsch @ Zoetis Inc   Add a test for retrieveNOAExemptSignedAccounts
* 1.5   7-27-2023    Padma Nerella @ Zoetis Inc  Add Financially Authorized Person record to send email to signature and modfied setup method with Vet owner and FinanciallyAuth owner
* 1.6   8-23-2023    Padma Nerella @ Zoetis Inc  Add test methods to test Recipient list on the Agreement record TPDEV-1832
* 1.7   8-29-2023    Padma Nerella @ Zoetis Inc  Add test method to test Recipient list contains emails of primary Financially Authorized Person on the Agreement
* 1.8   9-05-2023    Padma Nerella @ Zoetis Inc  Removed lead status update from Pending Exton Verification TPDEV-1885
**/
@isTest
private class NOALeadsServiceTest {
    
    @TestSetup
    static void setup() {
        
        
        List<Lead> noaLead = TestDataFactory.createLeadRec(4);
        noaLead[0].FirstName='lead';
        noaLead[0].LastName='leadLast';
        noaLead[0].Business_Name__c ='Petco 1773 FT Myers Hospital';
        noaLead[1].FirstName='lead1';
        noaLead[1].LastName='leadLast1';
        noaLead[1].Business_Name__c ='businessname';
        noaLead[2].FirstName='lead2';
        noaLead[2].LastName='leadLast2';
        noaLead[2].Business_Name__c ='businessname2';
        noaLead[3].FirstName='lead3';
        noaLead[3].LastName='leadLast3';
        noaLead[3].Business_Name__c ='businessname2';
        insert noaLead;
        
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonInsertList = new List<NOA_Financially_Authorized_Person__c>();
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonList1 = TestDataFactory.createFinanciallyAuthorizedPerson(1,noaLead[0].Id);
        noaFinanciallyAuthPersonList1[0].Email__c = 'noaAuth@Zoetis.com';
        noaFinanciallyAuthPersonList1[0].Primary__c =true;
        noaFinanciallyAuthPersonInsertList.addAll(noaFinanciallyAuthPersonList1);
        
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonList2 = TestDataFactory.createFinanciallyAuthorizedPerson(2,noaLead[1].Id);
        noaFinanciallyAuthPersonList2[0].Email__c = 'noaAuth1@Zoetis.com';
        noaFinanciallyAuthPersonList2[0].Primary__c =true;
        noaFinanciallyAuthPersonList2[1].Email__c = 'noaAuth2@Zoetis.com';
        noaFinanciallyAuthPersonList2[1].Primary__c =true;
        noaFinanciallyAuthPersonInsertList.addAll(noaFinanciallyAuthPersonList2);
        
        List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonList3 = TestDataFactory.createFinanciallyAuthorizedPerson(1,noaLead[3].Id);
        noaFinanciallyAuthPersonList3[0].Email__c = 'noaAuth1@Zoetis.com';
        noaFinanciallyAuthPersonList3[0].Primary__c =false;
        noaFinanciallyAuthPersonInsertList.addAll(noaFinanciallyAuthPersonList3);
       
        
        insert noaFinanciallyAuthPersonInsertList;
        List<Veterinarian_Information__c> vetInsertList = new List<Veterinarian_Information__c>();
        Veterinarian_Information__c vetInfoRec = TestDataFactory.createVetInformationRec(noaLead[0].Id);
        vetInfoRec.Veterinarian_Email__c = 'testvet1@Zoetis.com';
        vetInfoRec.Primary__c =true;
        vetInsertList.add(vetInfoRec);
        
        Veterinarian_Information__c vetInfoRec1 = TestDataFactory.createVetInformationRec(noaLead[1].Id);
        vetInfoRec1.Veterinarian_Email__c = 'testvet2@Zoetis.com';
        vetInfoRec1.Primary__c =true;
        vetInsertList.add(vetInfoRec1);
        
        Veterinarian_Information__c vetInfoRec2 = TestDataFactory.createVetInformationRec(noaLead[2].Id);
        vetInfoRec2.Veterinarian_Email__c = 'testvet3@Zoetis.com';
        vetInfoRec2.Primary__c =true;
        vetInsertList.add(vetInfoRec2);
        insert vetInsertList;
        
        String name = 'NOALeadDM';
        List<echosign_dev1__SIGN_Data_Mapping__c> echoSignList = new List<echosign_dev1__SIGN_Data_Mapping__c>();
        echosign_dev1__SIGN_Data_Mapping__c echoSignDataMapping1 =TestDataFactory.createEchoSigndev1SignDataMapping(name);
        echoSignList.add(echoSignDataMapping1);
        insert echoSignList;
    }
    
    @isTest
    static void sendNewOnlineAccountSignatureTest1(){
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        Set<String> noaAppNumString = new Set<String>();
        Date submittedDate = System.today();
        Set<Id> leadIdSet = new Set<Id>();
        for(lead ld:leadList){
            noaAppNumString.add(ld.NOA_Application_Number__c);
            leadIdSet.add(ld.id);
        }
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        Test.startTest();
        sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumString);
        Test.stopTest();
        List<Lead> updateLeadList = [Select Id,Name,NOA_Application_Number__c,Status,Signature_Status__c,Current_Status__c,Submitted_Date__c from Lead where Id=:leadIdSet];
        for(Lead ld:updateLeadList){
            Assert.areEqual('Submitted', ld.Current_Status__c, 'Current Status updated successfully for this LeadId: '+ld.id);
            Assert.areEqual('Out for Signature', ld.Signature_Status__c, 'Signature Status updated successfully for this LeadId: '+ld.id);
        }
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id from echosign_dev1__SIGN_Agreement__c where Lead__c=:updateLeadList];
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignList){
            System.assert(sendNewOnlineAccountSignature.containsKey(echo.Lead__r.NOA_Application_Number__c),'ReturnResponseBody contains Key:'+echo.Lead__r.NOA_Application_Number__c);
            System.assertEquals(echo.Id, sendNewOnlineAccountSignature.get(echo.Lead__r.NOA_Application_Number__c), 'ReturnResponseBody contains Value:'+echo.Id);
        }
        Assert.areEqual(4, echoSignList.size(), '3 echosign_dev1__SIGN_Agreement records are successfully created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(4,attachmentlist.size(), '3 attachment records got successfully created');
    }
    
    @isTest
    static void sendNewOnlineAccountSignatureEchosignAgrrementForceExceptionTest(){
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        Set<String> noaAppNumString = new Set<String>();
        for(lead ld:leadList){
            noaAppNumString.add(ld.NOA_Application_Number__c);
        }
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        NOALeadsService.forceExceptionEchoSignDev1AgrrementCreation =true;
        Boolean errorOccurred =false;
        try{
            Test.startTest();
            sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumString);
            Test.stopTest();
        } catch(Exception e){
            errorOccurred =true;
        }
        System.assert(errorOccurred);
        List<Lead> leadList1 = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead where Status ='Pending Exton Verification'];
        Assert.areEqual(0, leadList1.size(), 'Lead records did not get updated since User record did not meet the criteria to insert echosign_dev1__SIGN_Agreement__c record');
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id from echosign_dev1__SIGN_Agreement__c where Lead__c=:leadList1];
        Assert.areEqual(0, echoSignList.size(), 'echosign_dev1__SIGN_Agreement records did not get created since User record did not meet the criteria to insert record');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(0,attachmentlist.size(), 'Attachment records did not get created since User record did not meet the criteria to insert record');
    }
    
    @isTest
    static void sendNewOnlineAccountSignatureAttachmentcreationForceExceptionTest(){
        
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        Set<String> noaAppNumString = new Set<String>();
        for(lead ld:leadList){
            noaAppNumString.add(ld.NOA_Application_Number__c);
        }
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        NOALeadsService.forceExceptionAttachmentcreation=true;
        Boolean errorOccurred =false;
        try{
            Test.startTest();
            sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumString);
            Test.stopTest();
        } catch(Exception e){
            errorOccurred=true;
        }
        System.assert(errorOccurred);
        List<Lead> leadList1 = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead where Status ='Pending Exton Verification'];
        Assert.areEqual(0, leadList1.size(), 'Lead records did not get updated');
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id from echosign_dev1__SIGN_Agreement__c where Lead__c=:leadList1];
        Assert.areEqual(0, echoSignList.size(), 'echosign_dev1__SIGN_Agreement records did not get created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(0,attachmentlist.size(), 'Attachment records did not get created');
    }
    
    @isTest
    static void sendNewOnlineAccountSignatureLeadUpdateForceExceptionTest(){
        
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        Set<String> noaAppNumString = new Set<String>();
        for(lead ld:leadList){
            noaAppNumString.add(ld.NOA_Application_Number__c);
        }
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        NOALeadsService.forceExceptionLeadUpdate=true;
        Boolean errorOccurred =false;
        try{
            Test.startTest();
            sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumString);
            Test.stopTest();
        } catch(Exception e){
            errorOccurred =true;
        }
        System.assert(errorOccurred);
        List<Lead> leadList1 = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead where Status ='Pending Exton Verification'];
        Assert.areEqual(0, leadList1.size(), 'Lead records did not get updated');
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id from echosign_dev1__SIGN_Agreement__c where Lead__c=:leadList1];
        Assert.areEqual(0, echoSignList.size(), 'echosign_dev1__SIGN_Agreement records did not get created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(0,attachmentlist.size(), 'Attachment records did not get created');
    }
    
    @isTest
    static void generateNewOnlineAccountPDFTest(){
        List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c From Lead];
        Set<String> noaAppNumSet = new Set<String>();
        for(lead ld:leadList){
            noaAppNumSet.add(ld.NOA_Application_Number__c);
        }
        Map<String,Blob> generatPDFWithAppNumMap = new Map<String,Blob>();
        Test.startTest();
        generatPDFWithAppNumMap = NOALeadsService.generateNewOnlineAccountPDF(noaAppNumSet);
        Test.stopTest();
        Assert.areEqual(4, generatPDFWithAppNumMap.size());
        for(Lead ld:leadList){
            System.assert(generatPDFWithAppNumMap.containsKey(ld.NOA_Application_Number__c),'ReturnResponseBody contains Key:'+ld.NOA_Application_Number__c);
        }
    }

    @isTest
    static void retrieveNOAExemptSignedAccountsTest() {
        Test.startTest();
            Set<String> NOAaccountNameSet = NOALeadsService.retrieveNOAExemptSignedAccounts();
        Test.stopTest();

        Map<String, NOA_Accounts_Exempt__mdt> NOAaccountMetaData = NOA_Accounts_Exempt__mdt.getAll();
        System.assertEquals(NOAaccountMetaData.size(), NOAaccountNameSet.size(),
            'More/Less Names were returned from retrieveNOAExemptSignedAccounts');
    }
    
     @isTest
    static void sendNewOnlineAccountSignatureAgrrementEmailListWithCustomMetadataBusinessName(){
       List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c,FirstName From Lead where FirstName='lead'];
        Set<String> noaAppNumSet = new Set<String>();
        for(lead ld:leadList){
            noaAppNumSet.add(ld.NOA_Application_Number__c);
        }
        List<Veterinarian_Information__c> vetEmailList = [Select Id,Veterinarian_Email__c,Lead__c from Veterinarian_Information__c where Lead__c=:leadList[0].Id ORDER BY Id];
        Set<String> vetEmailSet = new Set<String>();
        for(Veterinarian_Information__c vet:vetEmailList){
            vetEmailSet.add(String.valueOf(vet.Veterinarian_Email__c));
        }
        String allRecipients;
        allRecipients = String.join(vetEmailSet, ',');
        allRecipients = allRecipients.removeEnd(',');
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        Test.startTest();
        sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumSet);
        Test.stopTest();
        List<Lead> updateLeadList = [Select Id,Name,NOA_Application_Number__c,Status,Signature_Status__c,Current_Status__c,Submitted_Date__c from Lead where NOA_Application_Number__c =:noaAppNumSet];
        for(Lead ld:updateLeadList){
            Assert.areEqual('Submitted', ld.Current_Status__c, 'Current Status updated successfully for this LeadId: '+ld.id);
            Assert.areEqual('Out for Signature', ld.Signature_Status__c, 'Signature Status updated successfully for this LeadId: '+ld.id);
        }
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id,echosign_dev1__Recipient_Addresses__c from echosign_dev1__SIGN_Agreement__c where Lead__c=:updateLeadList];
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignList){
            System.assert(sendNewOnlineAccountSignature.containsKey(echo.Lead__r.NOA_Application_Number__c),'ReturnResponseBody contains Key:'+echo.Lead__r.NOA_Application_Number__c);
            System.assertEquals(echo.Id, sendNewOnlineAccountSignature.get(echo.Lead__r.NOA_Application_Number__c), 'ReturnResponseBody contains Value:'+echo.Id);
            Assert.areEqual(allRecipients,echo.echosign_dev1__Recipient_Addresses__c,'Echo sign agreement sent only to Primary Vet since lead business name matches to NOA_Accounts_Exempt__mdt entity name');
        }
        Assert.areEqual(1, echoSignList.size(), '1 echosign_dev1__SIGN_Agreement records are successfully created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(1,attachmentlist.size(), '1 attachment records got successfully created');
    }
    
    @isTest
    static void sendNewOnlineAccountSignatureAgrrementEmailListWithOutCustomMetadataBusinessName(){
       List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c,FirstName From Lead where FirstName='lead1'];
        Set<String> noaAppNumSet = new Set<String>();
        for(lead ld:leadList){
            noaAppNumSet.add(ld.NOA_Application_Number__c);
        }
        List<Veterinarian_Information__c> vetEmailList = [Select Id,Veterinarian_Email__c,Lead__c from Veterinarian_Information__c where Lead__c=:leadList[0].Id ORDER BY Id];
        List<NOA_Financially_Authorized_Person__c> authEmailList = [Select Id,Email__c,Lead__c from NOA_Financially_Authorized_Person__c where Lead__c=:leadList[0].Id ORDER BY Id];
        Set<String> vetEmailSet = new Set<String>();
        Set<String> financiallyAuthEmailSet = new Set<String>();
        for(Veterinarian_Information__c vet:vetEmailList){
            vetEmailSet.add(String.valueOf(vet.Veterinarian_Email__c));
        }
        for(NOA_Financially_Authorized_Person__c auth:authEmailList){
            financiallyAuthEmailSet.add(String.valueOf(auth.Email__c));
        }
        
        String allRecipients;
        allRecipients = String.join(financiallyAuthEmailSet,',') + ',' + String.join(vetEmailSet, ',');
        allRecipients = allRecipients.removeEnd(',');
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        Test.startTest();
        sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumSet);
        Test.stopTest();
        List<Lead> updateLeadList = [Select Id,Name,NOA_Application_Number__c,Status,Signature_Status__c,Current_Status__c,Submitted_Date__c from Lead where NOA_Application_Number__c =:noaAppNumSet];
        for(Lead ld:updateLeadList){
            Assert.areEqual('Submitted', ld.Current_Status__c, 'Current Status updated successfully for this LeadId: '+ld.id);
            Assert.areEqual('Out for Signature', ld.Signature_Status__c, 'Signature Status updated successfully for this LeadId: '+ld.id);
        }
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id,echosign_dev1__Recipient_Addresses__c from echosign_dev1__SIGN_Agreement__c where Lead__c=:updateLeadList];
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignList){
            System.assert(sendNewOnlineAccountSignature.containsKey(echo.Lead__r.NOA_Application_Number__c),'ReturnResponseBody contains Key:'+echo.Lead__r.NOA_Application_Number__c);
            System.assertEquals(echo.Id, sendNewOnlineAccountSignature.get(echo.Lead__r.NOA_Application_Number__c), 'ReturnResponseBody contains Value:'+echo.Id);
            Assert.areEqual(allRecipients,echo.echosign_dev1__Recipient_Addresses__c,'Echo sign agreement sent all finanacially Auth Persons and all Primary Vets since lead business name does not matches to NOA_Accounts_Exempt__mdt entity name');
        }
        Assert.areEqual(1, echoSignList.size(), '1 echosign_dev1__SIGN_Agreement records are successfully created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(1,attachmentlist.size(), '1 attachment records got successfully created');
    }
    
    @isTest
    static void sendNewOnlineAccountSignatureAgrrementEmailListWithOutFinanciallyAuthPerson(){
       List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c,FirstName From Lead where FirstName='lead2'];
       List<Veterinarian_Information__c> vetEmailList = [Select Id,Veterinarian_Email__c,Lead__c from Veterinarian_Information__c where Lead__c=:leadList[0].Id ORDER BY Id];
        Set<String> noaAppNumSet = new Set<String>();
        for(lead ld:leadList){
            noaAppNumSet.add(ld.NOA_Application_Number__c);
        }
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        Set<String> vetEmailSet = new Set<String>();
        for(Veterinarian_Information__c vet:vetEmailList){
            vetEmailSet.add(String.valueOf(vet.Veterinarian_Email__c));
        }
        String allRecipients;
        allRecipients = String.join(vetEmailSet, ',');
        allRecipients = allRecipients.removeEnd(',');
        Test.startTest();
        sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumSet);
        Test.stopTest();
        List<Lead> updateLeadList = [Select Id,Name,NOA_Application_Number__c,Status,Signature_Status__c,Current_Status__c,Submitted_Date__c from Lead where NOA_Application_Number__c =:noaAppNumSet];
        for(Lead ld:updateLeadList){
            Assert.areEqual('Submitted', ld.Current_Status__c, 'Current Status updated successfully for this LeadId: '+ld.id);
            Assert.areEqual('Out for Signature', ld.Signature_Status__c, 'Signature Status updated successfully for this LeadId: '+ld.id);
        }
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id,echosign_dev1__Recipient_Addresses__c from echosign_dev1__SIGN_Agreement__c where Lead__c=:updateLeadList];
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignList){
            System.assert(sendNewOnlineAccountSignature.containsKey(echo.Lead__r.NOA_Application_Number__c),'ReturnResponseBody contains Key:'+echo.Lead__r.NOA_Application_Number__c);
            System.assertEquals(echo.Id, sendNewOnlineAccountSignature.get(echo.Lead__r.NOA_Application_Number__c), 'ReturnResponseBody contains Value:'+echo.Id);
            Assert.areEqual(allRecipients,echo.echosign_dev1__Recipient_Addresses__c,'Echo sign agreement sent only to Primary Vet since there are no Fianancially Auth persons for Daignostic lead and lead business name does not match to NOA_Accounts_Exempt__mdt entity name');
        }
        Assert.areEqual(1, echoSignList.size(), '1 echosign_dev1__SIGN_Agreement records are successfully created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(1,attachmentlist.size(), '1 attachment records got successfully created');
    }
    
    @isTest
    static void NonPrimaryAuthPersonSendNewOnlineAccountSignatureTest(){
       List<Lead> leadList = [Select Id,Name,NOA_Application_Number__c,Email,Company,Signature_Status__c,Status,Current_Status__c,Submitted_Date__c,FirstName From Lead where FirstName='lead3'];
       Set<String> noaAppNumSet = new Set<String>();
        for(lead ld:leadList){
            noaAppNumSet.add(ld.NOA_Application_Number__c);
        }
        List<NOA_Financially_Authorized_Person__c> authEmailList = [Select Id,Email__c,Lead__c from NOA_Financially_Authorized_Person__c where Lead__c=:leadList[0].Id ORDER BY Id];
        Set<String> financiallyAuthEmailSet = new Set<String>();
        for(NOA_Financially_Authorized_Person__c auth:authEmailList){
            financiallyAuthEmailSet.add(String.valueOf(auth.Email__c));
        }
        
        String allRecipients;
        allRecipients = String.join(financiallyAuthEmailSet,',');
        allRecipients = allRecipients.removeEnd(',');
        Map<String, Id> sendNewOnlineAccountSignature = new Map<String, Id>();
        Test.startTest();
        sendNewOnlineAccountSignature = NOALeadsService.sendNewOnlineAccountSignature(noaAppNumSet);
        Test.stopTest();
        List<Lead> updateLeadList = [Select Id,Name,NOA_Application_Number__c,Status,Signature_Status__c,Current_Status__c,Submitted_Date__c from Lead where NOA_Application_Number__c =:noaAppNumSet];
        for(Lead ld:updateLeadList){
            Assert.areEqual('Submitted', ld.Current_Status__c, 'Current Status updated successfully for this LeadId: '+ld.id);
            Assert.areEqual('Out for Signature', ld.Signature_Status__c, 'Signature Status updated successfully for this LeadId: '+ld.id);
        }
        List<echosign_dev1__SIGN_Agreement__c> echoSignList = [Select Id, Name,Lead__c,Lead__r.NOA_Application_Number__c,Lead__r.Id,echosign_dev1__Recipient_Addresses__c from echosign_dev1__SIGN_Agreement__c where Lead__c=:updateLeadList];
        for(echosign_dev1__SIGN_Agreement__c echo:echoSignList){
            System.assert(sendNewOnlineAccountSignature.containsKey(echo.Lead__r.NOA_Application_Number__c),'ReturnResponseBody contains Key:'+echo.Lead__r.NOA_Application_Number__c);
            System.assertEquals(echo.Id, sendNewOnlineAccountSignature.get(echo.Lead__r.NOA_Application_Number__c), 'ReturnResponseBody contains Value:'+echo.Id);
            Assert.areEqual(null,echo.echosign_dev1__Recipient_Addresses__c,'Echo sign agreement did not sent to any finanacially Auth Persons since there are no Primary Auth persons');
        }
        Assert.areEqual(1, echoSignList.size(), '1 echosign_dev1__SIGN_Agreement records are successfully created');
        List<Attachment> attachmentlist = [Select Id,Name,description,parentId From Attachment where parentId=:echoSignList];
        Assert.areEqual(1,attachmentlist.size(), '1 attachment records got successfully created');
    }
}