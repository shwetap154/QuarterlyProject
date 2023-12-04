/*
    @@ Puropose: (Scheduled batch class) Update vaccination due date for historical  records only for Hendra Second Dose for 1sttime vaccination
    @@ Author: Kaushik Ghosh(Cognizant Technology Solutions) 
    @@ Reference: 
    
    Modification LOG:
    
    Date             Author Name            DEFECT NO                    Description
    -------------------------------------------------------------------------------------------------------
*/   
global class MySchedulableClass implements Schedulable{ 
@ReadOnly 
global void execute (SchedulableContext ctx){ 

List<AggregateResult> query = [Select MIN(VACCINATIONDATE__C) CD from vaccinationRegister__c where treatment__c = 'Hendra' and vaccinationtype2__c = 'Second Dose' group by animal__c  ]; 
Date dt; 

for(AggregateResult ar : query){ 
dt = (Date)ar.get('CD');

//myid.add((ID)ar.get('CD'));
//system.debug(myid); 

//List<vaccinationregister__c> query = [select ID from VaccinationRegister__c where treatment__c = 'Hendra' and animal__c!=null and vaccinationtype2__c = 'Second Dose' group by animal__c ];
//set<Id> myid = new set<Id>();
//for (Vaccinationregister__c myquery :query){
//myid.add(myquery.id);
//system.debug(myid); 
} 
RunQuery1 rq = new RunQuery1(dt); 
Database.executeBatch(rq); 
} 
}