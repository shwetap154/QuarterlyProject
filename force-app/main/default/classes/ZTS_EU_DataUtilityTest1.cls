/*******************************************************************************************************************************************

* Description   :  ZTS_EU_DataUtilityTest1    
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/28         Sunil             Created the Class.

********************************************************************************************************************************************/
@isTest
public without sharing class ZTS_EU_DataUtilityTest1{

    @testVisible static String globalMarket = 'United Kingdom';

    /****************************Insert State County(s)**************************************************************************/
    public static List<State_Country__c> createStateCountryRecord() {
        List<State_Country__c> scList = new List<State_Country__c>();
            State_Country__c sc = new State_Country__c();         
            sc.name = 'County Down';
            sc.ZTS_EU_Country__c = globalMarket;
            sc.ZTS_EU_uniqueCOUNTY__c = 'County Down' + String.valueOf(Datetime.now());
            scList.add(sc);
        return scList;  
              
    }    
    
    /****************************Insert Account(s)**************************************************************************/
    public static List<Account> createAccountRecord(Integer numAcct) {
        List<Account> accList = new List<Account>();
        List<State_Country__c> scList = createStateCountryRecord();
        List<State_Country__c> dupes = [SELECT Id FROM State_Country__c WHERE ZTS_EU_uniqueCOUNTY__c = :scList[0].ZTS_EU_uniqueCOUNTY__c LIMIT 1];
        if (dupes.isEmpty()) 
        {
            insert scList;
        }
        else 
        {
            scList = dupes;    
        }

        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line '+i;
            acc.ZTS_EU_City__c = 'Test City'+i;
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';  
            acc.ZTS_EU_Potential_Region__c = '1';              
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c=globalMarket;
            acc.ZTS_EU_Country__c=globalMarket;
            acc.ZTS_EU_State_County__c=scList[0].Id;
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            accList.add(acc);
        }        
        return accList;  
              
    }
    

    /****************************Insert Contact(s)**************************************************************************/
    public static List<Contact> createContactRecord(Integer numCont) {
        List<Account> accList = createAccountRecord(1);
        insert accList;
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<numCont;i++) {
            Contact con = new Contact();         
            con.lastname = 'Test Contact'+i;  
            con.firstname = 'first name'; 
            con.AccountId = accList[0].Id;    
            con.ZTS_EU_Market__c =globalMarket;
            con.Email = i+'usa123@test.com';
            conList.add(con);
        }        
        return conList;  
           
    }
    /****************************Insert Address(s)**************************************************************************/
    public static List<Address__c> createAddressRecord(Integer numAdd) {
        List<Address__c> addList = new List<Address__c>();
        
        //Insert State County
        State_Country__c sc = new State_Country__c();
        sc.name = 'ABERCONWY';
        sc.ZTS_EU_Country__c = globalMarket;
        insert sc;
        
        for(Integer i=0;i<numAdd;i++) {
            Address__c add = new Address__c();         
            add.name = 'Test Address';
            add.ZTS_EU_State_County__c = sc.id;
            add.Zip_Postal_Code__c = '123456'; 
            addList.add(add);     
        } 
        return addList;      
    }
    /****************************Insert AccountAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Account_Affiliations__c> createAccAffiliationRecord(Integer numAffli) {
      
        
        List<ZTS_EU_Account_Affiliations__c> accAffList = new List<ZTS_EU_Account_Affiliations__c>();
        for(Integer i=0;i<numAffli;i++) {
            ZTS_EU_Account_Affiliations__c accAff = new ZTS_EU_Account_Affiliations__c();       
                 accAff.ZTS_EU_Role__c = 'Sell To';
                 accAff.ZTS_EU_Affiliation_Status__c = 'Active'; 
            accAffList.add(accAff);
        }        
        return accAffList;  
           
    }
    /****************************Insert AccountContactAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Affiliations__c> createAccConAffiliationRecord(Integer numConAffli) {
         List<Account> accList = createAccountRecord(1);
        insert accList;
         List<Contact> contList = createContactRecord(1);
        insert contList;
        List<ZTS_EU_Affiliations__c> accConAffList = new List<ZTS_EU_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c();
            accConAff.ZTS_EU_Account__c = accList[0].Id;
            accConAff.ZTS_EU_Contact__c = contList[0].Id;
            accConAffList.add(accConAff);
        }        
        return accConAffList;             
    }
    
    /****************************Insert KOL Records(s)**************************************************************************/
    public static List<ZTS_EU_KOL__c> createKolRecord(Integer numAdd) {
        List<ZTS_EU_KOL__c> addList = new List<ZTS_EU_KOL__c>();
        Contact con = new Contact();         
        con.lastname = 'Test Contact';
        con.Phone = '123456789';
        con.MobilePhone = '9876454321'; 
        con.ZTS_EU_Market__c=globalMarket;
        insert con;
        ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
        prodSpecies.Name='Test Product';
        prodSpecies.ZTS_EU_Market__c=globalMarket;
        prodSpecies.ZTS_EU_Type__c='Brand';
        prodSpecies.CurrencyIsoCode = 'EUR';
        prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpecies.ZTS_EU_Is_Active__c=true;
        insert prodSpecies;
        for(Integer i=0;i<numAdd;i++) {
            ZTS_EU_KOL__c add = new ZTS_EU_KOL__c();         
            add.ZTS_EU_Contact__c = con.id;
            add.ZTS_EU_Geographic_Influence__c = 'International';
            add.ZTS_EU_Status__c = 'Prime Target KOL'; 
            add.ZTS_EU_Brand__c= prodSpecies.id;
            addList.add(add);     
        } 
        return addList;      
    }
    /******************************Insert ZiptoBrick****************************************************************************/
     public static List<ZTS_GL_ZipToBrick__c> createZipBrickRecord(Integer numZip) {
        List<ZTS_GL_ZipToBrick__c> zipList = new List<ZTS_GL_ZipToBrick__c>();
         for(Integer i=0;i<numZip;i++) {
            ZTS_GL_ZipToBrick__c zipObj = new ZTS_GL_ZipToBrick__c();
            zipObj.Name = 'LD1';
            zipObj.ZTS_EU_ZipCode__c = 'LD'+i;
            zipObj.ZTS_EU_Market__c = globalMarket; 
            zipObj.ZTS_EU_To_Be_Synced__c = true;
            zipList.add(zipObj);
        }  
        return zipList;
     }
     
     /******************************Insert BricktoTerr****************************************************************************/
     public static List<ZTS_GL_BrickToTerr__c> createBrickTerrRecord(Integer numBrick) {
        List<ZTS_GL_BrickToTerr__c> brickList = new List<ZTS_GL_BrickToTerr__c>();
         for(Integer i=0;i<numBrick;i++) {
            ZTS_GL_BrickToTerr__c brickObj = new ZTS_GL_BrickToTerr__c();
            brickObj.Name = 'LD0'+i;
            brickObj.ZTS_EU_To_Be_Synced__c = true;
            brickObj.ZTS_EU_Market__c = globalMarket; 
            brickList.add(brickObj);
        }  
        return brickList;
     }
      /******************************Insert Territory****************************************************************************/
     public static List<ZTS_EU_Territory__c> createTerritory(Integer numTerr) {
        List<ZTS_EU_Territory__c> terrList = new List<ZTS_EU_Territory__c>();
        TerrSyncLogic__c terrsync = new TerrSyncLogic__c();
        terrsync.Name = 'From VF Page';
        insert terrsync;
         for(Integer i=0;i<numTerr;i++) {
            ZTS_EU_Territory__c terrObj = new ZTS_EU_Territory__c();
            terrObj.Name = 'LD01';
            terrObj.ZTS_EU_Need_syncing__c = true;
            terrObj.ZTS_EU_Market__c = globalMarket; 
            terrList.add(terrObj);
        }  
        return terrList;
     }
     /******************************Insert Time Out Off Territory****************************************************************************/
     public static List<Time_Out_of_Territory__c> createToTOffAM(Integer numTerr) { //8/1/2014 - AM
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time Off';
            totObj.ZTS_EU_Reason__c = 'W - Administrative Support';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 8, 1);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 8, 1);
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
            totObj.ownerid = '005L0000000jE35';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTOffPM(Integer numTerr) {  //8/1/2014 - PM
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time Off';
            totObj.ZTS_EU_Reason__c = 'W - Administrative Support';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 8, 1);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 8, 1);
            totObj.ZTS_EU_Duration__c = 'PM = 1 PM to 5 PM';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTOffFull(Integer numTerr) { //8/1/2014 - FULL
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time Off';
            totObj.ZTS_EU_Reason__c = 'W - Administrative Support';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 8, 1);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 8, 1);
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTOFFONFull(Integer numTerr) { //8/1/2014 - FULL
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 7, 1);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 7, 1);
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
            totObj.ownerid = '005L0000000jBio';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONAM(Integer numTerr) { // 7/1/2014 - AM
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 7, 1); 
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 7, 1);
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
            totObj.ownerid = '005L0000000jBio';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONOFFAM(Integer numTerr) { // 8/1/2014 - PM
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 8, 1);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 8, 1); 
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
            totObj.ownerid = '005L0000000jBio';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONFull(Integer numTerr) { //// 7/1/2014 - FULL
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 7, 1);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 7, 1);  
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
            totObj.ownerid = '005L0000000jBio';
            totList.add(totObj);
        }  
        return totList;
     }
 /**********************************Insert User *************************************************/
 public static List<User> createchocheUser(Integer numTerr) { //// 7/1/2014 - FULL
 Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
 User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='deneme1@deneme1.com';
    newuser.lastname='deneme';
    newuser.ZTS_EU_Market__c = globalMarket;
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.EmailEncodingKey='UTF-8';
    usersList.add(newuser);  
        return usersList;
}

