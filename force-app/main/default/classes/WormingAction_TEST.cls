@isTest(seealldata=false)
private class WormingAction_TEST {

	private static testMethod void Mymethod() {
       //Create a vaccinationRegister
       
       List<Worming__c> VRlist = new List<Worming__c>();
       Worming__c VR = new Worming__c();
      // String recordtypeid = String.valueOf([Select recordtypeid from animal__c where recordtype.name = 'horse' limit 1]);
       String recordtypeid = String.valueOf([Select id from recordtype where developername = 'horse' limit 1]);
       Animal__c myanimal = new Animal__c(AnimalChipID__c = '1test');
       Insert myanimal;
       
       
       VR.animal__c = myanimal.Id;
       VR.Date_of_Worming__c = System.Today();
       VR.Vaccination_Type__c = 'Equest Plus Tape';
       VRlist.add(VR);
       Insert VRlist;
       Test.startTest();
       WormingAction.insertworm(new list<Id>{vrlist[0].id});
       Test.stoptest();        
	}

}