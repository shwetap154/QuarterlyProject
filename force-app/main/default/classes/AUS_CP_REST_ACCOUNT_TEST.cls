@istest
private class AUS_CP_REST_ACCOUNT_TEST {
    
    private static testmethod void testMethod1()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        user u1 =ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        u1.ZTS_EU_Market__c='Australia';
        u1.Default_Country__c ='Australia';
        insert u1;
        system.runAs(u1)
        {
            
            AUS_CP_REST_ACCOUNT.accountWrapperReq awreq = new AUS_CP_REST_ACCOUNT.accountWrapperReq();
            awreq.email = 'abc@test.com'; 
            awreq.Name= 'est account new from endpoint';
            awreq.Phone= '122323432';
            awreq.send_Owner_Reminders= true;
            awreq.isEmailOptOut= true;
            awreq.emailOptOutDate= Date.valueOf('2019-03-26');
            awreq.city= 'Melbourne';
            awreq.zipcode= '134267';
            awreq.district='australia_test';
            awreq.subtype='Companion Animal;Cats';
            awreq.account_type='Vet Practice';
            awreq.country='Australia';
            awreq.market='Australia';
            awreq.statecountyval ='New South Wales';
            awreq.email_preference='Monthly';
            awreq.addressLine1='Test Address1';
            awreq.addressLine2='Test Address2';
            awreq.account_status='Active';
            awreq.rep_account_status='Inactive';
            awreq.inactive_reason = 'Invalid';
            awreq.Potential_Region='1';
            awreq.owner_id=u1.Id;
            awreq.recordtype='Activated Account';
            awreq.ext_id='121324';
            
            RestRequest req1 = new RestRequest();
            RestResponse res = new RestResponse();
            String JSONMsg= JSON.serialize(awreq);
            system.debug(JSONMsg);
            req1.requestURI = '/services/apexrest/Account/REST/*';  
            req1.httpMethod = 'POST';
            req1.requestBody = Blob.valueof(JSONMsg); 
            req1.addHeader('Content-Type', 'application/json');
            RestContext.request = req1;
            RestContext.response = res;
            Test.startTest();
            List<Account> lstinsertresult = AUS_CP_REST_ACCOUNT.dopost();
            System.assert(lstinsertresult.size() > 0 );
            //FOR POST REQUEST NEGATIVE TESTING (CATCH BLOCK)
            awreq.isEmailOptOut=TRUE;
            awreq.ext_id='121324'; //Trying to create a duplicate record
            awreq.Name= 'test account negative testing';
            String JSONMsg11= JSON.serialize(awreq);
            req1.requestBody = Blob.valueof(JSONMsg11); 
            List<Account> lstinsertresult2 = AUS_CP_REST_ACCOUNT.dopost();
            
            //FOR POST REQUEST WITH BLANK STATECOUNTY VALUE
            AUS_CP_REST_ACCOUNT.accountWrapperReq awreq2 = New AUS_CP_REST_ACCOUNT.accountWrapperReq();
            awreq2 = awreq;
            awreq2.ext_id='23254324654'; 
            awreq2.Name= 'test account negative testing';
            awreq2.statecountyval ='';
            String JSONMsg2= JSON.serialize(awreq);
            req1.requestBody = Blob.valueof(JSONMsg2); 
            List<Account> lstinsertresult12 = AUS_CP_REST_ACCOUNT.dopost();
            
            //FOR GET REQUEST
            RestRequest req2 = new RestRequest();
            req2.requestURI ='/services/apexrest/Account/REST/';
            req2.httpMethod = 'GET';
            req2.addHeader('Content-Type', 'application/json');
            RestContext.request = req2;        		
            List<Account> lstgetresult = AUS_CP_REST_ACCOUNT.doget();
            
            //FOR GET REQUEST ON EXTERNAL ID
            RestRequest req3 = new RestRequest();
            req3.requestURI ='/services/apexrest/Account/REST/'+awreq.ext_id;
            req3.httpMethod = 'GET';
            req3.addHeader('Content-Type', 'application/json');
            RestContext.request = req3;        		
            List<Account> lstgetresult2 = AUS_CP_REST_ACCOUNT.doget();
            
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
        System.runAs(u1)
        {
            AUS_CP_REST_ACCOUNT.accountWrapperReq awreq = new AUS_CP_REST_ACCOUNT.accountWrapperReq();
            awreq.email = 'abctest2@test.com'; 
            awreq.Name= 'Test account new from endpoint 2';
            awreq.Phone= '1223234322';
            awreq.send_Owner_Reminders= true;
            awreq.isEmailOptOut= true;
            awreq.emailOptOutDate= Date.valueOf('2019-07-02');
            awreq.city= 'Sydney';
            awreq.zipcode= '134267';
            awreq.district='australia_test';
            awreq.subtype='Companion Animal';
            awreq.account_type='Vet Practice';
            awreq.country='Australia';
            awreq.market='Australia';
            awreq.statecountyval ='Western Australia';
            awreq.email_preference='Monthly';
            awreq.addressLine1='Test Address 1';
            awreq.addressLine2='Test Address 2';
            awreq.account_status='Active';
            awreq.rep_account_status='Active';
            awreq.Potential_Region='1';
            awreq.owner_id=u1.Id;
            awreq.recordtype='Activated Account';
            awreq.ext_id='121325';
            
            RestRequest req1 = new RestRequest();
            RestResponse res = new RestResponse();
            String JSONMsg= JSON.serialize(awreq);
            system.debug(JSONMsg);
            req1.requestURI = '/services/apexrest/Account/REST/*';  
            req1.httpMethod = 'POST';
            req1.requestBody = Blob.valueof(JSONMsg); 
            req1.addHeader('Content-Type', 'application/json');
            RestContext.request = req1;
            RestContext.response = res;
            Test.startTest();
            List<Account> lstinsertresult = AUS_CP_REST_ACCOUNT.dopost();
            System.assert(lstinsertresult.size() > 0 );
            awreq.email= 'abctest3@test.com'; 
            awreq.email_preference = 'Quarterly';
            awreq.statecountyval ='';
            String JSONMsg1= JSON.serialize(awreq);
            
            RestRequest req2 = new RestRequest();
            req2.requestURI ='/services/apexrest/Account/REST/';
            req2.httpMethod = 'PATCH';
            req2.requestBody = Blob.valueof(JSONMsg1);
            req2.addHeader('Content-Type', 'application/json');
            RestContext.request = req2;        		
            List<Account> lstpatchresult = AUS_CP_REST_ACCOUNT.dopatch();
            
            awreq.isEmailOptOut=TRUE;
            awreq.Name= '';//Trying to add blank name
            String JSONMsg11= JSON.serialize(awreq);
            req2.requestBody = Blob.valueof(JSONMsg11); 
            List<Account> lstpatchresult2 = AUS_CP_REST_ACCOUNT.dopatch();
            
            //Update the account with valid State-county value
            awreq.statecountyval= 'New South Wales';
            String JSONMsg12= JSON.serialize(awreq);
            req2.requestBody = Blob.valueof(JSONMsg12); 
            List<Account> lstpatchresult3 = AUS_CP_REST_ACCOUNT.dopatch();
            Test.stopTest();
        }

	}

}