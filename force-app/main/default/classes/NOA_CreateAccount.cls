/**
 * @description       : 
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 05-25-2021
 * @last modified by  : Chelsea Paice @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   05-04-2021   Chelsea Paice @ Zoetis Inc     Adding Specialty Hospital questions/field mapping to Lead
 * 1.0   05-25-2021   Chelsea Paice @ Zoetis Inc     Adding header :P
**/
public class NOA_CreateAccount {
    
    public Lead newOnlineAcc{get;set;}
    public List<Account> existingAccts {get; set;} 
    public String selectedAccId {get;set;}
    public Account newAcc {get;set;}
    public List<SelectOption> statePicklist {get;set;}
    public Map<String,String> businessClassMap;
    public Map<String,String> contactProfMap {get;set;}
    public Map<String,String> contactJobFunMap {get;set;}

    public NOA_CreateAccount(ApexPages.StandardController stdController){  
        newOnlineAcc = (Lead)stdController.getRecord();
        newOnlineAcc = loadNOA(newOnlineAcc.Id);
        statePicklist = new List<SelectOption>();

        if(newAcc == null){
            newAcc = new Account();
        }     
        businessClassMap = new Map<String,String>();
        createBusinessClassMap();
        createContactProfJobMap();
        Schema.DescribeFieldResult fieldResult;
        // Slalom 06/29/20 - Lead StateCode is no longer a field in the org,
        // using a different state field to populate picklist.
        fieldResult = Account.ZTS_US_State_Province__c.getDescribe();//Lead.ZTS_US_State_Province__c.getDescribe();
        for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
            statePicklist.add(new SelectOption(p.getValue(),p.getLabel()));
        } 

        //prepare state dropdown
        /*if(statePicklist == null){
            statePicklist = new List<SelectOption>();
        }
        Schema.DescribeFieldResult fieldResult = Lead.StateCode.getDescribe();
        for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
            statePicklist.add(new SelectOption(p.getValue(),p.getLabel())); 
        }*/
        
