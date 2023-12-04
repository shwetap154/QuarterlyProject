/**
 * @description       : Common Test Utils
 * @author            : Deloitte consulting
 * @group             : 
 * @last modified on  : 06-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   04-28        Sunil @ Deloitte Consulting  Created the class
 * 1.1   10-15        Ilirjana Ame @ Cloudsense    Modified the Class
 * 1.1   02-03        Ilirjana Ame @ Cloudsense    Modified the Class
 * 1.1   02-23-2017   Tanmoy(Cognizant)            Modified the Method createAddressRecord
 * 1.2   06-07-2022   Ethan Hirsch @ Zoetis Inc    Changed createToTONAM createToTONFULL, createToTONOFFAM, and 
                                                   createToTOFFONFULL methods to use GER and CE Euro Business Administrator profile
                                                   instead of ZTS PL Business Administrator.
                                                   Assuming PL stood for Poland and based on Users with PL Roles, GER and CE 
                                                   appears to have replaced PL.
                                                   Also change file header to not use = sign due to copado issues.
                                                   Moved creation of User in createHoliday to occur after exclusions so no error occurs
                                                   Changed references to ZTS_Global HelpDesk and Marketo-Salesforce Sync Profiles 
                                                   to not include special characters to avoid Copado issues
 * 1.3   07-07-2022   Ethan Hirsch @ Zoetis Inc    Changed createToTOFFONPM to use ZTS UK Business Administrator instead 
 *                                                 of the ZTS PL Business Administrator Profile.
 * 1.4   07-25-2022   Ethan Hirsch @ Zoetis Inc    Add new createUserWithProfile to create Users with a passed in Profile Id.
 *                                                 Add createColleague, createAccountAffiliationReverseRolesSetting and createAttendees methods.
**/
@isTest
public class ZTS_EU_DataUtilityTest{
    
    public static Map < String, ZTS_GL_Account_Affiliation_Reverse_Roles__c > customSettingAcc = ZTS_GL_Account_Affiliation_Reverse_Roles__c.getAll();
    /****************************Insert State County(s)**************************************************************************/
    public static List<State_Country__c> createStateCountryRecord() {
        List<State_Country__c> scList = new List<State_Country__c>();
            State_Country__c sc = new State_Country__c();         
            sc.name = 'County Down';
            sc.ZTS_EU_Country__c = 'United Kingdom';
            sc.ZTS_EU_uniqueCOUNTY__c = 'County Down';
            scList.add(sc);
        return scList;  
              
    }    
    
    /****************************Insert State County(s) with Parameters**************************************************************************/
    /* Author : Shefali , Date : 8/10/2014 */
   public static State_Country__c createStateCountryRecordPara(String state , String country) {
            State_Country__c sc = new State_Country__c();         
            sc.name = state;
            sc.ZTS_EU_Country__c = country;
            sc.ZTS_EU_uniqueCOUNTY__c = state;
        return sc;  
              
    }
    
