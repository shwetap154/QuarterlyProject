public with sharing class ContactUtility {
    public ContactUtility(){
        
    }
    
    public void setMKTOPermissions(List<Contact> contactList){
        
        //List<Contact> contacts = [SELECT Id,Email,Privacy_Authorisation__c,Authorization_Letter_Signed__c,Mkto_Sync_Permission__c,ZTS_EU_Country__c,ZTS_EU_Market__c FROM Contact WHERE Id IN:contactList];
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for(Contact c: [SELECT Id,Email,Privacy_Authorisation__c,Authorization_Letter_Signed__c,Mkto_Sync_Permission__c,ZTS_EU_Country__c,ZTS_EU_Market__c FROM Contact WHERE Id IN:contactList AND ZTS_EU_Market__c != 'United States']){
            
            system.debug('Privacy_Authorisation__c: '+c.Privacy_Authorisation__c+'   Authorization_Letter_Signed__c: '+c.Authorization_Letter_Signed__c);

            
                if(c.ZTS_EU_Country__c != 'Italy' && c.ZTS_EU_Market__c != 'Italy'){
                    c.Mkto_Sync_Permission__c = ''; 
                }
                else if(c.ZTS_EU_Country__c == 'Italy' || c.ZTS_EU_Market__c == 'Italy'){
                    if(c.Privacy_Authorisation__c == 'Si' && c.Authorization_Letter_Signed__c == 'Yes'){
                        c.Mkto_Sync_Permission__c = ''; 
                    }
                    else{
                        c.Mkto_Sync_Permission__c = 'disabled';
                    }
                }
                contactsToUpdate.add(c);
                
        }
        try {
                // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
                 Database.DMLOptions dml = new Database.DMLOptions(); 
                 dml.DuplicateRuleHeader.allowSave = true;
                 dml.DuplicateRuleHeader.runAsCurrentUser = true;
                 Database.update(contactsToUpdate,dml);
                 
                //update contactsToUpdate; -- commented for SC-008149
            } catch (DmlException e) {
                // Process exception here
                system.debug('Failed to update Contact in AccountUtility.syncOptOutField');
            } 
        return;
    }   
}