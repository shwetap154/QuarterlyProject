/*************************************************************************************************************************
  Class Name     : ZTS_GL_accUpdateClass
  Description    : This class is called from trigger on ZTS_US_Account_Contact_Affiliations__c 
  Created By     : Akanksha
  Created On     : 03/20/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------

***************************************************************************************************************************/
public class ZTS_GL_accUpdateClass {

    List<Contact> listContact=new List<Contact>();
    //Map <id, Account> mapIdAcc = new Map<id, Account>();
    Map <id,Contact> mapIdCon = new Map<id,Contact>();
    
    /***********
    * Method name  : UpdateAccOnCont
    * Description  : This method updates  contact with account details.
    * Return Type  : None.
    * Parameters   : Trigger Context variables.
    ***********/
    public void UpdateAccOnCont(List<ZTS_EU_Affiliations__c> Triggernew,List<ZTS_EU_Affiliations__c> Triggerold,Map<id,ZTS_EU_Affiliations__c>triggerNewMap,Map<id,ZTS_EU_Affiliations__c>triggerOldMap,boolean isUpdate,boolean isInsert)
    {
        
        for (ZTS_EU_Affiliations__c oAff: triggerNew)
        {
           // mapIdAcc.put(oAff.ZTS_EU_Account__c,null);
            system.debug('*'+oAff.ZTS_EU_Account__c);
            mapIdCon.put(oAff.ZTS_EU_Contact__c,null);
        }
        //for(Account oAcc : [SELECT id, name, ZTS_US_NARC_ID__c,Phone,BillingCity ,BillingState,BillingCountry,BillingPostalCode FROM Account WHERE ID IN : mapIdAcc.keyset() AND ZTS_EU_Market__c = 'United States'])
        //{
         //   mapIdAcc.put(oAcc.id,oAcc);
       // }
        
        List<ZTS_EU_Affiliations__c> accConAffWithContactsUpdatedList=new  List<ZTS_EU_Affiliations__c>();
         /** Update profession on ACA records**/
            if(isInsert){
               ZTS_US_ContactAffiliation_Update.populateAccContactAffPositions(Triggernew);  
            }
        for(ZTS_EU_Affiliations__c oAff: Triggernew){
                        
            if(isUpdate)
            { 
              if (triggerOldMap.get(oAff.id).ZTS_EU_Contact__c !=oAff.ZTS_EU_Contact__c && oAff.ZTS_EU_Contact__c!=null){
                 accConAffWithContactsUpdatedList.add(oAff);
                 
               }
               
                if (((triggerOldMap.get(oAff.id).ZTS_US_LE_Contact__c)<>( oAff.ZTS_US_LE_Contact__c))||((triggerOldMap.get(oAff.id).ZTS_EU_Account_influence__c)<>( oAff.ZTS_EU_Account_influence__c))||((triggerOldMap.get(oAff.id).ZTS_US_Job_Function__c)<>( oAff.ZTS_US_Job_Function__c))||((triggerOldMap.get(oAff.id).Profit_Solver_Contact__c)<>( oAff.Profit_Solver_Contact__c)))
                {
                    if(oAff.ZTS_US_Primary_Account__c)
                    {
                        Contact oCon = new Contact(id = oAff.ZTS_EU_Contact__c, ZTS_US_LE_Contact__c =oAff.ZTS_US_LE_Contact__c,ZTS_US_Account_influence__c=oAff.ZTS_EU_Account_influence__c,ZTS_Job_Function__c=oAff.ZTS_US_Job_Function__c,ZTS_US_Profit_Solver_Contact__c=oAff.Profit_Solver_Contact__c);
                        listContact.add(oCon);
                    }
                }  
                
                     
            }            
        }
        //Sync Contact profession when ACA records
                if(!accConAffWithContactsUpdatedList.isEmpty()){
                ZTS_US_ContactAffiliation_Update.populateAccContactAffPositions(accConAffWithContactsUpdatedList);      
                }  
        if(listContact.size()>0){
            try{
                //Database.update(listContact);
             //CheckRecursiveTrigger.updateconaffonce();
             // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                dml.OptAllOrNone = false;
                List<Database.SaveResult> sr = Database.update(listContact,dml);
                //List<Database.Saveresult> results=Database.update(listContact,false);-- commented for SC-008149
    
                    ZTS_EU_Logger.error(sr, 'ZTS_GL_accUpdateClass-UpdateAccOnCont');
                
            }catch(Exception e){
                   ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_GL_accUpdateClass-UpdateAccOnCont');
                   
            }     
        }
    }
    
