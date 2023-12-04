/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.

* Name          :   ZTS_EU_ZipAllignBatchTest .
* Description   :    This is used to test ZTS_EU_ZipAllignBatch.
* Author        :    Sunil

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
5/26/2014       Sunil                       Created
*/
@isTest(seeAllData = false)
public with sharing class ZTS_EU_ZipAllignBatchTest {
    
    public static testMethod void tesZipAllign(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            // Insert Custom Territory
            List<ZTS_EU_Territory__c> custTerritory = ZTS_EU_DataUtilityTest.createTerritory(1);
            system.debug('custTerritory****************>'+custTerritory);
            insert custTerritory;
            
            //Insert Brick
            List<ZTS_GL_BrickToTerr__c> brickTerritory = ZTS_EU_DataUtilityTest.createBrickTerrRecord(1);
            List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
            for(ZTS_GL_BrickToTerr__c b : brickTerritory){
                b.ZTS_EU_Territory__c = custTerritory[0].Id;
                brickList.add(b);
            }
            insert brickList;
            //Insert Zip
            List<ZTS_GL_ZipToBrick__c> zipBrick = ZTS_EU_DataUtilityTest.createZipBrickRecord(19);
            List<ZTS_GL_ZipToBrick__c> zipList = new List<ZTS_GL_ZipToBrick__c>();
            for(ZTS_GL_ZipToBrick__c zip : zipBrick){
                zip.ZTS_EU_BrickCode__c = brickList[0].id;
                zipList.add(zip);
            }
            insert zipList;
            
            // Insert Account
            List<Account> acclist = ZTS_EU_DataUtilityTest.createAccountRecord(19);
            List<Account> accountList = new List<Account>();
            for(Account a : acclist){
                a.ZTS_EU_Excludezipbrickterralignment__c = false;
                a.ZTS_EU_Account_Status__c = 'Active';
                a.IsExcludedFromRealign = false;
                a.ZTS_EU_Excludezipbrickterralignment__c = false;
                a.ZTS_EU_Market__c= 'United Kingdom';
                a.ZTS_EU_Zip_Postal_Code__c = '12345';
                accountList.add(a);
                
            }
            insert accountList;
            
            Test.StartTest();
            ZTS_EU_ZipAllignBatch zipObj = new ZTS_EU_ZipAllignBatch();
            zipObj.market = 'United Kingdom';
            ID batchprocessid = Database.executeBatch(zipObj,20);
            Test.StopTest();
            
            Account a = [select id,ZTS_EU_TSF_PBC__c,ZTS_EU_TSF_PBC_1__c, ZTS_EU_TSF_PBC_2__c, ZTS_EU_TSF_PBC_3__c from account where id = :accountList[0].id AND ZTS_EU_Market__c != 'United States' limit 1] ;
            
        }
    }
}