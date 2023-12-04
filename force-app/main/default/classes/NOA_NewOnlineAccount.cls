/**
 * @description       :
 * @author            : Unknown
 * @group             :
 * @last modified on  : 09-01-2022
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   02-22-2021   Morgan Marchese @ Zoetis Inc   Header Creation
 * 1.1   05-04-2021   Chelsea Paice @ Zoetis Inc     Adding Specialty Hospital questions/field mapping to Lead
 **/
public class NOA_NewOnlineAccount {
  public Lead newOnlineAcc { get; set; }
  public Id LeadId { get; set; }
  public String pageName { get; set; }
  public String nextPage;
  public String prevPage;
  public String applicationNo { get; set; }
  public Boolean triggerESign { get; set; } // Adobe E-Sign Send for Signature Guest User Permissions Fix
  public Id agreementId { get; set; }
  public transient boolean readonly { get; set; }
  public transient boolean hasErrors { get; set; }
  public transient List<SelectOption> prefix { get; set; }
  public transient List<SelectOption> ownershipType { get; set; }
  public transient List<SelectOption> customerType { get; set; }
  public transient List<SelectOption> applicantRole { get; set; }
  public transient List<SelectOption> salesTaxStatus { get; set; }
  //public List<SelectOption> typeOfBusiness {get;set;}
  public Attachment existingTaxAtt { get; set; }
  public Attachment existingSignedAtt { get; set; }
  public List<Attachment> existingOtherAtt { get; set; }
  public transient String deleteAtt { get; set; }
  public string requiredMessage = 'Required information missing';
  public string customerrormessage = 'Atleast 1 "business type"(%) field must be populated';
  private Blob fileContent;
  public List<String> species {
    get {
      if (species == null)
        species = new List<String>();
      return species;
    }
    set;
  }

