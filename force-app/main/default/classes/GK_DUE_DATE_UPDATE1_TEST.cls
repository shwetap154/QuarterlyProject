/**
 * @description       : Test class for MySchedulableClass
 * @author            : Kaushik Ghosh @ Cognizant
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-16-2019   Kaushik Ghosh @ Cognizant   Initial Version (Estimate based on date in Salesforce and MySchedulableClass author)
 * 1.1   03-23-2022   Ethan Hirsch @ Zoetis Inc   Fix unit test failures due to validation errors
**/
@isTest
public class GK_DUE_DATE_UPDATE1_TEST {

    @IsTest
 	static void testMethod1() 
    { 
        Contact mycontact = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
        mycontact.lastname = '1';
        mycontact.firstname = '1';
        insert mycontact;
        
        Animal__c myanimal = new Animal__c();
        myanimal.animal_name__c = '1';
        myanimal.animal_Type__c = 'Horse';
        myanimal.animal_sex__c = 'Male';
        myanimal.AnimalChipID__c = '1';
        insert myanimal;    
        
        VaccinationRegister__c myVR = new VaccinationRegister__c();
        myVR.treatment__c = 'Hendra';
        myVR.VaccinationType2__c = 'Second Dose';
        myVR.vaccinationdate__c = System.Today();
        myVR.Veterinary__c = mycontact.id;
        myVR.animal__c = myanimal.id;
        insert myVR;  
        
        Test.startTest();

            MySchedulableClass obj = new MySchedulableClass();
            obj.execute(null); 
            
        Test.stopTest();
        
        List<VaccinationRegister__c> vr = [SELECT Id, Due_Date__c, VaccinationDate__c FROM VaccinationRegister__c];
        System.assert(vr[0].Due_Date__c > vr[0].VaccinationDate__c);
    }
}