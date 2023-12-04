/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
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
 
 * Name          :   CustomSettingServiceTest .
* Description   :    This is used to test CustomSettingService.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/14/2014       Sunil                       Created
4/11/2022       Ethan Hirsch @ Zoetis       Added execution for setTriggerBypass
4/12/2022       Ethan Hirsch @ Zoetis       Updated the test for Trigger Bypass to actually bypass the Trigger
 */
 @isTest(seeAllData = false)
public with sharing class CustomSettingServiceTest {
    public static testMethod void tesCustomSetting(){
        
        // Insert custom setting data for trigger activation.
        
        //TriggerActivation__c triActivation = new TriggerActivation__c(Name = 'Test Trigger', ZTS_EU_Bypass__c = true);
        //insert triActivation;
        
        // Insert mass territory assignment custom setting data
        ZTS_EU_MassTerritoryAssignment__c massTerritory = new ZTS_EU_MassTerritoryAssignment__c(name = 'Test Sync' , ZTS_EU_Start_Syncing__c = false,ZTS_EU_User_Update_Schedule_Time__c = '0 5 * * * ?');
        insert massTerritory;
        
        //Start test
        Test.StartTest();
            CustomSettingService.refreshTriggerActivationMap();
            CustomSettingService.getzoetisAppConfig();
            CustomSettingService.triggerActivationMap = null;
            CustomSettingService.checkIfTriggerActive('Test Trigger');
            CustomSettingService.triggerActivationMap = null;
            CustomSettingService.checkIfTriggerIsForBypass('Test Trigger');
            CustomSettingService.triggerActivationMap = null;
            CustomSettingService.setTriggerBypass('Test Sync', true);
        Test.StopTest(); // Stop test

        // The data set for the organization using getOrgDefaults, the result is:
        ZTS_EU_MassTerritoryAssignment__c massTerObj = ZTS_EU_MassTerritoryAssignment__c.getOrgDefaults();
        System.assert(massTerObj.ZTS_EU_Start_Syncing__c == false);
        System.assert(massTerObj.name == 'Test Sync');
        
    }
}