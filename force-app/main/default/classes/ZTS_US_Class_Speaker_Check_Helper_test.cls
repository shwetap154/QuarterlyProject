/*******************************************************************************************************************************************
* File Name     :  ZTS_US_Class_Speaker_Check_Helper_test
* Description   :  Test class for ZTS_US_Class_Speaker_Check_Helper
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/15         Mukta Sachdeva       Created the Class.
* 1.1     10/24/2016   Saibal Mondal        Ref US SC-002011 : Added test method TestUpdateSpeakerContactIDsOnEvent
***************************************************************************************************************/


@isTest (Seealldata = false)
public class ZTS_US_Class_Speaker_Check_Helper_test{

  public static testMethod void TestcheckSpeakerRecord(){
    
        test.starttest();
        List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(1);
        Con[0].ZTS_US_Speaker_Flag__c = true;
        Con[0].ZTS_EU_Market__c = 'United States';
        Insert Con;
        ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker;
        List<ZTS_Events__c> Eventspeaker =  ZTS_DataUtilityTest.createEvents(2);
        Eventspeaker[0].ZTS_US_End_Date__c = system.today().addDays(20);
        Eventspeaker[1].ZTS_US_End_Date__c = system.today().addDays(20);
        insert Eventspeaker ;
        ZTS_US_Speaker__c USSpeaker = new  ZTS_US_Speaker__c();
        USSpeaker.ZTS_US_Speaker_Fee__c = 500;
        USSpeaker.ZTS_US_Contact__c=Con[0].id;
        USSpeaker.ZTS_US_Event__c= Eventspeaker[0].id;
        USSpeaker.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker;
        
        
        ZTS_US_Speaker__c USSpeaker1 = new  ZTS_US_Speaker__c();
        USSpeaker1.ZTS_US_Speaker_Fee__c = 500;
        USSpeaker1.ZTS_US_Contact__c=Con[0].id;
        USSpeaker1.ZTS_US_Event__c= Eventspeaker[0].id;
        USSpeaker1.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker1.ZTS_US_Speaking_Date__c = system.today().addDays(2);
        USSpeaker1.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker1;
        
        List<ZTS_US_Speaker__c> recSpeaker = new List<ZTS_US_Speaker__c>();
        recSpeaker.add(USSpeaker);
        Map<ID, ZTS_US_Speaker__c> mapSpeakerID = new Map<ID, ZTS_US_Speaker__c>();
        mapSpeakerID.put(USSpeaker1.id,USSpeaker1);
        USZTS_US_Class_Speaker_Check_Helper.checkSpeakerRecord(recSpeaker,mapSpeakerID);
    
        test.stoptest();
   
      }
  //Added for US SC-002011
  public static testMethod void TestUpdateSpeakerContactIDsOnEvent(){
     ZTS_DataUtilityTest.activateTriggerSettings();
      List<Contact> Con = ZTS_DataUtilityTest.createContactRecord(4);
        Con[0].ZTS_US_Speaker_Flag__c = true;
        Con[0].ZTS_EU_Market__c = 'United States';
        Con[1].ZTS_US_Speaker_Flag__c = true;
        Con[1].ZTS_EU_Market__c = 'United States';
        Con[2].ZTS_US_Speaker_Flag__c = true;
        Con[2].ZTS_EU_Market__c = 'United States';
        Con[3].ZTS_US_Speaker_Flag__c = true;
        Con[3].ZTS_EU_Market__c = 'United States';        
       
        Insert Con;
        ZTS_EU_KOL__c kolSpeaker = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[0].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker;
        ZTS_EU_KOL__c kolSpeaker1 = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[1].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker1;
        ZTS_EU_KOL__c kolSpeaker2 = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[2].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker2;
        ZTS_EU_KOL__c kolSpeaker3 = new ZTS_EU_KOL__c(ZTS_EU_Contact__c = Con[3].id,ZTS_US_Start_Date__c = System.today(),ZTS_US_Role__c = 'Speaker',ZTS_US_Area_of_Expertise__c='Chef');
        insert kolSpeaker3;
       
        List<ZTS_Events__c> event =  ZTS_DataUtilityTest.createEvents(1);
        event[0].ZTS_US_End_Date__c = system.today().addDays(20);
        //event[1].ZTS_US_End_Date__c = system.today().addDays(20);
        insert event ;
       
        List<ZTS_Events__c> outputEvent;
     
        ZTS_US_Speaker__c USSpeaker1 = new  ZTS_US_Speaker__c();
        USSpeaker1.ZTS_US_Speaker_Fee__c = 200;
        USSpeaker1.ZTS_US_Contact__c=Con[0].id;
        USSpeaker1.ZTS_US_Event__c= event[0].id;
        USSpeaker1.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker1.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker1.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker1;   
        List<ZTS_US_Speaker__c> eventSpeakerList = new List<ZTS_US_Speaker__c>([SELECT Id,ZTS_US_Contact__c,ZTS_US_Event__c FROM ZTS_US_Speaker__c WHERE Id =:USSpeaker1.Id]);
                                                                                 
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[0].id, outputEvent[0].Speaker_ID_1__c);