        //Start of CR changes for account match
        String noaAcctName = null;
        System.debug('....Existing newOnlineAcc.Existing_Account_Name__c...' + newOnlineAcc.Existing_Account_Name__c);
        if(!String.isBlank(newOnlineAcc.Existing_Account_Name__c)){
            noaAcctName = '%' + newOnlineAcc.Existing_Account_Name__c + '%';
            existingAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                             BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Specialty_Description__c, Specialty_Hospital__c  
                             FROM Account WHERE ( Name like :noaAcctName ) AND ZTS_EU_Market__c = 'United States'  Limit 10];  
            List<Address__c> accAddrs =  [SELECT id,ZTS_EU_Account__c,ZTS_EU_Account__r.Name,ZTS_US_Source_Account_Number__c,
                                          ZTS_Address_Line_1__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Type__c,ZTS_EU_City__c,ZTS_County__c,
                                          ZTS_US_State_Province__c,Zip_Postal_Code__c,ZTS_US_Primary__c, ZTS_EU_Account__r.Specialty_Description__c, 
                                          ZTS_EU_Account__r.Specialty_Hospital__c 
                                          FROM Address__c  WHERE (ZTS_US_Source_Account_Number__c = :newOnlineAcc.Zoetis_Account__c  
                                                                  OR ((ZTS_EU_Address_Type__c LIKE '%Primary%' OR ZTS_EU_Address_Type__c LIKE '%Bill%' OR ZTS_EU_Address_Type__c LIKE '%Ship%') 
                                                                      AND( (ZTS_Address_Line_1__c = :newOnlineAcc.Billing_Street_1__c AND ZTS_EU_City__c = :newOnlineAcc.Billing_City__c 
                                                                            AND ZTS_US_State_Province__c = :newOnlineAcc.Billing_State__c AND Zip_Postal_Code__c = :newOnlineAcc.Billing_Zip_Code__c)
                                                                          OR (ZTS_Address_Line_1__c = :newOnlineAcc.Shipping_Street_1__c AND ZTS_EU_City__c = :newOnlineAcc.Shipping_City__c 
                                                                              AND ZTS_US_State_Province__c = :newOnlineAcc.Shipping_State__c AND Zip_Postal_Code__c = :newOnlineAcc.Shipping_Zip_Code__c)
                                                                         )  
                                                                     )
                                                                 )
                                          Limit 20];     
            if(accAddrs != null && accAddrs.size() > 0){
                List<Id> accIds = new List<Id>();
                for(Address__c ad : accAddrs){
                    accIds.add(ad.ZTS_EU_Account__c);
                }
                List <Account> additionalAccts = [SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,ZFS_Status__c,
                                                    Specialty_Description__c, Specialty_Hospital__c  
                                                  FROM Account WHERE id in :accIds AND ZTS_EU_Market__c = 'United States'];
                
                if(additionalAccts != null && additionalAccts.size() > 0){
                    if(existingAccts == null){
                        existingAccts = new List<Account>();
                    }
                    existingAccts.addAll(additionalAccts); 
                }
            }

        }
         
        //System.debug('....Existing Accounts...' + existingAccts); 
        newAcc.Name          = newOnlineAcc.Business_Name__c;
        newAcc.BillingStreet = newOnlineAcc.Billing_Street_1__c;
        newAcc.BillingCity = newOnlineAcc.Billing_City__c;
        newAcc.BillingCountry = 'United States';
        //newAcc.BillingCountryCode = 'US';
        newAcc.BillingState = newOnlineAcc.Billing_State__c;
        System.debug('....newAcc.BillingState... ' +  newAcc.BillingState); 
        newAcc.BillingPostalCode = newOnlineAcc.Billing_Zip_Code__c;
        newAcc.Specialty_Hospital__c = newOnlineAcc.Specialty_Hospital__c;
        if (newOnlineAcc.Specialty_Description__c != null) {
            //get lead picklist vals/labels because of Account/lead mismatch
            Schema.DescribeFieldResult leadField = Lead.Specialty_Description__c.getDescribe();
            List<Schema.PicklistEntry> leadPEs = leadField.getPicklistValues();
            Map<String,String> leadLabelMap = new Map<String,String>();
            for (Schema.PicklistEntry leadPE : leadPEs) {
                leadLabelMap.put(leadPE.getValue(),leadPE.getLabel());
            }
            newAcc.Specialty_Description__c = leadLabelMap.get(newOnlineAcc.Specialty_Description__c);
        }
        
    } 
    
    public void manageContact(Account acc){ 
        List<Contact> dupContacts = [SELECT id,Name,FirstName,LastName,Email,Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c FROM Contact WHERE FirstName = :newOnlineAcc.FirstName AND LastName = :newOnlineAcc.LastName
                                     AND (Email = :newOnlineAcc.Email OR Phone = :newOnlineAcc.Phone) AND ZTS_EU_Market__c = 'United States' LIMIT 5]; 
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
            newC.FirstName = this.newOnlineAcc.FirstName;
            newC.LastName = this.newOnlineAcc.LastName;
            newC.Phone = this.newOnlineAcc.Phone;
            newC.Interface_Email__c = this.newOnlineAcc.Email;
            newC.AccountId = acc.Id;
            //newC.ZTS_US_Profession__c = 'Staff';
            newC.ZTS_US_Profession__c = contactProfMap.get(this.newOnlineAcc.Applicant_Role__c);
            //newC.ZTS_US_Job_Function__c = 'Staff Specialist';
            newC.ZTS_US_Job_Function__c = contactJobFunMap.get(this.newOnlineAcc.Applicant_Role__c);
            try{
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
                 Database.DMLOptions dml = new Database.DMLOptions(); 
                 dml.DuplicateRuleHeader.allowSave = true;
                 dml.DuplicateRuleHeader.runAsCurrentUser = true;
                 Database.SaveResult sr = Database.insert(newC,dml);
                //insert newC; -- commented for SC-008149
            }catch(Exception ex){
                System.debug('Error creating New Contact ' + ex);            
            } 
        } 
    }
    
    public void manageVetContacts(Account acc){  
        List<Contact> contListTBI = new List<Contact>();
        List<ZTS_EU_Affiliations__c> contAFTBI = new List<ZTS_EU_Affiliations__c>();

        List<Veterinarian_Information__c> vetInforList = [SELECT ID,Lead__c,Veterinarian_First_Name__c,Veterinarian_Last_Name__c,Veterinarian_Email__c,Veterinarian_Role__c,Delete_Record__c
                                                          FROM Veterinarian_Information__c WHERE Lead__c = :newOnlineAcc.Id];
        if(vetInforList != null && vetInforList.size() > 0){
            List<String> fNameList = new List<String>();
            List<String> lNameList = new List<String>();
            List<String> emailList = new List<String>();
            for(Veterinarian_Information__c vet: vetInforList){
                fNameList.add(vet.Veterinarian_First_Name__c);
                lNameList.add(vet.Veterinarian_Last_Name__c);
                emailList.add(vet.Veterinarian_Email__c);
                
            } 
            system.debug('VetFirstName'+fNameList);
            system.debug('VetLastName'+lNameList);
             system.debug('VetEmail'+emailList);
            
            List<Contact> dupVetContacts = [SELECT id,Name,FirstName,LastName,Email,Phone,ZTS_US_Profession__c,ZTS_US_Job_Function__c FROM Contact WHERE FirstName IN :fNameList AND LastName IN :lNameList
                                            AND Email IN :emailList AND ZTS_EU_Market__c = 'United States' LIMIT 100];  
            system.debug('Check duplicate list'+dupVetContacts);
            if(dupVetContacts != null && dupVetContacts.size() > 0){
                
                for(Veterinarian_Information__c vet: vetInforList){
                    for(Contact con: dupVetContacts){
                        if(con.FirstName == vet.Veterinarian_First_Name__c && con.LastName == vet.Veterinarian_Last_Name__c && con.Email == vet.Veterinarian_Email__c ){
                            Contact cont = con;
                            ZTS_EU_Affiliations__c contAff = new ZTS_EU_Affiliations__c();
                            contAff.Name = cont.Name + '@' + acc.Name;
                            contAff.ZTS_EU_Account__c = acc.Id;
                            contAff.ZTS_EU_Contact__c = cont.Id;
                            contAff.ZTS_US_Profession__c = cont.ZTS_US_Profession__c;
                            contAff.ZTS_US_Job_Function__c = cont.ZTS_US_Job_Function__c;
                            contAFTBI.add(contAff); 
                            vet.Delete_Record__c = true;
                            break;
                        }
                    }//end of cont for loop
                    if(vet.Delete_Record__c == null || vet.Delete_Record__c == false){
                        Contact newC = new Contact();
                        newC.FirstName = vet.Veterinarian_First_Name__c;
                        newC.LastName = vet.Veterinarian_Last_Name__c; 
                        newC.Interface_Email__c = vet.Veterinarian_Email__c;
                        newC.AccountId = acc.Id;
                        newC.ZTS_US_Profession__c = 'Veterinarian';
                        if(vet.Veterinarian_Role__c != null && vet.Veterinarian_Role__c == 'Owner'){
                            newC.ZTS_US_Job_Function__c = 'Owner';
                        }else{
                            newC.ZTS_US_Job_Function__c = 'Associate Vet';
                        }
                        contListTBI.add(newC);
                        vet.Delete_Record__c = true;
                    }
                }// end of vet for loop
                
            }//end of duplicates if
            
            //below code is for any remaining vets
            for(Veterinarian_Information__c vet: vetInforList){
                if(vet.Delete_Record__c == null || vet.Delete_Record__c == false){
                    Contact newC = new Contact();
                    newC.FirstName = vet.Veterinarian_First_Name__c;
                    newC.LastName = vet.Veterinarian_Last_Name__c; 
                    newC.Interface_Email__c = vet.Veterinarian_Email__c;
                    newC.AccountId = acc.Id;
                    newC.ZTS_US_Profession__c = 'Veterinarian';
                    if(vet.Veterinarian_Role__c != null && vet.Veterinarian_Role__c == 'Owner'){
                        newC.ZTS_US_Job_Function__c = 'Owner';
                    }else{
                        newC.ZTS_US_Job_Function__c = 'Associate Vet';
                    }
                    contListTBI.add(newC);
                    vet.Delete_Record__c = true;
                } 
            }   //end of for loop for remaining vets logic
            
            //inserting Contacts prepared above
            if(contListTBI.size() > 0){
                try{
                    //Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
                     Database.DMLOptions dml = new Database.DMLOptions(); 
                     dml.DuplicateRuleHeader.allowSave = true;
                     dml.DuplicateRuleHeader.runAsCurrentUser = true;
                     List<Database.SaveResult> sr = Database.insert(contListTBI,dml);
                    //insert contListTBI;-- commented for SC-008149
                }catch(Exception ex){
                    System.debug('....contListTBI...contact list to be inserted...' + contListTBI);
                    System.debug('Error creating contacts ' + ex);            
                } 
            }
            //inserting Contact Affiliations prepared above
            if(contAFTBI.size() > 0){
                try{
                    insert contAFTBI;
                }catch(Exception ex){
                    System.debug('....contAFTBI...contact list to be inserted...' + contAFTBI);
                    System.debug('Error creating Contact Affiliations ' + ex);            
                } 
            }
            
        }   //end of main if
    }// end of manage contacts method
    
    public PageReference createNewAccount(){  
        if(String.isBlank(newAcc.Name) || String.isBlank(newAcc.BillingStreet) || String.isBlank(newAcc.BillingCity) || String.isBlank(newAcc.BillingState) || String.isBlank(newAcc.BillingPostalCode)){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All fields are mandatory. Please enter missing information.'));
            return null;
        }
        try{ 
            if(String.isNotBlank(this.newOnlineAcc.Customer_Type__c) && this.newOnlineAcc.Customer_Type__c != 'Other'){
                newAcc.ZTS_US_Business_Class__c = businessClassMap.get(this.newOnlineAcc.Customer_Type__c);
                if(this.newOnlineAcc.Customer_Type__c == 'Mobile Practice'){
                    newAcc.ZTS_US_Sub_Class_1__c = 'Mobile Vet';
                }
            }else if(String.isNotBlank(this.newOnlineAcc.Type_of_Business__c)){
                newAcc.ZTS_US_Business_Class__c = businessClassMap.get(this.newOnlineAcc.Type_of_Business__c);
            }
            insert newAcc;  
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating new account for New Online Account process. ' + ex)); 
            return null;
        }
        System.debug('....New Account Inserted....' + newAcc.Id);
        manageContact(newAcc);
        manageVetContacts(newAcc);
        try{
            this.newOnlineAcc.Account_ID__c = newAcc.Id;
            this.newOnlineAcc.isNewAccCreatedFlag__c = true;         
            update this.newOnlineAcc;
            PageReference pageRef = new PageReference('/'+newAcc.Id);  
            pageRef.setRedirect(true);
            return pageRef;  
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating Lead record with newly created account'));                     
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
            
             system.debug('selected account Id-->'+selectedAccId);
            
            
            
            if(selAccount != null && selAccount.Id != null && isupdate){ 
                this.newOnlineAcc.Account_ID__c = selAccount.Id;
                this.newOnlineAcc.isNewAccCreatedFlag__c = false;
                manageContact(selAccount);
                manageVetContacts(selAccount);
                try{ 
                    update newOnlineAcc;
                }catch(Exception ex){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error selecting existing account'));                     
                    return null;
                }
                
                PageReference pageRef = new PageReference('/' + newOnlineAcc.Id);  
                return pageRef;
            }
        }     
        return null;
    }
    
    public Lead loadNOA(Id id){  
        Lead noaLead = null;
        try{
           noaLead = [SELECT Id,Name,Salutation,FirstName,LastName,NOA_Application_Number__c, Step_Number__c,Email, Phone,  Company,Business_Name__c,Customer_Type__c,Customer_Type_Other__c,
                            Small_Animal__c, Equine__c, Beef__c,    Dairy__c,   Swine__c,   Feed__c,    Poultry__c, Eggs__c,    Turkey__c,  Broiler__c, 
                            Shipping_Street_1__c,   Shipping_Street_2__c,   Shipping_County__c, Shipping_City__c,   Shipping_State__c,  
                            Shipping_Zip_Code__c,   Shipping_Phone__c,  Shipping_Fax__c,    Shipping_Email__c,  Billing_Street_1__c,    
                            Billing_Street_2__c,    Billing_County__c,  Billing_City__c,    Billing_State__c,   Billing_Zip_Code__c,Type_of_Business__c,    
                            Billing_Phone__c,   Billing_Fax__c, Billing_Email__c,   Existing_account_with_Zoetis_at_this_Loc__c,Authorization_Email__c, 
                            Ownership_Change__c,    Date_of_Ownership_Change__c,    Existing_account_with_Zoetis__c,   Existing_Account_Name__c, Zoetis_Account__c,Applicant_Role__c, 
                            Specialty_Description__c, Specialty_Hospital__c                               
                            FROM Lead where Id = :id AND Market__c = 'United States'  LIMIT 1][0]; 
        }catch(Exception e){
            noaLead = null;
        }
        System.debug('noaLead   ::::: ' + noaLead);
        System.debug('noaLead   ::::: ' + noaLead.Billing_State__c);
        return noaLead; 
    } 

    public void createBusinessClassMap(){
        if(businessClassMap == null || businessClassMap.isEmpty()){
            businessClassMap.put('Vet Practice','Veterinarian');
            businessClassMap.put('University','University/College');
            businessClassMap.put('Non-Profit','Government/Non-Profit');
            businessClassMap.put('Government / Military','Government/Non-Profit');
            businessClassMap.put('Mobile Practice','Veterinarian'); 
            businessClassMap.put('Diagnostic Laboratory','Diagnostic');
            businessClassMap.put('Reproduction Services','Breeder');  
        }
    }
    
    public void createContactProfJobMap(){
        if(contactProfMap == null || contactProfMap.isEmpty()){
            contactProfMap = new Map<String, String>();
            contactProfMap.put('Owner','Executive Leadership');
            contactProfMap.put('Veterinarian – Owner','Veterinarian');
            contactProfMap.put('Veterinarian – Associate','Veterinarian');
            contactProfMap.put('Receptionist','Staff');
            contactProfMap.put('Technician','Technician');
            contactProfMap.put('Practice / Purchasing / Procurement Manager','Manager/Sr. Manager');
        }
        
        if(contactJobFunMap == null || contactJobFunMap.isEmpty()){
            contactJobFunMap = new Map<String, String>();
            contactJobFunMap.put('Owner','Owner');
            contactJobFunMap.put('Veterinarian – Owner','Owner');
            contactJobFunMap.put('Veterinarian – Associate','Associate Vet');
            contactJobFunMap.put('Receptionist','Admin Asst/Recep.');
            contactJobFunMap.put('Technician','Vet Technician');
            contactJobFunMap.put('Practice / Purchasing / Procurement Manager','Practice/Office/Hospital Mgr.');
        }
    }

}