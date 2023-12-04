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

* Name          :   ZTS_US_AccountUpdatefromEducationTest .
* Description   :    This is used to test ZTS_US_AccountUpdatefromEducation.
* Author        :    Sunil

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
7/14/2014       Sunil                       Created
*/
@isTest
public class ZTS_US_AccountUpdatefromEducationTest {
      public static testMethod void testEducationRecord(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr){
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            //
            List<ZTS_US_Education_Background__c> eBList = ZTS_DataUtilityTest.createEduBackgroundRecord(3); 
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(1);
            insert contList;
            List<ZTS_US_Education_Background__c>  eduList= new List<ZTS_US_Education_Background__c>();
            ZTS_US_Education_Background__c edurec= new ZTS_US_Education_Background__c(ZTS_US_Contact__c=contList[0].Id,ZTS_US_Type__c='DVM',ZTS_US_Institution__c='Auburn University',ZTS_US_DVM_Year__c='2000');
            eduList.add(edurec);
            Map<Id,ZTS_US_Education_Background__c> eduMapOld=new Map<Id,ZTS_US_Education_Background__c>();
            eduMapOld.put(eduList[0].Id,eduList[0]);
            ZTS_US_EduUpdateOnContact.updateConOnEduCreation(eduList,eduMapOld);
            List<ZTS_US_Education_Background__c>  eduListnew= new List<ZTS_US_Education_Background__c>();
            ZTS_US_Education_Background__c edurecnew= new ZTS_US_Education_Background__c(ZTS_US_Contact__c=contList[0].Id,ZTS_US_Type__c='DVM',ZTS_US_Institution__c='Purdue University',ZTS_US_DVM_Year__c='2001');
            eduListnew.add(edurecnew);
            Map<Id,ZTS_US_Education_Background__c> eduMapNew=new Map<Id,ZTS_US_Education_Background__c>();
            eduMapNew.put(eduListnew[0].Id,eduListnew[0]);
            ZTS_US_EduUpdateOnContact.updateConOnEduModification(eduListnew,eduMapOld,eduMapNew);
            ZTS_US_EduUpdateOnContact.updateConOnEduDeletion(eduList,eduMapOld);
            Test.startTest();
            insert eBList;      
            Test.stopTest();
        }
    }
    
    public static testMethod void testEducationUpdateRecord(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr){
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

            List<ZTS_US_Education_Background__c> eBList1 = ZTS_DataUtilityTest.createEduBackgroundRecord(2);
            List<ZTS_US_Education_Background__c> eBListUpdate = new List<ZTS_US_Education_Background__c>();
            insert eBList1;
            for(ZTS_US_Education_Background__c eb : eBList1){
                eb.ZTS_US_Institution__c = 'Cornell University';
                eBListUpdate.add(eb);
                
            }
            Test.startTest();
            update eBListUpdate;
            delete eBListUpdate;
            Test.stopTest();
        }
        
    }
    
    @isTest static void prodValidationTest() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        
    
        System.runAs(usr){

            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            List <Contact> contList= new List <Contact>();
            contList=ZTS_DataUtilityTest.createContactRecord(1);
            contList[0].ZTS_EU_Market__c = 'United States';
            insert contList;
            
            
            ZTS_US_Education_Background__c edurec1= new ZTS_US_Education_Background__c(ZTS_US_Contact__c=contList[0].Id,ZTS_US_Type__c='DVM',ZTS_US_Institution__c='Auburn University',ZTS_US_DVM_Year__c='20001');
            insert edurec1;
            
            Test.startTest();
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            List<ZTS_US_Education_Background__c>  eduList= new List<ZTS_US_Education_Background__c>();
            ZTS_US_Education_Background__c edurec= new ZTS_US_Education_Background__c(ZTS_US_Contact__c=contList[0].Id,ZTS_US_Type__c='DVM',ZTS_US_Institution__c='Auburn University2',ZTS_US_DVM_Year__c='2000');
            eduList.add(edurec);
            
            String errorMessage = '';
            try{
                insert eduList;
            }catch(DmlException ex){
                errorMessage = ex.getMessage();
            }

            System.assertNotEquals('', errorMessage, 'The insert should throw a duplicate record error');

            update edurec1;
            delete edurec1;
            undelete edurec1;
            
            Test.stopTest();
        }
    }
}