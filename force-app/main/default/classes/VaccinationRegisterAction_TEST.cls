@isTest(seealldata=false)
private class VaccinationRegisterAction_TEST {

	private static testMethod void Mymethod() {
       //Create a vaccinationRegister
       
       List<VaccinationRegister__c> VRlist = new List<VaccinationRegister__c>();
       VaccinationRegister__c VR = new VaccinationRegister__c();
      // String recordtypeid = String.valueOf([Select recordtypeid from animal__c where recordtype.name = 'horse' limit 1]);
        String recordtypeid = String.valueOf([Select id from recordtype where developername = 'horse' limit 1]);
       Animal__c myanimal = new Animal__c(AnimalChipID__c = '1test');
       Insert myanimal;
       
       VR.treatment__c = 'Hendra';
       VR.VaccinationType2__c = 'First Dose';
       VR.animal__c = myanimal.Id;
       VR.VaccinationDate__c = System.Today();
       VRlist.add(VR);
       Insert VRlist;
       Test.startTest()  ;
       VaccinationRegisterAction.insertVaccRegister(new list<Id>{VRlist[0].id});
       Test.stoptest();
	}
	
	private static testMethod void Mymethod1() {
       //Create a vaccinationRegister
       
       List<VaccinationRegister__c> VRlist = new List<VaccinationRegister__c>();
       List<VaccinationRegister__c> VRlist1 = new List<VaccinationRegister__c>();
       VaccinationRegister__c VR = new VaccinationRegister__c();
      // String recordtypeid = String.valueOf([Select recordtypeid from animal__c where recordtype.name = 'horse' limit 1]);
        String recordtypeid = String.valueOf([Select id from recordtype where developername = 'horse' limit 1]);
       Animal__c myanimal = new Animal__c(AnimalChipID__c = '1test');
       Insert myanimal;
       
       VR.treatment__c = 'Hendra';
       VR.VaccinationType2__c = 'Second Dose';
       VR.animal__c = myanimal.Id;
       VR.VaccinationDate__c = System.Today();
       VRlist.add(VR);
       Insert VRlist;
       
      VaccinationRegister__c VR1 = new VaccinationRegister__c();

       
       VR1.treatment__c = 'Hendra';
       VR1.VaccinationType2__c = 'Second Dose';
       VR1.animal__c = myanimal.Id;
       VR1.VaccinationDate__c = System.Today();
       VRlist1.add(VR1);
       Insert VRlist1;
       Test.startTest()  ;
       VaccinationRegisterAction.insertVaccRegister(new list<Id>{VRlist1[0].id});
       Test.stoptest();
	}

}