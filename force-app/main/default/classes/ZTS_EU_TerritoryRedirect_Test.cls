@isTest (Seealldata = false)
public class ZTS_EU_TerritoryRedirect_Test{
    
    static testMethod void myTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            TerrSyncLogic__c terrsync = new TerrSyncLogic__c();
            terrsync.Name = 'From VF Page';
            insert terrsync;
            //        TerrSyncLogic__c tr = [Select Need_syncing__c from TerrSyncLogic__c where name='From VF page'];
            PageReference pageRef = Page.ZTS_EU_TerritoryRedirect;
            Test.setCurrentPageReference(pageRef);
            
            ZTS_EU_Territory__c trrObj = new ZTS_EU_Territory__c(Name = 'Test Territory', ZTS_EU_Market__c = 'United Kingdom', ZTS_EU_Territory_synced__c = True);
            insert trrObj;
            
            ZTS_EU_Territory__c gettrrObj = [select id from ZTS_EU_Territory__c WHERE ZTS_EU_Market__c != 'United States' limit 1];
            TerrSyncLogic__c tr = [Select Need_syncing__c from TerrSyncLogic__c where name='From VF page'];
            
            //       Apexpages.currentPage().getParameters().put('retURL','a0n/o');
            //      Apexpages.currentPage().getParameters().put('nooverride','1');
            //      Apexpages.currentPage().getParameters().put('00NL0000002jPYV','United Kingdom');
            
            ApexPages.StandardController controller = new ApexPages.StandardController(gettrrObj);
            ZTS_EU_TerritoryRedirect appRedirect = new ZTS_EU_TerritoryRedirect(controller);
            Test.startTest();
            appRedirect.trrRedirect();
            Test.stopTest();
        }
    }
}