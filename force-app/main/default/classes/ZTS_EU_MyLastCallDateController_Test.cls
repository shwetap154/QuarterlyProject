@isTest (SeeAlldata = False)
public class ZTS_EU_MyLastCallDateController_Test{
    
    private static final Id accountId = SL_IdGenerator.generateMockIdForObjectType(Account.SObjectType);
    private static final Id contactId = SL_IdGenerator.generateMockIdForObjectType(Contact.SObjectType);
    private static final Id callId = SL_IdGenerator.generateMockIdForObjectType(Call__c.SObjectType);
    private static final Id attendeeId = SL_IdGenerator.generateMockIdForObjectType(Attendee__c.SObjectType);
    
    private static Account getMockAccountRecord() 
    {
        String strAccountJson = '{"attributes":' +
                           '{'+
                            '"type":"Account"'+
                            '},'+
                            '"Id":"'+accountId+'",' +
                            '"Name":"Account Test 1",'+
                            '"ZTS_TSF__c":"AccTerri",' +
                            '"ZTS_EU_Zoetis_SFDC_ID__c":"NARCId123"'+
                            '}';
        Account objAccount = (Account)JSON.deserialize(strAccountJson, Account.class);
        
        return objAccount;
    }
    
    private static Contact getMockContactRecord() 
    {
        String strContactJson = '{"attributes":' +
                           '{'+
                            '"type":"Contact"'+
                            '},'+
                            '"Id":"'+contactId+'",' +
                            '"FirstName":"Test",'+
            				'"LastName":"Contact",'+
                            '"ZTS_TSF__c":"AccTerri",' +
                            '"ZTS_EU_Zoetis_SFDC_ID__c":"NARCId123"'+
                            '}';
        Contact objContact = (Contact)JSON.deserialize(strContactJson, Contact.class);
        
        return objContact;
    }
    
    private static Call__c getMockCallRecord() 
    {
        Id userId = UserInfo.getUserId();
        DateTime dttimeLastDay = System.now().addDays(-1);
        String strDateTime = String.valueOf(dttimeLastDay);
        String strCallJson = '{"attributes":' +
                           '{'+
                            '"type":"Call__c"'+
                            '},'+
                            '"Id":"'+callId+'",' +
                            '"ZTS_EU_Account__c":"'+accountId+'",'+
                            '"ZTS_EU_Call_Owner__c":"'+userId+'",' +
                            '"ZTS_EU_Duration__c":"2 hours",'+
            				'"ZTS_EU_Sub_Type__c":"Account Call",'+
            				'"ZTS_EU_Start_Date_Time__c":"2019-04-14"'+
                            '}';
        Call__c objCall = (Call__c)JSON.deserialize(strCallJson, Call__c.class);
        
        return objCall;
    }
    private static Attendee__c getMockAttendeeRecord() 
    {
        String strAttendeeJson = '{"attributes":' +
                           '{'+
                            '"type":"Attendee__c"'+
                            '},'+
                            '"Id":"'+attendeeId+'",' +
                            '"ZTS_EU_call__c":"'+callId+'",'+
                            '"ZTS_EU_Contact__c":"'+contactId+'"' +
                            '}';
        Attendee__c objAttendee = (Attendee__c)JSON.deserialize(strAttendeeJson, Attendee__c.class);
        
        return objAttendee;
    }
	
    @isTest
    static void myTest(){
        PageReference pageRef = Page.ZTS_EU_MyLastCallDateOnContact;
        Test.setCurrentPageReference(pageRef);
        Attendee__c objAttendee = getMockAttendeeRecord();
        Call__c objCall = getMockCallRecord();
        Apexpages.currentpage().getparameters().put('id',objAttendee.ZTS_EU_Contact__c);
		ApexPages.StandardController controller = new ApexPages.StandardController(getMockContactRecord());
        ZTS_EU_MyLastCallDateController appRedirect = new ZTS_EU_MyLastCallDateController(controller);
        Date dtReturned = appRedirect.getMyLastCallDate();
       
    }
}