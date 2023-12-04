/**
 * @description       : Controller for the Zoetis for Shelters Guest Website
 * @author            : Unknown
 * @group             :
 * @last modified on  : 09-12-2022
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   Unknown      Unknown                       Initial Version
 * 1.1   05-14-2021   Morgan Marchese @ ZTS         Prettier Formatter. Changed Customer Facing Error Messages.
 * 1.2   09-06-2022   Morgan Marchese @ ZTS         Added RemoteAction Method for User Elevation
 * 1.3   08-16-2023   Pooja R @CTS					Added TPDEV-1355 Changes on creating new fields in basic information page and ZFS_QualificationCriteria page and also they requested to remove ZFS_References page.									      
 **/
public without sharing class ZoetisForShelters {
    public Lead shelter { get; set; }
    public List<SelectOption> prefix { get; set; }
    public List<SelectOption> shelterType { get; set; }
    public List<SelectOption> salesTaxStatusType { get; set; }
    public List<SelectOption> shippingAddressType { get; set; }
    public List<SelectOption> salesTaxStatus { get; set; }
    public List<SelectOption> statePicklist { get; set; }
	public List<SelectOption> hearAboutZoeties { get; set; }
    public String applicationNo { get; set; }
    public Id LeadId { get; set; }
    public Id recordTypeId;
    public Id agreementId { get; set; }
    public String pageName { get; set; }
    public String nextPage;
    public String prevPage;
    public String pageMessage { get; set; }
    public Id shelterRecTypeId;
    //public Boolean cont{get;set;}
    public boolean hasErrors { get; set; }
    public boolean submitted { get; set; }
    public boolean readonly { get; set; }
    public Boolean triggerESign { get; set; }
    public string requiredMessage = 'Required information missing';
    private static final String TEAM_EMAIL = 'ShelterTeam@zoetis.com';
    private static final String TEAM_PHONE = '1-866-225-9777';
    private static final String SOMETHING_WENT_WRONG = 'Oops! Something went wrong, application was not saved successfully. Please try again.';
    private static final String NO_APPLICATION_FOUND =
      'No Application Found. Please Email or Call Zoetis Shelter Team at ' +
      TEAM_EMAIL +
      ' or ' +
      TEAM_PHONE +
      ' for assistance.';
    public Attachment npoAtt {
      get {
        if (npoAtt == null)
          npoAtt = new Attachment();
        return npoAtt;
      }
      set;
    }
    public Attachment signedAtt {
      get {
        if (signedAtt == null)
          signedAtt = new Attachment();
        return signedAtt;
      }
      set;
    }
    public Attachment otherAtt {
      get {
        if (otherAtt == null)
          otherAtt = new Attachment();
        return otherAtt;
      }
      set;
    }
    public Attachment existingNpoAtt { get; set; }
    public Attachment existingSignedAtt { get; set; }
    public List<Attachment> existingOtherAtt { get; set; }
    public String deleteAtt { get; set; }
    Map<String, String> stepNumberPageNameMap;
    public String emailId { get; set; }
    public List<Lead> emailLeads { get; set; }
    public boolean downloadFlag { get; set; }
    public Map<String, String> eSignTagsMap { get; set; }
    public List<SelectOption> typeOfSancAnimals { get; set; }
  //	public boolean DisplayPopup {get; set;}
    public ZoetisForShelters(ApexPages.StandardController stdController) {
      shelter = (Lead) stdController.getRecord();
        System.debug('pageParams'+shelter);
      shelterRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('Shelters')
        .getRecordTypeId();
      Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        System.debug('pageParams'+pageParams);
      String urlName = ApexPages.currentPage().getUrl();
      String source = pageParams.get('source');
      downloadFlag = false;
      triggerESign = false;
      eSignTagsMap = new Map<String, String>();
      if (source == 'ZoetisWebSite') {
        this.shelter.Company = 'ZoetisWebSite';
        this.shelter.Salutation = pageParams.get('prefix');
        this.shelter.FirstName = pageParams.get('fName');
        this.shelter.LastName = pageParams.get('lName');
        this.shelter.Job_Role__c = pageParams.get('Jobrole'); //Pooja Added TPDEV-1355
        this.shelter.Email = pageParams.get('email');
        this.shelter.Phone = pageParams.get('phone');
        this.shelter.Shelter_Name__c = pageParams.get('shelterName');
        this.shelter.Shelter_Website__c = pageParams.get('shelterWebsite');
        this.shelter.Secondary_Contact_First_Name__c = pageParams.get('shelterSecondaryContactfName');//Pooja Added TPDEV-1355
        this.shelter.Secondary_Contact_Last_Name__c = pageParams.get('shelterSecondaryContactlName');//Pooja Added TPDEV-1355
        this.shelter.Secondary_Contact_Job_Role__c = pageParams.get('shelterSecondaryContactJobRole'); //Pooja Added TPDEV-1355       
        this.shelter.Secondary_Contact_Email__c = pageParams.get('shelterSecondaryContactemail');//Pooja Added TPDEV-1355
        this.shelter.Secondary_Contact_Phone__c = pageParams.get('shelterSecondaryContactphone');//Pooja Added TPDEV-1355
        this.pageName = 'ZFS_BasicInformation';
      } else {
        if (urlName != null) {
          if (!urlName.contains('?')) {
            pageName = urlName.substringAfterLast('/');
          } else {
            pageName = urlName.substringBetween('zoetisforshelters/', '?');
            pageName = urlName.substringBetween('apex/', '?');
          }
        }
        system.debug('current page: ' + pageName);
        if (pageName == 'ZFS_downloadForm') {
          downloadFlag = true;
        }
        if (shelter.id != null) {
          shelter = loadShelter(shelter.id, null, null);
          if (
            shelter.status != 'Open' &&
            shelter.status != 'Pre-Qualification Not Eligible' &&
            shelter.status != 'Under Review' &&
            shelter.status != 'Permanent Pending'
          )
            readonly = true;
          if (shelter.LastName.equalsIgnoreCase('reset-dummy'))
            shelter.LastName = null;
          existingOtherAtt = new List<Attachment>();
          loadAttachments(shelter.Id);
  
          LeadId = shelter.Id;
          shelter.Id = null;
          if (shelter.status != 'Open' && shelter.status != 'Permanent Pending')
            submitted = true;
  
          system.debug('Submitted: ' + submitted);
        }
      }
      setNextPrevPages();
      setPicklistValues();
      System.debug('...typeOfSancAnimals...' + typeOfSancAnimals);
      hasErrors = false;
      options = new List<String>();
      options.add('Basic Information');
      options.add('Qualification Criteria');
      options.add('Contact Information');
      options.add('Statistics');
      options.add('Veterinarian Information');
      //options.add('Credit References');
      options.add('Sales Tax Information');
      options.add('Review');
  
      stepNumberPageNameMap = new Map<String, String>();
      stepNumberPageNameMap.put('1', 'ZFS_BasicInformation');
      stepNumberPageNameMap.put('2', 'ZFS_QualificationCriteria');
      stepNumberPageNameMap.put('3', 'ZFS_Contact');
      stepNumberPageNameMap.put('4', 'ZFS_Stats');
      stepNumberPageNameMap.put('5', 'ZFS_VeterinarianInformation');
     // stepNumberPageNameMap.put('6', 'ZFS_References');//Pooja Added TPDEV-1355
      stepNumberPageNameMap.put('6', 'ZFS_SalesTaxStatus');
      stepNumberPageNameMap.put('7', 'ZFS_ReviewAndSubmit');
  
      if (pageName == 'ZFS_ReviewAndSubmit') {
        eSignTagsMap.put(shelter.Email, '{{appSign_es_:signer1:signature}}');
        if (shelter.Email == shelter.DVM_Email__c) {
          eSignTagsMap.put(shelter.DVM_Email__c, eSignTagsMap.get(shelter.Email));
        } else {
          eSignTagsMap.put(
            shelter.DVM_Email__c,
            '{{vetsign_es_:signer2:signature}}'
          );
        }
        System.debug('..3333...' + eSignTagsMap);
      }
    }
  
    public PageReference createShelterFromWebSite() {
      if (this.shelter.Company == 'ZoetisWebSite') {
        this.shelter.Company = 'Shelter';
        this.pageName = 'ZFS_BasicInformation';
        this.nextPage = 'ZFS_QualificationCriteria';
        return saveShelter();
      }
      return null;
    }
  
    public Lead loadShelter(Id id, String appNo, String emailId) {
      System.debug(id + '...Search Application Number:' + appNo);
      Lead shelterLead;
      if (id != null) {
        shelterLead = LeadsSelector.selectZFSLeadsById(new Set<Id>{ id })[0];
        return shelterLead;
      } else if (
          appNo != null && 
          appNo.length() > 0 && 
          emailId != null && 
          emailId.length() > 0
      ) {
        List<Lead> shelterLeads = LeadsSelector.selectZFSLeadsByAppIdAndEmail(
          new Set<String>{ appNo },
          new Set<String>{ emailId }
        );
        if (shelterLeads != null && shelterLeads.size() > 0) {
          shelterLead = shelterLeads[0];
          return shelterLead;
        } else {
          return null;
        }
      }
      return null;
    }
  
    public PageReference fetchShelter() {
      PageReference pageRef = null;
      if (
          applicationNo != null && 
          applicationNo.length() > 0 && 
          emailId != null && 
          emailId.length() > 0
      ) {
        applicationNo = applicationNo.trim();
        emailId = emailId.trim();
        shelter = loadShelter(null, applicationNo, emailId);
        if (
          shelter == null ||
          shelter.status == 'To be Deleted' ||
          shelter.status == 'Application Suspended'
        ) {
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, NO_APPLICATION_FOUND)
          );
          return null;
        }
        if (
          shelter.Signature_Status__c == 'Out for Signature' ||
          (shelter.status != 'Open' &&
          shelter.status != 'Pre-Qualification Not Eligible' &&
          shelter.status != 'Under Review' &&
          shelter.status != 'Permanent Pending')
        ) {
          pageRef = new PageReference('/apex/ZFS_SubmittedForm');
          readonly = true;
        } else if (shelter.status == 'Pre-Qualification Not Eligible') {
          if (shelter.Step_Number__c >= 4) {
            pageRef = new PageReference(
              '/apex/' + stepNumberPageNameMap.get(String.valueOf(4))
            );
          } else if (shelter.Step_Number__c >= 2) {
            pageRef = new PageReference(
              '/apex/' + stepNumberPageNameMap.get(String.valueOf(2))
            );
          }
        } else {
          pageRef = new PageReference(
            '/apex/' +
            stepNumberPageNameMap.get(String.valueOf(shelter.Step_Number__c))
          );
        }
        pageRef.getParameters().put('id', this.shelter.id);
        pageRef.setRedirect(true);
      } else {
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please Provide Both an Application Number and an Email Address'
          )
        );
        return null;
      }
      return pageRef;
    }
  
    public void loadAttachments(Id pId) {
      if (
        this.pageName == 'ZFS_ReviewAndSubmit' ||
        this.pageName == 'ZFS_SubmittedForm'
      ) {
        List<Attachment> att = [
          SELECT name, description
          FROM Attachment
          WHERE parentid = :pId
          ORDER BY createdDate
        ];
        for (Attachment a : att) {
          if (
            String.isEmpty(a.description) ||
            (a.description != 'NPO 501(c)' &&
            a.description != 'Signed Application Form')
          ) {
            this.existingOtherAtt.add(a);
          } else if (a.description.equalsIgnoreCase('NPO 501(c)')) {
            this.existingNpoAtt = a;
          } else if (a.description.equalsIgnoreCase('Signed Application Form')) {
            this.existingSignedAtt = a;
          }
        }
      }
    }
  
    public PageReference uploadNpoAtt() {
      if (npoAtt.Body == null) {
        apexPages.addMessage(
          new apexPages.Message(
            ApexPages.Severity.ERROR,
            'Please select a file for uploading.'
          )
        );
        hasErrors = true;
      } else {
        try {
          npoAtt.OwnerId = UserInfo.getUserId();
          npoAtt.parentId = LeadId;
          npoAtt.Description = 'NPO 501(c)';
          if (existingNpoAtt != null)
            delete existingNpoAtt;
          insert npoAtt;
          npoAtt.Body = null;
          existingNpoAtt = npoAtt;
        } catch (exception e) {
          apexPages.addMessage(
            new apexPages.Message(
              ApexPages.Severity.ERROR,
              'Error uploading file.'
            )
          );
          hasErrors = true;
        } finally {
          npoAtt = new Attachment();
        }
      }
      return null;
    }
  
    public PageReference uploadSignedAtt() {
      if (signedAtt.Body == null) {
        apexPages.addMessage(
          new apexPages.Message(
            ApexPages.Severity.ERROR,
            'Please select a file for uploading.'
          )
        );
        hasErrors = true;
      } else {
        try {
          signedAtt.OwnerId = UserInfo.getUserId();
          signedAtt.parentId = LeadId;
          signedAtt.Description = 'Signed Application Form';
          if (existingSignedAtt != null)
            delete existingSignedAtt;
          insert signedAtt;
          signedAtt.Body = null;
          existingSignedAtt = signedAtt;
        } catch (exception e) {
          apexPages.addMessage(
            new apexPages.Message(
              ApexPages.Severity.ERROR,
              'Error uploading file.'
            )
          );
          hasErrors = true;
        } finally {
          signedAtt = new Attachment();
        }
      }
      return null;
    }
  
    public PageReference uploadOtherAttachment() {
      if (otherAtt.Body == null) {
        apexPages.addMessage(
          new apexPages.Message(
            ApexPages.Severity.ERROR,
            'Please select a file for uploading.'
          )
        );
      } else {
        try {
          otherAtt.OwnerId = UserInfo.getUserId();
          otherAtt.parentId = LeadId;
          insert otherAtt;
          otherAtt.Body = null;
          this.existingOtherAtt.add(otherAtt);
        } catch (exception e) {
          apexPages.addMessage(
            new apexPages.Message(
              ApexPages.Severity.ERROR,
              'Error uploading file.'
            )
          );
          hasErrors = true;
        } finally {
          otherAtt = new Attachment();
        }
      }
      return null;
    }
  
    public PageReference deleteOtherAtt() {
      try {
        Attachment att = new Attachment(id = this.deleteAtt);
        delete att;
        this.existingOtherAtt = [
          SELECT name, description
          FROM Attachment
          WHERE
            parentid = :LeadId
            AND description NOT IN ('NPO 501(c)', 'Signed Application Form')
        ];
      } catch (Exception e) {
        apexPages.addMessage(
          new apexPages.Message(ApexPages.Severity.ERROR, 'Error deleting file.')
        );
        hasErrors = true;
      }
      return null;
    }
  
    public PageReference previous() {
      PageReference pageRef = new PageReference('/apex/' + prevPage);
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', this.LeadId);
      return pageRef;
    }
  
    public PageReference saveShelter() {
      try {
        this.shelter.id = LeadId;
        this.shelter.Company = 'Shelter';
        this.shelter.LeadSource = 'Zoetis™ Interest Form';
        this.shelter.Current_Status__c = 'Save-Next';
        this.shelter.RecordTypeId = this.shelterRecTypeId;
  
        copyBillingAddress();
        createNullFields();
  
        validateCurrentPage('savenext');
        system.debug('##after validateCurrentPage : ' + hasErrors);
        if (hasErrors) {
          this.shelter.id = null;
          return null;
        }
        setStepNumber(pageName);
  
        if (
          this.pageName == 'ZFS_QualificationCriteria' &&
          this.shelter.Type_of_Organization__c != 'Other' &&
          this.shelter.Type_of_Organization__c !=
          'Spay/Neuter Group (No direct adoptions)' &&
          (this.shelter.annual_cat_dog__c == 'Yes' ||
          (this.shelter.annual_cat_dog__c == 'No' &&
          this.shelter.Type_of_Organization__c == 'Animal Sanctuary')) &&
          this.shelter.Do_you_have_a_licensed_veterinarian__c == 'Yes' &&
          this.shelter.status == 'Pre-Qualification Not Eligible'
        ) {
          shelter.status = 'Open';
        }
        upsert shelter;
      } catch (Exception ex) {
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, SOMETHING_WENT_WRONG)
        );
        hasErrors = true;
        System.debug(ex.getStackTraceString());
        return null;
      }
      PageReference pageRef = new PageReference('/apex/' + this.nextPage);
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', shelter.id);
      return pageRef;
    }
  
    public PageReference saveExit() {
      try {
        validateCurrentPage('saveexit');
        if (hasErrors) {
          return null;
        }
        shelter.id = LeadId;
        setStepNumber(pageName);
        this.shelter.Company = 'Shelter';
        this.shelter.LeadSource = 'Zoetis™ Interest Form';
        this.shelter.Current_Status__c = 'Save-Exit';
        shelter.RecordTypeId = this.shelterRecTypeId;
        if (
          this.pageName == 'ZFS_QualificationCriteria' &&
          (this.shelter.Type_of_Organization__c == 'Other' ||
          this.shelter.Type_of_Organization__c ==
          'Spay/Neuter Group (No direct adoptions)' ||
          (this.shelter.annual_cat_dog__c == 'No' &&
          this.shelter.Type_of_Organization__c != 'Animal Sanctuary') ||
          this.shelter.Do_you_have_a_licensed_veterinarian__c == 'No')
        ) {
          shelter.status = 'Pre-Qualification Not Eligible';
        } else if (
          this.pageName == 'ZFS_QualificationCriteria' &&
          (this.shelter.Type_of_Organization__c != 'Other' &&
          this.shelter.Type_of_Organization__c !=
          'Spay/Neuter Group (No direct adoptions)') &&
          (this.shelter.annual_cat_dog__c == 'Yes' ||
          (this.shelter.Type_of_Organization__c == 'Animal Sanctuary' &&
          this.shelter.annual_cat_dog__c == 'No')) &&
          this.shelter.Do_you_have_a_licensed_veterinarian__c == 'Yes' &&
          this.shelter.status == 'Pre-Qualification Not Eligible'
        ) {
          shelter.status = 'Open';
        }
        copyBillingAddress();
        createNullFields();
        upsert shelter;
      } catch (Exception ex) {
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, SOMETHING_WENT_WRONG)
        );
        hasErrors = true;
        System.debug(ex.getStackTraceString());
        return null;
      }
      shelter = null;
      PageReference pageRef = new PageReference('/apex/ZFS_homepage');
      pageRef.setRedirect(true);
      return pageRef;
    }
  
    public PageReference discard() {
      try {
        if (LeadId != null) {
          shelter.id = LeadId;
          shelter.status = 'To be Deleted';
          update shelter;
        }
      } catch (Exception ex) {
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Error discarding shelter application.' + ex
          )
        );
        hasErrors = true;
        System.debug(ex.getStackTraceString());
        return null;
      }
  
      shelter = null;
      PageReference pageRef = new PageReference('/apex/ZFS_homepage');
      pageRef.setRedirect(true);
      return pageRef;
    }
  
    public PageReference reset() {
      if (LeadId != null) {
        Lead lead = new Lead(
          id = LeadId,
          Current_Status__c = 'Reset-Form',
          RecordTypeId = this.shelterRecTypeId,
          Salutation = null,
          FirstName = null,
          LastName = 'reset-dummy',
          Job_Role__c = null,//Pooja Added TPDEV-1355
          Email = null,
          Phone = null,
          Secondary_Contact_First_Name__c = null,//Pooja Added TPDEV-1355
          Secondary_Contact_Last_Name__c = 'reset-dummy',//Pooja Added TPDEV-1355
          Secondary_Contact_Job_Role__c = null,//Pooja Added TPDEV-1355
          Secondary_Contact_Email__c = null,//Pooja Added TPDEV-1355
          Secondary_Contact_Phone__c = null,//Pooja Added TPDEV-1355
          MobilePhone = null,
          Shelter_Name__c = null,
          Shelter_Website__c = null,
          Type_of_Organization__c = null,
          If_Other_please_describe__c = null,
          annual_cat_dog__c = null,
          Do_you_currently_purchase_from_Zoetis__c = null,
          Existing_account_with_Zoetis__c = null,
          Account_Prefix__c = null,
          Account_First_Name__c = null,
          Account_Last_Name__c = null,
          Shelter_Account_Name__c = null,
          Zoetis_Account__c = null,
          How_did_you_hear_about_us2__c = null,//Pooja Added TPDEV-1355
          Enter_the_details_for_the_value_selected__c = null,
          Puppy_Intakes_Yr__c = null,
          Dog_Intakes_Yr__c = null,
          Puppy_Adoptions_Yr__c = null,
          Dog_Adoptions_Yr__c = null,
          Kitten_Intakes_Yr__c = null,
          Cat_Intakes_Yr__c = null,
          Kitten_Adoptions_Yr__c = null,
          Cat_Adoptions_yr__c = null,
          Does_org_perform_Spay_Neuter_operations__c = null,
          Estimated_S_N_performed_average_yr__c = null,
          Principal_Bank_Name__c = null,
          Principal_Bank_Phone__c = null,
          Trade_Reference_1_Company_Name__c = null,
          Trade_Reference_1_Company_Phone__c = null,
          Trade_Reference_2_Company_Name__c = null,
          Trade_Reference_2_Company_Phone__c = null,
          Trade_Reference_3_Company_Name__c = null,
          Trade_Reference_3_Company_Phone__c = null,
          Sales_Tax_Status_Type__c = null,
          Sales_Tax_Status__c = null,
          Tax_Permit__c = null,
          Step_Number__c = 1,
          Vet_Prefix__c = null,
          Vet_First_Name__c = null,
          Vet_Last_Name__c = null,
          DVM_Phone__c = null,
          DVM_Address__c = null,
          DVM_Address_2__c = null,
          DVM_City__c = null,
          DVM_State__c = null,
          DVM_County__c = null,
          DVM_Zip__c = null,
          DVM_Email__c = null,
          DVM_Fax__c = null,
          DVM_ST__c = null,
          Contact_Prefix__c = null,
          Contact_Phone__c = null,
          Contact_Email__c = null,
          Contact_Fax__c = null,
          Billing_Street_1__c = null,
          Billing_Street_2__c = null,
          Billing_City__c = null,
          Billing_County__c = null,
          Billing_Country__c = null,
          Billing_State__c = null,
          Billing_Zip_Code__c = null,
          Shipping_Street_1__c = null,
          Shipping_Street_2__c = null,
          Shipping_City__c = null,
          Shipping_County__c = null,
          Shipping_Country__c = null,
          Shipping_State__c = null,
          Shipping_Zip_Code__c = null,
          Contact_Preference__c = null,
          Do_you_have_a_licensed_veterinarian__c = null,
          In_House_Clinic__c = null,
          Wellness_Center__c = null,
          Authorization_Flag__c = false,
          I_agree_to_the_terms_and_conditions__c = false
        );
        try {
          update lead;
          List<attachment> att = [
            SELECT name, description
            FROM Attachment
            WHERE parentid = :LeadId
          ];
          delete att;
        } catch (Exception ex) {
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Error resetting shelter information.' + ex
            )
          );
          hasErrors = true;
          System.debug(ex.getStackTraceString());
          return null;
        }
        this.shelter = lead;
      }
      PageReference pageRef = new PageReference('/apex/ZFS_BasicInformation');
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', shelter.id);
      return pageRef;
    }
  
    public PageReference submitShelter() {
      try {
        validateCurrentPage('submit');
        if (hasErrors) {
          return null;
        }
        shelter.id = LeadId;
        setStepNumber(pageName);
        if (this.shelter.Status == 'Under Review') {
          this.shelter.Status = 'Resubmit';
        } else {
          this.shelter.Status = 'Pending Exton Verification';
        }
        shelter.RecordTypeId = this.shelterRecTypeId;
        shelter.Shelter_Submitted_Date__c = System.Today();
        upsert shelter;
        submitted = true;
        system.debug('Shelter ID ==>' + shelter.Id);
      } catch (Exception ex) {
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, SOMETHING_WENT_WRONG)
        );
        hasErrors = true;
        System.debug(ex.getStackTraceString());
        return null;
      }
      PageReference pageRef = new PageReference('/apex/ZFS_SubmittedForm');
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', shelter.id);
      pageRef.getParameters().put('submitted', 'true');
      return pageRef;
    }
  
    public PageReference returnToApplication() {
      PageReference pageRef = new PageReference('/apex/ZFS_BasicInformation');
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', LeadId);
      return pageRef;
    }
  
    public void setPicklistValues() {
      statepicklist = new List<SelectOption>();
      prefix = new List<SelectOption>();
      shelterType = new List<SelectOption>();
      salesTaxStatusType = new List<SelectOption>();
      salesTaxStatus = new List<SelectOption>();
      shippingAddressType = new List<SelectOption>();
      typeOfSancAnimals = new List<SelectOption>();
	  hearAboutZoeties = new List<SelectOption>();
      Schema.DescribeFieldResult fieldResult;
  
      // Slalom 06/25/20 - Lead Statecode is no longer a field in the org,
      // using a different state field to populate picklist.
      fieldResult = Account.ZTS_US_State_Province__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
        if (
          p.getLabel() != 'Federated Micronesia' &&
          p.getLabel() != 'Marshall Islands' &&
          p.getLabel() != 'Northern Mariana Islands' &&
          p.getLabel() != 'Other'
        ) {
          statePicklist.add(new SelectOption(p.getValue(), p.getLabel()));
        }
      }
  
      fieldResult = Lead.Salutation.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        prefix.add(new SelectOption(p.getValue(), p.getValue()));
		
		fieldResult = Lead.How_did_you_hear_about_us2__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        hearAboutZoeties.add(new SelectOption(p.getValue(), p.getValue()));
  
      fieldResult = Lead.Type_of_Organization__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        shelterType.add(new SelectOption(p.getValue(), p.getValue()));
  
      fieldResult = Lead.Type_of_Sanctuary_Animals__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        typeOfSancAnimals.add(new SelectOption(p.getValue(), p.getValue()));
  
      fieldResult = Lead.Sales_Tax_Status_Type__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        salesTaxStatusType.add(new SelectOption(p.getValue(), p.getValue()));
  
      fieldResult = Lead.Sales_Tax_Status__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        salesTaxStatus.add(new SelectOption(p.getValue(), p.getValue()));
  
      fieldResult = Lead.Shipping_Address_Type__c.getDescribe();
      for (Schema.PicklistEntry p : fieldResult.getPicklistValues())
        shippingAddressType.add(new SelectOption(p.getValue(), p.getValue()));
    }
  
    private void setStepNumber(String currPage) {
      if (currPage == 'ZFS_BasicInformation') {
        if (
          this.shelter.Step_Number__c == null ||
          this.shelter.Step_Number__c < 1
        ) {
          this.shelter.Step_Number__c = 1;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      } else if (currPage == 'ZFS_QualificationCriteria') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c < 2
        ) {
          this.shelter.Step_Number__c = 2;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      } else if (currPage == 'ZFS_Contact') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c < 3
        ) {
          this.shelter.Step_Number__c = 3;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      } else if (currPage == 'ZFS_Stats') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c < 4
        ) {
          this.shelter.Step_Number__c = 4;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      } else if (currPage == 'ZFS_VeterinarianInformation') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c < 5
        ) {
          this.shelter.Step_Number__c = 5;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      } /*else if (currPage == 'ZFS_References') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c < 6
        ) {
          this.shelter.Step_Number__c = 6;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      }*/ else if (currPage == 'ZFS_SalesTaxStatus') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c < 6
        ) {
          this.shelter.Step_Number__c = 6;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
        }
      } else if (currPage == 'ZFS_ReviewAndSubmit') {
        if (
          this.shelter.Step_Number__c != null &&
          this.shelter.Step_Number__c <= 7
        ) {
          this.shelter.Step_Number__c = 7;
          shelter.Shelter_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/zoetisforshelters/' +
            currPage;
          shelter.Notification_Flag__c = true;
        }
      }
    }
  
    private void setNextPrevPages() {
      if (this.pageName == 'ZFS_BasicInformation') {
        this.nextPage = 'ZFS_QualificationCriteria';
      } else if (this.pageName == 'ZFS_QualificationCriteria') {
        this.nextPage = 'ZFS_Contact';
        this.prevPage = 'ZFS_BasicInformation';
      } else if (this.pageName == 'ZFS_Contact') {
        this.nextPage = 'ZFS_Stats';
        this.prevPage = 'ZFS_QualificationCriteria';
      } else if (this.pageName == 'ZFS_Stats') {
        this.nextPage = 'ZFS_VeterinarianInformation';
        this.prevPage = 'ZFS_Contact';
      } else if (this.pageName == 'ZFS_VeterinarianInformation') {
        this.nextPage = 'ZFS_SalesTaxStatus';
        this.prevPage = 'ZFS_Stats';
      } /*else if (this.pageName == 'ZFS_References') {
        this.nextPage = 'ZFS_SalesTaxStatus';				//Pooja Added TPDEV-1355
        this.prevPage = 'ZFS_VeterinarianInformation';
      }*/ else if (this.pageName == 'ZFS_SalesTaxStatus') {
        this.nextPage = 'ZFS_ReviewAndSubmit';
        this.prevPage = 'ZFS_VeterinarianInformation';
      } else if (this.pageName == 'ZFS_ReviewAndSubmit') {
        this.prevPage = 'ZFS_SalesTaxStatus';
      }
    }
  
    public void validateCurrentPage(String action) {
      hasErrors = false;
      if (this.pageName == 'ZFS_BasicInformation') {
        if (
          this.shelter.FirstName == null ||
          this.shelter.LastName == null ||
          this.shelter.Job_Role__c == null ||
          this.shelter.Email == null ||
          this.shelter.Phone == null ||
          this.shelter.Shelter_Name__c == null ||
          this.shelter.Shelter_Website__c == null||
          this.shelter.Secondary_Contact_First_Name__c == null||    //Pooja Added TPDEV-1355
          this.shelter.Secondary_Contact_Last_Name__c == null||
          this.shelter.Secondary_Contact_Email__c == null||
          this.shelter.Secondary_Contact_Phone__c == null
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        }
          //Pooja Added TPDEV-1355
          else if (this.shelter.I_agree_to_the_terms_and_conditions__c == false) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Please read and agree to the terms & conditions to proceed'
            )
          );
        }
      } else if (this.pageName == 'ZFS_QualificationCriteria') {
        if (
          this.shelter.Type_of_Organization__c == null ||
          this.shelter.annual_cat_dog__c == null ||
          this.shelter.Do_you_currently_purchase_from_Zoetis__c == null ||
          this.shelter.Existing_account_with_Zoetis__c == null ||
          this.shelter.How_did_you_hear_about_us2__c == null ||
          this.shelter.Do_you_have_a_licensed_veterinarian__c == null ||
          (this.shelter.Type_of_Organization__c != null &&
          this.shelter.Type_of_Organization__c == 'Other' &&
          this.shelter.If_Other_please_describe__c == null) ||
          (this.shelter.Type_of_Organization__c != null &&
          this.shelter.Type_of_Organization__c == 'Animal Sanctuary' &&
          this.shelter.Type_of_Sanctuary_Animals__c == null) ||
          (this.shelter.Type_of_Organization__c != null &&
          this.shelter.Type_of_Organization__c == 'Animal Sanctuary' &&
          this.shelter.Type_of_Sanctuary_Animals__c == 'Other' &&
          this.shelter.Type_of_Sanctuary_Animals_Other__c == null)||
          (this.shelter.How_did_you_hear_about_us2__c != null &&
           this.shelter.How_did_you_hear_about_us2__c == 'Zoetis Representative' &&    //Pooja Added TPDEV-1355
           this.shelter.Enter_the_details_for_the_value_selected__c == null)||
          (this.shelter.How_did_you_hear_about_us2__c != null &&
           this.shelter.How_did_you_hear_about_us2__c == 'Veterinarian' &&
           this.shelter.Enter_the_details_for_the_value_selected__c == null)||
          (this.shelter.How_did_you_hear_about_us2__c != null &&
           this.shelter.How_did_you_hear_about_us2__c == 'Other' &&
           this.shelter.Enter_the_details_for_the_value_selected__c == null)
            
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        } else if (
          action != 'saveexit' &&
          (this.shelter.Type_of_Organization__c == 'Other' ||
          this.shelter.Type_of_Organization__c ==
          'Spay/Neuter Group (No direct adoptions)') ||
          ((this.shelter.Type_of_Organization__c != 'Animal Sanctuary' &&
          this.shelter.annual_cat_dog__c == 'No') ||
          this.shelter.Do_you_have_a_licensed_veterinarian__c == 'No')
        ) {
          hasErrors = true;
  
          //Added by Abir: SC-002301
          this.shelter.status = 'Pre-Qualification Not Eligible';
          try {
            update this.shelter;
          } catch (Exception e) {
            hasErrors = true;
            ApexPages.addMessage(
              new ApexPages.Message(
                ApexPages.Severity.ERROR,
                SOMETHING_WENT_WRONG
              )
            );
          }
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'We are sorry; your organization type does not qualify for the Zoetis for Shelters program. If you think your organization still qualifies please call us at 1-866-225-9777'
            )
          );
        } else if (this.shelter.Existing_account_with_Zoetis__c == 'Yes') {
          if (
            this.shelter.Account_Prefix__c == null ||
            this.shelter.Account_First_Name__c == null ||
            this.shelter.Account_Last_Name__c == null ||
            this.shelter.Shelter_Account_Name__c == null ||
            this.shelter.Zoetis_Account__c == null
          ) {
            hasErrors = true;
            ApexPages.addmessage(
              new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
            );
          }
        }
      } else if (this.pageName == 'ZFS_Contact') {
        if (
          this.shelter.Contact_Phone__c == null ||
          this.shelter.Contact_Email__c == null ||
          this.shelter.Contact_Fax__c == null ||
          this.shelter.Billing_Street_1__c == null ||
          this.shelter.Billing_City__c == null ||
          this.shelter.Billing_State__c == 'Select' ||
          this.shelter.Billing_Zip_Code__c == null ||
          this.shelter.Shipping_Address_Type__c == null ||
          this.shelter.Contact_Preference__c == null ||
          this.shelter.Authorization_Flag__c == false
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        } else if (this.shelter.Shipping_Address_Type__c == 'Shelter') {
          if (
            this.shelter.Shipping_Address_Type__c == null ||
            this.shelter.Shipping_Street_1__c == null ||
            this.shelter.Shipping_City__c == null ||
            this.shelter.Shipping_State__c == 'Select' ||
            this.shelter.Shipping_Zip_Code__c == null
          ) {
            hasErrors = true;
            ApexPages.addmessage(
              new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
            );
          }
        } else if (this.shelter.Shipping_Address_Type__c == 'Veterinarian') {
          if (
            this.shelter.Shipping_Address_Type__c == null ||
            this.shelter.Shipping_Street_1__c == null ||
            this.shelter.Shipping_City__c == null ||
            this.shelter.Shipping_State__c == 'Select' ||
            this.shelter.Shipping_Zip_Code__c == null
          ) {
            hasErrors = true;
            ApexPages.addmessage(
              new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
            );
          }
        }
      } else if (this.pageName == 'ZFS_Stats') {
        if (
          this.shelter.Puppy_Intakes_Yr__c == null ||
          this.shelter.Dog_Intakes_Yr__c == null ||
          this.shelter.Puppy_Adoptions_Yr__c == null ||
          this.shelter.Dog_Adoptions_Yr__c == null ||
          this.shelter.Kitten_Intakes_Yr__c == null ||
          this.shelter.Cat_Intakes_Yr__c == null ||
          this.shelter.Kitten_Adoptions_Yr__c == null ||
          this.shelter.Cat_Adoptions_yr__c == null ||
          this.shelter.Resurrenders_for_Cats__c == null ||
          this.shelter.Resurrenders_for_Dogs__c == null ||
          this.shelter.Max_Capacity_for_Cats__c == null ||
          this.shelter.Max_Capacity_for_Dogs__c == null ||
          this.shelter.Does_org_perform_Spay_Neuter_operations__c == null ||
          this.shelter.In_House_Clinic__c == null||
          this.shelter.Wellness_Center__c == null
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        } else if (
          action != 'saveexit' &&
          ((this.shelter.Type_of_Organization__c != 'Animal Sanctuary' &&
          (((this.shelter.Puppy_Adoptions_Yr__c +
          this.shelter.Dog_Adoptions_Yr__c +
          this.shelter.Kitten_Adoptions_Yr__c +
          this.shelter.Cat_Adoptions_yr__c) < 1) ||
          ((this.shelter.Puppy_Intakes_Yr__c +
          this.shelter.Dog_Intakes_Yr__c +
          this.shelter.Kitten_Intakes_Yr__c +
          this.shelter.Cat_Intakes_Yr__c) < 80))) ||
          (this.shelter.Type_of_Organization__c == 'Animal Sanctuary' &&
          (this.shelter.Puppy_Intakes_Yr__c +
          this.shelter.Dog_Intakes_Yr__c +
          this.shelter.Kitten_Intakes_Yr__c +
          this.shelter.Cat_Intakes_Yr__c +
          this.shelter.Puppy_Adoptions_Yr__c +
          this.shelter.Dog_Adoptions_Yr__c +
          this.shelter.Cat_Adoptions_yr__c +
          this.shelter.Kitten_Adoptions_Yr__c) < 1))
        ) {
          hasErrors = true;
          //Added by Abir: SC-002301
          this.shelter.status = 'Pre-Qualification Not Eligible';
          this.shelter.Step_Number__c = 4;
          try {
            update this.shelter;
          } catch (Exception e) {
            hasErrors = true;
            ApexPages.addMessage(
              new ApexPages.Message(
                ApexPages.Severity.ERROR,
                SOMETHING_WENT_WRONG
              )
            );
          }
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Your Facility does not intake and/or adopt out enough animals to join the Zoetis For Shelters Program. If you think your organization still qualifies, please call us at 1-866-225-9777.'
            )
          );
        }
      } else if (this.pageName == 'ZFS_VeterinarianInformation') {
        if (
          this.shelter.Vet_Prefix__c == null ||
          this.shelter.Vet_First_Name__c == null ||
          this.shelter.Vet_Last_Name__c == null ||
          this.shelter.DVM_Phone__c == null ||
          this.shelter.DVM_Address__c == null ||
          this.shelter.DVM_City__c == null ||
          this.shelter.DVM_State__c == 'Select' ||
          this.shelter.DVM_Zip__c == null ||
          this.shelter.DVM_Email__c == null ||
          this.shelter.DVM_Fax__c == null ||
          this.shelter.DVM_ST__c == null
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        }
      } /*else if (this.pageName == 'ZFS_References') {
        if (
          this.shelter.Principal_Bank_Name__c == null ||				//Pooja Added TPDEV-1355
          this.shelter.Principal_Bank_Phone__c == null ||
          this.shelter.Trade_Reference_1_Company_Name__c == null ||
          this.shelter.Trade_Reference_1_Company_Phone__c == null ||
          this.shelter.Trade_Reference_2_Company_Name__c == null ||
          this.shelter.Trade_Reference_2_Company_Phone__c == null ||
          this.shelter.Trade_Reference_3_Company_Name__c == null ||
          this.shelter.Trade_Reference_3_Company_Phone__c == null
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        }
      }*/ else if (this.pageName == 'ZFS_SalesTaxStatus') {
        if (
          this.shelter.Sales_Tax_Status_Type__c == null ||
          this.shelter.Sales_Tax_Status__c == null
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
          );
        } else if (
          this.shelter.Sales_Tax_Status__c == 'Tax Exempt' &&
          this.shelter.Tax_Permit__c == null
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Please enter the Tax Permit Number'
            )
          );
        } else if (this.shelter.I_agree_to_the_terms_and_conditions__c == false) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Please read and agree to the terms & conditions to proceed'
            )
          );
        }
      }
  
      if (action == 'Submit') {
        if (this.shelter.Signature_Status__c == 'Out for Signature') {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Electronic Signatures must be signed by all parties and in Completed status before submitting the application'
            )
          );
        } else if (
          String.isBlank(this.shelter.Signature_Status__c) &&
          (existingSignedAtt == null)
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Complete the signature process either using electronic signature or print/manual upload of the application before submitting the application'
            )
          );
        }
      }
    }
  
    public void copyBillingAddress() {
      if (this.pageName == 'ZFS_Contact') {
        if (this.shelter.Shipping_Address_Type__c == 'Same as Billing') {
          this.Shelter.Shipping_Street_1__c = this.Shelter.Billing_Street_1__c;
          this.Shelter.Shipping_Street_2__c = this.Shelter.Billing_Street_2__c;
          this.Shelter.Shipping_City__c = this.Shelter.Billing_City__c;
          this.Shelter.Shipping_County__c = this.Shelter.Billing_County__c;
          this.Shelter.Shipping_State__c = this.Shelter.Billing_State__c;
          this.Shelter.Shipping_Zip_Code__c = this.Shelter.Billing_Zip_Code__c;
        }
      }
    }
  
    public List<String> options { get; set; }
    public string opts { get; set; }
  
    public void createNullFields() {
      if (this.pageName == 'ZFS_QualificationCriteria') {
        if (this.Shelter.Existing_account_with_Zoetis__c == 'No') {
          this.Shelter.Account_Prefix__c = null;
          this.Shelter.Account_First_Name__c = null;
          this.Shelter.Account_Last_Name__c = null;
          this.Shelter.Shelter_Account_Name__c = null;
          this.Shelter.Zoetis_Account__c = null;
        }
        if (
          this.Shelter.Type_of_Organization__c != null &&
          this.Shelter.Type_of_Organization__c != 'Other'
        ) {
          this.Shelter.If_Other_please_describe__c = null;
        }
  
        if (
          this.Shelter.Type_of_Organization__c != null &&
          this.Shelter.Type_of_Organization__c != 'Animal Sanctuary'
        ) {
          this.Shelter.Type_of_Sanctuary_Animals__c = null;
          this.Shelter.Type_of_Sanctuary_Animals_Other__c = null;
        }
  
        if (
          this.Shelter.Type_of_Sanctuary_Animals__c != null &&
          this.Shelter.Type_of_Sanctuary_Animals__c != 'Other'
        ) {
          this.Shelter.Type_of_Sanctuary_Animals_Other__c = null;
        }
          Set<String> hearAboutMap = new Set<String>{'Zoetis Representative', 'Veterinarian', 'Other'}; //Pooja Added TPDEV-1355
             
          if (
          this.Shelter.How_did_you_hear_about_us2__c != null &&
          !hearAboutMap.contains(this.Shelter.How_did_you_hear_about_us2__c)
        ) {
          this.Shelter.Enter_the_details_for_the_value_selected__c = null;
        } //Pooja Added TPDEV-1355
          
          
      }
  
      if (this.pageName == 'ZFS_SalesTaxStatus') {
        if (this.Shelter.Sales_Tax_Status__c != 'Tax Exempt') {
          Shelter.Tax_Permit__c = null;
        }
      }
    }
  
    public void createNullShelterAndVet() {
      if (this.pageName == 'ZFS_Contact') {
        if (
          this.Shelter.Shipping_Address_Type__c == 'Shelter' ||
          this.Shelter.Shipping_Address_Type__c == 'Veterinarian'
        ) {
          this.Shelter.Shipping_Street_1__c = null;
          this.Shelter.Shipping_Street_2__c = null;
          this.Shelter.Shipping_City__c = null;
          this.Shelter.Shipping_County__c = null;
          this.Shelter.Shipping_State__c = null;
          this.Shelter.Shipping_Zip_Code__c = null;
        }
      }
    }
  
    public echosign_dev1__SIGN_Agreement__c agmt = null;
  
    public PageReference adobeSendForSignature() {
      setStepNumber(pageName);
      agmt = new echosign_dev1__SIGN_Agreement__c();
      String allRecipients = '';
      Attachment att = new Attachment();
      Blob b;
      PageReference pdfPage = Page.ZFS_FinalFormPDF;
      for (String recp : eSignTagsMap.keySet()) {
        allRecipients = allRecipients + recp + ',';
      }
      allRecipients.removeEnd(',');
      agmt.Name =
        'Zoetis For Shelters Application - ' +
        this.Shelter.Shelter_Application_Number__c;
      agmt.Lead__c = this.LeadId;
      agmt.echosign_dev1__Signature_Flow__c = 'Any Order';
      agmt.echosign_dev1__Recipient_Addresses__c = allRecipients;
      agmt.echosign_dev1__Message__c = 'If you have questions about your application, please email us at shelterteam@zoetis.com';
  
      try {
        agmt.echosign_dev1__Process_Template__c = [
          SELECT Id
          FROM echosign_dev1__SIGN_Data_Mapping__c
          WHERE Name = 'ZFSLeadDM'
        ][0]
        .Id; //set data mapping
        /* Implement 'Send on Behalf Of' logic -Start */
        List<User> sendAsUsers = [
          SELECT Id
          FROM User
          WHERE
            Name = 'Zoetis For Shelters Site Guest User'
            AND echosign_dev1__EchoSign_Allow_Delegated_Sending__c = TRUE
        ];
        System.debug('sendAsUsers--->' + sendAsUsers);
        if (!sendAsUsers.isEmpty()) {
          agmt.echosign_dev1__Sender_User__c = sendAsUsers[0].Id;
        }
        /* Implement 'Send on Behalf Of' logic -END*/
        insert agmt;
        this.agreementId = agmt.Id;
      } catch (Exception ex) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Error creating agreement.'
          )
        );
      }
  
      att.Name = shelter.Shelter_Application_Number__c + '.pdf';
      att.parentId = agmt.Id;
      att.description = 'Zoetis For Shelters Application';
  
      if (Test.isRunningTest()) {
        b = blob.valueof('TEST');
      } else {
        b = pdfPage.getContentAsPDF();
      }
      att.body = b;
  
      try {
        insert att;
      } catch (Exception ex) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Error creating document.'
          )
        );
      }
  
      this.shelter.Signature_Status__c = 'Out for Signature';
      this.shelter.Id = this.LeadId;
      try {
        update this.shelter;
      } catch (Exception e) {
        hasErrors = true;
        ApexPages.addMessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, SOMETHING_WENT_WRONG)
        );
      }
      triggerESign = true;
  
      return null;
    }
  
    public PageReference submittedFormRedirect() {
      //redirect to readonly page
      PageReference pageRef = new PageReference('/apex/ZFS_SubmittedForm');
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', this.shelter.id);
      return pageRef;
    }
  
    @RemoteAction
    public static String sendForSignatureRemote(Id agreementId) {
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      String responseString;
      req.setEndpoint('callout:Touchpoint_ApexRest_API' + '/Adobe/v1/eSign/');
      req.setMethod('PUT');
      req.setHeader('Content-Type', 'application/json');
      req.setHeader('Accept', 'application/json');
  
      String reqBody = '{"documents":[{"Id":"' + agreementId + '"}]}';
      req.setBody(reqBody);
  
      HttpResponse res = h.send(req);
      System.debug('res: ' + res);
      System.debug('Response Headers: ' + res.getHeaderKeys());
      System.debug(res.getHeader('Location'));
      while (res.getStatusCode() == 302) {
        req.setEndpoint(res.getHeader('Location'));
        res = h.send(req);
      }
      responseString = res.getBody();
      return responseString;
    }
    /*public void ClosePopup() {       
        DisplayPopup = false;   
    }*/
  
   /* public void ShowPopup() {       
        DisplayPopup = true;   
    }*/
  }