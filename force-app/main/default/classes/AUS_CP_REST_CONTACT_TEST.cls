@istest
private class AUS_CP_REST_CONTACT_TEST {
    
    private static testmethod void testMethod1()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        user u1 =ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        u1.ZTS_EU_Market__c='Australia';
        u1.Default_Country__c ='Australia';
        insert u1;
        
        Account acc1 = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr){
            insert acc1;
            
            
            
            AUS_CP_REST_CONTACT.contactWrapperReq cwreq = new AUS_CP_REST_CONTACT.contactWrapperReq();
            cwreq.email= 'abccontact@test.com';
            cwreq.firstName='test contact firstname';
            cwreq.lastName='test contact lastname';
            cwreq.password='password1$';
            cwreq.Phone='34353534';
            cwreq.registryReminderDisabled =true;
            cwreq.isEmailOptOut = true;
            cwreq.emailOptOutDate = Date.valueOf('2019-03-26');
            cwreq.country='Australia';
            cwreq.market='Australia';
            cwreq.emailPreference=false;
            cwreq.owner_id=u1.Id;
            cwreq.speciesSpecialty='Companion Animal;Cats';
            cwreq.isGovernmentofficial='Yes';
            cwreq.recordtype='Contact';
            cwreq.ext_id='CON-121324';
            cwreq.syncPermission='Permitted';
            cwreq.vetsAustralia=true;
            cwreq.vetsAustralia_LastLoginDate = Datetime.newInstance(2019, 3, 27, 13, 30, 2);
            cwreq.accountName='test account new records';
            cwreq.contact_type='Veterinarian';
            
            RestRequest req1 = new RestRequest();
            RestResponse res = new RestResponse();
            String JSONMsg= JSON.serialize(cwreq);
            system.debug(JSONMsg);
            req1.requestURI = '/services/apexrest/Contact/REST/*';  
            req1.httpMethod = 'POST';
            req1.requestBody = Blob.valueof(JSONMsg); 
            req1.addHeader('Content-Type', 'application/json');
            RestContext.request = req1;
            RestContext.response = res;
            Test.startTest();
            List<Contact> lstinsertresult = AUS_CP_REST_CONTACT.dopost();
            System.assert(lstinsertresult.size() > 0 );
            
            //FOR POST REQUEST NEGATIVE TESTING (CATCH BLOCK)
            cwreq.isEmailOptOut=TRUE;
            cwreq.ext_id='CON-121324'; //Trying to create a duplicate record
            cwreq.firstName= 'test contact firstname new';
            String JSONMsg11= JSON.serialize(cwreq);
            req1.requestBody = Blob.valueof(JSONMsg11); 
            List<Contact> lstinsertresult2 = AUS_CP_REST_CONTACT.dopost();
            
            //FOR GET REQUEST
            RestRequest req2 = new RestRequest();
            req2.requestURI ='/services/apexrest/Contact/REST/';
            req2.httpMethod = 'GET';
            req2.addHeader('Content-Type', 'application/json');
            RestContext.request = req2;        		
            List<Contact> lstgetresult = AUS_CP_REST_CONTACT.doget();
            
            //FOR GET REQUEST ON EXTERNAL ID
            RestRequest req3 = new RestRequest();
            req3.requestURI ='/services/apexrest/Contact/REST/'+cwreq.ext_id;
            req3.httpMethod = 'GET';
            req3.addHeader('Content-Type', 'application/json');
            RestContext.request = req3;        		
            List<Contact> lstgetresult2 = AUS_CP_REST_CONTACT.doget();
            
            Test.stopTest();
        }

	} 
    
    private static testmethod void testMethod2()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        user u1 =ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        u1.ZTS_EU_Market__c='Australia';
        u1.Default_Country__c ='Australia';
        insert u1;
        
        Account acc1 = new Account();
        acc1.Name = 'test account new record 2';
        acc1.Email__c='testaccount@test.com';
        acc1.ZTS_EU_Country__c='Australia';
        acc1.ZTS_EU_Market__c='Australia';
        acc1.Type = 'Vet Practice';
        acc1.ZTS_EU_Sub_Type__c = 'Companion Animal;Cats';
        acc1.ZTS_EU_Zip_Postal_Code__c ='235444';
        acc1.ZTS_EU_Customer_ID__c='ACC-3257443';

        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr){
            insert acc1;
            
            
            
            AUS_CP_REST_CONTACT.contactWrapperReq cwreq = new AUS_CP_REST_CONTACT.contactWrapperReq();
            cwreq.email= 'abccontact@test.com';
            cwreq.firstName='test contact firstname';
            cwreq.lastName='test contact lastname';
            cwreq.password='password1$';
            cwreq.Phone='34353534';
            cwreq.registryReminderDisabled =true;
            cwreq.isEmailOptOut = true;
            cwreq.emailOptOutDate = Date.valueOf('2019-03-26');
            cwreq.country='Australia';
            cwreq.market='Australia';
            cwreq.emailPreference=false;
            cwreq.owner_id=u1.Id;
            cwreq.speciesSpecialty='Companion Animal;Cats';
            cwreq.isGovernmentofficial='Yes';
            cwreq.recordtype='Contact';
            cwreq.ext_id='CON-121325';
            cwreq.syncPermission='Permitted';
            cwreq.vetsAustralia=true;
            cwreq.vetsAustralia_LastLoginDate = Datetime.newInstance(2019, 3, 26, 13, 30, 2);
            cwreq.accountName='test account new record 2';
            cwreq.contact_type='Veterinarian';
            
            RestRequest req1 = new RestRequest();
            RestResponse res = new RestResponse();
            String JSONMsg= JSON.serialize(cwreq);
            system.debug(JSONMsg);
            req1.requestURI = '/services/apexrest/Account/REST/*';  
            req1.httpMethod = 'POST';
            req1.requestBody = Blob.valueof(JSONMsg); 
            req1.addHeader('Content-Type', 'application/json');
            RestContext.request = req1;
            RestContext.response = res;
            Test.startTest();
            List<Contact> lstinsertresult = AUS_CP_REST_CONTACT.dopost();
            System.assert(lstinsertresult.size() > 0 );
            cwreq.email= 'abctest3@test.com'; 
            cwreq.isGovernmentofficial = 'No';
            String JSONMsg1= JSON.serialize(cwreq);
            
            RestRequest req2 = new RestRequest();
            req2.requestURI ='/services/apexrest/Account/REST/';
            req2.httpMethod = 'PATCH';
            req2.requestBody = Blob.valueof(JSONMsg1);
            req2.addHeader('Content-Type', 'application/json');
            RestContext.request = req2;        		
            List<Contact> lstpatchresult = AUS_CP_REST_CONTACT.dopatch();
            
            cwreq.isEmailOptOut=TRUE;
            cwreq.firstName= '';//Trying to add blank name
            String JSONMsg11= JSON.serialize(cwreq);
            req2.requestBody = Blob.valueof(JSONMsg11); 
            List<Contact> lstpatchresult2 = AUS_CP_REST_CONTACT.dopatch();
            Test.stopTest();
        }

	}

}