@isTest
public class VmipsCaseTriggerTest 
{
    static testMethod void beforeUpdateTest(){
      ZTS_DataUtilityTest.activateTriggerSettings();
        Test.starttest();
        List<Account> accts = new List<Account>();
        Integer count=1;
        Integer uniquenarid = 12;
        accts = ZTS_DataUtilityTest.createAccountRecord(count);
        insert accts;
        Profile profiles=[Select Id From Profile Where Name='US Small Animal Rep'];
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='testem@deneme.com';
        newuser.username='testem@deneme1.com';
        newuser.firstname='test2';
        newuser.lastname='testem';
        newuser.alias='testem';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';  
        newuser.EmailEncodingKey='ISO-8859-1';
        newuser.PIT_Coaching_Group__c='TBM';
        newuser.ZTS_EU_Market__c='United States';
        insert newuser;
      
        //Comment some of the US code to accommodate for changes on the merged org 10/12/2020
        //ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='Terr',ZTS_US_Field_Force_Name__c='Small Animal',ZTS_US_Description__c='Terr Desc-',ZTS_US_Type__c='Territory',ZTS_US_Species__c='Small Animal');
       ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='Terr', ZTS_EU_Market__c = 'United States',ZTS_Field_Force_Name__c = 'Small Animal', ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Territory',ZTS_Species__c ='Small Animal' );
       insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=newuser.id,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        
        insert usrTerr;
        ZTS_AccountTerritory__c accterr=new ZTS_AccountTerritory__c(ZTS_EU_Account__c=accts[0].id,ZTS_EU_Territory__c=cterr.id,ZTS_SIB_Flag__c =true,ZTS_Zoetis_SFDC_ID__c=accts[0].ZTS_EU_Zoetis_SFDC_ID__c,ZTS_ChangeFlag__c =ZTS_GlobalConstants.CHANGE_FLAG_STATUS_INSERT,ZTS_NARC_ID__c='test', ZTS_EU_Market__c = 'United States');
        
        Insert accterr;
        
        //ZTS_EU_Account_Position__c  accteam=new ZTS_EU_Account_Position__c (ZTS_EU_Account__c =accts[0].id,ZTS_AccountTerritory__c =accterr.id,ZTS_NotificationUser__c =newuser.id,ZTS_US_UserTerritory__c=usrTerr.id);
        ZTS_EU_Account_Position__c  accteam=new ZTS_EU_Account_Position__c (ZTS_EU_Account__c =accts[0].id,ZTS_AccountTerritory__c =accterr.id,ZTS_NotificationUser__c =newuser.id);

        insert accteam;
       
        List<ZTS_US_VMIPS_Case__c> caselist = new List<ZTS_US_VMIPS_Case__c>();
        ZTS_US_VMIPS_Case__c vcase = new ZTS_US_VMIPS_Case__c();
                    //vcase.ZTS_US_Vmips_Account__c  = accts[0].id;
                    //vcase.ZTS_US_Case_Role__c = 'TestRole';
                    vcase.Name= '2020US-01479';
                    vcase.ZTS_US_Case_Type__c = 'Animal Complaint';
                    vcase.ZTS_US_Sub_Type__c = 'On-Label';
                    vcase.ZTS_US_Comments__c = 'Test Comments';
                    vcase.ZTS_US_Priority__c = true;
                    vcase.ZTS_US_Species_Group__c='Small Animal';
                    vcase.ZTS_US_Description__c = 'Test Description';
                    //vcase.ZTS_US_Contact__c = con.id;
                    caselist.add(vcase);
           insert vcase;
           System.debug('***vcase id***'+vcase.id);

           //vcase.ZTS_US_Vmips_Account__c = accts[0].id;
           //update vcase;
        ZTS_US_VMIPS_Case_Account__c vcaseacct = new ZTS_US_VMIPS_Case_Account__c();
                    vcaseacct.ZTS_US_Account__c = accts[0].id;
                    vcaseacct.ZTS_US_Case_Role__c = 'TestRole';
                    vcaseacct.ZTS_US_Clinic__c = 'Test Clinic';
                    vcaseacct.ZTS_US_Contact__c = 'Test Contact';
                    vcaseacct.ZTS_US_VMIPS_Case_Number__c=vcase.Id;
        insert vcaseacct;
        Test.stopTest();
 }
}