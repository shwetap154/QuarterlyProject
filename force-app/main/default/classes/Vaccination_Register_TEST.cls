@isTest
private class Vaccination_Register_TEST{
    
    private static testMethod void createVaccReg() {
        
        //Create a vaccinationRegister       
        List<VaccinationRegister__c> VRlist = new List<VaccinationRegister__c>();       
        
        // INSERT Animal
        List<Animal__c> lstAnml = new List<Animal__c>();
        Animal__c anml = new Animal__c(AnimalChipID__c = 'test');
        lstAnml.add(anml);
        Animal__c anml2 = new Animal__c(AnimalChipID__c = 'test21');
        lstAnml.add(anml2);
        
        Insert lstAnml;
        
        // INSERT Vaccination Register
        VaccinationRegister__c VR = new VaccinationRegister__c();
        VR.treatment__c = 'Hendra';
        VR.Due_Date__c = System.Today().addDays(1);
        VR.animal__c = lstAnml[0].Id;
        VR.VaccinationDate__c = System.Today();
        
        VaccinationRegister__c VReg = new VaccinationRegister__c();
        VReg.treatment__c = 'Tetanus';
        VReg.Due_Date__c = System.Today().addDays(5);
        VReg.animal__c = lstAnml[0].Id;
        VReg.VaccinationDate__c = System.Today();
        
        VRlist.add(VReg);
        VRlist.add(VR);
        
        Insert VRlist;
        
        // Assert Statements
        System.assertEquals(VReg.Inactive__c, FALSE); 
        
    }
    private static testMethod void updateVaccReg() {
        
        //Create a vaccinationRegister       
        List<VaccinationRegister__c> VRlist = new List<VaccinationRegister__c>();       
        
        // INSERT Animal
        List<Animal__c> lstAnml = new List<Animal__c>();
        Animal__c anml = new Animal__c(AnimalChipID__c = 'test2');
        lstAnml.add(anml);
        Animal__c anml2 = new Animal__c(AnimalChipID__c = 'test22');
        lstAnml.add(anml2);
        
        Insert lstAnml;
        
        // INSERT Vaccination Register
        VaccinationRegister__c VR = new VaccinationRegister__c();
        VR.treatment__c = 'Hendra';
        VR.Due_Date__c = System.Today();
        VR.animal__c = lstAnml[0].Id;
        VR.VaccinationDate__c = System.Today();
        
        VaccinationRegister__c VReg = new VaccinationRegister__c();
        VReg.treatment__c = 'Tetanus';
        VReg.Due_Date__c = System.Today().addDays(1);
        VReg.animal__c = lstAnml[0].Id;
        VReg.VaccinationDate__c = System.Today();
        
        VRlist.add(VReg);       
        VRlist.add(VR);
        
        Insert VRlist;
        
        VReg.VaccinationDate__c = System.Today().addDays(-4);
        UPDATE VReg;
        
        // Assert Statements
        System.assertEquals(VReg.Inactive__c, FALSE);
    }
    
    @isTest static void deleteVaccinationRegisterTest() {
        
        //Create a vaccinationRegister       
        List<VaccinationRegister__c> VRlist = new List<VaccinationRegister__c>();       
        
        // INSERT Animal
        List<Animal__c> lstAnml = new List<Animal__c>();
        Animal__c anml = new Animal__c(AnimalChipID__c = 'test2');
        lstAnml.add(anml);
        Animal__c anml2 = new Animal__c(AnimalChipID__c = 'test22');
        lstAnml.add(anml2);
        
        Insert lstAnml;
        
        // INSERT Vaccination Register
        VaccinationRegister__c VR = new VaccinationRegister__c();
        VR.treatment__c = 'Hendra';
        VR.Due_Date__c = System.Today();
        VR.animal__c = lstAnml[0].Id;
        VR.VaccinationDate__c = System.Today();
        
        VaccinationRegister__c VReg = new VaccinationRegister__c();
        VReg.treatment__c = 'Tetanus';
        VReg.Due_Date__c = System.Today().addDays(1);
        VReg.animal__c = lstAnml[0].Id;
        VReg.VaccinationDate__c = System.Today();
        
        VRlist.add(VReg);       
        VRlist.add(VR);
        
        Insert VRlist;
        
        Test.startTest();
        	delete VRlist;
        Test.stopTest();
        
		List<VaccinationRegister__c> actualVRs = [SELECT Id FROM VaccinationRegister__c WHERE Id IN :VRlist];        
        
        System.assertEquals(0,actualVRs.size(), 'No VRs should exist');
    }
    
}