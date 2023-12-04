/**
 * @description       : 
 * @author            : Tanmoy Das @ Cognizant
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-12-2018   Tanmoy Das @ Cognizant      Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Run all tests as an International User. Perform minor code cleanup.
**/
@isTest
private class AUS_CP_REST_WORM_TEST {
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
            
            Worming__c myworming = new Worming__c();
            myworming.product__c = '1';
            myworming.source_application__c = 'VA Registry';
            myworming.vaccination_type__c = 'Equimax';
            myworming.Date_of_Worming__c = System.Today();
            myworming.Worming_Country__c = 'Australia';
            myworming.Veterinary__c = mycontact.id;
            myworming.animal__c = myanimal.id;
            Insert myworming;
            
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/Worming/REST/*';
            request.httpMethod = 'GET';
            RestContext.request = request;
            Worming__c[] w1 = AUS_CP_REST_WORM.doGet();
            
            request.requestUri ='/services/apexrest/Worming/REST/';
            request.httpMethod = 'GET';
            RestContext.request = request;
            Worming__c[] w2 = AUS_CP_REST_WORM.doGet();
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
            
            Worming__c myworming = new Worming__c();
            myworming.product__c = '1';
            myworming.source_application__c = 'VA Registry';
            myworming.vaccination_type__c = 'Equimax';
            myworming.Date_of_Worming__c = System.Today();
            myworming.Worming_Country__c = 'Australia';
            myworming.Veterinary__c = mycontact.id;
            myworming.animal__c = myanimal.id;
            Insert myworming; 
            
            String JSONMsg= JSON.serialize(myworming);
            req.requestURI = '/services/apexrest/Worming/REST/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSONMsg); 
            req.addHeader('Content-Type', 'application/json');
            Test.startTest();
            Worming__c[] w3 =AUS_CP_REST_WORM.dopost();
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
            
            Worming__c myworming = new Worming__c();
            myworming.product__c = '1';
            myworming.source_application__c = 'VA Registry';
            myworming.vaccination_type__c = 'Equimax';
            myworming.Date_of_Worming__c = System.Today();
            myworming.Worming_Country__c = 'Australia';
            myworming.Veterinary__c = mycontact.id;
            myworming.animal__c = myanimal.id;
            Insert myworming; 
    
            AUS_CP_REST_WORM.wormingwrapperreq reqst = new AUS_CP_REST_WORM.wormingwrapperreq();
            reqst.dateofworming = myworming.date_of_worming__c;
            reqst.street = myworming.worming_street__c;
            reqst.product = myworming.product__c;
            reqst.suburb = myworming.worming_suburb__c;
            reqst.wormingcountry = myworming.worming_country__c;
            reqst.state = myworming.worming_state__c;
            reqst.postcode = myworming.worming_postcode__c;
            reqst.source = myworming.source_application__c;
            reqst.externalid = myworming.external_id__c;
            reqst.animalchipid = myanimal.animalchipid__c;
            reqst.vaccination = myworming.vaccination_type__c;
    
            String JSONMsg= JSON.serialize(reqst);
            req.requestURI = '/services/apexrest/Worming/REST/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSONMsg); 
            req.addHeader('Content-Type', 'application/json');
            res.statuscode = 201;
            Test.startTest();
            //Worming__c[] w3 =AUS_CP_REST_WORM.dopost();
            AUS_CP_REST_WORM.wormingwrapperresp myresp = new AUS_CP_REST_WORM.wormingwrapperresp();
            list<worming__c> myworminglist = new list<worming__c>();
            myworminglist.add(myworming);
            myworminglist=AUS_CP_REST_WORM.dopost();
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