@isTest
public class AUS_CP_HENDRA_DUEDATE_REP_UPD_TEST {
    
    static final Integer NUM_VACCINE_REGISTERS = 204;
    static final String HENDRA_TRTMENT = 'Hendra';
    
    @TestSetup
    static void dataSetup(){
        
        User intlUsr = new User();
		intlUsr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
		intlUsr.FirstName = 'intlUsr';
		intlUsr.ZTS_EU_Market__c = 'Australia';
        insert intlUsr;
        
        System.runAs(intlUsr) {

            ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();

            Integer updateRepeatDays = AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE.REPEAT_TIME;
            
            Account testAccount= ZTS_DataUtilityTest.createAccountRecord(1)[0];
            insert testAccount; 
    
            Contact testContact = ZTS_DataUtilityTest.createContactRecord(1)[0];
            testContact.AccountId = testAccount.Id;
            insert testContact;
            
            Animal__c testAnimal = new Animal__c();
            testAnimal.Animal_Name__c = '1';
            testAnimal.Animal_Type__c = 'Horse';
            testAnimal.Animal_Sex__c = 'Male';
            testAnimal.AnimalChipID__c = '1';
            insert testAnimal;    
            
            List<VaccinationRegister__c> testVaccineRegisters = new List<VaccinationRegister__c>();
            for(Integer i=0; i<NUM_VACCINE_REGISTERS; i++) {
                VaccinationRegister__c testVaccineRegister = new VaccinationRegister__c();
                testVaccineRegister.Animal__c = testAnimal.Id;
                testVaccineRegister.Veterinary__c = testContact.Id;
                testVaccineRegister.FirstTime__c = false;
                if(Math.mod(i, 2) == 0) {
                    testVaccineRegister.Treatment__c = HENDRA_TRTMENT;
                    testVaccineRegister.VaccinationType2__c = 'Second Dose';
                    if(Math.mod(i, 4) == 0) {
                        testVaccineRegister.VaccinationDate__c = System.today();
                    }
                    else if(Math.mod(i, 4) == 2) {
                        testVaccineRegister.VaccinationDate__c = System.today()-updateRepeatDays;
                    }
                }
                else {
                    testVaccineRegister.VaccinationType2__c = 'Second Primary Dose';
                    testVaccineRegister.Treatment__c = 'Tetanus';
                }
                testVaccineRegisters.add(testVaccineRegister);
            }
            insert testVaccineRegisters; 
        }
        
    }
    
    @isTest static void AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE_TEST() 
    {

        Test.startTest();
            AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE obj = new AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE();
            DataBase.executeBatch(obj); 
        Test.stopTest();

        List<AggregateResult> actualVaccineRegisters = [SELECT Due_Date__c, count(Id) total 
                                                               FROM Vaccinationregister__c 
                                                               WHERE Treatment__c = :HENDRA_TRTMENT 
                                                                 AND VaccinationDate__c != null 
                                                                 AND VaccinationType2__c = 'Second Dose' 
                                                                 AND Animal__c != null 
                                                                 AND FirstTime__c = FALSE
                                                               GROUP BY Due_Date__c];

        for(AggregateResult aggResult : actualVaccineRegisters) {
            System.assertEquals(NUM_VACCINE_REGISTERS/4, aggResult.get('total'), 'Quarter of the records should be set to each date');
        }
    }
}