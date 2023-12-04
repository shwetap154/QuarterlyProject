/**
 * @description       : Test class for AUS_CP_REST_ANIMAL
 * @author            : Aritra Chakraborty @ Cognizant
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   07-10-2019   Aritra Chakraborty @ Cognizant  Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc       Run all tests as an International User. Perform minor code cleanup.
**/
@isTest
private class AUS_CP_REST_ANIMAL_TEST {
    private final static string testAdminUsername = 'testAustraliaAdmin@zoets.com.unitTestUser';

    @testSetup
    private static void setupTestData(){
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfileAndMarket('System Administrator', 'Australia');
        testUser.Username = testAdminUsername;
        insert testUser;
    }
    
	@isTest
    private static void test() {
        System.runAs(retrieveTestUser()) {
            Contact mycontact = new Contact();
            mycontact.lastname = '1';
            mycontact.firstname = '1';
            Insert mycontact;
            
            Animal__c myanimal = new Animal__c();
            myanimal.animal_name__c = '1';
            myanimal.animal_Type__c = 'Horse';
            myanimal.animal_sex__c = 'Male';
            myanimal.AnimalChipID__c = '1';
            myanimal.breed__c = '1';
            myanimal.age__c = null;
            myanimal.Height_hh__c = null;
            myanimal.weight__c = null;
            myanimal.colour__c = null;
            myanimal.Removed_from_Owner__c = false;
            myanimal.Share_opt_in__c = false;
            myanimal.ShowPDFCertificateLink__c = false;
            myanimal.Contact_with_other_horses__c = false;
            myanimal.Deceased__c = false;
            
            Insert myanimal;    
            
            
            
            RestRequest request = new RestRequest();
            request.requestUri ='/Animal/REST/*';
            request.httpMethod = 'GET';
            RestContext.request = request;
            Animal__c[] v1 = AUS_CP_REST_ANIMAL.doGet();
            request.requestUri ='/services/apexrest/Animal/REST/';
            request.httpMethod = 'GET';
            RestContext.request = request;
            Animal__c[] v2 = AUS_CP_REST_ANIMAL.doGet();
        }
    }
        
    @isTest static void testpostcallout(){
        System.runAs(retrieveTestUser()) {
            
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
            myanimal.AnimalChipID__c = '2i222222';
            myanimal.AnimalChipId2__c = '2i22222';
            myanimal.Removed_from_Owner__c = false;
            myanimal.Share_opt_in__c = false;
            myanimal.ShowPDFCertificateLink__c = false;
            myanimal.Contact_with_other_horses__c = false;
            myanimal.Deceased__c = false;
            myanimal.breed__c = '2';
            myanimal.colour__c = null;
            myanimal.age__c = null;
            
            //Insert myanimal;    
            system.debug(myanimal);
            AUS_CP_REST_ANIMAL.animalwrapperreq reqst = new AUS_CP_REST_ANIMAL.animalwrapperreq();
            
            reqst.animaltype = myanimal.animal_type__c;
            reqst.animalname = myanimal.animal_name__c;
            reqst.showpdflink = myanimal.ShowPDFCertificateLink__c ;
            reqst.contactwithotherhorses = myanimal.Contact_with_other_horses__c;
            reqst.shareoptin = myanimal.Share_opt_in__c;
            reqst.removedfromowner = myanimal.Removed_from_Owner__c;
            reqst.decesased = myanimal.Deceased__c;
            reqst.animalchipid = myanimal.animalchipid__c;
            reqst.animalchipid2 = myanimal.animalchipid2__c;
            reqst.animalsex = myanimal.animal_sex__c;
            
            reqst.recordtype = 'Horse';
                
            
            String JSONMsg= JSON.serialize(reqst);
            system.debug(JSONMsg);
            req.requestURI = '/services/apexrest/Animal/REST/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSONMsg); 
            req.addHeader('Content-Type', 'application/json');
            res.statuscode = 201;
            Test.startTest();
            AUS_CP_REST_ANIMAL.animalwrapperresp myresp = new AUS_CP_REST_ANIMAL.animalwrapperresp();
            list<ANIMAL__C> myvaclist = new list<ANIMAL__C>();
            myvaclist.add(myanimal);
            system.debug(myvaclist);
            myvaclist=AUS_CP_REST_ANIMAL.dopost();
            Test.stopTest();
                
        }
    }

