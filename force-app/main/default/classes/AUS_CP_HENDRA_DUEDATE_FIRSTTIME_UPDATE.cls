/*
@@ Puropose: (Scheduled batch class) Update vaccination due date for historical  records only for Hendra Second Dose for firstime vaccination
@@ Author: Kaushik Ghosh(Cognizant Technology Solutions) 
@@ Reference: 

Modification LOG:

Date             Author Name            DEFECT NO                    Description
-------------------------------------------------------------------------------------------------------
AUS_CP_HENDRA_DUEDATE_FIRSTTIME_UPDATE gK2 = new AUS_CP_HENDRA_DUEDATE_FIRSTTIME_UPDATE();
Database.executeBatch(gk2,100);

*/
global class AUS_CP_HENDRA_DUEDATE_FIRSTTIME_UPDATE implements Database.Batchable<sObject> {        
    
    @TestVisible static final Integer REPEAT_TIME = 182; // in days
    
    global Database.queryLocator start(Database.BatchableContext BC)
    {   
        
        String Query = 'SELECT Id FROM Animal__c';
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext BC, List<Animal__c> myAnimal)
    
    { 
        Set<Id> myId = new Set<Id>();
        String fk='';
        for (Animal__c a1:myAnimal){
            myId.add(a1.Id);
        }
        
        List<VaccinationRegister__c> firstTimeList = new List<VaccinationRegister__c>();
        List<VaccinationRegister__c> mylist = [SELECT Id, Animal__c,VaccinationDate__c,Due_Date__c 
                                                FROM VaccinationRegister__c 
                                                WHERE Animal__c IN :myId 
                                                  AND Animal__c !=null 
                                                  AND Treatment__c ='Hendra' 
                                                  AND VaccinationType2__c ='Second Dose' 
                                                  AND VaccinationDate__c!=null ORDER BY VaccinationDate__c asc  ];
        for(Animal__c aR :myAnimal){
            for(VaccinationRegister__c vacRegister :mylist){
                if(vacRegister.Animal__c !=null && aR.Id==vacRegister.Animal__c && !fk.equals(vacRegister.Animal__c)) {
                    fk = vacRegister.Animal__c;
                    vacRegister.FirstTime__c = true;
                    vacRegister.Due_Date__c = vacRegister.VaccinationDate__c + REPEAT_TIME;
                    firstTimeList.add(vacRegister);
                    break;
                }
            }  
        }
        
        update firstTimeList;
    }
    global void finish(Database.BatchableContext BC){}   
}