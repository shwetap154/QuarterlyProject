/*
    * Test Class : Class(RequestPayment)
    * Created: 8th aug,2015
    * Author: Sohil Shah (CloudSense)
    * Reference: DEF-001710
*/
@isTest
public class RequestPaymentTest
{
    static testMethod void TestRequestPayment()
    {
       //adding market segmenting
        ZTS_Events__c eve = new ZTS_Events__c(ZTS_US_Name__c = 'Test Event',ZTS_US_Accomplishment__c='Test Accomplishment',ZTS_EU_Market__c = 'United States',ZTS_US_Type__c = 'DISC',ZTS_US_Event_Category__c ='CPAC',ZTS_US_Status__c = 'Complete', ZTS_US_Location__c='US', ZTS_US_Number_of_Attendees__c=5, Purpose_Agenda__c='Test', ZTS_US_Start_Date__c = System.today(),ZTS_US_End_Date__c = System.today());
       test.startTest();
       insert eve;
       RequestPayment.paymentRequestOnEvent(eve.id);
       test.stopTest();
    }
}