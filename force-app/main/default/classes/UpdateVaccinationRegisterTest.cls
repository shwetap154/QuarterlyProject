@ISTEST
public class UpdateVaccinationRegisterTest 
{
    static testMethod void testMethod1() 
    {
        List<VaccinationRegister__c > lstVacc= new List<VaccinationRegister__c >();
        
       
           // Id RecordTypeIdContact = Schema.SObjectType.Animal__c.getRecordTypeInfosByDeveloperName().get('DeveloperNameOfRecordType').getRecordTypeId();
           String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Animal__c' and Name = 'Horse'].Id;
            Animal__c anm = new Animal__c();
            anm.AnimalChipID__c = 'dsDsdd22qwws';
            anm.RecordTypeId= strRecordTypeId ;
            insert anm;
            
            
            VaccinationRegister__c vacc = new VaccinationRegister__c();
           // vacc.Name ='Name'+i;
           //vacc.Animal_Chip_ID__c = 'TEST';
            vacc.Animal__c = anm.id;
            vacc.VaccinationDate__c = System.today();
            vacc.Due_Date__c = System.today();
           
        
        
        insert vacc;
        update vacc;
        
        Test.startTest();

            UpdateVaccinationRegister obj = new UpdateVaccinationRegister ();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}