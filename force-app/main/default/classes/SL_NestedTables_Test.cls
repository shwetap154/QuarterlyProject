@isTest
private class SL_NestedTables_Test
{
    @isTest 
    static void test_dynQry() 
    {	
        User intlUsr = new User();
        intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        intlUsr.FirstName = 'IntUser';
        intlUsr.ZTS_EU_Market__c = 'United Kingdom';
        insert intlUsr;
        // Account objAcc = new Account();
        // Contact objContact = new Contact();
        // ApexPages.StandardSetController setCon;
        // SL_LinkContactToAccountController objCntl;
        Account objAcc = new Account();
        System.runAs(intlUsr) {

        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> mapAccountRecTypes = cfrSchema.getRecordTypeInfosByDeveloperName();
        
        List<String> lstAccRecTypeNames = new List<String>();
        for(String strName : mapAccountRecTypes.keySet()) {
           if(strName != 'Household' && mapAccountRecTypes.get(strName).isAvailable())
            lstAccRecTypeNames.add(strName);
        }
        
        Id accTestRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(lstAccRecTypeNames[0]).getRecordTypeId();
        objAcc = new Account();
        if(accTestRecTypeId != null){
           objAcc.Name='Test Household Acc';
           objAcc.RecordTypeId = accTestRecTypeId;
           objAcc.ZTS_EU_Market__c = 'Italy';
        }  
        else{
             objAcc.Name='Test Household Acc';
        }
        Insert objAcc;  
       
        
        Contact objCont = new Contact(firstName='Cont', lastName = 'Test', AccountId = objAcc.Id, ZTS_EU_Market__c ='Italy');
        insert objCont;

    }
        Test.startTest();
            // Test without a given sort field or sort direction
            SL_NestedTables.dynQry('Id,Name', 'Account', '', '', '', '', '', '', false, null, '','');
            
            // Test with all parameters
            String jsonReturnVal = SL_NestedTables.dynQry(
            'Id,AccountId,Name,Account.CreatedDate,Account.CreatedBy.Name',
            'Contact',
            'AccountId',
            'DESC',
            'ownerId = currentuser',
            objAcc.Id,
            'AccountId',
            '',
            false,
            null, 
            '',
            '');
            
            //test parent field sort
            String jsonReturnVal1 = SL_NestedTables.dynQry(
            'Id,AccountId,Name,Account.CreatedDate,Account.CreatedBy.Name',
            'Contact',
            'AccountId',
            'DESC',
            'ownerId = currentuser',
            objAcc.Id,
            'AccountId',
            '',
            true,
            null, 
            '',
            '');
            
            String jsonReturnVal2 = SL_NestedTables.dynQry(
            'Id,AccountId,Name,Account.CreatedDate,Account.CreatedBy.Name',
            'Contact',
            'AccountId',
            'DESC',
            'ownerId = currentuser',
            objAcc.Id,
            'AccountId',
            '',
            true,
            'Contact', 
            'Id',
            '');
            
            
            SL_NestedTables.dynQry( 'Name,AccountNumber', 'Account','Name','ASC',
                                '',
                                objAcc.Id,
                                'Id',
                                'Id',
                                false,
                                'Contact',
                                'AccountID',
                                '');
            SL_NestedTables.getUserPemissions(objAcc.Id);
            SL_NestedTables.getProfileAccessForMainObj('Account');
            SL_NestedTables.getRecordType('Account');
            SL_NestedTables.getName('Account');
            SL_NestedTables.deleteRecord(objAcc.Id);
            SL_NestedTables_ResponseWrapper obj = new SL_NestedTables_ResponseWrapper(intlUsr,1);
            
        Test.stopTest();
        List<Account> lstAcc = [Select Id from Account];
        system.assertEquals(0, lstAcc.size());
        
    }
    
    @isTest
    static void test_getChildRelationshipName() {
        Test.startTest();
        
        String result = SL_NestedTables.getChildRelationshipName('Asset','Contact', Null);
        
        System.assertEquals('Assets', result);
        
        result = SL_NestedTables.getChildRelationshipName('Chicken','Contact', Null);
        
        System.assertEquals(null, result);
        
        Test.stopTest();
    }
}