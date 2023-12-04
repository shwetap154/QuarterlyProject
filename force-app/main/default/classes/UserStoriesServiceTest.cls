/**
 * @description       : Test Class for UserStoriesService
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 01-03-2023
 * @last modified by  : Padma Nerella @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   12-16-2021   Namrata Patane @ Zoetis Inc   Initial Version
 * 1.1   12-17-2021   Morgan Marchese @ Zoetis Inc  Additional Methods, formatting
 * 1.2   12-22-2021   Morgan Marchese @ Zoetis Inc  Reworked Test Class to support changes to logic
 * 1.3   01-03-2023   Padma Nerella @ Zoetis Inc    Added addtional logic to approvals_Test TPDev-75
 **/

@isTest
public class UserStoriesServiceTest {
  @testSetup
  public static void setUpData() {
    List<copado__User_Story__c> lstUS = new List<copado__User_Story__c>();
    List<copado__Environment__c> lstEnv = new List<copado__Environment__c>();
    String Metadatalst;
    for (Integer i = 0; i < 5; i++) {
      copado__Environment__c objEnv = new copado__Environment__c();
      objEnv.Name = 'TestEnv ' + i;
      objEnv.Approval_Level_Required__c = 'Merge';
      lstEnv.add(objEnv);
    }
    insert lstEnv;
    List<Environment_Metadata_Approval__c> envMetadataBefore = [
      SELECT Id
      FROM Environment_Metadata_Approval__c
    ];
    // Delete the automatically created Metadata Approval records for testing purposes
    delete envMetadataBefore;

    List<Environment_Metadata_Approval__c> lstEnvMetadata = new List<Environment_Metadata_Approval__c>();
    Environment_Metadata_Approval__c metadata;
    copado__User_Story__c objUS;
    for (copado__Environment__c env : lstEnv) {
      objUS = new copado__User_Story__c();
      objUS.copado__User_Story_Title__c = 'US ' + env.Name;
      objUS.copado__Environment__c = env.Id;

      if (env.Name.contains('0')) {
        // Requires Approval
        metadata = new Environment_Metadata_Approval__c();
        metadata.Environment__c = env.Id;
        metadata.Metadata_Type__c = 'ApexClass';
        metadata.Additional_Approval_Required__c ='Architect';
        lstEnvMetadata.add(metadata);
        objUS.copado__Metadata_Types_in_Selection__c = 'ApexClass;Flow';
      } else if (env.Name.contains('1')) {
        // Requires Approval
        objUS.copado__Metadata_Types_in_Selection__c = 'ApexPage;Flow';
        for (Integer i = 0; i < 3; i++) {
          metadata = new Environment_Metadata_Approval__c();
          metadata.Environment__c = env.Id;
          if (i == 0) {
            metadata.Metadata_Type__c = 'ApexPage';
          } else if (i == 1) {
            metadata.Metadata_Type__c = 'ApexClass';
            metadata.Additional_Approval_Required__c ='Architect';
          } else if (i == 2) {
            metadata.Metadata_Type__c = 'ApexComponent';
            metadata.Additional_Approval_Required__c ='Architect';
          }
          lstEnvMetadata.add(metadata);
        }
      } else if (env.Name.contains('2')) {
        // does not require approval
        objUS.copado__Metadata_Types_in_Selection__c = 'Profile;Flow;ApexComponent';
        metadata = new Environment_Metadata_Approval__c();
        metadata.Environment__c = env.Id;
        metadata.Metadata_Type__c = 'ApexPage';
        lstEnvMetadata.add(metadata);
      } else if (env.Name.contains('3')) {
        // requires approval
        objUS.copado__Metadata_Types_in_Selection__c = 'UnknownType;Translations;Profile';
        for (Integer i = 0; i < 4; i++) {
          metadata = new Environment_Metadata_Approval__c();
          metadata.Environment__c = env.Id;
          if (i == 0) {
            metadata.Metadata_Type__c = 'ApexTrigger';
          } else if (i == 1) {
            metadata.Metadata_Type__c = 'Flow';
          } else if (i == 2) {
            metadata.Metadata_Type__c = 'Workflow';
          } else if (i == 3) {
            metadata.Metadata_Type__c = 'ApexComponent';
          }
          lstEnvMetadata.add(metadata);
        }
      } else if (env.Name.contains('4')) {
        // Requires Approval
        objUS.copado__Metadata_Types_in_Selection__c = 'Profile;ApexClass';

        metadata = new Environment_Metadata_Approval__c();
        metadata.Environment__c = env.Id;
        metadata.Metadata_Type__c = 'Profile';
        lstEnvMetadata.add(metadata);
      }
      lstUS.add(objUS);
    }

    // Create a Copado Release Record that is Frozen for Frozen Release Test
    copado__Release__c release = new copado__Release__c();
    release.Name = 'Frozen Release Test';
    release.Metadata_Freeze_Start_Date__c = System.today().addDays(-5);
    release.Metadata_Freeze_End_Date__c = System.today().addDays(20);
    insert release;

    // Create User Story linked to the Frozen Release for Frozen Release Test
    copado__User_Story__c freezeStory = new copado__User_Story__c();
    freezeStory.copado__User_Story_Title__c = 'Copado Frozen Release Story';
    freezeStory.copado__Environment__c = lstEnv[0].Id;
    freezeStory.copado__Release__c = release.Id;

    // Add Freeze Story to existing DML for User Stories
    lstUS.add(freezeStory);

    insert lstEnvMetadata;
    insert lstUS;

    List<copado__User_Story_Metadata__c> lstUserStoryMetadata = new List<copado__User_Story_Metadata__c>();
    // Create User Story Metadata related to Frozen Release Record
    for(Integer i=0;i<5;i++){
      copado__User_Story_Metadata__c metadataRecord = new copado__User_Story_Metadata__c();
      metadataRecord.Name = freezeStory.Name + ' StoryMetadataTestRecord ' + i;
      //metadataRecord.copado__Unique_Id__c = freezeStory.Name + ' StoryMetadataTestRecord ' + i;
      metadataRecord.copado__User_Story__c = freezeStory.Id;
      metadataRecord.copado__Metadata_API_Name__c = 'ApexClass.StoryMetadataTestRecord' + i;
      lstUserStoryMetadata.add(metadataRecord);
    }

    insert lstUserStoryMetadata;
  }

