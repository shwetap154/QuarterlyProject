/*******************************************************************************************************************************************
* File Name     :  ZTS_US_KOL_UpdateContact_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Chandra            Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_US_KOL_UpdateContact_Test 
{   
    public static List <ZTS_EU_KOL__c> kolList= new List<ZTS_EU_KOL__c>();
    public static ZTS_US_KOL_UpdateContact KOLUpContact = new ZTS_US_KOL_UpdateContact();

    public static void createTestData(){
        List<Account> lstacnt = ZTS_DataUtilityTest.createAccountRecord(1);
        lstacnt[0].ZTS_EU_Market__c = 'United States';

        insert lstacnt;
        List<Contact> lstcont = ZTS_EU_DataUtilityTest.createContactRecord(1);
        List<Contact> lstcontins = new List<Contact>();
        for(Contact con : lstcont){
            con.AccountId = lstacnt[0].id;
            con.ZTS_US_Phone_Opt_out__c = True;
            con.HasOptedOutOfEmail = True;
            con.ZTS_EU_Contact_Status__c = 'Active';
            lstcontins.add(con);
        }
        insert lstcontins;
        ZTS_EU_KOL__c kolrecord = new ZTS_EU_KOL__c(ZTS_EU_Contact__c =lstcontins[0].id,ZTS_US_Therapeutic_Class__c='Anesthetic',ZTS_US_Role__c='Influencer');
        kolList.add(kolrecord);
        ZTS_EU_KOL__c kolrecord1 = new ZTS_EU_KOL__c(ZTS_EU_Contact__c =lstcontins[0].id,ZTS_US_Therapeutic_Class__c='Anesthetic',ZTS_US_Role__c='Speaker');
        kolList.add(kolrecord1);   
        insert kolList;

        State_Country__c stateCountry = new State_Country__c();
            stateCountry.Name = 'Madrid';
            stateCountry.ZTS_EU_Country__c = 'Spain';
            insert stateCountry;

        Address__c shipToAddress = new Address__c();
            //shipToAddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Account_Address').getRecordTypeId();
            shipToAddress.Name = 'Evergreen Av. 1234567';
            shipToAddress.ZTS_EU_Account__c =  lstacnt[0].id;
            shipToAddress.ZTS_EU_Address_Type__c = 'Ship To';
            shipToAddress.ZTS_EU_Country__c = 'Spain';
            shipToAddress.ZTS_EU_District__c = 'Madrid';
            shipToAddress.Zip_Postal_Code__c = '1234';
            shipToAddress.ZTS_EU_State_County__c = stateCountry.Id;
            shipToAddress.Ship_Indirect__c = 'N';
            shipToAddress.Is_Active__c = true;
            shipToAddress.ZTS_US_Source_Account_Number__c = '110001';
            shipToAddress.LIS_Number__c = '99999test';

        insert shipToAddress;

        // ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c();
        // accConAff.ZTS_EU_Account__c = lstacnt[0].id;
        // accConAff.ZTS_EU_Contact__c =lstcontins[0].id;

        // insert accConAff;

       // kolList= [SELECT Id from ZTS_EU_KOL__c AND ZTS_EU_Market__c = 'United States' LIMIT 10];
    }
    
    static testMethod void ZTS_US_KOL_UpdateContact_Insert(){
        ZTS_EU_DataUtilityTest.activateTriggerSettings();
        test.startTest();
        
        createTestData();
        KOLUpContact.UpdateKOLandSpeakerFlag(kolList);
        KOLUpContact.KOLUpdates(kolList);
        List<ZTS_EU_KOL__c> kolupdlst = new List<ZTS_EU_KOL__c>();
        for(ZTS_EU_KOL__c kolrec : kolList){
        kolrec.ZTS_US_Therapeutic_Class__c = 'Device';
        kolupdlst.add(kolrec);
        }    
        test.stopTest();
    }

    static testMethod void ZTS_US_KOL_UpdateContact_Update(){
        ZTS_EU_DataUtilityTest.activateTriggerSettings();

        createTestData();
        KOLUpContact.UpdateKOLandSpeakerFlag(kolList);
        KOLUpContact.KOLUpdates(kolList);
        List<ZTS_EU_KOL__c> kolupdlst = new List<ZTS_EU_KOL__c>();
        for(ZTS_EU_KOL__c kolrec : kolList){
        kolrec.ZTS_US_Therapeutic_Class__c = 'Device';
        kolupdlst.add(kolrec);
        }
        test.startTest();
        UtilityService.kolRun = True;
        Update kolupdlst;
    //  KOLUpContact.KOLUpdates(kolupdlst);       
        test.stopTest();
    }
    
    static testMethod void ZTS_US_KOL_updateSendTOLIS(){
        ZTS_EU_DataUtilityTest.activateTriggerSettings();

        createTestData();

        Account acc = [ SELECT Id, Reference_Lab_Customer__c FROM Account ];

        Contact con = [SELECT Id ,Reference_Lab_Contact__c,LIS_NPI__c,LIS_ID__c,ZTS_EU_Market__c,RefLabs_Contact_Email__c,
                       ZTS_US_Profession__c, RefLabs_Results_Email__c, RefLabs_Email_Default__c
                       FROM Contact LIMIT 1];
        con.Reference_Lab_Contact__c = true;
        con.LIS_ID__c = '';
        con.ZTS_EU_Market__c = 'United States';
        con.RefLabs_Contact_Email__c = 'Test@gmail.com';
        con.RefLabs_Results_Email__c = 'Test@gmail.com';
        con.RefLabs_Email_Default__c = true;
        con.ZTS_US_Profession__c = 'Veterinarian';
        con.LIS_NPI__c = ''; 

        Test.startTest();
        ContactTriggerHandler contTriggerHandler = new ContactTriggerHandler();
        DispatchTriggerHandler.setRecursionContexts(contTriggerHandler);
        update con;    
        Test.stopTest();

        System.assert( con.Reference_Lab_Contact__c, 'Ref lab contact flag is TRUE' );
        Contact updatedCon = [SELECT Id, Send_To_LIS__c FROM Contact WHERE RefLabs_Contact_Email__c = :con.RefLabs_Contact_Email__c LIMIT 1];
        System.assert( updatedCon.Send_To_LIS__c, 'SEND TO LIS contact flag is FALSE' );
        delete acc;
    }

    static testMethod void ZTS_US_KOL_UpdateContact_Delete(){
        ZTS_EU_DataUtilityTest.activateTriggerSettings();

        createTestData();
        KOLUpContact.UpdateKOLandSpeakerFlag(kolList);
        KOLUpContact.KOLUpdates(kolList);
        List<ZTS_EU_KOL__c> kolupdlst = new List<ZTS_EU_KOL__c>();
        for(ZTS_EU_KOL__c kolrec : kolList){
        kolrec.ZTS_US_Therapeutic_Class__c = 'Device';
        kolupdlst.add(kolrec);
        }
        test.startTest();
        UtilityService.kolRun = True;
        Delete kolupdlst;
    //  KOLUpContact.KOLUpdates(kolupdlst);       
        test.stopTest();
    }

    static testMethod void ZTS_US_KOL_UpdateContact_Undelete(){
        ZTS_EU_DataUtilityTest.activateTriggerSettings();

        createTestData();
        KOLUpContact.UpdateKOLandSpeakerFlag(kolList);
        KOLUpContact.KOLUpdates(kolList);
        List<ZTS_EU_KOL__c> kolupdlst = new List<ZTS_EU_KOL__c>();
        for(ZTS_EU_KOL__c kolrec : kolList){
            kolrec.ZTS_US_Therapeutic_Class__c = 'Device';
            kolupdlst.add(kolrec);
        }
        test.startTest();
        UtilityService.kolRun = True;
        Delete kolupdlst;
        undelete kolupdlst;
    //  KOLUpContact.KOLUpdates(kolupdlst);       
        test.stopTest();
    }
}