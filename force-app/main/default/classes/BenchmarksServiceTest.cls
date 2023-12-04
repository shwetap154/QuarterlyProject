/**
* @description       : Test class for Benchmark Trigger 
* @author            : Raut, Pranav Krushnarao @ Zoetis Inc
* @group             : 
* @last modified on  : 06-10-2023
* @last modified by  : Nayak, Kalyan @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   03-03-2023   Raut, Pranav Krushnarao     Added setupData and benchmarkMarkCompleteValidationsTest method to 
												 test the Benchmark after mark complete functionality.
* 1.1	06-10-2023	 Nayak, Kalyan				 Added benchmarkMarkCompleteValidationsTest3 method to test if we have 
												 Draft and Active Competencies for an active Competency Model then also
												 it should allow to complete the Benchmark.
**/
@isTest 
public class BenchmarksServiceTest {
    
    //----------setupData start----------------
    @testSetup 
    public static void setupData() {
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User coach = TestDataFactory.createUser(adminProfileId, false);
        insert coach;
        
        User coachee = TestDataFactory.createUser(adminProfileId, false);
        coachee.ManagerId = coach.Id;
        insert coachee;
        // Competency model records        
       List<Competency_Model__c> competencyModelList = new List<Competency_Model__c>();
         Competency_Model__c objCompetencymodel = new Competency_Model__c();
         objCompetencymodel.Name = 'competencymodeltest';
         objCompetencymodel.Status__c='Active';
         competencyModelList.add(objCompetencymodel);
         
         //Second Record
         Competency_Model__c objCompetencymodel2 = new Competency_Model__c();
         objCompetencymodel2.Name = 'competencymodeltest1';
         objCompetencymodel2.Status__c='Active';
         competencyModelList.add(objCompetencymodel2);
        
        insert competencyModelList;
                
        //Competency group records
        Competency_Group__c objCompetencyGroup = new Competency_Group__c();
        objCompetencyGroup.Market__c = 'Ukraine';
        objCompetencyGroup.Role__c = 'TBM;ABM';
        insert objCompetencyGroup;
        
        Competency_Group__c objCompetencyGroup2 = new Competency_Group__c();
        objCompetencyGroup2.Market__c = 'Canada';
        objCompetencyGroup2.Role__c = 'BUD';
        insert objCompetencyGroup2;
        
        //Competency Group Assignment records
        Competency_Group_Assignment__c objComGroupAssign = new Competency_Group_Assignment__c();
        objComGroupAssign.Competency_Group__c = objCompetencyGroup.Id;
        objComGroupAssign.Competency_Model__c = objCompetencymodel.id;
        insert objComGroupAssign;
        
        Competency_Group_Assignment__c objComGroupAssign2 = new Competency_Group_Assignment__c();
        objComGroupAssign2.Competency_Group__c = objCompetencyGroup2.Id;
        objComGroupAssign2.Competency_Model__c = objCompetencymodel2.id;
        insert objComGroupAssign2;
        
        //Competency records
        Competency__c objCompetency = new Competency__c();
        objCompetency.Order__c = 1;
        objCompetency.Name = 'Competencytest';
        objCompetency.Competency_Model__c = objCompetencymodel.id;
        objCompetency.Status__c = 'Active';
        insert objCompetency;
        
        List<Competency__c> listCompetencies = new List<Competency__c>();
        Competency__c objCompetency2 = new Competency__c();
        objCompetency2.Order__c = 2;
        objCompetency2.Name = 'Competencytest2';
        objCompetency2.Competency_Model__c = objCompetencymodel2.id;
        objCompetency2.Status__c = 'Active';
        listCompetencies.add(objCompetency2);
        
        Competency__c objCompetency3 = new Competency__c();
        objCompetency3.Order__c = 3;
        objCompetency3.Name = 'Competencytest2';
        objCompetency3.Competency_Model__c = objCompetencymodel2.id;
        objCompetency3.Status__c = 'Draft';
        listCompetencies.add(objCompetency3);
        //inserted 2 Competencies to one Competency Model
        insert listCompetencies;
    }
    
    //------------setupData End-------------------   
    