        ZTS_US_Speaker__c USSpeaker2 = new  ZTS_US_Speaker__c();
        USSpeaker2.ZTS_US_Speaker_Fee__c = 300;
        USSpeaker2.ZTS_US_Contact__c=Con[1].id;
        USSpeaker2.ZTS_US_Event__c= event[0].id;
        USSpeaker2.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker2.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker2.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker2;  

        List<ZTS_US_Speaker__c> eventSpeakerList2 = new List<ZTS_US_Speaker__c>([SELECT Id,ZTS_US_Contact__c,ZTS_US_Event__c FROM ZTS_US_Speaker__c WHERE Id =:USSpeaker2.Id]);
      
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[0].id, outputEvent[0].Speaker_ID_1__c);
        //System.assertEquals(Con[1].id, outputEvent[0].Speaker_ID_2__c);

        ZTS_US_Speaker__c USSpeaker3 = new  ZTS_US_Speaker__c();
        USSpeaker3.ZTS_US_Speaker_Fee__c = 400;
        USSpeaker3.ZTS_US_Contact__c=Con[2].id;
        USSpeaker3.ZTS_US_Event__c= event[0].id;
        USSpeaker3.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker3.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker3.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker3;   
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[0].id, outputEvent[0].Speaker_ID_1__c);
        //System.assertEquals(Con[1].id, outputEvent[0].Speaker_ID_2__c);
        //System.assertEquals(Con[2].id, outputEvent[0].Speaker_ID_3__c);

        ZTS_US_Speaker__c USSpeaker4 = new  ZTS_US_Speaker__c();
        USSpeaker4.ZTS_US_Speaker_Fee__c = 500;
        USSpeaker4.ZTS_US_Contact__c=Con[3].id;
        USSpeaker4.ZTS_US_Event__c= event[0].id;
        USSpeaker4.ZTS_US_Speaker_Fee_Type__c = 'Dollars';
        USSpeaker4.ZTS_US_Speaking_Date__c = system.today().addDays(1);
        USSpeaker4.ZTS_US_Therapeutic_Area_Experience__c = '1';
        Insert USSpeaker4; 
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[0].id, outputEvent[0].Speaker_ID_1__c);
       // System.assertEquals(Con[1].id, outputEvent[0].Speaker_ID_2__c);
       // System.assertEquals(Con[2].id, outputEvent[0].Speaker_ID_3__c);

        USSpeaker1.ZTS_US_Speaker_Fee_Type__c = 'Dollar';
        update USSpeaker1;
        //commenting below code as it is not needed
        /*outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[0].id, outputEvent[0].Speaker_ID_1__c);
        System.assertEquals(Con[1].id, outputEvent[0].Speaker_ID_2__c);
        System.assertEquals(Con[2].id, outputEvent[0].Speaker_ID_3__c);
        
        delete USSpeaker1;
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[1].id, outputEvent[0].Speaker_ID_1__c);
        System.assertEquals(Con[2].id, outputEvent[0].Speaker_ID_2__c);
        System.assertEquals(Con[3].id, outputEvent[0].Speaker_ID_3__c);

        delete USSpeaker2;
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[2].id, outputEvent[0].Speaker_ID_1__c);
        System.assertEquals(Con[3].id, outputEvent[0].Speaker_ID_2__c);
        System.assertEquals(null, outputEvent[0].Speaker_ID_3__c);
       
        delete USSpeaker3;
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(Con[3].id, outputEvent[0].Speaker_ID_1__c);
        System.assertEquals(null, outputEvent[0].Speaker_ID_2__c);
        System.assertEquals(null, outputEvent[0].Speaker_ID_3__c);
       
        delete USSpeaker4; 
        outputEvent = new List<ZTS_Events__c>([select id, Speaker_ID_1__c, Speaker_ID_2__c, Speaker_ID_3__c from ZTS_Events__c where id =: event[0].id AND ZTS_EU_Market__c = 'United States']);
        System.assertEquals(null, outputEvent[0].Speaker_ID_1__c);
        System.assertEquals(null, outputEvent[0].Speaker_ID_2__c);
        System.assertEquals(null, outputEvent[0].Speaker_ID_3__c);*/
  }
  }