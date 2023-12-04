@isTest
public class ZTS_EU_BO_AccUtil_Queueable_Test {
    
    static testMethod void TestQueueable(){
        List<id> idList = new List<id>();
        List<string> emailList = new List<string>();
        Set<Id> accountIDs = new Set<Id>();
        Map<string,boolean> emailMap = new Map<string,boolean>();
        String triggerContext = 'AfterUpdate';
      	
       ZTS_EU_BO_AccUtil_Queueable APC= new ZTS_EU_BO_AccUtil_Queueable(emailList, accountIDs, emailMap, idList,triggerContext);
        
       Test.startTest();
            System.enqueueJob(APC);
       Test.stopTest();
    } 

}