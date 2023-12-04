/*******************************************************************************************************************************************
* File Name     :  ZTS_US_EduUpdateOnContactTest
* Description   :  Test class for ZTS_US_EduUpdateOnContact
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Akanksha          Created the Class.

***************************************************************************************************************/
@isTest
public class ZTS_US_EduUpdateOnContactTest{
    static testMethod void validate_ZTS_US_EduUpdateOnContact(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
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
        }
    }
    static testMethod void validate_ZTS_US_educationCreationAndUpdateFromContact(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        test.startTest();
        List <Contact> contlist= new List <Contact>();
        contlist=ZTS_DataUtilityTest.createContactRecord(1);
        insert contlist;
        contlist[0].ZTS_US_Institution__c='Auburn University';
        contlist[0].ZTS_US_DVM_Year__c='2007';
        update contlist;
        Map<Id,Contact> mapIdCon= new Map<Id,Contact>();
        mapIdCon.put(contlist[0].Id,contlist[0]);
        ZTS_US_EduCreationAndUpdateFromContact.createEducationRecord(contList);
        ZTS_US_EduCreationAndUpdateFromContact.updateEducationRecord(contList,mapIdCon);
        contList[0].ZTS_EU_Contact_Status__c='Inactive';
        update contList;
        List<ZTS_US_Education_Background__c>  eduList= new List<ZTS_US_Education_Background__c>();
        ZTS_US_Education_Background__c edurec= new ZTS_US_Education_Background__c(ZTS_US_Contact__c=contlist[0].Id,ZTS_US_Type__c='Internship',ZTS_US_Institution__c='Auburn University',ZTS_US_DVM_Year__c='2000');
        insert edurec;
        eduList.add(edurec);
        List<Account> accList=new List<Account>();
        accList=ZTS_DataUtilityTest.createAccountRecord(1,56);
        insert accList;
        ZTS_EU_Affiliations__c aff = new ZTS_EU_Affiliations__c(ZTS_EU_Contact__c = contList[0].Id, ZTS_EU_Account__c = accList[0].Id);
        insert aff;
        List<ZTS_EU_Affiliations__c> aconaffListNew= new List<ZTS_EU_Affiliations__c>();
        aconaffListNew.add(aff);
        ZTS_US_EduCreationAndUpdateFromContact.updateAccConAffInactive(contList);
        test.stoptest();
        }
    }
}