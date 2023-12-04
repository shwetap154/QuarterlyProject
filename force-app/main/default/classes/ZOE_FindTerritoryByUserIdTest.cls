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
 */
/*******************************************************************************************************************************************
* File Name     :  ZOE_FindTerritoryByUserIdTest
* Description   :           
* @author       :  Ketan Prakash Singh
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/15         Ketan             Created the Class.

********************************************************************************************************************************************/
@isTest /*(SeeAllData = true)*/
public class ZOE_FindTerritoryByUserIdTest
{
   static User createUserTerritoryToAssociation()
    {
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
         User u2 = new User(firstname= 'Test',
                              lastname='XXXX',
                              Alias='Test',
                              email = 'test1234122@test.com',
                              username= 'test1234xxx123@test.com', 
                              profileId= p.id, 
                              emailencodingkey='UTF-8',
                              languagelocalekey='en_US',
                              localesidkey='en_US',
                              timezonesidkey='America/Los_Angeles',
                              ZTS_EU_Market__c ='India');
        insert u2;   
        return u2;
    }
   static testMethod void PositionUtilityClass()
   {     
          
       User thisUser = createUserTerritoryToAssociation(); /*[ select Id from User where Id = :UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];*/
       Set<Id> territoryIdSet = new Set<Id>();
       list<Territory2>lstTerritoryIdSet = new list<Territory2>();
         
       Set<Id> childTerritoryIdSet = new Set<Id>();  
       list<Territory2> lstChildTerritoryIdSet = new list<Territory2>();
       Territory2 t = new Territory2();
       Territory2 ct = new Territory2();

        List<ETM_Required_Ids__mdt> mdtETMRequiredIds = [SELECT DeveloperName,ETM_Model_ID__c,ETM_Type_Id__c FROM ETM_Required_Ids__mdt Where DeveloperName = 'Default_Values' Limit 1];

         System.runAs (thisUser) 
         {           
              t.name = 'terrName';
              t.DeveloperName = 'terrName';
              t.Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c;
              t.Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c;
              lstTerritoryIdSet.add(t);
              insert lstTerritoryIdSet;
              territoryIdSet.add(lstTerritoryIdSet[0].id);
              
              ct.name = 'child Terr';
              ct.DeveloperName = 'child_Terr';
              ct.Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c;
              ct.Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c;
              ct.ParentTerritory2Id = lstTerritoryIdSet[0].id;
              lstChildTerritoryIdSet.add(ct);
              insert lstChildTerritoryIdSet;
              childTerritoryIdSet.add(lstChildTerritoryIdSet[0].id);
               
              test.starttest();
                 ZOE_FindTerritoryByUserId.findTerritoriesForUserId(thisUser.id, true);
                 ZOE_FindTerritoryByUserId.getAllAccountsByTerritory(territoryIdSet,thisUser.id);
                 ZOE_FindTerritoryByUserId.getAllSubChildTerritoryIds(childTerritoryIdSet);
              test.stoptest();
         }   
   }
}