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
 
 * Name          :   GlobalVariablesServiceTest .
* Description   :    This is used to test GlobalVariablesService.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/14/2014       Sunil                       Created
 */
@isTest
private class GlobalVariablesServiceTest {

    @IsTest
    static void tesGlobalVariable(){
        GlobalVariablesService.isCallDeletingEvent = false;
        GlobalVariablesService.isCallUpdatingEvent = false;
        GlobalVariablesService.isEventUpdatingCall = false;
        GlobalVariablesService.isEventDeletingCall = false;

        // Insert mass territory assignment custom setting data
        sObject s = new Account(ShippingCity='Abc',name='name');
        String getString = GlobalVariablesService.getString(s,'ShippingCity','yes');
        /*ZTS_EU_MassTerritoryAssignment__c massTerritory = new ZTS_EU_MassTerritoryAssignment__c(name = 'Test Sync' , ZTS_EU_Start_Syncing__c = false,ZTS_EU_User_Update_Schedule_Time__c = '0 5 * * * ?');
        insert massTerritory;*/

        ZTS_Settings__c objCS = new ZTS_Settings__c(ZTS_CRON_EXP_REMOVE_USERS__c = '0 5 * * * ?');
        insert objCS;
        String Check = GlobalVariablesService.CRON_EXP_REMOVE_USERS;
        String SERVER_URL = GlobalVariablesService.SERVER_URL ;
        GlobalVariablesService.zoetisAppConfig = objCS;
    }
    
}