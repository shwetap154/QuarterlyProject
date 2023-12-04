/**
* @ClassName    : AnimalSupportAlignedReps
* @SystemChange : SC-009661
* @CreatedOn    : 31/12/2022
* @CreatedBy    : Prasun Dubey (Cognizant)
* @Description  : Class contains invocable method called from Case After Insert/Update flow to get the list of users 
				  aligned to account and have the same species as of Species added in Case Animal record.
**/

global class AnimalSupportAlignedReps {
    
    public static List<String> includedSIBFlagBusinessUnits = new List<String>{'Petcare','Diagnostics'};

    // Invocable class returns the aligned users based on Case Animal species  
    @InvocableMethod(label='Get Aligned Reps' description='Method' category= 'Account')
    public static CaseToAlignedRepsObject[] sentRepNotification(List<String> caseIds){
        
        List<ZTS_US_Case_Animal__c> casePatients = new List<ZTS_US_Case_Animal__c>();
        casePatients = [Select Id,ZTS_US_Case__c,ZTS_US_Case__r.AccountId,ZTS_US_Animal__c,ZTS_US_Animal__r.ZTS_US_Species__c 
                      From ZTS_US_Case_Animal__c Where ZTS_US_Case__c =: caseIds];
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id,List<ZTS_US_Case_Animal__c>> accountToCasePatientMap = new Map<Id,List<ZTS_US_Case_Animal__c>>();
        Map<Id,ZTS_US_Case_Animal__c> caseMap = new Map<Id,ZTS_US_Case_Animal__c>();
        Map<Id,Set<String>> caseToUserMap = new Map<Id,Set<String>>();
        
        for(ZTS_US_Case_Animal__c casePatient: casePatients){
            if(casePatient.ZTS_US_Case__r.AccountId != null){
                accountIds.add(casePatient.ZTS_US_Case__r.AccountId);
                if(accountToCasePatientMap.containsKey(casePatient.ZTS_US_Case__r.AccountId))
            		accountToCasePatientMap.get(casePatient.ZTS_US_Case__r.AccountId).add(casePatient);
                else
                    accountToCasePatientMap.put(casePatient.ZTS_US_Case__r.AccountId,new List<ZTS_US_Case_Animal__c>{casePatient});
                caseMap.put(casePatient.ZTS_US_Case__c, casePatient);
            }
        }
        
            //Getting field force details of aligned reps
            Map<Id,Account> accounts = new Map<Id,Account>([
                SELECT Id,   Name, Company_Specialty__c,ZTS_EU_Zip_Postal_Code__c,OwnerId,ZTS_EU_Market__c,BillingStreet,  BillingCity,  BillingState,BillingCountry, BillingPostalCode,
                (SELECT Id, Name,  ZTS_EU_Account__c, Account_Market__c, ZTS_NotificationUser__c, ZTS_AccountTerritory__c, Account_Type__c, ZTS_EU_Active__c, ZTS_City__c, 
             ZTS_EU_Employee__c,ZTS_EU_Position__r.ZTS_EU_Employee__r.Sharing_Business_Unit__c, ZTS_EU_Employee_Id__c,ZTS_Employee_ID__c, ZTS_Field_Force_Name__c, ZTS_EU_Employee_Role__c, ZTS_EU_Is_Active__c, ZTS_EU_Market__c,ZTS_EU_Position__c,
             ZTS_SIB_Flag__c, Standard_Territory_ID__c, ZTS_EU_Territory__c,
             ZTS_AccountTerritory__r.ZTS_EU_Territory__r.ZTS_EU_Type__c
             FROM Account_Positions__r WHERE ZTS_EU_Employee__c != 'Vacant Vacant' AND ZTS_EU_Employee__c != ' '
                ) FROM Account  WHERE Id IN : accountIds]); 
            
            // Custom metadata to maintain mapping of field force to species they should get notification for.
            Map<String,String> caseToUserSpeciesMap = new Map<String,String>();
            List<CaseSpeciesMapping__mdt> mdtRecords = [Select Case_Species__c,Rep_Species__c	From CaseSpeciesMapping__mdt Where Market__c = 'United States'];
            
            for(CaseSpeciesMapping__mdt mdtRecord:mdtRecords){
                caseToUserSpeciesMap.put(mdtRecord.Case_Species__c,mdtRecord.Rep_Species__c);
            }
            
            for(Id accountId: accountIds){
                List<ZTS_US_Case_Animal__c> caseAnimals = accountToCasePatientMap.get(accountId);
                for(ZTS_US_Case_Animal__c caseAnimal : caseAnimals){
                    if(accounts.get(accountId).Account_Positions__r != null){
                        List<ZTS_EU_Account_Position__c> alignments = new List<ZTS_EU_Account_Position__c>();
                        alignments = accounts.get(accountId).Account_Positions__r;
                        for(ZTS_EU_Account_Position__c employee: alignments){
                        // check SIB flag for applicable business units
                        if(employee.ZTS_EU_Position__c != null && employee.ZTS_EU_Position__r.ZTS_EU_Employee__c != null && employee.ZTS_EU_Position__r.ZTS_EU_Employee__r.Sharing_Business_Unit__c != null && 
                           includedSIBFlagBusinessUnits.contains(employee.ZTS_EU_Position__r.ZTS_EU_Employee__r.Sharing_Business_Unit__c) && !employee.ZTS_SIB_Flag__c){
                               continue;
                           }
                        // Check if the field force is matching with animal species or adding field force which will get the notification for all types of species
                        if(caseToUserSpeciesMap.get(caseAnimal.ZTS_US_Animal__r.ZTS_US_Species__c) == 'General'
                           || ( employee.ZTS_EU_Position__c != null && employee.ZTS_EU_Position__r.ZTS_EU_Employee__c != null && employee.ZTS_EU_Position__r.ZTS_EU_Employee__r.Sharing_Business_Unit__c != null &&
                               employee.ZTS_EU_Position__r.ZTS_EU_Employee__r.Sharing_Business_Unit__c.containsIgnoreCase(caseToUserSpeciesMap.get(caseAnimal.ZTS_US_Animal__r.ZTS_US_Species__c)))){
                                   if(caseToUserMap.containsKey(caseAnimal.ZTS_US_Case__c)){
                                       caseToUserMap.get(caseAnimal.ZTS_US_Case__c).add(employee.ZTS_Employee_ID__c);
                                   }else{
                                       caseToUserMap.put(caseAnimal.ZTS_US_Case__c, new Set<String>{employee.ZTS_Employee_ID__c});
                                   }
                               }
                        }
                    }
                }
            }
            
            //return list of users aligned for particular species or eligible for notifications.
        List<CaseToAlignedRepsObject> returnWrap = new List<CaseToAlignedRepsObject>();
        
        for(Id relatedCase : caseIds){
            CaseToAlignedRepsObject objWrapper = new CaseToAlignedRepsObject();
            objWrapper.caseId = relatedCase;
            objWrapper.userIds = new List<String>();
            if(caseToUserMap.containsKey(relatedCase)){
            	objWrapper.userIds.addAll(caseToUserMap.get(relatedCase));
            }
                    returnWrap.add(objWrapper);
                }
                
                return returnWrap;
    }
    
    global class CaseToAlignedRepsObject {
        @InvocableVariable
        global string caseId; 
        
        @InvocableVariable
        global List<String> userIds; 
    }
}