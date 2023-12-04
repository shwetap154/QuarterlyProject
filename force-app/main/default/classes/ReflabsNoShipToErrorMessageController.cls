public with sharing class ReflabsNoShipToErrorMessageController {
    
    @AuraEnabled
    public static Boolean isAccountWithNoShipTo( String caseId )  {

        List<Case> caseRecord = [ SELECT Id, Has_RefLabs_Multiple_Ship_To__c
                                    FROM Case 
                                    WHERE Id = :caseId 
                                ];
                                            
        return  ( !caseRecord.isEmpty() && !caseRecord[0].Has_RefLabs_Multiple_Ship_To__c );  
    }
}