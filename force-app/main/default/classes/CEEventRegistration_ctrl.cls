public class CEEventRegistration_ctrl {
    public String einviteID {get;set;}
    public String eventID {get;set;} 
    public ZTS_US_Event_Invitee__c eventAttendee {get;set;} 
    public ZTS_US_Event_Invitee__c newEventAttendee;
    public Contact newInviteeContact{get;set;}
    public String selAccount {get;set;} 
    public List<SelectOption> AccountList{get;set;}  
    public ZTS_Events__c eventInfo {get;set;}
    public String startDateTime {get;set;}
    public String endDateTime {get;set;}
    public String eventOwnerName {get;set;}
    public String eventOwnerEmail {get;set;}   
    public List<SelectOption> prefix {get;set;}
    public boolean registrtionFlag {get;set;} 
    public boolean hasErrorsFlag {get;set;} 
    public String ecId {get;set;}
    public boolean smsOptIn {get;set;}
    
    public CEEventRegistration_ctrl(ApexPages.StandardController controller) {
        if(eventID == null){
            eventID = ApexPages.currentPage().getParameters().get('eid');    
        }
        if(einviteID == null){
            einviteID = ApexPages.currentPage().getParameters().get('eaid');
        } 
        registrtionFlag = false;
        hasErrorsFlag = false;
        Schema.DescribeFieldResult fieldResult = null;
        prefix = new List<SelectOption>();
        System.debug('...Event Id...' + eventID);
        System.debug('...Event Attendee Id...' + einviteID);
        if(eventId != null){ 
            List<ZTS_Events__c> eventList = [SELECT Id,Name,OwnerId,Speaker_ID_1__r.Name,Speaker_ID_1__r.Speaker_Bio__c,Speaker_ID_1__r.Speaker_Bio_Rich_Text__c,
                                             Speaker_ID_2__r.Speaker_Bio__c,Speaker_ID_2__r.Name,Speaker_ID_2__r.Speaker_Bio_Rich_Text__c,
                                             Speaker_ID_3__r.Speaker_Bio__c,Speaker_ID_3__r.Speaker_Bio_Rich_Text__c,Speaker_ID_3__r.Name,
                                             ZTS_US_Name__c,ZTS_US_Location__c,of_CE_credits__c,Purpose_Agenda__c,ZTS_US_Start_Date__c,ZTS_US_End_Date__c
                                             FROM ZTS_Events__c WHERE id = :eventId AND ZTS_EU_Market__c = 'United States'];
            if(eventList != null && eventList.size() > 0){
                eventInfo = eventList[0];
                User eventOwnerUser = [Select Name,TimeZoneSidKey,Email from User where id =:eventInfo.OwnerId AND ZTS_EU_Market__c  = 'United States'];
                eventOwnerName = eventOwnerUser.Name;
                eventOwnerEmail = eventOwnerUser.Email;
                startDateTime = eventInfo.ZTS_US_Start_Date__c.format('MMM.dd.YYYY h:mm a z', eventOwnerUser.TimeZoneSidKey);
                endDateTime = eventInfo.ZTS_US_End_Date__c.format('MMM.dd.YYYY h:mm a z', eventOwnerUser.TimeZoneSidKey);
                if(AccountList == null){
                    List<ZTS_US_Event_Account__c> eventAccounts = [select id, name, ZTS_US_Events__c, ZTS_US_Event_Account__r.Id,ZTS_US_Event_Account__r.Name from ZTS_US_Event_Account__c where ZTS_US_Events__c = :eventID ];
                    AccountList = new List<SelectOption>(); 
                    AccountList.add(new SelectOption('Please Select', 'Please Select')); 
                    for(ZTS_US_Event_Account__c ea : eventAccounts) {
                        AccountList.add(new SelectOption(ea.ZTS_US_Event_Account__r.Id, ea.ZTS_US_Event_Account__r.Name)); 
                    }  
                    System.debug('...SK Account List...' + AccountList);
                }
                fieldResult = Contact.Salutation.getDescribe();
                for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
                    prefix.add(new SelectOption(p.getValue(), p.getValue())); 
                }
            }  else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Invalid Event Registratoin Link'));
                hasErrorsFlag = true;
                return;
            }
            if(einviteID != null){  
                List<ZTS_US_Event_Invitee__c> evAttendeesList= [SELECT Id, ZTS_US_Event_Name__c,ZTS_US_Invitation_Status__c,ZTS_US_Contact__c,ZTS_US_Event_Invitee_First_Name__c,
                                                                ZTS_US_Event_Invitee_Last_Name__c,ZTS_US_Contact__r.phone,ZTS_US_Contact__r.MobilePhone,ZTS_US_Contact__r.email,ZTS_US_Contact__r.ZTS_US_Profession__c,ZTS_US_Contact__r.ZTS_US_Job_Function__c, ZTS_US_Event_Invitee_Account_Name__c,
                                                                ZTS_US_Event__r.ZTS_US_Name__c,ZTS_US_Event__r.ZTS_US_Location__c,ZTS_US_Event__r.Purpose_Agenda__c,ZTS_US_Event__r.ZTS_US_Start_Date__c,ZTS_US_Event__r.ZTS_US_End_Date__c,
                                                                SMS_Text_Opt_In__c
                                                                FROM ZTS_US_Event_Invitee__c 
                                                                WHERE id = :einviteID
                                                                  AND ZTS_EU_Market__c = 'United States' 
                                                                LIMIT 1];
                if(evAttendeesList != null && evAttendeesList.size() > 0){
                    eventAttendee = evAttendeesList[0];  
                    eventAttendee.Id = null;
                    this.smsOptIn = eventAttendee.SMS_Text_Opt_In__c;
                    if(eventAttendee.ZTS_US_Invitation_Status__c != null && eventAttendee.ZTS_US_Invitation_Status__c == 'Registered'){
                        registrtionFlag = true;
                        hasErrorsFlag = false; 
                        //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'You have already registered.'));
                        return;
                    }
                    List<Contact> conDetails  = [select Id,AccountId,Account.Name,Salutation,FirstName,LastName,Phone,MobilePhone,Email,Interface_Email__c,ZTS_US_Profession__c,ZTS_US_Job_Function__c from Contact WHERE id = :eventAttendee.ZTS_US_Contact__c AND ZTS_EU_Market__c = 'United States' limit 1];
                    if(conDetails != null && conDetails.size() > 0){
                        newInviteeContact = conDetails[0];
                        ecId = newInviteeContact.Id;
                        newInviteeContact.Id = null;                        
                        selAccount = newInviteeContact.AccountId;   
                    }  
                }else{
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Invalid Event Registration Link'));
                    hasErrorsFlag = true;
                    return;
                }
            }else{
                newInviteeContact = new Contact();  
                if(eventInfo != null){ 
                    newEventAttendee = new ZTS_US_Event_Invitee__c();
                    newEventAttendee.ZTS_US_Event__c = eventInfo.Id;  
                } else{
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Invalid Event Registration Link'));
                    hasErrorsFlag = true;
                    return;
                }
            }
        }else{
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Invalid Event Registration Link'));
            hasErrorsFlag = true; 
            return;
        } 
    }   

    public boolean validate(){
        boolean isValid = true;
        if (newInviteeContact != null){
            System.debug(newInviteeContact.firstName + '::' + newInviteeContact.lastName + '::' + newInviteeContact.Interface_Email__c );
            if(einviteID == null && String.isBlank(newInviteeContact.firstName)){  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'First Name is Mandatory'));
                isValid = false;
            }
            if(einviteID == null && String.isBlank(newInviteeContact.lastName)){  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Last Name is Mandatory'));
                isValid = false;
            }
            if(String.isBlank(newInviteeContact.Interface_Email__c)){  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Email is Mandatory'));
                isValid = false;
            }
            if(einviteID == null && (selAccount == null || selAccount == 'Please Select')){  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Account is Mandatory'));
                isValid = false;
            }
            if(newInviteeContact.ZTS_US_Profession__c == null){  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Professoin is Mandatory'));
                isValid = false;
            }
            if(newInviteeContact.ZTS_US_Job_Function__c== null){  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Job Function is Mandatory'));
                isValid = false;
            }
        }
        return isValid;
    }    
    public PageReference register(){    
        if(!validate()){
            registrtionFlag = false;
            return null;
        } 
        if(einviteID != null){   
            try{
                newInviteeContact.Id = ecId; 
                update newInviteeContact;
            }catch(Exception e){
                System.debug('Error updating CE Event Invited Attendee Contact Information ');
                ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.Error, 'Error Registeing Event Invitee.'));
                if (newInviteeContact != null) newInviteeContact.Id = null;
                hasErrorsFlag = true; 
                return null;
            } 
            eventAttendee.ZTS_US_Invitation_Status__c = 'Registered'; 
            eventAttendee.SMS_Text_Opt_In__c = this.smsOptIn;
            try{
                eventAttendee.Id = einviteID;
                update eventAttendee;
            }catch(Exception e){
                System.debug('Error updating CE Event Invited Attendee Contact Information...');
                ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.Error, 'Error Registeing Event Invitee.'));
                newInviteeContact.Id = null;
                hasErrorsFlag = true; 
                return null;
            } 
                        
            registrtionFlag = true;
            hasErrorsFlag = false; 
            //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Registration Successfull.'));
            return null; 
            
        }else {
            //search Account Contacts for duplicate
            List<Contact> dupContacts = [SELECT id,Name,Salutation,AccountId,FirstName,LastName,Email,Interface_Email__c,Phone,MobilePhone,ZTS_US_Profession__c,ZTS_US_Job_Function__c
                                         FROM Contact WHERE AccountId = :selAccount AND FirstName = :newInviteeContact.FirstName AND LastName = :newInviteeContact.LastName
                                         AND (Email = :newInviteeContact.Interface_Email__c OR Phone = :newInviteeContact.Phone OR MobilePhone = :newInviteeContact.MobilePhone) AND ZTS_EU_Market__c = 'United States' LIMIT 5]; 
            if(dupContacts != null && dupContacts.size() > 0){
                newInviteeContact = dupContacts[0];
            }else{
                try{ 
                    newInviteeContact.AccountId = selAccount;
                    System.debug('...Contact...' + newInviteeContact);
                    insert newInviteeContact;     
                }catch(Exception ex){
                    System.debug('Error inserting invitee contact' + ex);
                    ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.Error, 'Error Registeing Event Invitee!'));
                    hasErrorsFlag = true; 
                    return null;
                }
            }
            
            ZTS_US_Event_Invitee__c newEA = new ZTS_US_Event_Invitee__c();
            newEA.ZTS_US_Event__c = eventID;
            newEA.ZTS_US_Contact__c = newInviteeContact.Id;        
            newEA.ZTS_US_Invitation_Status__c = 'Registered';
            newEA.SMS_Text_Opt_In__c = this.smsOptIn;
            try{ 
                insert newEA;     
            }catch(Exception ex){ 
                System.debug('Error inserting Event Invitee' + ex);
                ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.Error, 'Error Registeing Event Invitee.'));
                hasErrorsFlag = true; 
                return null;
            }
            
            registrtionFlag = true;
            hasErrorsFlag = false; 
            //ApexPages.addMessage(new apexPages.Message(ApexPages.Severity.INFO, 'Registration Successfull.'));            
            return null;
        } 
        
    }
}//end of class