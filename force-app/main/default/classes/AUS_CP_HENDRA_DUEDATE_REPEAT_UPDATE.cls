/*
@@ Puropose: (Scheduled batch class) Update vaccination due date forhistorical  records only forHendra Second Dose for repeat vaccination
@@ Author: Kaushik Ghosh(Cognizant Technology Solutions) 
@@ Reference: 

Modifcation LOG:

Date             Author Name            DEFECT NO                    Description
-------------------------------------------------------------------------------------------------------
AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE gK2 = new AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE();
Database.executeBatch(gk2,100);

*/
global class AUS_CP_HENDRA_DUEDATE_REPEAT_UPDATE implements Database.Batchable<sObject> {        
    
    @TestVisible static final Integer REPEAT_TIME = 364; // in days

    global Database.queryLocator start(Database.BatchableContext BC)
    {   
        
        String query ='SELECT VaccinationDate__c, Id, Due_Date__c, Repeat__c FROM Vaccinationregister__c WHERE Treatment__c = \'Hendra\' AND VaccinationDate__c !=null AND VaccinationType2__c = \'Second Dose\' AND Animal__c!=null AND FirstTime__c = FALSE';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<VaccinationRegister__c> vrList)
    {  
        
        for(Integer j=0; j<vrList.size(); j++){
            vrList[j].repeat__c = true;
            vrList[j].Due_Date__c = vrList[j].VaccinationDate__c + REPEAT_TIME;
        }
        
        if(vRlist.size()>0) {
            update vRlist;
        }
        
    }
    global void finish(Database.BatchableContext BC){}   
}