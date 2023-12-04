public with sharing class PIT_TestOrderedTriggerService {

    public static void setCostValue(List<PIT_Test_Ordered__c> testOrderedList) {

        Map<id, String> recordTypeIdToTestTypeMap = getRecordTypeIdToTestTypeMap();
        Map<String, PIT_Test_Cost__c> costList = PIT_Test_Cost__c.getAll();
        
        for(PIT_Test_Ordered__c testOrdered : testOrderedList) 
        {
            testOrdered.PIT_Cost__c = null;
            for(String testCostName : costList.keySet()) 
            {
                PIT_Test_Cost__c currentTestCost = costList.get(testCostName);
                if(currentTestCost.PIT_Diagnostic_Lab__c == testOrdered.PIT_Diagnostic_Lab__c 
                    && currentTestCost.PIT_Test__c == testOrdered.PIT_Test__c
                    && currentTestCost.PIT_Type__c == recordTypeIdToTestTypeMap.get(testOrdered.RecordTypeId)) 
                {
                    testOrdered.PIT_Cost__c = currentTestCost.PIT_Cost__c;
                }
            }
            
            if(testOrdered.PIT_Cost__c == null) {
                testOrdered.addError('There is no cost deifned for this test: Diagnostic Lab: ' + testOrdered.PIT_Diagnostic_Lab__c + '; Test: '+ testOrdered.PIT_Test__c +'; Test Type: ' + recordTypeIdToTestTypeMap.get(testOrdered.RecordTypeId) );
            }
        }
    }
    
    
    private static Map<id, String> getRecordTypeIdToTestTypeMap() {
        Map<id, String> recordTypeIdToTestTypeMap = new Map<id, String>();
        
        for(RecordType rt : [SELECT Id, DeveloperName 
                                  FROM RecordType 
                                     WHERE SObjectType = 'PIT_Test_Ordered__c'
                                     AND DeveloperName IN ('PIT_Tissue', 'PIT_Swab', 'PIT_Sow_Serology', 'PIT_Pig_Serology')]) {
                                     
            
           if(rt.DeveloperName == 'PIT_Tissue') {            
                recordTypeIdToTestTypeMap.put(rt.id, 'PAHUS_TISSUE_TEST');
           }
           if(rt.DeveloperName == 'PIT_Swab') {                            
                recordTypeIdToTestTypeMap.put(rt.id, 'PAHUS_SWAB_TEST');
           }     
           if(rt.DeveloperName == 'PIT_Sow_Serology' || rt.DeveloperName == 'PIT_Pig_Serology') {            
                recordTypeIdToTestTypeMap.put(rt.id, 'PAHUS_SEROLOGY_TEST');
           }  
                                     
        }     
        
        return recordTypeIdToTestTypeMap;
    }
}