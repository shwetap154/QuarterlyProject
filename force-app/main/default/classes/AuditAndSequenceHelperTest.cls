@isTest
public class AuditAndSequenceHelperTest {
    static final String RECORDTYPE_CASE_ANIMAL_SUPPORT_STR = 'Animal_Support';
    static final String animalRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORDTYPE_CASE_ANIMAL_SUPPORT_STR).getRecordTypeId(); 
    static final String LOCALASSESSMENT_RT_ID= Schema.SObjectType.ZTS_US_Assessment__c.getRecordTypeInfosByDeveloperName().get('ZTS_US_Local_Assessment').getRecordTypeId();
    
    @testSetup static void createRecords() {
                
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('RingLeadTrigger');
        Case newCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Test Case',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint',
                                ZTS_EU_PV_Works__c='1234');
        Case mergeCase = new Case(RecordTypeId = animalRecordtypeId,
                                Subject = 'Merge Case',
                                Status = 'New',
                                Origin = 'Email',
                                Type = 'Animal Complaint');
        Case[] testCases = new Case[]{newCase,mergeCase};
        insert testCases;
        Id[] caseIds = new Id[]{newCase.Id,mergeCase.Id};
        //Insert Contact
		Contact contact = new Contact(LastName = 'Doe', FirstName = 'Testone',ZTS_US_Job_Function__c = 'CFO', ZTS_US_Profession__c= 'Consultant');
        insert contact;
        
        // Insert Breed
        ZTS_US_Breed__c Breed1 = new ZTS_US_Breed__c (Name = 'Terrier', ZTS_US_Species__c = 'Feline');
        insert Breed1;
        //Insert Animal
        ZTS_US_Animal__c animal = new ZTS_US_Animal__c(Name = 'Tessjyyy', ZTS_US_Species__c='Feline',
                                                       ZTS_US_Breed__c = Breed1.id,ZTS_US_Date_of_Birth__c = date.today()-500,
                                                       ZTS_US_Atlas_Id__c ='PETOWNER_ATLAS_ID');
        insert animal;
        
        //every record inserted after this point should generate an audit log, some of which will also generate a sequence
        //Insert Case Contact
		Case_Contact__c caseContact1 = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = newCase.Id);
        Case_Contact__c caseContact2 = new Case_Contact__c(Contact__c = contact.Id, ZTS_US_Contact_Role__c = 'Pharmacist', Case__c = mergeCase.Id);
		insert new Case_Contact__c[]{caseContact1,caseContact2};
        //Create PVW Product record
        ZTS_US_PVW_Product__c prod1 = new ZTS_US_PVW_Product__c(Name = 'VANGUARD PLUS 5/L',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        ZTS_US_PVW_Product__c prod2 = new ZTS_US_PVW_Product__c(Name = 'Symparica',ZTS_US_MAH_Country__c = 'US',ZTS_US_Active_Product__c = 'Yes');
        insert new ZTS_US_PVW_Product__c[]{prod1,prod2};

        //Insert Case Product Record
        ZTS_US_Case_Product__c caseProduct1 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = newcase.Id,
                                                                        ZTS_US_PVW_Product__c = prod1.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        ZTS_US_Case_Product__c caseProduct2 = new ZTS_US_Case_Product__c(ZTS_US_Case__c = mergecase.Id,
                                                                        ZTS_US_PVW_Product__c = prod2.Id,ZTS_US_Product_problem_type__c='Adverse Reaction',
                                                                        ZTS_US_Product_Role__c = 'Suspect Product',ZTS_US_Product_Used_Correctly__c = 'Yes');
        insert new ZTS_US_Case_Product__c[]{caseProduct1,caseProduct2};

        Batch_Detail__c bd1 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct1.Id,ZTS_US_Product_Lot__c='56',ZTS_US_Serial_Number__c='12',ZTS_US_Diluent__c='34');
        Batch_Detail__c bd2 = new Batch_Detail__c(ZTS_US_Case_Product__c=caseProduct2.Id,ZTS_US_Product_Lot__c='54',ZTS_US_Serial_Number__c='33',ZTS_US_Diluent__c='77');
        insert new Batch_Detail__c[]{bd1,bd2};


        ZTS_US_Product_Investigation__c investigation1 = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Batch_Detail__c=bd1.Id,
                                            ZTS_US_Investigation_Request__c = 'testing1', ZTS_US_Case_Product__c = caseProduct1.Id,
                                            ZTS_US_Investigation_Type__c='Lot');
        ZTS_US_Product_Investigation__c investigation2 = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Batch_Detail__c=bd1.Id,
                                            ZTS_US_Investigation_Request__c = 'testing2', ZTS_US_Case_Product__c = caseProduct1.Id,
                                            ZTS_US_Investigation_Type__c='Lot');
        ZTS_US_Product_Investigation__c investigation3 = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = newCase.Id,ZTS_US_Batch_Detail__c=bd1.Id,
                                            ZTS_US_Investigation_Request__c = 'testing3', ZTS_US_Case_Product__c = caseProduct1.Id,
                                            ZTS_US_Investigation_Type__c='Serial');
        ZTS_US_Product_Investigation__c investigation4 = new ZTS_US_Product_Investigation__c(ZTS_US_Case__c = mergeCase.Id,ZTS_US_Batch_Detail__c=bd2.Id,
                                            ZTS_US_Investigation_Request__c = 'testing4', ZTS_US_Case_Product__c = caseProduct2.Id,
                                            ZTS_US_Investigation_Type__c='Serial');
        insert new ZTS_US_Product_Investigation__c[]{investigation1,investigation2,investigation3,investigation4};

        //Insert Case Animal
        ZTS_US_Case_Animal__c caseAnimal = new ZTS_US_Case_Animal__c(ZTS_US_Case__c = newCase.Id, ZTS_US_Animal__c = animal.Id );
        insert caseAnimal;
        ZTS_US_Event_Narrative__c[] eventNarratives = [SELECT id FROM ZTS_US_Event_Narrative__c WHERE ZTS_US_Case__c in : caseIds];
        ZTS_US_VedDRA_Event__c[] eventVeddras = new ZTS_US_VedDRA_Event__c[]{};
        for(ZTS_US_Event_Narrative__c narrative : eventNarratives){
            ZTS_US_VedDRA_Event__c veddra = new ZTS_US_VedDRA_Event__c(ZTS_US_Event_Narrative__c=narrative.id);
            eventVeddras.add(veddra);
        }
        insert eventVeddras;

        ZTS_US_Assessment__c assessmentLocal1 = new ZTS_US_Assessment__c(RecordTypeId=LOCALASSESSMENT_RT_ID,ZTS_US_Case__c=newCase.id,ZTS_US_Local_Assessment__c='USDA');
        ZTS_US_Assessment__c assessmentLocal2 = new ZTS_US_Assessment__c(RecordTypeId=LOCALASSESSMENT_RT_ID,ZTS_US_Case__c=mergeCase.id,ZTS_US_Local_Assessment__c='USDA');
        insert new ZTS_US_Assessment__c[]{assessmentLocal1,assessmentLocal2};

        ZTS_US_Case_Agency_Submission__c agency = new ZTS_US_Case_Agency_Submission__c(Agency_Name__c='FDA',Case__c=newCase.Id);
        insert agency;

        ZTS_US_Case_Review_Card__c reviewCard = new ZTS_US_Case_Review_Card__c(ZTS_US_Case__c=newCase.Id);
        insert reviewCard;
    }

    static testMethod void insertRecordsTest() {  
        test.startTest();      
        Case newCase = [SELECT id,ZTS_US_Event_Narrative__c FROM Case LIMIT 1];
        ZTS_US_Assessment__c assessmentLocal = [SELECT id,Sequence__c FROM ZTS_US_Assessment__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 1];
        
        ZTS_US_Case_Product__c caseProduct = [SELECT id,Sequence__c FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 1];

        Case_Contact__c caseContact = [SELECT id,Sequence__c FROM Case_Contact__c WHERE Case__c=:newCase.id LIMIT 1];

        ZTS_US_VedDRA_Event__c veddra = [SELECT id,Sequence__c FROM ZTS_US_VedDRA_Event__c WHERE ZTS_US_Event_Narrative__c=:newCase.ZTS_US_Event_Narrative__c LIMIT 1];

        ZTS_US_Product_Investigation__c[] productInvestigations = [SELECT id,Sequence__c,Suffix__c FROM ZTS_US_Product_Investigation__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 3];


        
        system.assertEquals(3,productInvestigations.size());
        ZTS_US_Product_Investigation__c investigation1 = productInvestigations[0];
        ZTS_US_Product_Investigation__c investigation2 = productInvestigations[1];
        ZTS_US_Product_Investigation__c investigation3 = productInvestigations[2];

        Map<String,ZTS_US_CSE_Audit_Trail__c>auditTrailByRecordId = new Map<String,ZTS_US_CSE_Audit_Trail__c>();
        String insertType = String.valueOf(System.TriggerOperation.AFTER_INSERT);
        ZTS_US_CSE_Audit_Trail__c[] auditTrailRecs = [  SELECT  Id, Audit_Flag__c, Object_Name__c, Record_Id__c, Sequence_Number__c, Suffix__c
                                                        FROM    ZTS_US_CSE_Audit_Trail__c 
                                                        WHERE   Case__c = :newCase.Id 
                                                        AND     Trigger_Operation__c = :insertType];
        System.assertEquals(12, auditTrailRecs.size(),  'Every case related record inserted should generate an audit log');       
        for(ZTS_US_CSE_Audit_Trail__c auditRec: auditTrailRecs){
            //case was sent to pv prior to child record creation, all flags should be true
            system.assertEquals(true,auditRec.Audit_Flag__c);
            auditTrailByRecordId.put(auditRec.Record_Id__c,auditRec);
        } 
        //the following are those that should have a sequence, investigation should also have a suffix
        ZTS_US_CSE_Audit_Trail__c assessmentAuditTrail = auditTrailByRecordId.get(assessmentLocal.Id);
        system.assert(assessmentAuditTrail!=null);
        system.assert(assessmentAuditTrail.Sequence_Number__c == 1);
        system.assertEquals(Decimal.valueOf(assessmentLocal.Sequence__c),assessmentAuditTrail.Sequence_Number__c);

        ZTS_US_CSE_Audit_Trail__c caseProductAuditTrail = auditTrailByRecordId.get(caseProduct.Id);
        system.assert(caseProductAuditTrail!=null);
        system.assertEquals(1,caseProductAuditTrail.Sequence_Number__c);
        system.assertEquals(Decimal.valueOf(caseProduct.Sequence__c),caseProductAuditTrail.Sequence_Number__c);

        ZTS_US_CSE_Audit_Trail__c caseContactAuditTrail = auditTrailByRecordId.get(caseContact.Id);
        system.assert(caseContactAuditTrail!=null);
        system.assertEquals(1,caseContactAuditTrail.Sequence_Number__c);
        system.assertEquals(Decimal.valueOf(caseContact.Sequence__c),caseContactAuditTrail.Sequence_Number__c);

        ZTS_US_CSE_Audit_Trail__c veddraAuditTrail = auditTrailByRecordId.get(veddra.Id);
        system.assert(veddraAuditTrail!=null);
        system.assertEquals(1,veddraAuditTrail.Sequence_Number__c);
        system.assertEquals(Decimal.valueOf(veddra.Sequence__c),veddraAuditTrail.Sequence_Number__c);

        ZTS_US_CSE_Audit_Trail__c pi1AuditTrail = auditTrailByRecordId.get(investigation1.Id);
        system.assert(pi1AuditTrail!=null);
        system.assertEquals(1,pi1AuditTrail.Sequence_Number__c);
        system.assertEquals('A1',pi1AuditTrail.Suffix__c);
        system.assertEquals(Decimal.valueOf(investigation1.Sequence__c),pi1AuditTrail.Sequence_Number__c);
        system.assertEquals(investigation1.Suffix__c,pi1AuditTrail.Suffix__c);

        ZTS_US_CSE_Audit_Trail__c pi2AuditTrail = auditTrailByRecordId.get(investigation2.Id);
        system.assert(pi2AuditTrail!=null);
        system.assertEquals(2,pi2AuditTrail.Sequence_Number__c);
        system.assertEquals('A2',pi2AuditTrail.Suffix__c);
        system.assertEquals(Decimal.valueOf(investigation2.Sequence__c),pi2AuditTrail.Sequence_Number__c);
        system.assertEquals(investigation2.Suffix__c,pi2AuditTrail.Suffix__c);

        ZTS_US_CSE_Audit_Trail__c pi3AuditTrail = auditTrailByRecordId.get(investigation3.Id);
        system.assert(pi3AuditTrail!=null);
        system.assertEquals(3,pi3AuditTrail.Sequence_Number__c);
        system.assertEquals('B1',pi3AuditTrail.Suffix__c);
        system.assertEquals(Decimal.valueOf(investigation3.Sequence__c),pi3AuditTrail.Sequence_Number__c);
        system.assertEquals(investigation3.Suffix__c,pi3AuditTrail.Suffix__c);
        Test.stopTest();
    }

    static testMethod void deleteRecordsTest() {        
        Case newCase = [SELECT id,ZTS_US_Event_Narrative__c,Sync_Status__c,ZTS_EU_PV_Works__c FROM Case LIMIT 1];
        newCase.Sync_Status__c = 'Unapproved';
        update newCase;
        test.startTest();

        ZTS_US_Assessment__c assessmentLocal = [SELECT id FROM ZTS_US_Assessment__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 1];

        Batch_Detail__c batchDetail = [SELECT id FROM Batch_Detail__c WHERE ZTS_US_Case_Product__r.ZTS_US_Case__c =:newCase.id LIMIT 1];
        
        ZTS_US_Case_Product__c caseProduct1 = [SELECT id FROM ZTS_US_Case_Product__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 1];

        Case_Contact__c caseContact = [SELECT id FROM Case_Contact__c WHERE Case__c=:newCase.id LIMIT 1];

        ZTS_US_VedDRA_Event__c veddra = [SELECT id FROM ZTS_US_VedDRA_Event__c WHERE ZTS_US_Event_Narrative__c=:newCase.ZTS_US_Event_Narrative__c LIMIT 1];

        ZTS_US_Product_Investigation__c[] productInvestigations = [SELECT id FROM ZTS_US_Product_Investigation__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 3];

        ZTS_US_Case_Animal__c caseAnimal = [SELECT id FROM ZTS_US_Case_Animal__c WHERE ZTS_US_Case__c=:newCase.id LIMIT 1];

        ZTS_US_Event_Narrative__c eventNarrative = [SELECT id FROM ZTS_US_Event_Narrative__c WHERE Id=:newCase.ZTS_US_Event_Narrative__c LIMIT 1];

        ZTS_US_Case_Agency_Submission__c agency = [SELECT id FROM ZTS_US_Case_Agency_Submission__c WHERE Case__c=:newCase.Id LIMIT 1];

        ZTS_US_Case_Review_Card__c reviewCard = [SELECT id FROM ZTS_US_Case_Review_Card__c WHERE ZTS_US_Case__c=:newCase.Id LIMIT 1];
        
        delete assessmentLocal;
        system.assertEquals(3,productInvestigations.size());
        delete productInvestigations;
        delete batchDetail;
        delete caseProduct1;
        delete caseContact;
        delete veddra;
        delete caseAnimal;
        delete eventNarrative;
        delete agency;
        delete reviewCard;
        
        String deleteType = String.valueOf(System.TriggerOperation.AFTER_DELETE);
        ZTS_US_CSE_Audit_Trail__c[] auditTrailRecs = [  SELECT  Id, Audit_Flag__c, Object_Name__c, Record_Id__c, Sequence_Number__c, Suffix__c
                                                        FROM    ZTS_US_CSE_Audit_Trail__c 
                                                        WHERE   Case__c = :newCase.Id 
                                                        AND     Trigger_Operation__c = :deleteType];
        System.assertEquals(12, auditTrailRecs.size(),  'Every case related record deleted should generate an audit log');
        Test.stopTest();
    }
    static testMethod void sequenceMergeTest() { 
        
        TriggerActivation__c tr = new TriggerActivation__c(Name = 'ZTS_EU_ServiceRequest',ZTS_EU_Bypass__c = true);
        insert tr;

        Case[] testCases = [SELECT id,ZTS_US_Event_Narrative__c,Sync_Status__c,Subject FROM Case LIMIT 2];
        Case survivingCase;
        Case mergeCase;
        for(Case queriedCase : testCases){
            if(queriedCase.Subject == 'Test Case'){
                survivingCase = queriedCase;
            }
            else{
                mergeCase = queriedCase;
            }
        }
        
        SL_CaseTriggerHelper.setAuditTrailLock(new Id[]{survivingCase.Id});

        test.startTest();
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('RingLeadTrigger');
        
        
        //CustomSettingService.setTriggerBypass('ZTS_EU_ServiceRequest', true);
        system.assert(survivingCase!=null);
        system.assert(mergeCase!=null);
        Database.Merge(survivingCase,mergeCase);
        Test.stopTest();
        Case survivingCaseAfterMerge = [SELECT id,ZTS_US_Event_Narrative__c,Sync_Status__c,ZTS_EU_PV_Works__c,Subject ,
                                        (SELECT Id,Object_Name__c,Record_Id__c,Sequence_Number__c FROM CSE_Audit_Trails__r ORDER BY Sequence_Number__c ASC),
                                        (SELECT Id,Case__c,Sequence__c FROM Case_Contacts__r ORDER BY Sequence__c ASC),
                                        (SELECT Id,ZTS_US_Case__c,Sequence__c FROM Case_Products__r ORDER BY Sequence__c ASC),
                                        (SELECT Id,ZTS_US_Case__c,Sequence__c 
                                            FROM Assessments__r 
                                            WHERE RecordTypeId = :CSE_AssessmentTriggerHandler.localAssessmentRT
                                            ORDER BY Sequence__c ASC),
                                        (SELECT Id,ZTS_US_Case__c,ZTS_US_Batch_Detail__c,ZTS_US_Investigation_Type__c,Sequence__c,Suffix__c 
                                            FROM Product_Investigations__r ORDER BY Sequence__c ASC)
                                        FROM Case
                                        WHERE Id = :survivingCase.Id
                                        LIMIT 1];
        ZTS_US_Assessment__c[] assessmentsLocal = survivingCaseAfterMerge.Assessments__r;
        system.assertEquals(2,assessmentsLocal.size());  

        Batch_Detail__c[] batchDetails = [  SELECT id,Sequence__c 
                                            FROM Batch_Detail__c 
                                            WHERE ZTS_US_Case_Product__r.ZTS_US_Case__c =:survivingCase.id 
                                            ORDER BY Sequence__c];
        
        system.assertEquals(2,batchDetails.size());                                    

        ZTS_US_Case_Product__c[] caseProducts = survivingCaseAfterMerge.Case_Products__r;
        system.assertEquals(2,caseProducts.size());

        Case_Contact__c[] caseContacts = survivingCaseAfterMerge.Case_Contacts__r;
        system.assertEquals(2,caseContacts.size());

        ZTS_US_Product_Investigation__c[] productInvestigations = survivingCaseAfterMerge.Product_Investigations__r;
        system.assertEquals(4,productInvestigations.size());

        Map<String,ZTS_US_CSE_Audit_Trail__c> auditTrailByRecordId = new Map<String,ZTS_US_CSE_Audit_Trail__c>();
        for(ZTS_US_CSE_Audit_Trail__c auditRecord : survivingCaseAfterMerge.CSE_Audit_Trails__r){
            auditTrailByRecordId.put(auditRecord.Record_Id__c,auditRecord);
        }
        for(Integer i=0;i<assessmentsLocal.size();i++){
            system.assertEquals(String.valueOf(i+1),assessmentsLocal[i].Sequence__c);
            system.assert(auditTrailByRecordId.containsKey(assessmentsLocal[i].Id));
        }
        for(Integer i=0;i<batchDetails.size();i++){
            system.assertEquals(String.valueOf(i+1),batchDetails[i].Sequence__c);
            system.assert(auditTrailByRecordId.containsKey(batchDetails[i].Id));
        }
        for(Integer i=0;i<caseProducts.size();i++){
            system.assertEquals(String.valueOf(i+1),caseProducts[i].Sequence__c);
            system.assert(auditTrailByRecordId.containsKey(caseProducts[i].Id));
        }
        for(Integer i=0;i<caseContacts.size();i++){
            system.assertEquals(String.valueOf(i+1),caseContacts[i].Sequence__c);
            system.assert(auditTrailByRecordId.containsKey(caseContacts[i].Id));
        }
        for(Integer i=0;i<productInvestigations.size();i++){
            //system.assertEquals(String.valueOf(i+1),productInvestigations[i].Sequence__c);
            system.debug('investigation Sequence: '+productInvestigations[i].Sequence__c);
            switch on i{
                when 0{
                    system.assertEquals('A1',productInvestigations[i].Suffix__c);
                }
                when 1{
                    system.assertEquals('A2',productInvestigations[i].Suffix__c);
                }
                when 2{
                    system.assertEquals('B1',productInvestigations[i].Suffix__c);
                }
                when 3{
                    system.assertEquals('C1',productInvestigations[i].Suffix__c);
                }
            }
            system.assert(auditTrailByRecordId.containsKey(productInvestigations[i].Id));
        }
    }
    
    
}