@isTest (SeeAlldata = False)
public class ZTS_EU_CustEventsredirect_Test{

    static testMethod void myTest(){

        List<Profile> p = [select Id from Profile where Name='System Administrator' limit 1];       
        User user = new User(username='testUser@testabcasdfasdf232323.com',alias='abctest',ProfileId=p[0].Id,email='test@abc.com',CommunityNickname='abc',ZTS_EU_Market__c='United Kingdom',EmailEncodingKey='ISO-8859-1', TimeZoneSidKey='America/Los_Angeles',LanguageLocaleKey='en_US',LocaleSidKey='en_US',CurrencyIsoCode='EUR',LastNAme='testLsatNAme');
        insert user;

        System.runAs(user)
        {

        PageReference pageRef = Page.ZTS_EU_CustEventsredirect;
        Test.setCurrentPageReference(pageRef);

        //create Time out of Territory
        ZTS_Events__c eventsObj = new ZTS_Events__c(ZTS_US_Name__c = 'Test Event',ZTS_US_Start_Date__c = System.now(), ZTS_US_End_Date__c = System.now()+1, 
                                                              ZTS_US_Event_Category__c = 'Educational Meeting', ZTS_US_Number_of_Attendees__c = 20, ZTS_US_Type__c = 'BRD Solutions',ZTS_US_Location__c = 'Test Location', ZTS_EU_Market__c = 'Germany',
                                                               Purpose_Agenda__c = 'ZTS_US_Purpose_Agenda__c');
        insert eventsObj;
        
        
        ZTS_Events__c geteventObj = [select id from ZTS_Events__c WHERE ZTS_EU_Market__c != 'United States' limit 1];
        Schema.DescribeSObjectResult r = ZTS_Events__c.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        Apexpages.currentPage().getParameters().put('retURL','/'+keyPrefix+'/e');
        Apexpages.currentPage().getParameters().put('nooverride','1');
        
        ApexPages.StandardController controller = new ApexPages.StandardController(geteventObj);
        ZTS_EU_CustEventsredirect appRedirect = new ZTS_EU_CustEventsredirect(controller);
        appRedirect.eventsRedirect();
        }
        
    }
}