/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_BatchEventCreateToT_Test.cls
   Description: Test Class for Batch Apex ZTS_EU_Batch_Owner_Expiration_Notice_Sch.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   01-07-2015   1.0     Priya Krishnamurthy               Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_BatchEventCreateToT_Test {
    
    public static void TotOffInsertion(string Type,string market){   
        
        Time_Out_of_Territory__c t = new Time_Out_of_Territory__c();
        t.ZTS_EU_Start_Date__c = date.newInstance(2015, 05, 01);
        t.ZTS_EU_End_Date__c = date.newInstance(2015, 05, 01);
        t.ZTS_EU_Type__c = Type;
        t.ZTS_Market__c = market;
        t.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
        t.ZTS_EU_Status__c = 'Planned';
        insert t;
    }
     public static void TotOnInsertion(string Type,string market){   
         
        Time_Out_of_Territory__c t = new Time_Out_of_Territory__c();
        t.ZTS_EU_Start_Date__c = date.newInstance(2015, 05, 01);
        t.ZTS_EU_End_Date__c = date.newInstance(2015, 05, 01);
        t.ZTS_EU_Type__c = Type;
        t.ZTS_Market__c = market;
        t.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
        t.ZTS_EU_Status__c = 'Planned';
        t.ZTS_EU_Sales_Representative__c = '005F0000003xBXy';
        insert t;
    }
    private static testmethod void ToTInsertOff(){
        TotOffInsertion('Time Off', 'Australia');
        test.startTest();
        ZTS_EU_BatchEventCreateToT TotBatch = new ZTS_EU_BatchEventCreateToT();
        Database.executeBatch(TotBatch);
        test.stopTest();
    }
    private static testmethod void ToTInsertOn(){
        TotOnInsertion('Time On', 'Australia');
        test.startTest();
        ZTS_EU_BatchEventCreateToT TotBatch = new ZTS_EU_BatchEventCreateToT();
        Database.executeBatch(TotBatch);
        test.stopTest();
    }
}