    /****************************Insert Account(s)**************************************************************************/
    public static List<Account> createAccountRecord(Integer numAcct,Integer uniquenarid) {
        List<Account> accList = new List<Account>();
                
        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.ZTS_US_Business_Class__c = 'Sub-Class 1';
            acc.ZTS_EU_Country__c = 'United States';
            acc.BillingCity = 'Test City'+i;
            acc.ZTS_US_State_Province__c  = 'Ohio';
            acc.BillingStreet = 'Test Street'+i;  
            acc.ZTS_US_NARC_ID__c='NC'+(100*uniquenarid)+i;
            accList.add(acc);
        }    
        return accList;  
    }
    
    public static List<Account> createAccountRecord(Integer numAcct) {
        List<Account> accList = new List<Account>();
        State_Country__c sc = createStateCountryRecordPara('Test State', 'Brazil');
                
        for(Integer i=0;i<numAcct;i++) {
            Account acc = new Account();         
            acc.name = 'Test Account'+i;
            acc.Type = 'Farm';
            acc.ZTS_EU_Sub_Type__c = 'Beef';
            acc.ZTS_EU_Address_Line_1__c = 'Test Address Line '+i;
            acc.ZTS_EU_Address_Line_2__c = 'Test Address Line2 '+i;
            acc.ZTS_EU_City__c = 'Test City'+i;
            acc.ZTS_EU_Zip_Postal_Code__c = 'LD'+i;                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc.ZTS_EU_Main_Phone__c='9876789876';
            acc.CurrencyIsoCode='EUR';
            acc.ZTS_EU_Market__c='United Kingdom';
            acc.Practice_Management_Software__c = 'Other';
            acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc.ZTS_EU_Vetsave_ID__c='200';
            acc.ZTS_EU_Vetsave_HO_ID__c='56';
            acc.ZTS_EU_Country__c = 'Brazil';
            acc.ZTS_EU_State_County__c = sc.Id;
            acc.ZTS_EU_VAT_Code__c = 'VAT-'+i;
            accList.add(acc);
        }  
        //insert accList;      
        return accList;  
              
    }
    /****************************Insert Contact(s)**************************************************************************/
    public static List<Contact> createContactRecord(Integer numCont) {
    
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<numCont;i++) {
            Contact con = new Contact(); 
            con.firstname='Test First'+i;
            con.lastname = 'Test Contact'+i; 
            con.ZTS_US_Profession__c='Executive Leadership';
            con.ZTS_US_Job_Function__c='CEO/President';
            con.ZTS_EU_Speaker_Flag__c=true;
            
            conList.add(con);
        }        
        return conList;  
           
    }
    /****************************Insert Address(s)**************************************************************************/
    public static List<Address__c> createAddressRecord(Integer numAdd) {
        List<Address__c> addList = new List<Address__c>();
        
        //Insert State County
        State_Country__c sc = new State_Country__c();
        sc.name = 'Aberdeen';
        sc.ZTS_EU_Country__c = 'United Kingdom';
        insert sc;
        State_Country__c sc1 = new State_Country__c(); //Added by Tanmoy(Cognizant)
        sc1.name = 'Test State Country';
        sc1.ZTS_EU_Parent_State_Country__c = sc.Id;
        Insert sc1;
        
         Account acc1 = new Account();         
            acc1.name = 'Test Account';
            acc1.Type = 'Farm';
            acc1.ZTS_EU_Sub_Type__c = 'Beef';
            acc1.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc1.ZTS_EU_City__c = 'Test City';
            acc1.ZTS_EU_Zip_Postal_Code__c = 'LD';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc1.ZTS_EU_Main_Phone__c='9876789876';
            acc1.CurrencyIsoCode='EUR';
            acc1.ZTS_EU_Market__c='United Kingdom';
            acc1.Practice_Management_Software__c = 'Other';
            acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc1.ZTS_EU_Vetsave_ID__c='200';
            acc1.ZTS_EU_Vetsave_HO_ID__c='56';
            insert acc1;
        
        for(Integer i=0;i<numAdd;i++) {
            Address__c add = new Address__c();         
            add.name = 'Test Address';
            add.ZTS_EU_Country__c = 'United Kingdom';
            add.ZTS_EU_State_County__c = sc.id;
            add.Zip_Postal_Code__c = '123456';
            add.ZTS_EU_District__c = 'Test_District';
            add.ZTS_EU_Commune_Lookup__c = sc1.Id; //Added by Tanmoy(Cognizant)
            //add.ZTS_EU_Account__c = acc1.Id;
            addList.add(add);     
        } 
        
        
        return addList;      
    }
    
      public static List<Address__c> createAddressRecorddup(Integer numAdd) {
        List<Address__c> addList1 = new List<Address__c>();
        
        //Insert State County
        State_Country__c sc1 = new State_Country__c();
        sc1.name = 'ABERCONWY';
        sc1.ZTS_EU_Country__c = 'United Kingdom';
        insert sc1;
        
         Account acc1 = new Account();         
            acc1.name = 'Test Account';
            acc1.Type = 'Farm';
            acc1.ZTS_EU_Sub_Type__c = 'Beef';
            acc1.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
            acc1.ZTS_EU_City__c = 'Test City';
            acc1.ZTS_EU_Zip_Postal_Code__c = 'LD';                
           // acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ZTS_EU_Activated_Account').getRecordTypeId();
            acc1.ZTS_EU_Main_Phone__c='9876789876';
            acc1.CurrencyIsoCode='EUR';
            acc1.ZTS_EU_Market__c='United Kingdom';
            acc1.Practice_Management_Software__c = 'Other';
            acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc1.ZTS_EU_Vetsave_ID__c='200';
            acc1.ZTS_EU_Vetsave_HO_ID__c='56';
            insert acc1;
            
        for(Integer i=0;i<numAdd;i++) {
            Address__c add1 = new Address__c();         
            add1.name = 'Test Address';
            add1.ZTS_EU_Country__c = 'United Kingdom';
            add1.ZTS_EU_State_County__c = sc1.id;
            add1.Zip_Postal_Code__c = '2343'; 
            //add1.ZTS_EU_Account__c = acc1.Id;
            addList1.add(add1);     
        } 
        return addList1;      
    }
    /****************************Insert AccountAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Account_Affiliations__c> createAccAffiliationRecord(Integer numAffli) {
    
        List<ZTS_EU_Account_Affiliations__c> accAffList = new List<ZTS_EU_Account_Affiliations__c>();
        for(Integer i=0;i<numAffli;i++) {
            ZTS_EU_Account_Affiliations__c accAff = new ZTS_EU_Account_Affiliations__c();       
                 accAff.ZTS_EU_Role__c = 'Corporate';
               // accAff.ZTS_GL_Reverse_Role__c = 'Corporate Member';
                 accAff.ZTS_EU_Affiliation_Status__c = 'Active'; 
            accAffList.add(accAff);
        }        
        return accAffList;  
           
    }
    /****************************Insert AccountContactAffiliation(s)**************************************************************************/
    public static List<ZTS_EU_Affiliations__c> createAccConAffiliationRecord(Integer numConAffli) {
    
        List<ZTS_EU_Affiliations__c> accConAffList = new List<ZTS_EU_Affiliations__c>();
        for(Integer i=0;i<numConAffli;i++) {
            ZTS_EU_Affiliations__c accConAff = new ZTS_EU_Affiliations__c();
               
            accConAffList.add(accConAff);
        }        
        return accConAffList;             
    }
    
    /****************************Insert KOL Records(s)**************************************************************************/
    public static List<ZTS_EU_KOL__c> createKolRecord(Integer numAdd) {
        List<ZTS_EU_KOL__c> addList = new List<ZTS_EU_KOL__c>();
        Contact con = new Contact();
        con.firstname='Test First';          
        con.lastname = 'Test Contact';
        con.Phone = '123456789';
        con.MobilePhone = '9876454321'; 
        con.ZTS_EU_Market__c='United Kingdom';
        insert con;
        ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
        prodSpecies.Name='Test Product';
        prodSpecies.ZTS_EU_Market__c='United Kingdom';
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
            zipObj.ZTS_EU_Market__c = 'United Kingdom'; 
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
            brickObj.ZTS_EU_Market__c = 'United Kingdom'; 
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
            terrObj.ZTS_EU_Market__c = 'United Kingdom'; 
            terrObj.ZTS_EU_Terr_SFID__c = '0MI4z000000Ch2FGAS'; // this is a dummy Id and does not necessarily exist in the org
           
            terrList.add(terrObj);
        }  
        return terrList;
     }
     
      /******************************Insert Std Territory****************************************************************************/
    /* 
    public static List<Territory> createStdTerritory(Integer numTerr) {
        List<Territory> terrList = new List<Territory>();
         for(Integer i=0;i<numTerr;i++) {
            Territory terrObj = new Territory();
            terrObj.Description = 'LD01';
            terrObj.CaseAccessLevel = 'Edit';
            terrObj.AccountAccessLevel = 'Edit'; 
            terrObj.Name = 'Testterr';
            terrList.add(terrObj);
        }  
        return terrList;
     }
     */
     /******************************Insert Time Out Off Territory****************************************************************************/
     public static List<Time_Out_of_Territory__c> createToTOffAM(Integer numTerr) { //8/1/2014 - AM
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time Off';
            totObj.ZTS_EU_Reason__c = 'W - Administrative Support';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 7);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 7);
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
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
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 9);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 9);
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
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 8);
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 8);
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            totObj.ZTS_EU_Status__c = 'Accepted';
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONAM(Integer numTerr) { // 7/1/2014 - AM
          Profile profiles=[Select Id From Profile Where Name='GER and CE Euro Business Administrator'];
        List<User> usercoachList = new List<User>();
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='PLBusineAdmin@bisadmin.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;    
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    usercoachList.add(newuser);  
        insert usercoachList;
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6); 
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
            totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONFULL(Integer numTerr) { // 7/1/2014 - AM
          Profile profiles=[Select Id From Profile Where Name='GER and CE Euro Business Administrator'];
        List<User> usercoachList = new List<User>();
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='PLBusineAdmin@bisadmin.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;    
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    usercoachList.add(newuser);  
        insert usercoachList;
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6); 
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
            totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONPM(Integer numTerr) { // 7/1/2014 - AM
          Profile profiles=[Select Id From Profile Where Name='ZTS PL Business Administrator'];
        List<User> usercoachList = new List<User>();
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='PLBusineAdmin@bisadmin.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;    
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    usercoachList.add(newuser);  
        insert usercoachList;
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6); 
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);
            totObj.ZTS_EU_Duration__c = 'PM = 1 PM to 5 PM';
            totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTONOFFAM(Integer numTerr) { // 8/1/2014 - PM
     Profile profiles=[Select Id From Profile Where Name='GER and CE Euro Business Administrator'];
        List<User> usercoachList = new List<User>();
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='PLBusAdmin@bs.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;    
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    usercoachList.add(newuser);  
        insert usercoachList;        
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6); 
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
            totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     
     public static List<Time_Out_of_Territory__c> createToTOFFONFULL(Integer numTerr) { //// 7/1/2014 - FULL
        Profile profiles=[Select Id From Profile Where Name='GER and CE Euro Business Administrator'];
        List<User> usercoachList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='deneme@deneme.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        usercoachList.add(newuser);  
            insert usercoachList;
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
//            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
           totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTOFFONAM(Integer numTerr) { //// 7/1/2014 - FULL
        Profile profiles=[Select Id From Profile Where Name='ZTS PL Business Administrator'];
        List<User> usercoachList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='deneme@deneme.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        usercoachList.add(newuser);  
            insert usercoachList;
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_Duration__c = 'AM = 9 AM to 1 PM';
//            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
           totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTOFFONPM(Integer numTerr) { //// 7/1/2014 - FULL
        Profile profiles=[Select Id From Profile Where Name='ZTS UK Business Administrator'];
        List<User> usercoachList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='deneme@deneme.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        usercoachList.add(newuser);  
            insert usercoachList;
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time On';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_Duration__c = 'PM = 1 PM to 5 PM';
//            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
           totObj.ownerid = usercoachList[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
     public static List<Time_Out_of_Territory__c> createToTCallOnOff(Integer numTerr) { //// 7/1/2014 - FULL
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = 'Time Off';
            totObj.ZTS_EU_Reason__c = 'Coaching Days';
            totObj.ZTS_EU_Coaching_Day_Sub_Type__c = 'Clarify Customer Needs';
            totObj.ZTS_EU_Start_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_End_Date__c = Date.newInstance(2017, 4, 6);  
            totObj.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
//            totObj.ZTS_EU_Sales_Representative__c = '005L0000000jE35';
//           totObj.ownerid = userscoacheeList[0].id[0].id;
            totList.add(totObj);
        }  
        return totList;
     }
 /**********************************Insert User *************************************************/
 public static List<User> createrepToTUser() {
 Profile profiles=[Select Id From Profile Where Name='ZTS PL Field Based Function'];
        List<User> userprodPLBAcoachList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='EUPLBusinessAdminTestDUPLICATE@bisadmintest.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        userprodPLBAcoachList.add(newuser);  
        return userprodPLBAcoachList;
 }
  public static List<User> createcoachToTUser() {
 Profile profiles=[Select Id From Profile Where Name='ZTS PL Business Administrator'];
        List<User> userprodPLBAcoachList = new List<User>();
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='EUPLBusinessAdminTestDUPLICATE@bisadmintest.com';
        newuser.username= 'z' + string.valueof(math.random())+'@ZEUAFMETEST.com';
        newuser.lastname='deneme';
        newuser.alias='deneme1';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';
        newuser.ZTS_EU_isCoacher__c=TRUE;    
        newuser.ZTS_EU_Market__c='United Kingdom';
        newuser.EmailEncodingKey='ISO-8859-1';
        userprodPLBAcoachList.add(newuser);  
        return userprodPLBAcoachList;
 }
 public static List<User> createcoacherUser() { //// 7/1/2014 - FULL
 Profile profiles=[Select Id From Profile Where Name='System Administrator'];
        List<User> usersList = new List<User>();
    User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='deneme@deneme.com';
    newuser.username='deneme1@deneme1.com';
    newuser.lastname='deneme';
    newuser.alias='deneme1';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';
    newuser.ZTS_EU_isCoacher__c=TRUE;    
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    usersList.add(newuser);  
        return usersList;
}
public static List<User> createcoacheeUser() { //// 7/1/2014 - FULL
 Profile profiles=[Select Id From Profile Where Name='ZTS PL Business Administrator'];
        List<User> usersList = new List<User>();
 User newuser=new User();
    newuser.profileid=profiles.Id;
    newuser.email='chandra@deneme.com';
    newuser.username='chandra@deneme1.com';
    newuser.lastname='chandra';
    newuser.alias='chandra';
    newuser.languagelocalekey='en_US';
    newuser.localesidkey='en_US';
    newuser.timezonesidkey='America/Los_Angeles';
    newuser.localesidkey='en_US';  
    newuser.ZTS_EU_Market__c='United Kingdom';
    newuser.EmailEncodingKey='ISO-8859-1';
    usersList.add(newuser);  
        return usersList;
}
/*
public static AccountTerritoryAssignmentRule createAccountTerrAssignmentRule(String stdTerrId){
    AccountTerritoryAssignmentRule atsr=new AccountTerritoryAssignmentRule(TerritoryId=stdTerrId,Name='Test_Assignment_sample',IsActive=true,Id='041c00000004IpAAAU');
    return atsr;
    
}
*/
public static List<ZTS_EU_Discussion__c> createDiscussions(Integer numDisc){
    List<ZTS_EU_Discussion__c> l_discussion = new List<ZTS_EU_Discussion__c>();
    for(Integer i=0;i<numDisc;i++) {
        ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c();
        discussion.Name = 'test';
        l_discussion.add(discussion);
    }
    return l_discussion;
}

    /*-------------insert ZTS_Events__c objects---------------*/
    public static List < ZTS_Events__c > createEvents(Integer counter) {
        List < ZTS_Events__c > listEvents1 = new List < ZTS_Events__c > ();
            for (Integer i = 0; i < counter; i++) {
                ZTS_Events__c event = new ZTS_Events__c();
                event.ZTS_US_Will_Firearms_be_Present__c = true;
                event.ZTS_US_Type__c = 'Cattle General';
                event.ZTS_US_Status__c = 'New';
                event.ZTS_US_Start_Date__c = system.now();
                event.ZTS_US_Is_Event_Private__c = false;
                event.ZTS_US_Name__c = 'Test Event' + i;
                //event.ZTS_US_End_Date__c = system.today().addDays(i);
                event.ZTS_US_End_Date__c = system.now().addDays(i);
                event.ZTS_US_Compliance_Status__c = 'Acceptable';
                event.ZTS_US_Event_Category__c = 'Educational Meeting';
                event.ZTS_US_Location__c = 'Test street, Test Town, Test Country';
                event.ZTS_US_Number_of_Attendees__c = i + 2;
               // event.ZTS_US_Purpose_Agenda__c = 'Test purpose'; // Pooja - No more required this field as per TPDEV-885
                event.Purpose_Agenda__c = 'Test purpose'; //Pooja - Added new rich text field insted old text field
                //event.Product_Type__c = 'CA';
                event.ZTS_EU_Market__c = 'United Kingdom';
                listEvents1.add(event);
            }
        return listEvents1;
    }
    
    //Ilirjana 30/9/2014 T-14040
    public static Orders__c createOrderForCall(Id callId, boolean insertOrder){
        Account acc = createAccountRecord(1)[0];
        insert acc;
        
        ZTS_EU_Species_Product__c productSKU = createProduct(ZTS_EU_Constants.productTypeSKU, insertOrder);
        
        Orders__c newOrder = new Orders__c();
        newOrder.Call__c = callId;
        newOrder.ZTS_EU_Dealer_Distributor__c = acc.Id;
        newOrder.Sales_Price__c = Decimal.valueOf(2000);
        newOrder.ZTS_EU_Fulfillment_Date__c = System.today();
        newOrder.Product__r = productSKU;
        newOrder.Product__c = productSKU.Id;
        newOrder.Quantity__c = 10;
        newOrder.ZTS_EU_Account__c = acc.Id;
        
        if (insertOrder)
            insert newOrder;
        
        return newOrder;
    }
    
    //Ilirjana 30/9/2014 T-14040
    public static ZTS_EU_Species_Product__c createProduct(string productType, boolean insertProduct){
        ZTS_EU_Species_Product__c parentProduct = new ZTS_EU_Species_Product__c();
        if (productType == ZTS_EU_Constants.productTypeSKU){
            parentProduct = createProduct(ZTS_EU_Constants.productTypeMPG, insertProduct);
        }
        else if (productType == ZTS_EU_Constants.productTypeMPG){
            parentProduct = createProduct(ZTS_EU_Constants.productTypeBrand, insertProduct);
        }
        
        ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
        prodSpecies.Name='Test Product';
        prodSpecies.ZTS_EU_Market__c='United Kingdom';
        prodSpecies.ZTS_EU_Type__c=productType;
        prodSpecies.CurrencyIsoCode = 'EUR';
        prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
        prodSpecies.ZTS_EU_Is_Active__c=true;
        prodSpecies.ZTS_EU_Is_Orderable__c = True;
        prodSpecies.ZTS_EU_Standard_Price__c=Decimal.valueOf(1000);
        
        if (parentProduct != null)
            prodSpecies.ZTS_EU_Parent_Species_Product__c = parentProduct.Id;
        
        if (insertProduct)
            insert prodSpecies;
            
        return prodSpecies;
    }
    
    //Ilirjana 30/9/2014 T-14040
    public static Call__c createCall(boolean insertCall){
        Account acc = createAccountRecord(1)[0];
        insert acc;
        
        Call__c call = new Call__c();
        call.ZTS_EU_Account__c = acc.Id;
        call.Name = 'Test Call';
        
        //Ilirjana 3-Feb-15 Added values for other fields
        dateTime dt = system.now();
        call.ZTS_EU_Sub_Type__c = 'Account Call';
        call.ZTS_EU_Start_Date_Time__c = dt+3;
        call.ZTS_EU_End_Date_Time__c = dt+4;
        call.ZTS_EU_Status__c = 'Planned';
        call.ZTS_EU_Duration__c = '0.5 Hour';
      
        
        
        if (insertCall)
            insert call;
        
        return call;
    }

    //Author : Shefali 08/10/2014 UserUtility class
    public static User createUtilityUser(boolean insertUser, String country, String uState, String market){
        Integer randomNumber = Math.abs(Crypto.getRandomInteger());
        String uniqueEmail = 'user' + String.valueOf(randomNumber) + '@testorg.com';
        System.debug('Random number for e-mail/username generation: ' + String.valueOf(randomNumber));
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User user = new User(Alias = 'standt', Email=uniqueEmail, 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profile.Id, 
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueEmail,state = uState ,Default_Country__c =country,
        CurrencyIsoCode='EUR', ZTS_EU_Market__c = market);
        
        if (insertUser)
            insert user;
            
       return user;
    }
    
    //Ilirjana 3-Feb-15
    public static list<Event> createEventLst(boolean insertEvents){
        RecordType recTId=[Select Id from RecordType where SObjectType='Event' and DeveloperName='Sales_Call' limit 1];
        list<Event> eventLst = new list<event>();
        event e1= new Event(Subject=' Subject 1',CurrencyIsoCode='EUR',StartDateTime=System.Now(),EndDateTime=System.Now().addDays(4),RecordTypeId=recTId.Id);
        eventLst.add(e1);
        
        event e2= new Event(Subject=' Subject 1',CurrencyIsoCode='EUR',StartDateTime=System.Now().addDays(1),EndDateTime=System.Now().addDays(4),RecordTypeId=recTId.Id);
        eventLst.add(e2);
        
        if (insertEvents)
            insert eventLst;
            
       return eventLst;
    }
    
    //Ilirjana 30/9/2014 T-14040
    public static User createUser(boolean insertUser){
       return createUserWithProfile('Standard User', insertUser);
    }
    
    //Ilirjana 3-Feb-15
    public static User createUserWithProfile(string profileName, boolean insertUser){
        Profile profile = [SELECT Id FROM Profile WHERE Name=:profileName]; 
        return createUserWithProfile(profile.Id, insertUser);
    }

    public static User createUserWithProfile(Id profileId, boolean insertUser) {
        Integer randomNumber = Math.abs(Crypto.getRandomInteger());
        String uniqueEmail = 'user' + String.valueOf(randomNumber) + '@testorg.com';
        System.debug('Random number for e-mail/username generation: ' + String.valueOf(randomNumber));
        
        User user = new User(Alias = 'standt', Email=uniqueEmail, FirstName = 'Mohamed', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profileId, 
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueEmail,
        CurrencyIsoCode='EUR', ZTS_EU_Market__c='Brazil',
        Default_Country__c='Brazil', Country='Brazil');
        
        if (insertUser)
            insert user;
            
       return user;
    }

    public static User createUserWithProfileAndMarket(string profileName, string market){
        User user = createUserWithProfile(profileName, false);
        user.ZTS_EU_Market__c = market;
        
        return user;
    }
    
    //Ilirjana 3-Feb-15
    public static ZTS_EU_Account_Position__c createAccountPosition(id userId, id accId){
        ZTS_EU_Position__c pos = createPosition(userId, true);
        ZTS_EU_Account_Position__c ap = new ZTS_EU_Account_Position__c(
            ZTS_EU_Position__c = pos.Id, ZTS_EU_Active__c = true,
            ZTS_EU_Account__c = accId, ZTS_EU_Primary_Sales_Rep__c = true);

        insert ap;
        createEmployeeCallCredit(ap, userId, true);
            
        return ap;
    }
    
    //Ilirjana 3-Feb-15
    public static ZTS_EU_Position__c createPosition(id userId, boolean insertPos){
        ZTS_EU_Position__c pos = new ZTS_EU_Position__c(
            ZTS_EU_Employee__c = userId, ZTS_EU_Is_Active__c = true);
        
        if (insertPos)
        {
            if (pos.ZTS_EU_Territory__c == null)
            {
                ZTS_EU_Territory__c terr = createTerritory(1)[0];
                insert terr;
                pos.ZTS_EU_Territory__c = terr.Id;
                insert pos;
            }
        }   
        return pos;
    }
     
    //Ilirjana 3-Feb-15
    public static ZTS_EU_Employee_Call_Credit__c createEmployeeCallCredit(ZTS_EU_Account_Position__c ap, id userId, boolean insertECC){
        ZTS_EU_Employee_Call_Credit__c ecc = new ZTS_EU_Employee_Call_Credit__c();
        ecc.ZTS_EU_Account_Position__c = ap.Id;
        ecc.ZTS_EU_Employee_Colleague__c = createColleague(userId, ap.ZTS_EU_Account__c, true).Id;
        
        if (insertECC)
            insert ecc;
            
        return ecc;
    }
    
    //Ilirjana 3-Feb-15
    public static ZTS_EU_Colleague__c createColleague(id userId, id accId, boolean insertCol){
        Call__c call = createCallWithAcc(accId, true);
        
        ZTS_EU_Colleague__c colleague = [
            SELECT Id
            FROM ZTS_EU_Colleague__c
            WHERE ZTS_EU_Call__c = :call.Id
        ];
            
        return colleague;
    }

    public static ZTS_EU_Colleague__c createColleague(Id callId, Id userId){
        return new ZTS_EU_Colleague__c(
            ZTS_EU_User__c = userId,
            ZTS_EU_call__c = callId);
    }
    
    //Ilirjana 3-Feb-15
    public static Holiday__c createHoliday(string market, boolean insertHol){
       //add all the excluded profiles
       List <Excluded_Profiles_for_Auto_TOT__c> lst_ExclProf = new List<Excluded_Profiles_for_Auto_TOT__c>();
        Excluded_Profiles_for_Auto_TOT__c prof1;
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'ZTS_Helpdesk', Profile_Id__c = '00eF0000000hypOIAQ');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Pitcher Zero System Admin', Profile_Id__c = '00eF0000000hyduIAA');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'ZTS Global HelpDesk', Profile_Id__c = '00eF0000000i0sRIAQ');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Trial Customer Portal User', Profile_Id__c = '00eF0000000U6IuIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'System Administrator', Profile_Id__c = '00eF0000000U6IvIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Marketing User', Profile_Id__c = '00eF0000000U6IzIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Premier Support User', Profile_Id__c = '00eF0000001V5EvIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'sfdc', Profile_Id__c = '00eF0000000i5DuIAI');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Data Vendor', Profile_Id__c = '00eF0000000i1G1IAI');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Contract Manager', Profile_Id__c = '00eF0000000U6J0IAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Guest License User', Profile_Id__c = '00eF0000000hWDGIA2');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter External User', Profile_Id__c = '00eF0000000U6J2IAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Standard User', Profile_Id__c = '00eF0000000U6IwIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Integration Profile', Profile_Id__c = '00eF0000000hyLzIAI');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Moderator User', Profile_Id__c = '00eF0000000U6J1IAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Solution Manager', Profile_Id__c = '00eF0000000U6IyIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Free User', Profile_Id__c = '00eF0000000U6IsIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'High Volume Customer Portal User', Profile_Id__c = '00eF0000000U6J3IAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Passport Chatter External Profile', Profile_Id__c = '00eF0000001V4eYIAS');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Passport Chatter Profile', Profile_Id__c = '00eF0000001V4eTIAS');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Read Only', Profile_Id__c = '00eF0000000U6IxIAK');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Marketo Salesforce Sync', Profile_Id__c = '00eF0000001CAhKIAW');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Passport Integration Profile', Profile_Id__c = '00eF0000001V4edIAC');
        lst_ExclProf.add(prof1);
        prof1 = new Excluded_Profiles_for_Auto_TOT__c(Name = 'Chatter Free Zoetis', Profile_Id__c = '00e2A000000i7NRQAY');
        lst_ExclProf.add(prof1);
        insert lst_ExclProf;

         //Added by Aritra: As part of SC-002868
         Holiday__c holiday;
         User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         u1.ZTS_EU_Market__c = market;
         insert u1;
        
       system.runAs(u1)
       {  
         holiday = new Holiday__c(
         ZTS_EU_Is_Active__c = true, ZTS_EU_Market__c = market,
         ZTS_EU_Default_Holiday__c = true, ZTS_EU_Holiday_Date__c = Date.today());
         if (insertHol)
        {
          
            insert holiday;
            
        }
       }  
        return holiday;
    }

    public static ZTS_GL_Account_Affiliation_Reverse_Roles__c createAccountAffiliationReverseRolesSetting(String role) {
        ZTS_GL_Account_Affiliation_Reverse_Roles__c reverseRoles = new ZTS_GL_Account_Affiliation_Reverse_Roles__c();
        reverseRoles.Name = role;
        reverseRoles.ZTS_GL_Reverse_Role__c = role;

        return reverseRoles;
    }
    
    //Ilirjana 5-Feb-15
    public static Call__c createCallWithAcc(id accId, boolean insertCall){
        Call__c call = new Call__c();
        call.ZTS_EU_Account__c = accId;
        call.Name = 'Test Call';
        
        //Ilirjana 3-Feb-15 Added values for other fields
        dateTime dt = system.now();
        call.ZTS_EU_Sub_Type__c = 'Account Call';
        call.ZTS_EU_Start_Date_Time__c = dt+3;
        call.ZTS_EU_End_Date_Time__c = dt+4;
        call.ZTS_EU_Status__c = 'Planned';
        call.ZTS_EU_Duration__c = '0.5 Hour';
        
        if (insertCall)
            insert call;
        
        return call;
    }

    public static List<Attendee__c> createAttendees(List<Contact> contacts, Call__c testCall) {
        List<Attendee__c> attendees = new List<Attendee__c>();

        for (Contact testContact : contacts) {
            attendees.add(new Attendee__c(
                ZTS_EU_Contact__c = testContact.Id,
                ZTS_EU_call__c = testCall.Id
            ));
        }

        return attendees;
    } 
    
    /*************************** Active Trigger Settings *******************************************/
     public static void  activateTriggerSettings(){
        List<TriggerActivation__c> taList=new List<TriggerActivation__c>();
        List<String> names=new List<String>{'PopulateAccountTSFTrigger',
                                    'ZTS_US_Update_Expense_Record',
                                    'AddressCreateAccountTrigger',
                                    'AccountAddressUpdateAddressTrigger',
                                    'ZTS_US_Account_Affi_InsertDupliRec',
                                    'ZTS_US_RecordCreationOnAccount',
                                    'ZTS_US_Populate_ProdTerritoryTrigger',
                                    'ZTS_US_AccountUpdatefromEducation',
                                    'ZTS_US_UserTerritoryTrigger',
                                    'AccountTerrAssignTrigger',
                                    'ZTS_US_Account',
                                    'ZTS_US_Contact_Affi_InsertDupliRec',
                                    'ZTS_US_AllContractTrigger',
                                    'ZTS_KOL',
                                    'ZTS_US_Account_PositionTrigger',
                                    'ZTS_US_Contact_Trigger',
                                    'ZTS_US_EduCreationAndUpdatefromContact',
                                    'ZTS_GL_ChangeRequest',
                                    'AttendeeTrigger',
                                    'ZTS_US_Trigger_Create_Expense_Record',
                                    'EventTrigger',
                                    'CallTrigger',
                                    'ZTS_US_AddressUpdateOnAccount',
                                    'ZTS_US_TerritoryTrigger',
                                    'ZTS_US_PopulateCampaignMemberTrigger',
                                    'ZTS_US_PopulateAccTSF',
                                    'ZTS_GL_AllCustomEventsTrigger',
                                    'ZTS_GL_AllTOTTrigger',
                                    'ZTS_US_AccountContactAffiliation',
                                    'ZTS_US_CustomTerritoryTrigger',
                                    'ZTS_US_VMIPSCaseTrigger',
                                    'CampaignMemberTrigger',
                                    'ZTS_US_Colleague',
                                    'Vmips_Case_Trigger',
                                    'TaskTrigger',
                                    'PIT_Coaching_Guide',
                                    'SampleDropTrigger',
                                    'CampaignTrigger',
                                    'DiscussionCheck',
                                    'populateAccount',
                                    'ZTS_US_VMIPSCaseAccountTrigger',
                                    'ZTS_US_Opportunity',
                                    'ZTS_US_Contracted_Services'};
        for(String name:names)  {
            TriggerActivation__c ta=new TriggerActivation__c(name=name,isActive__c=true);
            taList.add(ta);
        }   
        
        upsert talist;                  
     }
     //added by Ankur as part of TPDEV-862
    public static List<Time_Out_of_Territory__c> createToTOffThisYear(Integer numTerr, String totType, String duration ) {  
        List<Time_Out_of_Territory__c> totList = new List<Time_Out_of_Territory__c>();
         for(Integer i=0;i<numTerr;i++) {
            Time_Out_of_Territory__c totObj = new Time_Out_of_Territory__c();
            totObj.ZTS_EU_Type__c = totType;
            totObj.ZTS_EU_Reason__c = 'W - Administrative Support';
            totObj.ZTS_EU_Start_Date__c = System.now().date();
            totObj.ZTS_EU_End_Date__c =  System.now().date();
            totObj.ZTS_EU_Duration__c = duration;
            //added
             
            totList.add(totObj);
        }  
        return totList;
     }
    
    
     //added by Ankur as part of TPDEV-862
    
    public static List<ZTS_EU_Accounting_Period__c> createAccountingperiod(Integer numAccPer){
         
  List <ZTS_EU_Accounting_Period__c> accper = new List<ZTS_EU_Accounting_Period__c>();
        for(Integer i=0;i<numAccPer;i++) { 
             
        ZTS_EU_Accounting_Period__c ap = new ZTS_EU_Accounting_Period__c();
            ap.ZTS_EU_AP_Start_Editable__c = System.now().date();
            ap.ZTS_EU_AP_End_Editable__c = System.now().date();
            ap.ZTS_EU_Fiscal_Year__c = '2023';
            ap.ZTS_EU_Market__c = 'Brazil';
            ap.ZTS_EU_Account_Period__c = '04';
            ap.ZTS_EU_No_of_Working_Days__c = 24;
            accper.add(ap);
 		
        }
        return accper;

            
    }  
   
    //added by Amrita as part of TPDEV-486
    public static List<ZTS_EU_Sample__c> createSampleRecords(Integer count) {
        List<ZTS_EU_Sample__c> samplesList = new List<ZTS_EU_Sample__c>();
        for (Integer i = 0; i < count; i++) {
            ZTS_EU_Sample__c sample = new ZTS_EU_Sample__c();
            sample.ZTS_EU_Is_Active__c = true;
            samplesList.add(sample);
        }
        return samplesList;
    }
}