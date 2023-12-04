@isTest
public class ZTS_EU_Account_Segmentation_Rating_Test{
   
    public static String uk='United Kingdom';
    public static testMethod void validateInsert(){
        String busUnitRecordTypeId = [SELECT Id FROM RecordType 
                                        WHERE DeveloperName = 'Business_Unit'].Id;
        
        ZTS_EU_Species_Product__c bUnit = TestUtilities.createNoInsertBusUnit('Companion Animals','Business Unit',uk,'CA',busUnitRecordTypeId);
        insert bUnit;
        
        
        test.startTest();
           
            Account_Segmentation_threshold__c threshold1 = TestUtilities.createNoInsertAccountSegmentationThreshold(uk,'CA',1000,3000,'C1');
            insert threshold1;
            Account_Segmentation_threshold__c threshold2 = TestUtilities.createNoInsertAccountSegmentationThreshold(uk,'CA',0,2000,'C2');
            insert threshold2; // between the min and max of first record
            system.debug(''+threshold2);
            
            List<Account_Segmentation_threshold__c> testThreshold2 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold2.Id LIMIT :1];
            System.assertEquals(1000,testThreshold2[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            List<Account_Segmentation_threshold__c> testThreshold1 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold1.Id LIMIT :1];
            System.assertEquals(2000,testThreshold1[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            Account_Segmentation_threshold__c threshold3 = TestUtilities.createNoInsertAccountSegmentationThreshold(uk,'CA',0,500,'C0');
            insert threshold3; // first record check
            List<Account_Segmentation_threshold__c> testThreshold3 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold3.Id LIMIT :1];
            System.assertEquals(0,testThreshold3[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            List<Account_Segmentation_threshold__c> testThreshold02 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold2.Id LIMIT :1];
            System.assertEquals(500,testThreshold02[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            Account_Segmentation_threshold__c threshold4 = TestUtilities.createNoInsertAccountSegmentationThreshold(uk,'CA',0,4000,'C4');
            insert threshold4; //last record check
            List<Account_Segmentation_threshold__c> testThreshold4 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold4.Id LIMIT :1];
            System.assertEquals(3000,testThreshold4[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            Account_Segmentation_threshold__c threshold5 = TestUtilities.createNoInsertAccountSegmentationThreshold(uk,'CA',0,3500,'C3');
            insert threshold5; // between the min and max of any record
            List<Account_Segmentation_threshold__c> testThreshold5 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold5.Id LIMIT :1];
            System.assertEquals(3000,testThreshold5[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            List<Account_Segmentation_threshold__c> testThreshold04 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold4.Id LIMIT :1];
            System.assertEquals(3500,testThreshold04[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            delete threshold5; //checking deletion of record
            List<Account_Segmentation_threshold__c> testThreshold004 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold4.Id LIMIT :1];
            System.assertEquals(3000,testThreshold004[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  
            
            threshold1.ZTS_EU_Threshold_Maximum_Value_Potential__c =2700;
            update threshold1; // checking update of records due to change in max
            List<Account_Segmentation_threshold__c> testThreshold0004 =[Select ZTS_EU_Threshold_Minimum_Value_Potential__c,ZTS_EU_Threshold_Maximum_Value_Potential__c from Account_Segmentation_threshold__c where Id = : threshold4.Id LIMIT :1];         
         //   System.assertEquals(2700,testThreshold0004[0].ZTS_EU_Threshold_Minimum_Value_Potential__c);  

            
            
            //NC REVIEW Please add more asserts. We don't want just test coverage. We want real tests.
        test.stopTest();
        
        
    }
   
}