  static testMethod void approvals_Test() {
    List<copado__User_Story__c> lstUS = [
      SELECT Id, copado__Environment__c, copado__Metadata_Types_in_Selection__c,Additional_Approval_Required__c
      FROM copado__User_Story__c
    ];

    Test.startTest();
    update lstUS;
    Test.stopTest();

    lstUS = [
      SELECT Id, Metadata_Approval_Required__c,Additional_Approval_Required__c
      FROM copado__User_Story__c WHERE copado__User_Story_Title__c != 'Copado Frozen Release Story'
    ];

    Integer approvalCount = 0;
    Integer noApprovalCount = 0;
    Integer architectApprovalCount = 0;
    Integer noarchitectApprovalCount = 0;

    for (copado__User_Story__c story : lstUS) {
      if (story.Metadata_Approval_Required__c) {
        approvalCount++;
      } else {
        noApprovalCount++;
      }
      if(story.Additional_Approval_Required__c!=null && story.Additional_Approval_Required__c.contains('Architect')){
        architectApprovalCount++;

      } else{
        noarchitectApprovalCount++;
      }
    }
    System.assertEquals(4, approvalCount);
    System.assertEquals(1, noApprovalCount);
    System.assertEquals(2, architectApprovalCount);
    System.assertEquals(3, noarchitectApprovalCount);
  }

  @isTest
  static void frozenRelease_Test(){
    // Query Frozen Release
    copado__Release__c release = [SELECT Id FROM copado__Release__c WHERE Name = 'Frozen Release Test'];

    // Create User Story not tied to this release
    copado__User_Story__c story = new copado__User_Story__c();
    story.copado__User_Story_Title__c = 'Test for Frozen Record';
    insert story;

    // Add User Story Metadata to this Story which is linked to the Frozen Release
    copado__User_Story_Metadata__c metadata = new copado__User_Story_Metadata__c();
    metadata.Name = story.Name + ' Frozen Metadata Test';
    //metadata.copado__Unique_Id__c = story.Name + ' StoryMetadataTestRecord 0';
    metadata.copado__User_Story__c = story.Id;
    metadata.copado__Metadata_API_Name__c = 'ApexClass.StoryMetadataTestRecord0';
    insert metadata;

    // Re-query Story and Validate Results

    story = [SELECT Id,Frozen_By__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'Test for Frozen Record' LIMIT 1];
    System.assertEquals(release.Id, story.Frozen_By__c,'Story should be Frozen by the Release');

  }
}