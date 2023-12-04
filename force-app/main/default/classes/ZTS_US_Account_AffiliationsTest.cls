/**
* Name          :   ZTS_GL_Affiliation_ReverseRecordCreaTest .
* Description   :    This is used to test ZTS_US_Account_Affiliations_InsertDuplicateRecord.
* Author        :    Teresa
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
7/16/2014        Teresa                Created
 */
@isTest(seeAllData= false)
public class ZTS_US_Account_AffiliationsTest {
    public static testMethod void testinsertRecord(){
        ZTS_DataUtilityTest.activateTriggerSettings();
        /************************Insert Accounts*******************************************/
        List<Account> accList = ZTS_DataUtilityTest.createAccountRecord(4);
		for (Account a : accList) a.ZTS_EU_Market__c = 'United States';     
        insert accList ;
       /******************Insert Account Affiliation *********************************************/
        List<ZTS_EU_Account_Affiliations__c> affliatedRecord = ZTS_DataUtilityTest.createAccAffiliationRecord(1);
        Map <ID,ZTS_EU_Account_Affiliations__c>  affliationMap = new Map <ID,ZTS_EU_Account_Affiliations__c>();
        List<ZTS_EU_Account_Affiliations__c> affliatedData = new  List<ZTS_EU_Account_Affiliations__c>();
        List<ZTS_EU_Account_Affiliations__c> affliatedUpdate = new  List<ZTS_EU_Account_Affiliations__c>();     
        for(ZTS_EU_Account_Affiliations__c aff  : affliatedRecord){
            aff.ZTS_EU_Account__c = accList[0].id;
            aff.ZTS_EU_Affiliated_Account__c = accList[1].id;
            affliatedData.add(aff);
            
        }
        insert affliatedData;
        affliatedData[0].ZTS_EU_Affiliated_Account__c = accList[2].id;
        update affliatedData;
        delete affliatedData;
        undelete affliatedData;
        
        
    }
}