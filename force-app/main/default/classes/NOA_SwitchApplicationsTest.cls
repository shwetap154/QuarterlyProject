@IsTest
public class NOA_SwitchApplicationsTest {

    @IsTest
    static void testConvertVetToRepro(){
        Id vetRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        Lead l = new Lead(Company = 'New Online Account', LastName = 'Test 1', FirstName='Test First1', Ownership_Type__c='LLC', RecordTypeId = vetRecTypeId);
        insert l;
        Veterinarian_Information__c v = new Veterinarian_Information__c(Lead__c = l.Id);
        insert v;
        String result = NOA_SwitchApplications.convertVetToRepro(l.Id);
        System.assert(result != null && !result.startsWith('Error'));
    }
    
    @IsTest
    static void testConvertReproToVet(){
        Id servRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Diagnostic_or_Reproduction').getRecordTypeId();
        Lead l = new Lead(Company = 'New Online Account', LastName = 'Test 2', FirstName='Test First2', Ownership_Type__c='Corporation', RecordTypeId = servRecTypeId);
        insert l;
        
        String result = NOA_SwitchApplications.convertVetToRepro(l.Id);
        System.assert(result != null && !result.startsWith('Error'));
    }
}