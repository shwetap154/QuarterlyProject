/*******************************************************************************************************************************************
* File Name     :  ZTS_US_RecordCreationOnAccount_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Chandra            Created the Class.
* 1.1     27/10/2023   Yadagiri           Added ZTS_US_RecordupdateOnAccount1 method
*****************************************************************************************************************************************/

@isTest(SeeAlldata = False)
public class ZTS_US_RecordCreationOnAccount_Test 
{   
    @testVisible static final String ANIMAL_COUNT_INSERT_EXP_ORIGIN1 = 'ZTS_US_RecordCreationOnAccount_Test - ZTS_US_RecordCreationOnAccount(): insert ZTS_Animal_Count_Potential__c ';
    @testVisible static final String ANIMAL_COUNT_INSERT_EXP_ORIGIN2 = 'ZTS_US_RecordCreationOnAccount_Test - ZTS_US_RecordupdateOnAccount(): insert ZTS_Animal_Count_Potential__c';

    @isTest
    static void ZTS_US_RecordCreationOnAccount(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(2);
        insert lstacnt;
        List<ZTS_Animal_Count_Potential__c> lstanimalcount = ZTS_DataUtilityTest.createAnimalCount(lstacnt);
        insert lstanimalcount;
        test.startTest();
        List<ZTS_Animal_Count_Potential__c> lstanimalcount1 = ZTS_DataUtilityTest.createAnimalCount(lstacnt);
        Boolean errorFlag = false;
        try
        {
            insert lstanimalcount1;
        }
        catch(DmlException dex)
        {
            errorFlag = true;
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(ANIMAL_COUNT_INSERT_EXP_ORIGIN1);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, ANIMAL_COUNT_INSERT_EXP_ORIGIN1);
        }
        test.stopTest();

