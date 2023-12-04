global class RunQuery1 implements Database.Batchable<sObject> { 

global Date dt; 
global RunQuery1(Date dt){ 
this.dt = dt; 
} 

global set<Id> dt2 = new set<Id>(); 
//global RunQuery1(set<Id> dt1){
//dt2 = dt1;
//system.debug(dt2);
//}

global Database.QueryLocator start(Database.BatchableContext BC){ 
DateTime createdDate; 
String query; 
Set<Date> dtime = new Set<Date>(); 
dtime.add(dt); 
//query = 'select Id,Due_Date__c	,firsttime__c,vaccinationdate__c from vaccinationregister__c where Id IN: dt2 order by vaccinationdate__c asc LIMIT 1'  ;
query = 'select id from vaccinationregister__c where vaccinationdate__c=: dt and treatment__c = \'Hendra\' and vaccinationtype2__c = \'Second Dose\' '  ;
system.debug('Hi 12');
return Database.getQueryLocator(query);
} 
  
global void execute(Database.BatchableContext BC, List<vaccinationregister__c> scope){
for(vaccinationregister__c s : scope){ 
s.firsttime__c	 = true;
    if(s.vaccinationdate__c != null)
		s.DUE_DATE__C    = s.vaccinationdate__c + 182;
system.debug('Inside Scope');
} 
update scope;
system.debug('Scope Endede');
} 
global void finish(Database.BatchableContext BC){ 
AsyncApexJob a = 
[Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
System.debug('********: ' + a.Id); 
} 
}