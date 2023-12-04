@isTest
public class TargetedAccountBatchTest
{
    
    static testMethod void testMethod1(){
        Primary_Contact_Inactive_Profile_List__c contSetting = new Primary_Contact_Inactive_Profile_List__c();
      Primary_Contact_Inactive_Profile_List__c contSetting1 = new Primary_Contact_Inactive_Profile_List__c();
      Primary_Contact_Inactive_Profile_List__c contSetting2 = new Primary_Contact_Inactive_Profile_List__c();

      contSetting.Name = 'Profile Names';
      contSetting1.Name = 'Profile Names 1';
      contSetting2.Name = 'Profile Names 2';
      contSetting.Profile__c = '\'ZTS AUT Business Administrator\';\'ZTS BAL Business Administrator\';\'ZTS BGR Business Administrator\';\'ZTS BNLX Business Administrator\';\'ZTS EGY Business Administrator\';\'ZTS ESP Business Administrator\';\'ZTS FIN Business Administrator\';\'System Administrator\'';
      contSetting1.Profile__c = '\'ZTS FRA Business Administrator\';\'ZTS UK Business Administrator\';\'ZTS ITA Business Administrator\',\'Integration Profile\',\'ZTS KOR Business Administrator\',\'ZTS THA Business Administrator\',\'ZTS PHL Business Administrator\',\'ZTS VNM Business Administrator\'';
      contSetting2.Profile__c = '\'ZTS TWN Business Administrator\',\'ZTS IDN Business Administrator\',\'ZTS IND Business Administrator\', \'ZTS CHN Business Administrator\',\'Intll Business Administrator\', \'ZTS CLAR SoLA Business Administrator\'';

      insert new List<Primary_Contact_Inactive_Profile_List__c>{contSetting, contSetting1, contSetting2};
          
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
    List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
        System.runAs(usr)
        {
            insert lstacnt;
        }
        
        State_Country__c sc = new State_Country__c();
        sc.Name = 'Sachsen';
        sc.ZTS_EU_Country__c = 'Germany';
        insert sc;
        
    List<Contact> lstcont = ZTS_DataUtilityTest.createContactRecord(1);
    List<Contact> lstcontins = new List<Contact>();
    for(Contact con : lstcont){
        con.AccountId = lstacnt[0].id;
        con.ZTS_EU_Country__c = 'Germany';
        con.ZTS_EU_Market__c = 'Germany';
        con.ZTS_US_Phone_Opt_out__c = True;
        con.HasOptedOutOfEmail = True;
        con.ZTS_EU_Contact_Status__c = 'Active';
        con.ZTS_EU_State_County__c = sc.Id;
    lstcontins.add(con);
    }
        System.runAs(usr)
        {
            insert lstcontins;
        }
        
    /*List<ZTS_EU_Affiliations__c> lstaccconafft = ZTS_DataUtilityTest.createAccConAffiliationRecord(1);
    List<ZTS_EU_Affiliations__c> lstaccconafftins = new List<ZTS_EU_Affiliations__c>();
    for(ZTS_EU_Affiliations__c accconaff : lstaccconafft){
    accconaff.ZTS_EU_Account__c = lstacnt[0].id;
    accconaff.ZTS_EU_Contact__c = lstcontins[0].id;  
    lstaccconafftins.add(accconaff);
    }
    insert lstaccconafftins;
    */
    List<Campaign> lstcamp = ZTS_DataUtilityTest.createCampaignRecord(1);
    List<Campaign> lstcampins = new List<Campaign>();
    List<CampaignMember> lstcampinss = new List<CampaignMember>();
    for(Campaign camp : lstcamp)
    {
        camp.ZTS_EU_Market__c = 'Germany';
        camp.Type = 'Email';
        camp.Campaign_Name_English__c = 'is Test';
        lstcampins.add(camp);
    }
    insert lstcampins;
    
    CampaignMember cm= New CampaignMember(CampaignId=lstcampins[0].Id, ContactId= lstcont[0].Id, Status='Opt-In'); 
    lstcampinss.add(cm);
    insert lstcampinss;


        List<ZTS_EU_Campaign_Account__c> lstcampacnt = ZTS_DataUtilityTest.createCampaignAccountRecord(1);
    List<ZTS_EU_Campaign_Account__c> lstcampAccntins = new List<ZTS_EU_Campaign_Account__c>();
    for(ZTS_EU_Campaign_Account__c camAccnt : lstcampacnt){
        camAccnt.ZTS_EU_Account__c = lstacnt[0].id;
        camAccnt.ZTS_EU_Campaign__c = lstcampins[0].id;
        lstcampAccntins.add( camAccnt);       
        }
        
     insert lstcampAccntins;
     Test.startTest();
    TargetedAccountBatchSchedule accntAlign = new TargetedAccountBatchSchedule();
    String sch = '0 0 23 * * ?'; 
    system.schedule('Test Alignment', sch, accntAlign); 
    Test.stopTest();
        /*Test.startTest();
            TargetedAccountBatch obj = new TargetedAccountBatch();
            DataBase.executeBatch(obj);
        Test.stopTest();*/
        
    }
     
}