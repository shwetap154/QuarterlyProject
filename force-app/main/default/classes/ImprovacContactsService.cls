/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 04-10-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Ver   Date         Author                      Modification
 * 1.0   04-05-2023   Padma nerella @ Zoetis Inc  Moved all the logic from ImprovacTriggerHandler to ImprovacContactsService as part of the tech debt stroy TPDEV-89
**/
public with sharing class ImprovacContactsService {

    public static List<String> echoSigndev1TempalteName = new List<String>{'Improvac Certificate for Vet','Improvac Certificate for LW'};
    public static final String LW_AT_NAME = 'Improvac Certificate for LW';
    public static final String VW_AT_NAME = 'Improvac Certificate for Vet'; 
    public static final String CONTACT_TYPE_FARMER = 'Farmer';
    public static final String CONTACT_TYPE_VET = 'Veterinarian'; 
    public static String lwAT = null;
    public static String vwAT = null;        
    public static boolean canIrun = true;
    
    public static void prepareContacts(String insertOrupdate, List<Contact> newContacts, Map<Id,Contact> oldMap){

        List<echosign_dev1__Agreement_Template__c> echoSignAgreementTemplateList = EchoSignAgreementTemplatesSelector.selectEchoSignAgreementTemplateByName(echoSigndev1TempalteName);
        for(echosign_dev1__Agreement_Template__c agreementTemplate : echoSignAgreementTemplateList){
            if(agreementTemplate.Name == LW_AT_NAME)
            {
                lwAT = agreementTemplate.Id;
            }
            else
            {
                vwAT = agreementTemplate.Id;
            }   

        }
        List<Id> vwContacts = new List<Id>();
        List<Id> lwContacts = new List<Id>(); 
        Set<Id> accIds = new Set<Id>();
        for(Contact c : newContacts)
        {  
            if(c.Certification_Status__c == true && c.Email != Null && insertOrupdate != null 
               && ( (insertOrupdate == 'afterInsert')
                   || (insertOrupdate == 'afterUpdate' && oldMap != null &&oldMap.get(c.Id) != null && oldMap.get(c.Id).Certification_Status__c == False &&(oldMap.get(c.Id).Certification_Status__c != c.Certification_Status__c))
                   || (insertOrupdate == 'afterUpdate' && oldMap != null &&oldMap.get(c.Id) != null && oldMap.get(c.Id).Email == Null&& (oldMap.get(c.Id).Email != c.Email ))
                   || (insertOrupdate == 'afterUpdate' && oldMap != null &&oldMap.get(c.Id) != null && (oldMap.get(c.Id).ZTS_EU_Contact_type__c == Null || oldMap.get(c.Id).ZTS_EU_Contact_type__c != 'Farmer' || oldMap.get(c.Id).ZTS_EU_Contact_type__c != 'Veterinarian') && (c.ZTS_EU_Contact_type__c =='Farmer'||c.ZTS_EU_Contact_type__c =='Veterinarian' )&& (oldMap.get(c.Id).ZTS_EU_Contact_type__c != c.ZTS_EU_Contact_type__c))        
                  )
             
              )
            {  
                if(c.ZTS_EU_Contact_type__c == CONTACT_TYPE_FARMER)
                {
                    lwContacts.add(c.Id);
                    accIds.add(c.AccountId);
                }
                else if(c.ZTS_EU_Contact_type__c == CONTACT_TYPE_VET)
                {
                    vwContacts.add(c.Id);
                    accIds.add(c.AccountId);
                }
                
            }else if(insertOrupdate == 'afterUpdate' && oldMap != null &&oldMap.get(c.Id) != null && oldMap.get(c.Id).Certification_Status__c == True && c.Certification_Status__c == False
                  ) {
                        accIds.add(c.AccountId);
                    }
        }
        if(vwContacts.size() > 0)
        {
            createAgreements(vwContacts, vwAT); 
        }
        if(lwContacts.size() > 0)
        {
            createAgreements(lwContacts, lwAT);  
        }   
        //update Account records
        if(accIds.size() > 0){
            AccountsService.updateAccountcertificationStatus(accIds);
        }
    } 
    
    Private static void createAgreements(List<Id> contactIds, String agmtTemplateId){
        canIrun = false;      
         try{
                echosign_dev1.AgreementTemplateServiceBatch vwbatch = new echosign_dev1.AgreementTemplateServiceBatch(contactIds,agmtTemplateId,'Contact');
                Id syncProcessId = Database.executeBatch(vwbatch, 5);
                logger.error('ImprovacTrigger async process Id '+syncProcessId);            
            }catch(Exception ex){
                logger.error('Error creating agreements for Improvac Contacts' + ex); 
            }
    }
    
}