  public Attachment taxAtt {
    get {
      if (taxAtt == null) {
        taxAtt = new Attachment();
      }
      return taxAtt;
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
  public List<Veterinarian_Information__c> vetList { get; set; }
  public List<SelectOption> statePicklist { get; set; }
  public boolean sameAsBilling { get; set; }
  public Map<String, String> stepNumberPageNameMap;
  public String formType { get; set; }
  public boolean submitted { get; set; }
  public boolean downloadFlag { get; set; }
  public String renderRx { get; set; }
  public String emailId { get; set; }
  public String sapBillToId { get; set; }
  public List<Lead> emailLeads { get; set; }
  public List<Lead> sapBillToIdLeads { get; set; }
  public Map<String, String> eSignTagsMap { get; set; }
  public String ownEmail { get; set; }
  public Id vetRecTypeId;
  public Id diagRecTypeId;
  public String accountType { get; set; }
  public String hospitalType { get; set; }
  public String hospitalSubType { get; set; }
  public Boolean isVet { get; set; }


  public NOA_NewOnlineAccount(ApexPages.StandardController stdController) {
    newOnlineAcc = (Lead) stdController.getRecord();
    newOnlineAcc.Company = 'New Online Account';
    downloadFlag = false;
    renderRx = '';
    triggerESign = false;
    eSignTagsMap = new Map<String, String>();
    String urlName = ApexPages.currentPage().getUrl();
    if (!urlName.contains('?')) {
      pageName = urlName.substringAfterLast('/');
    } else {
      pageName = urlName.substringBetween('newonlineaccount/', '?');
      pageName = urlName.substringBetween('apex/', '?');
    }

    if (pageName == 'NOA_downloadForm') {
      downloadFlag = true;
    }
    taxAtt = new Attachment();
    System.debug('....Shiva...' + taxAtt.Name);
    existingOtherAtt = new List<Attachment>();
    system.debug('current page: ' + pageName);
    vetRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('Online_Account_Licensed_Vet')
      .getRecordTypeId();
    diagRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('Online_Account_Diagnostic_or_Reproduction')
      .getRecordTypeId();

    if (newOnlineAcc.id != null) {
      newOnlineAcc = loadNOA(newOnlineAcc.id, null, null);
      initializeStepNos();
      if (
        newOnlineAcc.status != 'Open' &&
        newOnlineAcc.status != 'Under Review' &&
        newOnlineAcc.status != 'Permanent Pending'
      ) {
        readonly = true;
      }
      if (newOnlineAcc.LastName.equalsIgnoreCase('reset-dummy')) {
        newOnlineAcc.LastName = null;
      }
      LeadId = newOnlineAcc.Id;
      newOnlineAcc.Id = null;
      System.debug('lead id' + LeadId);
      loadAttachments(LeadId);
      if (
        newOnlineAcc.status != 'Open' &&
        newOnlineAcc.Status != 'Permanent Pending'
      )
        submitted = true;
        if (this.pageName == 'NOA_BasicAndFacilityInformation'){
                this.newOnlineAcc.Salutation = '';
                this.newOnlineAcc.FirstName = '';
                this.newOnlineAcc.LastName = '';
                this.newOnlineAcc.Applicant_Role__c = '';
                this.newOnlineAcc.Email ='';
                this.newOnlineAcc.Phone ='';
			/** this.newOnlineAcc.Business_Name__c = '';   Defect issue INC2866403 
                this.newOnlineAcc.Customer_Type__c = '';
                this.newOnlineAcc.Billing_Street_1__c = '';
                this.newOnlineAcc.Billing_City__c = '';
                this.newOnlineAcc.Billing_State__c = '';
                this.newOnlineAcc.Billing_Zip_Code__c = '';
                this.newOnlineAcc.Billing_Phone__c = '';
                this.newOnlineAcc.Billing_Email__c = ''; 
                this.newOnlineAcc.Shipping_Street_1__c = '';
                this.newOnlineAcc.Shipping_City__c = ''; 
                this.newOnlineAcc.Shipping_State__c = '';
                this.newOnlineAcc.Shipping_Zip_Code__c = '';
                this.newOnlineAcc.Shipping_Phone__c = '';
                this.newOnlineAcc.Shipping_Email__c = ''; **/
            
        }
    } else {
      if (this.pageName == 'NOA_BasicAndFacilityInformation') {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
          .get('Online_Account_Licensed_Vet')
          .getRecordTypeId();
        this.newOnlineAcc.RecordTypeId = recTypeId;
        this.newOnlineAcc.Customer_Type__c = ApexPages.currentPage()
          .getParameters()
          .get('accountType');
        this.newOnlineAcc.Customer_Sub_Type__c = ApexPages.currentPage()
          .getParameters()
          .get('accountSubType');
        this.newOnlineAcc.Contact_Preference__c = 'Email';
          
      } else if (this.pageName == 'NOA_DiagnosticsorReproductiveServices') {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
          .get('Online_Account_Diagnostic_or_Reproduction')
          .getRecordTypeId();
        this.newOnlineAcc.RecordTypeId = recTypeId;
        this.newOnlineAcc.Customer_Type__c = ApexPages.currentPage()
          .getParameters()
          .get('accountType');
        this.newOnlineAcc.Customer_Sub_Type__c = ApexPages.currentPage()
          .getParameters()
          .get('accountSubType');
        this.newOnlineAcc.Contact_Preference__c = 'Email';
      } else {
        this.newOnlineAcc.Customer_Type__c = ApexPages.currentPage()
          .getParameters()
          .get('accountType');
        this.newOnlineAcc.Customer_Sub_Type__c = ApexPages.currentPage()
          .getParameters()
          .get('accountSubType');
      }
    }
    if (this.newOnlineAcc.Customer_Type__c == 'Vet Practice') {
      isVet = true;
    }
    if (this.newOnlineAcc.Specialty_Description__c != null) {
      this.hospitalType = this.newOnlineAcc.Specialty_Description__c;
    }
    if (this.pageName == 'NOA_VeterinarianInformation') {
      if (vetList == null || vetList.size() <= 0)
        addVet();
    }

    if (
      this.pageName == 'NOA_ReviewAndSubmit' ||
      this.pageName == 'NOA_FinalFormPDF'
    ) {
      List<Veterinarian_Information__c> vetInforList = [
        SELECT ID, Lead__c, Veterinarian_Email__c
        FROM Veterinarian_Information__c
        WHERE Lead__c = :this.LeadId
      ];

      String fetchESignEmail = null;
      if (this.newOnlineAcc.Ownership_Type__c == 'Sole-proprietorship') {
        fetchESignEmail = this.newOnlineAcc.SP_Email__c;
      } else if (this.newOnlineAcc.Ownership_Type__c == 'Partnership') {
        fetchESignEmail = this.newOnlineAcc.Partership_Email__c;
      } else if (
        this.newOnlineAcc.Ownership_Type__c == 'Corporation' ||
        this.newOnlineAcc.Ownership_Type__c == 'LLC' ||
        this.newOnlineAcc.Ownership_Type__c == 'Government'
      ) {
        fetchESignEmail = this.newOnlineAcc.CLG_Email__c;
      } else {
        fetchESignEmail = this.newOnlineAcc.Email;
      }
      ownEmail = fetchESignEmail;
      //SK eSignTagsMap.put(fetchESignEmail, '{{ownSign_es_:signer1:signature}}');
      eSignTagsMap.put(fetchESignEmail, 'O1_es_:signer1:signature}}');
      Integer i = 2;
      for (Veterinarian_Information__c vi : vetInforList) {
        if (eSignTagsMap.get(vi.Veterinarian_Email__c) == null) {
          //SK eSignTagsMap.put(vi.Veterinarian_Email__c, '{{O'+i+'_es_:signer'+i+':signature}}');
          eSignTagsMap.put(
            vi.Veterinarian_Email__c,
            'O' +
            i +
            '_es_:signer' +
            i +
            ':signature}}'
          );
          ++i;
        }
      }
    }
    System.debug('....FINAL.......' + eSignTagsMap);

    setPicklistValues();
    setNextPrevPages();
    hasErrors = false;
    initializeStepNos();

    if (
      this.newOnlineAcc.Customer_Sub_Type__c == 'Diagnostic' ||
      this.newOnlineAcc.Customer_Sub_Type__c == 'Genetics Services' ||
      this.newOnlineAcc.Customer_Sub_Type__c == 'Poultry' ||
      this.newOnlineAcc.Customer_Sub_Type__c == 'Producer Rx'
    ) {
      renderRx = this.newOnlineAcc.Customer_Sub_Type__c.toUpperCase();
    }
  } //end of constructor

  public void initializeStepNos() {
    stepNumberPageNameMap = new Map<String, String>();
    System.debug(
      this.newOnlineAcc.RecordTypeId +
      '....RecordType...' +
      vetRecTypeId
    );

    if (this.newOnlineAcc.RecordTypeId == vetRecTypeId) {
      stepNumberPageNameMap.put('1', 'NOA_BasicAndFacilityInformation');
      stepNumberPageNameMap.put('2', 'NOA_VeterinarianInformation');
      stepNumberPageNameMap.put('3', 'NOA_OwnershipInformation');
      stepNumberPageNameMap.put('4', 'NOA_ReviewAndSubmit');
    } else {
      stepNumberPageNameMap.put('1', 'NOA_DiagnosticsorReproductiveServices');
      stepNumberPageNameMap.put('2', 'NOA_OwnershipInformation');
      stepNumberPageNameMap.put('3', 'NOA_ReviewAndSubmit');
    }
  }

  public PageReference identifyForm() {
    /*
        if(species == null || species.size() <= 0){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select atleast one species')); 
            hasErrors = true;
            return null;
        }
        */
    if (this.newOnlineAcc.Customer_Type__c == null) {
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Please select an Account Type'
        )
      );
      hasErrors = true;
      return null;
    }
    if (
      (this.newOnlineAcc.Customer_Type__c == 'Producer' ||
      this.newOnlineAcc.Customer_Type__c == 'Pet Owner') &&
      newOnlineAcc.Customer_Sub_Type__c == null
    ) {
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Please select Account Sub Type'
        )
      );
      hasErrors = true;
      return null;
    }
    //String speciesSel = String.valueOf(species);
    PageReference pageRef = null;
    if (
      this.newOnlineAcc.Customer_Type__c == 'Vet Practice' ||
      this.newOnlineAcc.Customer_Type__c == 'Mobile Practice' ||
      this.newOnlineAcc.Customer_Type__c == 'Government / Military' ||
      this.newOnlineAcc.Customer_Type__c == 'University' ||
      this.newOnlineAcc.Customer_Type__c == 'University'
    ) {
      pageRef = new PageReference('/apex/NOA_BasicAndFacilityInformation');
      pageRef.getParameters()
        .put('accountType', this.newOnlineAcc.Customer_Type__c);
      pageRef.getParameters()
        .put('accountSubType', this.newOnlineAcc.Customer_Sub_Type__c);
      pageRef.setRedirect(true);
    } else if (
      newOnlineAcc.Customer_Type__c == 'Laboratory' ||
      newOnlineAcc.Customer_Type__c == 'Processor' ||
      (newOnlineAcc.Customer_Type__c == 'Producer' &&
      (newOnlineAcc.Customer_Sub_Type__c == 'Diagnostic' ||
      newOnlineAcc.Customer_Sub_Type__c == 'Genetics Services' ||
      newOnlineAcc.Customer_Sub_Type__c == 'Poultry')) ||
      (newOnlineAcc.Customer_Type__c == 'Pet Owner' &&
      newOnlineAcc.Customer_Sub_Type__c == 'Reproductive Services')
    ) {
      pageRef = new PageReference(
        '/apex/NOA_DiagnosticsorReproductiveServices'
      );
      pageRef.getParameters()
        .put('accountType', this.newOnlineAcc.Customer_Type__c);
      pageRef.getParameters()
        .put('accountSubType', this.newOnlineAcc.Customer_Sub_Type__c);
      pageRef.setRedirect(true);
    } else {
      pageRef = new PageReference('/apex/NOA_Distribution');
      pageRef.getParameters()
        .put('accountType', this.newOnlineAcc.Customer_Type__c);
      pageRef.getParameters()
        .put('accountSubType', this.newOnlineAcc.Customer_Sub_Type__c);
      pageRef.setRedirect(true);
    }

    /* code disabled as per SC-002745
        if(speciesSel.contains('Cats & Dogs')){
            system.debug('Lic Vet ===>'+newOnlineAcc.Do_you_have_a_licensed_veterinarian__c);
            system.debug('Species ===>'+speciesSel);
            if(newOnlineAcc.Do_you_have_a_licensed_veterinarian__c == 'Yes'){
                pageRef = new PageReference('/apex/NOA_BasicAndFacilityInformation');
                pageRef.setRedirect(true);                  
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Thank you for your interest in sourcing Zoetis products. Please contact us at 1-855-721-0078 if you have any questions or need more information.')); 
                hasErrors = true;
            }
            
        }else if(speciesSel.contains('Diagnostics') || speciesSel.contains('Reproductive Services')  || speciesSel.contains('Genetic Services') ){
            pageRef = new PageReference('/apex/NOA_DiagnosticsorReproductiveServices');  
            pageRef.setRedirect(true); 
        }else {
            pageRef = new PageReference('/apex/NOA_Distribution');
            pageRef.setRedirect(true);
        }
        */
    return pageRef;
  }

  public PageReference saveNewOnlineAccount() {
    try {
      validateCurrentPage('savenext');
      System.debug('saveNewOnlineAccount::..Has Errors...:: ' + hasErrors);
      if (hasErrors) {
        return null;
      }
      newOnlineAcc.id = LeadId;
      System.debug('...Page Name...: ' + pageName);
      setStepNumber(pageName);
      this.newOnlineAcc.Company = 'New Online Account';
      this.newOnlineAcc.LeadSource = ' Zoetis US Portal';
      this.newOnlineAcc.Current_Status__c = 'Save-Next';
      setSpecialtyOptions();
      if (this.newOnlineAcc.RecordTypeId == null) {
        if (this.pageName == 'NOA_BasicAndFacilityInformation') {
          Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get('Online_Account_Licensed_Vet')
            .getRecordTypeId();
          this.newOnlineAcc.RecordTypeId = recTypeId;
        } else {
          Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get('Online_Account_Diagnostic_or_Reproduction')
            .getRecordTypeId();
          this.newOnlineAcc.RecordTypeId = recTypeId;
        }
      }
      System.debug('...Account Type..' + this.newOnlineAcc.Customer_Type__c);
      System.debug(
        '...Account Sub Type...' + this.newOnlineAcc.Customer_Sub_Type__c
      );
      createNullFields();
      upsert newOnlineAcc;

      if (
        this.pageName == 'NOA_BasicAndFacilityInformation' ||
        this.pageName == 'NOA_DiagnosticsorReproductiveServices'
      ) {
        uploadTaxAtt();
      }

      if (
        (formType != null && formType != 'Diagnostics') &&
        (this.pageName == 'NOA_VeterinarianInformation' ||
        this.pageName == 'NOA_OwnershipInformation')
      ) {
        List<Veterinarian_Information__c> backupVetList = new List<Veterinarian_Information__c>();
        backupVetList.addAll(vetList);
        List<Veterinarian_Information__c> existVetList = [
          SELECT
            Id,
            Name,
            DEA__c,
            Veterinarian_Role__c,
            Lead__c,
            Primary__c,
            Delete_Record__c,
            State_License__c,
            Veterinarian_Email__c,
            Veterinarian_First_Name__c,
            Veterinarian_Last_Name__c,
            Veterinarian_Signature_Tag__c
          FROM Veterinarian_Information__c
          WHERE Lead__c = :newOnlineAcc.Id
        ];
        if (existVetList != null || existVetList.size() > 0) {
          delete existVetList;
        }
        System.debug('...backup list...' + backupVetList);
        if (backupVetList != null && backupVetList.size() > 0) {
          List<Veterinarian_Information__c> vetListTobeInserted = new List<Veterinarian_Information__c>();
          Integer tagCounter = 2;
          String fetchESignEmail = null;
          if (this.newOnlineAcc.Ownership_Type__c == 'Sole-proprietorship') {
            fetchESignEmail = this.newOnlineAcc.SP_Email__c;
          } else if (this.newOnlineAcc.Ownership_Type__c == 'Partnership') {
            fetchESignEmail = this.newOnlineAcc.Partership_Email__c;
          } else if (
            this.newOnlineAcc.Ownership_Type__c == 'Corporation' ||
            this.newOnlineAcc.Ownership_Type__c == 'LLC' ||
            this.newOnlineAcc.Ownership_Type__c == 'Government'
          ) {
            fetchESignEmail = this.newOnlineAcc.CLG_Email__c;
          } else {
            fetchESignEmail = this.newOnlineAcc.Email;
          }
          for (Veterinarian_Information__c vet : backupVetList) {
            vet.id = null;
            if (!vet.Delete_Record__c) {
              vet.Lead__c = newOnlineAcc.Id;
              System.debug(
                vet.Veterinarian_Email__c +
                '..vet email compare...' +
                fetchESignEmail
              );
              System.debug(vet.Veterinarian_Email__c == fetchESignEmail);
              if (vet.Veterinarian_Email__c == fetchESignEmail) {
                vet.Veterinarian_Signature_Tag__c = 'O1_es_:signer1:signature}}';
              } else {
                vet.Veterinarian_Signature_Tag__c =
                  'O' +
                  tagCounter +
                  '_es_:signer' +
                  tagCounter +
                  ':signature}}';
                ++tagCounter;
              }
              vetListTobeInserted.add(vet);
              //++tagCounter;
            }
          }
          if (vetListTobeInserted.size() > 0) {
            insert vetListTobeInserted;
          }
        }
      }
    } catch (Exception ex) {
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Error saving New Online Account information.' + ex
        )
      );
      hasErrors = true;
      System.debug(ex.getStackTraceString());
      return null;
    }
    System.debug('...Next Page...: ' + this.nextPage);
    PageReference pageRef = new PageReference('/apex/' + this.nextPage);
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', newOnlineAcc.id);
    return pageRef;
  } //end of SaveNext method

  public PageReference resetForm() {
    PageReference pageRef = null;
    String resetPage = null;
    if (LeadId != null) {
      Id basic_RecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('Online_Account_Licensed_Vet')
        .getRecordTypeId();
      if (this.newOnlineAcc.RecordTypeId == basic_RecTypeId) {
        resetPage = '/apex/NOA_BasicAndFacilityInformation';
      } else {
        resetPage = '/apex/NOA_DiagnosticsorReproductiveServices';
      }
      Lead lead = new Lead(
        ID = LeadId,
        LastName = 'reset-dummy',
        Salutation = null,
        FirstName = null,
        Step_Number__c = 1,
        Email = null,
        Phone = null,
        Business_Name__c = null,
        Customer_Type__c = null,
        Small_Animal__c = null,
        Equine__c = null,
        Beef__c = null,
        Dairy__c = null,
        Swine__c = null,
        Feed__c = null,
        Poultry__c = null,
        Eggs__c = null,
        Turkey__c = null,
        Broiler__c = null,
        Billing_Street_1__c = null,
        Billing_Street_2__c = null,
        Applicant_Role__c = null,
        Billing_County__c = null,
        Billing_City__c = null,
        Billing_State__c = null,
        Billing_Zip_Code__c = null,
        Billing_Phone__c = null,
        Billing_Fax__c = null,
        Billing_Email__c = null,
        Shipping_Street_1__c = null,
        Shipping_Street_2__c = null,
        Shipping_County__c = null,
        Shipping_City__c = null,
        Shipping_State__c = null,
        Shipping_Zip_Code__c = null,
        Shipping_Phone__c = null,
        Shipping_Fax__c = null,
        Shipping_Email__c = null,
        Existing_account_with_Zoetis_at_this_Loc__c = null,
        Ownership_Change__c = null,
        Date_of_Ownership_Change__c = null,
        Existing_account_with_Zoetis__c = null,
        Existing_Account_Name__c = null,
        Zoetis_Account__c = null,
        Sales_Tax_Status__c = null,
        Tax_Permit__c = null,
        Do_you_have_a_licensed_veterinarian__c = null,
        Business_Permit_or_License_Number__c = null,
        Ownership_Type__c = null,
        SP_Name__c = null,
        SP_Telephone__c = null,
        SP_Email__c = null,
        SP_Fax__c = null,
        SP_Address__c = null,
        SP_County__c = null,
        SP_City__c = null,
        SP_State__c = null,
        SP_Zip__c = null,
        Partership_Name__c = null,
        Partnership_Title_or_Officer_Info_1__c = null,
        Partership_Address__c = null,
        Partership_City__c = null,
        Partership_County__c = null,
        Partership_State__c = null,
        Partership_Zip__c = null,
        Partership_Name_2__c = null,
        Partnership_Title_or_Officer_Info_2__c = null,
        Partership_Address_2__c = null,
        Partership_City_2__c = null,
        Partership_County_2__c = null,
        Partership_State_2__c = null,
        Partership_Zip_2__c = null,
        Partership_Telephone__c = null,
        Partership_Fax__c = null,
        Partership_Email__c = null,
        CLG_Name__c = null,
        CLG_Company__c = null,
        CLG_Address__c = null,
        CLG_City__c = null,
        CLG_County__c = null,
        CLG_State__c = null,
        CLG_Zip__c = null,
        CLG_Telephone__c = null,
        CLG_Fax__c = null,
        CLG_Email__c = null,
        Buyer_Name__c = null,
        Buyer_Phone__c = null,
        Years_in_Business__c = null,
        Controller_Name__c = null,
        Controller_Phone__c = null,
        Accounts_Payable_Contact_Name__c = null,
        Accounts_Payable_Contacts_Phone__c = null,
        Has_your_company_filed_bankruptcy__c = null,
        Principal_Bank_Name__c = null,
        Principal_Bank_Phone__c = null,
        Trade_Reference_1_Company_Name__c = null,
        Trade_Reference_1_Company_Phone__c = null,
        Trade_Reference_2_Company_Name__c = null,
        Trade_Reference_2_Company_Phone__c = null,
        Trade_Reference_3_Company_Name__c = null,
        Trade_Reference_3_Company_Phone__c = null,
        Contact_Preference__c = null,
        Current_Status__c = 'Reset-Form'
      );

      try {
        update lead;
        List<Attachment> att = [
          SELECT ID, Description
          FROM Attachment
          WHERE parentid = :LeadId
        ];
        if (att != null && att.size() > 0)
          delete att;
        List<Veterinarian_Information__c> vetInforList = [
          SELECT ID, Lead__c
          FROM Veterinarian_Information__c
          WHERE Lead__c = :LeadId
        ];
        if (vetInforList != null && vetInforList.size() > 0)
          delete vetInforList;
      } catch (Exception e) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Error reseting form ' + e
          )
        );
        hasErrors = true;
        return null;
      }
      pageRef = new PageReference(resetPage);
      pageRef.setRedirect(true);
      pageRef.getParameters().put('id', LeadId);
    }

    return pageRef;
  } // End of Reset Method

  public Lead loadNOA(Id id, String appNo, String emailId) {
    System.debug(id + '...Search Application Number:' + appNo);
    Lead noaLead;
    if (id != null) {
      noaLead = LeadsSelector.selectNOALeadsById(new Set<Id>{ id })[0];
      vetList = VeterinarianInformationSelector.selectByLeadId(
        new Set<Id>{ noaLead.Id }
      );
      if (vetList == null || vetList.size() <= 0) {
        vetList = new List<Veterinarian_Information__c>();
      }
      if (vetList != null && vetList.size() > 0) {
        for (Veterinarian_Information__c vet : vetList) {
          vet.Lead__c = null;
        }
      }
      Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
        .get('Online_Account_Licensed_Vet')
        .getRecordTypeId();
      if (noaLead.RecordTypeId == recTypeId) {
        formType = 'Basic';
      } else {
        formType = 'Diagnostics';
      }

      return noaLead;
    } else if (
      appNo != null &&
      appNo.length() > 0 &&
      emailId != null &&
      emailId.length() > 0
    ) {
      System.debug('..app no...' + appNo);
      List<Lead> noaLeads = LeadsSelector.selectNOALeadsByAppIdAndEmail(
        new Set<String>{ appNo },
        new Set<String>{ emailId }
      );
      System.debug('...search results...' + noaLeads);
      if (noaLeads != null && noaLeads.size() > 0) {
        noaLead = noaLeads[0];
        vetList = VeterinarianInformationSelector.selectByLeadId(
          new Set<Id>{ noaLead.Id }
        );
        if (vetList != null && vetList.size() > 0) {
          for (Veterinarian_Information__c vet : vetList) {
            vet.Lead__c = null;
          }
        }
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
          .get('Online_Account_Licensed_Vet')
          .getRecordTypeId();
        if (noaLead.RecordTypeId == recTypeId) {
          formType = 'Basic';
        } else {
          formType = 'Diagnostics';
        }
        return noaLead;
      } else {
        return null;
      }
    }
    return null;
  } //end of load method

  public void openApplication() {
  }

  public PageReference fetchNOA() {
    PageReference pageRef = null;
    if (
      applicationNo != null &&
      applicationNo.length() > 0 &&
      emailId != null &&
      emailId.length() > 0
    ) {
      applicationNo = applicationNo.trim();
      emailId = emailId.trim();
      newOnlineAcc = loadNOA(null, applicationNo, emailId);
      initializeStepNos();
      if (newOnlineAcc == null || newOnlineAcc.status == 'To be Deleted') {
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'No Application Found. Please Try Again.'
          )
        );
        hasErrors = true;
        return null;
      }

      if (
        newOnlineAcc.Signature_Status__c == 'Out for Signature' ||
        (newOnlineAcc.status != 'Open' &&
        newOnlineAcc.status != 'Under Review' &&
        newOnlineAcc.status != 'Permanent Pending')
      ) {
        pageRef = new PageReference('/apex/NOA_SubmittedForm');
        readonly = true;
      } else {
        Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
          .get('Online_Account_Licensed_Vet')
          .getRecordTypeId();
        System.debug(newOnlineAcc.RecordTypeId + '-----' + recTypeId);
        System.debug('Compare..' + (newOnlineAcc.RecordTypeId == recTypeId));
        if (newOnlineAcc.RecordTypeId == recTypeId) {
          System.debug(
            newOnlineAcc.Step_Number__c +
            '....Inside Vet...' +
            (stepNumberPageNameMap.get(
              String.valueOf(newOnlineAcc.Step_Number__c)
            ))
          );

          if (newOnlineAcc.Step_Number__c != null) {
            pageRef = new PageReference(
              '/apex/' +
              stepNumberPageNameMap.get(
                String.valueOf(newOnlineAcc.Step_Number__c)
              )
            );
          } else {
            ApexPages.addmessage(
              new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Invalid Application Number.'
              )
            );
            hasErrors = true;
            return null;
          }
        } else {
          if (newOnlineAcc.Step_Number__c != null) {
            pageRef = new PageReference(
              '/apex/NOA_DiagnosticsorReproductiveServices'
            );
          } else {
            ApexPages.addmessage(
              new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Invalid Application Number.'
              )
            );
            hasErrors = true;
            return null;
          }
        }
      }
      pageRef.getParameters().put('id', this.newOnlineAcc.id);
      pageRef.setRedirect(true);
    } else if (this.sapBillToId != null && this.sapBillToId.length() > 0) {
      System.Debug('...SAP Bill To Search Id: ' + this.sapBillToId);
      sapBillToIdLeads = LeadsSelector.selectNOALeadsBySAPBillToId(
        new Set<String>{ this.sapBillToId }
      );
      System.debug('...SAP Bill To Search Result: ' + sapBillToIdLeads);
      if (sapBillToIdLeads == null || sapBillToIdLeads.size() <= 0) {
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'No application found with the given Bill To Account Number. Please contact us for assistance at 1-855-721-0078'
          )
        );
        hasErrors = true;
      }
      return null;
    } else {
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Please Provide Both an Application Number and an Email Address'
        )
      );
      hasErrors = true;
      return null;
    }
    return pageRef;
  }

  public void loadAttachments(Id aID) {
    if (
      this.pageName == 'NOA_BasicAndFacilityInformation' ||
      this.pageName == 'NOA_ReviewAndSubmit' ||
      this.pageName == 'NOA_DiagnosticsorReproductiveServices' ||
      this.pageName == 'NOA_SubmittedForm' ||
      this.pageName == 'NOA_DownloadForm' ||
      this.pageName == 'NOA_FinalFormPDF'
    ) {
      List<Attachment> taxAtt = [
        SELECT Id, name, description
        FROM Attachment
        WHERE parentid = :aId
        ORDER BY createdDate
      ];
      for (Attachment a : taxAtt) {
        if (
          a.Description != null &&
          a.Description.equalsIgnoreCase('Tax Permit Document')
        ) {
          this.existingTaxAtt = a;
        } else if (
          a.Description != null &&
          a.Description.equalsIgnoreCase('Signed Application Form')
        ) {
          this.existingSignedAtt = a;
        } else if (
          a.Description == null ||
          (a.Description != 'Tax Permit Document' &&
          a.Description != 'Signed Application Form')
        ) {
          this.existingOtherAtt.add(a);
        }
      }
    }
    System.debug('....otherss...' + existingOtherAtt);
  }

  public void uploadTaxAtt() {
    try {
      System.debug('..111 name ' + taxAtt.name);
      System.debug('...222 des' + taxAtt.description);
      System.debug('..111 body' + taxAtt.body);
      taxAtt.OwnerId = UserInfo.getUserId();
      if (taxAtt != null && taxAtt.Name != null && newOnlineAcc.Id != null) {
        taxAtt.parentId = newOnlineAcc.Id;
        taxAtt.Description = 'Tax Permit Document';
        if (existingTaxAtt != null) {
          delete existingTaxAtt;
        }
        insert taxAtt;
        taxAtt.Body = null;
        existingTaxAtt = taxAtt;
      }
    } catch (exception ex) {
      apexPages.addMessage(
        new apexPages.Message(ApexPages.Severity.ERROR, 'Error uploading file')
      );
      hasErrors = true;
    } /*finally{
if(LeadId != null){
taxAtt = new Attachment();
}
}*/
    //return null;
  }

  //Created for CR
  public PageReference uploadSalesTaxAtt() {
    this.newOnlineAcc.Id = LeadId;
    if (taxAtt.Body == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Error,
          'Please select a file for uploading'
        )
      );
      hasErrors = true;
    } else {
      try {
        taxAtt.OwnerId = UserInfo.getUserId();
        taxAtt.parentId = LeadId;
        taxAtt.Description = 'Tax Permit Document';
        if (existingTaxAtt != null)
          delete existingTaxAtt;
        insert taxAtt;
        taxAtt.Body = null;
        existingTaxAtt = taxAtt;
        this.newOnlineAcc.Id = this.LeadId;
        update newOnlineAcc;
      } catch (exception e) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.Error,
            'Error uploading Tax file'
          )
        );
        hasErrors = true;
      } finally {
        taxAtt = new Attachment();
      }
    }
    return null;
  }

  public List<SelectOption> getHospitalTypeItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(
      new SelectOption(
        'General',
        'General Practice Only – a veterinary hospital that provides general medical and surgical care for patients'
      )
    );
    options.add(
      new SelectOption(
        'GeneralAndAH',
        'General Practice + After Hour Emergency Facility – a veterinary hospital that provides general medical and surgical care for patients as well as providing after hour emergency services'
      )
    );
    options.add(
      new SelectOption(
        'Mobile',
        'Mobile Only Practice – veterinary practice that provides (primarily) out of hospital services; farm, home and retail locations '
      )
    );
    options.add(
      new SelectOption(
        'Emergency',
        'Emergency Hospital Only – a veterinary medical facility dedicated to emergency care only, primarily after hour services for general practitioners and pet owners  '
      )
    );
    options.add(
      new SelectOption(
        'Feline',
        'Feline Only hospital – a veterinary practice that exclusively treats feline patients (no canine)'
      )
    );
    options.add(
      new SelectOption(
        'Specialty',
        'Specialty or Referral Hospital - please select for further options'
      )
    );
    return options;
  }

  public List<SelectOption> getHospitalSubTypeItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(
      new SelectOption(
        'Specialty',
        'Specialty hospital only – a hospital entity that is comprised of board certified veterinary specialists where patients are primarily referred by general practitioners.'
      )
    );
    options.add(
      new SelectOption(
        'SpecialtyWithEmergency',
        'Specialty hospital with emergency services – a hospital entity that is comprised of board certified veterinary specialists where patients are primarily referred by general practitioners and provides 24/7 emergency services (typically onsite)'
      )
    );
    options.add(
      new SelectOption(
        'SpecialtyHybrid',
        'Specialty hospital with emergency and GP hospital services (hybrid) – a hospital entity that is comprised of primarily board certified veterinary specialists, provides 24/7 emergency services and contains a general practice as part of overall services'
      )
    );
    return options;
  }

  public void setSpecialtyOptions() {
    system.debug('hospital type: ' + this.hospitalType);
    if (
      this.hospitalType == 'General' ||
      this.hospitalType == 'GeneralAndAH' ||
      this.hospitalType == 'Mobile' ||
      this.hospitalType == null
    ) {
      this.newOnlineAcc.Specialty_Hospital__c = false;
    } else {
      this.newOnlineAcc.Specialty_Hospital__c = true;
    }
    String typeToMatch = this.hospitalType == 'Specialty'
      ? this.hospitalSubType
      : this.hospitalType;
    Schema.DescribeFieldResult descField = Lead.Specialty_Description__c.getDescribe();
    List<Schema.PicklistEntry> pickEntries = descField.getPicklistValues();
    for (Schema.PicklistEntry pe : pickEntries) {
      String valString = pe.getValue();
      if (typeToMatch == valString) {
        this.newOnlineAcc.Specialty_Description__c = valString;
        break;
      }
    }
  }

  public void setPicklistValues() {
    prefix = new List<SelectOption>();
    ownershipType = new List<SelectOption>();
    customerType = new List<SelectOption>();
    salesTaxStatus = new List<SelectOption>();
    statePicklist = new List<SelectOption>();
    applicantRole = new List<SelectOption>();
    //typeOfBusiness = new List<SelectOption>();

    Schema.DescribeFieldResult fieldResult;

    fieldResult = Lead.Salutation.getDescribe();
    for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
      prefix.add(new SelectOption(p.getValue(), p.getValue()));
    }

    fieldResult = Lead.Customer_Type__c.getDescribe();
    for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
      customerType.add(new SelectOption(p.getValue(), p.getValue()));
    }

    fieldResult = Lead.Applicant_Role__c.getDescribe();
    for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
      applicantRole.add(new SelectOption(p.getValue(), p.getValue()));
    }

    fieldResult = Lead.Ownership_Type__c.getDescribe();
    for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
      ownershipType.add(new SelectOption(p.getValue(), p.getValue()));
    }

    fieldResult = Lead.Sales_Tax_Status__c.getDescribe();
    for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
      salesTaxStatus.add(new SelectOption(p.getValue(), p.getValue()));
    }

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

    // fieldResult = Lead.StateCode.getDescribe();
    // for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
    //     if(p.getLabel() != 'Federated Micronesia' && p.getLabel() != 'Guam' && p.getLabel() != 'Marshall Islands' &&
    //        p.getLabel() != 'Northern Mariana Islands' && p.getLabel() != 'Other' && p.getLabel() != 'Hawaii'){
    //             statePicklist.add(new SelectOption(p.getValue(),p.getLabel()));
    //     }
    // }
  } //End of set picklist values method

  public void setNextPrevPages() {
    if (this.pageName == 'NOA_Distribution') {
      this.prevPage = 'NOA_homepage';
    } else if (this.pageName == 'NOA_BasicAndFacilityInformation') {
      this.nextPage = 'NOA_VeterinarianInformation';
    } else if (this.pageName == 'NOA_VeterinarianInformation') {
      this.prevPage = 'NOA_BasicAndFacilityInformation';
      this.nextPage = 'NOA_OwnershipInformation';
    } else if (this.pageName == 'NOA_OwnershipInformation') {
      if (formType != null && formType == 'Diagnostics') {
        this.prevPage = 'NOA_DiagnosticsorReproductiveServices';
      } else {
        this.prevPage = 'NOA_VeterinarianInformation';
      }
      this.nextPage = 'NOA_ReviewAndSubmit';
    } else if (this.pageName == 'NOA_ReviewAndSubmit') {
      /* SC-002745
            if(formType != null && formType == 'Diagnostics'){
                this.prevPage = 'NOA_DiagnosticsorReproductiveServices'; 
            }else{
                this.prevPage = 'NOA_OwnershipInformation';                 
            } */
      this.prevPage = 'NOA_OwnershipInformation';
    } else if (this.pageName == 'NOA_DiagnosticsorReproductiveServices') {
      //SC-002745 this.nextPage = 'NOA_ReviewAndSubmit';
      this.nextPage = 'NOA_OwnershipInformation';
    }
  }

  public PageReference createFormOne() {
    System.debug(
      '...createFormOne...' +
      newOnlineAcc.Do_you_have_a_licensed_veterinarian__c
    );
    PageReference pageRef = null;
    if (
      newOnlineAcc.Do_you_have_a_licensed_veterinarian__c != null &&
      newOnlineAcc.Do_you_have_a_licensed_veterinarian__c == 'Yes'
    ) {
      pageRef = new PageReference('/apex/NOA_BasicAndFacilityInformation');
      pageRef.getParameters()
        .put('accountType', this.newOnlineAcc.Customer_Type__c);
      pageRef.getParameters()
        .put('accountSubType', this.newOnlineAcc.Customer_Sub_Type__c);
      pageRef.setRedirect(true);
    } else if (
      newOnlineAcc.Do_you_have_a_licensed_veterinarian__c == null ||
      newOnlineAcc.Do_you_have_a_licensed_veterinarian__c == 'No'
    ) {
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.INFO,
          'Thank you for your interest in sourcing Zoetis products. Please contact us at 1-855-721-0078 if you have any questions or need more information.'
        )
      );
      hasErrors = true;
    }
    return pageRef;
  }

  public void addVet() {
    if (vetList == null)
      vetList = new List<Veterinarian_Information__c>();

    Veterinarian_Information__c vet = new Veterinarian_Information__c();
    //vet.Lead__c = this.LeadId;
    vetList.add(vet);
  }

  public PageReference previous() {
    PageReference pageRef = new PageReference('/apex/' + this.prevPage);
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', this.LeadId);
    return pageRef;
  }

  public PageReference saveExit() {
    try {
      validateCurrentPage('saveexit');
      if (hasErrors) {
        return null;
      }
      newOnlineAcc.id = LeadId;
      setStepNumber(pageName);
      this.newOnlineAcc.Company = 'New Online Account';
      this.newOnlineAcc.LeadSource = 'Zoetis US Portal';
      this.newOnlineAcc.Current_Status__c = 'Save-Exit';
      if (this.newOnlineAcc.RecordTypeId == null) {
        if (this.pageName == 'NOA_BasicAndFacilityInformation') {
          Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get('Online_Account_Licensed_Vet')
            .getRecordTypeId();
          this.newOnlineAcc.RecordTypeId = recTypeId;
        } else {
          Id recTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get('Online_Account_Diagnostic_or_Reproduction')
            .getRecordTypeId();
          this.newOnlineAcc.RecordTypeId = recTypeId;
        }
      }
      setSpecialtyOptions();
      //this.newOnlineAcc.Customer_Type__c = this.accountType;
      upsert newOnlineAcc;
      if (
        this.pageName == 'NOA_BasicAndFacilityInformation' ||
        this.pageName == 'NOA_DiagnosticsorReproductiveServices'
      ) {
        uploadTaxAtt();
      }

      if (this.pageName == 'NOA_VeterinarianInformation') {
        List<Veterinarian_Information__c> backupVetList = new List<Veterinarian_Information__c>();
        backupVetList.addAll(vetList);
        List<Veterinarian_Information__c> existVetList = [
          SELECT
            Id,
            Name,
            DEA__c,
            Veterinarian_Role__c,
            Lead__c,
            Primary__c,
            Delete_Record__c,
            State_License__c,
            Veterinarian_Email__c,
            Veterinarian_First_Name__c,
            Veterinarian_Last_Name__c,
            Veterinarian_Signature_Tag__c
          FROM Veterinarian_Information__c
          WHERE Lead__c = :newOnlineAcc.Id
        ];
        if (existVetList != null || existVetList.size() > 0) {
          delete existVetList;
        }
        System.debug('...backup list...' + backupVetList);
        if (backupVetList != null && backupVetList.size() > 0) {
          for (Veterinarian_Information__c vet : backupVetList) {
            vet.id = null;
            if (!vet.Delete_Record__c) {
              vet.Lead__c = newOnlineAcc.Id;
            }
          }
          insert backupVetList;
        }
      }

      //copyBillingAddress();
      createNullFields();
      //newOnlineAcc.NOA_Base_URL__c = URL.getSalesforceBaseUrl().toExternalForm()+'/newonlineaccount/'+pageName;
      upsert newOnlineAcc;
    } catch (Exception ex) {
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Error saving Online Account information.' + ex
        )
      );
      hasErrors = true;
      System.debug(ex.getStackTraceString());
      return null;
    }
    newOnlineAcc = null;
    PageReference pageRef = new PageReference('/apex/NOA_homepage');
    pageRef.setRedirect(true);
    return pageRef;
  }

  public PageReference discard() {
    try {
      if (LeadId != null) {
        newOnlineAcc.id = LeadId;
        newOnlineAcc.status = 'To be Deleted';
        update newOnlineAcc;

        /*
                List<Attachment> att = [Select ID,Description from Attachment where parentId = :LeadId]; 
                if( att != null && att.size() > 0)
                    Delete att;
                List<Veterinarian_Information__c> vetInforList = [Select ID,Lead__c from Veterinarian_Information__c where Lead__c = :LeadId];
                if(vetInforList != null && vetInforList.size() > 0)
                    Delete vetInforList;
                newOnlineAcc.ID = LeadId;
                System.debug('Discarding Lead...' + newOnlineAcc.ID);
                Delete newOnlineAcc;
                */
      }
    } catch (exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Error,
          'Error discarding form' + e
        )
      );
      System.debug('Discard Exception==>' + e.getStackTraceString());
      hasErrors = true;
      return null;
    }
    newOnlineAcc = null;
    System.debug('...Redirecting to homepage after discarding NOA lead...');
    PageReference pageRef = new PageReference('/apex/NOA_homepage');
    pageRef.setRedirect(true);
    return pageRef;
  } // End of discard method

  public PageReference submitNOA() {
    try {
      validateCurrentPage('submit');
      if (hasErrors) {
        return null;
      }
      createNullFields();
      newOnlineAcc.Id = LeadId;
      setStepNumber(pageName);
      newOnlineAcc.Status = 'Pending Exton Verification';
      newOnlineAcc.Current_Status__c = 'Submitted';
      newOnlineAcc.Submitted_Date__c = System.Today();

      upsert newOnlineAcc;
      submitted = true;
      system.debug('New Online Account Submitted ID ==>' + newOnlineAcc.Id);
    } catch (exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Error,
          'Error Submitting New Online Account Form' + e
        )
      );
      System.debug(
        'Error Line num : ' +
        e.getLineNumber() +
        'Error ' +
        e.getStackTraceString()
      );
      hasErrors = true;
    }
    PageReference pageRef = new PageReference('/apex/NOA_SubmittedForm');
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', LeadId);
    pageRef.getParameters().put('submitted', 'true');
    return pageRef;
  } //end of Submit method

  public void copyBillingToShipping() {
    if (sameAsBilling != null && sameAsBilling) {
      this.newOnlineAcc.Shipping_Street_1__c = this.newOnlineAcc.Billing_Street_1__c;
      this.newOnlineAcc.Shipping_Street_2__c = this.newOnlineAcc.Billing_Street_2__c;
      this.newOnlineAcc.Shipping_County__c = this.newOnlineAcc.Billing_County__c;
      this.newOnlineAcc.Shipping_City__c = this.newOnlineAcc.Billing_City__c;
      this.newOnlineAcc.Shipping_State__c = this.newOnlineAcc.Billing_State__c;
      this.newOnlineAcc.Shipping_Zip_Code__c = this.newOnlineAcc.Billing_Zip_Code__c;
      this.newOnlineAcc.Shipping_Phone__c = this.newOnlineAcc.Billing_Phone__c;
      this.newOnlineAcc.Shipping_Fax__c = this.newOnlineAcc.Billing_Fax__c;
      this.newOnlineAcc.Shipping_Email__c = this.newOnlineAcc.Billing_Email__c;
    }
  }

  public PageReference returnToApplication() {
    PageReference pageRef = null;
    newOnlineAcc.id = LeadId;
    ID RecTypeIDret = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('Online_Account_Licensed_Vet')
      .getRecordTypeId();
    if (newOnlineAcc.RecordTypeId == RecTypeIDret) {
      pageRef = new PageReference('/apex/NOA_BasicAndFacilityInformation');
    } else {
      pageRef = new PageReference(
        '/apex/NOA_DiagnosticsorReproductiveServices'
      );
    }
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', LeadId);
    return pageRef;
  }

  public PageReference uploadSignedAtt() {
    //this.newOnlineAcc.Id = LeadId;
    if (signedAtt.Body == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Error,
          'Please select a file for uploading'
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
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.Error,
            'Error uploading file'
          )
        );
        hasErrors = true;
      } finally {
        signedAtt = new Attachment();
      }
    }
    return null;
  }

  public PageReference uploadOtherAtt() {
    this.newOnlineAcc.Id = LeadId;
    if (otherAtt.Body == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.Error,
          'Please select a file for uploading'
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
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.Error,
            'Error Uploading File'
          )
        );
        System.debug(
          'Upload Error ==>' +
          e.getLineNumber() +
          'Error Message==>' +
          e.getMessage()
        );
        hasErrors = true;
      } finally {
        otherAtt = new Attachment();
      }
    }
    return null;
  }

  public PageReference deleteOtherAtt() {
    //this.newOnlineAcc.Id = LeadID;
    try {
      Attachment att = new Attachment(id = this.deleteAtt);
      delete att;
      this.existingOtherAtt = [
        SELECT name, description
        FROM Attachment
        WHERE
          parentid = :LeadId
          AND description NOT IN (
            'Tax Permit Document',
            'Signed Application Form'
          )
      ];
    } catch (exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.Error, 'Error Deleting File')
      );
      hasErrors = true;
    }
    return null;
  }

  @testVisible
  private void setStepNumber(String currPage) {
    System.debug('currPage  >>>>> ' + currPage);
    if (currPage == 'NOA_BasicAndFacilityInformation') {
      System.debug('currPage  >>>>> ' + currPage);
      System.debug(' Step_Number__c >>>> ' + this.newOnlineAcc.Step_Number__c);
      //System.debug( 'Current_Status__c   >>>>> ' +  this.newOnlineAcc.Current_Status__c);
      System.debug('formType   >>>>> ' + formType);

      if (
        this.newOnlineAcc.Step_Number__c == null ||
        this.newOnlineAcc.Step_Number__c < 1
      ) {
        this.newOnlineAcc.Step_Number__c = 1;
        newOnlineAcc.NOA_Base_URL__c =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/newonlineaccount/' +
          currPage;
      }
    } else if (currPage == 'NOA_VeterinarianInformation') {
      System.debug('currPage  >>>>> ' + currPage);
      System.debug(' Step_Number__c >>>> ' + this.newOnlineAcc.Step_Number__c);
      //System.debug( 'Current_Status__c   >>>>> ' +  this.newOnlineAcc.Current_Status__c);
      System.debug('formType   >>>>> ' + formType);
      if (
        this.newOnlineAcc.Step_Number__c == null ||
        this.newOnlineAcc.Step_Number__c < 2
      ) {
        this.newOnlineAcc.Step_Number__c = 2;
        newOnlineAcc.NOA_Base_URL__c =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/newonlineaccount/' +
          currPage;
      }
    } else if (currPage == 'NOA_OwnershipInformation') {
      System.debug('currPage  >>>>> ' + currPage);
      System.debug(' Step_Number__c >>>> ' + this.newOnlineAcc.Step_Number__c);
      //System.debug( 'Current_Status__c   >>>>> ' +  this.newOnlineAcc.Current_Status__c);
      System.debug('formType   >>>>> ' + formType);
      if (formType == 'Basic') {
        if (
          this.newOnlineAcc.Step_Number__c == null ||
          this.newOnlineAcc.Step_Number__c < 3
        ) {
          this.newOnlineAcc.Step_Number__c = 3;
          newOnlineAcc.NOA_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/newonlineaccount/' +
            currPage;
        }
      } else {
        if (
          this.newOnlineAcc.Step_Number__c == null ||
          this.newOnlineAcc.Step_Number__c < 2
        ) {
          this.newOnlineAcc.Step_Number__c = 2;
          newOnlineAcc.NOA_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/newonlineaccount/' +
            currPage;
        }
      }
    } else if (currPage == 'NOA_ReviewAndSubmit') {
      System.debug('currPage  >>>>> ' + currPage);
      System.debug(' Step_Number__c >>>> ' + this.newOnlineAcc.Step_Number__c);
      //System.debug( 'Current_Status__c   >>>>> ' +  this.newOnlineAcc.Current_Status__c);
      System.debug('formType   >>>>> ' + formType);
      if (formType == 'Basic') {
        if (
          this.newOnlineAcc.Step_Number__c == null ||
          this.newOnlineAcc.Step_Number__c < 4
        ) {
          this.newOnlineAcc.Step_Number__c = 4;
          newOnlineAcc.NOA_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/newonlineaccount/' +
            currPage;
        }
      } else {
        if (
          this.newOnlineAcc.Step_Number__c == null ||
          this.newOnlineAcc.Step_Number__c < 3
        ) {
          this.newOnlineAcc.Step_Number__c = 3;
          newOnlineAcc.NOA_Base_URL__c =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/newonlineaccount/' +
            currPage;
        }
      }
    } else if (currPage == 'NOA_DiagnosticsorReproductiveServices') {
      System.debug('currPage  >>>>> ' + currPage);
      System.debug(' Step_Number__c >>>> ' + this.newOnlineAcc.Step_Number__c);
      //System.debug( 'Current_Status__c   >>>>> ' +  this.newOnlineAcc.Current_Status__c);
      System.debug('formType   >>>>> ' + formType);
      if (
        this.newOnlineAcc.Step_Number__c == null ||
        this.newOnlineAcc.Step_Number__c < 1
      ) {
        this.newOnlineAcc.Step_Number__c = 1;
        newOnlineAcc.NOA_Base_URL__c =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/newonlineaccount/' +
          currPage;
      }
    }
  }

  public void validateCurrentPage(String action) {
    hasErrors = false;

    if (this.pageName == 'NOA_BasicAndFacilityInformation') {
      if (
        this.newOnlineAcc.Salutation == null ||
        this.newOnlineAcc.FirstName == null ||
        this.newOnlineAcc.LastName == null ||
        this.newOnlineAcc.Applicant_Role__c == null ||
        this.newOnlineAcc.Email == null ||
        this.newOnlineAcc.Phone == null ||
        this.newOnlineAcc.Business_Name__c == null ||
        this.newOnlineAcc.Billing_Street_1__c == null ||
        this.newOnlineAcc.Billing_City__c == null ||
        this.newOnlineAcc.Billing_State__c == '--Select--' ||
        this.newOnlineAcc.Billing_Zip_Code__c == null ||
        this.newOnlineAcc.Billing_Phone__c == null ||
        this.newOnlineAcc.Billing_Email__c == null ||
        this.newOnlineAcc.Shipping_Street_1__c == null ||
        this.newOnlineAcc.Shipping_City__c == null ||
        this.newOnlineAcc.Shipping_State__c == '--Select--' ||
        this.newOnlineAcc.Shipping_Zip_Code__c == null ||
        this.newOnlineAcc.Shipping_Phone__c == null ||
        this.newOnlineAcc.Shipping_Email__c == null ||
        this.newOnlineAcc.Existing_account_with_Zoetis_at_this_Loc__c == null ||
        this.newOnlineAcc.Ownership_Change__c == null ||
        (!this.newOnlineAcc.New_Shipping_Location__c &&
        this.newOnlineAcc.Existing_account_with_Zoetis__c == null) ||
        newOnlineAcc.Sales_Tax_Status__c == null ||
        (!this.newOnlineAcc.New_Shipping_Location__c &&
        newOnlineAcc.Contact_Preference__c == null)
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
        );
      } else if (
        this.newOnlineAcc.Ownership_Change__c == 'Yes' &&
        this.newOnlineAcc.Date_of_Ownership_Change__c == null
      ) {
        /*else if(this.newOnlineAcc.Customer_Type__c=='Other' && this.newOnlineAcc.Customer_Type_Other__c==null){
                   hasErrors = true;
                   ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Customer Type Other')); 
               }*/ hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter Date of Ownership Change'
          )
        );
      } else if (
        this.newOnlineAcc.Existing_account_with_Zoetis__c == 'Yes' &&
        (this.newOnlineAcc.Existing_Account_Name__c == null ||
        this.newOnlineAcc.Zoetis_Account__c == null)
      ) {
        /*
            else if(this.newOnlineAcc.Ownership_Change__c=='Yes' && this.newOnlineAcc.Date_of_Ownership_Change__c>Date.today())
            {
                hasErrors = true;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ownership Change date cannot be a future date')); 
            }*/

        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter existing account information'
          )
        );
      } else if (
        this.newOnlineAcc.Small_Animal__c == null &&
        this.newOnlineAcc.Equine__c == null &&
        this.newOnlineAcc.Beef__c == null &&
        this.newOnlineAcc.Dairy__c == null &&
        this.newOnlineAcc.Swine__c == null &&
        this.newOnlineAcc.Feed__c == null &&
        this.newOnlineAcc.Poultry__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, customerrormessage)
        );
      }
      if (
        this.newOnlineAcc.Contact_Preference__c != null &&
        this.newOnlineAcc.Contact_Preference__c == 'Fax' &&
        this.newOnlineAcc.Billing_Fax__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter Billing Fax'
          )
        );
      }
      if (
        this.newOnlineAcc.Contact_Preference__c != null &&
        this.newOnlineAcc.Contact_Preference__c == 'Fax' &&
        this.newOnlineAcc.Shipping_Fax__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter Shipping Fax'
          )
        );
      }
      if (!isBusinessTypeValid()) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Invidual Business Type and Sum of all Business Types cannot exceed 100% '
          )
        );
      }
      if (this.newOnlineAcc.Sales_Tax_Status__c == 'Tax Exempt') {
        if (
          this.newOnlineAcc.Tax_Permit__c == null ||
          String.isBlank(this.newOnlineAcc.Tax_Permit__c)
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Please enter Tax Permit information'
            )
          );
        }
      }
    }

    if (
      this.pageName == 'NOA_OwnershipInformation' &&
      !this.newOnlineAcc.New_Shipping_Location__c
    ) {
      /* SC-002745
            if(this.newOnlineAcc.Ownership_Type__c==null || this.newOnlineAcc.Principal_Bank_Name__c==null || this.newOnlineAcc.Principal_Bank_Phone__c==null || this.newOnlineAcc.Trade_Reference_1_Company_Name__c==null 
               || this.newOnlineAcc.Trade_Reference_1_Company_Phone__c==null || this.newOnlineAcc.Trade_Reference_2_Company_Name__c==null || this.newOnlineAcc.Trade_Reference_2_Company_Phone__c==null || this.newOnlineAcc.Trade_Reference_3_Company_Name__c==null || this.newOnlineAcc.Trade_Reference_3_Company_Phone__c==null 
              ) */

      if (
        formType != null &&
        formType == 'Diagnostics' &&
        this.newOnlineAcc.Small_Animal__c == null &&
        this.newOnlineAcc.Equine__c == null &&
        this.newOnlineAcc.Beef__c == null &&
        this.newOnlineAcc.Dairy__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, customerrormessage)
        );
      }

      if (
        this.newOnlineAcc.Ownership_Type__c == null ||
        this.newOnlineAcc.Principal_Bank_Name__c == null ||
        this.newOnlineAcc.Principal_Bank_Phone__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
        );
      } else if (
        this.newOnlineAcc.Ownership_Type__c == 'Sole-proprietorship' &&
        (this.newOnlineAcc.SP_Name__c == null ||
        this.newOnlineAcc.SP_Telephone__c == null ||
        this.newOnlineAcc.SP_Email__c == null ||
        this.newOnlineAcc.SP_Address__c == null ||
        this.newOnlineAcc.SP_City__c == null ||
        this.newOnlineAcc.SP_State__c == '--Select--' ||
        this.newOnlineAcc.SP_Zip__c == null)
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
        );
      } else if (
        this.newOnlineAcc.Ownership_Type__c == 'Partnership' &&
        (this.newOnlineAcc.Partership_Name__c == null ||
        this.newOnlineAcc.Partnership_Title_or_Officer_Info_1__c == null ||
        this.newOnlineAcc.Partership_Address__c == null ||
        this.newOnlineAcc.Partership_City__c == null ||
        this.newOnlineAcc.Partership_State__c == '--Select--' ||
        this.newOnlineAcc.Partership_Zip__c == null ||
        this.newOnlineAcc.Partership_Telephone__c == null ||
        this.newOnlineAcc.Partership_Email__c == null ||
        this.newOnlineAcc.Partership_Name_2__c == null ||
        this.newOnlineAcc.Partnership_Title_or_Officer_Info_2__c == null ||
        this.newOnlineAcc.Partership_Address_2__c == null ||
        this.newOnlineAcc.Partership_City_2__c == null ||
        this.newOnlineAcc.Partership_State_2__c == '--Select--' ||
        this.newOnlineAcc.Partership_Zip_2__c == null)
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
        );
      } else if (
        (this.newOnlineAcc.Ownership_Type__c == 'Corporation' ||
        this.newOnlineAcc.Ownership_Type__c == 'LLC' ||
        this.newOnlineAcc.Ownership_Type__c == 'Government') &&
        (this.newOnlineAcc.CLG_Name__c == null ||
        this.newOnlineAcc.CLG_Company__c == null ||
        this.newOnlineAcc.CLG_Address__c == null ||
        this.newOnlineAcc.CLG_City__c == null ||
        this.newOnlineAcc.CLG_State__c == '--Select--' ||
        this.newOnlineAcc.CLG_Zip__c == null ||
        this.newOnlineAcc.CLG_Telephone__c == null ||
        this.newOnlineAcc.CLG_Email__c == null ||
        this.newOnlineAcc.Buyer_Name__c == null ||
        this.newOnlineAcc.Buyer_Phone__c == null ||
        this.newOnlineAcc.Years_in_Business__c == null ||
        this.newOnlineAcc.Controller_Name__c == null ||
        this.newOnlineAcc.Controller_Phone__c == null ||
        this.newOnlineAcc.Accounts_Payable_Contact_Name__c == null ||
        this.newOnlineAcc.Accounts_Payable_Contacts_Phone__c == null ||
        this.newOnlineAcc.Has_your_company_filed_bankruptcy__c == null ||
        (this.newOnlineAcc.Has_your_company_filed_bankruptcy__c == 'Yes' &&
        (this.newOnlineAcc.Type_of_bankruptcy__c == null ||
        this.newOnlineAcc.Bankrupt_File_Date__c == null)))
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
        );
      } else if (
        (this.newOnlineAcc.Ownership_Type__c == 'Corporation' ||
        this.newOnlineAcc.Ownership_Type__c == 'LLC' ||
        this.newOnlineAcc.Ownership_Type__c == 'Government') &&
        this.newOnlineAcc.Bankrupt_File_Date__c > Date.today()
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Bankrupt File Date cannot be a future date'
          )
        );
      }
    }
    if (this.pageName == 'NOA_VeterinarianInformation') {
      if (vetList == null || vetList.size() <= 0) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Atleast one Veterinarian row must be added'
          )
        );
      } else {
        Integer counter = 0;
        for (Veterinarian_Information__c v : vetList) {
          if (v.Delete_Record__c == true) {
            ++counter;
          }
        }

        if (counter == vetList.size()) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Atleast one Veterinarian row must be added'
            )
          );
        } else {
          for (Veterinarian_Information__c v : vetList) {
            if (
              v.Delete_Record__c == false &&
              (v.Veterinarian_First_Name__c == null ||
              v.Veterinarian_First_Name__c == '' ||
              v.Veterinarian_Last_Name__c == null ||
              v.Veterinarian_Last_Name__c == '' ||
              v.Veterinarian_Email__c == null ||
              v.Veterinarian_Email__c == '' ||
              v.State_License__c == null ||
              v.State_License__c == '' ||
              v.Veterinarian_Role__c == null)
            ) {
              hasErrors = true;
              ApexPages.addmessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
              );
            }
          }
        }
        Integer primaryCounter = 0;
        for (Veterinarian_Information__c v : vetList) {
          if (v.Primary__c == false) {
            ++primaryCounter;
          }
        }
        if (vetList.size() == primaryCounter) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Please select primary licensed veterinarian for shipping purposes'
            )
          );
        }

        for (Veterinarian_Information__c v1 : vetList) {
          if (v1.Primary__c == true && v1.Delete_Record__c == true) {
            hasErrors = true;
            ApexPages.addmessage(
              new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Cannot delete a primary vet'
              )
            );
          }
        }
        Integer primCounter = 0;
        for (Veterinarian_Information__c vet : vetList) {
          if (vet.Primary__c == true) {
            ++primCounter;
          }
        }
        if (primCounter > 1) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Only one veterinarian can be selected as Primary'
            )
          );
        }
      }
    }

    if (this.pageName == 'NOA_DiagnosticsorReproductiveServices') {
      /* SC-002745
            if(this.newOnlineAcc.Business_Name__c==null || this.newOnlineAcc.FirstName==null || this.newOnlineAcc.LastName==null || this.newOnlineAcc.Applicant_Role__c==null || this.newOnlineAcc.Email==null || this.newOnlineAcc.Phone==null || this.newOnlineAcc.Billing_Street_1__c==null || this.newOnlineAcc.Billing_City__c==null || this.newOnlineAcc.Billing_State__c=='--Select--'
               || this.newOnlineAcc.Billing_Zip_Code__c==null || this.newOnlineAcc.Billing_Phone__c==null || this.newOnlineAcc.Billing_Email__c==null || this.newOnlineAcc.Shipping_Street_1__c==null || this.newOnlineAcc.Shipping_City__c==null  || this.newOnlineAcc.Shipping_State__c=='--Select--'
               || this.newOnlineAcc.Shipping_Zip_Code__c==null || this.newOnlineAcc.Shipping_Phone__c==null ||  this.newOnlineAcc.Shipping_Email__c==null || this.newOnlineAcc.Principal_Bank_Name__c==null || this.newOnlineAcc.Principal_Bank_Phone__c==null
               || this.newOnlineAcc.Trade_Reference_1_Company_Name__c==null || this.newOnlineAcc.Trade_Reference_1_Company_Phone__c==null || this.newOnlineAcc.Trade_Reference_2_Company_Name__c==null || this.newOnlineAcc.Trade_Reference_2_Company_Phone__c==null
               || this.newOnlineAcc.Trade_Reference_3_Company_Name__c==null || this.newOnlineAcc.Trade_Reference_3_Company_Phone__c==null || this.newOnlineAcc.Contact_Preference__c==null || newOnlineAcc.Sales_Tax_Status__c == null
              ) */
      if (
        this.newOnlineAcc.Business_Name__c == null ||
        this.newOnlineAcc.FirstName == null ||
        this.newOnlineAcc.LastName == null ||
        this.newOnlineAcc.Applicant_Role__c == null ||
        this.newOnlineAcc.Email == null ||
        this.newOnlineAcc.Phone == null ||
        this.newOnlineAcc.Billing_Street_1__c == null ||
        this.newOnlineAcc.Billing_City__c == null ||
        this.newOnlineAcc.Billing_State__c == '--Select--' ||
        this.newOnlineAcc.Billing_Zip_Code__c == null ||
        this.newOnlineAcc.Billing_Phone__c == null ||
        this.newOnlineAcc.Billing_Email__c == null ||
        this.newOnlineAcc.Shipping_Street_1__c == null ||
        this.newOnlineAcc.Shipping_City__c == null ||
        this.newOnlineAcc.Shipping_State__c == '--Select--' ||
        this.newOnlineAcc.Shipping_Zip_Code__c == null ||
        this.newOnlineAcc.Shipping_Phone__c == null ||
        this.newOnlineAcc.Shipping_Email__c == null ||
        this.newOnlineAcc.Contact_Preference__c == null ||
        newOnlineAcc.Sales_Tax_Status__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, requiredMessage)
        );
      }

      if (
        this.newOnlineAcc.Contact_Preference__c != null &&
        this.newOnlineAcc.Contact_Preference__c == 'Fax' &&
        this.newOnlineAcc.Billing_Fax__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter Billing Fax'
          )
        );
      }
      if (
        this.newOnlineAcc.Contact_Preference__c != null &&
        this.newOnlineAcc.Contact_Preference__c == 'Fax' &&
        this.newOnlineAcc.Shipping_Fax__c == null
      ) {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Please enter Shipping Fax'
          )
        );
      }

      if (this.newOnlineAcc.Sales_Tax_Status__c == 'Tax Exempt') {
        if (
          this.newOnlineAcc.Tax_Permit__c == null ||
          String.isBlank(this.newOnlineAcc.Tax_Permit__c)
        ) {
          hasErrors = true;
          ApexPages.addmessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Please enter Tax Permit information'
            )
          );
        }
      }
      /* SC-002745
            if(this.newOnlineAcc.Type_of_Business__c == 'Other'){
                if(this.newOnlineAcc.Business_Other__c == null || String.isBlank(this.newOnlineAcc.Business_Other__c)){
                    hasErrors = true;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter Business Other information'));  
                } 
            } */
    }

    if (action == 'Submit') {
      if (this.newOnlineAcc.Signature_Status__c == 'Out for Signature') {
        hasErrors = true;
        ApexPages.addmessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Electronic Signatures must be signed by all parties and in Completed status before submitting the application'
          )
        );
      } else if (
        String.isBlank(this.newOnlineAcc.Signature_Status__c) &&
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

    /*
        if(this.pageName=='NOA_ReviewAndSubmit')
        {
            
            if(this.newOnlineAcc.Sales_Tax_Status__c == 'Tax Exempt'){ 
                if(this.existingTaxAtt.Name==null && this.taxAtt.Name==null){
                    hasErrors = true;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Upload Tax Exemption Certificate')); 
                }
            } 
            
           // if(this.existingSignedAtt.Name==null && this.signedAtt.Name == Null)
            //{
              //  hasErrors = true;
            //    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Upload Signed Application form'));  
            //}
        } */
  }

  public void createNullFields() {
    if (
      this.pageName == 'NOA_BasicAndFacilityInformation' ||
      this.pageName == 'NOA_DiagnosticsorReproductiveServices'
    ) {
      if (newOnlineAcc.Customer_Type__c != 'Other') {
        newOnlineAcc.Customer_Type_Other__c = null;
      }
      if (newOnlineAcc.Poultry__c == null) {
        newOnlineAcc.Eggs__c = null;
        newOnlineAcc.Turkey__c = null;
        newOnlineAcc.Broiler__c = null;
      }
      if (newOnlineAcc.Ownership_Change__c != 'Yes') {
        newOnlineAcc.Date_of_Ownership_Change__c = null;
      }
      if (newOnlineAcc.Existing_account_with_Zoetis__c != 'Yes') {
        newOnlineAcc.Existing_Account_Name__c = null;
        newOnlineAcc.Zoetis_Account__c = null;
      }
      if (newOnlineAcc.Sales_Tax_Status__c != 'Tax Exempt') {
        newOnlineAcc.Tax_Permit__c = null;
        if (this.TaxAtt != null && this.TaxAtt.id != null) {
          delete TaxAtt;
        } else if (
          this.existingTaxAtt != null &&
          this.existingTaxAtt.ID != null
        ) {
          delete existingTaxAtt;
          this.taxAtt = null;
        }
        taxAtt = new Attachment();
      }
      /* SC-002745
            if(this.newOnlineAcc.Type_of_Business__c != null && this.newOnlineAcc.Type_of_Business__c != 'Other'){
                    this.newOnlineAcc.Business_Other__c = null;
            } */
    } else if (this.pageName == 'NOA_OwnershipInformation') {
      if (newOnlineAcc.Ownership_Type__c != 'Sole-proprietorship') {
        newOnlineAcc.SP_Name__c = null;
        newOnlineAcc.SP_Telephone__c = null;
        newOnlineAcc.SP_Email__c = null;
        newOnlineAcc.SP_Fax__c = null;
        newOnlineAcc.SP_Address__c = null;
        newOnlineAcc.SP_County__c = null;
        newOnlineAcc.SP_City__c = null;
        newOnlineAcc.SP_State__c = null;
        newOnlineAcc.SP_Zip__c = null;
      }
      if (newOnlineAcc.Ownership_Type__c != 'Partnership') {
        newOnlineAcc.Partership_Name__c = null;
        newOnlineAcc.Partnership_Title_or_Officer_Info_1__c = null;
        newOnlineAcc.Partership_Address__c = null;
        newOnlineAcc.Partership_City__c = null;
        newOnlineAcc.Partership_County__c = null;
        newOnlineAcc.Partership_State__c = null;
        newOnlineAcc.Partership_Zip__c = null;
        newOnlineAcc.Partership_Telephone__c = null;
        newOnlineAcc.Partership_Email__c = null;
        newOnlineAcc.Partership_Name_2__c = null;
        newOnlineAcc.Partnership_Title_or_Officer_Info_2__c = null;
        newOnlineAcc.Partership_Address_2__c = null;
        newOnlineAcc.Partership_City_2__c = null;
        newOnlineAcc.Partership_County_2__c = null;
        newOnlineAcc.Partership_State_2__c = null;
        newOnlineAcc.Partership_Zip_2__c = null;
        newOnlineAcc.Partership_Fax__c = null;
      }
      if (
        newOnlineAcc.Ownership_Type__c != 'Corporation' &&
        newOnlineAcc.Ownership_Type__c != 'LLC' &&
        newOnlineAcc.Ownership_Type__c != 'Government'
      ) {
        newOnlineAcc.CLG_Name__c = null;
        newOnlineAcc.CLG_Company__c = null;
        newOnlineAcc.CLG_Address__c = null;
        newOnlineAcc.CLG_City__c = null;
        newOnlineAcc.CLG_County__c = null;
        newOnlineAcc.CLG_State__c = null;
        newOnlineAcc.CLG_Zip__c = null;
        newOnlineAcc.CLG_Telephone__c = null;
        newOnlineAcc.CLG_Fax__c = null;
        newOnlineAcc.CLG_Email__c = null;
        newOnlineAcc.Buyer_Name__c = null;
        newOnlineAcc.Buyer_Phone__c = null;
        newOnlineAcc.Years_in_Business__c = null;
        newOnlineAcc.Controller_Name__c = null;
        newOnlineAcc.Controller_Phone__c = null;
        newOnlineAcc.Accounts_Payable_Contact_Name__c = null;
        newOnlineAcc.Accounts_Payable_Contacts_Phone__c = null;
        newOnlineAcc.Has_your_company_filed_bankruptcy__c = null;
      }
      if (newOnlineAcc.Has_your_company_filed_bankruptcy__c != 'Yes') {
        newOnlineAcc.Type_of_bankruptcy__c = null;
        newOnlineAcc.Bankrupt_File_Date__c = null;
      }
    }
    if (this.pageName == 'NOA_ReviewAndSubmit') {
      /*
            if(newOnlineAcc.Sales_Tax_Status__c != 'Tax Exempt'){
                newOnlineAcc.Tax_Permit__c = Null;
                if(this.TaxAtt != Null && this.TaxAtt.id != Null){
                    Delete TaxAtt;
                }else if( this.existingTaxAtt != Null && this.existingTaxAtt.ID != Null){
                    Delete existingTaxAtt;
                    this.taxAtt = Null;
                }
                taxAtt = new Attachment();
            }   */
    }
  } //end of createNullFields method

  @TestVisible
  private boolean isBusinessTypeValid() {
    boolean isValid = true;
    Decimal total = 0;
    system.debug('Small Animal Count==>' + newOnlineAcc.Small_Animal__c);
    if (this.newOnlineAcc.Small_Animal__c != null) {
      total = total + this.newOnlineAcc.Small_Animal__c;
    }
    system.debug('Equine Count==>' + newOnlineAcc.Equine__c);
    if (this.newOnlineAcc.Equine__c != null) {
      total = total + this.newOnlineAcc.Equine__c;
    }

    if (this.newOnlineAcc.Beef__c != null) {
      total = total + this.newOnlineAcc.Beef__c;
    }

    if (this.newOnlineAcc.Dairy__c != null) {
      total = total + this.newOnlineAcc.Dairy__c;
    }

    if (this.newOnlineAcc.Swine__c != null) {
      total = total + this.newOnlineAcc.Swine__c;
    }

    if (this.newOnlineAcc.Feed__c != null) {
      total = total + this.newOnlineAcc.Feed__c;
    }

    if (this.newOnlineAcc.Poultry__c != null) {
      total = total + this.newOnlineAcc.Poultry__c;
    }

    if (
      (total > 100 ||
      this.newOnlineAcc.Small_Animal__c > 100 ||
      this.newOnlineAcc.Equine__c > 100 ||
      this.newOnlineAcc.Beef__c > 100 ||
      this.newOnlineAcc.Dairy__c > 100 ||
      this.newOnlineAcc.Swine__c > 100 ||
      this.newOnlineAcc.Feed__c > 100 ||
      this.newOnlineAcc.Poultry__c > 100) ||
      (this.newOnlineAcc.Poultry__c != null &&
      ((this.newOnlineAcc.Eggs__c != null &&
      this.newOnlineAcc.Eggs__c > 100) ||
      (this.newOnlineAcc.Turkey__c != null &&
      this.newOnlineAcc.Turkey__c > 100) ||
      (this.newOnlineAcc.Broiler__c != null &&
      this.newOnlineAcc.Broiler__c > 100)))
    ) {
      isValid = false;
    }

    return isValid;
  }

  public echosign_dev1__SIGN_Agreement__c agmt = null;

  public PageReference adobeSendForSignature() {
    setStepNumber(pageName);
    agmt = new echosign_dev1__SIGN_Agreement__c();
    agmt.Name =
      'Zoetis New Account Agreement - ' +
      this.newOnlineAcc.NOA_Application_Number__c;
    System.debug('...LeadId...' + this.LeadId);
    agmt.Lead__c = this.LeadId;
    agmt.echosign_dev1__Signature_Flow__c = 'Any Order';
    String[] stringList = new List<String>(0);
    List<Veterinarian_Information__c> vetInforList = [
      SELECT ID, Lead__c, Veterinarian_Email__c
      FROM Veterinarian_Information__c
      WHERE Lead__c = :this.LeadId
    ];

    String fetchESignEmail = null;
    if (formType != null && formType != 'Diagnostics') {
      if (this.newOnlineAcc.Ownership_Type__c == 'Sole-proprietorship') {
        fetchESignEmail = this.newOnlineAcc.SP_Email__c;
      } else if (this.newOnlineAcc.Ownership_Type__c == 'Partnership') {
        fetchESignEmail = this.newOnlineAcc.Partership_Email__c;
      } else if (
        this.newOnlineAcc.Ownership_Type__c == 'Corporation' ||
        this.newOnlineAcc.Ownership_Type__c == 'LLC' ||
        this.newOnlineAcc.Ownership_Type__c == 'Government'
      ) {
        fetchESignEmail = this.newOnlineAcc.CLG_Email__c;
      }
    } else {
      fetchESignEmail = this.newOnlineAcc.Email;
    }

    for (Veterinarian_Information__c vi : vetInforList) {
      if (vi.Veterinarian_Email__c != fetchESignEmail) {
        stringList.add(String.valueOf(vi.Veterinarian_Email__c));
      }
    }

    // SC-009711  
    Map<String, NOA_Accounts_Exempt__mdt> NOAaccountMetaData = NOA_Accounts_Exempt__mdt.getAll();
    Set<String> NOAaccountNameSet= new Set<String>();
               
    //collect all the entity names from custom metadata and store in NOAaccountNameSet
    for(string entityName : NOAaccountMetaData.keyset()){
        NOAaccountNameSet.add(NOAaccountMetaData.get(entityName).Entity_Name__c);
    }     
    
	String allRecipients;
    if (formType != null ) {
          if(NOAaccountNameSet.contains(this.newOnlineAcc.Business_Name__c)){
              allRecipients = String.join(stringList, ',');
          }else{
              allRecipients = fetchESignEmail + ',' + String.join(stringList, ',');
          }
                                                       
    }   
 //   String allRecipients = fetchESignEmail + ',' + String.join(stringList, ',');
    System.debug(
      'Lead Id: ' +
      newOnlineAcc.Id +
      ':: All Recipients...' +
      allRecipients
    );
    agmt.echosign_dev1__Recipient_Addresses__c = allRecipients;
    agmt.echosign_dev1__Message__c = 'If you have questions about your application, please email us at customeraccounts@zoetis.com';
    try {
      agmt.echosign_dev1__Process_Template__c = [
        SELECT Id, Name
        FROM echosign_dev1__SIGN_Data_Mapping__c
        WHERE Name = 'NOALeadDM'
      ][0]
      .Id; //set data mapping
      /*Implement 'Send on Behalf Of' logic -Start*/
      List<User> sendAsUsers = [
        SELECT Id
        FROM User
        WHERE
          Name = 'New Online Account Site Guest User'
          AND echosign_dev1__EchoSign_Allow_Delegated_Sending__c = TRUE
      ];
      if (!sendAsUsers.isEmpty()) {
        agmt.echosign_dev1__Sender_User__c = sendAsUsers[0].Id;
      }
      /*Implement 'Send on Behalf Of' logic -END*/
      insert agmt;
      this.agreementId = agmt.Id; // Added for Guest User fix
      /*
            this.newOnlineAcc.Signature_Status__c = 'Ready to Send';
            this.newOnlineAcc.Id = this.LeadId;
            update this.newOnlineAcc;   */
      System.debug('Agreement Created: ' + agmt);
    } catch (Exception ex) {
      System.debug('Error inserting agreement record: ' + ex);
      hasErrors = true;
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Error creating signature document'
        )
      );
    }

    Attachment att = new Attachment();
    att.Name = newOnlineAcc.NOA_Application_Number__c + '.pdf';
    att.parentId = agmt.Id;
    att.description = 'New Online Account Application';
    PageReference pdfPage = Page.NOA_FinalFormPDF;
    Blob b;
    if (Test.isRunningTest()) {
      b = blob.valueof('TEST');
    } else {
      b = pdfPage.getContentAsPDF();
    }
    att.body = b;
    try {
      insert att;
      //sendForSignature();
    } catch (Exception ex) {
      System.debug('Error inserting agreement PDF record: ' + ex);
      hasErrors = true;
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Error sending document out for signature. ' + ex
        )
      );
    }
    this.newOnlineAcc.Signature_Status__c = 'Out for Signature';
    this.newOnlineAcc.Id = this.LeadId;
    try {
      update this.newOnlineAcc;
    } catch (Exception e) {
      hasErrors = true;
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.ERROR, 'We could not save your changes. Please try again or contact us at 1-855-721-0078.')
      );
    }
    triggerESign = true;
    return null;
  }

  public PageReference submittedFormRedirect() {
    //redirect to readonly page
    PageReference pageRef = new PageReference('/apex/NOA_SubmittedForm');
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', this.newOnlineAcc.id);
    return pageRef;
  }

  /*public void sendForSignature() {
    for (echosign_dev1__SIGN_Agreement__c agreement : [
      SELECT Id, Lead__c
      FROM echosign_dev1__SIGN_Agreement__c
      WHERE Lead__c = :LeadId
      ORDER BY LastModifiedDate DESC
      LIMIT 1
    ]) {
      List<Id> agreementIds = new List<Id>();
      agreementIds.add(agreement.Id);
      System.debug('...Agreement Id....' + agreementIds);
      User user = [
        SELECT Id
        FROM user
        WHERE id = :UserInfo.getUserId() AND ZTS_EU_Market__c = 'United States'
        LIMIT 1
      ];
      if (!Test.isRunningTest()) {
        echosign_dev1.EchoSignActionBatch agreementsBatch = new echosign_dev1.EchoSignActionBatch(
          agreementIds,
          'Send',
          null,
          null
        );
        String syncAgrProcessId = Database.executeBatch(agreementsBatch);
        System.debug(
          '...Agreement Sent Out for Signature...Process Id: ' +
          syncAgrProcessId
        );
      }
      break;
    }
    //updating lead record to set the Signature Status
    this.newOnlineAcc.Signature_Status__c = 'Out for Signature';
    this.newOnlineAcc.Id = this.LeadId;
    update this.newOnlineAcc;
  }*/

  public PageReference addNewShippingLocation() {
    System.debug('...Parent Lead No...' + applicationNo);
    this.newOnlineAcc = loadNOA(null, applicationNo, emailId);
    Lead newLead = new Lead();
    newLead.New_Shipping_Location__c = true;
    newLead.SAP_Bill_To_ID__c = this.newOnlineAcc.SAP_Bill_To_ID__c;
    newLead.Step_Number__c = 1;
    newLead.Company = 'New Online Account';
    newLead.RecordTypeId = vetRecTypeId;
    newLead.LeadSource = this.newOnlineAcc.LeadSource;

    //copy below fields from Parent corporate/speciality lead
    newLead.Salutation = this.newOnlineAcc.Salutation;
    newLead.FirstName = this.newOnlineAcc.FirstName;
    newLead.LastName = this.newOnlineAcc.LastName;
    newLead.Email = this.newOnlineAcc.Email;
    newLead.Phone = this.newOnlineAcc.Phone;
    newLead.Website = this.newOnlineAcc.Website;
    newLead.Applicant_Role__c = this.newOnlineAcc.Applicant_Role__c;
    newLead.Corporate_Account__c = this.newOnlineAcc.Corporate_Account__c;
    newLead.Customer_Type__c = this.newOnlineAcc.Customer_Type__c;
    newLead.Customer_Sub_Type__c = this.newOnlineAcc.Customer_Sub_Type__c;

    newLead.Business_Name__c = this.newOnlineAcc.Business_Name__c;
    //Copy Billing Address
    newLead.Contact_Preference__c = this.newOnlineAcc.Contact_Preference__c;
    newLead.Billing_Street_1__c = this.newOnlineAcc.Billing_Street_1__c;
    newLead.Billing_Street_2__c = this.newOnlineAcc.Billing_Street_2__c;
    newLead.Billing_County__c = this.newOnlineAcc.Billing_County__c;
    newLead.Billing_City__c = this.newOnlineAcc.Billing_City__c;
    newLead.Billing_State__c = this.newOnlineAcc.Billing_State__c;
    newLead.Billing_Zip_Code__c = this.newOnlineAcc.Billing_Zip_Code__c;
    newLead.Billing_Phone__c = this.newOnlineAcc.Billing_Phone__c;
    newLead.Billing_Fax__c = this.newOnlineAcc.Billing_Fax__c;
    newLead.Billing_Email__c = this.newOnlineAcc.Billing_Email__c;

    //ownership information page details
    newLead.Ownership_Type__c = this.newOnlineAcc.Ownership_Type__c;
    newLead.SP_Name__c = this.newOnlineAcc.SP_Name__c;
    newLead.SP_Telephone__c = this.newOnlineAcc.SP_Telephone__c;
    newLead.SP_Email__c = this.newOnlineAcc.SP_Email__c;
    newLead.SP_Fax__c = this.newOnlineAcc.SP_Fax__c;
    newLead.SP_Address__c = this.newOnlineAcc.SP_Address__c;
    newLead.SP_County__c = this.newOnlineAcc.SP_County__c;
    newLead.SP_City__c = this.newOnlineAcc.SP_City__c;
    newLead.SP_State__c = this.newOnlineAcc.SP_State__c;
    newLead.SP_Zip__c = this.newOnlineAcc.SP_Zip__c;

    newLead.Partership_Name__c = this.newOnlineAcc.Partership_Name__c;
    newLead.Partnership_Title_or_Officer_Info_1__c = this.newOnlineAcc.Partnership_Title_or_Officer_Info_1__c;
    newLead.Partership_Address__c = this.newOnlineAcc.Partership_Address__c;
    newLead.Partership_City__c = this.newOnlineAcc.Partership_City__c;
    newLead.Partership_County__c = this.newOnlineAcc.Partership_County__c;
    newLead.Partership_State__c = this.newOnlineAcc.Partership_State__c;
    newLead.Partership_Zip__c = this.newOnlineAcc.Partership_Zip__c;
    newLead.Partership_Name_2__c = this.newOnlineAcc.Partership_Name_2__c;
    newLead.Partnership_Title_or_Officer_Info_2__c = this.newOnlineAcc.Partnership_Title_or_Officer_Info_2__c;
    newLead.Partership_Address_2__c = this.newOnlineAcc.Partership_Address_2__c;
    newLead.Partership_City_2__c = this.newOnlineAcc.Partership_City_2__c;
    newLead.Partership_County_2__c = this.newOnlineAcc.Partership_County_2__c;
    newLead.Partership_State_2__c = this.newOnlineAcc.Partership_State_2__c;
    newLead.Partership_Zip_2__c = this.newOnlineAcc.Partership_Zip_2__c;
    newLead.Partership_Telephone__c = this.newOnlineAcc.Partership_Telephone__c;
    newLead.Partership_Fax__c = this.newOnlineAcc.Partership_Fax__c;
    newLead.Partership_Email__c = this.newOnlineAcc.Partership_Email__c;

    newLead.CLG_Name__c = this.newOnlineAcc.CLG_Name__c;
    newLead.CLG_Company__c = this.newOnlineAcc.CLG_Company__c;
    newLead.CLG_Address__c = this.newOnlineAcc.CLG_Address__c;
    newLead.CLG_City__c = this.newOnlineAcc.CLG_City__c;
    newLead.CLG_County__c = this.newOnlineAcc.CLG_County__c;
    newLead.CLG_State__c = this.newOnlineAcc.CLG_State__c;
    newLead.CLG_Zip__c = this.newOnlineAcc.CLG_Zip__c;
    newLead.CLG_Telephone__c = this.newOnlineAcc.CLG_Telephone__c;
    newLead.CLG_Fax__c = this.newOnlineAcc.CLG_Fax__c;
    newLead.CLG_Email__c = this.newOnlineAcc.CLG_Email__c;
    newLead.Buyer_Name__c = this.newOnlineAcc.Buyer_Name__c;
    newLead.Buyer_Phone__c = this.newOnlineAcc.Buyer_Phone__c;
    newLead.Years_in_Business__c = this.newOnlineAcc.Years_in_Business__c;
    newLead.Controller_Name__c = this.newOnlineAcc.Controller_Name__c;
    newLead.Controller_Phone__c = this.newOnlineAcc.Controller_Phone__c;
    newLead.Accounts_Payable_Contact_Name__c = this.newOnlineAcc.Accounts_Payable_Contact_Name__c;
    newLead.Accounts_Payable_Contacts_Phone__c = this.newOnlineAcc.Accounts_Payable_Contacts_Phone__c;
    //newLead.Has_your_company_filed_bankruptcy__c  =  this.newOnlineAcc.Has_your_company_filed_bankruptcy__c;
    //newLead.Type_of_bankruptcy__c  =  this.newOnlineAcc.Type_of_bankruptcy__c;
    //newLead.Bankrupt_File_Date__c  =  this.newOnlineAcc.Bankrupt_File_Date__c;

    try {
      System.debug(
        '...Inserting New Shipping Location for...' +
        this.newOnlineAcc.SAP_Bill_To_ID__c
      );
      insert newLead;
    } catch (DMLException ex) {
      hasErrors = true;
      ApexPages.addmessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Error creating new shipping location. ' + ex
        )
      );
    }
    System.debug('...New Child Lead...' + newLead.Id);
    PageReference pageRef = new PageReference(
      '/apex/NOA_BasicAndFacilityInformation'
    );
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', newLead.id);
    return pageRef;
  }

  //Adobe Guest User Permission Fix
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
} //end of class