/**
 * @description       : 
 * @author            : Chanbasha NoorBashaSheikh @ ATG
 * @group             : 
 * @last modified on  : 07-07-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   07-07-2021   Chanbasha NoorBashaSheikh @ ATG   Initial Version
 * 1.1   07-07-2021   Namrata Patane @ Zoetis           Changed Test to include assertion
**/
@isTest
public class ZIP_TerritoryBrickCodePopulation_Test {
  static testMethod void territoryBrickCodePopulationTest() {
    //BrickToterr
    List<ZTS_GL_BrickToTerr__c> b2tList = new List<ZTS_GL_BrickToTerr__c>();

    ZTS_GL_BrickToTerr__c b2t = new ZTS_GL_BrickToTerr__c();
    b2t.ZTS_EU_BrickName__c = '02155';
    b2t.Name = '02155';
    b2t.ZTS_EU_Market__c = 'Spain';
    b2t.ZTS_EU_Inactive__c = false;
    b2tList.add(b2t);

    insert b2tList;

    //Insert ZipToBrick
    List<ZTS_GL_ZipToBrick__c> ztblst = new List<ZTS_GL_ZipToBrick__c>();

    ZTS_GL_ZipToBrick__c ztb = new ZTS_GL_ZipToBrick__c();
    ztb.Name = '02155';
    ztb.ZTS_EU_Market__c = 'Spain';
    ztb.ZTS_EU_BrickCode__c = b2t.id;
    ztblst.add(ztb);

    insert ztblst;

    List<Account> accList = new List<Account>();

    State_Country__c sc = new State_Country__c();
    sc.Name = 'Test';
    sc.ZTS_EU_Country__c = 'Spain';
    sc.ZTS_EU_uniqueCOUNTY__c = 'Spain-Test';
    insert sc;

    Account acc = new Account();
    acc.name = 'Test Account';
    acc.Type = 'Farm';
    acc.ZTS_EU_Sub_Type__c = 'Beef';
    acc.ZTS_EU_Address_Line_1__c = 'Test Address Line';
    acc.ZTS_EU_City__c = 'Test City';
    acc.ZTS_EU_Zip_Postal_Code__c = '02155';
    acc.ZTS_EU_Main_Phone__c = '9876789876';
    acc.ZTS_EU_District__c = 'Test';
    acc.ZTS_EU_Market__c = 'Spain';
    acc.ZTS_EU_Country__c = 'Spain';
    acc.ZTS_EU_Vetsave_ID__c = '200';
    acc.ZTS_EU_Vetsave_HO_ID__c = '56';
    acc.ZTS_EU_VAT_Code__c = '132434223';
    acc.ZTS_EU_State_County__c = sc.Id;
    accList.add(acc);

    Test.startTest();
    insert accList;
    Test.stopTest();

    // Check Test Results
    Account newAcc = [
      SELECT Id, Name, ZTS_EU_Market__c, ZTS_EU_BrickCode__c
      FROM Account
      WHERE ZTS_EU_Market__c = 'Spain'
    ];

    System.assertEquals('02155', newAcc.ZTS_EU_BrickCode__c);
  }
}