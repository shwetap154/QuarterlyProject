/*************************************************************************************
* Name          :    AccountAlignmentNotification.
* Description   :    Schecdule the Batch class(AccountAlignmentNotification)daily to notify the user on alignment of an Account.
* Author        :    Sohil Shah(CloudSense)
 
Modification Log
----------------
Date             Developer                         Comments
---------------------------------------------------------------------------------------
12/30/2014       Sohil Shah(CloudSense)            Created

**************************************************************************************/

global class AccountAlignmentNotificationSchedulable implements Schedulable{
        global void execute(SchedulableContext sc) {
        AccountAlignmentNotification aan = new AccountAlignmentNotification();
        ID myBatchJobID = database.executebatch(aan);
        
    }

}