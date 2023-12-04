@isTest (Seealldata = false)
public class ZTS_EU_ServiceRequestOverride_Test{

    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        System.runAs(usr)
        {
            PageReference pageRef = Page.ZTS_EU_ServiceReqNewOverride;
            Test.setCurrentPageReference(pageRef);
            List<Contact> conrec =  ZTS_EU_DataUtilityTest.createContactRecord(1);
            conrec[0].ZTS_EU_Market__c = 'United Kingdom';
            insert conrec;
            ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
            prodSpecies.Name='Test Product';
            prodSpecies.ZTS_EU_Market__c='United Kingdom';
            prodSpecies.ZTS_EU_Type__c='Brand';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
            prodSpecies.ZTS_EU_Is_Active__c=true;
            insert prodSpecies;

            ZTS_EU_Species_Product__c prodSpecies1= new ZTS_EU_Species_Product__c();
            prodSpecies.Name='Ruminents';
            prodSpecies.ZTS_EU_Market__c='United Kingdom';
            prodSpecies.ZTS_EU_Type__c='Business Unit';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
            prodSpecies.ZTS_EU_Is_Active__c=true;
            insert prodSpecies1;

            /*     ZTS_EU_Species__c Species = new ZTS_EU_Species__c();
Species.Name='Test Product';
Species.ZTS_EU_Business_Unit__c = prodSpecies1.name;
Species.ZTS_EU_Species__c = 'Pigs';
insert Species;
*/
            Contact getconObj = [select id from Contact where Id = :conrec[0].id AND ZTS_EU_Market__c != 'United States' limit 1];
            ZTS_EU_Species_Product__c speObj1 = new ZTS_EU_Species_Product__c(Name = 'Test Product', ZTS_EU_Type__c = 'Business Unit', ZTS_EU_Market__c = 'United Kingdom', ZTS_EU_Is_Active__c = true);
            insert speObj1;
            ZTS_EU_Species_Product__c speObj2 = new ZTS_EU_Species_Product__c(Name = 'Test Product', ZTS_EU_Market__c = 'United Kingdom', ZTS_EU_Type__c = 'Brand', ZTS_EU_Is_Active__c = true);
            insert speObj2;

            ZTS_EU_Species__c speObj = new ZTS_EU_Species__c(Name = 'Test Species', ZTS_EU_Species__c = 'Pigs', ZTS_EU_Business_Unit__c = speObj1.id,  ZTS_EU_Market__c = 'United Kingdom');
            insert speObj;

            Case caseObj = new Case(Contact = getconObj,ZTS_EU_Species__c =speObj.id,ZTS_EU_Product__c = speObj2.id, Status = 'Open', Origin = 'Letter', Type = 'MIR', Description = 'Testing Test class for CAse', ZTS_EU_Market__c = 'United Kingdom');
            insert caseObj;


            Case getcaseObj = [select id from Case limit 1];
            Id addRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Open Service Request').getRecordTypeId();
            Apexpages.currentPage().getParameters().put('retURL','500/o');
            Apexpages.currentPage().getParameters().put('nooverride','1');
            Apexpages.currentPage().getParameters().put('RecordType',addRecordTypeId);

            ApexPages.StandardController controller = new ApexPages.StandardController(getcaseObj);
            ZTS_EU_ServiceRequestOverride appRedirect = new ZTS_EU_ServiceRequestOverride(controller);
            appRedirect.serviceRedirect();
            appRedirect.Redirect();
        }
    }

    static testMethod void deleteTest() {
       
        MarketGeoMapping__c mgm = new MarketGeoMapping__c();
        mgm.Name = 'United Kingdom';
        mgm.Product_Potential_Level__c = 'asdfasdf';
        insert mgm;

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        System.runAs(usr) {
            PageReference pageRef = Page.ZTS_EU_ServiceReqNewOverride;
            Test.setCurrentPageReference(pageRef);
            List<Contact> conrec = ZTS_EU_DataUtilityTest.createContactRecord(1);
            conrec[0].ZTS_EU_Market__c = 'United Kingdom';
            insert conrec;
            ZTS_EU_Species_Product__c prodSpecies = new ZTS_EU_Species_Product__c();
            prodSpecies.Name = 'Test Product';
            prodSpecies.ZTS_EU_Market__c = 'United Kingdom';
            prodSpecies.ZTS_EU_Type__c = 'Brand';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c = true;
            prodSpecies.ZTS_EU_Is_Active__c = true;
            prodSpecies.ZTS_EU_Product_Potential_Level__c = 'asdfasdf';
            insert prodSpecies;

            ZTS_EU_Species_Product__c prodSpecies1 = new ZTS_EU_Species_Product__c();
            prodSpecies.Name = 'Ruminents';
            prodSpecies.ZTS_EU_Market__c = 'United Kingdom';
            prodSpecies.ZTS_EU_Type__c = 'Business Unit';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c = true;
            prodSpecies.ZTS_EU_Is_Active__c = true;
            insert prodSpecies1;

            /*     ZTS_EU_Species__c Species = new ZTS_EU_Species__c();
Species.Name='Test Product';
Species.ZTS_EU_Business_Unit__c = prodSpecies1.name;
Species.ZTS_EU_Species__c = 'Pigs';
insert Species;
*/
            Contact getconObj = [select id from Contact where Id = :conrec[0].id AND ZTS_EU_Market__c != 'United States' limit 1];
            ZTS_EU_Species_Product__c speObj1 = new ZTS_EU_Species_Product__c(Name = 'Test Product', ZTS_EU_Type__c = 'Business Unit', ZTS_EU_Market__c = 'United Kingdom', ZTS_EU_Is_Active__c = true);
            insert speObj1;
            ZTS_EU_Species_Product__c speObj2 = new ZTS_EU_Species_Product__c(Name = 'Test Product', ZTS_EU_Market__c = 'United Kingdom', ZTS_EU_Type__c = 'Brand', ZTS_EU_Is_Active__c = true);
            insert speObj2;

            ZTS_EU_Species__c speObj = new ZTS_EU_Species__c(Name = 'Test Species', ZTS_EU_Species__c = 'Pigs', ZTS_EU_Business_Unit__c = speObj1.id, ZTS_EU_Market__c = 'United Kingdom');
            insert speObj;

            Case caseObj = new Case(Contact = getconObj, ZTS_EU_Species__c = speObj.id, ZTS_EU_Product__c = speObj2.id, Status = 'Open', Origin = 'Letter', Type = 'MIR', Description = 'Testing Test class for CAse', ZTS_EU_Market__c = 'United Kingdom');
            insert caseObj;

            delete prodSpecies;
        }
    }
}