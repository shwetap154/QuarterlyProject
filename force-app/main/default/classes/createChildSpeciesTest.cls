@isTest
private class createChildSpeciesTest{

    @TestSetup
    static void createTestData(){

      User usr = new User();
      usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
      usr.FirstName = 'eltonUser';
      usr.zts_eu_market__c = 'United Kingdom';
      insert usr;  

      SpeciesList__c sptest=new SpeciesList__c(Name='SPLIST1',ChildSpeciesName__c='abcd',factor__c=2 ,ParentSpeciesName__c='Vacas de Leche');
      insert sptest;
                 
      //Account creation
      Account acc = new Account(Name='testAccount',ZTS_EU_Account_Status__c='active',ZTS_EU_Market__c='Spain',
                                Practice_Management_Software__c = 'Other',ZTS_EU_Zip_Postal_Code__c = '00000',
                                Other_Practice_Management_Software__c = 'Sample Practice Management Software');
      
      System.runAs(usr)
      {
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        insert acc; 
        ZTS_EU_Species_Product__c prod = new ZTS_EU_Species_Product__c(Name='spainproduct',ZTS_EU_Type__c='Business Unit',ZTS_EU_Market__c='Spain',ZTS_EU_Business_Unit_Abbr__c='RU');
        insert prod;
 
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        ZTS_EU_Species__c species = new ZTS_EU_Species__c(Name='Vacas de Leche',ZTS_EU_Business_Unit__c=prod.id,ZTS_EU_Species__c='Vacas de Leche',ZTS_EU_Market__c='Spain');
        insert species;
		
        DispatchTriggerHandler.firstTimeTracker = new Set<String>();
        ZTS_EU_Species__c species1 = new ZTS_EU_Species__c(Name='abcd',ZTS_EU_Business_Unit__c=prod.id,ZTS_EU_Species__c='abcd',ZTS_EU_Market__c='Spain');
        insert species1;

      }
      
    }

    @isTest
    static void MyUnitTest() {



      List<ZTS_EU_Species__c> speciesList = [SELECT Id, Name FROM ZTS_EU_Species__c];
      List<Account> accounts = [SELECT Id FROM Account];
       
      test.startTest();

        ZTS_EU_Account_Species_Potential__c asp1=new ZTS_EU_Account_Species_Potential__c(ZTS_EU_Uniqueness_Key__c=accounts[0].id+'_'+speciesList[1].id,Account__c=accounts[0].id,ZTS_EU_Species_Potential__c=speciesList[0].id,ZTS_EU_Animals_Consultations_actual__c=5.00);
        insert asp1;

        ZTS_EU_Account_Species_Potential__c asp=new ZTS_EU_Account_Species_Potential__c(ZTS_EU_Uniqueness_Key__c=accounts[0].id+'_'+speciesList[0].id,Account__c=accounts[0].id,ZTS_EU_Species_Potential__c=speciesList[0].id,ZTS_EU_Animals_Consultations_actual__c=12.00);
        asp.ParentSpeciesid__c = asp1.Id;
        insert asp;


        List<ZTS_EU_Account_Species_Potential__c> aspListAfterInsert = [SELECT Id, ParentSpeciesid__c, updatedbyparentid__c, ZTS_EU_Animals_Consultations_actual__c 
                                                                    FROM ZTS_EU_Account_Species_Potential__c];

        System.assertEquals(asp1.ZTS_EU_Animals_Consultations_actual__c + (asp1.ZTS_EU_Animals_Consultations_actual__c*2) , aspListAfterInsert[0].ZTS_EU_Animals_Consultations_actual__c, 'The expected value of ZTS_EU_Animals_Consultations_actual__c is asp1.ZTS_EU_Animals_Consultations_actual__c + (asp1.ZTS_EU_Animals_Consultations_actual__c*2) = 15');

        asp.ZTS_EU_Animals_Consultations_actual__c=20.00;
        RecursiveTriggerHandler.isFirstTime=true;
        update asp;

        List<ZTS_EU_Account_Species_Potential__c> aspList=[Select Id, ParentSpeciesid__c, updatedbyparentid__c, ZTS_EU_Animals_Consultations_actual__c from ZTS_EU_Account_Species_Potential__c];

        System.assertEquals(asp.ZTS_EU_Animals_Consultations_actual__c, aspList[1].ZTS_EU_Animals_Consultations_actual__c, 'The expected value of ZTS_EU_Animals_Consultations_actual__c is 20');

        try{
            RecursiveTriggerHandler.isFirstTime = true;
            delete aspList[0];
        }
        
        catch(Exception e){
            System.debug('delete error: '+e.getMessage());
        }
      test.stopTest();

      List<ZTS_EU_Account_Species_Potential__c> aspListAfterDelete=[Select Id, ParentSpeciesid__c, updatedbyparentid__c, ZTS_EU_Animals_Consultations_actual__c from ZTS_EU_Account_Species_Potential__c];

      System.assertEquals(null, aspListAfterDelete[0].ParentSpeciesid__c, 'The expected value of ParentSpeciesid__c is null as the parent is deleted' );
    
    }

    @isTest
    static void MyUnitTest1(){

      List<ZTS_EU_Species__c> speciesList = [SELECT Id, Name FROM ZTS_EU_Species__c];
      List<Account> accounts = [SELECT Id FROM Account];
       
      Test.startTest();

        ZTS_EU_Account_Species_Potential__c asp1=new ZTS_EU_Account_Species_Potential__c(ZTS_EU_Uniqueness_Key__c=accounts[0].id+'_'+speciesList[1].id,Account__c=accounts[0].id,ZTS_EU_Species_Potential__c=speciesList[0].id,ZTS_EU_Animals_Consultations_actual__c=5.00);
        insert asp1;

        ZTS_EU_Account_Species_Potential__c asp=new ZTS_EU_Account_Species_Potential__c(ZTS_EU_Uniqueness_Key__c=accounts[0].id+'_'+speciesList[0].id,Account__c=accounts[0].id,ZTS_EU_Species_Potential__c=speciesList[0].id,ZTS_EU_Animals_Consultations_actual__c=12.00);
        //asp.updatedbyparentid__c = asp1.Id;
        insert asp;

        List<ZTS_EU_Account_Species_Potential__c> aspListAfterInsert = [SELECT Id, ParentSpeciesid__c, updatedbyparentid__c, ZTS_EU_Animals_Consultations_actual__c 
                                                                          FROM ZTS_EU_Account_Species_Potential__c];

        System.debug('AFTER INSERT -->'+aspListAfterInsert);

        RecursiveTriggerHandler.isFirstTime = true;
        aspListAfterInsert[1].ZTS_EU_Animals_Consultations_actual__c=20.00;
        update aspListAfterInsert[1];

      Test.stopTest();

      List<ZTS_EU_Account_Species_Potential__c> aspList=[Select Id, ParentSpeciesid__c, updatedbyparentid__c, ZTS_EU_Animals_Consultations_actual__c from ZTS_EU_Account_Species_Potential__c];

      System.assertEquals(aspListAfterInsert[1].ZTS_EU_Animals_Consultations_actual__c, aspList[1].ZTS_EU_Animals_Consultations_actual__c, 'The expected value of ZTS_EU_Animals_Consultations_actual__c is 20');
    
    }
    
}