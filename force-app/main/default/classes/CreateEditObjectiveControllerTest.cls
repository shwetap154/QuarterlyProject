@isTest
public class CreateEditObjectiveControllerTest {
    //Test Data Factory
    private static void setup() {
        // Create test Competency Model
        Competency_Model__c testModel = new Competency_Model__c(Name = 'Test Model');
        insert testModel;

        // Create test Competency
        Competency__c testCompetency = new Competency__c(Name = 'Test Competency', Competency_Model__c = testModel.Id, Order__c = 3);
        insert testCompetency;

        // Create test Skill
        Skill__c testSkill = new Skill__c(Name__c = 'Test Skill', Competency__c = testCompetency.Id, Order__c = 3);
        insert testSkill;

        // Create test iCoach Form
        iCoach_Form__c testForm = new iCoach_Form__c(Name = 'Test Form', Date_From__c = Date.newInstance(2023, 12, 8), Was_the_Coaching_Customer_Facing__c = 'Yes', The_Coaching_Was__c= 'Non-Virtual');
        insert testForm;

        // Create test Objective
        iCoach_Form_Objective__c testObjective = new iCoach_Form_Objective__c(
            iCoach_Form__c = testForm.Id,
            Competency_Model__c = testModel.Id,
            Competency__c = testCompetency.Id,
            Skill__c = testSkill.Id,
            Rating__c = '5',
            Comments__c = 'Test Comments'
        );
        insert testObjective;
    }
    
    // Test method for getiCoachObjectiveReleatediCoachForm
    @isTest
    static void testGetiCoachObjectiveReleatediCoachForm() {
        setup();
        Test.startTest();
        List<iCoach_Form_Objective__c> result = createEditiCoachFormObjectiveController.getiCoachObjectiveReleatediCoachForm('');
        System.assertNotEquals(0, result.size(), 'Expected records not found');
        Test.stopTest();   
    }
    
    // Test method for getPreviousScore
    @isTest
    static void testGetPreviousScore(){
        setup();
        Test.startTest();
        Map<String, String> result = createEditiCoachFormObjectiveController.getPreviousScore('RecordId', 'CompetencyModalId', 'CompetencyId', 'SkillId');
        System.assertEquals(0, result.size(), 'Map should be empty as no records were found');
        Test.stopTest();
    }
    
    // Test method for getCompetencyModels
    @isTest
    static void testGetCompetencyModels(){
        setup();
        Test.startTest();
        List<createEditiCoachFormObjectiveController.compentencyModelWithCompetenciesAndSkills> result = createEditiCoachFormObjectiveController.getCompetencyModels('aEA7h000000CcXNGA0');
        System.assertNotEquals(0, result.size(), 'Expected competency models not found');
        Test.stopTest();
    }
    

    @isTest
    static void testGetCompetencies(){
        setup();
        Test.startTest();
        List<Competency__c> result = createEditiCoachFormObjectiveController.getCompetencies('CompetencyModelId');
        System.assertNotEquals(0, result.size(), 'Expected competencies not found');
        Test.stopTest();
    }
    
    // Test method for getSkills
    @isTest
    static void testGetSkills(){
        setup();
        Test.startTest();
        List<Skill__c> result = createEditiCoachFormObjectiveController.getSkills('CompetencyId');
        System.assertNotEquals(0, result.size(), 'Expected skills not found');
        Test.stopTest();  
    }
    
    // Test method for CreateiCoachFormObjectiveRecord
    @isTest
    static void testCreateiCoachFormObjectiveRecord(){
        setup();
        Test.startTest();
        createEditiCoachFormObjectiveController.FormObjectiverWrapper testPayload = new createEditiCoachFormObjectiveController.FormObjectiverWrapper();
        String result = createEditiCoachFormObjectiveController.CreateiCoachFormObjectiveRecord(JSON.serialize(testPayload));
        System.assertNotEquals(null, result, 'Record creation failed');
        Test.stopTest();
    }
    
    // Test method for SaveiCoachFormObjectiveRecord
    @isTest
    static void testSaveiCoachFormObjectiveRecord() {
        setup();
        Test.startTest();
        createEditiCoachFormObjectiveController.FormObjectiverWrapper testPayload= new createEditiCoachFormObjectiveController.FormObjectiverWrapper();
        String upsertPayload = JSON.serialize(new List<createEditiCoachFormObjectiveController.FormObjectiverWrapper>{testPayload});
        createEditiCoachFormObjectiveController.saveiCoachFormObjectiveRecord(upsertPayload, null);
        Test.stopTest();
    }
    
    // Test method for UpdateiCoachFormObjectiveRecord
    @isTest
    static void testUpdateiCoachFormObjectiveRecord() {
        setup();
        Test.startTest();
        createEditiCoachFormObjectiveController.UpdateFormObjectiverWrapper testPayload = new createEditiCoachFormObjectiveController.UpdateFormObjectiverWrapper();
        String payloadForm = JSON.serialize(testPayload);
        String result = createEditiCoachFormObjectiveController.UpdateiCoachFormObjectiveRecord(payloadForm);
        System.assertNotEquals(null, result, 'Record update failed');
        Test.stopTest();
    }
    
    // Test method for getRelatedObjectives
    @isTest
    static void testGetRelatedObjectives() {
        setup();
        Test.startTest();
        List<iCoach_Form_Objective__c> result = createEditiCoachFormObjectiveController.getRelatedObjectives('RecordId');
        System.assertNotEquals(0, result.size(), 'Expected objectives not found');
        Test.stopTest();
    }
}