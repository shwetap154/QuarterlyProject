/**
 * @description       : Test class for AUS_CP_REST_VACC
 * @author            : Kaushik Ghosh @ Cognizant
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-15-2019   Kaushik Ghosh @ Cognizant   Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Run all tests as an International User. Perform minor code cleanup.
**/
@isTest
private class AUS_CP_REST_VACC_TEST {
    private final static string testAdminUsername = 'testAustraliaAdmin@zoets.com.unitTestUser';

    @testSetup
    private static void setupTestData(){
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfileAndMarket('System Administrator', 'Australia');
        testUser.Username = testAdminUsername;
        insert testUser;
    }

	@isTest
    private static void test() {
        system.runAs(retrieveTestUser()) {
            Contact mycontact = new Contact();
            mycontact.lastname = '1';
            mycontact.firstname = '1';
            Insert mycontact;
            
            Animal__c myanimal = new Animal__c();
            myanimal.animal_name__c = '1';
            myanimal.animal_Type__c = 'Horse';
            myanimal.animal_sex__c = 'Male';
            myanimal.AnimalChipID__c = '1';
        
            Insert myanimal;    
            
            VaccinationRegister__c myVR = new VaccinationRegister__c();
            myVR.treatment__c = 'Dentistry';
            myVR.VaccinationType2__c = 'Single Dose';
            myVR.vaccinationdate__c = System.Today();
            myVR.Vaccination_Country__c  = 'Australia';
            
            myVR.Veterinary__c = mycontact.id;
            myVR.animal__c = myanimal.id;
            Insert myVR;
            
            RestRequest request = new RestRequest();
            request.requestUri ='/VaccineRegister/REST/';
            request.httpMethod = 'GET';
            RestContext.request = request;
            VaccinationRegister__c[] v1 = AUS_CP_REST_VACC.doGet();
            request.requestUri ='/services/apexrest/VaccineRegister/REST/';
            request.httpMethod = 'GET';
            RestContext.request = request;
            VaccinationRegister__c[] v2 = AUS_CP_REST_VACC.doGet();
        }
	}
	
	@isTest static void testpostcallout(){
        system.runAs(retrieveTestUser()) {    
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                
            RestContext.request = req;
            RestContext.response = res;
                

            Contact mycontact = new Contact();
            mycontact.lastname = '2';
            mycontact.firstname = '2';
            Insert mycontact;
            
            Animal__c myanimal = new Animal__c();
            myanimal.animal_name__c = '2';
            myanimal.animal_Type__c = 'Horse';
            myanimal.animal_sex__c = 'Male';
            myanimal.AnimalChipID__c = '2';
        
            Insert myanimal;    
            
            VaccinationRegister__c myVR1 = new VaccinationRegister__c();
            myVR1.treatment__c = 'Dentistry';
            myVR1.VaccinationType2__c = 'Single Dose';
            myVR1.vaccinationdate__c = System.Today();
            myVR1.Vaccination_Country__c  = 'Australia';
            myVR1.Veterinary__c = mycontact.id;
            myVR1.animal__c = myanimal.id;
            myVR1.others__c = 'Test Info';
            Insert myVR1;
            
            String JSONMsg= JSON.serialize(myVR1);
            req.requestURI = '/services/apexrest/VaccineRegister/REST/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSONMsg); 
            req.addHeader('Content-Type', 'application/json');
            Test.startTest();
            VaccinationRegister__c[] w3 =AUS_CP_REST_VACC.dopost();
            Test.stopTest();
        }
    }

    @isTest static void testpostcallout1(){
        system.runAs(retrieveTestUser()) {
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
                
            RestContext.request = req;
            RestContext.response = res;
                
            
            Contact mycontact = new Contact();
            mycontact.lastname = '2';
            mycontact.firstname = '2';
            Insert mycontact;
            
            Animal__c myanimal = new Animal__c();
            myanimal.animal_name__c = '2';
            myanimal.animal_Type__c = 'Horse';
            myanimal.animal_sex__c = 'Male';
            myanimal.AnimalChipID__c = '2';
        
            Insert myanimal;    
            
            VaccinationRegister__c myVR1 = new VaccinationRegister__c();
            myVR1.treatment__c = 'Dentistry';
            myVR1.VaccinationType2__c = 'Single Dose';
            myVR1.vaccinationdate__c = System.Today();
            myVR1.Vaccination_Country__c  = 'Australia';
            myVR1.Veterinary__c = mycontact.id;
            myVR1.animal__c = myanimal.id;
            myVR1.others__c = 'Test Info';
            Insert myVR1; 
            
        
        AUS_CP_REST_VACC.vaccinationwrapperreq reqst = new AUS_CP_REST_VACC.vaccinationwrapperreq();
            reqst.treatment = myVR1.treatment__c ;
            reqst.vaccination = myVR1.VaccinationType2__c ;
            reqst.vaccinationdate = myVR1.vaccinationdate__c ;
            reqst.animalchipid = myanimal.animalchipid__c;
            reqst.vetname = '';
            reqst.externalid = myVR1.external_id__c;
            reqst.animalchipid = myanimal.animalchipid__c;
            reqst.inactive = false;
            reqst.vaccountry = myVR1.Vaccination_Country__c ;

            String JSONMsg= JSON.serialize(reqst);
            req.requestURI = '/services/apexrest/VaccineRegister/REST/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSONMsg); 
            req.addHeader('Content-Type', 'application/json');
            res.statuscode = 201;
            Test.startTest();
            AUS_CP_REST_VACC.vaccinationwrapperresp myresp = new AUS_CP_REST_VACC.vaccinationwrapperresp();
            list<VaccinationRegister__c> myvaclist = new list<VaccinationRegister__c>();
            myvaclist.add(myVR1);
            myvaclist=AUS_CP_REST_VACC.dopost();
            Test.stopTest();
        }
    }

    private static User retrieveTestUser() {
        return [
            SELECT Id 
            FROM User 
            WHERE Username =: testAdminUsername 
            LIMIT 1];
    }
}