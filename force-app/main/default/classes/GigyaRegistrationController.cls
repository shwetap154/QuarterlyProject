/**
 * @description       : Controller for Gigya Visualforce pages
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : Gigya
 * @last modified on  : 10-05-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-13-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 * 2.0	 11-14-2023	  Kalyan Nayak @ Zoetis Inc		 Updated market logic as part for TPDEV-2467
 **/
public with sharing class GigyaRegistrationController {
  private ApexPages.StandardController sc;

  public String userMarket { get; private set; }//Updated as part of TPDEV-2467
  public Set<String> allMarkets { get; private set; }//Added as part of TPDEV-2467
  public String contactMarket { get; private set; }
  public String market { get; set; }
  public string apiKey { get; private set; }
  public boolean hasAPIKey { get; private set; }
  public boolean isMarketAdmin { get; private set; }
  public boolean isRegisterable { get; private set; }
  public boolean isMarketMatch { get; private set; }
  public boolean isPermissionAssigned { get; private set; }
  private String userProfileName { get; private set; }
  private final string MARKET_ADMIN = 'Distributor Market Admin';
  private final String SYSTEM_ADMIN = 'System Administrator';
  private final string DistributorPortal_PermissionSet='Distributor_Portal_Admin';  
  private final Id contactId;
  private final Contact contactRecord;
  private final User ztsUserRecord;
  private final List<User> existingUsers;
  public boolean hasExistingUser { get; private set; }
  public string existingUserId { get; private set; }
  public User existingUser { get; private set; }
  public Profile distributorProfile { get; private set; }
  public boolean isPartnerEnabled { get; private set; }

  public GigyaRegistrationController(ApexPages.StandardController stdCtrl) {
    this.sc = stdCtrl;
    this.contactId = (Id) stdCtrl.getId();
    this.existingUser = null;
    this.distributorProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Distributor Community User'
      LIMIT 1
    ];
    // Get Current Contact Info
    this.contactRecord = [
      SELECT Id, ZTS_EU_Market__c, Account.IsPartner 
      FROM Contact
      WHERE Id = :this.contactId
      LIMIT 1
    ];
    // Get Logged in User Info
    // Added Additional_Markets__c as part of TPDEV-2467
    this.ztsUserRecord = [
      SELECT ZTS_EU_Market__c, Profile.Name, Additional_Markets__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
     
    // Query for existing Community User
    this.existingUsers = [SELECT Id, FederationIdentifier, Email 
                          FROM User WHERE 
                          ContactId = :this.contactRecord.Id 
                          AND FederationIdentifier != null];
     
      //Query Permission Sets of logged in user
     List<PermissionSetAssignment> permissionsetAssignmentList = [SELECT Id,Assignee.Name,PermissionSet.Name, PermissionSet.Label 
                                                     			  FROM PermissionSetAssignment 
                                                                  WHERE AssigneeId= :UserInfo.getUserId() 
                                                                  and PermissionSet.Name=:DistributorPortal_PermissionSet];
      if(permissionsetAssignmentList!=null && permissionsetAssignmentList.size()>0)
      {
          this.isPermissionAssigned=true;
      }
      else{this.isPermissionAssigned=false; }
     
      //Added as part of TPDEV-2467
      this.allMarkets = new Set<String>();
      if(this.ztsUserRecord != null && this.ztsUserRecord.Additional_Markets__c != null){
          this.allMarkets.addAll(this.ztsUserRecord.Additional_Markets__c.toLowerCase().split(';'));  
      }

      if(this.ztsUserRecord.ZTS_EU_Market__c != null){
          this.allMarkets.add(this.ztsUserRecord.ZTS_EU_Market__c.toLowerCase());
      }
    // Set some Variables for use in Code
    //this.userMarket = new List<String>();//Added as part of TPDEV-2467
    this.userMarket = string.join((Iterable<String>)this.allMarkets,',');//Added as part of TPDEV-2467
    this.userProfileName = this.ztsUserRecord.Profile.Name;
    this.contactMarket = this.contactRecord.ZTS_EU_Market__c;
    this.isPartnerEnabled = this.contactRecord.Account.IsPartner;
      
    // If Existing User, Cannot Register Again
    if (this.existingUsers.isEmpty()) {
      hasExistingUser = false;
        } else {
      hasExistingUser = true;
      existingUser = this.existingUsers[0];
      existingUserId = this.existingUsers[0].FederationIdentifier;
    }

    // Compare Logged in User Market with Contact Market
    // Users cannot create Distributor Users outside of their Market
    //Updated isMarketMatch to true condition as part of TPDEV-2467
    if(this.allMarkets.contains(this.contactMarket.toLowerCase())){
      this.isMarketMatch = true;
    } else {
      this.isMarketMatch = false;
    }
    this.apiKey = GigyaService.getAPIKey(this.contactMarket);
    if (String.isBlank(this.apiKey)) {
      this.hasAPIKey = false;
    } else {
      this.hasAPIKey = true;
    }
    if (MARKET_ADMIN.equalsIgnoreCase(this.userProfileName) || SYSTEM_ADMIN.equalsIgnoreCase(this.userProfileName)) {
      this.isMarketAdmin = true;
    } else if(isPermissionAssigned==true){
        this.isMarketAdmin = true;
    }
      else {
      this.isMarketAdmin = false;
    }
    if (
      hasAPIKey &&
      isMarketAdmin &&
      isMarketMatch &&
      !hasExistingUser &&
      isPartnerEnabled 
 ) 
    {
      this.isRegisterable = true;
    } else {
      this.isRegisterable = false;
    }
  }
  public GigyaRegistrationController() {
    this.market = ApexPages.currentPage().getParameters().get('market');
    if (this.market == null) {
      this.market = '';
    }
    this.apiKey = GigyaService.getAPIKey(this.market);
    if (String.isBlank(this.apiKey)) {
      this.hasAPIKey = false;
    } else {
      this.hasAPIKey = true;
    }
  }
}