/**
* @ClassName    : SpeakerBtnListController_test 
* @CreatedOn    : ??
* @ModifiedBy   : Mohamed Seliman
* @ModifiedOn   : 8/26/2020
* @Description  : Test class for SpeakerBtnListController.
*/
@isTest
public with sharing class SpeakerBtnListController_test {
    private static testMethod void doRedirectTest() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'USER';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Account testAcct = new Account(Name = 'TestAcct',
                                           ZTS_EU_Market__c = 'United Kingdom',
                                           ZTS_US_NARC_ID__c = 'TestNID',
                                           Type = 'Vet Practice',
                                           BillingPostalCode = '6789',
                                           ZTS_EU_Zip_Postal_Code__c = '12345',
                                           BillingCity = 'Boca Raton',
                                           BillingState = 'Florida',
                                           BillingStreet = 'Elm Lane');
            
            insert  testAcct;
            
            Contact testContact  = new Contact(FirstName = 'Test Contact',
                                               LastName = 'Si',
                                               ZTS_EU_Market__c = 'United Kingdom',
                                               ZTS_EU_Profession__c = 'Comercial',
                                               AccountId = testAcct.id,
                                               ZTS_Job_Function__c  = 'Admin Asst/Recep.'
                                               
                                              );
            insert testContact;
            
            ZTS_EU_KOL__c testKOL = new ZTS_EU_KOL__c( ZTS_EU_Contact__c = testContact.id,
                                                      ZTS_US_Role__c = 'Speaker',
                                                      ZTS_US_Species__c = 'Cattle - Dairy',
                                                      ZTS_US_Start_Date__c = date.newInstance(2020, 01, 01),
                                                      ZTS_US_Area_of_Expertise__c = 'Diabetes');
            
            insert testKOL;
            
            ZTS_Events__c testEvent =new ZTS_Events__c(ZTS_US_Name__c ='test Event',
                                                       ZTS_US_Event_Category__c ='CPAC',
                                                       ZTS_US_Location__c = 'some location',
                                                       ZTS_US_Number_of_Attendees__c = 111,
                                                       ZTS_US_Start_Date__c = datetime.newInstance(2020, 05, 01, 12, 30, 0),
                                                       ZTS_US_End_Date__c = datetime.newInstance(2020, 06, 01, 12, 30, 0),
                                                       //ZTS_US_Purpose_Agenda__c = 'some agenda',
                                                       Purpose_Agenda__c = 'some agenda',//Pooja - Added new rich text field insted old text field
                                                       ZTS_US_Type__c = 'Advisory Meeting',
                                                       ZTS_EU_Market__c = 'United Kingdom');
            insert testEvent;
            
            ZTS_US_Speaker__c testSpeaker = new ZTS_US_Speaker__c(ZTS_US_Speaking_Date__c = date.newInstance(2020, 05, 05),
                                                                  ZTS_US_Contact__c = testContact.id, ZTS_US_Event__c = testEvent.id, ZTS_US_Speaker_Fee__c = 1000);
            insert  testSpeaker;
            
            
            Test.startTest();
            
            List<ZTS_US_Speaker__c> speakerList = new List<ZTS_US_Speaker__c>();
            speakerList.add(testSpeaker);
            Test.setCurrentPage(Page.AddSpeakerListBtnVF);
            ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(speakerList);
            standardController.setSelected(speakerList);
            SpeakerBtnListController ext = new SpeakerBtnListController(standardController);
            SpeakerBtnListController.eventIdTest = testEvent.Id;
            System.assertNotEquals(null,ext.doAddSpeakerRedirect());
            SpeakerBtnListController.isIntlRedirect(null);
    
            Test.stopTest();
        }
        
    }
}