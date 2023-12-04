/**
 * @description       : Service class for Contacts
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
* @last modified on  : 04-17-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   1-24-2023    Padma Nerella @ Zoetis Inc  Added updateContactwithAccountEmail TPDev-103
* 1.1   4-11-2023    Padma Nerella @ Zoetis Inc  Moved updateRepContactStatus method from ZTS_EU_Affiliation_Update class as part of refactoring code TPDEV-104.
        17-Aug-2023  Yadagiri Avula @ Cognizant   Added  "listFieldName", "updateSendTOLIS" methods from USContactTriggerService Class part of refactoring code and TPDEV-366     
**/

public with sharing class ContactsService {
    
    public static boolean myFlag = false;
    public static void updateContactwithAccountEmail(List<Account> newlyUpdatedAccountList)
    {
        List<Contact> contactList = new List<Contact>();
        
        if(myFlag == false)
        {
            contactList = ContactSelector.newInstance().selectContactsToUpdateEmail(newlyUpdatedAccountList);
            
            Map<Id,contact> map1 = new Map<Id,Contact>();
            
            if(!contactList.isEmpty())
            { 
                for(Contact con : contactList){
                    map1.put(con.AccountId,con);
                }
                
                List<Contact> contactToUpdate = new List<Contact>();
                for(Account acc : newlyUpdatedAccountList) {
                    if(map1.get(acc.id) != null){
                        map1.get(acc.id).Interface_Email__c = acc.Email__c;
                        map1.get(acc.id).ZTS_EU_Opt_Out_Email__c  = acc.ZTS_EU_Opt_Out_Email__c;
                        map1.get(acc.id).ZTS_Invalid_Email__c = acc.ZTS_Invalid_Email__c;
                        contactToUpdate.add(map1.get(acc.id));
                    }
                }
                myFlag = true;
                Database.DMLOptions dml = new Database.DMLOptions(); 
                dml.DuplicateRuleHeader.allowSave = true;
                dml.DuplicateRuleHeader.runAsCurrentUser = true;
                List<Database.SaveResult> sr = Database.update(contactToUpdate,dml);
            } 
        }
    }
    
    /*Added by Sohil DEF-000087
This method is used to update the Rep contacts status to inactive if it's all related ACA records status are inactive
* Modification for DEF-000087 on 11/07/2014
*/
    public static void updateRepContactStatus(List<ZTS_EU_Affiliations__c> ACAList, List<Account> accList)
    {
        try{
            List<ZTS_EU_Affiliations__c> affliatiedContactLst = new List<ZTS_EU_Affiliations__c>();             
            affliatiedContactLst = AffiliationsSelector.selectInternationalAffiliationsById(ACAList);
            Set<ID> contactsIds = new Set<ID>();
            boolean flag = false;
            
            for(ZTS_EU_Affiliations__c affiliationObj : affliatiedContactLst)
            {
                contactsIds.add(affiliationObj.ZTS_EU_Contact__c);                
            }
            List<Contact> contactList = new List<Contact>();
            List<Contact> contactListToUpdate = new List<Contact>();           
            contactList = ContactSelector.newInstance().selectInternationalContactsByIdwithAffiliations(contactsIds);            
            Map<Id,Boolean> secondMap = new  Map<Id,Boolean>();
            Map<Id,Contact> contactMap = new Map<Id,Contact>();
            for(Contact con : contactList)
            {
                contactMap.put(con.id, con);
            }
            for(Contact contactObj : contactList)
            {   
                if(contactObj.Accounts_and_Contacts__r.size() > 0)
                {
                    flag = false;
                    for(ZTS_EU_Affiliations__c affiliatedContacts : contactObj.Accounts_and_Contacts__r)
                    {
                        if(affiliatedContacts.ZTS_EU_Affiliation_Status__c == 'Active')
                        {
                            flag = true;                    
                            break;
                        } 
                    }                   
                } 
                secondMap.put(contactObj.id, flag); 
            }
            Contact conObj = new Contact();
            for(Id contactId : secondMap.keySet())
            {
                conObj = contactMap.get(contactId);         
                if(secondMap.get(contactId) == false)
                {
                    conObj.ZTS_EU_Contact_Status__c = 'Inactive';
                    contactListToUpdate.add(conObj);
                }           
            }
            Map<Id, String> fundIdErrorMap = new Map<Id, String>();
            if(!contactListToUpdate.isEmpty())
            {
                try{
                    Database.SaveResult[] srList = database.update(contactListToUpdate, false);
                    
                    for(Integer i=0;i<srList.size();i++) 
                    {
                        if (srList.get(i).isSuccess())
                        {
                            // For success records, no action will be required
                        } else if (!srList.get(i).isSuccess())
                        {
                            // For failed operation, create map of Fund Id to error message
                            Database.Error error = srList.get(i).getErrors().get(0);
                            String errString ;
                            errString = ' On Contact: '+contactListToUpdate[i].Name + ' : Error : ' + error.getMessage() ;
                            fundIdErrorMap.put(contactListToUpdate[i].AccountID, errString);
                        }
                    }
                } 
                catch(Exception e)
                {
                    Logger.error('Exception in Update on Fund: ' + e.getMessage());
                }
            }
            
            if(fundIdErrorMap!=null && !fundIdErrorMap.isEmpty())
            {           
                for(Account acc : accList){                        
                    acc.addError(fundIdErrorMap.get(acc.id));                            
                }           
            }       
        }catch(DMLException e)
        {
            Logger.error('##### EXCEPTION - '+e.getmessage());
            Logger.error('##### EXCEPTION - '+e.getstacktracestring());            
        }   
    } //EOD Sohil Shah(15/10/2014 DEF-000087) // EOD Modification for DEF-000087 on 11/07/2014
    
         
    /*Added by Yadagiri Avula @ Cognizant TPDEV-366
This method Copied from  USContactTriggerService Class part of refactoring code and TPDEV-366
* 
*/
    // SFDCATS- 463 : set field members from field set.
    private static List<String> integrationTriggerFieldSet() {
        List<String> listFieldName = new List<String>();
        for(Schema.FieldSetMember fields : sObjectType.Contact.fieldSets.Integration_Trigger_to_lis.getfields()){
            listFieldName.add(fields.getFieldPath());
        }
        return listFieldName ;
        
    }
    
      /*Added by Yadagiri Avula @ Cognizant TPDEV-366
This method Copied from  USContactTriggerService Class part of refactoring code and TPDEV-366
* 
*/
    public static void updateSendTOLIS(List<Contact> triggerNew,Map<Id, Contact> triggerOldMap, Boolean isAfterContext){
        
        Set<Id> accountIdSet = new Set<Id>();
        List<String> listFieldName = new List<String>();
        listFieldName = integrationTriggerFieldSet();
        for ( Contact con : triggerNew ) {
            if( con.Reference_Lab_Contact__c ) accountIdSet.add( con.AccountId );
        }

        Map<Id,Account> mapAccountToAddress = USAccountTriggerService.getAccountShipToAddresses( accountIdSet );
        List<Contact> contactList = new List<Contact>();
        
        for(Contact tempCon: triggerNew) {
            sobject oldTempCon = triggerOldMap?.get(tempCon.Id);           
            if(tempCon.Reference_Lab_Contact__c && !tempCon.Send_To_LIS__c){
                for(string fieldName: listFieldName){
                    if(tempCon.get(fieldName) != oldTempCon?.get(fieldName)){
                        if  (   mapAccountToAddress.ContainsKey( tempCon.AccountId )  
                            &&  (   mapAccountToAddress.get( tempCon.AccountId ).Addresses__r.size() == 1 
                                ||  (   mapAccountToAddress.get( tempCon.AccountId ).Addresses__r.size() > 1 
                                    && mapAccountToAddress.get( tempCon.AccountId ).Addresses__r[0].LIS_Number__c != null 
                                    ) 
                                ) 
                            ) 
                        {
                            if( !isAfterContext ) 
                            {
                                tempCon.Send_To_LIS__c = true;
                            }
                            else 
                            {
                                Contact originalRecord = new Contact ( Id = tempCon.Id, Send_To_LIS__c = true );
                                contactList.add( originalRecord );
                            }
                        }
                        else 
                        {
                            tempCon.Reference_Lab_Contact__c.addError( Label.RefLabs_Contact_No_LIS_Org_Error );
                        }
                        break;
                    }
                }
            }
        }
        if( isAfterContext ) 
        {
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true; // Bypassing duplicate rules
            dml.optAllOrNone = false;
            List<Database.SaveResult> sr = Database.update(contactList,dml);
            
            LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                'Failed to update the LIS flag on contact to true: Please check the following contacts to confirm LIS Flag status : {0}', 
                contactList);
            Logger_Extension.errorLogIfSaveError(logMessage, contactList, sr);
            
        }
    }
    
    
}