        System.assertEquals(false, errorFlag, 'The expected value of ErrorFlag is False as no error should be thrown');
    }

    @isTest
    static void ZTS_US_RecordupdateOnAccount(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        Account acc2 = new Account();
        acc2.name = 'Test Account2';
        acc2.BillingPostalCode = '00000';
        acc2.BillingCity = 'testCity';
        acc2.BillingState = 'testState';
        acc2.BillingStreet = 'testStreet';
        insert acc2;
        ZTS_Animal_Count_Potential__c animalcount2=new ZTS_Animal_Count_Potential__c();
        animalcount2.ZTS_No_of_Calves__c = 20;
        animalcount2.ZTS_EU_Account__c = acc2.id;
        animalcount2.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Cattle_Count').getRecordTypeId();
        insert  animalcount2;
        
        ZTS_Animal_Count_Potential__c animalcount22=new ZTS_Animal_Count_Potential__c();
        animalcount22.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Equine_Count').getRecordTypeId();
        animalcount22.ZTS_No_of_Horses__c = 15;
        animalcount22.ZTS_Treated_Racing__c=100;
        animalcount22.ZTS_EU_Account__c = acc2.id;
        insert  animalcount22;
       
        animalcount22.RecordTypeId=Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Cattle_Count').getRecordTypeId();
        animalcount22.ZTS_No_of_Calves__c=15;
        test.startTest();
        Boolean errorFlag = false;
        try
        {
            update animalcount22;
        }
        catch(DmlException dex)
        {
            errorFlag = true;
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(ANIMAL_COUNT_INSERT_EXP_ORIGIN2);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, ANIMAL_COUNT_INSERT_EXP_ORIGIN2);
        }
        test.stopTest();

        System.assertEquals(true, errorFlag, 'The update Animal Account shall throw a duplicate error and hence the flag should be true.');
    }
    
    @isTest
    static void ZTS_US_RecordupdateOnAccount1(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        
        Account acc2 = new Account();
        acc2.name = 'Test Account2';
        acc2.BillingPostalCode = '00000';
        acc2.BillingCity = 'testCity';
        acc2.BillingState = 'testState';
        acc2.BillingStreet = 'testStreet';
        insert acc2;
        ZTS_Animal_Count_Potential__c animalcount2=new ZTS_Animal_Count_Potential__c();
        animalcount2.ZTS_No_of_Calves__c = 20;
        animalcount2.ZTS_EU_Account__c = acc2.id;
        animalcount2.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('Feed_Mill').getRecordTypeId();
        insert  animalcount2;
            
        ZTS_Animal_Count_Potential__c animalcount3=new ZTS_Animal_Count_Potential__c();
        animalcount3.ZTS_No_of_Calves__c = 20;
        animalcount3.ZTS_EU_Account__c = acc2.id;
        animalcount3.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('Feed_Mill').getRecordTypeId();
        insert  animalcount3;
        
        test.startTest();
        List<ZTS_Animal_Count_Potential__c> animalcount  = [select id from ZTS_Animal_Count_Potential__c where recordtype.name = 'Feed Mill'];
        List<ZTS_Animal_Count_Potential__c> animalclountlist = new List<ZTS_Animal_Count_Potential__c>();
        animalclountlist.add(animalcount2);
        USZTS_Animal_Count_PotentTriggerService.beforeInsert(animalclountlist);
        
        System.assertEquals(2,animalcount.size(),'2 Animal Count records should be returned');
        
        test.stoptest();
    }
    
    //  
    @isTest
    static void testAcctMerge(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            //insert 1st account
            Account acc = new Account();
            acc.name = 'Test Account1';
            acc.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc.ZTS_EU_Country__c = 'United States';
            acc.BillingCity = 'Test City1';
            acc.ZTS_US_State_Province__c  = 'Province1';
            acc.BillingStreet = 'Test Street1';  
            acc.BillingPostalCode = '00000';
            acc.BillingState = 'testState';
            acc.ZTS_EU_Zip_Postal_Code__c = '12354';
            insert acc;
            
            ZTS_Animal_Count_Potential__c animalcount=new ZTS_Animal_Count_Potential__c();
            animalcount.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Equine_Count').getRecordTypeId();
            animalcount.ZTS_No_of_Horses__c = 20;
            animalcount.ZTS_EU_Account__c = acc.id;
            animalcount.ZTS_Treated_Racing__c=100;
            insert  animalcount;
            //insert 2nd account
            
            Account acc2 = new Account();
            acc2.name = 'Test Account2';
            acc2.ZTS_US_Business_Class__c = 'Sub-Class 2';
            acc2.ZTS_EU_Country__c = 'United States';
            acc2.BillingCity = 'Test City2';
            acc2.ZTS_US_State_Province__c  = 'Province2';
            acc2.BillingStreet = 'Test Street2';  
            acc2.BillingPostalCode = '00000';
            acc2.BillingState = 'testState';
            acc2.ZTS_EU_Zip_Postal_Code__c = '12345';
            insert acc2;
            
            ZTS_Animal_Count_Potential__c animalcount2=new ZTS_Animal_Count_Potential__c();
            animalcount2.ZTS_No_of_Calves__c = 20;
            animalcount2.ZTS_EU_Account__c = acc2.id;
            animalcount2.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Cattle_Count').getRecordTypeId();
            insert  animalcount2;
            
            ZTS_Animal_Count_Potential__c animalcount22=new ZTS_Animal_Count_Potential__c();
            animalcount22.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Equine_Count').getRecordTypeId();
            animalcount22.ZTS_No_of_Horses__c = 15;
            animalcount22.ZTS_Treated_Racing__c=100;
            animalcount22.ZTS_EU_Account__c = acc2.id;
            insert  animalcount22;
            
            test.startTest();
            merge acc acc2;
            test.stopTest();
        }
    }

    @isTest
    static void testAcctMerge2(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            //insert 1st account
            Account acc = new Account();
            acc.name = 'Test Account1';
            acc.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc.ZTS_EU_Country__c = 'United States';
            acc.BillingCity = 'Test City1';
            acc.ZTS_US_State_Province__c  = 'Province1';
            acc.BillingStreet = 'Test Street1'; 
            acc.BillingPostalCode = '00000';
            acc.BillingState = 'testState';
            acc.ZTS_EU_Zip_Postal_Code__c = '12354';
            insert acc;
            
            //insert 2nd account
            
            Account acc2 = new Account();
            acc2.name = 'Test Account2';
            acc2.ZTS_US_Business_Class__c = 'Sub-Class 2';
            acc2.ZTS_EU_Country__c = 'United States';
            acc2.BillingCity = 'Test City2';
            acc2.ZTS_US_State_Province__c  = 'Province2';
            acc2.BillingStreet = 'Test Street2'; 
            acc2.BillingPostalCode = '00000';
            acc2.BillingState = 'testState';
            acc2.ZTS_EU_Zip_Postal_Code__c = '12345';
            insert acc2;
            
            ZTS_Animal_Count_Potential__c animalcount2=new ZTS_Animal_Count_Potential__c();
            animalcount2.ZTS_No_of_Calves__c = 20;
            animalcount2.ZTS_EU_Account__c = acc2.id;
            animalcount2.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Cattle_Count').getRecordTypeId();
            insert  animalcount2;
            
            ZTS_Animal_Count_Potential__c animalcount22=new ZTS_Animal_Count_Potential__c();
            animalcount22.RecordTypeId =Schema.SObjectType.ZTS_Animal_Count_Potential__c.getRecordTypeInfosByDeveloperName().get('ZTS_Equine_Count').getRecordTypeId();
            animalcount22.ZTS_No_of_Horses__c = 15;
            animalcount22.ZTS_Treated_Racing__c=100;
            animalcount22.ZTS_EU_Account__c = acc2.id;
            insert  animalcount22;
            
            test.startTest();
            merge acc acc2;
            test.stopTest();
        }
    }
    
    
}