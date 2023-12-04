@isTest
public class PIT_OrderTriggerHandler_Test
{
    static testMethod void beforeInsertTest()
    {
        Test.StartTest();
        List<ZTS_EU_Territory__c> lstUSTerritory = new List<ZTS_EU_Territory__c>();
        
        lstUSTerritory = ZTS_DataUtilityTest.createCustomTerritory(1);
        INSERT lstUSTerritory ;
        
        ZTS_EU_Species_Product__c objProd = new ZTS_EU_Species_Product__c();
        objProd.ZTS_US_PRD_ID__c ='0001';
        objProd.ZTS_US_Product_ID__c= '0001';
        objProd.ZTS_US_Cost__c=2;
        INSERT objProd;
        
        PIT_Budget_Allocation__c objBudallocaction= new PIT_Budget_Allocation__c();
        objBudallocaction.PIT_External_ID__c = '0001';
        INSERT objBudallocaction;
        
        
            
        PIT_Order__c objOrder=new PIT_Order__c();
        //objOrder.PIT_Account__c='001i000000zgBZ1';
        objOrder.PIT_Status__c='open';
        //objOrder.PIT_Budget_Allocation_Territory__c='a24e0000000Pv6q';
        //objOrder.PIT_Product__c='a1ci0000000JvLV';
        //objOrder.PIT_Area__c='a1ni0000000gnCJ';
        
        objOrder.PIT_Quantity__c=10;
        objOrder.PIT_Total_Cost__c=10000;
        objOrder.PIT_Budget_Allocation_Territory__c=objBudallocaction.Id;
        objOrder.PIT_Registration_Date__c=system.today();
        objOrder.PIT_Territory__c =lstUSTerritory[0].Id;
        objOrder.PIT_Product__c =objProd.Id;
        INSERT objOrder;
        Test.StopTest();
        
    }
}