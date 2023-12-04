/******************************************************************************************************************************************** File Name     :  ZTS_US_Mass_Add_Account_Ext_Test* Description   :           * @author       :  Deloitte consulting* Modification Log===================================================================================================* Ver.    Date          Author              Modification---------------------------------------------------------------------------------------------------* 1.0     7/14         Sonali             Created the Class.*****************************************************************************************************************************************/
@isTest
public class ZTS_US_Mass_Add_Account_Ext_Test {
    static List < ZTS_Events__c > listEvents;
    public static void createTestData() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        listEvents = ZTS_EU_DataUtilityTest.createEvents(1);
        System.runAs(usr)
        {
            insert listEvents;
        }
        
    }
    private static testMethod void constructorTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            createTestData();
            system.debug('-----------------event id---' + listEvents[0].Id);
            ApexPAges.StandardController sc = new ApexPages.StandardController(listEvents[0]);
            PageReference massAddAccPage = Page.ZTS_US_Mass_Add_Account;
            Test.setCurrentPage(massAddAccPage);
            ApexPages.currentPage().getParameters().put('eventId', listEvents[0].Id);
            ApexPages.currentPage().getParameters().put('id', listEvents[0].Id);
            ApexPages.currentPage().getParameters().put('isError', 'false');
            ZTS_US_Mass_Add_Account_Ext massAccount = new ZTS_US_Mass_Add_Account_Ext(sc);
            massAccount.process();
            account a1 = new account(name='test123', ZTS_EU_Market__c='United Kingdom',
                                     Practice_Management_Software__c = 'Other',
                                     Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                     ZTS_EU_Zip_Postal_Code__c = '00000');
            insert a1;
            //ApexPages.currentPage().getParameters().put('myaccountname', 'test123');
            
            
            
            Test.setCurrentPageReference(massAddAccPage); //Kaushik addded;
            //list<string> fixedsearch = new list<string>();
            //fixedsearch[0]=a1.name;
            massAccount.search();
            massAccount.myaccountname='test123';
            massAccount.search();
            ZTS_US_Mass_Add_Account_Ext.wrapperlist mydemo = new ZTS_US_Mass_Add_Account_Ext.wrapperlist(a1);
            //ZTS_US_Mass_Add_Account_Ext.wrapperlist mydemo1 = massaccount.mywrapperlist;
            //for (ZTS_US_Mass_Add_Account_Ext.wrapperlist d1 :mydemo){
            
            For (ZTS_US_Mass_Add_Account_Ext.wrapperlist d1 :massaccount.mywrapperlist){
                d1.selected = true;
            }
            //massAccount.search();
            massAccount.process();
            //  massAccount.clear();
            massAccount.myaccountname='test123';
            massAccount.search();
            For (ZTS_US_Mass_Add_Account_Ext.wrapperlist d1 :massaccount.mywrapperlist){
                d1.selected = true;
            }
            massAccount.process();
            massAccount.clear();
            test.stopTest();
        }
    }
    /*
public  static testMethod void abc(){
ZTS_US_Mass_Add_Account_Ext aw1 = new ZTS_US_Mass_Add_Account_Ext();
for (ZTS_US_Mass_Add_Account_Ext.wrapperlist aw2 :aw1.mywrapperlist){
aw2.selected = true;   
}
*/
    
    
}