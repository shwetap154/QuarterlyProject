/**
* @description       : Service class for Lead for New ONline Account Logic
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 08-31-2023
* @last modified by  : Morgan Marchese @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   6-22-2023    Padma Nerella @ Zoetis Inc  Initail version
* 1.1   7-10-2023    Padma Nerella @ Zoetis Inc  Add AccountSelector.enforceSecurity static boolean variable to 
                                                 avoid permission access to api user TPDev-1070
* 1.2   7-11-2023    Padma Nerella @ Zoetis Inc  Add generateNewOnlineAccountPDF to generate pdf TPDEV-1268
* 1.3   7-26-2023    Ethan Hirsch @ Zoetis Inc   Add retrieveNOAExemptSignedAccounts method to return NOA Exempt Accounts
                                                 in a single place for both the PDF Generation and Send for Signature logic TPDEV-1079
                                                 in a single place for both the PDF Generation and Send for Signature logic
* 1.4   7-27-2023    Padma Nerella @ Zoetis Inc  Modified the sendNewOnlineAccountSignature method to Request Signatures from 
                                                 all Financially Authorized Persons and Primary Vets only TPDEV-1546
* 1.5   7-28-2023    Ethan Hirsch @ Zoetis Inc   When generating NOA_FinalFOrmPDFV2, set downloadPdf depending on if 
                                                 the PDF is being generated to download or send through Adboe eSign TPDEV-1079
* 1.5   7-31-2023    Padma Nerella @ Zoetis Inc  Modified the batch job last param null to new User(Id =userInfo.getUserId())
* 1.6   8-22-2023    Padma Nerella @ Zoetis Inc  To avoid the first comma on Recipient list on the Agreement record TPDEV-1832 and also added removeEnd(',')
* 1.7   8-29-2023    Padma Nerella @ Zoetis Inc  Sending Agreement for adobe signature to only primary Financially Authorized Persons TPDEV-1865
* 1.8   9-05-2023    Padma Nerella @ Zoetis Inc  Removed lead status update from Pending Exton Verification TPDEV-1885
**/

