/**
 * @description Controller class for ZFS_CreateAccount Visualforce page. This page can setup or link a new Lead, 
 *              converted to a Contact, to a new or existing Shelter.
 * @author Unknown (Cognizant?)
 * @since 07-29-2020
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-29-2020   Unknown                     Initial Version (SC-008123 possibly)
 * 1.1   01-09-2023   Ethan Hirsch @ Zoetis Inc   Remove the update to selAccount in the submit method. 
 *                                                This previously set ZFS_Status__c to Member, but this logic was commented out 
 *                                                resulting in this update being unnecessary.
 */
public class ZFS_CreateAccount {
    public Lead shelter{get;set;}
    public List<Account> existingAccts {get; set;}
    //public List<USAccountWrapper> accWrapperList {get;set;}
    public String selectedAccId {get;set;}
    public Account newAcc {get;set;}
    public List<SelectOption> statePicklist {get;set;}

    public ZFS_CreateAccount(ApexPages.StandardController stdController){  
        shelter = (Lead)stdController.getRecord();
        shelter = loadShelter(shelter.Id);
        statePicklist = new List<SelectOption>();

        if(newAcc == null){
            newAcc = new Account();
        }
        Schema.DescribeFieldResult fieldResult;
        // Slalom 06/29/20 - Lead StateCode is no longer a field in the org,
        // using a different state field to populate picklist.
        fieldResult = Lead.ZTS_US_State_Province__c.getDescribe();
        for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
            statePicklist.add(new SelectOption(p.getValue(),p.getLabel()));
        }      
        //prepare state dropdown
        if(statePicklist == null){
            statePicklist = new List<SelectOption>();
        }
        //Schema.DescribeFieldResult fieldResult = Lead.StateCode.getDescribe();
        //for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
        //   statePicklist.add(new SelectOption(p.getValue(),p.getLabel())); 
        //}
        
        //Start of CR changes for account match
        String shelterAcctName = null;
        if(!String.isBlank(shelter.Shelter_Account_Name__c)){
            shelterAcctName = '%' + shelter.Shelter_Account_Name__c + '%';
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                             FROM Account WHERE ( Name like :shelterAcctName ) AND ZTS_EU_Market__c = 'United States'  Limit 10];  
            