    /***********
    * Method name  : updateContactsStatus
    * Description  : Update Contact status based on Affiliations status whenever Affiliation is updated
    * Return Type  : None
    * Parameters   : Set of Contact Ids related to triggered Affiliation records
    ***********/
    public void updateContactsStatus(Set<Id> contIdSet) {
        List<Contact> contactsToBeUpdated = new List<Contact>();
        Map<Id, List<ZTS_EU_Affiliations__c>> contactMap = new Map<Id, List<ZTS_EU_Affiliations__c>>();
        //SC-009019 - Modified by Prasun, added Contact_Affiliation_Deactivation_Date__c field in the query
        for(ZTS_EU_Affiliations__c acaf: [Select Id,ZTS_EU_Contact__c,ZTS_EU_Affiliation_Status__c,Contact_Affiliation_Deactivation_Date__c FROM ZTS_EU_Affiliations__c WHERE ZTS_EU_Contact__c in :contIdSet AND ZTS_EU_Market_from_Parent__c = 'United States']){
            if(contactMap.get(acaf.ZTS_EU_Contact__c) == null){
                List<ZTS_EU_Affiliations__c> afList = new List<ZTS_EU_Affiliations__c>();
                afList.add(acaf);
                contactMap.put(acaf.ZTS_EU_Contact__c, afList);  
                
            }else{
                List<ZTS_EU_Affiliations__c> existingAfList = contactMap.get(acaf.ZTS_EU_Contact__c);
                existingAfList.add(acaf);
                contactMap.put(acaf.ZTS_EU_Contact__c, existingAfList);  
            }  
        }
        
        for(Contact c : [Select Id,ZTS_EU_Contact_Status__c FROM Contact WHERE Id in :contactMap.keySet() AND ZTS_EU_Market__c = 'United States'] ){
            boolean isAnyActive = false;
            boolean isAnyRecentlyDeactivated = false;
            for(ZTS_EU_Affiliations__c af : contactMap.get(c.Id) ){
                if(af.ZTS_EU_Affiliation_Status__c == 'Active'){
                    isAnyActive = true;
                }else if(af.Contact_Affiliation_Deactivation_Date__c != null && ( af.Contact_Affiliation_Deactivation_Date__c > DateTime.now().addHours(-24))){
                    isAnyRecentlyDeactivated = true;
                }
            }
            if(isAnyActive){
                if(c.ZTS_EU_Contact_Status__c == 'Inactive'){
                    c.ZTS_EU_Contact_Status__c = 'Active'; 
                    contactsToBeUpdated.add(c);
                }
                
            }else{
                if(c.ZTS_EU_Contact_Status__c == 'Active' && !isAnyRecentlyDeactivated){
                    c.ZTS_EU_Contact_Status__c = 'Inactive'; 
                    contactsToBeUpdated.add(c);
                }
            }
        }
        System.debug('Contacts To Be Update :: ' + contactsToBeUpdated);
        if(contactsToBeUpdated.size() > 0){
            try{
                // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                dml.OptAllOrNone = false;
                List<Database.SaveResult> sr = Database.update(contactsToBeUpdated,dml);
                //Database.update(contactsToBeUpdated, false); -- commented for SC-008149
                
            } catch(Exception e){
                System.debug('Exception update contact status: ' + contactsToBeUpdated);
            }
        }
    }
    
}