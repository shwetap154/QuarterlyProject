/**
 * @description       : 
 * @author            : Padma Nerella @ Zoetis Inc
 * @group             : 
 * @last modified on  : 05-02-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
  Ver   Date         Author                         Modification
  1.0   02-27-2023   Padma Nerella @ Zoetis Inc     Added bypass AccountTriggerHandler to Limit the SOQL queries TPDEV-104
**/
@IsTest 
public class ZTS_US_Service_Optimization_Test {

    static testMethod void testSOopportunity(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.LastName = 'eltonboi';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        System.runAs(usr)
        {
            //create account 
            List<Account> accountRecord = ZTS_DataUtilityTest.createAccountRecord(1,6);
            accountRecord[0].ZTS_EU_Market__c = 'United Kingdom';
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            insert accountRecord;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
            
            //create call
            Call__c call = new Call__c();
            call.ZTS_EU_Account__c = accountRecord[0].Id;
            call.ZTS_EU_Start_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2);        
            call.ZTS_EU_End_Date_Time__c = datetime.newInstance(2014, 9, 1, 12, 30, 2).addHours(1);
            call.ZTS_EU_Sub_Type__c = 'Account Call';   
            call.ZTS_EU_Duration__c='0.5 Hours';
            call.ZTS_US_Call_Territory__c='8184-0';
            call.ZTS_EU_Call_Owner__c = UserInfo.getUserId();
            insert call;
            
            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
            //create contact
            Contact contact = (ZTS_DataUtilityTest.createContactRecord(1))[0];
            contact.ZTS_EU_Market__c = 'United Kingdom';
            insert contact;
            
            
            
            //insert custom settings DATA
            List<Territory_Role_Matrix__c> csList = new lIST<Territory_Role_Matrix__c>();
            Territory_Role_Matrix__c cs1=new Territory_Role_Matrix__c(Name='BSM',Role_Value__c='LM');
            csList.add(cs1);
            Territory_Role_Matrix__c cs2=new Territory_Role_Matrix__c(Name='SAM',Role_Value__c='SAM');
            csList.add(cs2);
            insert csList;
            
            //create territory
            List<ZTS_EU_Territory__c> terrList=new List<ZTS_EU_Territory__c>();
            for(Integer i=0; i< 1; i++)
            {
                ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='8180-1',ZTS_TerritoryRole__c='LM',ZTS_Field_Force_Name__c='FieldForceName-'+i,ZTS_EU_Description__c='Terr Desc-'+i,ZTS_EU_Type__c='Territory', ZTS_EU_Market__c = 'United Kingdom');
                terrList.add(cterr);
            }
            insert terrList;
            
            //create user territory        
            List<ZTS_EU_Position__c> usterList=new List<ZTS_EU_Position__c>();
            usterList=(ZTS_DataUtilityTest.createUserTerritory(terrList)); 
            insert usterList;
            
            //create account territory
            List<ZTS_AccountTerritory__c> accterrList=new List<ZTS_AccountTerritory__c>();
            accterrList=ZTS_DataUtilityTest.createAccountTerritory(accountRecord,terrList);
            insert accterrList;
        
        /*create account team
           List<ZTS_EU_Account_Position__c> accteamlist=new List<ZTS_EU_Account_Position__c>();
        //   accteamlist=ZTS_DataUtilityTest.createAccountTeam(accountRecord,usterList);
           
          for(Account acc:accountRecord)
          {
            system.debug('...Is Acc present...' + acc.Id);
            /*for(ZTS_US_AccountTerritory__c accterr:accterrList)
            {
                System.debug('...accterrList[0].ZTS_US_Account__c..' + accterrList[0].ZTS_EU_Account__c);
                if(accterrList[0].ZTS_EU_Account__c == acc.id)
                {
                    ZTS_EU_Account_Position__c acctm=new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=acc.id,ZTS_EU_Position__c=usterList[0].id,ZTS_AccountTerritory__c=accterrList[0].id);
                    accteamlist.add(acctm);
                }
            //}
          }
           insert accteamlist;
           
          system.debug('-----accteamlist----'+ accteamlist);
 
        system.debug('-----accteamlist.ZTS_EU_Territory__c----'+ accteamlist[0].ZTS_EU_Territory__c);
        system.debug('-----accteamlist.ZTS_US_Account__c----'+ accteamlist[0].ZTS_EU_Account__c);
       */
              