public with sharing class NOALeadsService {
    
    @testVisible private static Boolean forceExceptionAttachmentcreation = false;
    @testVisible private static Boolean forceExceptionEchoSignDev1AgrrementCreation = false;
    @testVisible private static Boolean forceExceptionLeadUpdate = false;
    
    public static Map<String, Id> sendNewOnlineAccountSignature(Set<String> leadAppNumSet) {
        // Add AccountSelector.enforceSecurity to false to avoid permission access issues while sending api
        // request as a new online account api user and resetting this variable to true after executing this method
        AccountSelector.enforceSecurity = false;
        Savepoint sp = Database.setSavePoint();
        Map<String,Id> leadAgreementIdMap = new Map<String,Id>();
        try{

            Set<String> vetEmailSet = new Set<String>();
            Set<String> financiallyAuthEmailSet = new Set<String>();
            Set<Id> leadIdSet = new Set<Id>();
            List<Lead> leadIdwithAppNumList = LeadsSelector.SelectByNOAAppNumber(leadAppNumSet);
            for(Lead ld:leadIdwithAppNumList){
                leadIdSet.add(ld.Id);
            }
            Map<Id,Lead> leadMap = new Map<Id,Lead>(leadIdwithAppNumList);
            List<NOA_Financially_Authorized_Person__c> noaFinanciallyAuthPersonList = FinanciallyAuthorizedPersonSelector.selectByLeadId(leadIdSet);
            Map<Id,List<NOA_Financially_Authorized_Person__c>> noaFinanciallyAuthPersonMap = new Map<Id,List<NOA_Financially_Authorized_Person__c>>();
            for(NOA_Financially_Authorized_Person__c noaFinAuth : noaFinanciallyAuthPersonList){
                if (!noaFinanciallyAuthPersonMap.containsKey(noaFinAuth.Lead__c)) {
                    noaFinanciallyAuthPersonMap.put(noaFinAuth.Lead__c, new List<NOA_Financially_Authorized_Person__c>());
                } 
                noaFinanciallyAuthPersonMap.get(noaFinAuth.Lead__c).add(noaFinAuth);
            }
            List<Veterinarian_Information__c> vetInforList = VeterinarianInformationSelector.selectByLeadId(leadIdSet);
            Map<Id,List<Veterinarian_Information__c>> leadVetMap = new Map<Id,List<Veterinarian_Information__c>>(); 
            for(Veterinarian_Information__c vet:vetInforList){
                if (!leadVetMap.containsKey(vet.Lead__c)) {
                    leadVetMap.put(vet.Lead__c, new List<Veterinarian_Information__c>());
                } 
                
                leadVetMap.get(vet.Lead__c).add(vet);
            }
            String allRecipients;
            String echoSignDev1Name = 'NOALeadDM';
            Set<String> echoSigndev1NamesSet = new Set<String>{echoSignDev1Name};
            Set<String> userNames = new Set<String>{'New Online Account Site Guest User'};
            List<echosign_dev1__SIGN_Data_Mapping__c> echoSigndev1DataMappingList = Echosigndev1SignDataMappingsSelector.selectByName(echoSigndev1NamesSet);
            List<User> sendAsUsers = UsersSelector.selectByName(userNames);
            List<echosign_dev1__SIGN_Agreement__c> echoSignDev1AgreementToInsertList = new List<echosign_dev1__SIGN_Agreement__c>();
            
            List<Lead> leadList = LeadsSelector.selectNOALeadsById(leadIdSet);
            Set<String> NOAaccountNameSet = retrieveNOAExemptSignedAccounts();

            try {
                for(Lead leadrec : leadList){
                    echosign_dev1__SIGN_Agreement__c agmt = new echosign_dev1__SIGN_Agreement__c();
                    agmt.Name = 'Zoetis New Account Agreement - ' + leadrec.NOA_Application_Number__c;
                    agmt.Lead__c = leadrec.Id;
                    agmt.echosign_dev1__Signature_Flow__c = 'Any Order';

                    if(noaFinanciallyAuthPersonMap.containsKey(leadRec.Id)){
                        // If the Account is exempt from requiring Financially Authorized Signatures
                        // then we don't bother looping the list.
                        if(!NOAaccountNameSet.contains(leadrec.Business_Name__c)){
                            for(NOA_Financially_Authorized_Person__c finAuth :noaFinanciallyAuthPersonMap.get(leadRec.Id)){
                                if(finAuth.Primary__c ==true){
                                    financiallyAuthEmailSet.add(String.valueOf(finAuth.Email__c));
                                }
                            }
                        }
                    }
                    
                    if(leadVetMap.containsKey(leadRec.Id)){
                        for(Veterinarian_Information__c vi:leadVetMap.get(leadRec.Id)){
                            if(!financiallyAuthEmailSet.contains(vi.Veterinarian_Email__c) && vi.Primary__c ==true){
                                vetEmailSet.add(String.valueOf(vi.Veterinarian_Email__c));
                            }
                        }
                    }
                    
                    if(!financiallyAuthEmailSet.isEmpty()){
                        allRecipients = String.join(financiallyAuthEmailSet,',') + ',' + String.join(vetEmailSet, ',');
                    } else{
                        allRecipients = String.join(vetEmailSet, ',');
                    }
                    allRecipients = allRecipients.removeEnd(',');
                    agmt.echosign_dev1__Recipient_Addresses__c = allRecipients;
                    agmt.echosign_dev1__Message__c = 'If you have questions about your application, please email us at customeraccounts@zoetis.com';
                    agmt.echosign_dev1__Process_Template__c = echoSigndev1DataMappingList[0].Id;
                    if (!sendAsUsers.isEmpty()) {
                        agmt.echosign_dev1__Sender_User__c = sendAsUsers[0].Id;
                    }
                    echoSignDev1AgreementToInsertList.add(agmt);
                }
                
                insert echoSignDev1AgreementToInsertList;
                if(forceExceptionEchoSignDev1AgrrementCreation){
                    integer y = 1 / 0;
                }
                
            } catch (Exception ex) {
                Logger.error('Error creating signature document: ',+ex.getMessage(), null);
                Throw ex;
            }
            
            
            try {
                
                List<Attachment> attchmentList = new List<Attachment>();
                for(echosign_dev1__SIGN_Agreement__c agmt:echoSignDev1AgreementToInsertList){
                    Attachment att = new Attachment();
                    att.Name =leadMap.get(agmt.Lead__c).NOA_Application_Number__c+'.pdf';
                    att.parentId = agmt.Id;
                    att.description = 'New Online Account Application';
                    PageReference pdfPage = Page.NOA_FInalFormPDFV2;
                    pdfPage.getParameters().put('Id',leadMap.get(agmt.Lead__c).id);
                    pdfPage.getParameters().put('downloadPdf','false');
                    Blob b;
                    if (Test.isRunningTest()) {
                        b = blob.valueof('TEST');
                    } else{
                        b = pdfPage.getContentAsPDF();
                    }
                    
                    att.body = b;
                    attchmentList.add(att);
                    String leadAppNumMapKey = leadMap.get(agmt.Lead__c).NOA_Application_Number__c;
                    leadAgreementIdMap.put(leadAppNumMapKey, agmt.Id);
                }
                
                
                insert attchmentList;
                if (!leadAgreementIdMap.isEmpty()) {
                    echosign_dev1.EchoSignActionBatch agreementsBatch = new echosign_dev1.EchoSignActionBatch(
                        leadAgreementIdMap.Values(),'Send',null,new User(Id =userInfo.getUserId()));
                    
                    if(!Test.isRunningTest()){
                        Database.executeBatch(agreementsBatch);
                    }
                }
                if(forceExceptionAttachmentcreation){
                    integer y = 1 / 0;
                }
                
            } catch (Exception ex) {
                logger.error('Error occured when sending document out for signature.: ',+ex.getMessage(), null);
                Throw ex;
            }
            List<Lead> leadUpdateList = new List<Lead>();
            
            try {
                
                for(Lead lead:leadList){
                    lead.Signature_Status__c = 'Out for Signature';
                    lead.Current_Status__c ='Submitted';
                    lead.Submitted_Date__c =System.today();
                    leadUpdateList.add(lead);
                }
                
                update leadUpdateList;
                if(forceExceptionLeadUpdate){
                    integer y = 1 / 0;
                }
            } catch (Exception e) {
                Logger.error('Error occurred when updating Lead Status.',+e.getMessage(), null);
                Throw e;
            }
            
        } catch(Exception e){
            Database.rollback(sp);
            Throw e;
        } finally{
            AccountSelector.enforceSecurity = true;
            
        }
        return leadAgreementIdMap;
    }
    
    
    /**
    * @description This method will generate pdf for the leads passed in the GenerateNewOnlineAccountPDFAPI request.
    * @author Padma Nerella @ Zoetis Inc | 07-07-2023 
    * @param leadAppNumSet 
    * @return Map<String,Blob>
    **/
    public static Map<String,Blob> generateNewOnlineAccountPDF(Set<String> leadAppNumSet){
        
        List<Lead> leadIdwithAppNumList = LeadsSelector.SelectByNOAAppNumber(leadAppNumSet);
        Map<String,Blob> pdfLeadAppNumMap = new Map<String,Blob>();
        for(Lead ld:leadIdwithAppNumList){
            PageReference pdf = Page.NOA_FInalFormPDFV2;
            pdf.getParameters().put('Id',ld.Id);
            pdf.getParameters().put('downloadPdf','true');
            Blob b;
            if (Test.isRunningTest()) {
                b = blob.valueof('TEST');
            } else{
                b = pdf.getContentAsPDF();
            }
            pdfLeadAppNumMap.put(ld.NOA_Application_Number__c, b);
        }
        return pdfLeadAppNumMap;
    }

    /**
    * @description This method will return all names of Accounts that are exempt from NOA Financial Signatures
    * @author Ethan Hirsch @ Zoetis Inc | 07-26-2023 
    * @param leadAppNumSet 
    * @return Set<String>
    **/
    public static Set<String> retrieveNOAExemptSignedAccounts() {
        Set<String> NOAaccountNameSet= new Set<String>();

        Map<String, NOA_Accounts_Exempt__mdt> NOAaccountMetaData = NOA_Accounts_Exempt__mdt.getAll();

        //collect all the entity names from custom metadata and store in NOAaccountNameSet
        for(string entityName : NOAaccountMetaData.keyset()){
            NOAaccountNameSet.add(NOAaccountMetaData.get(entityName).Entity_Name__c);
        }

        return NOAaccountNameSet;
    }
}