/*-------------insert Attendee__c objects---------------*/
    public static List<Attendee__c> createAttendee(Integer counter){ // 6/14
        List<Attendee__c> listAttendee = new List<Attendee__c>();
        List<Contact> contactList = createContactRecord(counter);
        insert contactList;
        Profile p = [select id from profile where name='System Administrator' limit 1];
        User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                   Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                   TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
        insert userRecord;

        List<Account> accountRecord = createAccountRecord(1);
        insert accountRecord;
        
         Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';
            call.ZTS_EU_Call_Owner__c = userRecord.Id;
            insert call;
            
        for(Integer i=0; i< counter; i++){
            Attendee__c attendee = new Attendee__c();
            attendee.ZTS_EU_Contact__c = contactList[i].Id;
            attendee.ZTS_EU_call__c = call.Id;
            listAttendee.add(attendee);
        }
        return listAttendee;
    }
    
    /*-------------insert Colleague objects---------------*/
    public static List<ZTS_EU_Colleague__c> createColleague(Integer counter){ // 6/14
        List<ZTS_EU_Colleague__c> listColleague = new List<ZTS_EU_Colleague__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        string userName = generateRandomUserName(); 
        User u = new User(Alias = 'standt', Email=userName, 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = globalMarket);
        insert u; 
        List<Account> accountRecord = createAccountRecord(1);
        insert accountRecord;
         Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';      
            insert call;
            
        for(Integer i=0; i< counter; i++){
            ZTS_EU_Colleague__c colleague = new ZTS_EU_Colleague__c();
            colleague.ZTS_EU_User__c = u.Id;
            colleague.ZTS_EU_call__c = call.Id;
            listColleague.add(colleague);
        }
        return listColleague;
    }
    
    /****************************Insert Call**************************************************************************/
    public static List<Call__c> createCallRecord(Integer counter) {
    
    Profile p = [select id from profile where name='System Administrator' limit 1];
        User userRecord =  new User(LastName = 'usa123', Email = 'usa123@test.com', Username = 'usa123@test.com', ProfileId = p.Id,Country = 'usa123',
                                   Alias = 'usa123'.substring(0,5), CommunityNickname = 'usa123'.substring(0,5), ZTS_EU_Market__c='Central America',
                                   TimeZoneSidKey='America/Los_Angeles',LocaleSidKey='en_US',EmailEncodingKey='UTF-8',languagelocalekey='en_US');
        insert userRecord;
    
       List<Account> accountRecord = createAccountRecord(1);
       User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = globalMarket;
        insert usr;

        System.runAs(usr){
            insert accountRecord;
        }
        
        List<Call__c> callList = new List<Call__c>();
        for(Integer i=0;i<counter;i++) {
            Call__c call = new Call__c();         
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call'; 
            call.ZTS_EU_Call_Owner__c = userRecord.Id;     
            callList.add(call);
        }        
        return callList;  
           
    }
    /****************************Insert Discussion items*************************************************************************/
    public static List<ZTS_EU_Discussion_Item__c> createDiscussionItemsRecord(Integer counter) {
        
        List<ZTS_EU_Discussion_Item__c> discussionItemList = new List<ZTS_EU_Discussion_Item__c>();
        
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Discussion_Item__c discItem = new ZTS_EU_Discussion_Item__c();
            discItem.ZTS_EU_Active__c=true;
            discItem.ZTS_EU_Description__c = 'Description Text'+i;
            discItem.ZTS_EU_Discussion_Item_Title__c = 'Description Text title';
            discItem.ZTS_EU_Market__c =globalMarket;
            discussionItemList.add(discItem);
        }        
        return discussionItemList;  
           
    }
    /****************************Insert Campaign**************************************************************************/
    public static List<Campaign> createCampaignRecord(Integer counter) {
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0;i<counter;i++) {
            Campaign campaign = new Campaign();         
            campaign.Name = 'TestCampaign'+i;
            campaign.Campaign_Name_English__c = 'TestCampaign'+i;
            campaign.ZTS_EU_Field_Targeting__c = 'Open';
            campaign.IsActive = true;
            campaign.StartDate = System.today();
            campaignList.add(campaign);
        }        
        return campaignList;  
           
    }
    
    /****************************Insert Campaign Member**************************************************************************/
    public static List<CampaignMember> createCampaignMemberRecord(Integer counter) {
        Campaign campaign = new Campaign();         
        campaign.Name = 'TestCampaign';
        campaign.ZTS_EU_Field_Targeting__c = 'Open';
        insert campaign;
        List<Contact> contactList = createContactRecord(counter);
        insert contactList;
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        for(Integer i=0;i<counter;i++) {
            CampaignMember objCampaignMember = new CampaignMember();         
            objCampaignMember.CampaignId = campaign.Id;
            objCampaignMember.ContactId = contactList[0].Id;        
            campaignMemberList.add(objCampaignMember);
        }        
        return campaignMemberList;  
           
    }
    
     public static List<ZTS_EU_Coaching__c> createCoachingRecord(Integer counter) {
        List<ZTS_EU_Coaching__c> coachingRecordList = new List<ZTS_EU_Coaching__c>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
          string userName = generateRandomUserName();  
          User u = new User(Alias = 'standt', Email=userName, 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id,ZTS_EU_isCoacher__c = true,
          TimeZoneSidKey='America/Los_Angeles', UserName=userName,ZTS_EU_Market__c = globalMarket);
          insert u;
          system.runAs(u){
              Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
              totObj.ZTS_EU_Type__c = 'Time On';
              totObj.ZTS_EU_Reason__c = 'Coaching Days';
              totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
              totObj.ZTS_EU_Start_Date__c = Date.newInstance(2014, 7, 1);  
              totObj.ZTS_EU_End_Date__c = Date.newInstance(2014, 7, 5);  
              totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
              totObj.ZTS_EU_Sales_Representative__c = u.Id;
              totObj.ZTS_EU_Status__c ='Submitted';
           //   totObj.ownerid = '005L0000000jBio';
              insert totObj;
         }
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Coaching__c coachingRecord = new ZTS_EU_Coaching__c();         
            coachingRecord.ZTS_EU_Start_Date__c =  Date.newInstance(2014, 7, 3);
            coachingRecord.ZTS_EU_End_Date__c = Date.newInstance(2014, 7, 3);  
            coachingRecord.ZTS_EU_Sales_Rep__c = u.Id;  
            coachingRecordList.add(coachingRecord);
        }        
        return coachingRecordList;  
           
    }
    
      /****************************Insert Change Request records**************************************************************************/
    public static List<ZTS_EU_Request__c> createChangeRequestRecord(Integer counter) {
        List<Account> accountRecord = createAccountRecord(1);
        insert accountRecord;
        List<ZTS_EU_Request__c> changeRequestList = new List<ZTS_EU_Request__c>();
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Request__c cRequest = new ZTS_EU_Request__c();         
            cRequest.ZTS_EU_Account_To_Be_Changed__c = accountRecord[0].Id;
            cRequest.ZTS_EU_Status__c = 'New';
             
            changeRequestList.add(cRequest);
        }        
        return changeRequestList;  
           
    }
    
       /****************************Insert Product Hierarchy Business Unit**************************************************************************/
    public static List<ZTS_EU_Species_Product__c> createProductBURecord(Integer counter) {
        
        List<ZTS_EU_Species_Product__c> productBUList = new List<ZTS_EU_Species_Product__c>();
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
            prodSpecies.Name='BU - Product'+i;
            prodSpecies.ZTS_EU_Market__c=globalMarket;
            prodSpecies.ZTS_EU_Type__c='Business Unit';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_Active__c=true;
            prodSpecies.ZTS_EU_Is_Detailable__c = false;
            productBUList.add(prodSpecies);
        }        
        return productBUList;  
           
    }
    
      /****************************Insert Product Hierarchy TG Group*************************************************************************/
    public static List<ZTS_EU_Species_Product__c> createProductTGRecord(Integer counter) {
        
        List<ZTS_EU_Species_Product__c> productTGList = new List<ZTS_EU_Species_Product__c>();
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
            prodSpecies.Name='TG - Product'+i;
            prodSpecies.ZTS_EU_Market__c=globalMarket;
            prodSpecies.ZTS_EU_Type__c='Therapeutic Group';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_Active__c=true;
            prodSpecies.ZTS_EU_Is_Detailable__c = false;
            productTGList.add(prodSpecies);
        }        
        return productTGList;  
           
    }
     /****************************Insert Product Hierarchy Brand*************************************************************************/
    public static List<ZTS_EU_Species_Product__c> createProductBrandRecord(Integer counter, Boolean createParent) {
        
        List<ZTS_EU_Species_Product__c> prodSpeciesBrand = new List<ZTS_EU_Species_Product__c>();
        List<ZTS_EU_Species_Product__c> prodSpeciesTG;
        if(createParent) {
            prodSpeciesTG = createProductTGRecord(1);
            insert prodSpeciesTG;
        }
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Species_Product__c prodSpecies1= new ZTS_EU_Species_Product__c();
            prodSpecies1.Name='Brand - Product'+i;
            if(createParent) {
                prodSpecies1.ZTS_EU_Parent_Species_Product__c = prodSpeciesTG[0].Id;
            }
            prodSpecies1.ZTS_EU_Market__c=globalMarket;
            prodSpecies1.ZTS_EU_Type__c='Brand';
            prodSpecies1.CurrencyIsoCode = 'EUR';
            prodSpecies1.ZTS_EU_Is_Active__c=true;
            prodSpecies1.ZTS_EU_Is_Detailable__c = true;
            prodSpeciesBrand.add(prodSpecies1);
        }        
        return prodSpeciesBrand;  
           
    }
    
    /****************************Insert Product Hierarchy MPG*************************************************************************/
    public static List<ZTS_EU_Species_Product__c> createProductMPGRecord(Integer counter) {
        List<ZTS_EU_Species_Product__c> prodMPG = new List<ZTS_EU_Species_Product__c>();
        List<ZTS_EU_Species_Product__c> prodSpeciesBrand = createProductBrandRecord(1, true);
        insert prodSpeciesBrand;
        
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Species_Product__c prodSpecies1= new ZTS_EU_Species_Product__c();
            prodSpecies1.Name='MPG - Product'+i;
            prodSpecies1.ZTS_EU_Parent_Species_Product__c = prodSpeciesBrand[0].Id;
            prodSpecies1.ZTS_EU_Market__c=globalMarket;
            prodSpecies1.ZTS_EU_Type__c='MPG';
            prodSpecies1.CurrencyIsoCode = 'EUR';
            prodSpecies1.ZTS_EU_Is_Active__c=true;
            prodSpecies1.ZTS_EU_Is_Detailable__c = true;
            prodMPG.add(prodSpecies1);
        }        
        return prodMPG;  
           
    }
     
    /****************************Insert Product Hierarchy SKU*************************************************************************/
    public static List<ZTS_EU_Species_Product__c> createProductSKURecord(Integer counter) {
        List<ZTS_EU_Species_Product__c> prodSKU = new List<ZTS_EU_Species_Product__c>();
        List<ZTS_EU_Species_Product__c> prodSpeciesMPG = createProductMPGRecord(1);
        insert prodSpeciesMPG;
        
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Species_Product__c prodSpecies1= new ZTS_EU_Species_Product__c();
            prodSpecies1.Name='SKU - Product'+i;
            prodSpecies1.ZTS_EU_Parent_Species_Product__c = prodSpeciesMPG[0].Id;
            prodSpecies1.ZTS_EU_Market__c=globalMarket;
            prodSpecies1.ZTS_EU_Type__c='SKU';
            prodSpecies1.CurrencyIsoCode = 'EUR';
            prodSpecies1.ZTS_EU_Is_Active__c=true;
            prodSKU.add(prodSpecies1);
        }        
        return prodSKU;  
           
    } 
    
     /****************************Insert Species*************************************************************************/
    public static List<ZTS_EU_Species__c> createSpeciesRecord(Integer counter) {
        
        List<ZTS_EU_Species__c> speciesList = new List<ZTS_EU_Species__c>();
        List<ZTS_EU_Species_Product__c> prodSpeciesBU = createProductBURecord(1);
        insert prodSpeciesBU;
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Species__c species1 = new ZTS_EU_Species__c();
            species1.Name='Test Species'+i;
            species1.ZTS_EU_Business_Unit__c = prodSpeciesBU[0].id;
            species1.ZTS_EU_Species__c = 'Test Species'+i;
            species1.CurrencyIsoCode='EUR'; 
            species1.ZTS_EU_Market__c =globalMarket;
            speciesList.add(species1);
        }        
        return speciesList;  
           
    }
    
     /****************************Insert Potential Brand*************************************************************************/
    public static List<ZTS_EU_Potential_Brands__c> createPotentialBrandRecords(Integer counter) {
        List<ZTS_EU_Potential_Brands__c> potBrandsList = new List<ZTS_EU_Potential_Brands__c>();
        List<ZTS_EU_Species__c> speciesList = createSpeciesRecord(counter);
        insert speciesList;
        List<ZTS_EU_Species_Product__c> prodSpeciesBrand = createProductBrandRecord(counter, true);
        insert prodSpeciesBrand;
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Potential_Brands__c potBrand = new ZTS_EU_Potential_Brands__c();
            potBrand.Brand__c = prodSpeciesBrand[i].Id;
            potBrand.Potential__c = speciesList[i].id;
            potBrand.ZTS_EU_Value_Region_1__c = 1;
            potBrand.ZTS_EU_Value_Region_2__c=2; 
            potBrand.ZTS_EU_Value_Region_3__c =3;
            potBrand.ZTS_EU_Value_Region_4__c =4;
            potBrandsList.add(potBrand);
        }        
        return potBrandsList;  
           
    }
    
     /****************************Insert Account Species Potential*************************************************************************/
    public static List<ZTS_EU_Account_Species_Potential__c> createAcctSpeciesPotRecords(Integer counter,String accId) {
        List<ZTS_EU_Account_Species_Potential__c> aspList = new List<ZTS_EU_Account_Species_Potential__c>();
        
        List<ZTS_EU_Potential_Brands__c> potBrandsList = new List<ZTS_EU_Potential_Brands__c>();
        List<ZTS_EU_Species__c> speciesList = createSpeciesRecord(counter);
        insert speciesList;
        List<ZTS_EU_Species_Product__c> prodSpeciesBrand = createProductBrandRecord(counter, true);
        insert prodSpeciesBrand;
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Potential_Brands__c potBrand = new ZTS_EU_Potential_Brands__c();
            potBrand.Brand__c = prodSpeciesBrand[i].Id;
            potBrand.Potential__c = speciesList[i].id;
            potBrand.ZTS_EU_Value_Region_1__c = 1;
            potBrand.ZTS_EU_Value_Region_2__c = 2; 
            potBrand.ZTS_EU_Value_Region_3__c = 3;
            potBrand.ZTS_EU_Value_Region_4__c = 4;
            potBrandsList.add(potBrand);
        }        
        insert potBrandsList;  
        for(Integer i=0;i<counter;i++) {
            ZTS_EU_Account_Species_Potential__c asp = new ZTS_EU_Account_Species_Potential__c();
            asp.ZTS_EU_Animals_Consultations_actual__c = 100;
            asp.ZTS_EU_Animal_Consultations_new__c = 200;
            asp.Account__c = accId;
            asp.ZTS_EU_Species_Potential__c = speciesList[i].id; 
            aspList.add(asp);
        }        
        return aspList;  
        
           
    }
    
    
    //--------------------Insert Account Action Plan records-----------------------
    /*public static List<ZTS_EU_Account_Action_Plan__c> createAAPRecord(Integer numAcct) {
        List<ZTS_EU_Account_Action_Plan__c> aapList = new List<ZTS_EU_Account_Action_Plan__c>();
        
                
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_Account_Action_Plan__c aap = new ZTS_EU_Account_Action_Plan__c();         
            aap.ZTS_EU_Is_Active__c = true;
            aap.ZTS_EU_Start_Date__c = System.today() + 10;
            aap.ZTS_EU_End_Date__c = System.today() - 10;
            aap.ZTS_EU_AAP_Type__c = '1';
            aapList.add(aap);
        }        
        return aapList;  
    }
    
    //-----------------------Insert Account Action Plan Objective records----------------------------
    public static List<ZTS_EU_Account_Action_Plan_Objectives__c> createAAPObjRecord(Integer numAcct, string aapId) {
        List<ZTS_EU_Account_Action_Plan_Objectives__c> aapObjList = new List<ZTS_EU_Account_Action_Plan_Objectives__c>();
        
                
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_Account_Action_Plan_Objectives__c aapObj = new ZTS_EU_Account_Action_Plan_Objectives__c();         
            aapObj.ZTS_EU_Account_Action_Plan__c = aapId;
            aapObj.ZTS_EU_Budget_Amount__c = 10000;
            aapObj.ZTS_EU_Chance_of_Success__c = '1';
            aapObjList.add(aapObj);
        }        
        return aapObjList;  
    }
    
    //-----------------------Insert Account Action Plan Collaborators records-----------------------
    public static List<ZTS_EU_Account_Action_Plan_Collaborator__c> createAAPCollabRecord(Integer numAcct, string aapId, string userId) {
        List<ZTS_EU_Account_Action_Plan_Collaborator__c> aapCollabList = new List<ZTS_EU_Account_Action_Plan_Collaborator__c>();
        
                
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_Account_Action_Plan_Collaborator__c aapCollab = new ZTS_EU_Account_Action_Plan_Collaborator__c();         
            aapCollab.ZTS_EU_Account_Action_Plan__c = aapId;
            aapCollab.ZTS_EU_User__c = userId;
            aapCollabList.add(aapCollab);
        }        
        return aapCollabList;  
    }
    
    //-----------------------Insert Account and Action Plan records-----------------------
    public static List<ZTS_EU_Account_and_Action_Plan__c> createAapAccRecord(Integer numAcct, string aapId, string accId) {
        List<ZTS_EU_Account_and_Action_Plan__c> aapAccList = new List<ZTS_EU_Account_and_Action_Plan__c>();
        
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_Account_and_Action_Plan__c aapAcc = new ZTS_EU_Account_and_Action_Plan__c();         
            aapAcc.ZTS_EU_Account_Action_Plan__c = aapId;
            aapAcc.ZTS_EU_Account__c = accId;
            aapAccList.add(aapAcc);
        }        
        return aapAccList;  
    }
    
    //-----------------------Insert Objective Product Associated records-----------------------
    public static List<ZTS_EU_Objective_Product_Association__c> createAapObjProRecord(Integer numAcct, string aapObjId, string prodId) {
        List<ZTS_EU_Objective_Product_Association__c> aapObjProdList = new List<ZTS_EU_Objective_Product_Association__c>();
        
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_Objective_Product_Association__c aapObjProd = new ZTS_EU_Objective_Product_Association__c();         
            aapObjProd.ZTS_EU_Objective__c = aapObjId;
            aapObjProd.ZTS_EU_Product__c = prodId;
            aapObjProdList.add(aapObjProd);
        }        
        return aapObjProdList;  
    }*/
    
    //-----------------------Insert Gift records-----------------------
    
    public static List<ZTS_EU_Gift__c> createGiftRecord(Integer numAcct, string contactId, string callId, string prodhierarchyId) {
        List<ZTS_EU_Gift__c> giftList = new List<ZTS_EU_Gift__c>();
        
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_Gift__c gft = new ZTS_EU_Gift__c();         
            gft.ZTS_EU_Call__c = callId;
            gft.ZTS_EU_Contact__c = contactId;
            gft.ZTS_EU_Gift_type__c = 'Professional';
            gft.ZTS_EU_Product_Hierarchy__c = prodhierarchyId;
            giftList.add(gft);
        }        
        return giftList;  
    }
    
    //-----------------------Insert Contract Template records-----------------------
    
    public static List<ZTS_EU_ContractTemplate__c> createContractTemplateRecord(Integer numAcct) {
        List<ZTS_EU_ContractTemplate__c> ctList = new List<ZTS_EU_ContractTemplate__c>();
        
        for(Integer i=0;i<numAcct;i++) {
            ZTS_EU_ContractTemplate__c ct = new ZTS_EU_ContractTemplate__c();         
            ct.Name = 'Test template';
            ct.ZTS_EU_Start_Date__c = Date.today();
            ct.ZTS_EU_End_Date__c = date.today()+10;
            ct.ZTS_EU_Discount__c = 20.00;
            ct.ZTS_EU_Discount_Type__c = 'Fixed Discount';
            ct.ZTS_EU_Fiscal_Year__c = '2014';
            ct.ZTS_EU_Status__c = 'Active';
            ct.ZTS_EU_Type__c = 'Bonus';
            ctList.add(ct);
        }        
        return ctList;  
    }
    
    public static string generateRandomUserName() {
        double a=(Math.random() + 1)*10000;
        integer b = a.intValue();
        string c = String.valueOf(b);
        string userName = 'standarduser' + c + '@testorg.com';
        return userName;     
    } 
  
}