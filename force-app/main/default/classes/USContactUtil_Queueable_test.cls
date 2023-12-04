/*************************************************************************************************************************
  Class Name     : USContactUtil_Queueable_test
  Description    : This is a test class for class "USContactUtil_Queueable". (SC-008149)
  Created By     : Aritra
  Created On     : 30/5/2022
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Aritra (Cognizant)                    30/5/2022                 Created

***************************************************************************************************************************/
@isTest
public class USContactUtil_Queueable_test {
    
    
    static testMethod void TestQueueable(){
       List<id> conList = new List<id>();
       Contact c = new Contact(lastName='test 1',ZTS_EU_Market__c='United States',ZTS_US_Profession__c='Academia', ZTS_US_Job_Function__c='Clinical Faculty',DuplicateBypassed__c=true);
       insert c;
       conList.add(c.Id);
       USContactUtil_Queueable q = new USContactUtil_Queueable(conList);
        
       Test.startTest();
            System.enqueueJob(q);
       Test.stopTest();
    } 


}