global class ImprovacAgreementsSchedular implements  Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        List<Contact> contacts = [Select ID,Name,Certification_Status__c,toBeProcessedForImprovac__c FROM Contact where toBeProcessedForImprovac__c = true AND ZTS_EU_Market__c != 'United States'];
        if(Test.isRunningTest()){
            contacts = getMockContacts();
        }
        List<Id> contIds = new List<Id>();
        if(contacts != null && contacts.size() > 0){
            for(Contact con : contacts){
                contIds.add(con.Id);
            }
            
            List<echosign_dev1__SIGN_Agreement__c> agreements = [Select Id,Contact__c,echosign_dev1__Status__c FROM echosign_dev1__SIGN_Agreement__c 
                                                                 WHERE Contact__c IN :contIds AND echosign_dev1__Status__c = 'Draft' 
                                                                 ORDER BY LastModifiedDate DESC];
            if(Test.isRunningTest()){
                agreements = getMockAgreements();
            }
            Map<Id, Id> agMap = new Map<Id, Id>(); 
            System.debug('...Improvac Agreements retrieved....' + agreements);
            if(agreements != null && agreements.size() > 0)
                for(echosign_dev1__SIGN_Agreement__c ag: agreements)
            { 
                if(agMap.keySet() == null || !agMap.keySet().contains(ag.Contact__c)){
                    agMap.put(ag.Contact__c, ag.Id); 
                }
                
            } 
            
            if(agMap.size() > 0){
                try{ 
                    echosign_dev1.EchoSignActionBatch agreementsBatch = new echosign_dev1.EchoSignActionBatch(agMap.values(), 'Send', UserInfo.getSessionId(), null);
                    String syncAgrProcessId = null;
                    if(!Test.isRunningTest()){
                        syncAgrProcessId = Database.executeBatch(agreementsBatch);  
                    } 
                    for(Contact ct : contacts){
                        ct.toBeProcessedForImprovac__c = false;
                    }
                    update contacts;                    
                }catch(Exception ex){
                    System.debug('Error processing improvac agreements:: ' + ex); 
                }
            }  
        }
    }
    
    public List<Contact> getMockContacts(){
        List<Contact> lstContact = new List<Contact>();
        Id idContact = SL_IdGenerator.generateMockIdForObjectType(Contact.SObjectType);
        String strContactJson = '{"attributes":' +
                           '{'+
                            '"type":"Contact"'+
                            '},'+
                            '"Id":"'+idContact+'",' +
                            '"FirstName":"Test",'+
            				'"LastName":"Contact",'+
                            '"echosign_dev1__Status__c":"true",' +
                            '"toBeProcessedForImprovac__c":"true"'+
                            '}';
        Contact objContact = (Contact)JSON.deserialize(strContactJson, Contact.class);
        lstContact.add(objContact);
        return lstContact;
    }
    public List<echosign_dev1__SIGN_Agreement__c> getMockAgreements(){
        List<echosign_dev1__SIGN_Agreement__c> lstAgreements = new List<echosign_dev1__SIGN_Agreement__c>();
        Id idContact = SL_IdGenerator.generateMockIdForObjectType(Contact.SObjectType);
        Id idAgreement = SL_IdGenerator.generateMockIdForObjectType(echosign_dev1__SIGN_Agreement__c.SObjectType);
        String strContactJson = '{"attributes":' +
                           '{'+
                            '"type":"echosign_dev1__SIGN_Agreement__c"'+
                            '},'+
                            '"Id":"'+idAgreement+'",' +
                            '"Name":"Test",'+
            				'"Contact__c":"'+idContact+'",'+
                            '"echosign_dev1__Status__c":"Draft"'+
                            '}';
        echosign_dev1__SIGN_Agreement__c objAgreement = (echosign_dev1__SIGN_Agreement__c)JSON.deserialize(strContactJson, echosign_dev1__SIGN_Agreement__c.class);
        lstAgreements.add(objAgreement);
        return lstAgreements;
    }
}