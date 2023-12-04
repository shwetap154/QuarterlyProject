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
 
 * Name          :   ZTS_GL_Affiliation_ReverseRecordCreaTest .
* Description   :    This is used to test ZTS_GL_Affiliation_ReverseRecordCreation.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
7/14/2014       Sunil                       Created
 */
@isTest(seeAllData= false)
public class ZTS_GL_Affiliation_ReverseRecordCreaTest {
	public static testMethod void testinsertRecord(){
		ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

		User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr)
        {
            
            ZTS_GL_Account_Affiliation_Reverse_Roles__c reverseRoles = new ZTS_GL_Account_Affiliation_Reverse_Roles__c();
            reverseRoles.Name = 'Sells to';
            reverseRoles.ZTS_GL_Reverse_Role__c = 'Sells to';
            insert reverseRoles;
            
			ZTS_EU_DataUtilityTest.activateTriggerSettings();
			/************************Insert Accounts*******************************************/
			List<Account> acPrimaryRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
			List<Account> acAffliatedRecord = ZTS_EU_DataUtilityTest.createAccountRecord(1);
			for (Account a : acPrimaryRecord)
			{
				a.ZTS_EU_Zip_Postal_Code__c = '12345';
				a.ZTS_EU_Market__c = 'United States';
				a.BillingPostalCode = '12345';
				a.BillingCity = 'Boca Raton';
				a.BillingState = 'Florida';
				a.BillingStreet = 'Elm Lane';
			}
			for (Account a : acAffliatedRecord)
			{
				a.BillingPostalCode = '12345';
				a.BillingCity = 'Boca Raton';
				a.BillingState = 'Florida';
				a.BillingStreet = 'Elm Lane';
				a.ZTS_EU_Zip_Postal_Code__c = '12345';
				a.ZTS_EU_Market__c = 'United States';
			}
			insert acPrimaryRecord;
			insert acAffliatedRecord;
			
			/*******************Insert Contacts *****************************************************/
			List<Contact> lstcont = ZTS_EU_DataUtilityTest.createContactRecord(2);
			List<Contact> lstcontins = new List<Contact>();
			for(Contact con : lstcont){
			con.AccountId = acPrimaryRecord[0].id;
			con.ZTS_US_Phone_Opt_out__c = True;
			con.HasOptedOutOfEmail = True;
			con.ZTS_EU_Contact_Status__c = 'Active';
			con.ZTS_EU_Market__c = 'United States';
			lstcontins.add(con);
			}
			insert lstcontins;

			Test.startTest();
			/******************Insert Account Affiliation *********************************************/
			List<ZTS_EU_Account_Affiliations__c> affliatedRecord = ZTS_EU_DataUtilityTest.createAccAffiliationRecord(1);
			Map <ID,ZTS_EU_Account_Affiliations__c>  affliationMap = new Map <ID,ZTS_EU_Account_Affiliations__c>();
			List<ZTS_EU_Account_Affiliations__c> affliatedInsert = new 	List<ZTS_EU_Account_Affiliations__c>();
			List<ZTS_EU_Account_Affiliations__c> affliatedUpdate = new 	List<ZTS_EU_Account_Affiliations__c>();		
			for(ZTS_EU_Account_Affiliations__c aff  : affliatedRecord){
				aff.ZTS_EU_Account__c = acPrimaryRecord[0].id;
				aff.ZTS_EU_Affiliated_Account__c = acAffliatedRecord[0].id;
				affliatedInsert.add(aff);
				
			}
			    
            String exc = '';
            try{
            	insert affliatedInsert;    
            }catch(DmlException dex){
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    exc += dex.getDmlMessage(i) + '\n';
            	}
            	exc.removeEnd('\n');
            }
            
            System.assertEquals('', exc, 'The insert should not throw an error');
            
            
			
			List<ZTS_EU_Account_Affiliations__c> affiObjList = [select id,ZTS_EU_Related_record_ID__c from ZTS_EU_Account_Affiliations__c where ZTS_EU_Related_record_ID__c = : affliatedInsert[0].id AND ZTS_EU_Market_from_Primary_Account__c = 'United States' ];
			
			if(affiObjList.size()>0){
				affiObjList[0].ZTS_EU_Account_Influence__c = 'Medium';
				system.debug('Related ID********>'+affiObjList[0].ZTS_EU_Related_record_ID__c);
				ZTS_EU_Account_Affiliations__c affObj = new ZTS_EU_Account_Affiliations__c(id= affliatedInsert[0].id);
				affliationMap.put(affliatedInsert[0].id,affObj);
				ZTS_GL_Affiliation_ReverseRecordCreation affRevObj = new ZTS_GL_Affiliation_ReverseRecordCreation();
                affliatedInsert[0].ZTS_EU_Affiliated_Account__c = null;
				affRevObj.insertRecord(affliatedInsert, affliationMap);
				
				/********************Delete Account Affiliation ***************************************************/
				for(ZTS_EU_Account_Affiliations__c af : affliatedInsert){
					ZTS_EU_Account_Affiliations__c afObj = new ZTS_EU_Account_Affiliations__c(id = af.id);
					afObj.ZTS_EU_Account_Influence__c = 'Low';
					affliatedUpdate.add(afObj);
				}
				//update affliatedUpdate;
				affiObjList[0].ZTS_US_Role__c = 'Sells to';
				update affiObjList[0];
				Test.stopTest();
				List<ZTS_EU_Account_Affiliations__c> expectedAccAffList = [SELECT Id, ZTS_EU_Account_Influence__c FROM ZTS_EU_Account_Affiliations__c WHERE Id = :affiObjList[0].Id ];
				System.assertEquals('Medium',expectedAccAffList[0].ZTS_EU_Account_Influence__c , 'The ZTS_EU_Account_Influence__c should be updated to Medium');
				affRevObj.undeleteAccountRecord(affliatedInsert);
				//delete affliatedInsert;
                affRevObj.updateAccountRecord(affliatedInsert, affliatedUpdate, affliationMap, affliationMap);
                
			}
				
		}
	}
}