    @isTest static void testpostcallout1(){
        System.runAs(retrieveTestUser()) {
            
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
            myanimal.AnimalChipID__c = '2i222222';
            myanimal.AnimalChipId2__c = '2i22222';
            myanimal.Removed_from_Owner__c = false;
            myanimal.Share_opt_in__c = false;
            myanimal.ShowPDFCertificateLink__c = false;
            myanimal.Contact_with_other_horses__c = false;
            myanimal.Deceased__c = false;
            myanimal.breed__c = '2';
            myanimal.colour__c = null;
            myanimal.age__c = null;
            
            Insert myanimal;    
            system.debug(myanimal);
            AUS_CP_REST_ANIMAL.animalwrapperreq reqst = new AUS_CP_REST_ANIMAL.animalwrapperreq();
            
            reqst.animaltype = myanimal.animal_type__c;
            reqst.animalname = myanimal.animal_name__c;
            reqst.showpdflink = myanimal.ShowPDFCertificateLink__c ;
            reqst.contactwithotherhorses = myanimal.Contact_with_other_horses__c;
            reqst.shareoptin = myanimal.Share_opt_in__c;
            reqst.removedfromowner = myanimal.Removed_from_Owner__c;
            reqst.decesased = myanimal.Deceased__c;
            reqst.animalchipid = myanimal.animalchipid__c;
            reqst.animalchipid2 = myanimal.animalchipid2__c;
            reqst.animalsex = myanimal.animal_sex__c;
            
            reqst.recordtype = 'Horse';
                
            
            String JSONMsg= JSON.serialize(reqst);
            system.debug(JSONMsg);
            req.requestURI = '/services/apexrest/Animal/REST/*';  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(JSONMsg); 
            req.addHeader('Content-Type', 'application/json');
            res.statuscode = 201;
            Test.startTest();
            AUS_CP_REST_ANIMAL.animalwrapperresp myresp = new AUS_CP_REST_ANIMAL.animalwrapperresp();
            list<ANIMAL__C> myvaclist = new list<ANIMAL__C>();
            myvaclist.add(myanimal);
            system.debug(myvaclist);
            myvaclist=AUS_CP_REST_ANIMAL.dopost();
            myvaclist=AUS_CP_REST_ANIMAL.dopatch();
            Test.stopTest();       
        }
    }

    @isTest static void testdeletecallout1(){
        System.runAs(retrieveTestUser()) {
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
            
            req.requestURI = '/services/apexrest/Animal/REST/2';  
            req.httpMethod = 'DELETE';
            req.addHeader('Content-Type', 'application/json');
            Test.startTest();
            AUS_CP_REST_ANIMAL.dodelete();
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

/*
@isTest static void testpatchcallout1(){
    //Test.setMock(HttpCalloutMock.class, new GK_REST_TESTMOCK());
    
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
        
    RestContext.request = req;
    RestContext.response = res;
        
    list<animal__c> animallist = new list<animal__c>();
    Animal__c myanimal = new Animal__c();
    myanimal.animal_name__c = '2';
    myanimal.animal_Type__c = 'Horse';
    myanimal.animal_sex__c = 'Male';
    myanimal.AnimalChipID__c = '2M';
   
   // Insert myanimal;    
    system.debug(myanimal);
     req.requestURI = '/services/apexrest/Animal/REST/2M';  
     req.httpMethod = 'PATCH';
     req.addHeader('Content-Type', 'application/json');
     myanimal.Deceased__c = true;
     myanimal.Contact_with_other_horses__c =true;
     myanimal.Share_opt_in__c = false;
     myanimal.Removed_from_Owner__c = true;
     myanimal.ShowPDFCertificateLink__c = true;
   

     
    AUS_CP_REST_ANIMAL.animalwrapperreq reqst = new AUS_CP_REST_ANIMAL.animalwrapperreq();
    
    reqst.animaltype = myanimal.animal_type__c;
    reqst.animalname = myanimal.animal_name__c;
    reqst.showpdflink = myanimal.ShowPDFCertificateLink__c ;
    reqst.contactwithotherhorses = myanimal.Contact_with_other_horses__c;
    reqst.shareoptin = myanimal.Share_opt_in__c;
    reqst.removedfromowner = myanimal.Removed_from_Owner__c;
    reqst.decesased = myanimal.Deceased__c;
    reqst.animalchipid = myanimal.animalchipid__c;
    reqst.animalchipid2 = myanimal.animalchipid2__c;
   
    reqst.recordtype = 'Horse';
    system.debug(reqst);
    Test.startTest();
    AUS_CP_REST_ANIMAL.animalwrapperresp myresp = new AUS_CP_REST_ANIMAL.animalwrapperresp();
    animallist.add(myanimal);
    animallist= AUS_CP_REST_ANIMAL.dopatch();
    Test.stopTest();
            
  
} 
*/
}