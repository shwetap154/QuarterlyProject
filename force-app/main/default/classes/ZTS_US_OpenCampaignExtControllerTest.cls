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
 */
@isTest
private class ZTS_US_OpenCampaignExtControllerTest {

    static testMethod void testOpenTargetCampaigns() {
    	ZTS_DataUtilityTest.activateTriggerSettings();
    	Integer rows=10;
    	List<Campaign> campList=ZTS_DataUtilityTest.createCampaignRecord(rows);
    	for(Campaign cmp:campList){
            cmp.ZTS_EU_Market__c = 'United States';
    		if(cmp.ZTS_EU_Field_Targeting__c!='Open'){
    			cmp.ZTS_EU_Field_Targeting__c='Open';
    		}
    		
    	}
    	insert campList;
    	Test.startTest();
    	Pagereference pg=Page.ZTS_US_OpenCampaign;
        pg.getParameters().put('maxrow',String.valueOf(rows));
    	Test.setCurrentPageReference(pg);
    	
        ApexPages.StandardSetController setCon=new ApexPages.Standardsetcontroller(campList);
        ZTS_US_OpenCampaignExtController openCampExtCtrl=new ZTS_US_OpenCampaignExtController(setCon);
        List<Campaign> openCampaignList=openCampExtCtrl.getCampaigns();
        Test.stopTest();
        System.assertEquals(rows,openCampaignList.size());
    }
}