          Attendee__c attendee = new Attendee__c();
          attendee.ZTS_EU_Contact__c = contact.Id;
          attendee.ZTS_EU_call__c = call.Id;
          insert attendee;
          
          ZTS_EU_Discussion__c disc = new ZTS_EU_Discussion__c();
          disc.name = 'Strategic Business Planning';
          disc.ZTS_EU_Call_Attendee__c = attendee.id; 
          Insert disc;
          Test.starttest();
          //insert data in custom setting       
          DiscussionMapping__c dMCustSetting = new DiscussionMapping__c();
          dMCustSetting.Name = 'Test';
          dMCustSetting.Disc_Item__c = 'Strategic Business Planning';
          dMCustSetting.Oppty_Type__c = 'PeopleFirst';        
          insert dMCustSetting;
          
          call.ZTS_EU_Status__c = 'submitted';
          call.ZTS_EU_Submitted_Date__c = system.now();
          call.Opportunity_Type__c = 'Strategic Business Planning';
          update call;
          
          List<Id> callList = new List<Id>(); 
          callList.add(call.Id);
          
          ZTS_DataUtilityTest.activateTriggerSettings();
          CallUtils.createOpportunity(callList);
  /*----------create data for SAM Role in territory----------------------------*/
        
        //create territory
          List<ZTS_EU_Territory__c> terrList_sam=new List<ZTS_EU_Territory__c>();
          for(Integer i=0; i< 1; i++)
          {
              ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='8180-1',ZTS_TerritoryRole__c='SAM',ZTS_Field_Force_Name__c='FieldForceName-'+i,ZTS_EU_Description__c='Terr Desc-'+i,ZTS_EU_Type__c='Territory', ZTS_EU_Market__c = 'United Kingdom');
              terrList_sam.add(cterr);
          }
          insert terrList_sam;
          
          
          //create user territory        
          List<ZTS_EU_Position__c> usterList_sam=new List<ZTS_EU_Position__c>();
          usterList_sam=(ZTS_DataUtilityTest.createUserTerritory(terrList_sam)); 
          insert usterList_sam;
          
          //create account territory
          List<ZTS_AccountTerritory__c> accterrList_sam=new List<ZTS_AccountTerritory__c>();
          accterrList_sam=ZTS_DataUtilityTest.createAccountTerritory(accountRecord,terrList_sam);
          insert accterrList_sam;
         
        
        /*create account team
           List<ZTS_EU_Account_Position__c> accteamlist_sam=new List<ZTS_EU_Account_Position__c>();           
          for(Account acc:accountRecord)
          {
            system.debug('...Is Acc present...' + acc.Id);
                System.debug('...accterrList_sam[0].ZTS_US_Account__c..' + accterrList_sam[0].ZTS_EU_Account__c);
                if(accterrList[0].ZTS_EU_Account__c == acc.id)
                {
                    ZTS_EU_Account_Position__c acctm=new ZTS_EU_Account_Position__c(ZTS_EU_Account__c=acc.id,ZTS_EU_Position__c=usterList[0].id,ZTS_AccountTerritory__c=accterrList[0].id);
                    accteamlist_sam.add(acctm);
                }
          }
        
        try{
            insert accteamlist_sam;
        }
         
        catch(Exception e){
            System.debug('Exception : '+e);
        }
           */
       
              
          Attendee__c attendee_sam = new Attendee__c();
          attendee_sam.ZTS_EU_Contact__c = contact.Id;
          attendee_sam.ZTS_EU_call__c = call.Id;
          insert attendee_sam ;
          
          ZTS_EU_Discussion__c disc_sam = new ZTS_EU_Discussion__c();
          disc_sam.name = 'Strategic Business Planning';
          disc_sam.ZTS_EU_Call_Attendee__c = attendee_sam.id; 
          Insert disc_sam;
          
          call.ZTS_EU_Status__c = 'submitted';
          call.ZTS_EU_Submitted_Date__c = system.now();
          call.Opportunity_Type__c = 'Strategic Business Planning';
          update call;
          
          List<Id> callList2 = new List<Id>(); 
          callList2.add(call.Id);
          
          ZTS_DataUtilityTest.activateTriggerSettings();
          CallUtils.createOpportunity(callList2);
          
          Test.stoptest();
      }
    }
}