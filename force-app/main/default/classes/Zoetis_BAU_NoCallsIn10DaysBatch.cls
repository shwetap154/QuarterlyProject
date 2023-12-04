/******************************************************************************************************************************************
* Class Name   : Zoetis_BAU_NoCallsIn10DaysBatch
* Description  : System Change: SC-008869, Zoetis_BAU_NoCallsIn10DaysBatch runs every day and 
				 prepares the data from which this class will send email notifications
* Summary      : We need to send emails to Anchor accounts in US where there are no calls for past 10 days, 
				 email receipients are account position employees where ZTS_US_Receive_Call_Reminders__c is true
* Created By   : Cognizant/Zoetis
* Created Date : 31 January 2023
* Test Class   : Zoetis_BAU_NoCallsIn10DaysBatch_Test
*
* Modification Log:
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sayan Majumder (Cognizant) 31/01/2023          Created.
*****************************************************************************************************************************************/


public without sharing class Zoetis_BAU_NoCallsIn10DaysBatch implements Database.Batchable<sObject>,System.Schedulable,Database.stateful {
    private static final Integer SCHEDULABLE_BATCH_SIZE = 150;
    private static final Integer ReminderIntervalInDays = 10;
    private static final Integer WorkTimeInHours = 480;
    private static final Id templateId = [Select Id from EmailTemplate where DeveloperName ='Key_Account_Email_Reminders'][0].Id;
    
    static Map<Id,Date> AccountIdCreatedDate;
    static Map<String,wrapAccount> MainAccountMap;//Key = Account Position Employee Id + Account Id, Value = Wrapper to hold the Call Dates and Accouont Details
    static Set<Id> OwnerIdToLookForTOT;//Utilized to find the TOT records for AP Employees
    static Map<Id,Date> MapoofAccountandLastCallDate;
    static Map<String,Decimal> DateMap;//Key = TOT start Date + Employee Id + Key Account Id, Value = Time Off length for the day in Minutes
    static Map<Id,List<Time_Out_of_Territory__c>> OwnerIdTOTMap;//Key = TOT Owner Id, Value = TOT fields
    static List<ZTS_US_Key_Account_Email_Reminders__c> KAERList;
    
    public Database.QueryLocator Start(Database.BatchableContext batchablecontext){
        return database.getQueryLocator([SELECT Id,CreatedDate FROM Account WHERE ZTS_EU_Key_Account__c=true AND ZTS_EU_Market__c='United States']);
    }
    
    public void Execute(Database.BatchableContext bathablecontext,List<sObject> Scope){
        
            AccountIdCreatedDate = new Map<Id,Date>();
            MainAccountMap = new Map<String,wrapAccount>();//Key = Account Position Employee Id + Account Id, Value = Wrapper to hold the Call Dates and Accouont Details
            OwnerIdToLookForTOT = new Set<Id>();//Utilized to find the TOT records for AP Employees
            MapoofAccountandLastCallDate = new Map<Id,Date>();
            DateMap = new Map<String,Decimal>();//Key = TOT start Date + Employee Id + Key Account Id, Value = Time Off length for the day in Minutes
            OwnerIdTOTMap = new Map<Id,List<Time_Out_of_Territory__c>>();//Key = TOT Owner Id, Value = TOT fields
            KAERList = new List<ZTS_US_Key_Account_Email_Reminders__c>();
            
            for(Account var1:(List<Account>)Scope)
                AccountIdCreatedDate.put(var1.Id,var1.CreatedDate.date());
            
            for(AggregateResult var2:[SELECT ZTS_EU_Account__c,Max(CreatedDate)LastCallCreatedDate FROM Call__c 
                                      WHERE ZTS_EU_Account__c=:AccountIdCreatedDate.keySet() GROUP BY ZTS_EU_Account__c LIMIT 20000]){
                                          if(AccountIdCreatedDate.containsKey((Id)var2.get('ZTS_EU_Account__c'))){//these are the items for which we atleast have one Call record created
                                              AccountIdCreatedDate.put((Id)var2.get('ZTS_EU_Account__c'),Date.Valueof(var2.get('LastCallCreatedDate')));
                                          }
                                      }
            
            for(ZTS_EU_Account_Position__c var3:[SELECT Id,ZTS_EU_Position__r.ZTS_EU_Employee__r.Email,ZTS_EU_Position__r.ZTS_EU_Employee__c,
                                                 ZTS_EU_Account__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Is_Active__c=true AND 
                                                 EmployeeIsActive__c=true AND ZTS_EU_Position__c!=null AND ZTS_EU_Position__r.ZTS_EU_Employee__c!=null AND ZTS_EU_Account__c!=null AND 
                                                 ZTS_US_Receive_Call_Reminders__c=true AND ZTS_EU_Account__c IN:AccountIdCreatedDate.keySet() LIMIT 45000]){
                                                     OwnerIdToLookForTOT.add(var3.ZTS_EU_Position__r.ZTS_EU_Employee__c);
                                                     wrapAccount ob = new wrapAccount();
                                                     ob.LastCallOrAccCreatedDate = AccountIdCreatedDate.get(var3.ZTS_EU_Account__c);
                                                     ob.EmailReminderDate = AccountIdCreatedDate.get(var3.ZTS_EU_Account__c).addDays(ReminderIntervalInDays);
                                                     ob.ReminderIntervalInMinutes = ReminderIntervalInDays*WorkTimeInHours;
                                                     ob.AccId = var3.ZTS_EU_Account__c;
                                                     MainAccountMap.put(var3.ZTS_EU_Position__r.ZTS_EU_Employee__c+'-'+var3.ZTS_EU_Account__c,ob);
                                                 }
            
            if(MainAccountMap.size()>0){//Go forward only if there are receivers to receive reminder emails
                //TOT Query to find if any employee has any time off dates in the scope
                Map<Id,Time_Out_of_Territory__c> TOTMap = 
                    new Map<Id,Time_Out_of_Territory__c>([SELECT Id,OwnerId,ZTS_EU_Start_Date__c,
                                                          ZTS_EU_End_Date__c,ZTS_EU_DurationInMinutes__c 
                                                          FROM Time_Out_of_Territory__c 
                                                          WHERE OwnerId IN:OwnerIdToLookForTOT 
                                                          AND 
                                                          (ZTS_EU_Status__c='Submitted' OR ZTS_EU_Status__c='Planned') 
                                                          ORDER BY OwnerId ASC,ZTS_EU_Start_Date__c ASC LIMIT 45000]);
                
                for(Id var:TOTMap.keySet()){
                    if(!OwnerIdTOTMap.containsKey(TOTMap.get(var).OwnerId)){
                        OwnerIdTOTMap.put(TOTMap.get(var).OwnerId,new List<Time_Out_of_Territory__c>{TOTMap.get(var)});
                    }else{
                        OwnerIdTOTMap.get(TOTMap.get(var).OwnerId).add(TOTMap.get(var));
                    }
                }
                
                
                for(String str:MainAccountMap.keySet()){//looping through all Employees of the Key Accounts
                    if(OwnerIdTOTMap.containsKey(str.substringBefore('-'))){//Check if the employee has a record in the TOT
                        for(Time_Out_of_Territory__c str2:OwnerIdTOTMap.get(str.substringBefore('-'))){// str.substringBefore('-') is Employee Id, look line 36
                            if(MainAccountMap.get(str).LastCallOrAccCreatedDate <= str2.ZTS_EU_Start_Date__c){//Check if the employee's time off date falls after the last call created date
                                if(str2.ZTS_EU_Start_Date__c.isSameDay(str2.ZTS_EU_End_Date__c))
                                    DateMap.put(str2.ZTS_EU_Start_Date__c+'-'+str.substringBefore('-')+'-'+MainAccountMap.get(str).AccId,str2.ZTS_EU_DurationInMinutes__c);
                                else{
                                    Date dateIterations = str2.ZTS_EU_Start_Date__c;
                                    for(Integer i=0;i<=str2.ZTS_EU_Start_Date__c.daysBetween(str2.ZTS_EU_End_Date__c);i++){
                                        DateMap.put(dateIterations+'-'+str.substringBefore('-')+'-'+MainAccountMap.get(str).AccId,str2.ZTS_EU_DurationInMinutes__c);
                                        dateIterations = dateIterations.addDays(1);
                                    }
                                }
                            }
                        }
                    }
                }//This loop iterates through all Key Accounts in current batch Scope and populates Time Off Date map for all of'em
                
                for(String str3:MainAccountMap.keySet()){
                    Date dateIterations2 = MainAccountMap.get(str3).LastCallOrAccCreatedDate;
                    for(Integer j=0;j<=5280;){//5280 is 8 hours a day for 10 days + 480 one more day to end the loop when 10 days are calculated correctly
                        if(DateMap.containsKey(dateIterations2+'-'+str3)){
                            MainAccountMap.get(str3).ReminderIntervalInMinutes += (Integer)DateMap.get(dateIterations2+'-'+str3);
                            j -= (Integer)DateMap.get(dateIterations2+'-'+str3);
                        }else
                            j += WorkTimeInHours;
                        dateIterations2 = dateIterations2.addDays(1);
                    }
                    MainAccountMap.get(str3).EmailReminderDate = MainAccountMap.get(str3).LastCallOrAccCreatedDate.addDays(MainAccountMap.get(str3).ReminderIntervalInMinutes/WorkTimeInHours);
                }//This loop calculates the reminder dates considering the Time Offs for the employees
                
                
                //Created a new object to store the Email Reminder dates and from where the next batch will query and send emails
                
                for(String oid:MainAccountMap.keySet()){
                    ZTS_US_Key_Account_Email_Reminders__c ob = new ZTS_US_Key_Account_Email_Reminders__c();
                    ob.ZTS_US_Account_Position_Employee__c = oid.substringBefore('-');
                    ob.ZTS_US_Account__c = oid.substringAfter('-');
                    ob.ZTS_US_Key__c = oid;
                    ob.ZTS_US_Last_Call_Created_Date__c = MainAccountMap.get(oid).LastCallOrAccCreatedDate;
                    ob.ZTS_US_Email_Reminder_Date__c = MainAccountMap.get(oid).EmailReminderDate;
                    KAERList.add(ob);
                }
                if(KAERList.size()>0)
                    UPSERT KAERList ZTS_US_Key__c;
                
            }
    }
    
    public void Finish(Database.BatchableContext bathablecontext){
        
        //We will send the email here by utilizing the Stateful behaviour of the Batch class
        //We will include the same email template as required
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bathablecontext.getJobId()];
        if(job.NumberOfErrors==0){
            //Fetch all email eligible records
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for(AggregateResult var:[SELECT ZTS_US_Account_Position_Employee__c,Count(Id) Number_Of_Records 
                                     FROM ZTS_US_Key_Account_Email_Reminders__c WHERE ZTS_US_Email_Reminder_Date__c<=TODAY 
                                     GROUP BY ZTS_US_Account_Position_Employee__c HAVING Count(Id)>=1]){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSenderDisplayName('Key Account Email Reminders');
                //mail.setReplyTo('sayan.majumder3@cognizant.com');
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);
                mail.setWhatId((Id)var.get('ZTS_US_Account_Position_Employee__c'));//Pass the user id for which mail will go
                mail.setTemplateID(templateId);
                mail.setTargetobjectid((Id)var.get('ZTS_US_Account_Position_Employee__c'));               
                //mail.toAddresses = new String[] { KAERMap.get(var) };
                    messages.add(mail);
            }
            if(messages.size()>0 && messages.size()<=49999){}
                Messaging.sendEmail(messages);
                
        }
    }
    
    
    //wrapper class to help creating the Map with owner Id and Account + call details
    public class wrapAccount {
        public Id AccId {get; set;}
        public Date LastCallOrAccCreatedDate {get; set;}
        public Integer ReminderIntervalInMinutes {get; set;}
        public Date EmailReminderDate {get; set;}
        public wrapAccount(){
            LastCallOrAccCreatedDate = null;
            AccId = null;
            ReminderIntervalInMinutes = 0;
            EmailReminderDate = null;
        }
    }
    
    
    //The batch class would be scheduled to run frequenty on each day
    public void execute(System.SchedulableContext schedulablecontext){
        database.executeBatch(new Zoetis_BAU_NoCallsIn10DaysBatch(),SCHEDULABLE_BATCH_SIZE);//calling batch class from this point
    }
}