            List<Address__c> accAddrs =  [SELECT id,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_US_Source_Account_Number__c,
                                          ZTS_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Type__c,ZTS_EU_City__c,ZTS_County__c,
                                          ZTS_US_State_Province__c,Zip_Postal_Code__c,ZTS_US_Primary__c 
                                          FROM Address__c  WHERE (ZTS_US_Source_Account_Number__c = :shelter.Zoetis_Account__c  
                                                                  OR ((ZTS_EU_Address_Type__c LIKE '%Primary%' OR ZTS_EU_Address_Type__c LIKE '%Bill%' OR ZTS_EU_Address_Type__c LIKE '%Ship%') 
                                                                      AND( (ZTS_Address_Line_1__c = :shelter.Billing_Street_1__c AND ZTS_EU_City__c = :shelter.Billing_City__c 
                                                                            AND ZTS_US_State_Province__c = :shelter.Billing_State__c AND Zip_Postal_Code__c = :shelter.Billing_Zip_Code__c)
                                                                          OR (ZTS_Address_Line_1__c = :shelter.Shipping_Street_1__c AND ZTS_EU_City__c = :shelter.Shipping_City__c 
                                                                              AND ZTS_US_State_Province__c = :shelter.Shipping_State__c AND Zip_Postal_Code__c = :shelter.Shipping_Zip_Code__c)
                                                                         )  
                                                                     )
                                                                 )
                                          Limit 20];       
            if(accAddrs != null && accAddrs.size() > 0){
                List<Id> accIds = new List<Id>();
                for(Address__c ad : accAddrs){
                    accIds.add(ad.ZTS_EU_Account__c);
                }
                List <Account> additionalAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,ZFS_Status__c 
                                                  FROM Account WHERE id in :accIds AND ZTS_EU_Market__c = 'United States'];
                if(additionalAccts != null && additionalAccts.size() > 0){
                    if(existingAccts == null){
                        existingAccts = new List<Account>();
                    }
                    existingAccts.addAll(additionalAccts); 
                }
            }

        }
        //End of CR changes for account match
        /*
        //checking billing address match
        String shelterAccName = null;
        if(!String.isBlank(shelter.Shelter_Account_Name__c)){
            shelterAccName = '%' + shelter.Shelter_Account_Name__c + '%';
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry 
                             FROM Account WHERE ( Name like :shelterAccName ) 
                             OR ( BillingStreet = :shelter.Billing_Street_1__c AND BillingCity = :shelter.Billing_City__c 
                                  AND BillingState = :shelter.Billing_State__c AND BillingPostalCode = :shelter.Billing_Zip_Code__c) 
                              OR ( ShippingStreet = :shelter.Shipping_Street_1__c AND ShippingCity = :shelter.Shipping_City__c 
                                  AND ShippingState = :shelter.Shipping_State__c AND ShippingPostalCode = :shelter.Shipping_Zip_Code__c)
                            AND ZTS_EU_Market__c = 'United States'
                             Limit 20];  
        }else{
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry ,ZFS_Status__c
                             FROM Account WHERE ( Name like :shelterAccName ) 
                             OR ( BillingStreet = :shelter.Billing_Street_1__c AND BillingCity = :shelter.Billing_City__c 
                                  AND BillingState = :shelter.Billing_State__c AND BillingPostalCode = :shelter.Billing_Zip_Code__c) 
                             OR ( ShippingStreet = :shelter.Shipping_Street_1__c AND ShippingCity = :shelter.Shipping_City__c 
                                  AND ShippingState = :shelter.Shipping_State__c AND ShippingPostalCode = :shelter.Shipping_Zip_Code__c)
                             AND ZTS_EU_Market__c = 'United States'
                             Limit 20];  
        }
        //checking SAP# match
        if(!String.isBlank(shelter.Zoetis_Account__c)){
            List<Address__c> accAddrs =  [select id,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_US_Source_Account_Number__c 
                                          from Address__c  where ZTS_US_Source_Account_Number__c = :shelter.Zoetis_Account__c Limit 10];       
            if(accAddrs != null && accAddrs.size() > 0){
                List<Id> accIds = new List<Id>();
                for(Address__c ad : accAddrs){
                    accIds.add(ad.ZTS_EU_Account__c);
                }
                List <Account> additionalAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,ZFS_Status__c 
                                                  FROM Account WHERE id in :accIds AND ZTS_EU_Market__c = 'United States'];
                if(additionalAccts != null && additionalAccts.size() > 0){
                    if(existingAccts == null){
                        existingAccts = new List<Account>();
                    }
                    existingAccts.addAll(additionalAccts); 
                }
            }
        }        
        */
        System.debug('....Existing Accounts...' + existingAccts); 
        newAcc.BillingStreet = shelter.Billing_Street_1__c;
        newAcc.BillingCity = shelter.Billing_City__c;
        newAcc.BillingCountry = 'United States';
        //newAcc.BillingCountryCode = 'US';
        newAcc.BillingState = shelter.Billing_State__c;
        newAcc.BillingPostalCode = shelter.Billing_Zip_Code__c;
    } 
    
    public void manageContact(Account acc){ 
        List<Contact> dupContacts = [SELECT id,Name,FirstName,LastName,Email,Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c FROM Contact WHERE FirstName = :shelter.FirstName AND LastName = :shelter.LastName
                                     AND (Email = :shelter.Email OR Phone = :shelter.Phone) AND ZTS_EU_Market__c = 'United States' LIMIT 5]; 
        if(dupContacts != null && dupContacts.size() > 0){
            Contact cont = dupContacts[0];
            ZTS_EU_Affiliations__c contAff = new ZTS_EU_Affiliations__c();
            contAff.Name = cont.Name + '@' + acc.Name;
            contAff.ZTS_EU_Account__c = acc.Id;
            contAff.ZTS_EU_Contact__c = cont.Id;
            contAff.ZTS_US_Profession__c = cont.ZTS_US_Profession__c;
            contAff.ZTS_US_Job_Function__c = cont.ZTS_US_Job_Function__c;
            try{
                insert contAff;
            }catch(Exception ex){
                System.debug('Error creating Contact Affiliation ' + ex);            
            }
        }else{
            Contact newC = new Contact();
            newC.FirstName = this.shelter.FirstName;
            newC.LastName = this.shelter.LastName;
            newC.Phone = this.shelter.Phone;
            newC.Interface_Email__c = this.shelter.Email;
            newC.AccountId = acc.Id;
            newC.ZTS_US_Profession__c = 'Staff';
            newC.ZTS_US_Job_Function__c = 'Staff Specialist';
            try{
                // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 				Database.DMLOptions dml = new Database.DMLOptions(); 
 				dml.DuplicateRuleHeader.allowSave = true;
 				dml.DuplicateRuleHeader.runAsCurrentUser = true;
 				Database.SaveResult sr = Database.insert(newC,dml);
                //insert newC;-- commented for SC-008149
                
            }catch(Exception ex){
                System.debug('Error creating New Contact ' + ex);            
            } 
        } 
    }
    
    public PageReference createNewAccount(){  
        if(String.isBlank(newAcc.Name) || String.isBlank(newAcc.BillingStreet) || String.isBlank(newAcc.BillingCity) || String.isBlank(newAcc.BillingState) || String.isBlank(newAcc.BillingPostalCode)){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All fields are mandatory. Please enter missing information.'));
            return null;
        }
        try{
            //newAcc.ZFS_Status__c = 'Member';
            newAcc.ZTS_US_Business_Class__c = 'Government/Non-Profit';
            newAcc.ZTS_US_Sub_Class_1__c = 'Zoo, SPCA, Humane Society';
            system.debug('newAcc ID :::'+ newAcc.Id);
            insert newAcc;  
        }catch(Exception ex){
            system.debug('Exception -->'+ ex.getMessage());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating new account'));                     
            return null;
        }
        System.debug('....New Account Inserted....' + newAcc.Id);
        manageContact(newAcc);
        try{
            this.shelter.Account_ID__c = newAcc.Id;
            this.shelter.isNewAccCreatedFlag__c = true;
            //this.shelter.Status = 'Member';   //commented for CR
            //this.shelter.Shelter_Member_Date__c = System.Today();     //commented for CR
            update this.shelter;
            PageReference pageRef = new PageReference('/'+newAcc.Id);  
            pageRef.setRedirect(true);
            return pageRef;  
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating shelter record with newly created account'));                     
            return null;
        }
        //return null;
    }
    
    public PageReference submit(){
        if(String.isBlank(selectedAccId)){ 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an account before clicking Submit'));                     
            return null;
        }
        System.debug('...Selected Account Id...' + selectedAccId);
        Account selAccount = null;
        if(selectedAccId != null && selectedAccId.length() > 0){
            boolean isupdate = false;
            for(Account acc: existingAccts){
                if(acc.Id == selectedAccId){
                    selAccount = acc;
                    isupdate = true;
                    break;
                }
            } 
            if(selAccount != null && selAccount.Id != null && isupdate){ 
                this.shelter.Account_ID__c = selAccount.Id;
                //this.shelter.Status = 'Member';
                this.shelter.isNewAccCreatedFlag__c = false;
                manageContact(selAccount);
                try{ 
                    update shelter;
                }catch(Exception ex){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error selecting existing account'));                     
                    return null;
                }
                
                PageReference pageRef = new PageReference('/' + shelter.Id);  
                return pageRef;
            }
        }     
        return null;
    }
    
    public Lead loadShelter(Id id){  
        Lead shelterLead = null;
        try{
           shelterLead  = [SELECT Id,Salutation, FirstName, LastName, Email, Phone, MobilePhone, Shelter_Name__c, Shelter_Website__c, 
                                Type_of_Organization__c, If_Other_please_describe__c, annual_cat_dog__c, Do_you_currently_purchase_from_Zoetis__c, 
                                Existing_account_with_Zoetis__c, Account_Prefix__c, Account_First_Name__c, Account_Last_Name__c, Shelter_Account_Name__c, 
                                Zoetis_Account__c, How_did_you_hear_about_us2__c, Puppy_Intakes_Yr__c, Dog_Intakes_Yr__c, 
                                Puppy_Adoptions_Yr__c, Dog_Adoptions_Yr__c, Kitten_Intakes_Yr__c, Cat_Intakes_Yr__c, Kitten_Adoptions_Yr__c, 
                                Cat_Adoptions_yr__c, Does_org_perform_Spay_Neuter_operations__c, Estimated_S_N_performed_average_yr__c, Principal_Bank_Name__c,
                                Principal_Bank_Phone__c, Trade_Reference_1_Company_Name__c, Trade_Reference_1_Company_Phone__c,
                                Trade_Reference_2_Company_Name__c, Trade_Reference_2_Company_Phone__c, Trade_Reference_3_Company_Name__c, 
                                Trade_Reference_3_Company_Phone__c, Sales_Tax_Status_Type__c, Sales_Tax_Status__c, Tax_Permit__c, Shelter_Application_Number__c, 
                                Step_Number__c, Vet_Prefix__c, Vet_First_Name__c, Vet_Last_Name__c, DVM_Phone__c, DVM_Address__c, DVM_Address_2__c, 
                                DVM_City__c, DVM_County__c, DVM_State__c, DVM_Zip__c, DVM_Email__c, DVM_Fax__c, DVM_ST__c,Contact_Prefix__c,Contact_Phone__c,Contact_Email__c,
                                Contact_Fax__c,Billing_Street_1__c,Billing_Street_2__c,Billing_City__c,Billing_County__c,Billing_Country__c,Billing_State__c,Billing_Zip_Code__c,Shipping_Address_Type__c,Shipping_Street_1__c,
                                Shipping_Street_2__c,Shipping_City__c,Shipping_County__c,Shipping_Country__c,Shipping_State__c,Shipping_Zip_Code__c,
                                Contact_Preference__c,Do_you_have_a_licensed_veterinarian__c,In_House_Clinic__c,Authorization_Flag__c,I_agree_to_the_terms_and_conditions__c
                                FROM Lead where Id = :id AND Market__c = 'United States'][0]; 
        }catch(Exception e){
            shelterLead = null;
        }
        return shelterLead; 
    }

}