@isTest
public class ZTS_EU_targetAccountIDControllerTest
{
    static testMethod void TestZTS_EU_targetAccountIDController()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Campaign camp = new Campaign();
            camp.Name = 'Test Campaign';
            camp.Campaign_Name_English__c = 'Test';
            camp.ZTS_EU_Field_Targeting__c = 'Open';
            insert camp;
            System.debug(camp.id);
            
            /*** added by Oeeshi ***/
            Campaign camp_new = new Campaign();
            camp_new.Name = 'Test Campaign1';
            camp_new.Campaign_Name_English__c = 'Test';
            camp.ZTS_EU_Field_Targeting__c = 'Open';
            insert camp_new;
            
            
            Account acc = new Account(Name = 'Test Account', ZTS_EU_Market__c = 'France', Type = 'Farm', ZTS_EU_District__c = 'XXXX', ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc;
            System.debug(acc.id);
            Account acc2 = new Account(Name = 'Test Account', ZTS_EU_Market__c = 'France', Type = 'Farm', ZTS_EU_District__c = 'XXXX', ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc2;
            
            Account acc1 = [Select id, ZTS_EU_Zoetis_SFDC_ID__c from Account where id = : acc.id AND ZTS_EU_Market__c != 'United States' ];
            Account acc3 = [Select id, ZTS_EU_Zoetis_SFDC_ID__c from Account where id = : acc2.id AND ZTS_EU_Market__c != 'United States' ];
            System.debug(acc1.ZTS_EU_Zoetis_SFDC_ID__c);
            ZTS_EU_Campaign_Account__c campAccnt = new ZTS_EU_Campaign_Account__c(ZTS_EU_Account__c = acc1.id, ZTS_EU_Campaign__c = camp.id,ZTS_EU_ZOETIS_SFDC_IDs__c= acc1.ZTS_EU_Zoetis_SFDC_ID__c, ZTS_EU_Member_Status__c = 'Removed');
            insert campAccnt;
            
            /*** added by Oeeshi***/
            Account acc_new = new Account(Name = 'Test Account1', ZTS_EU_Market__c = 'France', Type = 'Farm', ZTS_EU_District__c = 'abc', ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc_new;
            Account acc_camp2 = new Account(Name = 'Test Account2', ZTS_EU_Market__c = 'France', Type = 'Farm', ZTS_EU_District__c = 'xyz', ZTS_EU_Zip_Postal_Code__c = '12345');
            insert acc_camp2;
            Account acc4 = [Select id,ZTS_EU_Zoetis_SFDC_ID__c from Account where id=:acc_new.Id AND ZTS_EU_Market__c != 'United States' ];
            Account acc5 = [Select id,ZTS_EU_Zoetis_SFDC_ID__c from Account where id=:acc_camp2.Id AND ZTS_EU_Market__c != 'United States'];
            List<ZTS_EU_Campaign_Account__c> listcamp=new List<ZTS_EU_Campaign_Account__c>();
            test.startTest();
            camp_new.ZTS_EU_Field_Targeting__c = 'Open';
            update camp_new;
            ZTS_EU_Campaign_Account__c camp1=new ZTS_EU_Campaign_Account__c(ZTS_EU_Account__c=acc4.Id,ZTS_EU_Campaign__c=camp_new.id,ZTS_EU_ZOETIS_SFDC_IDs__c=acc4.ZTS_EU_Zoetis_SFDC_ID__c,ZTS_EU_Member_Status__c='Added');
            insert camp1;
            listcamp.add(camp1);
            camp_new.ZTS_EU_Field_Targeting__c = 'Open';
            update camp_new;
            ZTS_EU_Campaign_Account__c camp2=new ZTS_EU_Campaign_Account__c(ZTS_EU_Account__c=acc5.Id,ZTS_EU_Campaign__c=camp_new.id,ZTS_EU_ZOETIS_SFDC_IDs__c=acc5.ZTS_EU_Zoetis_SFDC_ID__c,ZTS_EU_Member_Status__c='Added');
            insert camp2;
            camp1.ZTS_EU_Member_Status__c='Removed';
            update camp2;
            listcamp.add(camp2);
            update listcamp;        
            
            PageReference pageRef = Page.ZTS_EU_targetAccountID;
            Test.setCurrentPageReference(pageRef);
            ApexPages.CurrentPage().getparameters().put('campId', camp.id);
            
            /*** added by Oeeshi***/
            PageReference pageRef1 = Page.ZTS_EU_targetAccountID;
            Test.setCurrentPageReference(pageRef1);
            ApexPages.CurrentPage().getparameters().put('setcampId', camp_new.id);
            
            
            ApexPages.StandardController controller = new ApexPages.StandardController(camp);
            ZTS_EU_targetAccountIDController obj = new ZTS_EU_targetAccountIDController(controller);
            obj.campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c = acc3.ZTS_EU_Zoetis_SFDC_ID__c + ';' + acc1.ZTS_EU_Zoetis_SFDC_ID__c ;
            obj.addTargetAccountID();
            
            
            
            ZTS_EU_targetAccountIDController obj1 = new ZTS_EU_targetAccountIDController(controller);
            obj1.campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c = acc3.ZTS_EU_Zoetis_SFDC_ID__c + '\n' + acc1.ZTS_EU_Zoetis_SFDC_ID__c ;
            obj1.addTargetAccountID();
            
            ZTS_EU_targetAccountIDController obj2 = new ZTS_EU_targetAccountIDController(controller);
            obj2.campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c = acc1.ZTS_EU_Zoetis_SFDC_ID__c ;
            obj2.addTargetAccountID();
            
            
            test.stopTest();
        }
    }
}