/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_ProductHierarchyUtilityTest
* Description   :  This is the test class for the class: ZTS_EU_ProductHierarchyUtility.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     2nd-June-15   Shreyas             Created the class.

********************************************************************************************************************************************/
@isTest(SeeAllData = false)
Public class ZTS_EU_ProductHierarchyUtilityTest{
    
    /*static testMethod void testMethod1(){

Test.starttest();
List<TriggerActivation__c> triggerActiveList = new List<TriggerActivation__c>();
TriggerActivation__c tr1 = new TriggerActivation__c(Name = 'ZTS_EU_Species_Product',ZTS_EU_Bypass__c = true);
triggerActiveList.add(tr1);
insert triggerActiveList;


String tgTypeId = [Select Id from RecordType where DeveloperName = 'Therapeutic_Group'].Id;
ZTS_EU_Species_Product__c tgRec = new ZTS_EU_Species_Product__c();
tgRec.Name = 'TestTG';
tgRec.RecordTypeId = tgTypeId;
tgRec.ZTS_EU_Market__c = 'Spain';
tgRec.ZTS_EU_Type__c = 'Therapeutic Group';
tgRec.ZTS_EU_Is_Active__c = true;
insert tgRec;

String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
ZTS_EU_Species_Product__c brandRec = new ZTS_EU_Species_Product__c();
brandRec.Name = 'Testbrand';
brandRec.RecordTypeId = brandTypeId;
brandRec.ZTS_EU_Market__c = 'Spain';
brandRec.ZTS_EU_Type__c = 'Brand';
brandRec.ZTS_EU_Is_Active__c = true;
brandRec.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
insert brandRec;

//String BUtypeID = [Select ID from RecordType where DeveloperName = 'Business Unit'].ID;
ZTS_EU_Species_Product__c buRec = new ZTS_EU_Species_Product__c(); // PH Business Unit type
//buRec.RecordTypeId = BUtypeID;
buRec.Name='Test BU - Product';
buRec.ZTS_EU_Market__c='Spain';
buRec.ZTS_EU_Type__c='Business Unit';
buRec.CurrencyIsoCode = 'EUR';
buRec.ZTS_EU_Is_Active__c=true;
buRec.ZTS_EU_Is_Detailable__c = false;
buRec.ZTS_EU_Business_Unit_Abbr__c = 'PY';
insert buRec;

ZTS_EU_Species__c speciesRec = new ZTS_EU_Species__c(); //Species record
speciesRec.Name='Test Species';
speciesRec.ZTS_EU_Business_Unit__c = buRec.id;
speciesRec.ZTS_EU_Species__c = 'Test Species';
speciesRec.CurrencyIsoCode='EUR'; 
speciesRec.ZTS_EU_Market__c ='Spain';
insert speciesRec;

//String brandTypeId = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
ZTS_EU_Species_Product__c brandRec2 = new ZTS_EU_Species_Product__c(); //PH Brand Type
brandRec2.Name = 'Testbrand2';
brandRec2.RecordTypeId = brandTypeId;
brandRec2.ZTS_EU_Market__c = 'Spain';
brandRec2.ZTS_EU_Type__c = 'Brand';
brandRec2.ZTS_EU_Is_Active__c = true;
brandRec2.CurrencyIsoCode = 'EUR';
//brandRec2.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
insert brandRec2;


ZTS_EU_Potential_Brands__c potBrandRec = new ZTS_EU_Potential_Brands__c(); // PB reord
potBrandRec.Brand__c = brandRec2.Id;
potBrandRec.Potential__c = speciesRec.id;
potBrandRec.ZTS_EU_Value_Region_1__c = 1;
potBrandRec.ZTS_EU_Value_Region_2__c=2; 
potBrandRec.ZTS_EU_Value_Region_3__c =3;
potBrandRec.ZTS_EU_Value_Region_4__c =4;
potBrandRec.ZTS_EU_Business_Unit_Abbr__c = 'PY';
insert potBrandRec;


ZTS_EU_Species_Product__c buRec2 = new ZTS_EU_Species_Product__c();
buRec2.Name='Test BU - Product';
buRec2.ZTS_EU_Market__c='Spain';
buRec2.ZTS_EU_Type__c='Business Unit';
buRec2.CurrencyIsoCode = 'EUR';
buRec2.ZTS_EU_Is_Active__c=true;
buRec2.ZTS_EU_Is_Detailable__c = false;
insert buRec2;

ZTS_EU_Species__c speciesRec2 = new ZTS_EU_Species__c();
speciesRec2.Name='Test Species2';
speciesRec2.ZTS_EU_Business_Unit__c = buRec2.id;
speciesRec2.ZTS_EU_Species__c = 'Test Species2';
speciesRec2.CurrencyIsoCode='EUR'; 
speciesRec2.ZTS_EU_Market__c ='Spain';
insert speciesRec2;

ZTS_EU_Potential_Brands__c potBrandRec2 = new ZTS_EU_Potential_Brands__c();
potBrandRec2.Brand__c = brandRec2.Id;
potBrandRec2.Potential__c = speciesRec2.id;
potBrandRec2.ZTS_EU_Value_Region_1__c = 1;
potBrandRec2.ZTS_EU_Value_Region_2__c=2; 
potBrandRec2.ZTS_EU_Value_Region_3__c =3;
potBrandRec2.ZTS_EU_Value_Region_4__c =4;
potBrandRec2.ZTS_EU_Business_Unit_Abbr__c = 'CA';
insert potBrandRec2;

delete buRec;

Test.stoptest();
}*/
    
    static testMethod void testMethod2(){ //Added by Tanmoy (Cognizant)
        
        Test.starttest();
        String BUtypeID = [Select ID from RecordType where DeveloperName = 'Business_Unit'].ID;
        ZTS_EU_Species_Product__c parentProduct = new ZTS_EU_Species_Product__c(); // PH Parent type
        parentProduct.RecordTypeId = BUtypeID;
        parentProduct.Name='Parent BU - Product';
        parentProduct.ZTS_EU_Market__c='Spain';
        parentProduct.ZTS_EU_Type__c='Therapeutic Group';
        parentProduct.CurrencyIsoCode = 'EUR';
        parentProduct.ZTS_EU_Is_Active__c=true;
        parentProduct.ZTS_EU_Is_Detailable__c = false;
        parentProduct.ZTS_EU_Business_Unit_Abbr__c = 'PY';
        
        insert parentProduct;
        
        ZTS_EU_Species_Product__c buRecAB = new ZTS_EU_Species_Product__c(); // PH Brand type
        buRecAB.RecordTypeId = BUtypeID;
        buRecAB.Name='Test BU - Product';
        buRecAB.ZTS_EU_Market__c='Spain';
        buRecAB.ZTS_EU_Type__c='Brand';
        buRecAB.CurrencyIsoCode = 'EUR';
        buRecAB.ZTS_EU_Is_Active__c=true;
        buRecAB.ZTS_EU_Is_Detailable__c = false;
        buRecAB.ZTS_EU_Business_Unit_Abbr__c = 'PY';
        buRecAB.ZTS_EU_Parent_Species_Product__c = parentProduct.Id;
        insert buRecAB;
        
        ZTS_EU_Species_Product__c speciesProduct =  new ZTS_EU_Species_Product__c(); // PH Business Unit type
        speciesProduct.RecordTypeId = BUtypeID;
        speciesProduct.Name='Test BU - Species Product';
        speciesProduct.ZTS_EU_Market__c='Spain';
        speciesProduct.ZTS_EU_Type__c='Business Unit';
        speciesProduct.CurrencyIsoCode = 'EUR';
        speciesProduct.ZTS_EU_Is_Active__c=true;
        speciesProduct.ZTS_EU_Is_Detailable__c = false;
        speciesProduct.ZTS_EU_Business_Unit_Abbr__c = 'PY';
        insert speciesProduct;        
        
        ZTS_EU_Species__c speciesRecAB = new ZTS_EU_Species__c(); //Species record
        speciesRecAB.Name='Test Species';
        speciesRecAB.ZTS_EU_Business_Unit__c = speciesProduct.id;
        speciesRecAB.ZTS_EU_Species__c = 'Test Species';
        speciesRecAB.CurrencyIsoCode='EUR'; 
        speciesRecAB.ZTS_EU_Market__c ='Spain';
        insert speciesRecAB;
        
        String brandTypeIdAB = [Select Id from RecordType where DeveloperName = 'Brand'].Id;
        ZTS_EU_Species_Product__c brandRec2AB = new ZTS_EU_Species_Product__c(); //PH Brand Type
        brandRec2AB.Name = 'Testbrand2';
        brandRec2AB.RecordTypeId = brandTypeIdAB;
        brandRec2AB.ZTS_EU_Market__c = 'Spain';
        brandRec2AB.ZTS_EU_Type__c = 'Brand';
        brandRec2AB.ZTS_EU_Is_Active__c = true;
        brandRec2AB.CurrencyIsoCode = 'EUR';
        //brandRec2.ZTS_EU_Parent_Species_Product__c = tgRec.Id;
        brandRec2AB.ZTS_EU_Parent_Species_Product__c = parentProduct.Id;

        insert brandRec2AB;
        
        
        ZTS_EU_Potential_Brands__c potBrandRecAB = new ZTS_EU_Potential_Brands__c(); // PB record
        potBrandRecAB.Brand__c = buRecAB.Id;
        potBrandRecAB.Potential__c = speciesRecAB.id;
        potBrandRecAB.ZTS_EU_Value_Region_1__c = 1;
        potBrandRecAB.ZTS_EU_Value_Region_2__c=2; 
        potBrandRecAB.ZTS_EU_Value_Region_3__c =3;
        potBrandRecAB.ZTS_EU_Value_Region_4__c =4;
        potBrandRecAB.ZTS_EU_Business_Unit_Abbr__c = 'EQ';
        
        ZTS_EU_Potential_Brands__c potBrandRecAB2 = new ZTS_EU_Potential_Brands__c(); // PB record

        potBrandRecAB2.Brand__c = buRecAB.Id;
        potBrandRecAB2.Potential__c = speciesRecAB.id;
        potBrandRecAB2.ZTS_EU_Value_Region_1__c = 1;
        potBrandRecAB2.ZTS_EU_Value_Region_2__c=2; 
        potBrandRecAB2.ZTS_EU_Value_Region_3__c =3;
        potBrandRecAB2.ZTS_EU_Value_Region_4__c =4;
        potBrandRecAB2.ZTS_EU_Business_Unit_Abbr__c = 'CA';
        insert new List<ZTS_EU_Potential_Brands__c>{ potBrandRecAB, potBrandRecAB2 };
        
        List<ZTS_EU_Species_Product__c> countPotentialBrands = [SELECT ZTS_EU_NO_OF_PY_Species__c, ZTS_EU_Business_Units__c, 
                                                                ZTS_EU_Type__c, ZTS_EU_Market__c, ZTS_EU_Business_Unit_Abbr__c 
                                                                FROM ZTS_EU_Species_Product__c 
                                                                WHERE Id = :brandRec2AB.Id];
        
        //countPotentialBrands[0].ZTS_EU_Business_Unit_Abbr__c = 'PY';
        countPotentialBrands[0].ZTS_EU_Type__c = 'Brand';
        countPotentialBrands[0].ZTS_EU_Market__c = 'Spain';
        Update countPotentialBrands;
        delete brandRec2AB;
        
        Test.stoptest();
        
    }
    
    
    
}