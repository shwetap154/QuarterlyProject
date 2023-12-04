/**
* @description  :  Data Factory to create any type of data needed to build and run test classes
* @author            : Morgan Marchese @ Zoetis Inc
* @group             :
* @last modified on  : 07-28-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                   Modification
* 1.0   12-04-2020	  Morgan Marchese @ ZTS	   Created the Class.
* 1.1   04-06-2022   Ethan Hirsch @ Zoetis    Added back a createPosition method that was removed on merge.
* 1.2   04-13-2022   Ethan Hirsch @ Zoetis    Added createContract Method
* 1.3   04-29-2022   Ethan Hirsch @ Zoetis    Added retrieveFirstActivePicklistValue Method
* 1.4   08-04-2022   Ethan Hirsch @ Zoetis    Set Profession and Job Function in createContacts
* 1.5   03-02-2023   Ethan Hirsch @ Zoetis    Add methods for iDevelop Setup
* 1.6   04-10-2023   Ethan Hirsch @ Zoetis    Add an additional override for createDataTranslation to setup a
*                                             Data Translation with a Competency Model.
* 1.7   06-09-2023   Padma Nerella @ Zoetis   Added createLeadRec method to create leads TPDEV-1070
* 1.8   06-09-2-23   Padma Nerella @ Zoetis   Added createVetInformationRec to create Veterinarian_Information__c record with leadId TPDEV-1070
* 1.9   06-09-2023   Padma Nerella @ Zoetis   Added createEchoSignDev1SignAgreement and createEchoSigndev1SignDataMapping TPDEV-1070
* 1.10   06-23-2023   Suprabha @ Zoetis        Added createKnowledgeArticle , createContentVersion and createContentDocumentLink TPDEV-554
* 1.11  07-27-2023   Padma Nerella @ Zoetis   Add createFinanciallyAuthorizedPerson TPDEV-1546
* 1.12  07-28-2023   Ethan Hirsch @ Zoetis    Add createVetShippingAddress TPDEV-1079
* 1.13  07-28-2023   Padma Nerella @ Zoetis   Add createAddressesWithLead 

**/
@IsTest
public with sharing class TestDataFactory {
    
    private static Account buildAccount(){
        Account acc = new Account();
        acc.name = 'Test Account';
        acc.Type = 'Farm';
        acc.ZTS_EU_Sub_Type__c = 'Beef';
        acc.ZTS_EU_Potential_Region__c = '1';              
        acc.ZTS_EU_Main_Phone__c='9876789876';
        acc.Practice_Management_Software__c = 'Other';
        acc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
        acc.ZTS_EU_Rep_Account_Status__c='Active';
        return acc;
    }
    
    public static Account createAccount_EU(Id stateCountyId, Boolean shouldInsert){
        Account acc = buildAccount();
        acc.CurrencyIsoCode='EUR';
        acc.ZTS_EU_Market__c='United Kingdom';
        acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc.ZTS_EU_City__c = 'Test City';
        acc.ZTS_EU_Zip_Postal_Code__c = 'DL12 8ED';  
        acc.ZTS_EU_Country__c = 'United Kingdom';
        acc.ZTS_EU_State_County__c = stateCountyId;
        acc.ZTS_EU_Vetsave_ID__c='300';
        acc.ZTS_EU_Vetsave_HO_ID__c='300';
        if(shouldInsert){
            insert acc;
        }
        return acc;
    }
    
    public static Account createAccount_EU(String name, Id stateCountyId, Boolean shouldInsert){
        Account acc = buildAccount();
        acc.Name = name;
        acc.CurrencyIsoCode='EUR';
        acc.ZTS_EU_Market__c='United Kingdom';
        acc.ZTS_EU_Address_Line_1__c = 'Test Address Line ';
        acc.ZTS_EU_City__c = 'Test City';
        acc.ZTS_EU_Zip_Postal_Code__c = 'DL12 8ED';  
        acc.ZTS_EU_Country__c = 'United Kingdom';
        acc.ZTS_EU_State_County__c = stateCountyId;
        acc.ZTS_EU_Vetsave_ID__c='300';
        acc.ZTS_EU_Vetsave_HO_ID__c='300';
        if(shouldInsert){
            insert acc;
        }
        return acc;
    }
    
    public static Account createAccount_US(String name, Boolean shouldInsert){
        Account acc = buildAccount();
        acc.Name = name;
        acc.CurrencyIsoCode='USD';
        acc.ZTS_EU_Market__c='United States';
        acc.BillingStreet = '10 Sylvan Way';
        acc.BillingCity = 'Parsippany';
        acc.BillingPostalCode = '07054';  
        acc.BillingCountry = 'United States';
        acc.BillingState = 'New Jersey';
        if(shouldInsert){
            insert acc;
        }
        return acc;
    }
    
    private static ZTS_EU_Territory__c buildZTSTerritory(){
        ZTS_EU_Territory__c record = new ZTS_EU_Territory__c();
        record.Name = 'UK-TER-TEST-1';
        record.ZTS_EU_Brick_Assignment__c = true;
        record.ZTS_EU_Description__c = 'UK-TER-TEST-1';
        record.ZTS_EU_Is_Active__c = true;
        record.ZTS_EU_Is_Assigned__c = false;
        record.ZTS_EU_Need_syncing__c = false;
        record.ZTS_US_Synced__c = false;
        record.ZTS_External_ID__c = String.valueOf(Math.random());
        record.ZTS_External_Par_Id__c = record.ZTS_External_ID__c;
        return record;
    }
    
    public static ZTS_EU_Territory__c createZTSTerritory(String name,String territoryId, String market, Boolean shouldInsert){
        ZTS_EU_Territory__c record = buildZTSTerritory();
        record.ZTS_EU_Market__c = market;
        record.Name = name;
        record.ZTS_EU_Terr_SFID__c = territoryId;
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    public static ZTS_EU_Territory__c createZTSTerritory(
        String market,
        Id parentTerritoryId,
        String fieldForceName,
        String territoryType,
        Boolean doInsert
    ) {
        ZTS_EU_Territory__c zTSEUTerritory = new ZTS_EU_Territory__c();
        zTSEUTerritory.ZTS_EU_Market__c = market;
        zTSEUTerritory.ZTS_EU_Parent_Territory__c = parentTerritoryId;
        zTSEUTerritory.ZTS_Field_Force_Name__c = fieldForceName;
        zTSEUTerritory.ZTS_EU_Type__c = territoryType;
        zTSEUTerritory.ZTS_Type__c = territoryType;
        
        if (doInsert) {
            insert zTSEUTerritory;
        }
        
        return zTSEUTerritory;
    }
    
    public static ZTS_AccountTerritory__c createAccountTerritory(
        Account acct,
        ZTS_EU_Territory__c territory,
        Boolean sibFlag,
        Boolean doInsert
    ) {
        ZTS_AccountTerritory__c acctTerritory = new ZTS_AccountTerritory__c();
        acctTerritory.ZTS_EU_Account__c = acct.Id;
        acctTerritory.ZTS_SIB_Flag__c = sibFlag;
        acctTerritory.ZTS_EU_Territory__c = territory.Id;
        if (doInsert) {
            insert acctTerritory;
        }
        return acctTerritory;
    }
    
    public static ZTS_EU_Position__c createZoetisPosition(User user, ZTS_EU_Territory__c territory, Boolean doInsert) {
        ZTS_EU_Position__c position = new ZTS_EU_Position__c();
        
        position.ZTS_EU_Employee__c = user.Id;
        position.ZTS_EU_Territory__c = territory.Id;
        if (doInsert) {
            insert position;
        }
        return position;
    }
    
    private static ZTS_EU_Position__c buildPosition(){
        ZTS_EU_Position__c record = new ZTS_EU_Position__c();
        record.ZTS_EU_Is_Active__c = true;
        record.ZTS_EU_Type__c = 'Sales';
        record.ZTS_Processed__c = false;
        record.ZTS_PrimaryUser__c = false;
        
        return record;
    }
    
    public static ZTS_EU_Position__c createPosition(String name, Id ztsTerritoryId, String market, Boolean shouldInsert){
        ZTS_EU_Position__c record = buildPosition();
        record.Name = name;
        record.Market__c = market;
        record.ZTS_EU_Territory__c = ztsTerritoryId;
        
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    public static ZTS_EU_Position__c createPosition(String name, Id ztsTerritoryId, String market, Id userId, Boolean shouldInsert){
        ZTS_EU_Position__c record = createPosition(name, ztsTerritoryId, market, false);
        record.ZTS_EU_Employee__c = userId;
        record.ZTS_EU_Is_Active__c = true;
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    private static ZTS_AccountTerritory__c buildAccountTerritory(){
        ZTS_AccountTerritory__c record = new ZTS_AccountTerritory__c();
        record.ZTS_ChangeFlag__c = 'Insert';
        record.ZTS_Processed__c = true;        
        return record;
    }
    
    public static ZTS_AccountTerritory__c createAccountTerritory(Id acctId, Id territoryId,Boolean shouldInsert){
        ZTS_AccountTerritory__c record = buildAccountTerritory();
        record.ZTS_EU_Account__c = acctId;
        record.ZTS_EU_Territory__c = territoryId;
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    private static ZTS_EU_Account_Position__c buildAccountPosition(){
        ZTS_EU_Account_Position__c record = new ZTS_EU_Account_Position__c();
        record.Exclude_Sales__c = false;
        record.Field_Force_Name_Text__c = 'Test AP';
        record.ZTS_EU_Active__c = true;
        return record;
    }
    
    public static ZTS_EU_Account_Position__c createAccountPosition(Id accountId, Id territoryId, Boolean shouldInsert){
        ZTS_EU_Account_Position__c record = buildAccountPosition();
        record.ZTS_EU_Account__c = accountId;
        record.ZTS_AccountTerritory__c = territoryId;
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    public static State_Country__c createStateCountry(String country, String uniqueCounty, Boolean shouldInsert){
        State_Country__c sc = new State_Country__c(); 
        sc.Name = uniqueCounty;
        sc.ZTS_EU_Country__c = country;    
        sc.ZTS_EU_uniqueCOUNTY__c = uniqueCounty;
        if(shouldInsert){
            insert sc;
        }
        return sc;
    }
    
    public static VetSave_Market__c createVetSaveMarket(String name, Boolean shouldInsert){
        VetSave_Market__c record = new VetSave_Market__c();
        record.Name = name;
        record.Market__c = name;
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    public static Vetsave_UK__c createVetSaveMarket_UK(String name,Boolean shouldInsert){
        Vetsave_UK__c record = new Vetsave_UK__c();
        record.Name = name;
        record.Market__c = name;
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    public static Contact buildContact(){
        Contact record = new Contact();
        record.FirstName = 'TestFirstName';
        record.LastName = 'TestLastName';
        record.ZTS_US_Profession__c='Executive Leadership';
        record.ZTS_US_Job_Function__c='CEO/President';
        return record;
    }
    
    public static Contact createContact(Id accountId, Boolean shouldInsert){
        Contact record = buildContact();
        record.AccountId = accountId;
        
        if(shouldInsert){
            insert record;
        }
        return record;
    }
    
    public static List<Contact> createContacts(Id accountId, Integer contactCount, Boolean shouldInsert){
        List<Contact> records = new List<Contact>();
        for(Integer i = 0;i<contactCount;i++){
            Contact record = buildContact();    
            record.AccountId = accountId;
            records.add(record);
        }
        if(shouldInsert){
            insert records;
        }
        return records;
    }
    
    public static User buildUser(){
        Integer randomNumber = Math.abs(Crypto.getRandomInteger());
        String uniqueEmail = 'user' + String.valueOf(randomNumber) + '@testorg.com';        
        User user = new User(
            Alias = 'testUsr', 
            Email=uniqueEmail, 
            FirstName = 'TestUserFirst', 
            EmailEncodingKey='UTF-8', 
            LastName='TestUserLast', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US',  
            TimeZoneSidKey='America/New_York', 
            Username=uniqueEmail,
            CurrencyIsoCode='EUR', 
            ZTS_EU_Market__c='Brazil',
            Default_Country__c='Brazil', 
            Country='Brazil'
        );
        
        return user;
    }
    
    public static User createUser(Id profileId, Id roleId, Id contactId, Boolean shouldInsert){
        User user = buildUser();
        user.ProfileId = profileId;
        user.UserRoleId = roleId;
        user.ContactId = contactId;
        
        if(shouldInsert){
            insert user;
        }
        return user;
    }
    
    public static User createUser(Id profileId, Boolean shouldInsert){
        return createUser(profileId, null, null, shouldInsert);
    }
    
    public static List<Address__c> createAddresses(integer numAddresses, Id accountId) {
        List<Address__c> addresses = new List<Address__c>();
        
        for (integer i = 0; i < numAddresses; i++) {
            addresses.add(new Address__c(
                Name = string.format('Test Address {0}', new List<Object> {i}),
                ZTS_EU_Account__c = accountId
            ));
        }
        
        return addresses;
    }
    
    private static Call__c buildCall(){
        Call__c call = new Call__c();
        call.Name = 'Test Call';        
        call.ZTS_EU_Sub_Type__c = 'Account Call';
        call.ZTS_EU_Start_Date_Time__c = system.now();
        call.ZTS_EU_End_Date_Time__c = system.now().addMinutes(30);
        call.ZTS_EU_Status__c = 'Planned';
        call.ZTS_EU_Duration__c = '0.5 Hour';
        
        return call;
    }
    
    public static Call__c createCall(Id accountId,Boolean shouldInsert){
        Call__c call = BuildCall();
        call.ZTS_EU_Account__c = accountId;
        
        if (shouldInsert){
            insert call;
        }
        return call;
    }
    
    public static ZTS_EU_Colleague__c createColleague(Id callId, Id userId) {
        return new ZTS_EU_Colleague__c(Name = 'Test Colleague',
                                       ZTS_EU_Call__c = callId, 
                                       ZTS_EU_User__c = userId);
    }
    
    public static List<Contract> createContracts(integer numContract, Id accountId, Id recordTypeId) {
        List<Contract> contracts = new List<Contract>();
        for (integer i = 0; i < numContract; i++) {
            contracts.add(new Contract(
                Name = string.format('Test Contract {0}', new List<Object> {i}),
                AccountId = accountId,
                RecordTypeId = recordTypeId,
                Status = 'Draft'
            ));
        }
        
        return contracts;
    }
    
    public static Batch_Detail__c batchDetail(Id cp){
        Batch_Detail__c bd = new Batch_Detail__c(); 
        bd.ZTS_US_Case_Product__c=cp;
        bd.ZTS_US_Primary__c=true;
        bd.ZTS_US_Product_Lot__c = 'cp.ZTS_US_Product_Lot__c';
        
        return bd;
    }
    
    public static ZTS_US_Case_Product__c createCaseProduct(Id caseId,Id productId,Id recordTypeId){
        return new ZTS_US_Case_Product__c(ZTS_US_Case__c = caseId,
                                          ZTS_US_PVW_Product__c = productId,
                                          ZTS_US_Product_problem_type__c = 'Adverse Reaction',
                                          ZTS_US_Product_Used_Correctly__c= 'Yes',
                                          ZTS_US_Serial_Number__c = 'test',                                                                        
                                          RecordTypeId = recordTypeId
                                         );
    }
    
    public static Case createCase(Id recordTypeId){
        return new Case(Status = 'Open',
                        Origin = 'Email',
                        Type = 'Animal Complaint',
                        RecordTypeId = recordTypeId);
    }
    public static ZTS_US_PVW_Product__c createProduct(){
        return  new ZTS_US_PVW_Product__c(Name = 'Simparica Test',
                                          CurrencyIsoCode='USD',
                                          ZTS_US_MAH_Country__c = 'US',
                                          ZTS_US_Active_Product__c = 'Yes');
    }
    
    // Retrieve the first active value for a Picklist.
    // Use this method when a picklist needs to be populated for data purposes, but the value does not matter.
    public static String retrieveFirstActivePicklistValue(string objectName, string fieldName) {
        Schema.DescribeSObjectResult typeInfo = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.SObjectField fieldInfo = typeInfo.fields.getMap().get(fieldName);
        List<Schema.PicklistEntry> pickListValues = fieldInfo.getDescribe().getPicklistValues();
        
        for (Schema.PicklistEntry pickListValue : pickListValues) {
            if (pickListValue.isActive()) {
                return pickListValue.value;
            }
        }
        
        return null;
    }
    
    public static City_State__c createCityState(String name, Id stateCountryId, Boolean shouldInsert) {
        City_State__c cityState = new City_State__c(
            Name = name,
            ZTS_EU_State_County__c = stateCountryId
        );
        
        if (shouldInsert) {
            insert cityState;
        }
        
        return cityState;
    }
    
    public static Order createOrder(Id accountId, Boolean shouldInsert) {
        Order order = new Order(AccountId = accountId, 
                                EffectiveDate = System.today(), 
                                Status = 'Draft');
        
        if (shouldInsert) {
            insert order;
        }
        
        return order;
    }
    
    //Create Competency Model
    public static List<Competency_Model__c> createCompetencyModels(integer numCompetencyModels) {
        List<Competency_Model__c> competencyModels = new List<Competency_Model__c>();
        
        for (Integer i = 0; i < numCompetencyModels; i++) {
            competencyModels.add(new Competency_Model__c(
                Status__c='Active',
                Name = String.format('Test Model - {0}', new List<Object> {i})
            ));
        }
        
        return competencyModels;
    }
    
    //Create Competency Group
    public static List<Competency_Group__c> createCompetencyGroups(integer numCompetencyGrp, String Market, String Role) {
        List<Competency_Group__c> lstCompetencyGrp = new List<Competency_Group__c>();
        
        for (Integer i = 0; i < numCompetencyGrp; i++) {
            lstCompetencyGrp.add(new Competency_Group__c(               
                Market__c = Market,
                Role__c = Role               
            ));
        }        
        return lstCompetencyGrp;
    }
    
    //Create Competency Group Assignments
    public static List<Competency_Group_Assignment__c> createCompetencyGrpAssignments(integer numCompetencyGrpAssign, List<Competency_Model__c> lstCompetencyModel, List<Competency_Group__c> lstCompetencyGroup) {
        List<Competency_Group_Assignment__c> lstCompetencyGrpAssign = new List<Competency_Group_Assignment__c>();
        
        for (Integer i = 0; i < numCompetencyGrpAssign; i++) {
            lstCompetencyGrpAssign.add(new Competency_Group_Assignment__c(               
                Competency_Group__c = lstCompetencyGroup[i].Id,
                Competency_Model__c = lstCompetencyModel[i].id           
            ));
        }        
        return lstCompetencyGrpAssign;
    }
    
    //create Competencies
    public static List<Competency__c> createCompetencies(integer numCompetencies, Id competencyModelId) {
        List<Competency__c> competencies = new List<Competency__c>();
        
        for (Integer i = 0; i < numCompetencies; i++) {
            competencies.add(new Competency__c(
                Name = String.format('Competency - {0}', new List<Object> {i}),
                Order__c = 1,
                Learning_Description__c = 'Learning Test',
                Applying_Description__c = 'Applying Test',
                Mastery_Description__c = 'Mastery Test',
                Status__c='Active',
                Competency_Model__c = competencyModelId
            ));
        }
        
        return competencies;
    }
    
    //Create Skills
    public static List<Skill__c> createSkills(integer numSkills, Id competencyId) {
        List<Skill__c> skills = new List<Skill__c>();
        
        for (Integer i = 0; i < numSkills; i++) {
            skills.add(new Skill__c(
                Name__c = String.format('Skill - {0}', new List<Object> {i}),
                Learning_Description__c = 'Learning Test',
                Applying_Description__c = 'Applying Test',
                Mastery_Description__c = 'Mastery Test',
                Competency__c = competencyId,
                Status__c='Active',
                Order__c = 1
            ));
        }
        
        return skills;
    }
    
    public static List<Benchmark__c> createBenchmarks(integer numBenchmarks, Id coacheeId, Id ownerId) {
        List<Benchmark__c> benchmarks = new List<Benchmark__c>();
        
        for (integer i = 0; i < numBenchmarks; i++) {
            benchmarks.add(new Benchmark__c(
                OwnerId = ownerId,
                Coachee__c = coacheeId
            ));
        }
        
        return benchmarks;
    }
    //Created Knowledge Article Testdata
    public static List<FAQ__kav> createKnowledgeArticle(integer numKA, String KATitle, String KASummary, String KAAnswer, String KAUrlName) {
        List<FAQ__kav> lstKnowledgeArticle = new List<FAQ__kav>(); 
        for (integer i = 0; i < numKA; i++) { 
            lstKnowledgeArticle.add(new FAQ__kav(
                Title = KATitle,
                Summary = KASummary,
                Answer__c = KAAnswer,
                UrlName = KAUrlName 
            ));
            
        } 
        return lstKnowledgeArticle; 
    } 
    //Created ContentVersion Testdata
    public static List<ContentVersion> createContentVersion(integer numKA, String KATitle, String KAPathOnClient, String KAVersionData, Boolean KAIsMajorVersion) {
        List<ContentVersion> lstContentVersion = new List<ContentVersion>(); 
        for (integer i = 0; i < numKA; i++) { 
            lstContentVersion.add(new ContentVersion(
                Title = KATitle,
                PathOnClient = KAPathOnClient,
                VersionData = Blob.valueOf(KAVersionData),
                IsMajorVersion = KAIsMajorVersion
                
            ));
        } 
        return lstContentVersion; 
    } 
    //Created ContentDocumentLink Testdata 
    public static List<ContentDocumentLink> createContentDocumentLink(integer numKA, String KALinkedEntityId, String  KAContentDocumentId,String KAshareType) {
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>(); 
        for (integer i = 0; i < numKA; i++) { 
            lstContentDocumentLink.add(new ContentDocumentLink(
                LinkedEntityId = KALinkedEntityId,
                ContentDocumentId = KAContentDocumentId,
                shareType = KAshareType
                
                
            ));
        } 
        return lstContentDocumentLink; 
    } 
 
    
    
    
    
    public static List<Observation__c> createObservations(integer numObservations, Id benchmarkId, String type) {
        List<Observation__c> observations = new List<Observation__c>();
        
        for (integer i = 0; i < numObservations; i++) {
            observations.add(new Observation__c(
                Benchmark__c = benchmarkId,
                Type__c = type
            ));
        }
        
        return observations;
    }
    
    // Create a single record so Score can be set differently
    public static Observed_Competency__c createObservedCompetency(Id competencyId, Id skillId, String score, Id observationId) {
        return new Observed_Competency__c(
            Competency__c = competencyId,
            Skill__c = skillId,
            Score__c = score,
            Observation__c = observationId
        );
    }
    
    public static List<Lesson_Template__c> createLessonTemplates(integer numTemplates, Id competencyId, Id skillId, String language) {
        List<Lesson_Template__c> lessonTemplates = new List<Lesson_Template__c>();
        
        for (integer i = 0; i < numTemplates; i++) {
            lessonTemplates.add(new Lesson_Template__c(
                Name = String.format('Test Lesson {0}', new List<Object>{i}),
                Competency__c = competencyId,
                Skill__c = skillId,
                Language__c = language,
                URL__c = 'https://ww.zoetis.com',
                Description__c = 'Test Lesson Descrpition',
                Threshold_Rating__c = 4
            ));
        }
        
        return lessonTemplates;
    }
    
    public static Lesson__c createLesson(String name, Id lessonTemplateId, Id observedCompetencyId) {
        return new Lesson__c(
            Name = name,
            Lesson_Template__c = lessonTemplateId,
            Observed_Competency__c = observedCompetencyId
        );
    }
    
    public static Data_Translation__c createDataTranslation(Id competencyId, Id skillId, string translationName, String language) {
        return createDataTranslation(competencyId, skillId, null, translationName, language);
    }
    
    public static Data_Translation__c createDataTranslation(Id competencyId, Id skillId, Id competencyModelId, string translationName, String language) {
        return new Data_Translation__c(
            Competency__c = competencyId,
            Skill__c = skillId,
            Competency_Model__c = competencyModelId,
            Name__c = translationName,
            Language__c = language
        );
    }
    
    public static List<Lead> createLeadRec(Integer count){
        List<Lead> leadList = new List<Lead>();
        for(Integer i=0;i<count;i++){
            Lead ld = new Lead();
            ld.FirstName = 'US';
            ld.LastName = 'QATEST';
            ld.Lead_Assignment_Processed__c = false;
            ld.State = 'mt';
            ld.Status = 'Open';
            ld.Company='New Online company api test1';
            leadList.add(ld);
        }
        return leadList;
    }
    
    public static Veterinarian_Information__c createVetInformationRec(Id leadId){
        return new Veterinarian_Information__c (
            Lead__c = leadId,
            Veterinarian_Email__c='testZoetis@Zoetis.com');
    }
    
    public static echosign_dev1__SIGN_Data_Mapping__c createEchoSigndev1SignDataMapping(String name){
        return new echosign_dev1__SIGN_Data_Mapping__c (Name =name);
    }
    
    public static List<echosign_dev1__SIGN_Agreement__c> createEchoSignDev1SignAgreement(Integer count){
        List<echosign_dev1__SIGN_Agreement__c> echoSignAgreeList = new List<echosign_dev1__SIGN_Agreement__c>();
        for(Integer i=0;i<count;i++){
            echosign_dev1__SIGN_Agreement__c echo = new echosign_dev1__SIGN_Agreement__c();
            echoSignAgreeList.add(echo);
        }
        return echoSignAgreeList;
        
    }
    
    public static List<NOA_Financially_Authorized_Person__c> createFinanciallyAuthorizedPerson(Integer count,Id leadId){
        List<NOA_Financially_Authorized_Person__c> noaAuthPersonList = new List<NOA_Financially_Authorized_Person__c>();
        for(Integer i=0;i<count;i++){
            NOA_Financially_Authorized_Person__c noa = new NOA_Financially_Authorized_Person__c();
            noa.Lead__c = leadId;
            noaAuthPersonList.add(noa);
        }
        return noaAuthPersonList;
    }

    public static Vet_Information_Shipping_Address__c createVetShippingAddress(Id vetId, Id shippingAddressId) {
        return new Vet_Information_Shipping_Address__c(
            Veterinarian_Information__c = vetId,
            Shipping_Address__c = shippingAddressId
        );
    }
    
    public static List<Address__c> createAddressesWithLead(integer numAddresses, Id leadId) {
        List<Address__c> addresses = new List<Address__c>();
        
        for (integer i = 0; i < numAddresses; i++) {
            addresses.add(new Address__c(
                Name = string.format('Test Address {0}', new List<Object> {i}),
                Lead__c = leadId
            ));
        }
        
        return addresses;
    }
    
    public static iCoach_Form__c createiCoachFormRec(){
        return new iCoach_Form__c (Date_From__c = System.Today(),
                                  Was_the_Coaching_Customer_Facing__c = 'Yes',
                                  The_Coaching_Was__c='Virtual');
    }
    
    public static list<iCoach_Form_Objective__c> createiCoachFormObjectives(integer numOfiCoahcFormObjects, Id icoachFormId,List<Competency_Model__c> competencyModels,List<Competency__c>competencies){
        list<iCoach_Form_Objective__c> iCoahcFormObjectiveList = new list<iCoach_Form_Objective__c>();
        
        for(Integer i=0;i<numOfiCoahcFormObjects;i++){
            iCoahcFormObjectiveList.add(new iCoach_Form_Objective__c(
                iCoach_Form__c = icoachFormId,
                Competency_Model__c = competencyModels[i].id,
                Competency__c = competencies[i].id
            ));
        }
        return iCoahcFormObjectiveList;
    }
    
    public static List<Action_Plan__c> createActionPlan(Integer numOfActionplan,Id icoachFormId, list<iCoach_Form_Objective__c>iCoahcFormObjectiveList){
        List<Action_Plan__c> actionPlanList = new List<Action_Plan__c>();
        for(Integer i=0; i<numOfActionplan;i++){
            actionPlanList.add(new Action_Plan__c(
               iCoach_Form__c = icoachFormId,
               iCoach_Form_Objective__c = iCoahcFormObjectiveList[i].id
            ));
        }
        return actionPlanList;
    }
}