@isTest(seeAlldata = false)
public with sharing class ZTS_EU_ProdAdoptionHistoryTest {
    public static testMethod void createProdAdoptHistoryTest()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        List<ZTS_EU_Product_Adoption_Profile_History__c> paphList; 
        Set<ID> conId;
        boolean papRun = true;
            
        List<ZTS_EU_Product_Adoption_Profile__c> pAdopList = new List<ZTS_EU_Product_Adoption_Profile__c> ();
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            Account A1= new Account();
            A1.Name= 'Test Account';
            A1.Type= 'Vet Practice';
            A1.ZTS_EU_Address_Line_1__c = 'Test123';
            A1.ZTS_EU_City__c= 'Test City';
            A1.ZTS_EU_Zip_Postal_Code__c= '123456';
            A1.ZTS_EU_Market__c='United Kingdom';
            A1.Practice_Management_Software__c = 'Other';
            A1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';

            insert A1;

            Contact C1= new Contact();
            C1.LastName = 'Test123';
            C1.FirstName = 'Test123';
            C1.Is_Government_Official__c = 'Yes';
            C1.Accountid = A1.id;
            C1.ZTS_EU_Species_Specialty__c='Companion Animal';
            C1.ZTS_EU_Market__c='United Kingdom';
            insert C1;
            
            ZTS_EU_Species_Product__c prodSpecies= new ZTS_EU_Species_Product__c();
            prodSpecies.Name='Test Product';
            prodSpecies.ZTS_EU_Market__c='United Kingdom';
            prodSpecies.ZTS_EU_Type__c='Brand';
            prodSpecies.CurrencyIsoCode = 'EUR';
            prodSpecies.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
            prodSpecies.ZTS_EU_Is_Active__c=true;
            prodSpecies.ZTS_EU_is_Samplable__c = True;
            insert prodSpecies;
            
            ZTS_EU_Species_Product__c prodSpecies1= new ZTS_EU_Species_Product__c();
            prodSpecies1.Name='Test Product';
            prodSpecies1.ZTS_EU_Market__c='United Kingdom';
            prodSpecies1.ZTS_EU_Type__c='Business Unit';
            prodSpecies1.CurrencyIsoCode = 'EUR';
            prodSpecies1.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
            prodSpecies1.ZTS_EU_Is_Active__c=true;
            prodSpecies1.ZTS_EU_is_Samplable__c = True;
            insert prodSpecies1;
            
            ZTS_EU_Species_Product__c prodSpecies2= new ZTS_EU_Species_Product__c();
            prodSpecies2.Name='Test Product';
            prodSpecies2.ZTS_EU_Market__c='United Kingdom';
            prodSpecies2.ZTS_EU_Type__c='Competitor';
            prodSpecies2.CurrencyIsoCode = 'EUR';
            prodSpecies2.ZTS_EU_Is_KOL_Area_of_Expertise__c=true;
            prodSpecies2.ZTS_EU_Is_Active__c=true;
            prodSpecies2.ZTS_EU_is_Samplable__c = True;
            insert prodSpecies2;
            
            ZTS_EU_Species__c Species = new ZTS_EU_Species__c();
            Species.Name = 'Test Species';
            Species.ZTS_EU_Business_Unit__c = prodSpecies1.id;
            Species.ZTS_EU_Market__c = 'United Kingdom';
            Species.ZTS_EU_Species__c = 'Species Test';
            Species.CurrencyIsoCode='EUR';
            insert Species;
            
            ZTS_EU_Brand_Indication__c Brand = new ZTS_EU_Brand_Indication__c();
            Brand.Name = 'Test Brand';
            Brand.ZTS_EU_Product__c = prodSpecies.id;
            Brand.Market__c = 'United Kingdom';
            insert Brand;
            
            ZTS_EU_Product_Barrier__c ProductBarrier = new ZTS_EU_Product_Barrier__c();
            ProductBarrier.Name = 'Test Barrier';
            ProductBarrier.ZTS_EU_Brand_Indication__c=Brand.id;
            insert ProductBarrier;
            
            ZTS_EU_Competitor_Product__c ComProd = new ZTS_EU_Competitor_Product__c();
            ComProd.Name = 'Test Com';
            ComProd.CurrencyIsoCode ='EUR';
            //ComProd.ZTS_EU_Brand_Indication__c = Brand.id;
            insert ComProd;
            
            ZTS_EU_Product_Adoption_Profile__c pap = new ZTS_EU_Product_Adoption_Profile__c();
            pap.ZTS_EU_Brand_Indication__c = Brand.id;
            pap.ZTS_EU_Competitor_Product__c = ComProd.id;
            pap.ZTS_EU_Contact__c = C1.id;
            pap.ZTS_EU_Product_Barrier__c = ProductBarrier.id;
            pap.ZTS_EU_Usage__c = 'Advocate';
            insert pap;
            pAdopList.add(pap);
        
        // insert pAdopList;       
            
            
        /* ZTS_EU_Product_Adoption_Profile_History__c papH = new ZTS_EU_Product_Adoption_Profile_History__c();
            papH.ZTS_EU_Brand_Indication__c = pap.ZTS_EU_Brand_Indication__c;
            papH.ZTS_EU_Competitor_Product__c = pap.ZTS_EU_Competitor_Product__c;
            papH.ZTS_EU_Contact__c = pap.ZTS_EU_Contact__c;
            papH.ZTS_EU_Product_Adoption_Profile__c = pap.id;
            papH.ZTS_EU_Product_Barrier__c = pap.ZTS_EU_Product_Barrier__c;
            papH.ZTS_EU_Usage__c = pap.ZTS_EU_Usage__c;
            paphList.add(papH);
            
            insert paphList; 
            */
            
            test.startTest();   
            UtilityService.ispapRun();
            ZTS_EU_ProdAdoptionHistory.createProdAdoptHistory(pAdopList);
            //ZTS_EU_ProdAdoptionHistory.updatePrimaryAccount(pAdopList);
        
            test.stoptest();    
        }
    }
}