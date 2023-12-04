@isTest
public class EventApprovalTest{
    
    @IsTest
    static void validate_eventApprovalTest() {
        ZTS_Events__c eve = new ZTS_Events__c(ZTS_US_Name__c = 'Test Event',ZTS_US_Type__c = 'Full Day Wet Lab',ZTS_US_Event_Category__c ='Educational Meeting',ZTS_US_Status__c = 'new', ZTS_US_Number_of_Attendees__c=5, ZTS_US_Location__c = 'Chicago',Purpose_Agenda__c='Test', ZTS_US_Start_Date__c = System.today(),ZTS_US_End_Date__c = System.today()+1);
        insert eve;            
       
        ZTS_EU_Species_Product__c prd = new ZTS_EU_Species_Product__c(Name='Draxxin', ZTS_Hierarchy_Level__c ='Product Line',ZTS_Species__c='Cattle Pork',ZTS_US_Product_ID__c='10204');
        Insert prd;
        ZTS_US_Event_Product__c evtprd = new ZTS_US_Event_Product__c(ZTS_US_Events__c=eve.id, ZTS_US_Product__c=prd.id);
        Insert evtprd;
        
        List<Account> acct = ZTS_DataUtilityTest.createAccountRecord(1);
        insert acct;
        
        ZTS_US_Event_Account__c evtacct = new ZTS_US_Event_Account__c(ZTS_US_Event_Account__c=acct[0].id,ZTS_US_Events__c=eve.id);
        insert evtacct;

        Test.startTest();
            EventApproval.submitEventApprovalRequest(eve.id);
        Test.stopTest();

        List<ProcessInstance> objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :eve.id];
        System.assert( !objProcessInstance.isEmpty(), 'Event not submitted for approval' );
    }
}