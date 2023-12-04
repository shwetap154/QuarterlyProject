@IsTest
public class ContactFixInvalidNamesScheduledTest {

static testMethod void testschedule() {
Test.StartTest();
ContactFixInvalidNamesScheduled schClass = new ContactFixInvalidNamesScheduled();
String cronExp = '0 0 0 ? * MON';
System.schedule('Contact fix invalid names', cronExp, schClass);
Test.stopTest();
}
}