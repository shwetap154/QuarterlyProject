/**
 * @description       : Unit Test class for ZTS_US_AddSpeakercontroller.
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2014   Unknown                     Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Fix validation errors with creating Contacts
**/
@istest(seeAllData=false)
public class Test_ZTS_US_AddSpeakercontroller {

    public static ZTS_Events__c EVE;
    public static ZTS_US_Speaker__c Speaker ;
    
    public static void createdata(){
    

           State_Country__c Cont = new State_Country__c();
            Cont.ZTS_EU_Country__c ='Spain';
            Cont.ZTS_EU_uniqueCOUNTY__c = '!@#ADSFD';
            Insert Cont;
            Contact con = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            con.firstname='Test First';
            con.lastname = 'Test Contact'; 
            con.ZTS_EU_Speaker_Flag__c=true;
            con.ZTS_EU_Market__c= '';
            con.ZTS_EU_Country__c ='Spain';
            con.ZTS_EU_State_County__c = Cont.id;
            insert con;

            ZTS_EU_KOL__c prof = new ZTS_EU_KOL__c();
            prof.ZTS_EU_Contact__c = con.Id;
            prof.ZTS_US_Start_Date__c = System.today() - 1;
            prof.ZTS_US_Role__c = 'Speaker';
            insert prof;
            
            EVE= new ZTS_Events__c();
            EVE.ZTS_US_Name__c = 'Name';
            //EVE.ZTS_US_Purpose_Agenda__c = 'Agenda';
            EVE.Purpose_Agenda__c = 'Agenda';
            EVE.ZTS_US_Event_Category__c ='CPAC';
            EVE.ZTS_US_Location__c ='US';    
            EVE.ZTS_US_Type__c = 'Type';
            EVE.ZTS_US_Number_of_Attendees__c  = 12;
            EVE.ZTS_US_Status__c = 'New';
            insert EVE;
            
            
            Speaker = new ZTS_US_Speaker__c();
            Speaker.ZTS_US_Contact__c = con.id;
            Speaker.ZTS_US_Event__c= EVE.id;
            Speaker.ZTS_US_Overall_Presentation__c='1';
            Speaker.ZTS_US_Product_Knowledge__c = '1';
            Speaker.ZTS_US_Speaker_Fee__c = 100;
            Speaker.ZTS_US_Speaker_Fee_Type__c ='Dollar';
            Speaker.ZTS_US_Therapeutic_Area_Experience__c = '1';
            Speaker.ZTS_US_would_you_recommend_the_speaker__c = '1';
            Speaker.ZTS_US_Speaking_Date__c = system.today();
            
            insert Speaker;
    }


    @isTest
    public static void Test_ZTS_US_AddSpeakercontroller (){
        
        test.starttest();
        createdata();
        PageReference pgRef = Page.ZTS_US_AddSpeaker;         
        Test.setCurrentPageReference(pgRef);
        ApexPages.currentPage().getParameters().put('id',EVE.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(Speaker);   
        ZTS_US_AddSpeakercontroller AddSpeaker= new ZTS_US_AddSpeakercontroller(sc);
        AddSpeaker.selectedSpeakerVal = '$12.12';
        PageReference P = AddSpeaker.save();
        
        Test.stoptest();
    
    }
    
      @isTest
      public static void Test_Save (){
        
          test.starttest();
        createdata();
        PageReference pgRef = Page.ZTS_US_AddSpeaker;         
        Test.setCurrentPageReference(pgRef);
        ApexPages.currentPage().getParameters().put('id',EVE.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(Speaker);   
        ZTS_US_AddSpeakercontroller AddSpeaker= new ZTS_US_AddSpeakercontroller(sc);
        AddSpeaker.selectedSpeakerVal = '';
        PageReference P = AddSpeaker.save();
        
        Test.stoptest();
    
    }
    
    
      @isTest
      public static void Test_Save_Function (){
        
          test.starttest();
        createdata();
        PageReference pgRef = Page.ZTS_US_AddSpeaker;         
        Test.setCurrentPageReference(pgRef);
        ApexPages.currentPage().getParameters().put('id',EVE.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(Speaker);   
        ZTS_US_AddSpeakercontroller AddSpeaker= new ZTS_US_AddSpeakercontroller(sc);
        AddSpeaker.selectedSpeakerVal = 'None';
        AddSpeaker.selectedFeeType ='';
        AddSpeaker.selectedSpeakerFee ='';
        PageReference P = AddSpeaker.save();
        Test.stoptest();
    
    }
    
}