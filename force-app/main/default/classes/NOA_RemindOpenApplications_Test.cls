@IsTest
public class NOA_RemindOpenApplications_Test {

    testmethod static void testNOAReminders(){
        Id carystaRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId(); 
        Lead l = new Lead(Company='New Online Account', RecordTypeId=carystaRecTypeId, FirstName='Test Reminder12113', LastName='Test Last', Status='To Be Deleted');
        insert l; 
        Lead l2 = new Lead(Company='New Online Account', RecordTypeId=carystaRecTypeId, FirstName='Test Reminder12114', LastName='Test Last2', Status='Open');
        insert l2; 
        /*Lead l3 = new Lead(Company='New Online Account', RecordTypeId=carystaRecTypeId, FirstName='Test Reminder12115', LastName='Test Last3', Status='Open', NOA_Reminder_Flag__c=30);
        insert l3; */
        Lead l4 = new Lead(Company ='New Online Account', RecordTypeId=carystaRecTypeId, FirstName ='Test Reminder12116', LastName ='Test Last4', Status ='To Be Deleted',NOA_Reminder_Flag__c=45 );
        insert l4;
        Test.setCreatedDate(l4.Id, DateTime.newInstance(2018,09,09));
        List<Lead> llist = new List<Lead>();
        llist.add(l);
        llist.add(l2);
       // llist.add(l3);
        llist.add(l4);
        Test.startTest();          
        NOA_RemindOpenApplications batch = new NOA_RemindOpenApplications();
        DataBase.executeBatch(batch);
        batch.execute(null, llist);
        Test.stopTest();        
    }
}