    //Testing Positive Scenarios of benchmarkMarkCompleteValidations method in Benchmark Trigger 
    @isTest
    public static void benchmarkMarkCompleteValidationsTest(){
        Test.startTest();
        try{
            //Benchmark record
            Benchmark__c objBenchmark = new Benchmark__c();
            objBenchmark.Market__c = 'Albania';
            objBenchmark.Role__c = 'SAM';
            objBenchmark.Status__c = 'Started';        
            insert objBenchmark;
            
            objBenchmark.Status__c = 'Completed';        
            update objBenchmark;
            
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Completed_Benchmark_Validations_Error_Message), 'message=' + message);
        }
        Test.StopTest();       
    }
    
    //Testing Positive Scenarios of benchmarkMarkCompleteValidations method with Benchmark having Observation & Observed Competency for all aplicable competency
    @isTest
    public static void benchmarkWithObservationValidationsTest(){
        Test.StartTest(); 
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User coach = TestDataFactory.createUser(adminProfileId, false);
        insert coach;
        
        User coachee = TestDataFactory.createUser(adminProfileId, false);
        coachee.ManagerId = coach.Id;
        coachee.ZTS_EU_Market__c = 'Ukraine';
        coachee.PIT_Coaching_Group__c = 'TBM';
        insert coachee;
        
        Benchmark__c objBenchmark = new Benchmark__c();
        objBenchmark.Market__c = 'Ukraine';
        objBenchmark.Role__c = 'TBM';
        objBenchmark.Status__c = 'Started';  
        objBenchmark.Coachee__c = coachee.Id;
        insert objBenchmark;
        
        Observation__c objObs = new Observation__c();
        objObs.Benchmark__r = objBenchmark;
        objObs.Benchmark__c = objObs.Benchmark__r.Id;  
        objObs.Type__c = 'Coach' ;
        Insert objObs;
        
        List<Competency_Model__c> lstCompModel = [SELECT Id,Name FROM Competency_Model__c WHERE Name = 'competencyModeltest'];
        List<Competency__c> lstCompetebcy = [SELECT Id,Competency_Model__c FROM Competency__c WHERE Competency_Model__c =: lstCompModel[0].Id ];
        
        Observed_Competency__c objObsCom = new Observed_Competency__c();
        objObsCom.Observation__r = objObs;
        objObsCom.Competency__c = lstCompetebcy[0].Id;
        objObsCom.Observation__c = objObsCom.Observation__r.Id;
        objObsCom.Score__c = '2';
        insert  objObsCom;
        
        Benchmark__c objBenchmark1 = new Benchmark__c();
        objBenchmark1.id = objObsCom.Observation__r.Benchmark__r.Id;
        objBenchmark1.Market__c = objObsCom.Observation__r.Benchmark__r.Market__c;
        objBenchmark1.Role__c = objObsCom.Observation__r.Benchmark__r.Role__c;
        objBenchmark1.Status__c = 'Completed';        
        update objBenchmark1;
        Test.StopTest();         
        System.assert(true, 'Benchmark Completed Successfully');
    }
    
    //Testing Positive Scenarios of benchmarkMarkCompleteValidations method of Benchmark with Self Observation Required but not complete Self Observation; 
    @isTest
    public static void benchmarkWithSelfObsCompletionTest(){
        Test.StartTest(); 
        try{
            Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            User coach = TestDataFactory.createUser(adminProfileId, false);
            insert coach;
            
            User coachee = TestDataFactory.createUser(adminProfileId, false);
            coachee.ManagerId = coach.Id;
            coachee.ZTS_EU_Market__c = 'Ukraine';
            coachee.PIT_Coaching_Group__c = 'TBM';
            insert coachee;
            
            Benchmark__c objBenchmark = new Benchmark__c();
            objBenchmark.Market__c = 'Ukraine';
            objBenchmark.Role__c = 'TBM';
            objBenchmark.Status__c = 'Started';  
            objBenchmark.Coachee__c = coachee.Id;
            objBenchmark.Self_Observation_Required__c = true; 
            objBenchmark.Self_Observation_Complete__c = false;
            insert objBenchmark;
            
            Observation__c objObs = new Observation__c();
            objObs.Benchmark__r = objBenchmark;
            objObs.Benchmark__c = objObs.Benchmark__r.Id; 
            objObs.Type__c = 'Coach' ;
            Insert objObs;
            
            List<Competency_Model__c> lstCompModel = [SELECT Id,Name FROM Competency_Model__c WHERE Name = 'competencyModeltest'];
            List<Competency__c> lstCompetebcy = [SELECT Id,Competency_Model__c FROM Competency__c WHERE Competency_Model__c =: lstCompModel[0].Id ];
            
            Observed_Competency__c objObsCom = new Observed_Competency__c();
            objObsCom.Observation__r = objObs;
            objObsCom.Competency__c = lstCompetebcy[0].Id;
            objObsCom.Observation__c = objObsCom.Observation__r.Id;
            objObsCom.Score__c = '2';
            insert  objObsCom;
            
            Benchmark__c objBenchmark1 = new Benchmark__c();
            objBenchmark1.id = objObsCom.Observation__r.Benchmark__r.Id;
            objBenchmark1.Market__c = objObsCom.Observation__r.Benchmark__r.Market__c;
            objBenchmark1.Role__c = objObsCom.Observation__r.Benchmark__r.Role__c;
            objBenchmark.Status__c = 'Completed';        
            update objBenchmark;
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Completed_Benchmark_Validations_Error_Message), 'message=' + message);
        }
        Test.StopTest(); 
    }
    
    //Testing Positive Scenarios of benchmarkMarkCompleteValidations method of Benchmark with no applicable competency been scored. 
    @isTest
    public static void benchmarkWithoutObsCompetencyTest(){
        Test.StartTest(); 
        try{
            Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            User coach = TestDataFactory.createUser(adminProfileId, false);
            insert coach;
            
            User coachee = TestDataFactory.createUser(adminProfileId, false);
            coachee.ManagerId = coach.Id;
            coachee.ZTS_EU_Market__c = 'Ukraine';
            coachee.PIT_Coaching_Group__c = 'TBM';
            insert coachee;
            
            Benchmark__c objBenchmark = new Benchmark__c();
            objBenchmark.Market__c = 'Ukraine';
            objBenchmark.Role__c = 'TBM';
            objBenchmark.Status__c = 'Started';  
            objBenchmark.Coachee__c = coachee.Id;
            insert objBenchmark;
            
            Observation__c objObs = new Observation__c();
            objObs.Benchmark__r = objBenchmark;
            objObs.Benchmark__c = objObs.Benchmark__r.Id;
            objObs.Type__c = 'Coach' ;
            Insert objObs;
            
            objBenchmark.Status__c = 'Completed';        
            update objBenchmark;
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Completed_Benchmark_Validations_Error_Message), 'message=' + message);
        }
        Test.StopTest(); 
    }  
        
    @isTest
    public static void benchmarkValidation2(){
        Test.StartTest(); 
        try{
            Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            User coach = TestDataFactory.createUser(adminProfileId, false);
            insert coach;
            
            User coachee = TestDataFactory.createUser(adminProfileId, false);
            coachee.ManagerId = coach.Id;
            coachee.ZTS_EU_Market__c = 'Canada';
            coachee.PIT_Coaching_Group__c = 'BUD';
            insert coachee;
            
            Benchmark__c objBenchmark = new Benchmark__c();
            objBenchmark.Market__c = 'Canada';
            objBenchmark.Role__c = 'BUD';
            objBenchmark.Status__c = 'Started';  
            objBenchmark.Coachee__c = coachee.Id;
            insert objBenchmark;
            
            Observation__c objObs = new Observation__c();
            objObs.Benchmark__r = objBenchmark;
            objObs.Benchmark__c = objObs.Benchmark__r.Id;
            objObs.Type__c = 'Coach' ;
            Insert objObs;
            
            objBenchmark.Status__c = 'Completed';        
            update objBenchmark;
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.Completed_Benchmark_Validations_Error_Message), 'message=' + message);
        }
        Test.StopTest(); 
    }  

    /*
      This method will test if we don't have any Competency Group related to benchmark's Market and Role then 
	  it should allow to complete the benchmark - This is an edge case
	*/
    @isTest
    public static void benchmarkMarkCompleteValidationsTest2(){
        Test.startTest();
        String message = '';
        try{
            //Benchmark record
            Benchmark__c objBenchmark = new Benchmark__c();
            objBenchmark.Market__c = 'Canada';
            objBenchmark.Role__c = 'BUD';
            objBenchmark.Status__c = 'Started';        
            insert objBenchmark;
            
            objBenchmark.Status__c = 'Completed';        
            update objBenchmark;
            
        }catch(Exception e){
            message = e.getMessage();
            system.assert(message.contains(System.Label.Completed_Benchmark_Validations_Error_Message), 'message=' + message);
        }
        Test.StopTest();
    }
    
    /*
     * This method will test Draft/inactive Competencies do not stop a Benchmark from being marked Completed.
    */
    @isTest
    public static void benchmarkMarkCompleteValidationsTest3(){
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User coach = TestDataFactory.createUser(adminProfileId, false);
        insert coach;
        
        User coachee = TestDataFactory.createUser(adminProfileId, false);
        coachee.ManagerId = coach.Id;
        coachee.ZTS_EU_Market__c = 'Canada';
        coachee.PIT_Coaching_Group__c = 'BUD';
        insert coachee;
        
        Benchmark__c objBenchmark = new Benchmark__c();
        objBenchmark.Market__c = 'Canada';
        objBenchmark.Role__c = 'BUD';
        objBenchmark.Status__c = 'Started';  
        objBenchmark.Coachee__c = coachee.Id;
        insert objBenchmark;
        
        Observation__c objObs = new Observation__c();
        objObs.Benchmark__c = objBenchmark.Id;  
        objObs.Type__c = 'Coach' ;
        Insert objObs;
        
        List<Competency_Model__c> lstCompModel = [SELECT Id,Name,Status__c FROM Competency_Model__c WHERE Name = 'competencyModeltest1'];        
        List<Competency__c> lstCompetebcy = [SELECT Id,Competency_Model__c,Status__c FROM Competency__c WHERE Competency_Model__c =: lstCompModel[0].Id AND Status__c = 'Active'];        
        
        Observed_Competency__c objObsCom = new Observed_Competency__c();
        objObsCom.Competency__c = lstCompetebcy[0].Id;
        objObsCom.Observation__c = objObs.Id;
        objObsCom.Score__c = '2';
        insert  objObsCom;
        
        Test.StartTest();
        String message = '';
        try{
        	objBenchmark.Status__c = 'Completed';
        	update objBenchmark;
        }catch(Exception e){
            message = e.getMessage();
        }
        system.assert(!message.contains(System.Label.Completed_Benchmark_Validations_Error_Message), 'message=' + message);
        Test.StopTest();
    }
}