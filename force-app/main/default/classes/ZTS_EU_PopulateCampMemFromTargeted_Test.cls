/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Saipraneeth             12/27/2018           Created - SC-004024.
*****************************************************************************************************************************************/
@isTest
public class ZTS_EU_PopulateCampMemFromTargeted_Test {
    static testMethod void ZTS_EU_CampaignManagerTest() {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            
            List<Id> campaignIds = new List<Id>();
            List<Id> accIds = new List<Id>();
            List<contact> cons = new List<contact>();
                        
            Campaign c = new Campaign();
            c.IsActive = true;
            c.startDate = system.today();
            c.EndDate = system.today()  +30;
            c.ZTS_EU_External_ID__c = '12345';
            c.Name = 'testCampaign';
            c.ZTS_EU_Field_Targeting__c = 'Open'; 
            c.Campaign_Name_English__c ='Test Campaign';
            c.Type = 'Rep Activities';
            c.ZTS_EU_Market__c = 'United Kingdom';
            insert c; 
            
            Campaign c1 = new Campaign();
            c1.IsActive = true;
            c1.startDate = system.today();
            c1.EndDate = system.today() +30;
            c1.ZTS_EU_External_ID__c = '123456';
            c1.Name = 'testCampaign1';
            c1.ZTS_EU_Field_Targeting__c = 'Open'; 
            c1.Campaign_Name_English__c ='Test Campaign1';
            c1.Type = 'Telemarketing';
            insert c1;    
            
            Campaign c2 = new Campaign();
            c2.IsActive = true;
            c2.startDate = system.today();
            c2.EndDate = system.today()+40;
            c2.ZTS_EU_External_ID__c = '1234567';
            c2.Name = 'testCampaign2';
            c2.ZTS_EU_Field_Targeting__c = 'Open'; 
            c2.Campaign_Name_English__c ='Test Campaign2';
            c2.Type = 'Email';
            insert c2;     
            
            campaignIds.add(c.id);
            campaignIds.add(c1.id);
            campaignIds.add(c2.id);
            
            Account a = new Account();
            a.name = 'testAcc';
            a.ZTS_EU_Market__c='United Kingdom';
            a.Practice_Management_Software__c = 'Other';
            a.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            a.ZTS_EU_Zip_Postal_Code__c = '12345';
            insert a;
            accIds.add(a.id);
        
            Contact con = new Contact();
            con.firstname = 'test';
            con.lastname = 'Con';
            con.accountID = a.Id;
            con.HasOptedOutOfEmail = False;
            con.ZTS_EU_Market__c = 'United Kingdom';
            cons.add(con);
            
            Contact con1 = new Contact();
            con1.firstname = 'test1';
            con1.lastname = 'Con1';
            con1.accountID = a.Id;
            con1.ZTS_EU_Opt_Out_Phone__c = False;
            con1.ZTS_EU_Market__c = 'United Kingdom';
            cons.add(con1);
            
            Contact con2 = new Contact();
            con2.firstname = 'test2';
            con2.lastname = 'Con2';
            con2.accountID = a.Id;
            con2.ZTS_EU_Market__c = 'United Kingdom';
            cons.add(con2);
           
            insert cons;
            
            test.starttest();
            Set<Id> conSet = new Set<Id>();
            conSet.add(con.Id);
            conSet.add(con1.id);
            conSet.add(con2.id);
            
            ZTS_EU_Campaign_Account__c ca = new ZTS_EU_Campaign_Account__c();
            ca.ZTS_EU_Account__c = a.id;
            ca.ZTS_EU_Campaign__c = c.id;
            ca.ZTS_EU_Member_Status__c = 'Added';
            insert ca;
            
            ZTS_EU_Campaign_Account__c ca1 = new ZTS_EU_Campaign_Account__c();
            ca1.ZTS_EU_Account__c = a.id;
            ca1.ZTS_EU_Campaign__c = c1.id;
            ca1.ZTS_EU_Member_Status__c = 'Added';
            insert ca1;
            
            ZTS_EU_Campaign_Account__c ca2 = new ZTS_EU_Campaign_Account__c();
            ca2.ZTS_EU_Account__c = a.id;
            ca2.ZTS_EU_Campaign__c = c2.id;
            ca2.ZTS_EU_Member_Status__c = 'Added';
            insert ca2;
            
            List<ZTS_EU_Campaign_Account__c> caList = new List<ZTS_EU_Campaign_Account__c>();
            caList.add(ca);
            caList.add(ca1);
            caList.add(ca2);
            
            Map<Id,ZTS_EU_Campaign_Account__c> TarAccOldMap = new Map<Id,ZTS_EU_Campaign_Account__c>();
            TarAccOldMap.put(ca.id,ca);
            TarAccOldMap.put(ca1.id,ca1);
            TarAccOldMap.put(ca2.id,ca2);
            
            Map<Id,Set<Id>> accContactIdMap = new Map<Id,Set<Id>>();
            accContactIdMap.put(a.Id, conSet);
            
            CampaignMember CamMem = new CampaignMember();
            CamMem.CampaignId = c.id;
            CamMem.ContactId = con.id;
            CamMem.Status = 'status';
            insert CamMem;
            
            CampaignMember CamMem1 = new CampaignMember();
            CamMem1.CampaignId = c1.id;
            CamMem1.ContactId = con1.id;
            CamMem1.Status = 'status';
            insert CamMem1;
            
            CampaignMember CamMem2 = new CampaignMember();
            CamMem2.CampaignId = c2.id;
            CamMem2.ContactId = con2.id;
            CamMem2.Status = 'status';
            insert CamMem2;
            
            List<CampaignMember> CamMemList = new List<CampaignMember>();
            CamMemList.add(CamMem);
            CamMemList.add(CamMem1);
            CamMemList.add(CamMem2);
            
            List<ZTS_EU_Campaign_Account__c> TarAccList = new List<ZTS_EU_Campaign_Account__c>();
            for(ZTS_EU_Campaign_Account__c TarAcc : caList){
                TarAcc.ZTS_EU_Member_Status__c = 'Removed';
                TarAccList.add(TarAcc);
            }
            
            update TarAccList;
            
            List<Id> ListofCamId = new List<Id>();
            for(ZTS_EU_Campaign_Account__c CamAcc : TarAccList){
                if(CamAcc.ZTS_EU_Member_Status__c == 'Removed'){
                    ListofCamId.add(CamAcc.ZTS_EU_Campaign__c);
                }
            }
            
            List<CampaignMember> ListofCampMemb = new List<CampaignMember>();
            ListofCampMemb = [select id from CampaignMember where  CampaignId IN: ListofCamId AND ZTS_EU_Market__c != 'United States'];
            
            //Delete ListofCampMemb;
            
            ZTS_EU_CampaignManager classObj1 = new ZTS_EU_CampaignManager();
            ZTS_EU_CampaignManager.getCampaignsWithMembers(campaignIds,accIds);
            
            ZTS_EU_PopulateCampMemFromTargetedAccnt classObj = new ZTS_EU_PopulateCampMemFromTargetedAccnt();
            ZTS_EU_PopulateCampMemFromTargetedAccnt.insertCampMem(caList);
            //ZTS_EU_PopulateCampMemFromTargetedAccnt.delCampMem(TarAccList,TarAccOldMap);
            
            test.stoptest();
            }
        }
    
   
    @isTest
    public static void testMethod2(){
         ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser1';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            List<Id> campaignIds = new List<Id>();
            List<Id> accIds = new List<Id>();
            List<contact> cons = new List<contact>();
            
             Campaign c = new Campaign();
            c.IsActive = true;
            c.startDate = system.today();
            c.EndDate = system.today()  +30;
            c.ZTS_EU_External_ID__c = '12345';
            c.Name = 'testCampaign';
            c.Type = 'Email2';
            c.ZTS_EU_Field_Targeting__c = 'Open'; 
            c.Campaign_Name_English__c ='Test Campaign';
            c.Type = ZTS_EU_GlobalConstants.TELEMARKET_TYPE_EMAIL;
            c.ZTS_EU_Market__c = 'United Kingdom';
            insert c;  
            
            campaignIds.add(c.id);
           
            Account a = new Account();
            a.name = 'testAcc2';
            a.ZTS_EU_Market__c='United Kingdom';
            a.Practice_Management_Software__c = 'Other';
            a.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            a.ZTS_EU_Zip_Postal_Code__c = '12345';
            insert a;
            accIds.add(a.id);
        
            Contact con = new Contact();
            con.firstname = 'test';
            con.lastname = 'Con';
            con.accountID = a.Id;
            con.HasOptedOutOfEmail = False;
            con.ZTS_EU_Market__c = 'United Kingdom';
            cons.add(con);
            insert cons;
            
           test.starttest();
            Set<Id> conSet = new Set<Id>();
            conSet.add(con.Id);
            
             ZTS_EU_Campaign_Account__c ca = new ZTS_EU_Campaign_Account__c();
            ca.ZTS_EU_Account__c = a.id;
            ca.ZTS_EU_Campaign__c = c.id;
            ca.ZTS_EU_Member_Status__c = 'Added';
            insert ca;
            
            List<ZTS_EU_Campaign_Account__c> caList = new List<ZTS_EU_Campaign_Account__c>();
            caList.add(ca);
            
            CampaignMember CamMem = new CampaignMember();
            CamMem.CampaignId = c.id;
            CamMem.ContactId = con.id;
            CamMem.Status = 'status';
            insert CamMem; 
            
              List<ZTS_EU_Campaign_Account__c> TarAccList = new List<ZTS_EU_Campaign_Account__c>();
            for(ZTS_EU_Campaign_Account__c TarAcc : caList){
                TarAcc.ZTS_EU_Member_Status__c = 'Removed';
                TarAccList.add(TarAcc);
            }
            
            update TarAccList; 
            
             Map<Id,ZTS_EU_Campaign_Account__c> TarAccOldMap = new Map<Id,ZTS_EU_Campaign_Account__c>();
            TarAccOldMap.put(ca.id,ca);
           
              ZTS_EU_PopulateCampMemFromTargetedAccnt.delCampMem(TarAccList,TarAccOldMap);
        }
        
    }
    
      
}